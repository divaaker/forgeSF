({
	getDataFunction : function(component,event,helper) {
		var action = component.get('c.getClist');        
        action.setCallback(this,function(response){             
   			 component.set("v.newList", response.getReturnValue());         
        });         
        $A.enqueueAction(action);
	}
})