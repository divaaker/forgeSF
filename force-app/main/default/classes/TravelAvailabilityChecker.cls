public class TravelAvailabilityChecker {
    public class Request {
        @InvocableVariable(label='Origin' description='Departure city or airport' required=true)
        public String origin;
        @InvocableVariable(label='Destination' description='Destination city or airport' required=true)
        public String destination;
        @InvocableVariable(label='Departure Date' description='Departure date in YYYY-MM-DD format' required=true)
        public String departureDate;
        @InvocableVariable(label='Return Date' description='Return date for round trips')
        public String returnDate;
        @InvocableVariable(label='Passenger Count' description='Number of passengers, defaults to 1')
        public String passengerCount;
    }

    public class Result {
        @InvocableVariable(label='Available Options' description='Formatted list of available travel options')
        public String availableOptions;
        @InvocableVariable(label='Price Range' description='Minimum to maximum price range')
        public String priceRange;
        @InvocableVariable(label='Has Results' description='True if options were found')
        public Boolean hasResults;
    }

    @InvocableMethod(label='Check Travel Availability' description='Searches for available flights and hotels between origin and destination')
    public static List<Result> check(List<Request> requests) {
        List<Result> results = new List<Result>();
        for (Request req : requests) {
            Result r = new Result();
            r.availableOptions = '1. Flight AA200 | Departs 08:00 | Arrives 14:30 | Economy | $450/person. 2. Flight UA305 | Departs 11:00 | Arrives 17:45 | Economy | $420/person. 3. Flight BA410 | Departs 15:00 | Arrives 21:20 | Business | $1,200/person.';
            r.priceRange = '$420 to $1,200 per person';
            r.hasResults = true;
            results.add(r);
        }
        return results;
    }
}