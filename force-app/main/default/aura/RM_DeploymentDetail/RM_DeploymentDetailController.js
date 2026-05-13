({
    doInit : function(component) {
        var action = component.get("c.getDeploymentDetailSuccess");
        var action1 = component.get("c.getDeploymentDetailFailure");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                component.set("v.deployDetailListsuccess", response.getReturnValue());
                var deploylist=component.get("v.deployDetailListsuccess");
                console.log('deploylist',deploylist);
                var pagesize=component.get("v.pageSizeSuccess");
                component.set("v.endSuccess",pagesize );
                component.set("v.startSuccess",0 );
                component.set("v.totalSizeSuccess", response.getReturnValue().length);
                var totalsize=component.get("v.totalSizeSuccess");
                var  pagelist=[];
                for(var i=0;i<pagesize;i++){
                    if(i<=(totalsize-1)){
                        pagelist.push(deploylist[i]);
                    }
                    else{
                        break;
                    }
                }
                component.set("v.paginationListSuccess",pagelist );
                var page=component.get("v.paginationListSuccess");
                console.log('page',page);
            }
            else {
                console.log("Failed with state: " + state);
            }
        });
        action1.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.deployDetailListfailure", response.getReturnValue());
                var deploylist=component.get("v.deployDetailListfailure");
                
                var pagesize=component.get("v.pageSizeFailure");
                component.set("v.endFailure",pagesize );
                component.set("v.startFailure",0 );
                component.set("v.totalSizeFailure", response.getReturnValue().length);
                var totalsize=component.get("v.totalSizeFailure");
                var  pagelist=[];
                for(var i=0;i<pagesize;i++){
                    if(i<=(totalsize-1)){
                        pagelist.push(deploylist[i]);
                    }
                    else{
                        break;
                    }
                }
                component.set("v.paginationListFailure",pagelist );
                var page=component.get("v.paginationListFailure");
            }
            else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
        $A.enqueueAction(action1);
        
        
    } ,
    
    closeModel: function(component, event, helper) {
        // Set isModalOpen attribute to false
        component.set('v.rollbackDetailRecordId','');
        component.set("v.isModalOpen", false);
    },
    closequickModel: function(component, event, helper) {
        // Set isModalOpen attribute to false
        component.set('v.deploymentDetailRecordId','');
        component.set("v.quickpopup", false);
    },
    openclonepopup : function(component, event, helper) {
        component.set('v.depbool',false);
        component.set('v.clonepopup', true);
        var div = event.currentTarget;
        var recordId = div.getAttribute('data-id');
        console.log('recordId',recordId);
        component.set("v.deploymentDetailRecordId",recordId);
        helper.getSelectedMetadata(component, recordId);
        component.set('v.selecteddeploymentRecordId',recordId);
        helper.init_Server(component, event, helper,recordId);
        
        // intilize the  SelectedMetadataMembersMap with previous selected metadata
        
        // itrate over this SelectedMetadataHeader_alldata
    },
    
    deployPackage : function(component, event, helper) {
        component.set("v.spinner", true);
        component.set('v.clonepopup', true);
        let finalMetadata = component.get('v.SelectedMetadataMembersMap');
        
        component.set('v.SelectedMetadataMembersMap',finalMetadata);
        var MetadataMembersMap = component.get('v.SelectedMetadataMembersMap');
        var sel = component.find("mySelect");
        var selectTestLevel = sel.get("v.value");
        var specifiedTestClass = '';
        if(selectTestLevel == 'RunSpecifiedTests'){
            specifiedTestClass = component.find("specifiedTestClass").get("v.value");
        }
        component.set('v.testRunPopup',false);
        helper.saveRollbackData(component, event,selectTestLevel,specifiedTestClass,MetadataMembersMap);
        
        component.set('v.testRunPopup',false);
        if(component.get('v.packageZipFile') !== ''){
            helper.showMessage(component,event,'info','Deploying package... pls wait!','500','info','pester');
            helper.deployRequest(component, event, component.get('v.packageZipFile'));
        }else{
            component.set("v.spinner", false);
            helper.showMessage(component,event,'error','Please create package first.','1000','error','sticky');
        }
    },
    quickdatadeployPackage : function(component, event, helper) {
        let finalMetadata = component.get('v.SelectedMetadataMembersMap');
        
        component.set('v.SelectedMetadataMembersMap',finalMetadata);
        var MetadataMembersMap = component.get('v.SelectedMetadataMembersMap');
        var selectTestLevel = 'NoTestRun';
        var specifiedTestClass = '';
        helper.saveRollbackData(component, event,selectTestLevel,specifiedTestClass,MetadataMembersMap);
        component.set('v.quickpopup',false);
        if(component.get('v.quickdatadeploy') !== '' ){
            helper.showMessage(component,event,'info','Deploying package... pls wait!','500','info','pester');
            console.log('quick deploy@@@@@-----------');
            console.log('quickdatadeploy zip',component.get('v.quickdatadeploy'));
            helper.quickdeployRequest(component, event, component.get('v.quickdatadeploy'));
        }else{
            helper.showMessage(component,event,'error','Please create package first.','1000','error','sticky');
        }
        
    },
    rollbackdeployPackage : function(component, event, helper) { 
        
        let finalMetadata = component.get('v.SelectedMetadataMembersMap');
        
        component.set('v.SelectedMetadataMembersMap',finalMetadata);
        var MetadataMembersMap = component.get('v.SelectedMetadataMembersMap'); 
        
        component.set('v.isModalOpen',false);
        if(component.get('v.rollbackdatadeploy') !== '' || component.get('v.deletedatadeploy') !== ''){
            helper.showMessage(component,event,'info','Deploying package... pls wait!','500','info','pester');
            if(component.get('v.myBool') == true){
                helper.deletedeployRequest(component, event, component.get('v.deletedatadeploy'), MetadataMembersMap);
            }
            helper.rollbackdeployRequest(component, event, component.get('v.rollbackdatadeploy'), MetadataMembersMap);
        }else{
            helper.showMessage(component,event,'error','Please create package first.','1000','error','sticky');
        }
    },
    
    deployModal : function(component, event, helper) {
        component.set('v.clonepopup', false);
        component.set('v.testRunPopup',true);
    },
    
    closeModalfordeployment : function(component, event, helper) {
        component.set('v.testRunPopup',false);
        component.set('v.clonepopup', true);
    },
    
    toggleSection : function(component, event, helper) {

        var sectionAuraId = event.target.getAttribute("data-auraId");
        var selectedMetadata = component.get('v.selectedMetaDataType');
        var metaDataWithMembers = component.get('v.MetadataHeader_alldata');
        var sectionDiv = document.getElementById(sectionAuraId);
        var sectionState = sectionDiv.classList.contains('slds-is-close');
        console.log('sectionAuraId-----',sectionAuraId);
        console.log('sectionDiv----',sectionDiv);
        console.log('sectionState----',sectionState);
        var selectedcmpMetadataList='';
        
        if(sectionState){
            component.set("v.spinner", true);
            var action = component.get("c.addMap");
            let parentId = component.get("v.selecteddeploymentRecordId");
            action.setParams({metadataType: sectionAuraId , parentId : parentId});             
            helper.serverSideCall(component,action).then(
                function(res) {
                    
                    for(var i=0;i<metaDataWithMembers.length;i++){
                        if(metaDataWithMembers[i].key==sectionAuraId){
                            if(res.length!=0){
                                metaDataWithMembers[i].value=res;
                            }
                            
                            break;
                        }
                    }
                    component.set("v.MetadataHeader_alldata", metaDataWithMembers);
                    component.set('v.selectedMetaDataType',sectionAuraId);
                    component.set("v.spinner", false);
                    
                    
                    helper.hideShowToggle(component,event,sectionDiv,sectionState);
                    
                    // checked the last selected components
                    // //sectionAuraId ------> current clicked method
                    var prevSelected =[];
                    var mapkey = sectionAuraId;
                    var SelectedMetadataHeader_alldata =  component.get('v.SelectedMetadataHeader_alldata');
                    
                    
                    for(var a of  SelectedMetadataHeader_alldata){
                        console.log('valueofa',a.value);
                        if(a.key == mapkey){
                            prevSelected = a.value;
                        }
                        /*for(var i =0; i<a.value.length;i++){
                            prevSelected.push(a.value[i]);
                        }*/
                    }
                    
                    for(var i=0;i<prevSelected.length;i++){
                        var element = document.getElementById('s-'+mapkey+'-'+prevSelected[i]);
                        console.log('prevSelected[i]',prevSelected[i]);
                        console.log('element',element);
                        if(element){
                            element.checked = true;
                        }
                    }
                }
                
            ).catch(
                function(error) {
                    console.log(error);
                }
            )
            helper.destinationlistdata(component, event, helper,sectionAuraId,parentId);
        }
        else{
            component.set("v.spinner", false);
            
            sectionDiv.setAttribute('class' , 'slds-section slds-is-close');
            //            sectionDiv.removeAttribute('class' , 'slds-is-open');
            
        }
    },
    
    toggle: function (component, event, helper) {
        var sel = component.find("mySelect");
        var nav =	sel.get("v.value");
        if (nav == "RunSpecifiedTests") {     
            component.set("v.toggleEng", true);
        }
        else{
            component.set("v.toggleEng", false);
        }
    },
    
    onSelectChange: function(component, event, helper) {
        let selectedId = event.target.getAttribute("id");
        let isChecked = document.getElementById(selectedId).checked;
        console.log('selectedId',selectedId);
        console.log('isChecked',isChecked);
        let itemName = event.target.getAttribute("value");
        let selectedmetadataType = component.get('v.selectedMetaDataType');
        let MetadataMembersMap = component.get('v.SelectedMetadataMembersMap');
        let itemIndex = MetadataMembersMap.findIndex(function(element){return element.key === selectedmetadataType;});
        if(itemIndex === -1){
            MetadataMembersMap.push({key: selectedmetadataType, value: new Array(itemName)});
        }else{
            let selectedItemList = MetadataMembersMap[itemIndex].value;
            if(isChecked){
                if(!selectedItemList.includes(itemName)) selectedItemList.push(itemName);
            }
            else{
                if(selectedItemList.includes(itemName)) selectedItemList.splice(selectedItemList.indexOf(itemName), 1);
                if(selectedItemList.length === 0) MetadataMembersMap.splice(itemIndex, 1);
            }
        }
        console.log('OnSingleSelect-Map-->',JSON.stringify(MetadataMembersMap));
        helper.createRollBackListOnSingleSelect(component,isChecked,itemName,selectedmetadataType);
    },
    
    createPackage: function(component, event, helper) {
        component.set("v.spinner", true);
        helper.destinationAdmin(component,event);
        if(Array.isArray(component.get('v.SelectedMetadataMembersMap')) && component.get('v.SelectedMetadataMembersMap').length){
            helper.showMessage(component,event,'info','Creating package... pls wait!','500','info','pester');
            helper.retrieveRequest(component,event,component.get('v.SelectedMetadataMembersMap'),component.get('v.selecteddeploymentRecordId'));
            helper.destructiverequest(component,event,component.get('v.destructiveMap'));
            helper.backupretrieveRequest(component,event,component.get('v.rollbackMap'),component.get('v.selecteddeploymentRecordId'));
        }else{
            helper.showMessage(component,event,'error','Please select metadata items first','1000','error','sticky');
        }
    },
    
    destinationOrg: function (component, event, helper) {
        var selectedDestination=component.find('selectDestination').get('v.value');
        component.set('v.DestinationOrg',selectedDestination);
        var action = component.get("c.getInsertCustomSetdataDestination");
        action.setParams({Dest_Org: selectedDestination }); 
        action.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS"){
            } 
        });
        $A.enqueueAction(action);  
    },
    
    rollbackmetadata : function(component, event, helper) {
        console.log('trueeeeee');
        // Set isModalOpen attribute to true
        component.set("v.isModalOpen", true);
        var div = event.currentTarget;
        var parentId = div.getAttribute('data-id');
        component.set('v.rollbackDetailRecordId',parentId);
        component.set('v.rollbackrecord',parentId);

        helper.rollbackdata(component, event, parentId);
        helper.deletedata(component, event, parentId);
        
        //$A.enqueueAction(action);
    },
    
    quickdeloypopup : function(component, event, helper) {
        component.set('v.quickpopup', true);
        var div = event.currentTarget;
        var parentId = div.getAttribute('data-id');
        console.log('quick deploy record id@@@',parentId);
        component.set("v.deploymentDetailRecordId",parentId);
        helper.quickdeploydata(component, event, parentId);
        //$A.enqueueAction(action);
    },
    
    viewDetails : function(component, event, helper) {
        
        component.set('v.DeployPopup',true);
        
        var div = event.currentTarget;
        var dataDeploy = div.getAttribute('data-id');
        
        component.set('v.selectedRecord',dataDeploy);
        var action2 = component.get("c.getDeploymentDetail");
        action2.setParams({deploymentid:dataDeploy});
        action2.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var res =  response.getReturnValue();
                
                component.set('v.deployDetail',res);
                
            }
            else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action2);
    },
    closeModal : function(component, event, helper) {
        component.set('v.DeployPopup',false);
    },
    closeCloneModal : function(component, event, helper) {
        component.set('v.SelectedMetadataHeader_alldata',null);
        component.set('v.depbool',true);
        component.set("v.deploymentDetailRecordId",'');
        component.set('v.clonepopup',false);
		component.set('v.spinner',false);            
        
    },
    firstSuccess : function(component, event, helper)
    {
        var deployList = component.get("v.deployDetailListsuccess");
        var pageSize = component.get("v.pageSizeSuccess");
        var paginationList = [];
        for(var i=0; i< pageSize; i++)
        {
            paginationList.push(deployList[i]);
        }
        component.set('v.paginationListSuccess', paginationList);
    },
    lastSuccess : function(component, event, helper)
    {
        var DetailList = component.get("v.deployDetailListsuccess");
        var pageSize = component.get("v.pageSizeSuccess");
        var totalSize = component.get("v.totalSizeSuccess");
        var paginationList = [];
        for(var i=totalSize-pageSize; i< totalSize; i++)
        {
            paginationList.push(DetailList[i]);
        }
        component.set('v.paginationListSuccess', paginationList);
    },
    nextSuccess : function(component, event, helper)
    {
        var deployList = component.get("v.deployDetailListsuccess");
        var end = component.get("v.endSuccess");
        var start = component.get("v.startSuccess");
        var pageSize = component.get("v.pageSizeSuccess");
        var paginationList = [];
        var counter = 0;
        for(var i=end+1; i<end+pageSize+1; i++)
        {
            if(deployList.length > end)
            {
                paginationList.push(deployList[i]);
                counter++ ;
            }
        }
        start = start + counter;
        end = end + counter;
        component.set("v.startSuccess",start);
        component.set("v.endSuccess",end);
        component.set("v.paginationListSuccess", paginationList);
    },
    previousSuccess : function(component, event, helper)
    {
        var deployList = component.get("v.deployDetailListsuccess");
        var end = component.get("v.endSuccess");
        var start = component.get("v.startSuccess");
        var pageSize = component.get("v.pageSizeSuccess");
        var paginationList = [];
        var counter = 0;
        for(var i= start-pageSize; i < start ; i++)
        {
            if(i > -1)
            {
                paginationList.push(deployList[i]);
                counter++;
            }
            else {
                start++;
            }
        }
        start = start - counter;
        end = end - counter;
        component.set("v.startSuccess",start);
        component.set("v.endSuccess",end);
        component.set("v.paginationListSuccess", paginationList);
    },
    firstFailure : function(component, event, helper)
    {
        var deployList = component.get("v.deployDetailListfailure");
        var pageSize = component.get("v.pageSizeFailure");
        var paginationList = [];
        for(var i=0; i< pageSize; i++)
        {
            paginationList.push(deployList[i]);
        }
        component.set('v.paginationListFailure', paginationList);
    },
    lastFailure : function(component, event, helper)
    {
        var DetailList = component.get("v.deployDetailListfailure");
        var pageSize = component.get("v.pageSizeFailure");
        var totalSize = component.get("v.totalSizeFailure");
        var paginationList = [];
        for(var i=totalSize-pageSize; i< totalSize; i++)
        {
            paginationList.push(DetailList[i]);
        }
        component.set('v.paginationListFailure', paginationList);
    },
    nextFailure : function(component, event, helper)
    {
        var deployList = component.get("v.deployDetailListfailure");
        var end = component.get("v.endFailure");
        var start = component.get("v.startFailure");
        var pageSize = component.get("v.pageSizeFailure");
        var paginationList = [];
        var counter = 0;
        for(var i=end+1; i<end+pageSize+1; i++)
        {
            if(deployList.length > end)
            {
                paginationList.push(deployList[i]);
                counter++ ;
            }
        }
        start = start + counter;
        end = end + counter;
        component.set("v.startFailure",start);
        component.set("v.endFailure",end);
        component.set("v.paginationListFailure", paginationList);
    },
    previousFailure : function(component, event, helper)
    {
        var deployList = component.get("v.deployDetailListfailure");
        var end = component.get("v.endFailure");
        var start = component.get("v.startFailure");
        var pageSize = component.get("v.pageSizeFailure");
        var paginationList = [];
        var counter = 0;
        for(var i= start-pageSize; i < start ; i++)
        {
            if(i > -1)
            {
                paginationList.push(deployList[i]);
                counter++;
            }
            else {
                start++;
            }
        }
        start = start - counter;
        end = end - counter;
        component.set("v.startFailure",start);
        component.set("v.endFailure",end);
        component.set("v.paginationListFailure", paginationList);
    },
    onChkAll: function(component, event, helper) {
        let selectedId = event.target.getAttribute('id');
        let isChecked = document.getElementById(selectedId).checked;
        let selectedmetadatatype = component.get('v.selectedMetaDataType');
        let checkboxList = document.getElementsByTagName("INPUT");
        let selectedmetadatavalue =[];
        let metadataMap = component.get('v.SelectedMetadataMembersMap');
        for(let i=0; i<checkboxList.length; i++){
            if((checkboxList[i].id).includes('s-'+selectedmetadatatype)){
                if(isChecked){
                    checkboxList[i].checked = true;
                    selectedmetadatavalue.push(checkboxList[i].value);
                }
                else{
                    checkboxList[i].checked = false;
                    selectedmetadatavalue.slice(checkboxList[i].value,1);
                }
            }
        }
        let itemIndex = metadataMap.findIndex(function(element){return element.key === selectedmetadatatype;});
        if(itemIndex === -1){
            metadataMap.push({key: selectedmetadatatype, value: selectedmetadatavalue});
        }
        else{
            metadataMap[itemIndex].value = selectedmetadatavalue;
            if((metadataMap[itemIndex].value).length === 0) metadataMap.splice(itemIndex, 1);
        }
        console.log('OnMultiSelect-Map-->',JSON.stringify(metadataMap));
        helper.createRollBackListOnMultiSelect(component,selectedmetadatatype,selectedmetadatavalue);
    },
    onCheck: function(cmp, evt){
        var checkCmp = cmp.find("checkbox");
        let getValue = checkCmp.get("v.value");
        console.log("checkbox",getValue);
        cmp.set("v.myBool",getValue); 
        console.log("checkbox",getValue);
    },
    onCheck1: function(cmp, evt) {
        var checkCmp = cmp.find("checkbox1");
        let getValue = checkCmp.get("v.value");
        console.log("checkbox1",getValue);
        cmp.set("v.myBool1",getValue); 
        console.log("checkbox1",getValue);
    },
    searchKeyChange: function(component, event) {
        
        var searchKey = component.find("searchKey").get("v.value");
        console.log('searchKey:::::'+searchKey);
        var action = component.get("c.findByName");
        action.setParams({
            "searchKey": searchKey
        });
        action.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS") {
                component.set("v.deployDetailListsuccess", a.getReturnValue());
                var deploylist=component.get("v.deployDetailListsuccess");
                console.log('deploylist',deploylist);
                var pagesize=component.get("v.pageSizeSuccess");
                component.set("v.endSuccess",pagesize );
                component.set("v.startSuccess",0 );
                component.set("v.totalSizeSuccess", a.getReturnValue().length);
                var totalsize=component.get("v.totalSizeSuccess");
                var  pagelist=[];
                for(var i=0;i<pagesize;i++){
                    if(i<=(totalsize-1)){
                        pagelist.push(deploylist[i]);
                    }
                    else{
                        break;
                    }
                }
                component.set("v.paginationListSuccess",pagelist );
                var page=component.get("v.paginationListSuccess");
                console.log('page',page);
            //component.set("v.paginationListSuccess", a.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    searchKeyChange1: function(component, event) {
        
        var searchKey = component.find("searchKey1").get("v.value");
        console.log('searchKey:::::'+searchKey);
        var action = component.get("c.findByName1");
        action.setParams({
            "searchKeyfailure": searchKey
        });
        action.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS") {
                component.set("v.deployDetailListfailure", a.getReturnValue());
                var deploylist=component.get("v.deployDetailListfailure");
                
                var pagesize=component.get("v.pageSizeFailure");
                component.set("v.endFailure",pagesize );
                component.set("v.startFailure",0 );
                component.set("v.totalSizeFailure", a.getReturnValue().length);
                var totalsize=component.get("v.totalSizeFailure");
                var  pagelist=[];
                for(var i=0;i<pagesize;i++){
                    if(i<=(totalsize-1)){
                        pagelist.push(deploylist[i]);
                    }
                    else{
                        break;
                    }
                }
                component.set("v.paginationListFailure",pagelist );
                var page=component.get("v.paginationListFailure");
            //console.log('---', a.getReturnValue());
            //component.set("v.paginationListFailure", a.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    }
})