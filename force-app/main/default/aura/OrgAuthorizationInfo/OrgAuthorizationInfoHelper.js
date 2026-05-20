({
	  getOrgList : function(component) {
        var action = component.get("c.getOrgList");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.orgList", response.getReturnValue());
                var orglist=component.get("v.orgList");
                var pagesize=component.get("v.pageSize");
                component.set("v.end",pagesize );
                component.set("v.start",0 );
                component.set("v.totalSize", response.getReturnValue().length);
                var totalsize=component.get("v.totalSize");
                var  pagelist=[];
                for(var i=0;i<pagesize;i++){ 
                    if(i<=(totalsize-1)){
                        pagelist.push(orglist[i]);
                    }
                    else{
                        break;
                    }
                }
                component.set("v.paginationList",pagelist );
                var page=component.get("v.paginationList");
            }
            else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
    } ,
    showSuccess : function(component, event, helper,msg) {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'Success',
                message: msg,
                duration:' 5000',
                key: 'info_alt',
                type: 'success',
                mode: 'pester'
            });
            toastEvent.fire();
        },
    showError : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Error',
            message:'Something went wrong please try again',
            duration:' 5000',
            key: 'info_alt',
            type: 'error',
            mode: 'pester'
        });
        toastEvent.fire();
    },
    DuplicateValues : function(component, event, helper, msg) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Error',
            message:msg,
            duration:' 5000',
            key: 'info_alt',
            type: 'error',
            mode: 'pester'
        });
        toastEvent.fire();
	}
})