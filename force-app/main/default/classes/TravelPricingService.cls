public class TravelPricingService {
    public class Request {
        @InvocableVariable(label='Destination' description='Destination city or country' required=true)
        public String destination;
        @InvocableVariable(label='Travel Dates' description='Travel date range' required=true)
        public String travelDates;
        @InvocableVariable(label='Travel Class' description='Travel class: Economy, Business, or First')
        public String travelClass;
    }

    public class Result {
        @InvocableVariable(label='Base Price' description='Base fare before taxes')
        public String basePrice;
        @InvocableVariable(label='Taxes' description='Taxes and fees')
        public String taxes;
        @InvocableVariable(label='Total Price' description='All-inclusive total price')
        public String totalPrice;
        @InvocableVariable(label='Discounts Applied' description='Discounts or promo codes applied')
        public String discountsApplied;
    }

    @InvocableMethod(label='Get Travel Pricing' description='Retrieves pricing breakdown for a destination and travel dates')
    public static List<Result> getPrice(List<Request> requests) {
        List<Result> results = new List<Result>();
        for (Request req : requests) {
            results.add(buildPrice(
                req.destination != null ? req.destination.toLowerCase() : '',
                req.travelDates != null ? req.travelDates.toLowerCase() : '',
                req.travelClass != null ? req.travelClass.toLowerCase() : 'economy'
            ));
        }
        return results;
    }

    private static Result buildPrice(String dest, String dates, String cls) {
        // Base economy prices by destination region
        Decimal base = getBasePrice(dest);

        // Class multipliers
        Decimal multiplier = 1.0;
        String classLabel = 'Economy';
        if (cls.contains('business')) {
            multiplier = 3.8;
            classLabel = 'Business';
        } else if (cls.contains('first')) {
            multiplier = 7.5;
            classLabel = 'First';
        }

        // Peak season adjustment (June–August, December) — matches both month names and ISO month numbers
        Boolean isPeak = dates.contains('jun') || dates.contains('jul') || dates.contains('aug') ||
            dates.contains('dec') || dates.contains('christmas') || dates.contains('summer') ||
            dates.contains('-06') || dates.contains('-07') || dates.contains('-08') || dates.contains('-12') ||
            dates.contains('/06') || dates.contains('/07') || dates.contains('/08') || dates.contains('/12');
        if (isPeak) multiplier *= 1.25;

        Decimal baseAmt = (base * multiplier).setScale(2);
        Decimal taxAmt = (baseAmt * 0.18).setScale(2);
        Decimal total = (baseAmt + taxAmt).setScale(2);

        // Discount logic
        String discount = 'None';
        if (!isPeak && multiplier >= 3.8) discount = '5% off-peak business discount applied';
        if (cls.contains('first') && !isPeak) discount = '8% off-peak first class discount applied';

        Result r = new Result();
        r.basePrice = classLabel + ' base fare: $' + baseAmt;
        r.taxes = 'Taxes & fees (18%): $' + taxAmt;
        r.totalPrice = 'Total per person: $' + total + (isPeak ? ' (peak season pricing)' : '');
        r.discountsApplied = discount;
        return r;
    }

    private static Decimal getBasePrice(String dest) {
        if (dest.contains('tokyo') || dest.contains('japan') || dest.contains('osaka')) return 850;
        if (dest.contains('sydney') || dest.contains('australia') || dest.contains('melbourne')) return 920;
        if (dest.contains('london') || dest.contains('uk') || dest.contains('britain')) return 480;
        if (dest.contains('paris') || dest.contains('france')) return 420;
        if (dest.contains('rome') || dest.contains('italy') || dest.contains('milan')) return 390;
        if (dest.contains('barcelona') || dest.contains('spain') || dest.contains('madrid')) return 370;
        if (dest.contains('dubai') || dest.contains('uae')) return 580;
        if (dest.contains('singapore')) return 760;
        if (dest.contains('bali') || dest.contains('indonesia')) return 680;
        if (dest.contains('india') || dest.contains('mumbai') || dest.contains('delhi')) return 620;
        if (dest.contains('new york') || dest.contains('usa') || dest.contains('los angeles')) return 280;
        if (dest.contains('toronto') || dest.contains('canada') || dest.contains('vancouver')) return 310;
        if (dest.contains('brazil') || dest.contains('rio') || dest.contains('sao paulo')) return 520;
        if (dest.contains('bangkok') || dest.contains('thailand')) return 640;
        if (dest.contains('amsterdam') || dest.contains('netherlands')) return 440;
        if (dest.contains('cape town') || dest.contains('south africa')) return 710;
        return 500; // default
    }
}