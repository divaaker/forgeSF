({
	getData : function(component, event, helper) {
		component.set('v.mycolumns', [
            {label: 'Subject', fieldName: 'subject', type: 'url', typeAttributes: {label: { fieldName: 'sub' }, target: '_blank'}},
            { label: "ActivityDate", fieldName: "activityDate", type: "date-local", typeAttributes:{ month: "2-digit", day: "2-digit" } },
            
        ]);
        var action = component.get("c.ApexActivityWrapper");
        action.setCallback(this, function(response){
            var state = response.getState();
              console.log('state==='+state);
            if(state === "SUCCESS")
            {
     		var response = response.getReturnValue();
            console.log('response==='+JSON.stringify(response));
     		component.set("v.taskEventList2", response);
            }
            else if(state === "INCOMPLETE")
            {
                //do something 
            }
            else if(state === "ERROR")
            {
             var error = response.getError();
             if(error)
             {
                 console.log("error"+error);
             }
            }
        });
        $A.enqueueAction(action);
	}
})