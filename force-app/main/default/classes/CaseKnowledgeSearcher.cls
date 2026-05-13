public with sharing class CaseKnowledgeSearcher {
    public class Request {
        @InvocableVariable(label='Search Keywords' required=true)
        public String searchKeywords;
        @InvocableVariable(label='Case Id')
        public String caseId;
    }

    public class Result {
        @InvocableVariable public String articleResults;
        @InvocableVariable public Integer articleCount;
        @InvocableVariable public Boolean hasResults;
    }

    @InvocableMethod(label='Search Knowledge Articles' description='SOSL search on ContentVersion documents for solution content matching the keywords')
    public static List<Result> search(List<Request> requests) {
        List<Result> results = new List<Result>();
        for (Request req : requests) {
            results.add(doSearch(req.searchKeywords));
        }
        return results;
    }

    private static Result doSearch(String keywords) {
        Result r = new Result();
        if (String.isBlank(keywords)) {
            r.hasResults = false;
            r.articleCount = 0;
            r.articleResults = 'No search keywords provided.';
            return r;
        }

        String sanitized = String.escapeSingleQuotes(keywords.trim());

        // Search ContentVersion (files/documents) for matching solution content
        List<List<SObject>> searchResults = Search.query(
            'FIND \'' + sanitized + '\' IN ALL FIELDS '
            + 'RETURNING ContentVersion(Id, ContentDocumentId, Title, Description, FileType, LastModifiedDate '
            + 'WHERE IsLatest = true) '
            + 'LIMIT 10'
        );

        List<ContentVersion> docs = (List<ContentVersion>) searchResults[0];
        r.articleCount = docs.size();

        if (docs.isEmpty()) {
            r.hasResults = false;
            r.articleResults = 'No solution documents found for "' + keywords + '". Try different search terms.';
            return r;
        }

        r.hasResults = true;
        List<String> lines = new List<String>();
        Integer idx = 1;
        for (ContentVersion d : docs) {
            String summary = String.isNotBlank(d.Description) ? d.Description : 'No description available.';
            String fileType = String.isNotBlank(d.FileType) ? ' [' + d.FileType + ']' : '';
            lines.add(idx + '. ' + d.Title + fileType + '\n   ' + summary
                + '\n   Document ID: ' + d.ContentDocumentId);
            idx++;
        }
        r.articleResults = String.join(lines, '\n\n');
        return r;
    }
}