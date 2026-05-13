public with sharing class SimilarCaseFinder {
    public class Request {
        @InvocableVariable(label='Search Text' required=true)
        public String searchText;
        @InvocableVariable(label='Exclude Case Id')
        public String excludeCaseId;
    }

    public class Result {
        @InvocableVariable public String similarCasesText;
        @InvocableVariable public Integer caseCount;
        @InvocableVariable public Boolean hasResults;
    }

    @InvocableMethod(label='Find Similar Cases' description='SOSL search on Case subject and description to find related cases')
    public static List<Result> find(List<Request> requests) {
        List<Result> results = new List<Result>();
        for (Request req : requests) {
            results.add(doFind(req.searchText, req.excludeCaseId));
        }
        return results;
    }

    private static Result doFind(String searchText, String excludeCaseId) {
        Result r = new Result();
        if (String.isBlank(searchText)) {
            r.hasResults = false;
            r.caseCount = 0;
            r.similarCasesText = 'No search text provided.';
            return r;
        }

        String sanitized = String.escapeSingleQuotes(searchText.trim());
        List<List<SObject>> searchResults = Search.query(
            'FIND \'' + sanitized + '\' IN ALL FIELDS '
            + 'RETURNING Case(Id, CaseNumber, Subject, Status, Priority, CreatedDate, Description) '
            + 'LIMIT 10'
        );

        List<Case> cases = (List<Case>) searchResults[0];

        List<Case> filtered = new List<Case>();
        for (Case c : cases) {
            if (String.isBlank(excludeCaseId) || c.Id != excludeCaseId) {
                filtered.add(c);
            }
        }

        r.caseCount = filtered.size();
        if (filtered.isEmpty()) {
            r.hasResults = false;
            r.similarCasesText = 'No similar cases found for "' + searchText + '".';
            return r;
        }

        r.hasResults = true;
        List<String> lines = new List<String>();
        for (Case c : filtered) {
            String line = '• Case ' + c.CaseNumber + ' [' + c.Status + ' | ' + c.Priority + '] — ' + c.Subject;
            if (String.isNotBlank(c.Description)) {
                String snippet = c.Description.length() > 120 ? c.Description.substring(0, 120) + '...' : c.Description;
                line += '\n  ' + snippet;
            }
            lines.add(line);
        }
        r.similarCasesText = 'Found ' + filtered.size() + ' similar case(s):\n\n' + String.join(lines, '\n\n');
        return r;
    }
}