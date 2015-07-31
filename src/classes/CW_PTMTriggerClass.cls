/*
 * Purpose:
 * Add new Campaign Project Team Member(s) to this ConfidentialFolder
 * and also create associated Share records and Box "collaborator" status for these team members for this ConfidentialFolder
 * 
 * 06/11/15:    P. Fendt    original author
 */

public class CW_PTMTriggerClass extends TriggerClass
{
    private static Boolean PTMTriggerClassDejavu = false;  // have we been here before (re-entering the trigger again in same context)
   
    public CW_PTMTriggerClass(sObject o, Boolean IsBefore, Boolean IsDelete, Boolean IsAfter, Boolean IsInsert, Boolean IsUpdate, Boolean IsExecuting,
                          List<sObject> newList, Map<ID,sObject> newmap, List<sObject> oldList, Map<ID,sObject> oldmap)
    {
        super(o, IsBefore, IsDelete, IsAfter, IsInsert, IsUpdate, IsExecuting,
                          newList, newmap, oldList, oldmap);
        this.MainEntry();
    }
    
    public override void MainEntry()
    {
        super.MainEntry(); // set appropriate execution context
        System.debug('CW_PTMTriggerClass: MainEntry() was called');
        PTMTriggerClassDejavu = true;
        
        if (IsDelete)
        {
            try
            {
                List<ConfidentialFolder__Share> shareList = [SELECT Id FROM ConfidentialFolder__Share WHERE ParentId IN :oldMap.keySet()];
                List<Database.DeleteResult> resList;
                
                if (shareList.size() > 0)
                {
                    resList = Database.delete(shareList,false);
                    for (Database.DeleteResult dr : resList)
                    {
                        if (!dr.isSuccess())
                        {
                            Database.Error[] errors = dr.getErrors();
                            for (Database.Error err : errors)
                                System.debug('ERROR DELETING ConfidentialFolder_Share RECORDS: ' + err.getMessage());                                
                        }
                    }
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