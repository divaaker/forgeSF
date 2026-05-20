public class DestructiveRollback {
    public static string packageXml(){
        string packageXml = '<?xml version="1.0" encoding="UTF-8"?>'+
            '<Package xmlns="http://soap.sforce.com/2006/04/metadata">'+
            '<version>48.0</version>'+
            '</Package>';
        return packageXml;
    }
    public static string destructivePackageXml(Map<string,Set<string>> packageFile){
        string packageDestructiveXml = '<?xml version="1.0" encoding="UTF-8"?>'+
            '<Package xmlns="http://soap.sforce.com/2006/04/metadata">';
        string file ='';
        for(string name : packageFile.keySet()){
            if(file == ''){
                file='<types>';
                for(string member : packageFile.get(name))
                    file = file +'<members>' + member + '</members>';
                file = file+ '<name>'+ name +'</name>'+'</types>';
            }else{
                file = file + '<types>';
                for(string member : packageFile.get(name))
                    file = file +'<members>' + member + '</members>';
                file = file+ '<name>'+ name +'</name>'+'</types>';
            }
            
        }
        packageDestructiveXml = packageDestructiveXml + file +
            '<version>48.0</version>'+
            '</Package>';
        return packageDestructiveXml;
    }
}