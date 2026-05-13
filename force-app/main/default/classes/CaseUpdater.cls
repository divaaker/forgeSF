public with sharing class CaseUpdater {
    public class Request {
        @InvocableVariable(label='Case Id' required=true)
        public String caseId;
        @InvocableVariable(label='New Status')
        public String newStatus;
        @InvocableVariable(label='New Priority')
        public String newPriority;
        @InvocableVariable(label='New Owner Id')
        public String newOwnerId;
        @InvocableVariable(label='Additional Info')
        public String additionalInfo;
    }

    public class Result {
        @InvocableVariable public Boolean updateSuccess;
        @InvocableVariable public String updateMessage;
        @InvocableVariable public String updatedFields;
    }

    @InvocableMethod(label='Update Case' description='Updates case fields: status, priority, owner, or appends additional description text')
    public static List<Result> updateCase(List<Request> requests) {
        List<Result> results = new List<Result>();
        for (Request req : requests) {
            results.add(doUpdate(req));
        }
        return results;
    }

    private static Result doUpdate(Request req) {
        Result r = new Result();
        if (String.isBlank(req.caseId)) {
            r.updateSuccess = false;
            r.updateMessage = 'Case ID is required.';
            r.updatedFields = '';
            return r;
        }

        List<Case> cases = [SELECT Id, Status, Priority, OwnerId, Description FROM Case WHERE Id = :req.caseId LIMIT 1];
        if (cases.isEmpty()) {
            r.updateSuccess = false;
            r.updateMessage = 'Case not found with ID: ' + req.caseId;
            r.updatedFields = '';
            return r;
        }

        Case c = cases[0];
        List<String> changed = new List<String>();

        if (String.isNotBlank(req.newStatus)) {
            c.Status = req.newStatus;
            changed.add('Status → ' + req.newStatus);
        }
        if (String.isNotBlank(req.newPriority)) {
            c.Priority = req.newPriority;
            changed.add('Priority → ' + req.newPriority);
        }
        if (String.isNotBlank(req.newOwnerId)) {
            if (req.newOwnerId.startsWith('005')) {
                c.OwnerId = req.newOwnerId;
                changed.add('Owner → ' + req.newOwnerId);
            } else {
                List<User> users = [SELECT Id, Name FROM User WHERE Username = :req.newOwnerId AND IsActive = true LIMIT 1];
                if (!users.isEmpty()) {
                    c.OwnerId = users[0].Id;
                    changed.add('Owner → ' + users[0].Name);
                }
            }
        }
        if (String.isNotBlank(req.additionalInfo)) {
            c.Description = (String.isNotBlank(c.Description) ? c.Description + '\n\n' : '') + req.additionalInfo;
            changed.add('Description appended');
        }

        if (changed.isEmpty()) {
            r.updateSuccess = false;
            r.updateMessage = 'No fields provided to update.';
            r.updatedFields = '';
            return r;
        }

        try {
            update c;
            r.updateSuccess = true;
            r.updatedFields = String.join(changed, ', ');
            r.updateMessage = 'Case updated successfully. Changed: ' + r.updatedFields;
        } catch (Exception e) {
            r.updateSuccess = false;
            r.updateMessage = 'Update failed: ' + e.getMessage();
            r.updatedFields = '';
        }
        return r;
    }
}