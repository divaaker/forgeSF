@RestResource(urlMapping='/ShivaPostSfArcProjectDetails/*')
global with sharing class TestAPI{
    
    @HttpPost
    global static String doPost(List<OpportunityWrapper> opportunitys){
        
        List<Opportunity> opportunityList = new list<Opportunity>();  
        if(opportunitys.size() >= 1){
            for(OpportunityWrapper opportunity : opportunitys){
                if(opportunity.opportunityId != NULL ){
                    List<String> opportunityIds =  new List<String>{opportunity.opportunityId} ;
                    System.debug('opportunityIds : ' + opportunityIds);
                    Opportunity opps = new Opportunity();
                    opps.Id = opportunity.opportunityId;
                    //opps.Project_ID__c = opportunity.projectId;
                    //opps.Arc_Project_Name__c = opportunity.arcProjectName;             
                    opportunityList.add(opps);             
                    //add opps to list and after forloop update list                                             
                }                
             }
            update opportunityList; 
         }
        return 'success';
    }
      
    global class OpportunityWrapper {
        public String projectId;
        public String arcProjectName;
        public String opportunityId;
    }
}