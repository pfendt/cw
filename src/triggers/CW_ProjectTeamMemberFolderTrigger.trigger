trigger CW_ProjectTeamMemberFolderTrigger on CW_Team_Member__c (before delete) 
{
    CW_PTMTriggerClass ptmc = new CW_PTMTriggerClass(new CW_Team_Member__c(), Trigger.IsBefore,  Trigger.IsDelete, Trigger.IsAfter,  
                                                Trigger.IsInsert, Trigger.IsUpdate,Trigger.IsExecuting, Trigger.new, Trigger.newmap,
                                                Trigger.old, Trigger.oldmap);
}