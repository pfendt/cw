// 
// (c) 2015 Appirio, Inc.
//
// Purpose: A test class for ProjectTeamMemberHandler
//
// 4th Feb 2015    Shikha Gupta    Original    Task Ref. T-358676
//
@isTest(seeAllData=false)
private class CW_TeamMemberTriggerHandlerTest {
	private static final Integer COUNTER = 10;
  private static final Map<String,String> marketingCampaignTeamRolesMap = new Map<String,String>{
  	'Ad Manager' => 'Ad_Manager__c',
    'Brand Manager' => 'Brand_Managers__c',
    'Connection Specialists' => 'Connection_Specialists__c',
    'Connections / IMC' => 'Connections_IMC__c',
    'Content Excellence' => 'Content_Excellence__c',
    'Lead Creative Agency' => 'Lead_Creative_Agency__c',
    'Legal' => 'Legal__c',
    'Other Team Member' => 'Other_Team_Member__c',
    'PAC' => 'PAC__c',
    'Project Manager' => 'Project_Manager__c',
    'Project Sponsor' => 'Project_Sponsor__c'
  };

	private static testMethod void myUnitTest() {
    // Inserting records for custom setting named "CW_Team_Member_Role_Field_Map__c".
    List<CW_Team_Member_Role_Field_Map__c> customSettingData = new List<CW_Team_Member_Role_Field_Map__c>();
    for(String theName : marketingCampaignTeamRolesMap.KeySet()) {
    	customSettingData.add(new CW_Team_Member_Role_Field_Map__c(
    	 Name = theName,
    	 Role_Field_Name__c = marketingCampaignTeamRolesMap.get(theName)
    	));
    }
    insert customSettingData;
    system.debug('Custom Setting Data : ' + customSettingData);

    // Inserting testing agency accounts.
    List<Account> testAgencyAccounts = new List<Account>();
    for(Integer i = 0;i < COUNTER;i++) {
    	testAgencyAccounts.add(CW_TestUtility.createAccount('Testing Agency Account - ' + i,null,'Customer'));
    }
    insert testAgencyAccounts;
    system.debug('Test Agency Accounts : ' + testAgencyAccounts);

    // Inserting testing accounts.
    List<Account> testAccounts = new List<Account>();
    for(Integer i = 0;i < COUNTER;i++) {
      testAccounts.add(CW_TestUtility.createAccount('Testing Account - ' + i,null,'Customer'));
    }
    insert testAccounts;
    system.debug('Test Accounts : ' + testAccounts);

		// Extracting profileId.
		List<Profile> profile = [SELECT Id FROM Profile WHERE Name like '%system%' limit 1];
		system.assert(profile.size() != 0,'Error: Requested profile does not exist.');

    // Inserting users.
    List<User> testUsers = new List<User>();
    for(Integer i = 0;i < COUNTER;i++) {
			testUsers.add(new User(
			  Alias = 'user#' + i,
			  Email = 'user#' + i + '@sfdc.com',
			  LocaleSidKey = 'en_US',
			  TimeZoneSidKey = 'America/Los_Angeles',
			  EmailEncodingKey = 'UTF-8',
			  LanguageLocaleKey = 'en_US',
			  LastName = 'Testing - ' + i,
			  ProfileId = profile[0].Id,
			  UserName= 'user#' + i + '@sfdc.com'
			));
    }
    insert testUsers;
    system.debug('Test Users : ' + testUsers);

    // Inserting contacts.
    List<Contact> testContacts = new List<Contact>();
    for(Integer i = 0;i < COUNTER;i++) {
    	testContacts.add(new Contact(
        lastName = 'Test Contact - ' + i,
        AccountId = testAccounts.get(i).Id,
        Agency_User__c = testUsers.get(i).Id
    	));
    }
    //testContacts.get(9).AccountID = null;
    //testContacts.get(7).Agency_User__c = null;
    insert testContacts;

    // Inserting marketing campaign records.
    List<IMC_Marketing_Campaign__c> testMarketingCampaigns = new List<IMC_Marketing_Campaign__c>();
    for(Integer i = 0;i < COUNTER;i++) {
      testMarketingCampaigns.add(CW_TestUtility.createMarketingCampaign('Test Marketing Campaign - ' + i, null, testAgencyAccounts.get(i).Id));
    }
    insert testMarketingCampaigns;
    system.debug('Test Marketing Campaigns : ' + testMarketingCampaigns);

    // Inserting project team members.
    List<String> teamRoleNames = new List<String>();
    teamRoleNames.addAll(marketingCampaignTeamRolesMap.KeySet());
    List<CW_Team_Member__c> testProjectTeamMembers = new List<CW_Team_Member__c>();
    for(Integer i = 0;i < COUNTER;i++) {
    	testProjectTeamMembers.add(new CW_Team_Member__c(
    	 Initiative__c = testMarketingCampaigns.get(i).Id,
    	 Role__c = teamRoleNames.get(i),
    	 User__c = testUsers.get(i).Id
    	));
    }
    insert testProjectTeamMembers;
    CW_Team_Member__c member = new CW_Team_Member__c();
    member.Initiative__c = testMarketingCampaigns.get(0).Id;
    member.User__c = testUsers.get(0).Id;
    insert member;
    
    system.debug('Test Project Team Members : ' + testProjectTeamMembers);

    // Validating the insertion of sharing records for SObject named "IMC_Marketing_Campaign__c".
    List<IMC_Marketing_Campaign__Share> sharingRecordsInserted = [SELECT Id FROM IMC_Marketing_Campaign__Share];
    system.assert(
      sharingRecordsInserted.size() > 0,
      'ProjectTeamMemberHandler class failed to insert the sharing records for SObject named "IMC_Marketing_Campaign__c".'
    );

    // Updating project team members.
    Integer index = COUNTER - 1;
    for(CW_Team_Member__c theTeamMember : testProjectTeamMembers) {
      if(index >= 0) {
        theTeamMember.User__c = testUsers.get(index).Id;
      }
      index--;
    }
    update testProjectTeamMembers;
    system.debug('Updated Test Project Team Members : ' + testProjectTeamMembers);

    // Validating the insertion of sharing records for SObject named "IMC_Marketing_Campaign__c".
    List<IMC_Marketing_Campaign__Share> sharingRecordsUpdated = [SELECT Id FROM IMC_Marketing_Campaign__Share];
    system.assert(
      sharingRecordsUpdated.size() > 0,
      'ProjectTeamMemberHandler class failed to update the sharing records for SObject named "IMC_Marketing_Campaign__c".'
    );
    
    List<CW_Team_Member__c> deletedProjectTeamMember = new List<CW_Team_Member__c>();
    for(Integer i =0; i<5 ; i++) {
    	deletedProjectTeamMember.add(testProjectTeamMembers.get(i));
    }
    delete deletedProjectTeamMember;
	}
}