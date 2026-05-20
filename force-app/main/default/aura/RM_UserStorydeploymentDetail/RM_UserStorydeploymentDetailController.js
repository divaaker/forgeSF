({
    doInit : function(component, event, helper) {
        var recordId = component.get('v.RecordId');
        console.log('getSelectedMetadata@@@12');
        console.log('parentId-------@@@',recordId);
        var action = component.get("c.RMgetSeletedMetadataMemberMap");
        action.setParams({ 'parentId' : recordId});
        action.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS"){
                var obj=a.getReturnValue();
                var object=   JSON.parse(obj);
                console.log('getSeletedMetadataMemberMap@@@1   '+obj) ;
                console.log('getSeletedMetadataMemberMap@@@2   '+object) ;
                component.set('v.SelectedMetadataHeader_alldata',object);
            } 
        });
        
        $A.enqueueAction(action);  
      
	}
})