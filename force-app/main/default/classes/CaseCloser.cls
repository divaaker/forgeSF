public with sharing class CaseCloser {
    public class Request {
        @InvocableVariable(label='Case Id' required=true)
        public String caseId;
        @InvocableVariable(label='Resolution Notes' required=true)
        public String resolutionNotes;
        @InvocableVariable(label='Send Notification')
        public Boolean sendNotification;
    }

    public class Result {
        @InvocableVariable public Boolean closeSuccess;
        @InvocableVariable public String closeMessage;
        @InvocableVariable public String closedCaseNumber;
    }

    @InvocableMethod(label='Close Case' description='Sets Status to Closed, writes resolution notes as a public comment, and optionally emails the case contact')
    public static List<Result> close(List<Request> requests) {
        List<Result> results = new List<Result>();
        for (Request req : requests) {
            results.add(doClose(req));
        }
        return results;
    }

    private static Result doClose(Request req) {
        Result r = new Result();
        r.closedCaseNumber = '';

        if (String.isBlank(req.caseId) || String.isBlank(req.resolutionNotes)) {
            r.closeSuccess = false;
            r.closeMessage = 'Case ID and resolution notes are required.';
            return r;
        }

        List<Case> cases = [
            SELECT Id, CaseNumber, Status, ContactId, Contact.Email, Contact.Name, Subject, Description
            FROM Case WHERE Id = :req.caseId LIMIT 1
        ];
        if (cases.isEmpty()) {
            r.closeSuccess = false;
            r.closeMessage = 'Case not found with ID: ' + req.caseId;
            return r;
        }

        Case c = cases[0];
        if (c.Status == 'Closed') {
            r.closeSuccess = false;
            r.closeMessage = 'Case ' + c.CaseNumber + ' is already closed.';
            r.closedCaseNumber = c.CaseNumber;
            return r;
        }

        c.Status = 'Closed';
        c.Description = (String.isNotBlank(c.Description) ? c.Description + '\n\n' : '')
            + 'RESOLUTION: ' + req.resolutionNotes;

        try {
            update c;
            r.closedCaseNumber = c.CaseNumber;

            insert new CaseComment(
                ParentId = c.Id,
                CommentBody = 'Resolution: ' + req.resolutionNotes,
                IsPublished = true
            );

            if (req.sendNotification == true && c.ContactId != null && String.isNotBlank(c.Contact.Email)) {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setTargetObjectId(c.ContactId);
                mail.setWhatId(c.Id);
                mail.setSaveAsActivity(true);
                mail.setSubject('Your case ' + c.CaseNumber + ' has been resolved');
                mail.setPlainTextBody(
                    'Dear ' + c.Contact.Name + ',\n\n'
                    + 'Your case "' + c.Subject + '" (Case #' + c.CaseNumber + ') has been resolved.\n\n'
                    + 'Resolution: ' + req.resolutionNotes + '\n\n'
                    + 'If you need further assistance, please contact us.\n\nBest regards,\nSupport Team'
                );
                Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ mail });
                r.closeMessage = 'Case ' + c.CaseNumber + ' closed and notification sent to ' + c.Contact.Email + '.';
            } else {
                r.closeMessage = 'Case ' + c.CaseNumber + ' closed successfully.';
            }
            r.closeSuccess = true;
        } catch (Exception e) {
            r.closeSuccess = false;
            r.closeMessage = 'Failed to close case: ' + e.getMessage();
        }
        return r;
    }
}