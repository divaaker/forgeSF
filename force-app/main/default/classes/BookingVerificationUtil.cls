public with sharing class BookingVerificationUtil {
    public static final String DEV_BYPASS_CODE = '246810';
    private static final Set<String> DEV_BYPASS_ORG_IDS = new Set<String>{
        '00Dg5000008cfQZEAY',  // headless-dev (old)
        '00DNS00000rNCTN2A4'   // agentforcemay2026
    };

    public static Boolean isDevBypassEnabled() {
        return DEV_BYPASS_ORG_IDS.contains(UserInfo.getOrganizationId());
    }

    public static String normalizeChannel(String channel) {
        if (String.isBlank(channel)) {
            return 'email';
        }
        String normalized = channel.trim().toLowerCase();
        if (normalized.contains('phone') || normalized.contains('sms') || normalized.contains('text')) {
            return 'phone';
        }
        return 'email';
    }

    public static String maskEmail(String email) {
        if (String.isBlank(email) || !email.contains('@')) {
            return 'unavailable';
        }
        List<String> parts = email.split('@');
        String local = parts[0];
        String domain = parts[1];
        String prefix = local.length() > 0 ? local.substring(0, 1) : '*';
        return prefix + '***@' + domain;
    }

    public static String maskPhone(String phone) {
        if (String.isBlank(phone)) {
            return 'unavailable';
        }
        String digits = '';
        for (Integer i = 0; i < phone.length(); i++) {
            String c = phone.substring(i, i + 1);
            if (c >= '0' && c <= '9') {
                digits += c;
            }
        }
        if (digits.length() <= 4) {
            return '***' + digits;
        }
        return '******' + digits.substring(digits.length() - 4);
    }

    public static String generateCode(String bookingReference, String channel, Long windowIndex) {
        String seed = bookingReference + '|' + channel + '|' + String.valueOf(windowIndex) + '|TravelDeskSecureV1';
        String hex = EncodingUtil.convertToHex(Crypto.generateDigest('SHA-256', Blob.valueOf(seed)));
        String digits = '';
        for (Integer i = 0; i < hex.length() && digits.length() < 6; i++) {
            String token = hex.substring(i, i + 1).toUpperCase();
            if (token >= '0' && token <= '9') {
                digits += token;
            } else {
                Integer mapped = Math.mod(token.charAt(0), 10);
                digits += String.valueOf(mapped);
            }
        }
        while (digits.length() < 6) {
            digits += '0';
        }
        return digits.substring(0, 6);
    }

    public static Long currentWindowIndex(Integer windowMinutes) {
        Long millis = Datetime.now().getTime();
        Long divisor = windowMinutes * 60L * 1000L;
        return millis / divisor;
    }
}