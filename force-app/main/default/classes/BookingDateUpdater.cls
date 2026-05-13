public with sharing class BookingDateUpdater {
    public class Request {
        @InvocableVariable(label='Booking Reference' description='Booking reference to update' required=true)
        public String bookingReference;
        @InvocableVariable(label='Departure Date' description='New departure date')
        public String departureDate;
        @InvocableVariable(label='Return Date' description='New return date')
        public String returnDate;
    }

    public class Result {
        @InvocableVariable(label='Update Status' description='Result of booking date update')
        public String updateStatus;
        @InvocableVariable(label='Normalized Departure Date' description='Stored departure date')
        public String normalizedDepartureDate;
        @InvocableVariable(label='Normalized Return Date' description='Stored return date')
        public String normalizedReturnDate;
        @InvocableVariable(label='Updated' description='True if booking dates were updated')
        public Boolean updated;
    }

    @InvocableMethod(label='Update Booking Dates' description='Updates departure and return dates for an existing booking')
    public static List<Result> updateDates(List<Request> requests) {
        List<Result> results = new List<Result>();
        for (Request req : requests) {
            Result res = new Result();
            res.updated = false;
            res.normalizedDepartureDate = '';
            res.normalizedReturnDate = '';

            if (String.isBlank(req.bookingReference)) {
                res.updateStatus = 'Booking reference is required.';
                results.add(res);
                continue;
            }

            List<Travel_Booking__c> matches = [
                SELECT Id, Name, DepartureDate__c, ReturnDate__c
                FROM Travel_Booking__c
                WHERE Name = :req.bookingReference
                LIMIT 1
            ];
            if (matches.isEmpty()) {
                res.updateStatus = 'Booking not found for reference ' + req.bookingReference + '.';
                results.add(res);
                continue;
            }

            Travel_Booking__c booking = matches[0];
            Date parsedDeparture = parseFlexibleDate(req.departureDate);
            Date parsedReturn = parseFlexibleDate(req.returnDate);

            if (parsedDeparture == null && parsedReturn == null) {
                res.updateStatus = 'No valid dates detected. Please provide dates in YYYY-MM-DD format.';
                results.add(res);
                continue;
            }

            if (parsedDeparture != null) {
                booking.DepartureDate__c = parsedDeparture;
            }
            if (parsedReturn != null) {
                booking.ReturnDate__c = parsedReturn;
            }
            update booking;

            res.updated = true;
            res.normalizedDepartureDate = booking.DepartureDate__c != null ? String.valueOf(booking.DepartureDate__c) : '';
            res.normalizedReturnDate = booking.ReturnDate__c != null ? String.valueOf(booking.ReturnDate__c) : '';
            res.updateStatus = 'Booking dates updated successfully.';
            results.add(res);
        }
        return results;
    }

    private static Date parseFlexibleDate(String rawDate) {
        if (String.isBlank(rawDate)) {
            return null;
        }
        String normalized = rawDate.trim();

        if (Pattern.matches('\\d{4}-\\d{2}-\\d{2}', normalized)) {
            return Date.valueOf(normalized);
        }

        if (Pattern.matches('\\d{2}/\\d{2}/\\d{4}', normalized)) {
            List<String> parts = normalized.split('/');
            return Date.newInstance(
                Integer.valueOf(parts[2]),
                Integer.valueOf(parts[1]),
                Integer.valueOf(parts[0])
            );
        }

        if (Pattern.matches('\\d{1,2}-\\d{1,2}-\\d{4}', normalized)) {
            List<String> parts = normalized.split('-');
            return Date.newInstance(
                Integer.valueOf(parts[2]),
                Integer.valueOf(parts[0]),
                Integer.valueOf(parts[1])
            );
        }

        // Try to parse relaxed month-name formats (e.g., "June 1 2026")
        try {
            String cleaned = normalized.replace(',', '');
            List<String> tokens = cleaned.split('\\s+');
            if (tokens.size() >= 2) {
                Map<String, Integer> monthMap = new Map<String, Integer>{
                    'january' => 1, 'february' => 2, 'march' => 3, 'april' => 4,
                    'may' => 5, 'june' => 6, 'july' => 7, 'august' => 8,
                    'september' => 9, 'october' => 10, 'november' => 11, 'december' => 12
                };
                Integer month = monthMap.get(tokens[0].toLowerCase());
                if (month != null) {
                    String dayToken = tokens[1].replaceAll('[^0-9]', '');
                    if (String.isBlank(dayToken)) {
                        return null;
                    }
                    Integer day = Integer.valueOf(dayToken);
                    Integer year = Date.today().year();
                    if (tokens.size() >= 3) {
                        String yearToken = tokens[2].replaceAll('[^0-9]', '');
                        if (!String.isBlank(yearToken)) {
                            year = Integer.valueOf(yearToken);
                        }
                    }
                    return Date.newInstance(year, month, day);
                }
            }
        } catch (Exception ex) {
            return null;
        }

        return null;
    }
}