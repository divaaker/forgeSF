public with sharing class StringHelper {

    public static String truncate(String value, Integer maxLen) {
        if (value == null) {
            return null;
        }
        if (maxLen == null || maxLen < 0) {
            throw new IllegalArgumentException('maxLen must be non-negative.');
        }
        return value.length() <= maxLen ? value : value.substring(0, maxLen);
    }

    public static String slugify(String value) {
        if (String.isBlank(value)) {
            return '';
        }
        String lowered = value.toLowerCase().trim();
        String stripped = lowered.replaceAll('[^a-z0-9]+', '-');
        return stripped.replaceAll('(^-+)|(-+$)', '');
    }

    public static String defaultIfBlank(String value, String fallback) {
        return String.isBlank(value) ? fallback : value;
    }

    public class IllegalArgumentException extends Exception {}
}