Trigger updateCaseTrg on Case(Before Update){
	for(Case oCase : Trigger.New){
		if(oCase.OwnerID != UserInfo.getUserId()){
            oCase.addError('You can not edit this record');
		}
	}  
}