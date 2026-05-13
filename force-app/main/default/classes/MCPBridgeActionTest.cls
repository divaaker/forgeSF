@isTest
private class MCPBridgeActionTest {

    @isTest
    static void testSuccessfulCall() {
        Test.setMock(HttpCalloutMock.class, new MCPMockSuccess());

        MCPBridgeAction.ActionInput inp = new MCPBridgeAction.ActionInput();
        inp.toolName    = 'smart_case_router';
        inp.payloadJson = '{}';
        inp.caseNumber  = '00001024';

        Test.startTest();
        List<MCPBridgeAction.ActionOutput> results =
            MCPBridgeAction.callMCPTool(
                new List<MCPBridgeAction.ActionInput>{ inp }
            );
        Test.stopTest();

        System.assertEquals(true,  results[0].success);
        System.assertNotEquals(null, results[0].result);
        System.assertEquals(null,  results[0].errorMessage);
    }

    @isTest
    static void testFailedCall() {
        Test.setMock(HttpCalloutMock.class, new MCPMockFailure());

        MCPBridgeAction.ActionInput inp = new MCPBridgeAction.ActionInput();
        inp.toolName    = 'org_health_check';
        inp.payloadJson = '{}';

        Test.startTest();
        List<MCPBridgeAction.ActionOutput> results =
            MCPBridgeAction.callMCPTool(
                new List<MCPBridgeAction.ActionInput>{ inp }
            );
        Test.stopTest();

        System.assertEquals(false, results[0].success);
        System.assertNotEquals(null, results[0].errorMessage);
    }

    private class MCPMockSuccess implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setStatusCode(200);
            res.setBody('{"status":"ok","result":"Case escalated successfully via MCP"}');
            return res;
        }
    }

    private class MCPMockFailure implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setStatusCode(500);
            res.setBody('{"error":"Internal server error"}');
            return res;
        }
    }
}