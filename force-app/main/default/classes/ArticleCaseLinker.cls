public with sharing class ArticleCaseLinker {
    public class Request {
        @InvocableVariable(label='Case Id' required=true)
        public String caseId;
        @InvocableVariable(label='Article Id' required=true)
        public String articleId;
    }

    public class Result {
        @InvocableVariable public Boolean attachSuccess;
        @InvocableVariable public String attachMessage;
    }

    @InvocableMethod(label='Attach Article to Case' description='Links a ContentDocument (solution document) to a case via ContentDocumentLink')
    public static List<Result> attach(List<Request> requests) {
        List<Result> results = new List<Result>();
        for (Request req : requests) {
            results.add(doAttach(req.caseId, req.articleId));
        }
        return results;
    }

    private static Result doAttach(String caseId, String articleId) {
        Result r = new Result();
        if (String.isBlank(caseId) || String.isBlank(articleId)) {
            r.attachSuccess = false;
            r.attachMessage = 'Case ID and Document ID are both required.';
            return r;
        }

        List<ContentDocumentLink> existing = [
            SELECT Id FROM ContentDocumentLink
            WHERE LinkedEntityId = :caseId AND ContentDocumentId = :articleId
            LIMIT 1
        ];
        if (!existing.isEmpty()) {
            r.attachSuccess = true;
            r.attachMessage = 'This document is already attached to the case.';
            return r;
        }

        try {
            ContentDocumentLink link = new ContentDocumentLink(
                LinkedEntityId = caseId,
                ContentDocumentId = articleId,
                ShareType = 'V'
            );
            insert link;
            r.attachSuccess = true;
            r.attachMessage = 'Document successfully attached to the case.';
        } catch (Exception e) {
            r.attachSuccess = false;
            r.attachMessage = 'Failed to attach document: ' + e.getMessage();
        }
        return r;
    }
}