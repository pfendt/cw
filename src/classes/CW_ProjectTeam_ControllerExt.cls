public class CW_ProjectTeam_ControllerExt 
{
    ApexPages.StandardController stdc;
    public CW_Team_Member__c member {get;set;}
    public ConfidentialFolder__c folder {get;set;}
    
    public CW_ProjectTeam_ControllerExt(ApexPages.StandardController std)
    {
        stdc = std;
        ID folderID = ApexPages.currentPage().getParameters().get('fld');
        System.debug(' folderID#####'+ folderID);
        ID campaignID = ApexPages.currentPage().getParameters().get('cam');
        folder = [SELECT Id, Name, Initiative__c FROM ConfidentialFolder__c WHERE Id =: folderID];
        member = new CW_Team_Member__c();
        member.ConfidentialFolder__c = folder.Id;
        member.Initiative__c = campaignID;
    }

    public PageReference goBack()
    {
    PageReference pr = null;
    String retURL = ApexPages.currentPage().getParameters().get('retURL');
    
    if ((retURL != null) && (retURL.length() > 0))
        pr = new PageReference(retURL);
    else
        pr = new ApexPages.StandardController(folder).view();
    
    pr.setRedirect(true);
    return pr;
    }
    
    public PageReference saveMember()
    {
        if (member.User__c == null)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'A user must be specified when adding a Project Team Member'));
            return null;            
        }
        
        try
        {
            Database.SaveResult sr = Database.insert(member);
            if (sr.IsSuccess())
            {                
                createShareAndCollab(sr.getId());                      
            }
        }
         catch (Exception e)
        {
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString()); 
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            return null;
        }
    
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Successfully Added New Team Member'));
        PageReference pr = stdc.view(); // go back
        return null;
    }

    @future(callout=true)    
    public static void createShareAndCollab(Id memberID)
    {
        try
        {
            CW_Team_Member__c member = [SELECT Id, Name, ConfidentialFolder__c, User__c, Initiative__c 
                                                    FROM CW_Team_Member__c WHERE Id = :memberID];   
            
            Box.Toolkit BoxToolkit = new Box.Toolkit();  // initiatize Box and authenticate

            ConfidentialFolder__Share cfShare = new ConfidentialFolder__Share(ParentId=member.ConfidentialFolder__c, UserOrGroupId=member.User__c);
            cfShare.AccessLevel = 'Edit';
            cfShare.RowCause = Schema.ConfidentialFolder__Share.RowCause.Box_Integration__c;    
            String CollabId = BoxToolkit.createCollaborationOnRecord(member.User__c,member.ConfidentialFolder__c,Box.Toolkit.CollaborationType.EDITOR,false);
            if ((CollabId == null) || (CollabId.length() < 1))
            {
                System.debug('BOX ERROR: ' + BoxToolkit.mostRecentError);
                member.addError('BOX ERROR: ' + BoxToolkit.mostRecentError);
                throw new BoxException(BoxToolkit.mostRecentError);
            }
            BoxToolkit.commitChanges();
            
            Database.SaveResult sr = Database.insert(cfShare);
            
            if (!sr.isSuccess())
            {
                Database.Error[] errors = sr.getErrors();
                for (Database.Error err : errors)
                    System.debug('ERROR INSERTING ConfidentialFolder_Share RECORDS: ' + err.getMessage());                                
            }                            
        }
         catch (Exception e)
        {
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString()); 
        }
    }
}