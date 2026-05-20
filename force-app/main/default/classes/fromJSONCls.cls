public class fromJSONCls{
	public cls_Results[] Results;
	class cls_Results {
		public cls_Result Result;
	}
	class cls_Result {
		public String IsDB;	//True
		public Integer Spend;	//453
		public cls_Paths[] Paths;
	}
	class cls_Paths {
		public cls_Technologies[] Technologies;
	}
	class cls_Technologies {
		public String IsPremium;	//no
		public String Name;	//SPF
		public String Description;	//The Sender Policy Framework is an open standard specifying a technical method to prevent sender address forgery.
		public String Link;	//http://www.openspf.org/
		public String Tag;	//mx
		public Integer FirstDetected;	//1566774000000
		public Integer LastDetected;	//1629702000000
	}
	public static fromJSONCls parse(String json){
		return (fromJSONCls) System.JSON.deserialize(json, fromJSONCls.class);
	}

	/*static testMethod void testParse() {
		String json=		'{'+
		'  "Results": ['+
		'    {'+
		'      "Result": {'+
		'        "IsDB": "True",'+
		'        "Spend": 453,'+
		'        "Paths": ['+
		'          {'+
		'            "Technologies": ['+
		'              {'+
		'                "IsPremium": "no",'+
		'                "Name": "SPF",'+
		'                "Description": "The Sender Policy Framework is an open standard specifying a technical method to prevent sender address forgery.",'+
		'                "Link": "http://www.openspf.org/",'+
		'                "Tag": "mx",'+
		'                "FirstDetected": 1566774000000,'+
		'                "LastDetected": 1629702000000'+
		'              }'+
		'            ]'+
		'          }'+
		'        ]'+
		'      }'+
		'    }'+
		'  ]'+
		'}';
		fromJSON obj = parse(json);
		System.assert(obj != null);
	}*/
}