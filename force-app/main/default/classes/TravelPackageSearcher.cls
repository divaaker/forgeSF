public class TravelPackageSearcher {
    public class Request {
        @InvocableVariable(label='Destination' description='Desired destination')
        public String destination;
        @InvocableVariable(label='Budget' description='Budget range such as $1000 to $2000')
        public String budget;
        @InvocableVariable(label='Travel Style' description='Travel style: Adventure, Relaxation, Cultural, or Family')
        public String travelStyle;
        @InvocableVariable(label='Duration' description='Trip duration such as 7 days')
        public String duration;
    }

    public class Result {
        @InvocableVariable(label='Package Options' description='Formatted list of available packages')
        public String packageOptions;
        @InvocableVariable(label='Featured Package' description='Top recommended package summary')
        public String featuredPackage;
        @InvocableVariable(label='Has Packages' description='True if packages were found')
        public Boolean hasPackages;
    }

    @InvocableMethod(label='Search Travel Packages' description='Searches Travel_Package__c records based on preferences')
    public static List<Result> search(List<Request> requests) {
        List<Result> results = new List<Result>();
        for (Request req : requests) {
            results.add(doSearch(req));
        }
        return results;
    }

    private static Result doSearch(Request req) {
        Result r = new Result();

        String dest = req.destination != null ? req.destination.trim() : '';
        String styleRaw = req.travelStyle != null ? req.travelStyle.trim().toLowerCase() : '';
        String budgetStr = req.budget != null ? req.budget : '';
        String dur = req.duration != null ? req.duration : '';

        // Normalize travel style to valid picklist values
        String style = normalizeStyle(styleRaw);

        // Parse max budget from string like "$5000", "under $3000", "$1000-$2000"
        Decimal maxBudget = parseMaxBudget(budgetStr);

        // Parse duration days
        Integer maxDays = parseDays(dur);

        // Build SOQL
        String soql = 'SELECT Name, Destination__c, Duration__c, PricePerPerson__c, '
            + 'TravelStyle__c, Description__c, IsFeatured__c, Rating__c, '
            + 'IncludesFlights__c, IncludesHotel__c FROM Travel_Package__c WHERE Id != null';

        if (String.isNotBlank(dest)) {
            soql += ' AND Destination__c LIKE \'%' + String.escapeSingleQuotes(dest) + '%\'';
        }
        if (String.isNotBlank(style)) {
            soql += ' AND TravelStyle__c = \'' + String.escapeSingleQuotes(style) + '\'';
        }
        if (maxBudget != null) {
            soql += ' AND PricePerPerson__c <= ' + maxBudget;
        }
        soql += ' ORDER BY IsFeatured__c DESC, Rating__c DESC LIMIT 10';

        List<Travel_Package__c> packages = Database.query(soql);

        // If no results and style was set, retry without style filter
        if (packages.isEmpty() && String.isNotBlank(style)) {
            String broadSoql = soql.replace(
                ' AND TravelStyle__c = \'' + style + '\'', ''
            );
            packages = Database.query(broadSoql);
        }

        // If still no results and destination was set, retry without destination (broadest fallback)
        // This handles region names like "Europe", "Asia" that won't match city-level Destination__c
        if (packages.isEmpty() && String.isNotBlank(dest)) {
            String noDestSoql = 'SELECT Name, Destination__c, Duration__c, PricePerPerson__c, '
                + 'TravelStyle__c, Description__c, IsFeatured__c, Rating__c, '
                + 'IncludesFlights__c, IncludesHotel__c FROM Travel_Package__c WHERE Id != null';
            if (String.isNotBlank(style)) {
                noDestSoql += ' AND TravelStyle__c = \'' + String.escapeSingleQuotes(style) + '\'';
            }
            if (maxBudget != null) {
                noDestSoql += ' AND PricePerPerson__c <= ' + maxBudget;
            }
            noDestSoql += ' ORDER BY IsFeatured__c DESC, Rating__c DESC LIMIT 10';
            packages = Database.query(noDestSoql);
        }

        if (!packages.isEmpty()) {
            r.hasPackages = true;
            List<String> lines = new List<String>();
            Travel_Package__c featured = null;
            Integer idx = 1;
            for (Travel_Package__c pkg : packages) {
                String includes = '';
                if (pkg.IncludesFlights__c) includes += 'Flights';
                if (pkg.IncludesHotel__c) includes += (includes != '' ? ' + ' : '') + 'Hotel';
                String line = idx + '. **' + pkg.Name + '** — ' + pkg.Destination__c
                    + ' | ' + pkg.Duration__c + ' days'
                    + ' | $' + pkg.PricePerPerson__c.setScale(0) + '/person'
                    + (String.isNotBlank(includes) ? ' | Includes: ' + includes : '')
                    + ' | Rating: ' + pkg.Rating__c + '/5';
                lines.add(line);
                if (featured == null || (pkg.IsFeatured__c && !featured.IsFeatured__c)) {
                    featured = pkg;
                }
                idx++;
            }
            r.packageOptions = String.join(lines, '\n');
            if (featured != null) {
                String inc = '';
                if (featured.IncludesFlights__c) inc += 'flights';
                if (featured.IncludesHotel__c) inc += (inc != '' ? ' and hotel' : 'hotel');
                r.featuredPackage = '⭐ ' + featured.Name + ': ' + featured.Duration__c
                    + ' days in ' + featured.Destination__c
                    + '. ' + (featured.Description__c != null ? featured.Description__c + ' ' : '')
                    + 'Rated ' + featured.Rating__c + '/5.'
                    + ' $' + featured.PricePerPerson__c.setScale(0) + '/person.'
                    + (String.isNotBlank(inc) ? ' Includes ' + inc + '.' : '');
            }
        } else {
            r.hasPackages = false;
            r.packageOptions = 'No packages found matching your criteria. Try broadening your destination, budget, or travel style.';
            r.featuredPackage = '';
        }
        return r;
    }

    // Maps loose style terms to picklist values
    private static String normalizeStyle(String raw) {
        if (String.isBlank(raw)) return '';
        if (raw.contains('adventure') || raw.contains('hiking') || raw.contains('sport')) return 'Adventure';
        if (raw.contains('relax') || raw.contains('luxury') || raw.contains('spa') || raw.contains('beach')) return 'Relaxation';
        if (raw.contains('cultur') || raw.contains('histor') || raw.contains('art') || raw.contains('museum')) return 'Cultural';
        if (raw.contains('family') || raw.contains('kid') || raw.contains('children')) return 'Family';
        return ''; // unknown style — don't filter
    }

    // Extracts max budget value from strings like "$5000", "under $3000", "$1k-$5k"
    private static Decimal parseMaxBudget(String budgetStr) {
        if (String.isBlank(budgetStr)) return null;
        // Find all numbers in the string
        List<Decimal> nums = new List<Decimal>();
        Pattern p = Pattern.compile('\\d[\\d,]*');
        Matcher m = p.matcher(budgetStr.replace('k', '000').replace('K', '000'));
        while (m.find()) {
            try {
                nums.add(Decimal.valueOf(m.group().replace(',', '')));
            } catch (Exception e) {}
        }
        if (nums.isEmpty()) return null;
        // Return the largest number found (treat as upper bound)
        Decimal max = nums[0];
        for (Decimal n : nums) if (n > max) max = n;
        return max;
    }

    // Extracts number of days from strings like "10 days", "2 weeks"
    private static Integer parseDays(String durStr) {
        if (String.isBlank(durStr)) return null;
        Pattern p = Pattern.compile('(\\d+)\\s*(day|week|night)');
        Matcher m = p.matcher(durStr.toLowerCase());
        if (m.find()) {
            Integer num = Integer.valueOf(m.group(1));
            String unit = m.group(2);
            return unit.startsWith('week') ? num * 7 : num;
        }
        return null;
    }
}