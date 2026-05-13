public class ItineraryFetcher {
    public class Request {
        @InvocableVariable(label='Booking Reference' description='The booking reference number' required=true)
        public String bookingReference;
    }

    public class Result {
        @InvocableVariable(label='Itinerary Summary' description='Human-readable itinerary overview')
        public String itinerarySummary;
        @InvocableVariable(label='Departure Date' description='Departure date')
        public String departureDate;
        @InvocableVariable(label='Return Date' description='Return date')
        public String returnDate;
        @InvocableVariable(label='Destinations' description='Comma-separated list of destinations')
        public String destinations;
        @InvocableVariable(label='Day By Day' description='Day-by-day itinerary breakdown')
        public String dayByDay;
        @InvocableVariable(label='Has Data' description='True if itinerary was found')
        public Boolean hasData;
    }

    @InvocableMethod(label='Fetch Itinerary' description='Retrieves travel itinerary details by booking reference including day-by-day breakdown')
    public static List<Result> fetch(List<Request> requests) {
        List<Result> results = new List<Result>();
        for (Request req : requests) {
            Result r = new Result();
            List<Travel_Booking__c> bookings = [
                SELECT Name, PassengerName__c, Origin__c, Destination__c,
                       DepartureDate__c, ReturnDate__c, TravelClass__c,
                       TravelOption__c, TotalAmount__c, ConfirmationStatus__c,
                       PassengerCount__c,
                       (SELECT Name, Day__c, Date__c, Location__c,
                               ActivityType__c, Description__c, Notes__c
                        FROM Itineraries__r
                        ORDER BY Day__c ASC)
                FROM Travel_Booking__c
                WHERE Name = :req.bookingReference
                LIMIT 1
            ];
            if (!bookings.isEmpty()) {
                Travel_Booking__c b = bookings[0];
                r.hasData = true;
                String destDisplay = TravelDestinationResolver.resolveDestinationForDisplay(
                    b.Destination__c,
                    b.TravelOption__c
                );
                r.destinations = destDisplay;
                String totalLine = b.TotalAmount__c != null
                    ? '$' + String.valueOf(b.TotalAmount__c.setScale(2))
                    : 'Not set';
                r.itinerarySummary = 'Booking ' + b.Name + ' for ' + b.PassengerName__c
                    + '. Route: ' + (String.isNotBlank(b.Origin__c) ? b.Origin__c : 'Not set') + ' to ' + destDisplay
                    + '. Departure Date: ' + (b.DepartureDate__c != null ? String.valueOf(b.DepartureDate__c) : 'Not set')
                    + '. Return Date: ' + (b.ReturnDate__c != null ? String.valueOf(b.ReturnDate__c) : 'Not set')
                    + '. Travel option: ' + (String.isNotBlank(b.TravelOption__c) ? b.TravelOption__c : 'Not set')
                    + '. Class: ' + b.TravelClass__c
                    + '. Passengers: ' + b.PassengerCount__c
                    + '. Total: ' + totalLine
                    + '. Status: ' + b.ConfirmationStatus__c + '.';
                if (!b.Itineraries__r.isEmpty()) {
                    List<String> lines = new List<String>();
                    for (Itinerary__c it : b.Itineraries__r) {
                        String dayNum = it.Day__c != null ? String.valueOf(it.Day__c.intValue()) : '?';
                        String line = '\u2022 **Day ' + dayNum + '**';
                        if (it.Date__c != null) {
                            String ds = String.valueOf(it.Date__c.year()) + '-'
                                + String.valueOf(it.Date__c.month()).leftPad(2, '0') + '-'
                                + String.valueOf(it.Date__c.day()).leftPad(2, '0');
                            line += ' (' + ds + ')';
                        }
                        if (String.isNotBlank(it.Location__c)) line += ' - **' + it.Location__c + '**';
                        if (String.isNotBlank(it.ActivityType__c)) line += ' [**' + it.ActivityType__c + '**]';
                        if (String.isNotBlank(it.Description__c)) line += ': ' + it.Description__c;
                        lines.add(line);
                    }
                    r.dayByDay = String.join(lines, '\n\n');
                } else {
                    r.dayByDay = 'No day-by-day breakdown available.';
                }
            } else {
                r.hasData = false;
                r.itinerarySummary = 'No booking found for reference ' + req.bookingReference + '.';
                r.destinations = '';
                r.departureDate = '';
                r.returnDate = '';
                r.dayByDay = '';
            }
            results.add(r);
        }
        return results;
    }
}