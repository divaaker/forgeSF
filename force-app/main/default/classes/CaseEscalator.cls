public with sharing class CaseEscalator {
    public class Request {
        @InvocableVariable(label='Case Id' required=true)
        public String caseId;
        @InvocableVariable(label='Escalation Reason' required=true)
        public String escalationReason;
        @InvocableVariable(label='Escalate To')
        public String escalateTo;
        @InvocableVariable(label='Urgency Level')
        public String urgencyLevel;
    }

    public class Result {
        @InvocableVariable public Boolean escalateSuccess;
        @InvocableVariable public String escalateMessage;
        @InvocableVariable public String newOwnerName;
        @InvocableVariable public Boolean taskCreated;
    }

    @InvocableMethod(label='Escalate Case' description='Sets priority to Critical/High, assigns to escalation queue, creates follow-up Task, logs reason as internal comment')
    public static List<Result> escalate(List<Request> requests) {
        List<Result> results = new List<Result>();
        for (Request req : requests) {
            results.add(doEscalate(req));
        }
        return results;
    }

    private static Result doEscalate(Request req) {
        Result r = new Result();
        r.taskCreated = false;

        if (String.isBlank(req.caseId) || String.isBlank(req.escalationReason)) {
            r.escalateSuccess = false;
            r.escalateMessage = 'Case ID and escalation reason are required.';
            r.newOwnerName = '';
            return r;
        }

        List<Case> cases = [SELECT Id, CaseNumber, OwnerId, Status FROM Case WHERE Id = :req.caseId LIMIT 1];
        if (cases.isEmpty()) {
            r.escalateSuccess = false;
            r.escalateMessage = 'Case not found with ID: ' + req.caseId;
            r.newOwnerName = '';
            return r;
        }

        Case c = cases[0];
        String priority = String.isNotBlank(req.urgencyLevel) && req.urgencyLevel.equalsIgnoreCase('High') ? 'High' : 'Critical';
        c.Priority = priority;
        c.Status = 'Escalated';

        String targetName = String.isNotBlank(req.escalateTo) ? req.escalateTo : 'Escalation Queue';
        List<Group> queues = [SELECT Id, Name FROM Group WHERE Type = 'Queue' AND Name = :targetName LIMIT 1];
        if (queues.isEmpty()) {
            queues = [SELECT Id, Name FROM Group WHERE Type = 'Queue' ORDER BY Name LIMIT 1];
        }
        if (!queues.isEmpty()) {
            c.OwnerId = queues[0].Id;
            r.newOwnerName = queues[0].Name;
        } else {
            r.newOwnerName = 'Unassigned — no queue found';
        }

        try {
            update c;

            insert new CaseComment(
                ParentId = c.Id,
                CommentBody = 'ESCALATION — ' + priority + ': ' + req.escalationReason,
                IsPublished = false
            );

            Task t = new Task(
                WhatId = c.Id,
                Subject = 'Follow up on escalated case ' + c.CaseNumber,
                Description = req.escalationReason,
                Status = 'Not Started',
                Priority = priority,
                ActivityDate = Date.today().addDays(1)
            );
            insert t;
            r.taskCreated = true;

            r.escalateSuccess = true;
            r.escalateMessage = 'Case escalated to ' + priority + ' priority and assigned to ' + r.newOwnerName + '.';
        } catch (Exception e) {
            r.escalateSuccess = false;
            r.escalateMessage = 'Escalation failed: ' + e.getMessage();
        }
        return r;
    }
}