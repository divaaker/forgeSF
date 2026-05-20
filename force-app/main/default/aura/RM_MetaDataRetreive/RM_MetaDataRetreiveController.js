({
    doInit : function(component, event, helper) {
        helper.fetchTypePicklist(component); // fetches PickList Values of Type Field
    },
    retrive : function(component, event, helper) {
        component.set("v.spinner", true);
        var sourceOrg = component.get('v.SourceOrg');alert(sourceOrg);
        var destination = component.get('v.DestinationOrg');
        var recordName = component.get('v.DeploymentName');
        if(sourceOrg=='No Value' && destination=='No Value'){
            component.set("v.spinner", false);
            helper.showError(component, event, helper,'Please Select Source Org and Destination Org');
        }
        //Added on 30-nov-2020 by Ujjwal
        else if(sourceOrg=='No Value'){
            component.set("v.spinner", false);
            helper.showError(component, event, helper,'Please Select Source Org');
        }
        //Added on 30-nov-2020 by Ujjwal
            else if(destination=='No Value'){
                component.set("v.spinner", false);
                helper.showError(component, event, helper,'Please Select Destination Org');
            }
        //added on 8-oct-2020 by shatrughna
                else if(sourceOrg==destination)
                {
                    component.set("v.spinner", false);
                    helper.showError(component, event, helper,'Source Org and Destination Org can not be Same.');
                }else if(recordName == ''){
                    component.set("v.spinner", false);
                    helper.showError(component, event, helper,'Name cannot be blank.');
                }
        //end
                    else{
                        helper.init_Server(component); 
                    }
    },
    setName: function (component, event, helper) {
        const inputName = event.getSource().get('v.value');
        console.log('inputName',inputName);
        component.set('v.DeploymentName',inputName);
        
    },
    setDescription: function (component, event, helper) {
        const inputDescription = event.getSource().get('v.value');
        console.log('inputDescription',inputDescription);
        component.set('v.DeploymentDescription',inputDescription);
    },
    setSourceOrg: function (component, event, helper) {
        var selPickListValue=component.find('select').get('v.value');
        component.set('v.SourceOrg',selPickListValue);
        console.log('selPickListValue',selPickListValue);
        //$A.enqueueAction(action);
    },
    destinationOrg: function (component, event, helper) {
        var selectedDestination=component.find('selectDestination').get('v.value');
        component.set('v.DestinationOrg',selectedDestination);
        console.log('selectedDestination',selectedDestination);
        //$A.enqueueAction(action);  
    },
    toggleSection : function(component, event, helper) {
        
        var sectionAuraId = event.target.getAttribute("data-auraId");
        var selectedMetadata = component.get('v.selectedMetaDataType');
        var metaDataWithMembers = component.get('v.MetadataHeader_alldata');
        var sectionDiv = document.getElementById(sectionAuraId);
        var sectionState = sectionDiv.classList.contains('slds-is-close');
        var sourceOrg = component.get('v.SourceOrg');
        var destinationOrg = component.get('v.DestinationOrg');
        if(sectionState){
            component.set("v.spinner", true);
            var action = component.get("c.addMap");
            action.setParams({metadataType: sectionAuraId, sourceOrg : sourceOrg, destinationOrg : destinationOrg}); 
            
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
                    console.log('sectionAuraId',sectionAuraId);
                    console.log('metaDataWithMembers',metaDataWithMembers);
                    component.set("v.MetadataHeader_alldata", metaDataWithMembers);
                    component.set('v.selectedMetaDataType',sectionAuraId);
                    component.set("v.spinner", false);
                    helper.hideShowToggle(component,event,sectionDiv,sectionState);
                    
                    if(component.get('v.SelectedMetadataMembersMap')!=null){
                        var prevSelected =[];
                        var mapkey = sectionAuraId;
                        var SelectedMetadataHeader_alldata =  component.get('v.SelectedMetadataMembersMap');
                        console.log('SelectedMetadataHeader_alldata',SelectedMetadataHeader_alldata);
                        for(var a of  SelectedMetadataHeader_alldata){
                            console.log('valueofa',a.value);
                            if(a.key == mapkey){
                                prevSelected = a.value;
                            }
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
                }
            ).catch(
                function(error) {
                    console.log(error);
                }
            )
            helper.destinationlistdata(component, event, helper,sectionAuraId);
        }
        else{
            component.set("v.spinner", false);
            sectionDiv.setAttribute('class' , 'slds-section slds-is-close');
        }
    },    
    
    onSelectChange: function(component, event, helper) {
        let selectedId = event.target.getAttribute("id");
        console.log('selectedId',selectedId);
        let isChecked = document.getElementById(selectedId).checked;
        let itemName = event.target.getAttribute("value");
        component.set("v.Checkedvalue",itemName);
        let selectedmetadataType = component.get('v.selectedMetaDataType');
        let MetadataMembersMap = component.get('v.SelectedMetadataMembersMap');
        console.log('isChecked',isChecked);
        console.log('itemName',itemName);
        console.log('selectedmetadataType',selectedmetadataType);
        console.log('MetadataMembersMap',MetadataMembersMap);
        let itemIndex = MetadataMembersMap.findIndex(function(element){return element.key === selectedmetadataType;});
        
        console.log('itemIndex',itemIndex);
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
    
    backtoRetrieve : function(component, event, helper) {
        component.set('v.packageBool',false);
        component.set('v.retrieveBool',true);
        $A.get('e.force:refreshView').fire();
    },
    
    backtocreatepackage : function(component, event, helper) {
        component.set('v.packageBool',true);
        component.set('v.deployBool',false);
    },
    
    createPackage: function(component, event, helper) { 
        helper.saveSeletedMetadataMap(component,event);
        helper.destinationAdmin(component,event);
        
        if(Array.isArray(component.get('v.SelectedMetadataMembersMap')) && component.get('v.SelectedMetadataMembersMap').length && component.get('v.SelectedMetadataMembersMap')!=null){
            helper.showMessage(component,event,'info','Creating package... pls wait!','50','info','pester');
            helper.retrieveRequest(component,event,component.get('v.SelectedMetadataMembersMap'));
            helper.destructiverequest(component,event,component.get('v.destructiveMap'));
            helper.backupretrieveRequest(component,event,component.get('v.rollbackMap'));
            
        }else{
            helper.showMessage(component,event,'error','Please select metadata items first','50','error','pester');
            component.set("v.spinner", false);
        }
    },
    
    deployPackage : function(component, event, helper) {
        component.set("v.spinner", true);
        component.set('v.testRunPopup',false);
        console.log('hello',component.get('v.myBool'));
        
        if(component.get('v.packageZipFile') !== ''){
            console.log('deploy');
            
            var sourceOrg = component.get('v.SourceOrg');
            var destinationOrg = component.get('v.DestinationOrg');
            var sel = component.find("mySelect");
            var selectTestLevel = sel.get("v.value");
            var specifiedTestClass = '';
            if(selectTestLevel == 'RunSpecifiedTests'){
                specifiedTestClass = component.find("specifiedTestClass").get("v.value");
            }
            console.log('destinationOrg-----',destinationOrg);
            helper.createDeploymentObjects(component,selectTestLevel,specifiedTestClass,sourceOrg, destinationOrg);
            helper.showMessage(component,event,'info','Deploying package... pls wait!','500','info','pester');
            helper.deployRequest(component, event, component.get('v.packageZipFile'),selectTestLevel,specifiedTestClass,sourceOrg,destinationOrg);
        }else{
            helper.showMessage(component,event,'error','Please create package first.','1000','error','sticky');
        }
        //$A.enqueueAction(action);
    },
    zipDownload : function(component, event, helper) {
        
        if(component.get('v.packageZipFile') != ''){
            helper.downloadZipHelper(component, event,component.get('v.packageZipFile'));
        }
        else{
            helper.showMessage(component,event,'error','Nothing to download.','1000','error','sticky');
        }
    },
    deployModal : function(component, event, helper) {
        component.set('v.ValidatePopup',false);
        component.set('v.testRunPopup',true);
    },
    ValidateTestModal : function(component, event, helper) {
        component.set('v.testPopup',true);
    },
    ValidateDeployModal	: function(component, event, helper) {
        component.set('v.testPopup',false);
        component.set('v.ValidatePopup',true);
        component.set("v.spinnerval",true);
        if(component.get('v.packageZipFile') !== ''){
            console.log('Validate');
            var sourceOrg = component.get('v.SourceOrg');
            var destinationOrg = component.get('v.DestinationOrg');
            var sel = component.find("mySelectTest");
            var selectTestLevel = sel.get("v.value");
            var specifiedTestClass = '';
            if(selectTestLevel == 'RunSpecifiedTests'){
                specifiedTestClass = component.find("validateTestClass").get("v.value");
            }
            console.log('destinationOrg',destinationOrg);
            helper.createDeploymentObjects(component,selectTestLevel,specifiedTestClass,sourceOrg, destinationOrg);
            helper.showMessage(component,event,'info','Validating package... pls wait!','500','info','pester');
            helper.ValidateRequest(component, event, component.get('v.packageZipFile'),selectTestLevel,specifiedTestClass,sourceOrg,destinationOrg);
        }
        else{
            component.set("v.spinnerval", false);
            helper.showMessage(component,event,'error','Please create package first.','1000','error','sticky');
        } 
    },
    closeValidateModal : function(component, event, helper) {
        component.set('v.ValidatePopup',false);
        component.set('v.errortrue',false);
        component.set("v.spinnerval",false);
        
    },
    closeModal : function(component, event, helper) {
        component.set('v.testRunPopup',false);
    },
    closetestModal : function(component, event, helper) {
        component.set('v.testPopup',false);
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
    
    toggletest: function (component, event, helper) {
        var sel = component.find("mySelectTest");
        var nav =	sel.get("v.value");
        console.log('nav',nav);
        if (nav == "RunSpecifiedTests") {     
            component.set("v.toggleEngtest", true);
        }
        else{
            component.set("v.toggleEngtest", false);
        }
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
                }else{
                    checkboxList[i].checked = false;
                    selectedmetadatavalue.slice(checkboxList[i].value,1);
                }
            }
        }
        let itemIndex = metadataMap.findIndex(function(element){return element.key === selectedmetadatatype;});
        if(itemIndex === -1){
            metadataMap.push({key: selectedmetadatatype, value: selectedmetadatavalue});
        }else{
            metadataMap[itemIndex].value = selectedmetadatavalue;
            if((metadataMap[itemIndex].value).length === 0) metadataMap.splice(itemIndex, 1);
        }
        console.log('OnMultiSelect-Map-->',JSON.stringify(metadataMap));
        helper.createRollBackListOnMultiSelect(component,selectedmetadatatype,selectedmetadatavalue);
    },
    onCheck: function(cmp, evt) {
        var checkCmp = cmp.find("checkbox");
        let getValue = checkCmp.get("v.value");
        console.log("checkbox",getValue);
        cmp.set("v.myBool",getValue); 
        console.log("checkbox",getValue);
    },
    doFilter: function(component, event, helper) {  
        //calling helper  
        helper.FilterRecords(component);  
    },
    firstSuccess : function(component, event, helper)
    {
        var deployList = component.get("v.UnfilteredData");
        var pageSize = component.get("v.pageSizeSuccess");
        
        var paginationList = [];
        for(var i=0; i< pageSize; i++)
        {
            paginationList.push(deployList[i]);
        }
        console.log('deployList',deployList);
        console.log('pageSize',pageSize);
        console.log('paginationList',paginationList);
        component.set('v.data', paginationList);
        
    },
    lastSuccess : function(component, event, helper)
    {
        var DetailList = component.get("v.UnfilteredData");
        var pageSize = component.get("v.pageSizeSuccess");
        var totalSize = component.get("v.totalSizeSuccess");
        var paginationList = [];
        for(var i=totalSize-pageSize; i< totalSize; i++)
        {
            paginationList.push(DetailList[i]);
        }
        console.log('deployList',deployList);
        console.log('pageSize',pageSize);
        console.log('paginationList',paginationList);
        component.set('v.data', paginationList);
    },
    nextSuccess : function(component, event, helper)
    {
        var deployList = component.get("v.UnfilteredData");
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
        component.set("v.data", paginationList);
        if(component.get('v.SelectedMetadataMembersMap')!=null){
            var prevSelected =[];
            var SelectedMetadataHeader_alldata =  component.get('v.SelectedMetadataMembersMap');
            var mapkey = component.get('v.selectedMetaDataType');
            
            for(var a of  SelectedMetadataHeader_alldata){
                console.log('valueofa',a.value);
                if(a.key == mapkey){
                    prevSelected = a.value;
                }
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
    },
    previousSuccess : function(component, event, helper)
    {
        var deployList = component.get("v.UnfilteredData");
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
        component.set("v.data", paginationList);
        if(component.get('v.SelectedMetadataMembersMap')!=null){
            var prevSelected =[];
            var SelectedMetadataHeader_alldata =  component.get('v.SelectedMetadataMembersMap');
            var mapkey = component.get('v.selectedMetaDataType');
            console.log('mapkey',mapkey);
            for(var a of  SelectedMetadataHeader_alldata){
                console.log('valueofa',a.value);
                if(a.key == mapkey){
                    prevSelected = a.value;
                }
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
    }
})