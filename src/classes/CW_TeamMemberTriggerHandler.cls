//
// 02/03/2015   Shikha Gupta    Original    Task Ref. T-358676
// 07/22/2015   P. Fendt    Avoid adding ConfidentialFolder-related members to Project team (lines 15 & 35)

public class CW_TeamMemberTriggerHandler {

  public static void beforeInsertUpdate(List<CW_Team_Member__c> newList) {
    validateTeamMemberAccount(newList);
  }
  
  private static void validateTeamMemberAccount(List<CW_Team_Member__c> newList) {
    
    Set<Id> setOfProjectTeamMemberUserIds = new Set<Id>();
    for(CW_Team_Member__c theTeamMember : newList) {
      if ((theTeamMember.User__c != null) && (theTeamMember.Initiative__c != null)) {
        setOfProjectTeamMemberUserIds.add(theTeamMember.User__c);
      }
    }
    
    Map<Id, List<Contact>> mapOfUserAndContacts = new Map<Id, List<Contact>>();
    Set<String> publicGroupIds = new Set<String>();
    system.debug('mapOfUserAndContacts 1 : ' + mapOfUserAndContacts);
    system.debug('setOfProjectTeamMemberUserIds :' + setOfProjectTeamMemberUserIds);
    for(Contact theContact : [SELECT Id, Name, Agency_User__c, Account.CW_Public_Group_Id__c FROM Contact WHERE Agency_User__c IN :setOfProjectTeamMemberUserIds]) {
    system.debug('theContact.Account.CW_Public_Group_Id__c :' + theContact.Account.CW_Public_Group_Id__c);
    if(theContact.Account.CW_Public_Group_Id__c != null) {
        system.debug('inside the if stmt 1');
        publicGroupIds.add(theContact.Account.CW_Public_Group_Id__c);
      }
    system.debug('theContact.Agency_User__c :' + theContact.Agency_User__c);
    if(!mapOfUserAndContacts.containsKey(theContact.Agency_User__c)) {
        system.debug('inside if stmt 2');
        mapOfUserAndContacts.put(theContact.Agency_User__c, new List<Contact>());
      }
      mapOfUserAndContacts.get(theContact.Agency_User__c).add(theContact);    
    }
    
    Map<Id, Group> mapOfGroup = new Map<Id, Group>([SELECT Id FROM Group WHERE Id IN :publicGroupIds]);
    
    for(CW_Team_Member__c theTeamMember : newList) {
    system.debug('theTeamMember.User__c :' + theTeamMember.User__c);
    system.debug('theTeamMember.Initiative__c :' + theTeamMember.Initiative__c);
      if ((theTeamMember.User__c != null) && (theTeamMember.Initiative__c != null)) {
          system.debug('inside if stmt 3');
        if(mapOfUserAndContacts.containsKey(theTeamMember.User__c)) {       
            for(Contact contact : mapOfUserAndContacts.get(theTeamMember.User__c)) {
                  if(contact.AccountId == null) {
                    system.debug('contact.AccountId :' + contact.AccountId);
                     theTeamMember.addError(Label.Error_Msg_On_User_Account_Improperly_Configured);
                    break;
                  }
                    else if(contact.Account.CW_Public_Group_Id__c == null || !mapOfGroup.containsKey(contact.Account.CW_Public_Group_Id__c)) {
                    system.debug('contact.Account.CW_Public_Group_Id__c :' + contact.Account.CW_Public_Group_Id__c);
                    theTeamMember.addError(Label.Error_Msg_On_User_Account_Not_Setup_For_Sharing);
                    break;
                  }
                }
        }
        else {
          theTeamMember.addError(Label.Error_Msg_On_User_Not_Setup_For_Sharing);
        }
      }
    }
  }
  
  public static void afterInsertUpdateDeleteUndelete(Map<Id,CW_Team_Member__c> newMap , Map<Id,CW_Team_Member__c> oldMap) {
    shareCampaignRecord(newMap, oldMap);
  }
  
  private static void shareCampaignRecord(Map<Id,CW_Team_Member__c> newMap , Map<Id,CW_Team_Member__c> oldMap) {
    Set<Id> marketingCampaignIds = new Set<Id>();
    Map<Id, Set<Id>> mapOfUserAndIMC = new Map<Id, set<Id>>();
    if(trigger.isInsert || trigger.isUpdate || trigger.isUndelete) {
        for(CW_Team_Member__c teamMember : newMap.values()) {
          if(teamMember.User__c != null && teamMember.Initiative__c != null
                    && (trigger.isInsert || trigger.isUpdate || trigger.isUndelete ||
                    (trigger.isUpdate && (
                    teamMember.User__c != oldMap.get(teamMember.Id).User__c ||
                    teamMember.Initiative__c != oldMap.get(teamMember.Id).Initiative__c)))) {
            marketingCampaignIds.add(teamMember.Initiative__c);
            if(!mapOfUserAndIMC.containsKey(teamMember.User__c)) {
              mapOfUserAndIMC.put(teamMember.User__c, new Set<Id>());
            }
            mapOfUserAndIMC.get(teamMember.User__c).add(teamMember.Initiative__c);
          }
        }
     }

    Set<Id> marketingCampaignIdsToBeRemoved = new Set<Id>();
    Map<Id, Set<Id>> mapOfUserAndIMCToBeRemoved = new Map<Id, set<Id>>();
    if(trigger.isDelete || trigger.isUpdate) {
        for(CW_Team_Member__c teamMember : oldMap.values()) {
          if(teamMember.User__c != null && teamMember.Initiative__c != null
                && (trigger.isDelete ||
                (trigger.isUpdate && (
                teamMember.User__c != newMap.get(teamMember.Id).User__c ||
                teamMember.Initiative__c != newMap.get(teamMember.Id).Initiative__c)))) {
            marketingCampaignIdsToBeRemoved.add(teamMember.Initiative__c);
            if(!mapOfUserAndIMCToBeRemoved.containsKey(teamMember.User__c)) {
              mapOfUserAndIMCToBeRemoved.put(teamMember.User__c, new Set<Id>());
            }
            mapOfUserAndIMCToBeRemoved.get(teamMember.User__c).add(teamMember.Initiative__c);
          }
        }
    }

    if(Trigger.IsDelete) {
      List<CW_Team_Member__c> existingteamMemberList = [SELECT Id, Initiative__c, User__c FROM CW_Team_Member__c WHERE Initiative__c IN :marketingCampaignIdsToBeRemoved AND Id NOT IN :oldMap.keySet()];
      for(CW_Team_Member__c teamMember : existingteamMemberList) {
        marketingCampaignIds.add(teamMember.Initiative__c);
        if(!mapOfUserAndIMC.containsKey(teamMember.User__c)) {
          mapOfUserAndIMC.put(teamMember.User__c, new Set<Id>());
        }
        mapOfUserAndIMC.get(teamMember.User__c).add(teamMember.Initiative__c);
      }
    }

    Set<String> tempGroupIds = new Set<String>();
    Set<String> tempGroupIdsToBeRemoved = new Set<String>();
    Set<String> tempGroupIdsExistingTeamMembers = new Set<String>();

    Map<Id, Set<String>> mapOfUserIdAndPublicGroupIds = new Map<Id, Set<String>>();
    // Removed OR Condition : (Agency_User__c IN  :userIds) - as userIds is not defined
    for(Contact con : [SELECT Id, Account.CW_Public_Group_Id__c, Agency_User__c FROM Contact WHERE (Agency_User__c IN :mapOfUserAndIMC.keySet() OR Agency_User__c IN :mapOfUserAndIMCToBeRemoved.keySet()) AND Account.CW_Public_Group_Id__c != null]) {
      if(mapOfUserAndIMC.containsKey(con.Agency_User__c)) {
        tempGroupIds.add(con.Account.CW_Public_Group_Id__c);
        if(!mapOfUserIdAndPublicGroupIds.containsKey(con.Agency_User__c)) {
          mapOfUserIdAndPublicGroupIds.put(con.Agency_User__c, new Set<String>());
        }
        mapOfUserIdAndPublicGroupIds.get(con.Agency_User__c).add(con.Account.CW_Public_Group_Id__c);
      }
      else if(mapOfUserAndIMCToBeRemoved.containsKey(con.Agency_User__c)) {
        tempGroupIdsToBeRemoved.add(con.Account.CW_Public_Group_Id__c);
      }
    }

    if(Trigger.IsDelete || Trigger.isUpdate) {
      delete [SELECT Id FROM IMC_Marketing_Campaign__Share WHERE ParentId IN  :marketingCampaignIdsToBeRemoved
                             AND UserOrGroupId IN :tempGroupIdsToBeRemoved 
                             AND RowCause = :Schema.IMC_Marketing_Campaign__Share.rowCause.CW_CokeWorks_Share__c
                             AND AccessLevel = 'edit'];
    }

    if(!Trigger.IsDelete) {
      Set<Id> validGroupIds = new Set<Id>();
      for(Group thegroup : [SELECT Id FROM Group WHERE Id IN :tempGroupIds]) {
        validGroupIds.add(thegroup.Id);
      }
  
      Set<String> existingShareRecords = new Set<String>();
      // changed WHERE clause -> ParentId IN :marketingCampaignIds from ParentId IN : mapOfUserAndIMC
      // added UserOrGroupId in the shareRecord SOQL to fix the INC2976726
      for(IMC_Marketing_Campaign__Share shareRecord : [SELECT ParentId, Id , UserOrGroupId FROM IMC_Marketing_Campaign__Share WHERE ParentId IN :marketingCampaignIds
                               AND UserOrGroupId IN :validGroupIds 
                               AND RowCause = :Schema.IMC_Marketing_Campaign__Share.rowCause.CW_CokeWorks_Share__c
                               AND AccessLevel = 'edit']) {
        existingShareRecords.add(shareRecord.UserOrGroupId + '-' + shareRecord.ParentId);
      }
  
      List<IMC_Marketing_Campaign__Share> marketingProgramShareToBeInserted = new List<IMC_Marketing_Campaign__Share>();                    
      for(Id userId : mapOfUserIdAndPublicGroupIds.keySet()) {
        for(String groupId : mapOfUserIdAndPublicGroupIds.get(userId)) {
          if(validGroupIds.contains(groupId) && mapOfUserAndIMC.containsKey(userId)) {
            for(Id campaignId : mapOfUserAndIMC.get(userId)) {
              if(!existingShareRecords.contains(groupId + '-' +campaignId)) {
                marketingProgramShareToBeInserted.add(new IMC_Marketing_Campaign__Share(ParentId = campaignId, UserOrGroupId = groupId, RowCause = Schema.IMC_Marketing_Campaign__Share.rowCause.CW_CokeWorks_Share__c, AccessLevel = 'edit'));
              }
            }
          }
        }
      }
      insert marketingProgramShareToBeInserted;
    }
  }
}