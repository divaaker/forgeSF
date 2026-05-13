public class VisaRequirementsService {
    public class Request {
        @InvocableVariable(label='Nationality' description='Customer nationality such as Indian or American' required=true)
        public String nationality;
        @InvocableVariable(label='Destination Country' description='Destination country name' required=true)
        public String destinationCountry;
        @InvocableVariable(label='Travel Purpose' description='Purpose of travel: Tourism, Business, or Transit')
        public String travelPurpose;
    }

    public class Result {
        @InvocableVariable(label='Visa Type' description='Visa category required')
        public String visaType;
        @InvocableVariable(label='Requirements' description='Document checklist')
        public String requirements;
        @InvocableVariable(label='Processing Time' description='Typical processing duration')
        public String processingTime;
        @InvocableVariable(label='Application URL' description='Embassy or consulate portal URL')
        public String applicationUrl;
        @InvocableVariable(label='Disclaimer' description='Legal disclaimer about accuracy of visa information')
        public String disclaimer;
    }

    static final String DISCLAIMER = 'DISCLAIMER: Visa requirements are subject to change. Always verify current requirements with the official embassy or consulate before applying. This is a general guide only.';

    @InvocableMethod(label='Get Visa Requirements' description='Returns visa type, required documents, and processing time for a destination')
    public static List<Result> getRequirements(List<Request> requests) {
        List<Result> results = new List<Result>();
        for (Request req : requests) {
            results.add(buildResult(
                req.nationality != null ? req.nationality.toLowerCase().trim() : '',
                req.destinationCountry != null ? req.destinationCountry.toLowerCase().trim() : '',
                req.travelPurpose != null ? req.travelPurpose.toLowerCase().trim() : 'tourism'
            ));
        }
        return results;
    }

    private static Result buildResult(String nat, String dest, String purpose) {
        Result r = new Result();
        r.disclaimer = DISCLAIMER;

        // USA passport holders
        if (nat.contains('american') || nat.contains('us') || nat.contains('united states')) {
            if (dest.contains('japan')) {
                r.visaType = 'Visa-Free Entry';
                r.requirements = '1. Valid US passport (6+ months validity). 2. Return or onward ticket. 3. Proof of sufficient funds. 4. Accommodation details.';
                r.processingTime = 'No visa required — entry granted on arrival for up to 90 days.';
                r.applicationUrl = 'https://www.us.emb-japan.go.jp';
            } else if (dest.contains('uk') || dest.contains('united kingdom') || dest.contains('britain')) {
                r.visaType = 'Electronic Travel Authorisation (ETA)';
                r.requirements = '1. Valid US passport. 2. ETA application (online, £10 fee). 3. Return ticket. 4. Proof of funds.';
                r.processingTime = 'ETA approval: usually within minutes, up to 3 days.';
                r.applicationUrl = 'https://www.gov.uk/guidance/apply-for-an-electronic-travel-authorisation-eta';
            } else if (dest.contains('canada')) {
                r.visaType = 'Electronic Travel Authorization (eTA)';
                r.requirements = '1. Valid US passport. 2. eTA application online (CAD $7). 3. Valid credit card for payment.';
                r.processingTime = 'Usually approved within minutes. Apply before travel.';
                r.applicationUrl = 'https://www.canada.ca/en/immigration-refugees-citizenship/services/visit-canada/eta.html';
            } else if (dest.contains('australia')) {
                r.visaType = 'Electronic Travel Authority (ETA) / eVisitor';
                r.requirements = '1. Valid US passport. 2. ETA application (AUD $20) or free eVisitor via IMMI account.';
                r.processingTime = 'Usually approved instantly online.';
                r.applicationUrl = 'https://immi.homeaffairs.gov.au/visas/getting-a-visa/visa-listing/electronic-travel-authority-601';
            } else if (dest.contains('india')) {
                r.visaType = 'e-Visa (e-Tourist Visa)';
                r.requirements = '1. Valid US passport. 2. Online e-Visa application. 3. Recent digital photo. 4. Passport scan. 5. Credit/debit card for USD 25 fee.';
                r.processingTime = '72 hours (3 business days). Apply at least 4 days before travel.';
                r.applicationUrl = 'https://indianvisaonline.gov.in/evisa/tvoa.html';
            } else if (dest.contains('brazil')) {
                r.visaType = 'Visa-Free Entry';
                r.requirements = '1. Valid US passport. 2. Return ticket. 3. Proof of accommodation.';
                r.processingTime = 'No visa required for tourism up to 90 days.';
                r.applicationUrl = 'https://br.usembassy.gov';
            } else if (dest.contains('china')) {
                r.visaType = '15-Day Visa-Free Transit / Tourist Visa (L)';
                r.requirements = '1. Valid US passport. 2. For short transit: onward ticket within 15 days. 3. For longer stays: Tourist Visa L — application form, photo, itinerary, hotel booking.';
                r.processingTime = 'Visa-free transit: immediate. Tourist visa: 4-7 business days.';
                r.applicationUrl = 'https://www.visaforchina.cn';
            } else {
                r = getSchengenOrGeneric(r, dest, 'American');
            }
        }
        // Indian passport holders
        else if (nat.contains('indian') || nat.contains('india')) {
            if (dest.contains('japan')) {
                r.visaType = 'Tourist Visa (Single or Multiple Entry)';
                r.requirements = '1. Valid Indian passport (6+ months validity). 2. Visa application form. 3. Recent passport photo. 4. Bank statements (last 3 months). 5. Return flight tickets. 6. Hotel reservations. 7. Leave letter from employer or business proof.';
                r.processingTime = '5 to 10 business days.';
                r.applicationUrl = 'https://www.in.emb-japan.go.jp/itprtop_en/index.html';
            } else if (dest.contains('usa') || dest.contains('united states') || dest.contains('america')) {
                r.visaType = 'B-1/B-2 Visitor Visa';
                r.requirements = '1. Valid Indian passport. 2. DS-160 online form. 3. Visa fee USD 185. 4. Photo (5x5 cm, white background). 5. Interview at US consulate. 6. Financial proof. 7. Ties to India (employment, family, property).';
                r.processingTime = '2 to 12 weeks depending on consulate and interview waittime.';
                r.applicationUrl = 'https://travel.state.gov/content/travel/en/us-visas/tourism-visit/visitor.html';
            } else if (dest.contains('uk') || dest.contains('united kingdom')) {
                r.visaType = 'Standard Visitor Visa';
                r.requirements = '1. Valid Indian passport. 2. Online application. 3. Biometrics at visa centre. 4. Bank statements (6 months). 5. Employer letter. 6. Hotel bookings. 7. Return tickets. 8. Fee: GBP 115.';
                r.processingTime = '15 business days (standard). Priority 5 days (GBP 250 extra).';
                r.applicationUrl = 'https://www.gov.uk/standard-visitor-visa';
            } else if (dest.contains('singapore')) {
                r.visaType = 'Visa-Free Entry (from 2024)';
                r.requirements = '1. Valid Indian passport. 2. Return ticket. 3. Proof of accommodation. 4. Sufficient funds (SGD 500+ per day).';
                r.processingTime = 'No visa required for tourism stays up to 30 days.';
                r.applicationUrl = 'https://www.ica.gov.sg';
            } else if (dest.contains('uae') || dest.contains('dubai') || dest.contains('abu dhabi')) {
                r.visaType = 'Visa on Arrival';
                r.requirements = '1. Valid Indian passport (6+ months). 2. Return ticket. 3. Hotel confirmation. 4. Sufficient funds. 5. AED 120 fee payable on arrival.';
                r.processingTime = 'Granted on arrival. Valid for 14 days, extendable once.';
                r.applicationUrl = 'https://www.gdrfad.gov.ae';
            } else if (dest.contains('australia')) {
                r.visaType = 'Tourist Visa (Subclass 600)';
                r.requirements = '1. Valid Indian passport. 2. Online application. 3. Bank statements. 4. Employment proof. 5. Travel itinerary. 6. Health insurance. 7. Fee: AUD 145.';
                r.processingTime = '20 to 30 business days.';
                r.applicationUrl = 'https://immi.homeaffairs.gov.au/visas/getting-a-visa/visa-listing/visitor-600';
            } else if (dest.contains('canada')) {
                r.visaType = 'Temporary Resident Visa (TRV)';
                r.requirements = '1. Valid Indian passport. 2. Online application. 3. Biometrics. 4. Financial proof. 5. Ties to India. 6. Travel history. 7. Fee: CAD 100.';
                r.processingTime = '2 to 4 weeks.';
                r.applicationUrl = 'https://www.canada.ca/en/immigration-refugees-citizenship/services/visit-canada/visitor-visa.html';
            } else {
                r = getSchengenOrGeneric(r, dest, 'Indian');
            }
        }
        // Australian passport holders
        else if (nat.contains('australian') || nat.contains('australia')) {
            if (dest.contains('japan')) {
                r.visaType = 'Visa-Free Entry';
                r.requirements = '1. Valid Australian passport. 2. Return ticket. 3. Proof of accommodation.';
                r.processingTime = 'No visa required — entry on arrival for up to 90 days.';
                r.applicationUrl = 'https://www.au.emb-japan.go.jp';
            } else if (dest.contains('usa') || dest.contains('united states')) {
                r.visaType = 'ESTA (Electronic System for Travel Authorization)';
                r.requirements = '1. Valid Australian passport (biometric). 2. ESTA application online (USD 21). 3. Valid credit card.';
                r.processingTime = 'Usually approved within 72 hours. Apply well in advance.';
                r.applicationUrl = 'https://esta.cbp.dhs.gov';
            } else if (dest.contains('india')) {
                r.visaType = 'e-Visa (e-Tourist Visa)';
                r.requirements = '1. Valid Australian passport. 2. Online e-Visa. 3. Digital photo. 4. Passport scan. 5. Fee USD 25.';
                r.processingTime = '72 hours.';
                r.applicationUrl = 'https://indianvisaonline.gov.in/evisa/tvoa.html';
            } else {
                r = getSchengenOrGeneric(r, dest, 'Australian');
            }
        }
        // UK passport holders
        else if (nat.contains('british') || nat.contains('uk ') || nat.startsWith('uk') || nat.contains('united kingdom')) {
            if (dest.contains('japan')) {
                r.visaType = 'Visa-Free Entry';
                r.requirements = '1. Valid UK passport. 2. Return ticket. 3. Proof of sufficient funds.';
                r.processingTime = 'No visa required — up to 90 days on arrival.';
                r.applicationUrl = 'https://www.uk.emb-japan.go.jp';
            } else if (dest.contains('usa') || dest.contains('united states')) {
                r.visaType = 'ESTA (Visa Waiver Program)';
                r.requirements = '1. UK biometric passport. 2. ESTA application (USD 21). 3. Valid email address.';
                r.processingTime = 'Approved within 72 hours usually.';
                r.applicationUrl = 'https://esta.cbp.dhs.gov';
            } else if (dest.contains('india')) {
                r.visaType = 'e-Visa (e-Tourist Visa)';
                r.requirements = '1. Valid UK passport. 2. Online e-Visa. 3. Digital photo and scan. 4. Fee USD 25.';
                r.processingTime = '72 hours.';
                r.applicationUrl = 'https://indianvisaonline.gov.in/evisa/tvoa.html';
            } else {
                r = getSchengenOrGeneric(r, dest, 'British');
            }
        }
        // Fallback
        else {
            r = getSchengenOrGeneric(r, dest, nat);
        }

        return r;
    }

    private static Result getSchengenOrGeneric(Result r, String dest, String natLabel) {
        Boolean isSchengen = dest.contains('france') || dest.contains('germany') || dest.contains('italy') ||
            dest.contains('spain') || dest.contains('netherlands') || dest.contains('greece') ||
            dest.contains('portugal') || dest.contains('austria') || dest.contains('switzerland') ||
            dest.contains('belgium') || dest.contains('sweden') || dest.contains('norway') ||
            dest.contains('denmark') || dest.contains('finland') || dest.contains('poland') ||
            dest.contains('czech') || dest.contains('europe');

        if (isSchengen) {
            r.visaType = 'Schengen Visa (Type C - Short Stay)';
            r.requirements = '1. Valid passport (6+ months validity beyond travel dates). 2. Completed Schengen visa application form. 3. Two recent passport photos (3.5x4.5 cm). 4. Travel insurance (EUR 30,000 minimum). 5. Proof of accommodation (hotel or host invitation). 6. Return flight booking. 7. Bank statements (last 3 months). 8. Proof of employment or enrolment. 9. Visa fee EUR 90 (adults).';
            r.processingTime = '15 calendar days (standard). Up to 45 days in complex cases. Apply at least 6 weeks before travel.';
            r.applicationUrl = 'https://www.schengenvisainfo.com';
        } else {
            r.visaType = 'Entry Requirements — Please Verify with Embassy';
            r.requirements = '1. Valid passport with 6+ months validity. 2. Completed visa application (check embassy website). 3. Passport-size photos. 4. Proof of accommodation. 5. Return flight ticket. 6. Sufficient funds proof. 7. Travel insurance recommended.';
            r.processingTime = 'Varies by destination. Check with the destination country embassy.';
            r.applicationUrl = 'https://www.iatatravelcentre.com';
        }
        return r;
    }
}