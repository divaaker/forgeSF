public with sharing class MCPBridgeAction {

    public class ActionInput {
        @InvocableVariable(label='Tool Name' required=true)
        public String toolName;

        @InvocableVariable(label='Payload JSON' required=true)
        public String payloadJson;

        @InvocableVariable(label='Case Number' required=false)
        public String caseNumber;
    }

    public class ActionOutput {
        @InvocableVariable(label='Result')
        public String result;

        @InvocableVariable(label='Success')
        public Boolean success;

        @InvocableVariable(label='Error Message')
        public String errorMessage;
    }

    @InvocableMethod(
        label='Call MCP Tool'
        description='Calls the Girikon MCP Server to execute tools on external systems like Jira, SAP, or compliance APIs via Model Context Protocol'
        category='MCP Integration'
    )
    public static List<ActionOutput> callMCPTool(List<ActionInput> inputs) {
        List<ActionOutput> outputs = new List<ActionOutput>();

        for (ActionInput inp : inputs) {
            ActionOutput out = new ActionOutput();
            try {
                // Build payload — merge case number if provided
                Map<String, Object> payloadMap = new Map<String, Object>();
                if (String.isNotBlank(inp.payloadJson)) {
                    payloadMap = (Map<String, Object>) JSON.deserializeUntyped(inp.payloadJson);
                }
                if (String.isNotBlank(inp.caseNumber)) {
                    payloadMap.put('caseNumber', inp.caseNumber);
                }

                // Build full request body
                Map<String, Object> body = new Map<String, Object>{
                    'tool'    => inp.toolName,
                    'payload' => payloadMap
                };

                // Call MCP server via Named Credential
                HttpRequest req = new HttpRequest();
                req.setEndpoint('callout:Girikon_MCP_Server/invoke');
                req.setMethod('POST');
                req.setHeader('Content-Type', 'application/json');
                req.setBody(JSON.serialize(body));
                req.setTimeout(30000);

                HttpResponse res = new Http().send(req);

                if (res.getStatusCode() == 200) {
                    out.result       = res.getBody();
                    out.success      = true;
                    out.errorMessage = null;
                } else {
                    out.result       = null;
                    out.success      = false;
                    out.errorMessage = 'MCP server error ' + res.getStatusCode() + ': ' + res.getBody();
                }

            } catch (Exception e) {
                out.result       = null;
                out.success      = false;
                out.errorMessage = 'Exception: ' + e.getMessage();
            }

            outputs.add(out);
        }

        return outputs;
    }
}