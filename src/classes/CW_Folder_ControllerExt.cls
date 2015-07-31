public class CW_Folder_ControllerExt  
{
    public ConfidentialFolder__c folder {get;set;}
    ApexPages.StandardController std;
    IMC_Marketing_Campaign__c campaign;
    public String campaignID {get;set;}
    String confidentialStr = '';
    public Boolean confidential {get;set;} {confidential = false;}
    public String title {get;set;} {title = 'New Folder';}
    ID folderID;
    
    public CW_Folder_ControllerExt(ApexPages.StandardController stdc)
    {
        std = stdc;
        campaignID = ApexPages.currentPage().getParameters().get('cam');
        confidentialStr = ApexPages.currentPage().getParameters().get('con');
        if ((confidentialStr != null) && (confidentialStr.equals('1')))
        {
            confidential = true;
            title = 'New Confidential Folder';
        }
        
        if ((campaignID == null) || (campaignID.length() < 1))
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'INVALID PAGE URL: NO CAMPAIGN ID PARAMETER'));
        }
        
        folder = new ConfidentialFolder__c(); // instantiate this as a placeholder, but it's only used for Confidential Folders
        folder.Initiative__c = campaignID;
        campaign = [SELECT Id, FolderID__c FROM IMC_Marketing_Campaign__c WHERE Id =: campaignID];
    }
    
    public PageReference saveFolder()
    {
        PageReference pr;
        
        try
        {
            if ((folder.Name == null) || (folder.Name.length() < 1))
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Folder Name is Required'));
                return null;               
            }

            if (confidential)
            {
                Database.SaveResult sr = Database.insert(folder);
                if (sr.isSuccess())
                {
                    folderID = sr.getId(); 
                    createBoxFolder(folderID, campaignID); 
                    Map<Id,CW_Team_Member__c> members = new Map<Id,CW_Team_Member__c>([SELECT Id, Name, ConfidentialFolder__c, User__c, Initiative__c 
                                                            FROM CW_Team_Member__c WHERE Initiative__c =: folder.Initiative__c]); 
                    if (members.size() > 0)
                        createCollaborations(members.keyset(),folderID);
                }              
                
                folder = [SELECT Id, Name FROM ConfidentialFolder__c WHERE Id =: folderID];
                pr = new ApexPages.StandardController(folder).view();
            }
            else if (campaign != null)
            {
                Box.Toolkit BoxToolkit = new Box.Toolkit();  // initiatize Box and authenticate
                String boxFolderID = BoxToolkit.getFolderIdByRecordId(campaignID);
                system.debug('ks1 boxFolderID :' + boxFolderID);
                if ((boxFolderID == null) || (boxFolderID.length() < 1))
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, BoxToolkit.mostRecentError));
                    return null;                     
                }  
                
                String newFolderID = BoxToolkit.createFolder(folder.Name, boxFolderID, null);
                system.debug('ks1 newFolderID :' + newFolderID);
                if (newFolderID == null) 
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, BoxToolkit.mostRecentError));
                    return null;                     
                } 
                
                BoxToolkit.commitChanges();
                pr = new ApexPages.StandardController(campaign).view();
            }

        }
        catch (Exception e)
        {
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            return null;            
        }
        
        pr.setRedirect(true);
        return pr;
    }
    
    @future (callout=true)    
    public static void createBoxFolder(ID folderRecID, String campaignID)
    {
        Box.Toolkit BoxToolkit;
        
        ConfidentialFolder__c cf = [SELECT Id, Name, FolderID__c FROM ConfidentialFolder__c WHERE Id =: folderRecID]; 
        system.debug('ks cf :' + cf);
        system.debug('ks folderRecID :' + folderRecID);
        if (cf != null)
        {            
            BoxToolkit = new Box.Toolkit();  // initiatize Box and authenticate
            String boxFolderID = BoxToolkit.createFolderForRecordId(folderRecID, null, true);
            system.debug('ks2 boxFolderID' + boxFolderID);
            BoxToolkit.commitChanges();
            if (boxFolderID == null)
            {
                System.debug('ERROR CREATING BOX FOLDER: ' + BoxToolkit.mostRecentError);
                cf.addError('BOX ERROR: ' + BoxToolkit.mostRecentError);
                throw new BoxException(BoxToolkit.mostRecentError);
                return;
            }
            else
            {
                cf.FolderID__c = boxFolderID;
                try
                {                   
                    Database.SaveResult sr = Database.update(cf);
                    if (!sr.isSuccess())
                    {
                        Database.Error[] errors = sr.getErrors();
                        for (Database.Error err : errors)
                            System.debug('ERROR UPDATING ConfidentialFolder record with BoxFolderID ' + err.getMessage());
                    }
                }
                catch (Exception e)
                {
                    System.debug(e.getMessage());
                    System.debug(e.getStackTraceString());          
                }
            }
        }
    }

    @future (callout=true)
    public static void createCollaborations(Set<ID> memberIDs, Id folderID)
    {
        try
        {
            List<CW_Team_Member__c> members = [SELECT Id, Name, ConfidentialFolder__c, User__c, Initiative__c, Role__c 
                                                    FROM CW_Team_Member__c WHERE Id IN :memberIDs]; 
            
            List<ConfidentialFolder__Share> newShareList = new List<ConfidentialFolder__Share>();
            List<CW_Team_Member__c> memList = new List<CW_Team_Member__c>();            
            Box.Toolkit BoxToolkit = new Box.Toolkit();  // initiatize Box and authenticate
            
            for (CW_Team_Member__c member : members)
            {
                // create new member for this folder
                CW_Team_Member__c newMember = new CW_Team_Member__c();
                //newMember.Project__c = member.Project__c;
                system.debug('ks folderID :' + folderID);
                system.debug('ks member.User__c :' + member.User__c);
                system.debug('ks member.Role__c :' + member.Role__c);
                newMember.ConfidentialFolder__c = folderID;
                newMember.User__c = member.User__c;
                newMember.Role__c = member.Role__c;
                memList.add(newMember);
                
                // create Share record for member
                ConfidentialFolder__Share cfShare = new ConfidentialFolder__Share(ParentId=folderID, UserOrGroupId=member.User__c);
                cfShare.AccessLevel = 'Edit';
                cfShare.RowCause = Schema.ConfidentialFolder__Share.RowCause.Box_Integration__c;
                newShareList.add(cfShare);  
                system.debug('ks2 member.User__c :' + member.User__c);
                system.debug('ks2 folderID :' + folderID);
                system.debug('ks2 Box.Toolkit.CollaborationType.EDITOR :' + Box.Toolkit.CollaborationType.EDITOR);
                String CollabId = BoxToolkit.createCollaborationOnRecord(member.User__c, folderID, Box.Toolkit.CollaborationType.EDITOR,true);
                system.debug('CollabId :' + CollabId);
                if ((CollabId == null) || (CollabId.length() < 1))
                {
                    System.debug('BOX ERROR: ' + BoxToolkit.mostRecentError);
                    member.addError('BOX ERROR: ' + BoxToolkit.mostRecentError);
                    throw new BoxException(BoxToolkit.mostRecentError);
                }
            }
            BoxToolkit.commitChanges();
            
            List<Database.SaveResult> resList;
            if (memList.size() > 0)
            {
                resList = Database.insert(memList);
                for (Database.SaveResult sr : resList)
                {
                    if (!sr.isSuccess())
                    {
                        Database.Error[] errors = sr.getErrors();
                        for (Database.Error err : errors)
                            System.debug('ERROR INSERTING ConfidentialFolder Project_Team_Member RECORDS: ' + err.getMessage());                                
                    }
                }
            }
            
            if (newShareList.size() > 0)
            {
                resList = Database.insert(newShareList);
                for (Database.SaveResult sr : resList)
                {
                    if (!sr.isSuccess())
                    {
                        Database.Error[] errors = sr.getErrors();
                        for (Database.Error err : errors)
                            System.debug('ERROR INSERTING ConfidentialFolder_Share RECORDS: ' + err.getMessage());                                
                    }
                }
            }        
        }
        catch (BoxException be)
        {
            System.debug(be.getMessage());
            System.debug(be.getStackTraceString());
            throw be;             
        }
        catch (Exception e)
        {
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());                
        }
    }
}