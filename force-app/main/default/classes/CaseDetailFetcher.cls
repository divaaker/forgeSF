public with sharing class CaseDetailFetcher {
    public class Request {
        @InvocableVariable(label='Case Number Or Id' required=true)
        public String caseNumberOrId;
    }

    public class Result {
        @InvocableVariable public String caseId;
        @InvocableVariable public String caseNumber;
        @InvocableVariable public String subject;
        @InvocableVariable public String status;
        @InvocableVariable public String priority;
        @InvocableVariable public String ownerName;
        @InvocableVariable public String accountName;
        @InvocableVariable public String contactName;
        @InvocableVariable public String caseDescription;
        @InvocableVariable public String createdDate;
        @InvocableVariable public String slaStatus;
        @InvocableVariable public Integer commentCount;
        @InvocableVariable public String recentComments;
        @InvocableVariable public Boolean caseFound;
    }

    @InvocableMethod(label='Get Case Details' description='Fetches full case record with comments, entitlement, and SLA milestone status')
    public static List<Result> fetch(List<Request> requests) {
        List<Result> results = new List<Result>();
        for (Request req : requests) {
            results.add(doFetch(req.caseNumberOrId));
        }
        return results;
    }

    private static Result doFetch(String caseNumberOrId) {
        Result r = new Result();
        if (String.isBlank(caseNumberOrId)) {
            r.caseFound = false;
            return r;
        }

        String trimmed = caseNumberOrId.trim();
        String whereClause = trimmed.startsWith('500') && trimmed.length() == 18
            ? 'Id = :trimmed'
            : 'CaseNumber = :trimmed';

        List<Case> cases = Database.query(
            'SELECT Id, CaseNumber, Subject, Status, Priority, '
            + 'Owner.Name, Account.Name, Contact.Name, Description, CreatedDate '
            + 'FROM Case WHERE ' + whereClause + ' LIMIT 1'
        );

        if (cases.isEmpty()) {
            r.caseFound = false;
            return r;
        }

        Case c = cases[0];
        r.caseFound = true;
        r.caseId = c.Id;
        r.caseNumber = c.CaseNumber;
        r.subject = c.Subject != null ? c.Subject : '';
        r.status = c.Status != null ? c.Status : '';
        r.priority = c.Priority != null ? c.Priority : '';
        r.ownerName = c.Owner != null ? c.Owner.Name : '';
        r.accountName = c.Account != null ? c.Account.Name : '';
        r.contactName = c.Contact != null ? c.Contact.Name : '';
        r.caseDescription = c.Description != null ? c.Description : '';
        r.createdDate = c.CreatedDate != null ? c.CreatedDate.format('yyyy-MM-dd HH:mm') : '';

        List<CaseMilestone> milestones = [
            SELECT MilestoneType.Name, IsCompleted, TargetDate
            FROM CaseMilestone
            WHERE CaseId = :c.Id AND IsCompleted = false
            ORDER BY TargetDate ASC
            LIMIT 1
        ];
        if (!milestones.isEmpty()) {
            CaseMilestone m = milestones[0];
            r.slaStatus = m.TargetDate != null && m.TargetDate < Datetime.now()
                ? 'Breached — ' + m.MilestoneType.Name
                : 'At risk — ' + m.MilestoneType.Name + ' due ' + m.TargetDate.format('yyyy-MM-dd HH:mm');
        } else {
            r.slaStatus = 'On track';
        }

        List<CaseComment> comments = [
            SELECT CommentBody, CreatedDate, CreatedBy.Name, IsPublished
            FROM CaseComment
            WHERE ParentId = :c.Id
            ORDER BY CreatedDate DESC
            LIMIT 3
        ];
        r.commentCount = comments.size();
        List<String> commentLines = new List<String>();
        for (CaseComment cc : comments) {
            String visibility = cc.IsPublished ? 'Public' : 'Internal';
            commentLines.add('[' + cc.CreatedDate.format('MM/dd HH:mm') + ' | ' + cc.CreatedBy.Name
                + ' | ' + visibility + '] ' + cc.CommentBody);
        }
        r.recentComments = commentLines.isEmpty() ? 'No comments.' : String.join(commentLines, '\n');

        return r;
    }
}