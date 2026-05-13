public class BookingCreator {
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

        return null;
    }

    public class Request {
        @InvocableVariable(label='Travel Option' description='The selected travel option from search results' required=true)
        public String travelOption;
        @InvocableVariable(label='Passenger Name' description='Full name of the primary passenger' required=true)
        public String passengerName;
        @InvocableVariable(label='Contact Email' description='Contact email for booking confirmation' required=true)
        public String contactEmail;
        @InvocableVariable(label='Contact Phone' description='Contact phone number')
        public String contactPhone;
        @InvocableVariable(label='Origin' description='Departure city or airport')
        public String origin;
        @InvocableVariable(label='Destination' description='Destination city or airport')
        public String destination;
        @InvocableVariable(label='Departure Date' description='Departure date in YYYY-MM-DD format')
        public String departureDate;
        @InvocableVariable(label='Return Date' description='Return date in YYYY-MM-DD format')
        public String returnDate;
        @InvocableVariable(label='Travel Class' description='Economy, Business, or First')
        public String travelClass;
        @InvocableVariable(label='Passenger Count' description='Number of passengers')
        public String passengerCount;
        @InvocableVariable(label='Total Amount' description='Total booking cost in USD')
        public String totalAmount;
    }

    public class Result {
        @InvocableVariable(label='Booking Reference' description='New booking reference number')
        public String bookingReference;
        @InvocableVariable(label='Confirmation Status' description='Booking status: Confirmed, Pending, or Failed')
        public String confirmationStatus;
        @InvocableVariable(label='Total Amount' description='Total cost of the booking')
        public String totalAmount;
        @InvocableVariable(label='Is Confirmed' description='True if booking was successfully confirmed')
        public Boolean isConfirmed;
        @InvocableVariable(label='Email Send Status' description='Whether the confirmation email was accepted by the mail service (check org deliverability if not received)')
        public String emailSendStatus;
    }

    @InvocableMethod(label='Create Booking' description='Creates a new confirmed travel booking record and sends a confirmation email')
    public static List<Result> create(List<Request> requests) {
        List<Result> results = new List<Result>();
        List<Travel_Booking__c> toInsert = new List<Travel_Booking__c>();
        for (Request req : requests) {
            Integer parsedPassengerCount = 1;
            if (String.isNotBlank(req.passengerCount)) {
                try {
                    parsedPassengerCount = Integer.valueOf(req.passengerCount.trim());
                } catch (Exception ex) {
                    parsedPassengerCount = 1;
                }
            }

            Decimal parsedTotalAmount = null;
            if (String.isNotBlank(req.totalAmount)) {
                String numericAmount = req.totalAmount.replace('$', '').replace(',', '').trim();
                if (String.isNotBlank(numericAmount)) {
                    try {
                        parsedTotalAmount = Decimal.valueOf(numericAmount);
                    } catch (Exception ex) {
                        parsedTotalAmount = null;
                    }
                }
            }

            String ref = 'TRV-' + String.valueOf(Math.abs(Crypto.getRandomInteger())).left(6);
            String resolvedDest = TravelDestinationResolver.resolveDestinationForStorage(req.destination, req.travelOption);
            if (String.isBlank(resolvedDest)) {
                resolvedDest = req.destination;
            }
            Travel_Booking__c booking = new Travel_Booking__c(
                Name = ref,
                PassengerName__c = req.passengerName,
                ContactEmail__c = req.contactEmail,
                ContactPhone__c = req.contactPhone,
                Origin__c = req.origin,
                Destination__c = resolvedDest,
                TravelOption__c = req.travelOption,
                TravelClass__c = String.isNotBlank(req.travelClass) ? req.travelClass : 'Economy',
                PassengerCount__c = parsedPassengerCount,
                TotalAmount__c = parsedTotalAmount,
                ConfirmationStatus__c = 'Confirmed'
            );
            Date parsedDepartureDate = parseFlexibleDate(req.departureDate);
            Date parsedReturnDate = parseFlexibleDate(req.returnDate);
            if (parsedDepartureDate != null) {
                booking.DepartureDate__c = parsedDepartureDate;
            }
            if (parsedReturnDate != null) {
                booking.ReturnDate__c = parsedReturnDate;
            }
            toInsert.add(booking);
        }
        insert toInsert;

        // Link or create Contact for each booking (ContactSanctionTrigger + handler must be safe)
        Set<String> emails = new Set<String>();
        for (Travel_Booking__c b : toInsert) {
            if (String.isNotBlank(b.ContactEmail__c)) {
                emails.add(b.ContactEmail__c.toLowerCase());
            }
        }
        Map<String, Id> emailToContactId = new Map<String, Id>();
        if (!emails.isEmpty()) {
            for (Contact c : [SELECT Id, Email FROM Contact WHERE Email IN :emails]) {
                if (String.isNotBlank(c.Email)) {
                    emailToContactId.put(c.Email.toLowerCase(), c.Id);
                }
            }
            List<Contact> newContacts = new List<Contact>();
            for (Travel_Booking__c b : toInsert) {
                if (String.isBlank(b.ContactEmail__c)) {
                    continue;
                }
                String key = b.ContactEmail__c.toLowerCase();
                if (!emailToContactId.containsKey(key)) {
                    String pName = String.isNotBlank(b.PassengerName__c) ? b.PassengerName__c.trim() : '';
                    Integer spIdx = pName.indexOf(' ');
                    String firstName = spIdx > 0 ? pName.substring(0, spIdx).trim() : '';
                    String lastName = spIdx > 0 ? pName.substring(spIdx + 1).trim() : pName;
                    if (String.isBlank(lastName)) {
                        lastName = 'Traveler';
                    }
                    newContacts.add(new Contact(
                        FirstName = firstName,
                        LastName = lastName,
                        Email = b.ContactEmail__c,
                        Phone = b.ContactPhone__c
                    ));
                }
            }
            if (!newContacts.isEmpty()) {
                insert newContacts;
                for (Contact c : newContacts) {
                    if (String.isNotBlank(c.Email)) {
                        emailToContactId.put(c.Email.toLowerCase(), c.Id);
                    }
                }
            }
            List<Travel_Booking__c> toUpdate = new List<Travel_Booking__c>();
            for (Travel_Booking__c b : toInsert) {
                if (String.isBlank(b.ContactEmail__c)) {
                    continue;
                }
                Id cId = emailToContactId.get(b.ContactEmail__c.toLowerCase());
                if (cId != null) {
                    toUpdate.add(new Travel_Booking__c(Id = b.Id, Contact__c = cId));
                }
            }
            if (!toUpdate.isEmpty()) {
                update toUpdate;
            }
        }

        Id orgWideEmailId = null;
        for (OrgWideEmailAddress owa : [
            SELECT Id
            FROM OrgWideEmailAddress
            WHERE IsVerified = true
            ORDER BY DisplayName ASC
            LIMIT 1
        ]) {
            orgWideEmailId = owa.Id;
            break;
        }

        List<Messaging.SingleEmailMessage> emails2 = new List<Messaging.SingleEmailMessage>();
        List<String> bookingRefPerEmail = new List<String>();
        for (Travel_Booking__c b : toInsert) {
            if (String.isBlank(b.ContactEmail__c)) {
                continue;
            }
            bookingRefPerEmail.add(b.Name);
            String depDate = b.DepartureDate__c != null ? b.DepartureDate__c.format() : 'TBD';
            String retDate = b.ReturnDate__c != null ? b.ReturnDate__c.format() : 'N/A';
            String amount = b.TotalAmount__c != null ? '$' + b.TotalAmount__c.setScale(2) : 'TBD';
            String phone = String.isNotBlank(b.ContactPhone__c) ? b.ContactPhone__c : 'N/A';
            String body =
                'Dear ' + b.PassengerName__c + ',\n\n' +
                'Your TravelDesk booking has been CONFIRMED! Here are your details:\n\n' +
                '  Booking Reference : ' + b.Name + '\n' +
                '  Travel Option     : ' + b.TravelOption__c + '\n' +
                '  From              : ' + (String.isNotBlank(b.Origin__c) ? b.Origin__c : 'N/A') + '\n' +
                '  To                : ' + (String.isNotBlank(b.Destination__c) ? b.Destination__c : 'N/A') + '\n' +
                '  Departure         : ' + depDate + '\n' +
                '  Return            : ' + retDate + '\n' +
                '  Travel Class      : ' + b.TravelClass__c + '\n' +
                '  Passengers        : ' + b.PassengerCount__c.intValue() + '\n' +
                '  Total Amount      : ' + amount + '\n' +
                '  Contact Phone     : ' + phone + '\n\n' +
                'Please keep your booking reference (' + b.Name + ') handy for all future correspondence.\n\n' +
                'Have a wonderful trip!\n\n' +
                'TravelDesk Team\n' +
                '--------------------------------------\n' +
                'This is an automated confirmation. Do not reply to this email.';

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new List<String>{ b.ContactEmail__c });
            mail.setSubject('Booking Confirmed: ' + b.Name + ' – ' + (String.isNotBlank(b.Destination__c) ? b.Destination__c : b.TravelOption__c));
            mail.setPlainTextBody(body);
            mail.setSaveAsActivity(false);
            mail.setUseSignature(false);
            if (orgWideEmailId != null) {
                mail.setOrgWideEmailAddressId(orgWideEmailId);
            }
            emails2.add(mail);
        }

        Map<String, String> refToEmailStatus = new Map<String, String>();
        if (!emails2.isEmpty()) {
            Messaging.SendEmailResult[] sendResults = Messaging.sendEmail(emails2, false);
            for (Integer ei = 0; ei < sendResults.size(); ei++) {
                Messaging.SendEmailResult sr = sendResults[ei];
                String refKey = ei < bookingRefPerEmail.size() ? bookingRefPerEmail[ei] : null;
                if (String.isBlank(refKey)) {
                    continue;
                }
                if (sr.isSuccess()) {
                    refToEmailStatus.put(refKey, 'Queued/Sent');
                } else {
                    List<String> errs = new List<String>();
                    for (Messaging.SendEmailError err : sr.getErrors()) {
                        errs.add(err.getMessage());
                    }
                    refToEmailStatus.put(refKey, 'Failed: ' + String.join(errs, '; '));
                }
            }
        }

        for (Integer i = 0; i < toInsert.size(); i++) {
            Result r = new Result();
            r.bookingReference = toInsert[i].Name;
            r.confirmationStatus = 'Confirmed';
            r.totalAmount = toInsert[i].TotalAmount__c != null ? '$' + toInsert[i].TotalAmount__c : 'N/A';
            r.isConfirmed = true;
            r.emailSendStatus = refToEmailStatus.get(toInsert[i].Name);
            if (String.isBlank(r.emailSendStatus)) {
                r.emailSendStatus = String.isNotBlank(toInsert[i].ContactEmail__c) ? 'Not sent (no email row)' : 'No email on booking';
            }
            results.add(r);
        }
        return results;
    }
}