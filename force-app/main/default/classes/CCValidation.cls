public class CCValidation {
	public boolean CCValidationMethod(String CCNumber){
    Integer sum = 0;
    Integer len = CCNumber.length();
    for(Integer i=len-1;i>=0;i--){
    Integer num = Integer.ValueOf(CCNumber.substring(i,i+1));
    if ( math.mod(i , 2) == math.mod(len, 2) )
    {
    Integer n = num * 2;
    sum += (n / 10) + ( math.mod(n, 10));
    }
    else{
    sum += num;
    }
    }
        system.debug(( math.mod( sum, 10) == 0 ));
    	return ( math.mod( sum, 10) == 0 );
	}

    @AuraEnabled( cacheable = true )
    public static List < Opportunity > fetchOpptys(){
        
        return [
            SELECT Id, Name, AccountId, Account.Name, Amount
            FROM Opportunity LIMIT 10
        ];
        

    }

    @AuraEnabled(cacheable=true)
    public static map<string,string> fetchAllObjectList(){
        Map<string,string> mapOfAllObject = new Map<string,string>();
        Map<String, string> sortedMap = new Map<String, string>();
        try {          
            for(Schema.SObjectType objTyp : Schema.getGlobalDescribe().values())
            {
                String objName = objTyp.getDescribe().getName();
                if(!objTyp.getDescribe().isCustomSetting() && objTyp.getDescribe().getRecordTypeInfos().size() > 0 && objTyp.getDescribe().isCreateable() && !objName.containsignorecase('history') && !objName.containsignorecase('tag') && !objName.containsignorecase('share') && !objName.containsignorecase('feed')){
                    string name = objTyp.getDescribe().getLocalName();
                    string label = objTyp.getdescribe().getlabel();
                    mapOfAllObject.put(name,label);
                    List<String> sortedList = new List<String>(mapOfAllObject.keyset());
                    sortedList.sort();
                    system.debug(sortedList);
                    for(String idKey : sortedList) {
                        system.debug(idKey);
                        sortedMap.put(idKey, mapOfAllObject.get(idKey));
                        system.debug(sortedMap);
                    }
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return sortedMap;
    }

    public List<String> getSortedKeyset(Map<String, String> dataMap) {
        List<String> keySetList = new List<String>();
        keySetList.addAll(dataMap.keySet());
        keySetList.sort();
        return keySetList;
    }
}