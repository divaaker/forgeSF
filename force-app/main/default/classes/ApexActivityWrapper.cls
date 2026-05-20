public Class ApexActivityWrapper { 
    @auraEnabled
    public static List<eEventTTask> ApexActivityWrapper () {
        List<eEventTTask> taskEventList = new List<eEventTTask>();
        for (Event evt : [
                SELECT Subject, ActivityDate FROM Event ORDER BY ActivityDate LIMIT 10
                ]) {
            taskEventList.add(new eEventTTask(evt.Subject, evt.ActivityDate));
        }
        for (Task tsk: [
                SELECT Subject, ActivityDate FROM Task ORDER BY ActivityDate LIMIT 10
                ]) {
            taskEventList.add(new eEventTTask(tsk.Subject, tsk.ActivityDate));
        }
        system.debug('taskEventList' + taskEventList);
        return taskEventList;
    }
    
    public class eEventTTask {
      @AuraEnabled
      public String subject { get; set; }
      @AuraEnabled
      public Date activityDate { get; set;}
    
      public eEventTTask(String sub, Date act) {
        subject = sub;
        activityDate = act;
      }
    }
  
}