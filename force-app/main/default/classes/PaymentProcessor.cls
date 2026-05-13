public class PaymentProcessor {
    public class Request {
        @InvocableVariable(label='Booking Reference' description='The booking reference number' required=true)
        public String bookingReference;
        @InvocableVariable(label='Payment Method' description='Payment method: Card, Bank, or Wallet' required=true)
        public String paymentMethod;
        @InvocableVariable(label='Card Last Four' description='Last 4 digits of card if applicable')
        public String cardLastFour;
    }

    public class Result {
        @InvocableVariable(label='Payment Status' description='Payment result: Success, Failed, or Pending')
        public String paymentStatus;
        @InvocableVariable(label='Transaction ID' description='Payment transaction reference')
        public String transactionId;
        @InvocableVariable(label='Receipt URL' description='Link to the payment receipt')
        public String receiptUrl;
    }

    @InvocableMethod(label='Process Payment' description='Processes payment for a confirmed booking')
    public static List<Result> process(List<Request> requests) {
        List<Result> results = new List<Result>();
        for (Request req : requests) {
            Result r = new Result();
            r.paymentStatus = 'Success';
            r.transactionId = 'TXN-' + String.valueOf(Math.abs(Crypto.getRandomInteger())).left(8);
            r.receiptUrl = 'https://traveldesk.example.com/receipts/' + req.bookingReference;
            results.add(r);
        }
        return results;
    }
}