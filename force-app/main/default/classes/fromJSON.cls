public class fromJSON{
    public cls_query query;
    public cls_results results;
    public class cls_query {
        public Integer count;   //1
    }
    public class cls_results {
        public cls_USD_INR USD_INR;
    }
    public class cls_USD_INR {
        public String id;   //USD_INR
        public Double val;  //77.96165
        public String to;   //INR
        public String fr;   //USD
    }
    public static fromJSON parse(String json){
        return (fromJSON) System.JSON.deserialize(json, fromJSON.class);
    }

   /* static testMethod void testParse() {
        String json=        '{"query":{"count":1},"results":{"USD_INR":{"id":"USD_INR","val":77.96165,"to":"INR","fr":"USD"}}}';
        fromJSON obj = parse(json);
        System.assert(obj != null);
    }*/
}