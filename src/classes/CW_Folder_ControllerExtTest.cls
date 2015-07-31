@isTest(seeAllData=false)
private class CW_Folder_ControllerExtTest 
{
    public Boolean confidential = true;
    private static testMethod void testMethod1()
    {
        PageReference newFolderPage = Page.CW_NewFolder;
        system.Test.setCurrentPage(newFolderPage);
        Account acc = CW_TestUtility.createAccount('Testing Agency Account',null,'Customer');
        insert acc;
        IMC_Marketing_Campaign__c campaign = CW_TestUtility.createMarketingCampaign('Test Marketing Campaign', null, acc.Id);
        insert campaign;
        ConfidentialFolder__c conFolder = new ConfidentialFolder__c();
    //    conFolder.Name = 'sample folder';
        conFolder.Name = 'test conf kushal';
        conFolder.Initiative__c = campaign.id;
        insert conFolder;
        User testUsers= CW_TestUtility.createUser('first','last','System Administrator',true);

        List<CW_Team_Member__c> memList = new List<CW_Team_Member__c>();
         CW_Team_Member__c mem1 = new  CW_Team_Member__c(user__c=testUsers.id,Role__c='System Administrator');
        //CW_Team_Member__c mem1 = new  CW_Team_Member__c(user__c='00556000000EBOS',initiative__c=campaign.id);
        CW_Team_Member__c mem2 = new  CW_Team_Member__c(initiative__c=campaign.id);
        memList.add(mem1);
        memList.add(mem2);
        insert memList;
        
        Set<ID> memSet = new Set<ID>();
        memSet.add(mem1.id);
        //memSet.add(mem2.id);
        
        
        
        
        system.test.startTest();
        ApexPages.StandardController stdcontroller = null;
        CW_Folder_ControllerExt ext = null;
        ApexPages.currentPage().getParameters().put('cam',campaign.id);
        ApexPages.currentPage().getParameters().put('con','1');
        stdcontroller = new ApexPages.StandardController(new ConfidentialFolder__c());
        ext  = new CW_Folder_ControllerExt(stdcontroller);
        ext.folder.Name = 'ABC';
        
        ext.saveFolder();
        CW_Folder_ControllerExt.createCollaborations(memSet,conFolder.id);
        CW_Folder_ControllerExt.createBoxFolder(conFolder.ID, campaign.ID );
        
        system.test.stopTest();
        
    } 
    
    private static testMethod void testMethod2()
    {
        PageReference newFolderPage = Page.CW_NewFolder;
        system.Test.setCurrentPage(newFolderPage);
        Account acc = CW_TestUtility.createAccount('Testing Agency Account',null,'Customer');
        insert acc;
        IMC_Marketing_Campaign__c campaign = CW_TestUtility.createMarketingCampaign('Test Marketing Campaign', null, acc.Id);
        insert campaign;
        ConfidentialFolder__c conFolder = new ConfidentialFolder__c();
        conFolder.Name = null;
        conFolder.Initiative__c = campaign.id;
        insert conFolder;
        User testUsers= CW_TestUtility.createUser('first','last','System Administrator',true);
        //testusers.role = 'System Administrator';
        
        lead lead1 = new lead(lastname='sample',company='infy',status='open',CurrencyIsoCode='USD');
        INSERT lead1;
        
        box__FRUP__c box = new box__FRUP__c(box__Record_ID__c=lead1.id);
        insert box;
        Set<ID> memSet = new Set<ID>();
        List<CW_Team_Member__c> memList = new List<CW_Team_Member__c>();
      //CW_Team_Member__c mem1 = new  CW_Team_Member__c(user__c='00556000000EBOS',initiative__c=campaign.id);
        CW_Team_Member__c mem1 = new  CW_Team_Member__c(user__c=testUsers.id,Role__c='System Administrator');
        CW_Team_Member__c mem2 = new  CW_Team_Member__c();
        memList.add(mem1);
        memList.add(mem2);
        insert memList;
        memSet.add(mem1.id);
        //memSet.add(mem2.id);
        system.test.startTest();
        ApexPages.StandardController stdcontroller = null;
        CW_Folder_ControllerExt ext = null;
        ApexPages.currentPage().getParameters().put('cam',campaign.id);
        ApexPages.currentPage().getParameters().put('con','1');
        stdcontroller = new ApexPages.StandardController(new ConfidentialFolder__c());
        ext  = new CW_Folder_ControllerExt(stdcontroller);
        ext.folder.Name = 'ABC';
        ext.confidential= false;
        
        ext.saveFolder();
        CW_Folder_ControllerExt.createCollaborations(memSet,conFolder.id);
        CW_Folder_ControllerExt.createBoxFolder(conFolder.ID, campaign.ID );
        

                system.test.stopTest();
        
    } 

   
     

}