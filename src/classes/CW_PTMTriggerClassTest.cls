@isTest(seeAllData=false)
private class CW_PTMTriggerClassTest 
{
  
    private static testMethod void testConstructor() 
    {
        sObject sObj = Schema.getGlobalDescribe().get('ConfidentialFolder__c').newSObject() ;
        User u = CW_TestUtility.createUser('first','last','System Administrator',true);
        Account acc = CW_TestUtility.createAccount('Testing Agency Account',null,'Customer');
        insert acc;
        IMC_Marketing_Campaign__c campaign = CW_TestUtility.createMarketingCampaign('Test Marketing Campaign', null, acc.Id);
        insert campaign;
        ConfidentialFolder__c ptm = new ConfidentialFolder__c();
        //ptm.Name = 'ABC';
        ptm.Initiative__c = campaign.id;
        insert ptm;
        Map<ID,sObject> oldmap = new Map<ID,sObject>();
        oldMap.put(ptm.id, sObj);
        ConfidentialFolder__Share cs = new ConfidentialFolder__Share();
        cs.ParentId = ptm.id;
        cs.UserOrGroupId = u.id;
        cs.AccessLevel = 'Edit';
        insert cs;
        test.startTest();
        CW_PTMTriggerClass ptmInstance = new CW_PTMTriggerClass(sObj, true, true, true, true, true, true, null, null, null, oldMap);
        test.stopTest();
    }
}