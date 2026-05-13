({
    init_Server: function (component, event, helper,recordId) {
        var action = component.get("c.init");
        action.setParams({ 'parentId' : recordId});
        action.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS"){
                var result = a.getReturnValue();
                console.log(result);
                var list = result.metadata;
                var arrayMapKeys = [];
                for(var key in list){
                    arrayMapKeys.push({key: key, value: list[key]});
                }
                component.set("v.MetadataHeader_alldata", arrayMapKeys);
                component.set("v.SourceOrg", result.sourceOrg);
                component.set("v.DestinationOrg", result.destinationOrg);
            }
        });
        $A.enqueueAction(action);    
    },
    createRollBackListOnSingleSelect : function(component,isChecked,itemName,selectedMetadataType){
        let destructivemetaMap = component.get('v.destructiveMap');
        let rollbackmetaMap = component.get('v.rollbackMap');
        let targetMetalist = component.get('v.destcmp');
        let desIndex = destructivemetaMap.findIndex(function(element){return element.key === selectedMetadataType;});
        if(desIndex === -1){
            if(!targetMetalist.includes(itemName)) destructivemetaMap.push({key: selectedMetadataType, value: new Array(itemName)});
        }else{
            let itemList = destructivemetaMap[desIndex].value;
            if(isChecked){
                if(!targetMetalist.includes(itemName)) itemList.push(itemName);
            }else{
                if(itemList.includes(itemName)) itemList.splice(itemList.indexOf(itemName), 1);
                if(itemList.length === 0) destructivemetaMap.splice(desIndex, 1);
            }
        }
        let rollIndex = rollbackmetaMap.findIndex(function(element){return element.key === selectedMetadataType;});
        if(rollIndex === -1){
            if(targetMetalist.includes(itemName)) rollbackmetaMap.push({key: selectedMetadataType, value: new Array(itemName)});
        }else{
            let itemList = rollbackmetaMap[rollIndex].value;
            if(isChecked){
                if(targetMetalist.includes(itemName)) itemList.push(itemName);
            }else{
                if(itemList.includes(itemName)) itemList.splice(itemList.indexOf(itemName), 1);
                if(itemList.length === 0) rollbackmetaMap.splice(rollIndex, 1);
            }
        }
        console.log('OnSingleSelect-rollbackmetaMap-->',JSON.stringify(rollbackmetaMap));
        console.log('OnSingleSelect-destructivemetaMap-->',JSON.stringify(destructivemetaMap));
    },
    createRollBackListOnMultiSelect : function(component,selectedmetadatatype,selectedmetadatavalue){
        let destructivemetaMap = component.get('v.destructiveMap');
        let rollbackmetaMap = component.get('v.rollbackMap');
        let targetMetalist = component.get('v.destcmp');
        let matchedValue = [];
        let unMatchedvalue = [];
        selectedmetadatavalue.forEach(function(itemName){
            if(!targetMetalist.includes(itemName)) unMatchedvalue.push(itemName); else matchedValue.push(itemName);
        }); 
        let desIndex = destructivemetaMap.findIndex(function(element){return element.key === selectedmetadatatype;});
        if(desIndex === -1){
            if(Array.isArray(unMatchedvalue) && unMatchedvalue.length) destructivemetaMap.push({key: selectedmetadatatype, value: unMatchedvalue});
        }else{
            destructivemetaMap[desIndex].value = unMatchedvalue;
            if((destructivemetaMap[desIndex].value).length === 0) destructivemetaMap.splice(desIndex, 1);
        }
        let rollIndex = rollbackmetaMap.findIndex(function(element){return element.key === selectedmetadatatype;});
        if(rollIndex === -1){
            if(Array.isArray(matchedValue) && matchedValue.length) rollbackmetaMap.push({key: selectedmetadatatype, value: matchedValue});
        }else{
            rollbackmetaMap[rollIndex].value = matchedValue;
            if((rollbackmetaMap[desIndex].value).length === 0) rollbackmetaMap.splice(rollIndex, 1);
        }
        console.log('OnMultiSelect-rollbackmetaMap-->',JSON.stringify(rollbackmetaMap));
        console.log('OnMultiSelect-destructivemetaMap-->',JSON.stringify(destructivemetaMap));
    },
    serverSideCall : function(component,action) {
        return new Promise(function(resolve, reject) { 
            action.setCallback(this, 
                               function(response) {
                                   var state = response.getState();
                                   if (state === "SUCCESS") {
                                       resolve(response.getReturnValue());
                                   } else {
                                       reject(new Error(response.getError()));
                                   }
                               }); 
            $A.enqueueAction(action);
        });
    },
    destinationlistdata : function(component, event, helper,sectionAuraId,parentId) {
        var action = component.get("c.targetaddMap");
        action.setParams({metadataType: sectionAuraId, parentId : parentId });
        action.setCallback(this, function(a) {
            var state = a.getState();
            if(state === "SUCCESS"){
                var result = a.getReturnValue();
                console.log('result+++++',result);
                component.set("v.destcmp",result);
            }
        });
        $A.enqueueAction(action);  
    },
    hideShowToggle: function(component,event,sectionDiv,sectionState){
        component.set("v.spinner", false);
        //var sectionAuraId = event.target.getAttribute("data-auraId");
        //var sectionDiv = document.getElementById(sectionAuraId);
        //console.log('sectionAuraId',sectionAuraId);
        //console.log('sectionDiv',sectionDiv);
        console.log('sectionState',sectionState);
        //var sectionState = sectionDiv.classList.contains('slds-is-close');
        if(sectionState){
            sectionDiv.setAttribute('class','slds-section slds-is-open');
        }
        else{
            sectionDiv.setAttribute('class' , 'slds-section slds-is-close');
            sectionDiv.removeAttribute('class' , 'slds-is-open');
        }
        
    },
    
    retrieveRequest : function(component,event,packageValue, recordId){
        let counter =  0;
        const self = this;
        var action = component.get("c.retrieveSelectedPackage");
        action.setParams({ 'packagevalueJson' : JSON.stringify(packageValue) , 'parentId' : recordId});
        action.setCallback(self, function(a) {
            var state = a.getState();
            if(state === "SUCCESS"){
                let asynId = a.getReturnValue();
                if(asynId !== '' || asynId !== null){
                    self.asynPackageRetrieve(component,asynId,counter+1,self,recordId);
                }else{
                    self.showMessage(component,event,'error','Retrieve request error.' + err,'1000','error','sticky');
                }
            }
        });
        $A.enqueueAction(action);
    },
    asynPackageRetrieve : function(component,asynId,counter,ref,recordId){
        
        let action = component.get("c.checkAsyncRequest");
        const self = this;
        ref.retrieveResponse(asynId,action,ref,recordId).then(function(result){
            component.set("v.spinner", false);
            component.set('v.packageZipFile',result);
            ref.showMessage(component,event,'Retrieve success','Package successfully retrieved.','1000','success','pester');
            self.updateZipHelper(component,result);
        }).catch(function(err){
            if(err === '') ref.asynPackageRetrieve(component,asynId,counter+1,ref,recordId);
            else ref.showMessage(component,event,'Retrieve error','some error occured : ' + err,'1000','error','sticky');
        });
    },
    retrieveResponse : function(asynId,action,ref,recordId){
        return new Promise(function(resolve, reject) {
            action.setParams({ 'requestId' : asynId, 'parentId' : recordId});
            action.setCallback(ref, function(a) {
                var state = a.getState();
                if(state === "SUCCESS"){
                    let res = a.getReturnValue();
                    if(res=='' || res=='error' || res.includes('error'))
                        reject(res);
                    else
                        resolve(res);
                }else{
                    reject('STATE:'+state);
                }
            });
            $A.enqueueAction(action);
        });
    },
    
    destructiverequest : function(component,event,packageValue){
        var action = component.get("c.destructivepackage");
        action.setParams({'destructivevalue': JSON.stringify(packageValue) });
        action.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS"){
                //component.set('v.ParentRecordId', a.getReturnValue());
                console.log('hello----world');
                let zipraw = new JSZip();
                zipraw.file("package.xml",a.getReturnValue()["package.xml"]);
                zipraw.file("destructiveChanges.xml",a.getReturnValue()["destructiveChanges.xml"]);
                zipraw.generateAsync({type:"base64"})
                .then(function(content) {
                    let data = content;
                    component.set("v.destructivepackagezip",data);
                    console.log('deldata',data);
                });
            }
        });
        
        $A.enqueueAction(action);
    },
    
    backupretrieveRequest : function(component,event,packageValue,recordId){
        let counter =  0;
        const self = this;
        var action = component.get("c.backupretrieveSelectedPackage");
        action.setParams({ 'packagevalueJson' : JSON.stringify(packageValue), 'parentId' : recordId});
        action.setCallback(self, function(a) {
            var state = a.getState();
            if(state === "SUCCESS"){
                console.log('state',state);
                let asynId = a.getReturnValue();
                if(asynId !== '' || asynId !== null){
                    self.backupasynPackageRetrieve(component,asynId,counter+1,self,recordId);
                }else{
                    self.showMessage(component,event,'error','Retrieve request error.' + err,'1000','error','sticky');
                }
            }
        });
        $A.enqueueAction(action);
    },
    backupasynPackageRetrieve : function(component,asynId,counter,ref,recordId){
        let action = component.get("c.backupcheckAsyncRequest");
        console.log('backup------');
        ref.backupretrieveResponse(asynId,action,ref,recordId).then(function(result){ 
            component.set('v.rollbackpackageZip',result);
            console.log('backupresult',result);
        }).catch(function(err){
            if(err === '') ref.backupasynPackageRetrieve(component,asynId,counter+1,ref,recordId);
        });
    },
    
    backupretrieveResponse : function(asynId,action,ref,recordId){
        
        console.log('backupasynId',asynId);
        return new Promise(function(resolve, reject) {
            action.setParams({ 'requestId' : asynId, 'parentId' : recordId});
            action.setCallback(ref, function(a) {
                var state = a.getState();
                if(state === "SUCCESS"){
                    let res = a.getReturnValue();
                    if(res=='' || res=='error' || res.includes('error'))
                        reject(res);
                    else
                        resolve(res);
                }else{
                    reject('STATE:'+state);
                }
            });
            $A.enqueueAction(action);
        });
    },
    
    getSelectedMetadata : function(component, recordId){
        const self = this;
        var pervkey = [];
        
        var action = component.get("c.getSeletedMetadataMemberMap");
        action.setParams({ 'parentId' : recordId});
        action.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS"){
                var obj=a.getReturnValue();
                var object=   JSON.parse(obj);
                component.set('v.SelectedMetadataHeader_alldata',object);
                //merging the previous and current data to make a finalmap
                let previousMetadata = component.get('v.SelectedMetadataHeader_alldata');
                //let currentMetadata = component.get('v.SelectedMetadataMembersMap');
                
                //let finalMetadata = previousMetadata.concat(currentMetadata);
                
                component.set('v.SelectedMetadataMembersMap',previousMetadata);
                console.log('previousMetadata',JSON.stringify(previousMetadata));
                for(var a of previousMetadata){
                    pervkey.push(a.key);
                }
                console.log('key',pervkey);
                //self.checkedPreviousSelected(component,recordId,pervkey);
                self.fetchMetadataNames_Clone(component,recordId);
            }
        });
        $A.enqueueAction(action);
        
    },
   /* checkedPreviousSelected : function(component,recordId,pervkey){
        console.log('call this');
        var destdata = [];
        for(var i=0;i<pervkey.length;i++){
            var action = component.get("c.selectedadd_Map");
            action.setParams({ 'parentId' : recordId, 'MetaData_Type' : pervkey[i]});
            console.log('pervkey+++',pervkey[i]);
            action.setCallback(this, function(a) {
                var state = a.getState();
                if (state === "SUCCESS"){
                    var obj = a.getReturnValue();
                    console.log('jhvkhk',obj);
                    destdata.push(obj);
                }
            });
        }
        console.log('destdata--',destdata);
        $A.enqueueAction(action);
    },*/
    fetchMetadataNames_Clone : function(component,recordId){
        debugger;
        let previousData = component.get('v.SelectedMetadataMembersMap');
        let counter = 0;
        let limit = previousData.length;
        let methodName = 'selectedadd_Map';
        let ref = this;
        ref.showSpinner(component);
        ref.metadata_init(component,methodName,recordId,previousData,counter,limit,ref);
    },
    metadata_init : function(component,methodName,recordId,previousData,counter,limit,ref){
        var destdata = [];
        let destructivemetaMap = component.get('v.destructiveMap');
        let rollbackmetaMap = component.get('v.rollbackMap');
        let matchedValue = [];
        let unMatchedvalue = [];
        if(counter < limit){
            console.log('key',previousData[counter].key);
            
            let params = {'parentId' : recordId, 'MetaData_Type' : previousData[counter].key};
            ref.apexServer(component,methodName,params,ref).then(function(result){
                counter ++;
                destdata = JSON.stringify(result);
                console.log('result---->',destdata);
                previousData[counter-1].value.forEach(function(itemName){
                    if(!destdata.includes(itemName)) unMatchedvalue.push(itemName); else matchedValue.push(itemName);
                });
                if(unMatchedvalue.length > 0){
                    destructivemetaMap.push({key: previousData[counter-1].key, value: unMatchedvalue});
                }
                if(matchedValue.length > 0){
                    rollbackmetaMap.push({key: previousData[counter-1].key, value: matchedValue});
                }
                console.log('matchedValue++--',matchedValue);
                console.log('unMatchedvalue--++',unMatchedvalue);
                console.log('OnMultiSelect-rollbackmetaMap-->',JSON.stringify(rollbackmetaMap));
                console.log('OnMultiSelect-destructivemetaMap-->',JSON.stringify(destructivemetaMap));
                ref.metadata_init(component,methodName,recordId,previousData,counter,limit,ref);
            }).catch(function(err){ console.log('ERROR-->',err)
                                  ref.hideSpinner(component);
                                  });
        }else{
            ref.hideSpinner(component);
        }
    },
    apexServer : function(component,method,params,ref){
        return new Promise(function(resolve, reject) {
            let action = component.get('c.'+method);
            if(params){
                action.setParams(params);
            }
            action.setCallback(ref,function(response){
                if(response.getState() === 'SUCCESS'){
                    resolve(response.getReturnValue());
                }else{
                    reject('Error');
                }
            });
            $A.enqueueAction(action);
        });
    },
    showSpinner: function(component){
        let spinner = component.find("spinnerId"); 
        $A.util.removeClass(spinner, "slds-hide");
    }, 
    hideSpinner: function(component){
        let spinner = component.find("spinnerId"); 
        $A.util.addClass(spinner, "slds-hide");
    }, 
    showError : function(component, event, helper,msg) {
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
    },
    showSuccess : function(component, event) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Success',
            message: 'This is a success message',
            duration:' 5000',
            key: 'info_alt',
            type: 'success',
            mode: 'pester'
        });
        toastEvent.fire();
    },
    
    /* Retrieve & Deploy Package -- Modified...*/
    showMessage : function(component, event, title, message, duration, type, mode){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: title,
            message: message,
            duration: duration,
            key: 'info_alt',
            type: type,
            mode: mode
        });
        toastEvent.fire();
    },
    deployRequest : function(component, event, zipFileVal){
        console.log('zipFileVal',zipFileVal);
        let counter = 0;
        const self = this;
        var sel = component.find("mySelect");
        var selectTestLevel = sel.get("v.value");
        var specifiedTestClass = '';
        if(selectTestLevel == 'RunSpecifiedTests'){
            specifiedTestClass = component.find("specifiedTestClass").get("v.value");
        }
        var action = component.get("c.deploySelectedPackage");
        var recordId = component.get('v.selecteddeploymentRecordId');
        action.setParams({ 'ZipData' : zipFileVal,'testlevel' : selectTestLevel,'allTestClass' : specifiedTestClass,'parentId' : recordId});
        action.setCallback(self, function(a) {
            var state = a.getState(); 
            if (state === "SUCCESS"){
                console.log('resultDeployId:'+a.getReturnValue());
                let asynId = a.getReturnValue();
                console.log('asynId',asynId);
                if(asynId !== '' || asynId !== null || typeof(asynId) !== undefined){
                    self.asynPackageDeploy(component,asynId,counter,self,recordId);
                }
            }else{
                self.showMessage(component,event,'error','Deploy request error.' + err,'1000','error','sticky');
                console.log('STATE:',state);
            }
        }); 
        $A.enqueueAction(action);
    },
    asynPackageDeploy : function(component,asynId,counter,ref,recordId){
        console.log('call this');
        
        var action = component.get("c.checkdeploymentresult");
        let deployrecordId = component.get("v.DeploymentRecordId");
        ref.deployResponse(asynId,action,ref,recordId,deployrecordId).then(function(result){ 
            component.set('v.SelectedMetadataMembersMap','[]');
            component.set("v.spinner", false);
            component.set('v.clonepopup', false);
            ref.showMessage(component,event,'Deploy success','Package successfully deployed.','1000','success','pester');
        }).catch(function(err){
            component.set('v.SelectedMetadataMembersMap','[]');
            if(err === '') ref.asynPackageDeploy(component,asynId,counter+1,ref,recordId);
            else {
                component.set("v.spinner", false);
                component.set('v.clonepopup', false);
                ref.showMessage(component,event,'Deploy error','some error occured : ' + err,'1000','error','sticky');
            }
        });
    },
    deployResponse: function(asynId,action,ref,recordId,deployrecordId){
        return new Promise(function(resolve, reject) {
            action.setParams({ 'asyncResultId' : asynId, 'parentId' : recordId, 'deployrecordId' : deployrecordId });
            action.setCallback(ref, function(a) {
                var state = a.getState(); 
                if (state === "SUCCESS"){
                    let res = a.getReturnValue();
                    if(res === 'success'){
                        resolve(res);
                    }else{
                        reject(res);
                    }
                }else{
                    reject('STATE:'+state);
                }
            }); 
            $A.enqueueAction(action);
        });
    },
    
    rollbackdata : function(component, event, parentId){
        var action = component.get("c.rollbackMethod");
        console.log('parentId===',parentId);
        action.setParams({'parentId' : parentId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var res =  response.getReturnValue();
                console.log('data---',res);
                component.set('v.rollbackdatadeploy',res);
                
            }
            else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
    },
    
    quickdeploydata : function(component, event, parentId){
        var action = component.get("c.quickDeployMethod");
        console.log('parentId===',parentId);
        action.setParams({'parentId' : parentId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var res =  response.getReturnValue();
                console.log('data---',res);
                component.set('v.quickdatadeploy',res);
                
            }
            else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
    },
    
    deletedata : function(component, event, parentId){
        var action = component.get("c.deleteMethod");
        console.log('parentId===',parentId);
        action.setParams({'parentId' : parentId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var res =  response.getReturnValue();
                console.log('data---',res);
                component.set('v.deletedatadeploy',res);
                
            }
            else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
    },
    
    rollbackdeployRequest : function(component, event, zipFileVal){
        console.log('zipFileVal',zipFileVal);
        let counter = 0;
        const self = this;
        var action = component.get("c.rollbackdeploySelectedPackage");
        var recordId = component.get('v.rollbackrecord');
        console.log('recordId-------',recordId);
        action.setParams({ 'ZipData' : zipFileVal,'parentId' : recordId});
        action.setCallback(self, function(a) {
            var state = a.getState(); 
            if (state === "SUCCESS"){
                console.log('resultDeployId:'+a.getReturnValue());
                let asynId = a.getReturnValue();
                if(asynId !== '' || asynId !== null || typeof(asynId) !== undefined){
                    self.rollbackasynPackageDeploy(component,asynId,counter,self,recordId);
                    console.log('-----+++');
                }
            }else{
                self.showMessage(component,event,'error','Deploy request error.' + err,'1000','error','sticky');
                console.log('====+++');
                console.log('STATE:',state);
            }
        }); 
        $A.enqueueAction(action);
    },
    rollbackasynPackageDeploy : function(component,asynId,counter,ref,recordId){
        
        var action = component.get("c.rollbackcheckdeploymentresult");
        console.log('=======+++++');
        ref.rollbackdeployResponse(asynId,action,ref,recordId).then(function(result){ 
            console.log('success');
            ref.showMessage(component,event,'Deploy success','Rollback Success.','1000','success','pester');
        }).catch(function(err){
            console.log('error');
            if(err === '') ref.rollbackasynPackageDeploy(component,asynId,counter+1,ref,recordId);
            else ref.showMessage(component,event,'Deploy error','some error occured : ' + err,'1000','error','sticky');
            
        });
    },
    rollbackdeployResponse: function(asynId,action,ref,recordId){
        return new Promise(function(resolve, reject) {
            action.setParams({ 'asyncResultId' : asynId, 'parentId' : recordId});
            action.setCallback(ref, function(a) {
                var state = a.getState(); 
                if (state === "SUCCESS"){
                    let res = a.getReturnValue();
                    if(res === 'success'){
                        resolve(res);
                    }else{
                        reject(res);
                    }
                }else{
                    reject('STATE:'+state);
                }
            }); 
            $A.enqueueAction(action);
        });
    },
    
    quickdeployRequest : function(component, event, zipFileVal){
        console.log('quickdeployRequest@@@@@@--');
        var recordId = component.get('v.deploymentDetailRecordId');
        console.log('recordId-------',recordId);
        console.log('zipFileVal@@@@@@@--',zipFileVal);
        let counter = 0;
        const self = this;
        console.log('before action');
        var action = component.get("c.quickdeploySelectedPackage");
        action.setParams({ 'ZipData' : zipFileVal,'parentId' : recordId});
        action.setCallback(this, function(a) {
            var state = a.getState(); 
            console.log('state@@@@@@',state);
            if (state === "SUCCESS"){
                console.log('resultDeployId:'+a.getReturnValue());
                let asynId = a.getReturnValue();
                if(asynId !== '' || asynId !== null || typeof(asynId) !== undefined){
                    self.quickasynPackageDeploy(component,asynId,counter,self,recordId);
                    console.log('-----+++');
                }
            }else{
                this.showMessage(component,event,'error','Deploy request error.' + err,'1000','error','sticky');
                console.log('====+++');
                console.log('STATE:',state);
            }
        }); 
        $A.enqueueAction(action);
    },
    quickasynPackageDeploy : function(component,asynId,counter,ref,recordId){
        debugger;
        console.log('quickasynPackageDeploy@@@@@');
        var action = component.get("c.quickcheckdeploymentresult");
        let deployrecordId = component.get("v.DeploymentRecordId");
        console.log('=======+++++');
        ref.quickdeployResponse(asynId,action,ref,recordId,deployrecordId).then(function(result){ 
            console.log('success');
            ref.showMessage(component,event,'Deploy success','Rollback Success.','1000','success','pester');
        }).catch(function(err){
            console.log('error');
            if(err === '') ref.quickasynPackageDeploy(component,asynId,counter+1,ref,recordId);
            else ref.showMessage(component,event,'Deploy error','some error occured : ' + err,'1000','error','sticky');
            
        });
    },
    quickdeployResponse: function(asynId,action,ref,recordId,deployrecordId){
        return new Promise(function(resolve, reject) {
            action.setParams({ 'asyncResultId' : asynId, 'parentId' : recordId, 'deployrecordId' : deployrecordId });
            action.setCallback(ref, function(a) {
                var state = a.getState(); 
                if (state === "SUCCESS"){
                    let res = a.getReturnValue();
                    if(res === 'success'){
                        resolve(res);
                    }else{
                        reject(res);
                    }
                }else{
                    reject('STATE:'+state);
                }
            }); 
            $A.enqueueAction(action);
        });
    },
    
    deletedeployRequest : function(component, event, zipDelVal){
        console.log('zipDelVal',zipDelVal);
        let counter = 0;
        const self = this;
        var action = component.get("c.deletedeploySelectedPackage");
        var recordId = component.get('v.rollbackrecord');
        console.log('recordId-------',recordId);
        action.setParams({ 'delData' : zipDelVal,'parentId' : recordId});
        action.setCallback(self, function(a) {
            var state = a.getState(); 
            if (state === "SUCCESS"){
                console.log('resultDeployId:'+a.getReturnValue());
                let asynId = a.getReturnValue();
                if(asynId !== '' || asynId !== null || typeof(asynId) !== undefined){
                    self.deleteasynPackageDeploy(component,asynId,counter,self,recordId);
                    console.log('-----+++');
                }
            }else{
                self.showMessage(component,event,'error','Deploy request error.' + err,'1000','error','sticky');
                console.log('====+++');
                console.log('STATE:',state);
            }
        }); 
        $A.enqueueAction(action);
    },
    deleteasynPackageDeploy : function(component,asynId,counter,ref,recordId){
        
        var action = component.get("c.deletecheckdeploymentresult");
        console.log('=======+++++Hello');
        ref.deletedeployResponse(asynId,action,ref,recordId).then(function(result){ 
            console.log('success---');
            ref.showMessage(component,event,'Deploy success','Package successfully deleted.','1000','success','pester');
        }).catch(function(err){
            console.log('error---');
            if(err === '') ref.deleteasynPackageDeploy(component,asynId,counter+1,ref,recordId);
            else ref.showMessage(component,event,'Deploy error','some error occured : ' + err,'1000','error','sticky');
            
        });
    },
    deletedeployResponse: function(asynId,action,ref,recordId){
        return new Promise(function(resolve, reject) {
            action.setParams({ 'asyncResultId' : asynId, 'parentId' : recordId});
            action.setCallback(ref, function(a) {
                var state = a.getState(); 
                if (state === "SUCCESS"){
                    let res = a.getReturnValue();
                    if(res === 'success'){
                        resolve(res);
                    }else{
                        reject(res);
                    }
                }else{
                    reject('STATE:'+state);
                }
            }); 
            $A.enqueueAction(action);
        });
    },
    saveRollbackData : function(component, event,selectTestLevel,specifiedTestClass,MetadataMembersMap){
        console.log('saverollback data called');
        var isBackUp = component.get('v.myBool1');
        var destructivemetaMap = component.get('v.destructiveMap');
        var obj= JSON.stringify(MetadataMembersMap);
        var rollbackmetaMap = component.get('v.rollbackMap');
        var action = component.get("c.saveRollbackData")
        var objdel = JSON.stringify(destructivemetaMap);
       // var recordId = component.get('v.selecteddeploymentRecordId');
        var recordId = component.get('v.deploymentDetailRecordId');
        console.log('recordId@@@@',recordId);
        var objroll = JSON.stringify(rollbackmetaMap);
        var bool = component.get('v.myBool1');
        let rollbackdata = component.get('v.rollbackpackageZip');
        let destructdata = component.get('v.destructivepackagezip');
        let packagedata = component.get('v.packageZipFile');
        action.setParams({ 'rollbackdata' : rollbackdata, 'isBackUp' : isBackUp, 'quickDeploy' : packagedata, 'parentId' : recordId, 'testLevel' : selectTestLevel, 'testClass' : specifiedTestClass, 'destructdata' : destructdata, 'datatodel' : objdel, 'datatoroll' : objroll,'selectedMetadataMap' : obj, 'bollbackup' : bool });
        action.setCallback(this, function(a) {
            var state = a.getState();
            console.log('state',state);
            if (state === "SUCCESS"){
                component.set('v.DeploymentRecordId', a.getReturnValue());
                console.log('record saved',a.getReturnValue());
            }else{
                reject('STATE:'+state);
            }
        });
        $A.enqueueAction(action);
    },
    
    updateZipHelper : function(component,rawData){ 
        const that = this;
        let covertedfile = atob(rawData);
        var count = 0;
        var total = 0;
        var filesUpdate =[];
        var jsZip = new JSZip();
        let onComplete = new Promise(function(resolve, reject) {
            jsZip.loadAsync(covertedfile).then(function(zipData) {
                Object.keys(zipData.files).forEach(function(filename) {
                    if(filename.includes("meta.xml") && (filename.includes("reports") || filename.includes("dashboards") || filename.includes("email")))
                        total++;                    
                });
                Object.keys(zipData.files).forEach(function(filename) {
                    var patt = /<sharedTo>/g;                    
                    if(filename.includes("meta.xml") && (filename.includes("reports") || filename.includes("dashboards") || filename.includes("email"))){
                        zipData.files[filename].async("string").then(function success(content){
                            if(patt.test(content)){
                                let newContent = content.replace(content.match('<sharedTo>'+'(.*)'+'</sharedTo>')[1],component.get('v.DestinationUser'));
                                jsZip.file(filename, newContent);                                                          
                            }                            	
                            count++;
                            if(count==total)
                                resolve(jsZip);                                                    
                        }).catch(err => reject(err));                                               
                    }
                });
            }).catch(err => console.log('Invalid raw data',err.message));
        });
        onComplete.then(function(response) { 
            response.generateAsync({ type: "string" }).then(function (content) {
                component.set('v.packageZipFile', btoa(content));
            });
        })
    },
    
    destinationAdmin : function(component,event){
        var action = component.get("c.nameDestinationAdmin");
        var sourceOrg = component.get('v.SourceOrg');
        var destinationOrg = component.get('v.DestinationOrg');
        action.setParams({ sourceOrg : sourceOrg, destinationOrg : destinationOrg });            
        action.setCallback(self, function(a) {
            var state = a.getState();
            if(state === "SUCCESS"){
                component.set('v.DestinationUser', a.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },    
})