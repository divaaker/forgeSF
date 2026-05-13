public class SpecialRequestHandler {
    public class Request {
        @InvocableVariable(label='Booking Reference' description='The booking reference number' required=true)
        public String bookingReference;
        @InvocableVariable(label='Request Type' description='Type of request: Meal, Accessibility, Seat, or Other' required=true)
        public String requestType;
        @InvocableVariable(label='Request Details' description='Detailed description of the special request' required=true)
        public String requestDetails;
    }

    public class Result {
        @InvocableVariable(label='Request Status' description='Result: Submitted, Confirmed, or Under Review')
        public String requestStatus;
        @InvocableVariable(label='Confirmation Number' description='Special request confirmation ID')
        public String confirmationNumber;
        @InvocableVariable(label='Estimated Fulfillment' description='When the request will be actioned')
        public String estimatedFulfillment;
    }

    @InvocableMethod(label='Submit Special Request' description='Submits a special travel accommodation request')
    public static List<Result> submit(List<Request> requests) {
        List<Result> results = new List<Result>();
        for (Request req : requests) {
            Result r = new Result();
            r.requestStatus = 'Confirmed';
            r.confirmationNumber = 'SR-' + String.valueOf(Math.abs(Crypto.getRandomInteger())).left(6);
            r.estimatedFulfillment = '48 hours before departure';
            results.add(r);
        }
        return results;
    }
}