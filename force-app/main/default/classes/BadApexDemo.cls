//Deployment 3
//Deployment 5
//commit test 
public class BadApexDemo {
    public static void hitSOQLLimit() {
        for (Integer i = 0; i < 101; i++) {
            List<Account> accs = [SELECT Id FROM Account LIMIT 1];
        }
    }
}