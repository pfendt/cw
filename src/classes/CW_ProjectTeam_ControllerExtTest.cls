@isTest(seeAllData=false)
private class CW_ProjectTeam_ControllerExtTest {

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

  private static testMethod void myUnitTest() 
  {
  
    // Inserting testing agency accounts.
    List<Account> testAgencyAccounts = new List<Account>();
    for(Integer i = 0;i < COUNTER;i++) 
    {
      testAgencyAccounts.add(CW_TestUtility.createAccount('Testing Agency Account - ' + i,null,'Customer'));
    }
    insert testAgencyAccounts;
    system.debug('Test Agency Accounts : ' + testAgencyAccounts);
    
    Account objAccount = new Account();
    objAccount.Name = 'Test Account';
    objAccount.CurrencyIsoCode = 'USD';
    INSERT objAccount;
    
    User testUsers= CW_TestUtility.createUser('first','last','System Administrator',true);
    
   // insert testUsers; 
    system.debug('Test Users : ' + testUsers); 
    
    
    
    // Extracting profileId.
  /*  List<Profile> profile = [SELECT Id FROM Profile WHERE Name like '%system%' limit 1];
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
    }*/
    
    
    
    //ks
    List<Contact> testcontact = new List<Contact>();
    testcontact.add(new Contact(
    AccountId = objAccount.Id,
    Agency_User__c = testUsers.Id,
    LastName = 'Test abc'
    ));
    insert testcontact;
    //ks
    
    // Inserting marketing campaign records.
    List<IMC_Marketing_Campaign__c> testMarketingCampaigns = new List<IMC_Marketing_Campaign__c>();
    for(Integer i = 0;i < COUNTER;i++) {
      testMarketingCampaigns.add(CW_TestUtility.createMarketingCampaign('Test Marketing Campaign - ' + i, null, testAgencyAccounts.get(i).Id));
    }
    insert testMarketingCampaigns;
    system.debug('Test Marketing Campaigns : ' + testMarketingCampaigns);
  
   
  // Insertign Project Team members
  List<String> teamRoleNames = new List<String>();
  teamRoleNames.addAll(marketingCampaignTeamRolesMap.KeySet());
  List<CW_Team_Member__c> testProjectTeamMembers = new List<CW_Team_Member__c>();
    for(Integer i = 0;i < COUNTER;i++) {
      testProjectTeamMembers.add(new CW_Team_Member__c(
       Role__c = teamRoleNames.get(i),
       User__c = testUsers.Id
      ));
    }
    system.debug('Test Project Team Members : b4 insert' + testProjectTeamMembers); 
    insert testProjectTeamMembers;
    system.debug('Test Project Team Members : ' + testProjectTeamMembers);
    
    
    
  /*  // Insertign Project Team members
    Project_Team_Member__c teammember = new Project_Team_Member__c();
    teammember.Project__c = testMarketingCampaigns.get(0).Id;
    teammember.Team_Member_Role__c = teamRoleNames.get(0);
    teammember.User__c = testUsers.get(0).Id;
    insert teammember; */
    
    
   //Inserting Confidential Folder
    
   ConfidentialFolder__c conFolder = new ConfidentialFolder__c();
        conFolder.Name = 'sample folder';
        conFolder.Initiative__c = testMarketingCampaigns[0].id;
   insert conFolder;
   System.debug('conFolder#######'+conFolder.id);
    
   System.test.startTest();
        ApexPages.StandardController stdcontroller = null;
        CW_ProjectTeam_ControllerExt ext = null;
       
        stdcontroller = new ApexPages.StandardController(conFolder);
        ApexPages.currentPage().getParameters().put('fld', conFolder.id);
        ID idNew = ApexPages.currentPage().getParameters().get('fld');
        system.debug('fid is: '+idNew);
        ext  = new CW_ProjectTeam_ControllerExt(stdcontroller);
        ext.member.User__c=testUsers.id;
        ext.goBack();
        ApexPages.currentPage().getParameters().put('retURL','home/home.jsp');
        ext.goBack();
        ext.saveMember();
        //ProjectTeam_ControllerExt.createShareAndCollab();
        CW_ProjectTeam_ControllerExt.createShareAndCollab(testProjectTeamMembers[0].id);
   System.test.stopTest();
    
 }
 
 private static testMethod void myUnitTest1() 
  {
  
    // Inserting testing agency accounts.
    List<Account> testAgencyAccounts = new List<Account>();
    for(Integer i = 0;i < COUNTER;i++) 
    {
      testAgencyAccounts.add(CW_TestUtility.createAccount('Testing Agency Account - ' + i,null,'Customer'));
    }
    insert testAgencyAccounts;
    system.debug('Test Agency Accounts : ' + testAgencyAccounts);
    
    Account objAccount = new Account();
    objAccount.Name = 'Test Account';
    objAccount.CurrencyIsoCode = 'USD';
    INSERT objAccount;
    
    User testUsers= CW_TestUtility.createUser('first','last','System Administrator',true);
    
   // insert testUsers; 
    system.debug('Test Users : ' + testUsers); 
    
    
    
    // Extracting profileId.
  /*  List<Profile> profile = [SELECT Id FROM Profile WHERE Name like '%system%' limit 1];
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
    }*/
    
    
    
    //ks
    List<Contact> testcontact = new List<Contact>();
    testcontact.add(new Contact(
    AccountId = objAccount.Id,
    Agency_User__c = testUsers.Id,
    LastName = 'Test abc'
    ));
    insert testcontact;
    //ks
    
    // Inserting marketing campaign records.
    List<IMC_Marketing_Campaign__c> testMarketingCampaigns = new List<IMC_Marketing_Campaign__c>();
    for(Integer i = 0;i < COUNTER;i++) {
      testMarketingCampaigns.add(CW_TestUtility.createMarketingCampaign('Test Marketing Campaign - ' + i, null, testAgencyAccounts.get(i).Id));
    }
    insert testMarketingCampaigns;
    system.debug('Test Marketing Campaigns : ' + testMarketingCampaigns);
  
   
  // Insertign Project Team members
  List<String> teamRoleNames = new List<String>();
  teamRoleNames.addAll(marketingCampaignTeamRolesMap.KeySet());
  List<CW_Team_Member__c> testProjectTeamMembers = new List<CW_Team_Member__c>();
    for(Integer i = 0;i < COUNTER;i++) {
      testProjectTeamMembers.add(new CW_Team_Member__c(
       Role__c = teamRoleNames.get(i) ,
       User__c = testUsers.Id     
      ));
    }
    system.debug('Test Project Team Members : b4 insert' + testProjectTeamMembers); 
    insert testProjectTeamMembers;
    system.debug('Test Project Team Members : ' + testProjectTeamMembers);
    
    
    
  /*  // Insertign Project Team members
    Project_Team_Member__c teammember = new Project_Team_Member__c();
    teammember.Project__c = testMarketingCampaigns.get(0).Id;
    teammember.Team_Member_Role__c = teamRoleNames.get(0);
    teammember.User__c = testUsers.get(0).Id;
    insert teammember; */
    
    
   //Inserting Confidential Folder
    
   ConfidentialFolder__c conFolder = new ConfidentialFolder__c();
        conFolder.Name = 'sample folder';
        conFolder.Initiative__c = testMarketingCampaigns[0].id;
   insert conFolder;
   System.debug('conFolder#######'+conFolder.id);
    
   System.test.startTest();
        ApexPages.StandardController stdcontroller = null;
        CW_ProjectTeam_ControllerExt ext = null;
       
        stdcontroller = new ApexPages.StandardController(conFolder);
        ApexPages.currentPage().getParameters().put('fld', conFolder.id);
        ID idNew = ApexPages.currentPage().getParameters().get('fld');
        system.debug('fid is: '+idNew);
        ext  = new CW_ProjectTeam_ControllerExt(stdcontroller);
        //ext.member.User__c=testUsers.id;
        ext.goBack();
        ApexPages.currentPage().getParameters().put('retURL','home/home.jsp');
        ext.goBack();
        ext.saveMember();
        //ProjectTeam_ControllerExt.createShareAndCollab();
        CW_ProjectTeam_ControllerExt.createShareAndCollab(testProjectTeamMembers[0].id);
   System.test.stopTest();
    
 }
 
 
 
 
}