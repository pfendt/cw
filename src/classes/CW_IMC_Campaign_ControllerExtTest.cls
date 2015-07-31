@isTest(seeAllData=false)
private class CW_IMC_Campaign_ControllerExtTest
{
  
    private static testMethod void testMethod1() 
    {
        PageReference boxPage = Page.CW_MarketingCampaign_BoxPage;
        Test.setCurrentPage(boxPage);
        Account acc = CW_TestUtility.createAccount('Testing Agency Account',null,'Customer');
        insert acc;
        IMC_Marketing_Campaign__c campaign = CW_TestUtility.createMarketingCampaign('Test Marketing Campaign', null, acc.Id);
        insert campaign;
        
        test.startTest();
        ApexPages.StandardController stdcontroller = null;
        CW_IMC_Campaign_ControllerExt ext = null;
        ApexPages.currentPage().getParameters().put('id', null);
        stdcontroller = new ApexPages.StandardController(new IMC_Marketing_Campaign__c());
        ext  = new CW_IMC_Campaign_ControllerExt(stdcontroller);
        ext.newFolder();
        test.stopTest();
    }
     private static testMethod void testMethod2() 
    {
        PageReference boxPage = Page.CW_MarketingCampaign_BoxPage;
        Test.setCurrentPage(boxPage);
        Account acc = CW_TestUtility.createAccount('Testing Agency Account',null,'Customer');
        insert acc;
        IMC_Marketing_Campaign__c campaign = CW_TestUtility.createMarketingCampaign('Test Marketing Campaign', null, acc.Id);
        insert campaign;
         
        test.startTest();
        ApexPages.StandardController stdcontroller = null;
        CW_IMC_Campaign_ControllerExt ext = null;
        ApexPages.currentPage().getParameters().put('id', campaign.id);
        stdcontroller = new ApexPages.StandardController(campaign);
        ext  = new CW_IMC_Campaign_ControllerExt(stdcontroller);
        ext.newFolder();
        test.stopTest();
    }
    private static testMethod void testMethod3() 
    {
        PageReference boxPage = Page.CW_MarketingCampaign_BoxPage;
        Test.setCurrentPage(boxPage);
        Account acc = CW_TestUtility.createAccount('Testing Agency Account',null,'Customer');
        insert acc;
        IMC_Marketing_Campaign__c campaign = CW_TestUtility.createMarketingCampaign('Test Marketing Campaign', null, acc.Id);
        insert campaign;
        IMC_Campaign_Stage__c stage = CW_TestUtility.createCampaignStage('Test Stage', campaign.Id, null, null);
        insert stage;
        
        test.startTest();
        ApexPages.StandardController stdcontroller = null;
        CW_IMC_Campaign_ControllerExt ext = null;
        ApexPages.currentPage().getParameters().put('id', campaign.id);
        stdcontroller = new ApexPages.StandardController(stage);
        ext  = new CW_IMC_Campaign_ControllerExt(stdcontroller);
        ext.newFolder();
        test.stopTest();
    }
    private static testMethod void testMethod4() 
    {
        PageReference boxPage = Page.CW_MarketingCampaign_BoxPage;
        Test.setCurrentPage(boxPage);
        Account acc = CW_TestUtility.createAccount('Testing Agency Account',null,'Customer');
        insert acc;
        IMC_Marketing_Campaign__c campaign = CW_TestUtility.createMarketingCampaign('Test Marketing Campaign', null, acc.Id);
        insert campaign;
        IMC_Campaign_Stage__c stage = CW_TestUtility.createCampaignStage('Test Stage', campaign.Id, null, null);
        insert stage;
        IMC_Campaign_Step__c step = CW_TestUtility.createCampaignStep('Test Step', campaign.Id, stage.Id);
        insert step; 
        //IMC_Campaign_Activity__c activity = TestUtility.createCampaignActivity('Test Activity', campaign.Id, null);
        //insert activity; 
        test.startTest();
        ApexPages.StandardController stdcontroller = null;
        CW_IMC_Campaign_ControllerExt ext = null;
        ApexPages.currentPage().getParameters().put('id', campaign.id);
        stdcontroller = new ApexPages.StandardController(step);
        ext  = new CW_IMC_Campaign_ControllerExt(stdcontroller);
        ext.newFolder();
        test.stopTest();
    }
    private static testMethod void testMethod5() 
    {
        PageReference boxPage = Page.CW_MarketingCampaign_BoxPage;
        Test.setCurrentPage(boxPage);
        Account acc = CW_TestUtility.createAccount('Testing Agency Account',null,'Customer');
        insert acc;
        IMC_Marketing_Campaign__c campaign = CW_TestUtility.createMarketingCampaign('Test Marketing Campaign', null, acc.Id);
        insert campaign;
        IMC_Campaign_Stage__c stage = CW_TestUtility.createCampaignStage('Test Stage', campaign.Id, null, null);
        insert stage;
        IMC_Campaign_Step__c step = CW_TestUtility.createCampaignStep('Test Step', campaign.Id, stage.Id);
        insert step; 
        IMC_Campaign_Activity__c activity = CW_TestUtility.createCampaignActivity('Test Activity', campaign.Id, null);
        insert activity; 
        test.startTest();
        ApexPages.StandardController stdcontroller = null;
        CW_IMC_Campaign_ControllerExt ext = null;
        ApexPages.currentPage().getParameters().put('id', campaign.id);
        stdcontroller = new ApexPages.StandardController(activity);
        ext  = new CW_IMC_Campaign_ControllerExt(stdcontroller);
        ext.newFolder();
        test.stopTest();
    }
}