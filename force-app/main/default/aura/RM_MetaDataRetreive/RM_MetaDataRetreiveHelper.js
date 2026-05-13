({
    fetchTypePicklist : function(component){
        var action = component.get("c.getOrgList");
        action.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS"){
                var v=a.getReturnValue();
                component.set("v.TypePicklist", a.getReturnValue());
            } 
        });
        $A.enqueueAction(action);
    },
    serverSideCall : function(component,action) {
        return new Promise(function(resolve, reject) { 
            action.setCallback(this, 
                               function(response) {
                                   var state = response.getState();
                                   if (state === "SUCCESS") {
                                       var result = response.getReturnValue();
                                       component.set("v.UnfilteredData",result);
                                       var deploylist = component.get("v.UnfilteredData");
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
                                       component.set("v.data",pagelist );
                                       var page=component.get("v.data");
                                       console.log('page',page);
                                       resolve(response.getReturnValue());
                                   } else {
                                       reject(new Error(response.getError()));
                                   }
                               }); 
            $A.enqueueAction(action);
        });
    },
    destinationlistdata : function(component, event, helper,sectionAuraId) {
        var action = component.get("c.targetaddMap");
        var sourceOrg = component.get('v.SourceOrg');
        var destinationOrg = component.get('v.DestinationOrg');
        action.setParams({metadataType: sectionAuraId, sourceOrg : sourceOrg, destinationOrg : destinationOrg });
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
    init_Server: function (component, event, helper) { 
        var sourceOrg = component.get('v.SourceOrg');
        var destinationOrg = component.get('v.DestinationOrg');
        var action = component.get("c.init");
        action.setParams({sourceOrg : sourceOrg, destinationOrg : destinationOrg });
        action.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS"){
                var result = a.getReturnValue();
                var arrayMapKeys = [];
                for(var key in result){
                    arrayMapKeys.push({key: key, value: result[key]});
                }
                console.log('arrayMapKeys',arrayMapKeys);
                component.set("v.MetadataHeader_alldata", arrayMapKeys);
                component.set("v.spinner", false);
                component.set("v.retrieveBool",false);
                component.set("v.packageBool",true);
            }
        });
        $A.enqueueAction(action);    
    },
    hideShowToggle: function(component,event,sectionDiv,sectionState){
        
        //var sectionAuraId = event.target.getAttribute("data-auraId");
        //var sectionDiv = document.getElementById(sectionAuraId);
        //var sectionState = sectionDiv.classList.contains('slds-is-close');
        if(sectionState){
            sectionDiv.setAttribute('class','slds-section slds-is-open');
        }
        else{
            sectionDiv.setAttribute('class' , 'slds-section slds-is-close');
            sectionDiv.removeAttribute('class' , 'slds-is-open');
        }
        
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
    downloadZipHelper : function(component,event, rawData){
        const that = this;
        //let result = component.get("v.rollbackpackageZip");
        let covertedfile = atob(rawData);
        let readZip = new JSZip();
        readZip.loadAsync(covertedfile)
        .then(function (readZip) {
            console.log(readZip.files);
            let content = readZip.generateAsync({type:"blob"})
            .then(function(content){
                saveAs(content, 'Package.zip');
                that.showMessage(component,event,'success','Download started...','1000','success','pester');
            });
        }).catch(err => that.showMessage(component,event,'error','Failed to download : ' + err.message,'1000','error','sticky'));
    },
    retrieveRequest : function(component,event,packageValue){
        let counter =  0;
        const self = this;
        var sourceOrg = component.get('v.SourceOrg');
        var destinationOrg = component.get('v.DestinationOrg');
        var action = component.get("c.retrieveSelectedPackage");
        action.setParams({ 'packagevalueJson' : JSON.stringify(packageValue), sourceOrg : sourceOrg, destinationOrg : destinationOrg});
        action.setCallback(self, function(a) {
            var state = a.getState();
            if(state === "SUCCESS"){
                console.log('state',state);
                let asynId = a.getReturnValue();
                if(asynId !== '' || asynId !== null){
                    self.asynPackageRetrieve(component,asynId,counter+1,self,sourceOrg,destinationOrg);
                }else{
                    component.set("v.spinner", false);
                    self.showMessage(component,event,'error','Retrieve request error.' + err,'1000','error','sticky');
                }
            }
        });
        $A.enqueueAction(action);
    },
    asynPackageRetrieve : function(component,asynId,counter,ref,sourceOrg,destinationOrg){
        let action = component.get("c.checkAsyncRequest");
        console.log('------');
        const self = this;
        ref.retrieveResponse(asynId,action,ref,sourceOrg,destinationOrg).then(function(result){ 
            component.set('v.packageZipFile',result);
            //self.ProfileDeployHelper(component, event, component.get('v.packageZipFile'));
            console.log('result',result);
            component.set("v.packageBool", false);
            component.set("v.deployBool",true);
            ref.showMessage(component,event,'Retrieve success','Package successfully retrieved.','1000','success','pester');
            component.set("v.spinner", false);
            self.updateZipHelper(component,result);
            
        }).catch(function(err){
            if(err === '') ref.asynPackageRetrieve(component,asynId,counter+1,ref,sourceOrg,destinationOrg);
            else
            {
                ref.showMessage(component,event,'Retrieve error','some error occured : ' + err,'1000','error','sticky');
                component.set("v.spinner", false);
            }
        });
    },
    
    retrieveResponse : function(asynId,action,ref,sourceOrg,destinationOrg){
        console.log('asynId',asynId);
        return new Promise(function(resolve, reject) {
            action.setParams({ 'requestId' : asynId, sourceOrg : sourceOrg, destinationOrg : destinationOrg});
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
    
    backupretrieveRequest : function(component,event,packageValue){
        let counter =  0;
        const self = this;
        var sourceOrg = component.get('v.SourceOrg');
        var destinationOrg = component.get('v.DestinationOrg');
        console.log('packageValue',packageValue);
        var action = component.get("c.backupretrieveSelectedPackage");
        action.setParams({ 'packagevalueJson' : JSON.stringify(packageValue), sourceOrg : sourceOrg, destinationOrg : destinationOrg });
        action.setCallback(self, function(a) {
            var state = a.getState();
            if(state === "SUCCESS"){
                console.log('state',state);
                let asynId = a.getReturnValue();
                if(asynId !== '' || asynId !== null){
                    self.backupasynPackageRetrieve(component,asynId,counter+1,self,sourceOrg,destinationOrg);
                }else{
                    self.showMessage(component,event,'error','Retrieve request error.' + err,'1000','error','sticky');
                }
            }
        });
        $A.enqueueAction(action);
    },
    backupasynPackageRetrieve : function(component,asynId,counter,ref,sourceOrg,destinationOrg){
        let action = component.get("c.backupcheckAsyncRequest");
        console.log('backup------');
        ref.backupretrieveResponse(asynId,action,ref,sourceOrg,destinationOrg).then(function(result){ 
            component.set('v.rollbackpackageZip',result);
            
            console.log('backupresult',result);
        }).catch(function(err){
            if(err === '') ref.backupasynPackageRetrieve(component,asynId,counter+1,ref,sourceOrg,destinationOrg);
        });
    },
    
    backupretrieveResponse : function(asynId,action,ref,sourceOrg,destinationOrg){
        console.log('backupasynId',asynId);
        return new Promise(function(resolve, reject) {
            action.setParams({ 'requestId' : asynId, sourceOrg : sourceOrg, destinationOrg : destinationOrg });
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
    deployRequest : function(component, event, zipFileVal,selectTestLevel,specifiedTestClass,sourceOrg,destinationOrg){        
        let counter = 0;
        const self = this;
        var action = component.get("c.deploySelectedPackage");
        action.setParams({ data:{'zipFile' : zipFileVal,'testlevel' : selectTestLevel,'allTestClass' : specifiedTestClass, 'sourceOrg' : sourceOrg, 'destinationOrg' : destinationOrg}});
        action.setCallback(self, function(a) {
            var state = a.getState(); 
            
            if (state === "SUCCESS"){
                let asynId = a.getReturnValue();
                if(asynId !== '' || asynId !== null || typeof(asynId) !== undefined){
                    self.asynPackageDeploy(component,asynId,counter,self,sourceOrg,destinationOrg);
                }
            }else{
                self.showMessage(component,event,'error','Deploy request error.' + err,'1000','error','sticky');
            }
        }); 
        $A.enqueueAction(action);
    },
    asynPackageDeploy : function(component,asynId,counter,ref,sourceOrg,destinationOrg){
        var action = component.get("c.checkdeploymentresult");
        let packageId = component.get("v.ParentRecordId");
        console.log('packageId',packageId);
        let deployrecordId = component.get("v.DeploymentRecordId");
        console.log('deployrecordId',deployrecordId);
        
        ref.deployResponse(asynId,action,ref,packageId,sourceOrg,destinationOrg,deployrecordId).then(function(result){
            console.log('success');
            ref.showMessage(component,event,'Deploy success','Package successfully deployed.','1000','success','pester');
            component.set("v.spinner", false);
        }).catch(function(err){
            if(err === '') ref.asynPackageDeploy(component,asynId,counter+1,ref,sourceOrg,destinationOrg,deployrecordId);
            else{
                console.log('error');
                ref.showMessage(component,event,'Deploy error','some error occured : ' + err,'1000','error','sticky');
                component.set("v.spinner", false);
            }
        });
    },
    deployResponse: function(asynId,action,ref,packageId,sourceOrg, destinationOrg,deployrecordId){
        return new Promise(function(resolve, reject) {
            action.setParams({ 'resId' : asynId, 'packageId' : packageId, 'sourceOrg' : sourceOrg, 'destinationOrg' : destinationOrg, 'parentId' : deployrecordId});
            action.setCallback(ref, function(a) {
                var state = a.getState(); 
                if (state === "SUCCESS"){
                    let res = a.getReturnValue();
                    console.log('res',res);
                    if(res === 'Success'){
                        console.log('if');
                        resolve(res);
                    }else{
                        console.log('else');
                        reject(res);
                    }
                }else{
                    console.log('elseelse');
                    reject('STATE:'+state);
                }
            }); 
            $A.enqueueAction(action);
        });
    },
    
    ValidateRequest : function(component, event, zipFileVal,selectTestLevel,specifiedTestClass,sourceOrg,destinationOrg){
        let counter = 0;
        const self = this;
        
        var action = component.get("c.validateSelectedPackage");
        action.setParams({ data:{'zipFile' : zipFileVal, 'Testlevel' : selectTestLevel, 'alltestclass' : specifiedTestClass, 'sourceOrg' : sourceOrg, 'destinationOrg' : destinationOrg}});
        action.setCallback(self, function(a) {
            var state = a.getState();
            
            if (state === "SUCCESS"){
                let asynId = a.getReturnValue();
                if(asynId !== '' || asynId !== null || typeof(asynId) !== undefined){
                    self.asynPackageValidate(component,asynId,counter,self,sourceOrg,destinationOrg);
                }
            }
            else{
                self.showMessage(component,event,'error','Validation request error.' + err,'1000','error','sticky');
                component.set("v.spinnerval", false);
            }
        }); 
        $A.enqueueAction(action);
    },
    
    asynPackageValidate : function(component,asynId,counter,ref,sourceOrg,destinationOrg){
        console.log('ref ',ref);
        console.log('Async id ',asynId);
        let packageId = component.get("v.ParentRecordId");
        let deployrecordId = component.get("v.DeploymentRecordId");
        console.log('deployrecordId',deployrecordId);
        console.log('packageIdbefore',packageId);
        var action = component.get("c.validatedeploymentresult");
        
        console.log('packageId',packageId);
        
        ref.ValidateResponse(asynId,action,ref,packageId,sourceOrg,destinationOrg,deployrecordId).then(function(result){ 
            ref.showMessage(component,event,'Validation Success','Package Validated Successfully.','1000','success','pester');
            component.set("v.spinnerval", false);
            component.set("v.ValidateStatus", true);
            console.log('Succeess');
        }).catch(function(err){
            console.log('counter',counter);
            if(err === '') ref.asynPackageValidate(component,asynId,counter+1,ref,sourceOrg,destinationOrg,deployrecordId);
            else{
                ref.showMessage(component,event,'Validation error','some error occured : failure','1000','error','sticky');
                component.set('v.errormessage', err);
                component.set("v.spinnerval", false);
                component.set("v.ValidateStatus", false);
                component.set("v.errortrue",true);
            }
        });
    },
    ValidateResponse: function(asynId,action,ref,packageId,sourceOrg,destinationOrg,deployrecordId){
        return new Promise(function(resolve, reject) {
            action.setParams({ 'resId' : asynId, 'packageId' : packageId, 'sourceOrg' : sourceOrg, 'destinationOrg' : destinationOrg, 'parentId' : deployrecordId});
            action.setCallback(ref, function(a) {
                var state = a.getState(); 
                if (state === "SUCCESS"){
                    var respo = JSON.stringify(a.getReturnValue());
                    var res = JSON.parse(respo);
                    if(res.response === 'Validated'){
                        resolve(res.response);
                    }
                    else if(res.response === 'Validation Failure'){
                        console.log('res.msg-------',res.msg);
                        reject(res.msg);
                    }
                        else{
                            reject(res.response);
                        }
                }else{
                    reject('STATE:'+state);
                }
            }); 
            $A.enqueueAction(action);
        });
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
    ProfileDeployHelper : function(component, event, rawData, desData){
        const that = this;
        
        let SourceData = atob(rawData);
        let DestinationData = atob(desData);
        console.log('Source Data '+SourceData);
        console.log('Destination Data '+DestinationData);
        var jsZip = new JSZip();
        jsZip.loadAsync(SourceData).then(function(zipData) {
            Object.keys(zipData.files).forEach(function(filename) {
                if(filename.includes(".profile")){   
                    zipData.files[filename].async("string").then(function success(content){
                        console.log('log Data '+content);
                    }).catch(err => reject(err));
                }
            });
            
            
        }).catch((e) => {
            
        });
        jsZip.loadAsync(DestinationData).then(function(zipData) {
            Object.keys(zipData.files).forEach(function(filename) {
                if(filename.includes(".profile")){   
                    zipData.files[filename].async("string").then(function success(content){
                        console.log('DestinationData Data '+content);
                    }).catch(err => reject(err));
                }
            });
            
            
        }).catch((e) => {
            
        });
    },
    
    createDeploymentObjects : function(component,testLevel,testClass,sourceOrg, destinationOrg){
        var isBackUp = component.get('v.myBool');
        var MetadataMembersMap = component.get('v.SelectedMetadataMembersMap');
        var destructivemetaMap = component.get('v.destructiveMap');
        var rollbackmetaMap = component.get('v.rollbackMap');
        var action = component.get("c.insertInDeploymentObjects");
        var obj= JSON.stringify(MetadataMembersMap);
        var objdel = JSON.stringify(destructivemetaMap);
        var objroll = JSON.stringify(rollbackmetaMap);
        let rollbackdata = component.get('v.rollbackpackageZip');
        let destructdata = component.get('v.destructivepackagezip');
        let packagedata = component.get('v.packageZipFile');
        action.setParams({
            'testLevel' : testLevel, 
            'testClass' : testClass, 
            'isBackUp' : isBackUp, 
            'sourceOrg' : sourceOrg, 
            'destinationOrg' : destinationOrg, 
            'quickDeploy' : packagedata, 
            'rollbackdata' : rollbackdata, 
            'destructdata' : destructdata, 
            'datatodel': objdel, 
            'datatoroll': objroll, 
            'selectedMetadataMap': obj });
        action.setCallback(self, function(a) {
            var state = a.getState();
            if(state === "SUCCESS"){
                component.set('v.DeploymentRecordId', a.getReturnValue());
                console.log('upsi',a.getReturnValue());
                console.log('Depolyment Objects successfully created');
            }
        });
        $A.enqueueAction(action);
    },
    
    saveSeletedMetadataMap : function(component, event){
        var MetadataMembersMap = component.get('v.SelectedMetadataMembersMap');
        var sourceOrg = component.get('v.SourceOrg');
        var destinationOrg = component.get('v.DestinationOrg');
        var deploymentName = component.get('v.DeploymentName');
        var deploymentdescripton = component.get('v.DeploymentDescription');
        console.log('destinationOrg=====',destinationOrg);
        component.set("v.spinner", true);
        var action = component.get("c.saveSeletedMetadataMemberMap");
        var obj= JSON.stringify(MetadataMembersMap);
        console.log('obj',obj);
        action.setParams({
            data: {
                'selectedMetadataMap': obj, 'sourceOrg' : sourceOrg, 
                'destinationOrg' : destinationOrg, 'deploymentName' : deploymentName, 
                'deploymentDescription' : deploymentdescripton 
            }
        }); 
        action.setCallback(this, function(a) {
            var state = a.getState(); 
            if (state === "SUCCESS"){
                component.set('v.ParentRecordId', a.getReturnValue());
            } 
        });
        $A.enqueueAction(action);
    },
    FilterRecords: function(component) {
        var tempArray =[];
        var data = component.get("v.data");  
        var allData = component.get("v.UnfilteredData");
        console.log('data',data);
        console.log('allData',allData);
        var searchKey = component.get("v.filter");
        var	i;
        if(data!=undefined || data.length>0){ 
            for(i=0; i < allData.length; i++){
                console.log('searchKey',searchKey);
                if(allData[i].toUpperCase().startsWith(searchKey.toUpperCase())){
                    console.log('allData[i]',allData[i]);
                    tempArray.push(allData[i]);
                }
            }
            console.log('**----'+tempArray);  
        }  
        component.set("v.data", tempArray);  
        if(searchKey==''){
            debugger;
            var deploylist = component.get("v.UnfilteredData");
            var pagesize=component.get("v.pageSizeSuccess");
            component.set("v.endSuccess",pagesize );
            component.set("v.startSuccess",0 );
            component.set("v.totalSizeSuccess", allData.length);
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
            component.set("v.data",pagelist );
            var page=component.get("v.data");
            console.log('page',page);
            //component.set("v.data",component.get("v.UnfilteredData"));
        }  
    }
})