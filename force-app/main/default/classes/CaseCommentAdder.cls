public with sharing class CaseCommentAdder {
    public class Request {
        @InvocableVariable(label='Case Id' required=true)
        public String caseId;
        @InvocableVariable(label='Comment Body' required=true)
        public String commentBody;
        @InvocableVariable(label='Is Public')
        public Boolean isPublic;
    }

    public class Result {
        @InvocableVariable public Boolean commentSuccess;
        @InvocableVariable public String commentMessage;
    }

    @InvocableMethod(label='Add Case Comment' description='Inserts a CaseComment record — internal or public based on isPublic flag')
    public static List<Result> addComment(List<Request> requests) {
        List<Result> results = new List<Result>();
        for (Request req : requests) {
            results.add(doAdd(req));
        }
        return results;
    }

    private static Result doAdd(Request req) {
        Result r = new Result();
        if (String.isBlank(req.caseId) || String.isBlank(req.commentBody)) {
            r.commentSuccess = false;
            r.commentMessage = 'Case ID and comment body are required.';
            return r;
        }

        try {
            CaseComment cc = new CaseComment(
                ParentId = req.caseId,
                CommentBody = req.commentBody,
                IsPublished = req.isPublic != null ? req.isPublic : false
            );
            insert cc;
            String visibility = (req.isPublic == true) ? 'public' : 'internal';
            r.commentSuccess = true;
            r.commentMessage = 'Comment added successfully as ' + visibility + '.';
        } catch (Exception e) {
            r.commentSuccess = false;
            r.commentMessage = 'Failed to add comment: ' + e.getMessage();
        }
        return r;
    }
}