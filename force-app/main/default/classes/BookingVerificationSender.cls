public with sharing class BookingVerificationSender {
    private static final Integer OTP_WINDOW_MINUTES = 10;

    public class Request {
        @InvocableVariable(label='Booking Reference' description='Booking reference to verify' required=true)
        public String bookingReference;
        @InvocableVariable(label='Channel' description='Verification channel requested by customer: email or phone' required=true)
        public String channel;
    }

    public class Result {
        @InvocableVariable(label='Dispatch Status' description='Result of dispatch attempt')
        public String dispatchStatus;
        @InvocableVariable(label='Masked Target' description='Masked email or phone where code was sent')
        public String maskedTarget;
        @InvocableVariable(label='Expires In Minutes' description='Code validity duration in minutes')
        public String expiresInMinutes;
        @InvocableVariable(label='Normalized Channel' description='Effective verification channel used')
        public String normalizedChannel;
        @InvocableVariable(label='Is Dispatched' description='True if verification code dispatch succeeded')
        public Boolean isDispatched;
    }

    @InvocableMethod(label='Send Booking Verification Code' description='Sends a one-time verification code for booking security checks')
    public static List<Result> sendCode(List<Request> requests) {
        List<Result> results = new List<Result>();
        for (Request req : requests) {
            Result res = new Result();
            res.expiresInMinutes = String.valueOf(OTP_WINDOW_MINUTES);
            res.isDispatched = false;

            if (String.isBlank(req.bookingReference)) {
                res.dispatchStatus = 'Missing booking reference.';
                res.maskedTarget = 'unavailable';
                res.normalizedChannel = 'email';
                results.add(res);
                continue;
            }

            List<Travel_Booking__c> bookings = [
                SELECT Name, ContactEmail__c, ContactPhone__c
                FROM Travel_Booking__c
                WHERE Name = :req.bookingReference
                LIMIT 1
            ];

            if (bookings.isEmpty()) {
                res.dispatchStatus = 'Booking reference not found.';
                res.maskedTarget = 'unavailable';
                res.normalizedChannel = BookingVerificationUtil.normalizeChannel(req.channel);
                results.add(res);
                continue;
            }

            Travel_Booking__c booking = bookings[0];
            String channel = BookingVerificationUtil.normalizeChannel(req.channel);
            String code = BookingVerificationUtil.generateCode(
                booking.Name,
                channel,
                BookingVerificationUtil.currentWindowIndex(OTP_WINDOW_MINUTES)
            );

            if (BookingVerificationUtil.isDevBypassEnabled()) {
                res.dispatchStatus =
                    'Developer mode: email sending is bypassed in this org. Use verification code ' +
                    BookingVerificationUtil.DEV_BYPASS_CODE + ' to continue.';
                res.maskedTarget = 'dev-bypass';
                res.normalizedChannel = channel;
                res.isDispatched = true;
                results.add(res);
                continue;
            }

            if (channel == 'phone') {
                if (String.isNotBlank(booking.ContactEmail__c)) {
                    sendEmailCode(booking.ContactEmail__c, booking.Name, code);
                    res.dispatchStatus = 'Phone verification is not configured in this org. Sent verification code to email on file instead.';
                    res.maskedTarget = BookingVerificationUtil.maskEmail(booking.ContactEmail__c);
                    res.normalizedChannel = 'email';
                    res.isDispatched = true;
                } else {
                    res.dispatchStatus = 'Phone verification is not configured and no email is available for fallback.';
                    res.maskedTarget = BookingVerificationUtil.maskPhone(booking.ContactPhone__c);
                    res.normalizedChannel = 'phone';
                }
                results.add(res);
                continue;
            }

            if (String.isBlank(booking.ContactEmail__c)) {
                res.dispatchStatus = 'No email is available on this booking for verification.';
                res.maskedTarget = 'unavailable';
                res.normalizedChannel = 'email';
                results.add(res);
                continue;
            }

            sendEmailCode(booking.ContactEmail__c, booking.Name, code);
            res.dispatchStatus = 'Verification code sent successfully.';
            res.maskedTarget = BookingVerificationUtil.maskEmail(booking.ContactEmail__c);
            res.normalizedChannel = 'email';
            res.isDispatched = true;
            results.add(res);
        }
        return results;
    }

    private static void sendEmailCode(String toEmail, String bookingReference, String code) {
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setToAddresses(new List<String>{ toEmail });
        message.setSubject('TravelDesk Verification Code: ' + bookingReference);
        message.setPlainTextBody(
            'Your TravelDesk verification code is: ' + code + '\n\n' +
            'This code expires in ' + OTP_WINDOW_MINUTES + ' minutes.\n' +
            'If you did not request this code, please ignore this email.'
        );
        message.setSaveAsActivity(false);
        message.setUseSignature(false);
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ message }, false);
    }
}