public class ObjectCreator {

    public static sObject createAndSet(Schema.sObjectField field, object fieldValue) {
        Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
        Schema.sObjectType sourceType = fieldDescribe.getSObjectType();  
        sObject newObj = sourceType.newSObject(null, true);
        newObj.put(field, fieldValue);
        return newObj;
    }
}