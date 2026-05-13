/**
 * Maps travel-style labels (Cultural, Adventure, etc.) to real geography using TravelOption text,
 * and avoids showing style keywords as "destinations" in summaries.
 */
public with sharing class TravelDestinationResolver {
    private static final Set<String> STYLE_LABELS = new Set<String>{
        'cultural', 'adventure', 'relaxation', 'family'
    };

    public static Boolean isTravelStyleLabel(String value) {
        return String.isNotBlank(value) && STYLE_LABELS.contains(value.trim().toLowerCase());
    }

    /** Prefer a parsed place from travelOption; never persist a style keyword alone when a place can be derived. */
    public static String resolveDestinationForStorage(String destination, String travelOption) {
        String fromOption = extractPlaceFromTravelOption(travelOption);
        if (String.isNotBlank(fromOption)) {
            return fromOption;
        }
        if (isTravelStyleLabel(destination)) {
            return null;
        }
        return destination;
    }

    /** For itinerary UI: replace mistaken style-only destination with parsed place when possible. */
    public static String resolveDestinationForDisplay(String storedDestination, String travelOption) {
        String fromOption = extractPlaceFromTravelOption(travelOption);
        if (String.isNotBlank(fromOption)) {
            return fromOption;
        }
        if (isTravelStyleLabel(storedDestination)) {
            return 'Not specified (see travel option)';
        }
        return storedDestination;
    }

    private static String extractPlaceFromTravelOption(String travelOption) {
        if (String.isBlank(travelOption)) {
            return null;
        }
        String t = travelOption.trim();

        Matcher m = Pattern.compile(
            '(?i)^\\s*([A-Za-z][a-zA-Z]*(?:\\s+[A-Za-z][a-z]+)?)\\s+(Adventure|Relaxation|Family|Cultural)\\b'
        ).matcher(t);
        if (m.find()) {
            return m.group(1).trim();
        }

        m = Pattern.compile('(?i)\\b(?:in|to)\\s+([A-Za-z][a-zA-Z]+(?:\\s+[A-Za-z][a-z]+)?(?:\\s*,\\s*[A-Za-z][a-zA-Z]*)?)').matcher(t);
        if (m.find()) {
            return cleanPlaceFragment(m.group(1));
        }

        m = Pattern.compile('(?i)^\\s*([A-Za-z][a-zA-Z]+(?:\\s+[A-Za-z][a-z]+)?)\\s*:').matcher(t);
        if (m.find()) {
            return m.group(1).trim();
        }

        return null;
    }

    private static String cleanPlaceFragment(String raw) {
        if (String.isBlank(raw)) {
            return null;
        }
        String s = raw.trim();
        if (s.endsWith(',')) {
            s = s.substring(0, s.length() - 1).trim();
        }
        return s;
    }
}