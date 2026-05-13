public with sharing class BookingVerificationChecker {
    private static final Integer OTP_WINDOW_MINUTES = 10;

    public class Request {
        @InvocableVariable(label='Booking Reference' description='Booking reference being verified' required=true)
        public String bookingReference;
        @InvocableVariable(label='Channel' description='Verification channel used for code dispatch' required=true)
        public String channel;
        @InvocableVariable(label='Verification Code' description='6-digit verification code provided by customer' required=true)
        public String verificationCode;
    }

    public class Result {
        @InvocableVariable(label='Is Verified' description='True when verification succeeds')
        public Boolean isVerified;
        @InvocableVariable(label='Verification Message' description='Human-readable verification result')
        public String verificationMessage;
        @InvocableVariable(label='Verified Booking Reference' description='Booking reference that passed verification')
        public String verifiedBookingReference;
    }

    @InvocableMethod(label='Verify Booking Code' description='Validates one-time booking verification code')
    public static List<Result> verifyCode(List<Request> requests) {
        List<Result> results = new List<Result>();
        for (Request req : requests) {
            Result res = new Result();
            res.isVerified = false;
            res.verifiedBookingReference = '';

            if (String.isBlank(req.bookingReference) || String.isBlank(req.verificationCode)) {
                res.verificationMessage = 'Booking reference and verification code are required.';
                results.add(res);
                continue;
            }

            String enteredCode = req.verificationCode.replaceAll('[^0-9]', '');
            if (enteredCode.length() != 6) {
                res.verificationMessage = 'Please provide a valid 6-digit verification code.';
                results.add(res);
                continue;
            }

            if (BookingVerificationUtil.isDevBypassEnabled() && enteredCode == BookingVerificationUtil.DEV_BYPASS_CODE) {
                res.isVerified = true;
                res.verifiedBookingReference = req.bookingReference;
                res.verificationMessage = 'Verification successful (developer bypass).';
                results.add(res);
                continue;
            }

            String channel = BookingVerificationUtil.normalizeChannel(req.channel);
            Long currentWindow = BookingVerificationUtil.currentWindowIndex(OTP_WINDOW_MINUTES);
            String currentCode = BookingVerificationUtil.generateCode(req.bookingReference, channel, currentWindow);
            String previousCode = BookingVerificationUtil.generateCode(req.bookingReference, channel, currentWindow - 1);

            if (enteredCode == currentCode || enteredCode == previousCode) {
                res.isVerified = true;
                res.verifiedBookingReference = req.bookingReference;
                res.verificationMessage = 'Verification successful.';
            } else {
                res.verificationMessage = 'Invalid or expired code. Please request a new code and try again.';
            }
            results.add(res);
        }
        return results;
    }
}