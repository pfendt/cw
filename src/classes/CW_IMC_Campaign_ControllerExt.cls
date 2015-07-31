public with sharing class CW_IMC_Campaign_ControllerExt  
{
    ApexPages.StandardController stdController;
    public ID extUserID;
    public User extUser;
    public Id myID {get;set;}
    public sObject myRecord {get;set;}
    public String myPageName {get;set;}
    public IMC_Marketing_Campaign__c campaign {get;set;}
    public ID campaignID {get;set;}
    public IMC_Campaign_Stage__c stage {get;set;}
    public IMC_Campaign_Step__c step {get;set;}
    public IMC_Campaign_Activity__c activity {get;set;}
    Schema.SObjectType objType;
    public String objName {get;set;}
    public String iFrameSrc {get;set;} {iFrameSrc='';}
    public List<ConfidentialFolder__c> folderList {get;set;} {folderList = new List<ConfidentialFolder__c>();}

    public CW_IMC_Campaign_ControllerExt()
    {
    }
    
    public CW_IMC_Campaign_ControllerExt(ApexPages.StandardController stdc)
    {
        stdController = stdc;
        extUserID = System.UserInfo.getUserId();
        myRecord = stdc.getRecord();
        if (myRecord == null)
        {
            String errString = 'PAGE MUST BE EMBEDDED WITHIN A CAMPAIGN/STAGE/STEP/ACTIVITY DETAIL PAGE';
            System.debug(errString);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errString));  
            return;
        }
        
        myID = myRecord.Id;
        try
        {
            PageReference pg = ApexPages.currentPage();
            String myurl = pg.getURL();
            myPageName = myurl.removeStart('/apex/');
            myPageName = myPageName.substringBefore('?');
            System.debug('URL: ' + myurl + ' MYNAME: ' + myPagename);
            objType = myID.getSobjectType();
            if (objType == Schema.getGlobalDescribe().get('IMC_Marketing_Campaign__c'))
            {
                objName = 'CAMPAIGN';
                campaign = (IMC_Marketing_Campaign__c) myRecord;
                campaignID = campaign.Id;
            }
            else if (objType == Schema.getGlobalDescribe().get('IMC_Campaign_Stage__c'))
            {
                objName = 'STAGE';
                stage = [SELECT Id, Initiative__c FROM IMC_Campaign_Stage__c WHERE Id =: myID];
                campaignID = stage.Initiative__c;
            }
            else if (objType == Schema.getGlobalDescribe().get('IMC_Campaign_Step__c'))
            {
                objName = 'STEP';
                step = [SELECT Id, Initiative__c FROM IMC_Campaign_Step__c WHERE Id =: myID];
                campaignID = step.Initiative__c;
            }
            else if (objType == Schema.getGlobalDescribe().get('IMC_Campaign_Activity__c'))
            {
                objName = 'ACTIVITY';
                activity = [SELECT Id, Initiative__c FROM IMC_Campaign_Activity__c WHERE Id =: myID];
                campaignID = activity.Initiative__c;
            }
            else 
            {
                objName = '---INVALID---';
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'THIS PAGE IS USED IN AN INVALID CONTEXT'));
            }
            iFrameSrc = '/apex/box__BOXSection?id=' + campaignID + '&param=' + myPageName;
            System.debug('>> OBJNAME: ' + objName + ' >> IFRAMESRC: ' + iFrameSrc);
        }
        catch (Exception e)
        {
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
    }
    
    public PageReference newFolder()
    {
        String currentURL = ApexPages.currentPage().getURL();
        currentURL = URL.getCurrentRequestUrl().toString();
        currentURL = currentURL.substringAfter('Url:[delegate=');
        String newURL = '/apex/CW_NewFolder?cam=' + campaignID + '&retURL=' + currentURL;
        PageReference pr = new PageReference(newURL);
        // pr.setRedirect(true);
        return pr;
    }
    
    public void getFolderList()
    {
        try
        {
            folderList = [SELECT Id, Name, Initiative__c FROM ConfidentialFolder__c WHERE Initiative__c =: campaignID];
        }
        catch (Exception e)
        {
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
    }
}