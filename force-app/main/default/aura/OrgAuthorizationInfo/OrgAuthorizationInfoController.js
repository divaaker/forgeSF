({
    doInit: function(component, event, helper) {
        // Set isModalOpen attribute to true
        var selectedorg = component.get('v.selectedOrg');
        helper.getOrgList(component);
    },
    openModel: function(component, event, helper) {
        // Set isModalOpen attribute to true
        component.set("v.isModalOpen", true);
    },
    
    closeModel: function(component, event, helper) {
        // Set isModalOpen attribute to false  
        component.set("v.isModalOpen", false);
    },
    openpopup: function(component, event, helper) {
        // Set removeOrgPopup attribute to true selectedOrg
        var div = event.currentTarget;
        var recordid = div.getAttribute('data-recordid');
        component.set("v.orgIdToRemove", recordid);
        component.set("v.removeOrgPopup", true);        
    },
    closepopup: function(component, event, helper) {
        // Set removeOrgPopup attribute to true
        component.set("v.removeOrgPopup", false);
    },
    onLoad : function(component, event, helper) {
        component.set("v.isModalOpen", false);
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Loaded!",
            "message": "The record has been Loaded successfully ."
        });
        toastEvent.fire();
    },
    
    submitDetails: function(component, event, helper) {
        // Set isModalOpen attribute to false
        //Add your code to call apex method or do some processing
        component.set("v.isModalOpen", false);
    },
    onSuccess : function(component, event, helper) {
        helper.showSuccess(component, event, helper,'The Org has been added successfully');
        $A.get('e.force:refreshView').fire();
    },
    deleteRecord: function(component,event,helper){
        var recordid = component.get("v.orgIdToRemove");
        component.set("v.removeOrgPopup", false);
        
        var action = component.get("c.deleteOrg");
        action.setParams({orgId:recordid});
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                helper.showSuccess(component, event, helper,'The Org has been removed successfully');
                component.set("v.orgList", response.getReturnValue());
            }
            else {
                console.log("Failed with state: " + state);
            }
            component.set("v.orgList",response.getReturnValue());
        });
        $A.enqueueAction(action);
        
    }, 
    handleOrgAuthorization : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Info',
            message: 'Proceeding..',
            duration:' 5000',
            key: 'info_alt',
            type: 'info',
            mode: 'dismissible'
        });
        toastEvent.fire();
        var div = event.currentTarget;
        var dataorg = div.getAttribute('data-org');
        component.set('v.selectedOrg',dataorg);
        var action2 = component.get("c.insertCustomSetdata");
        action2.setParams({orgId:dataorg});
        action2.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log(response);
                var res =  response.getReturnValue();
                $A.enqueueAction(action);
            }
            else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action2);
        
        var action = component.get("c.returnAccessToken");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var res =  response.getReturnValue();
                console.log('response is @@@',res);
                window.open(res);
            }
            else {
                console.log("Failed with state: " + state);
            }
        });
          //$A.enqueueAction(action);
    },
    handleSubmit :function(component,event,helper){
        $A.get('e.force:refreshView').fire();
    },
    onError :function(component,event,helper){
        helper.showError(component, event, helper)
        $A.get('e.force:refreshView').fire();
    },
    validateOrgName : function(component, event, helper) {
        debugger;
        var inputOrgName = component.find("oid").get("v.value");
         console.log('Input org name'+inputOrgName);
        var inputOrgType = component.find("otid").get("v.value");
        var org = component.get("c.duplicateOrgName");
        org.setParams({"orgname":inputOrgName,"orgtype":inputOrgType});
         org.setCallback(this, function(response) {
            var state = response.getState();
            var Message = response.getReturnValue();
            if (Message === "SUCCESS") {
                helper.showSuccess(component, event, helper,'The Org has been added Successfully');
                $A.get('e.force:refreshView').fire();
            }
            else if (Message === "ERROR") {
               helper.DuplicateValues(component, event, helper,'Org Name already Exists');
            }
            else{
               helper.DuplicateValues(component, event, helper,'Please add a valid Org Name');
            }
        });
        $A.enqueueAction(org);
    },
    //  Pagination methods (Added by Yashpal Singh , Date : 12/03/2020)
    first : function(component, event, helper)
    {
        var orgList = component.get("v.orgList");
        var pageSize = component.get("v.pageSize");
        var paginationList = [];
        for(var i=0; i< pageSize; i++)
        {
            paginationList.push(orgList[i]);
        }
        component.set("v.start",0);
        component.set("v.end",pageSize);
        component.set('v.paginationList', paginationList);
    },
    last : function(component, event, helper)
    {
        var orgList = component.get("v.orgList");
        var pageSize = component.get("v.pageSize");
        var totalSize = component.get("v.totalSize");
        var paginationList = [];
        for(var i=totalSize - totalSize%pageSize; i< totalSize; i++)
        {
            paginationList.push(orgList[i]);
        }
        component.set("v.start",totalSize - totalSize%pageSize);
        component.set("v.end",totalSize - totalSize%pageSize + pageSize);
        component.set('v.paginationList', paginationList);
    },
    next : function(component, event, helper)
    {        
        var orgList = component.get("v.orgList");
        var end = component.get("v.end"); 
       
        var start = component.get("v.start"); 
        var pageSize = component.get("v.pageSize"); 
        var paginationList = [];
        var counter = 0;
        for(var i=end; i<end+pageSize; i++) 
        {
            if(i < orgList.length )
            {
                paginationList.push(orgList[i]);
                counter++ ;
            }
        }
        start = start + counter;
        end = end + counter;
        component.set("v.start",start);
        component.set("v.end",end);
        component.set("v.paginationList", paginationList);
    },
    previous : function(component, event, helper)
    {
        var orgList = component.get("v.orgList");
        var end = component.get("v.end");
        var start = component.get("v.start");
        var pageSize = component.get("v.pageSize");
        var paginationList = [];
        var counter = 0;
        for(var i= start-pageSize; i < start ; i++)
        {
            if(i > -1)
            {
                paginationList.push(orgList[i]);
                counter++;
            }
            else {
                start++;
            }
        }
        start = start - counter;
        end = end - counter;
        component.set("v.start",start);
        component.set("v.end",end);
        component.set("v.paginationList", paginationList);
    }    
})