public with sharing class ProjectUtil {

    public static void applyDefaults(List<Project__c> projects) {
        ProjectConfig__mdt cfg = getDefaultConfig();
        for (Project__c p : projects) {
            if (String.isBlank(p.Status__c)) {
                p.Status__c = cfg != null && String.isNotBlank(cfg.DefaultStatus__c)
                    ? cfg.DefaultStatus__c
                    : 'Planned';
            }
            if (p.StartDate__c == null) {
                p.StartDate__c = Date.today();
            }
        }
    }

    public static ProjectConfig__mdt getDefaultConfig() {
        List<ProjectConfig__mdt> rows = [
            SELECT DeveloperName, DefaultStatus__c, DefaultBudget__c
            FROM ProjectConfig__mdt
            WHERE DeveloperName = 'Default'
            LIMIT 1
        ];
        return rows.isEmpty() ? null : rows[0];
    }
}