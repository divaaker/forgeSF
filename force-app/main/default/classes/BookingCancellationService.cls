public class BookingCancellationService {
    public class Request {
        @InvocableVariable(label='Booking Reference' description='The booking reference to cancel' required=true)
        public String bookingReference;
        @InvocableVariable(label='Cancellation Reason' description='Reason for cancellation')
        public String cancellationReason;
    }

    public class Result {
        @InvocableVariable(label='Cancellation Status' description='Result: Cancelled, Pending, or Non-Refundable')
        public String cancellationStatus;
        @InvocableVariable(label='Refund Amount' description='Refund amount if applicable')
        public String refundAmount;
        @InvocableVariable(label='Refund Timeline' description='Expected refund processing time')
        public String refundTimeline;
    }

    @InvocableMethod(label='Cancel Booking' description='Cancels a booking in Salesforce and returns refund details')
    public static List<Result> cancel(List<Request> requests) {
        List<Result> results = new List<Result>();
        for (Request req : requests) {
            Result r = new Result();
            List<Travel_Booking__c> bookings = [
                SELECT Id, Name, TotalAmount__c, ConfirmationStatus__c, DepartureDate__c
                FROM Travel_Booking__c
                WHERE Name = :req.bookingReference
                LIMIT 1
            ];
            if (!bookings.isEmpty()) {
                Travel_Booking__c b = bookings[0];
                if (b.ConfirmationStatus__c == 'Cancelled') {
                    r.cancellationStatus = 'Already Cancelled';
                    r.refundAmount = 'N/A';
                    r.refundTimeline = 'N/A';
                } else if (b.DepartureDate__c != null && b.DepartureDate__c <= Date.today().addDays(2)) {
                    // Within 48 hours of departure — non-refundable
                    b.ConfirmationStatus__c = 'Cancelled';
                    update b;
                    r.cancellationStatus = 'Non-Refundable';
                    r.refundAmount = '$0.00';
                    r.refundTimeline = 'No refund — cancelled within 48 hours of departure.';
                } else {
                    Decimal refund = b.TotalAmount__c != null ? b.TotalAmount__c * 0.9 : 0;
                    b.ConfirmationStatus__c = 'Cancelled';
                    b.RefundAmount__c = refund;
                    update b;
                    r.cancellationStatus = 'Cancelled';
                    r.refundAmount = '$' + refund.setScale(2);
                    r.refundTimeline = '5 to 7 business days';
                }
            } else {
                r.cancellationStatus = 'Not Found';
                r.refundAmount = 'N/A';
                r.refundTimeline = 'N/A';
            }
            results.add(r);
        }
        return results;
    }
}