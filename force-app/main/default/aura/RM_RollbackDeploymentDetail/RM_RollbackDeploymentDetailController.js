({
    doInit : function(component, event, helper) {
        var recordId = component.get('v.RecordId');
        console.log('getSelectedMetadata@@@123');
        console.log('parentId-------@@@',recordId);
       helper.rollbackMethod(component, event, recordId);
       helper.deleteMethod(component, event, recordId);
	}
})