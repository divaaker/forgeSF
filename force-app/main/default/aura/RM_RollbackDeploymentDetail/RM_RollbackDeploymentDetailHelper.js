({
    rollbackMethod : function(component, event, recordId) {
        var action = component.get("c.RMgetRollbackMetadataMemberMap");
        action.setParams({ 'parentId' : recordId});
        action.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS"){
                var obj=a.getReturnValue();
                if(obj != null){
                    var object=   JSON.parse(obj);
                    console.log('getSeletedMetadataMemberMap@@@1   '+obj) ;
                    console.log('getSeletedMetadataMemberMap@@@2   '+object) ;
                    component.set('v.RollbackMetadataHeader_alldata',object);
                    component.set('v.rollstate',true)
                }
            } 
        });
        
        $A.enqueueAction(action);  
        
    },
    
    deleteMethod : function(component, event, recordId) {
        var action = component.get("c.RMgetDeletedMetadataMemberMap");
        action.setParams({ 'parentId' : recordId});
        action.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS"){
                var obj=a.getReturnValue();
                if(obj != null){
                    var object=   JSON.parse(obj);
                    console.log('getSeletedMetadataMemberMap@@@1   '+obj) ;
                    console.log('getSeletedMetadataMemberMap@@@2   '+object) ;
                    component.set('v.DeletedMetadataHeader_alldata',object);
                    component.set('v.delstate',true)
                }
            } 
        });
        $A.enqueueAction(action);
    }
})