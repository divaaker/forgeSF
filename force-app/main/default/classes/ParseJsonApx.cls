public class ParseJsonApx {
    public static string Createdata(){
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
		'                "FirstDetected": "no",'+
		'                "LastDetected": "no"'+
		'              }'+
		'            ]'+
		'          }'+
		'        ]'+
		'      }'+
		'    }'+
		'  ]'+
		'}';
        //fromJSONCls.parse = parse(json);
        fromJSONCls results = (fromJSONCls) System.JSON.deserialize(json, fromJSONCls.class);
        system.debug(results);
        return null;
    }
}