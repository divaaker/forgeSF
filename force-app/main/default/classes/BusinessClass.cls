public class BusinessClass {
    public static Datetime addDays(Datetime baseDate, Integer daysToAdd, String jurisdiction) {
  String businessName = 'BusinessHour-' + jurisdiction;
  system.debug(businessName);
  List<BusinessHours> bHoursList = [SELECT Id FROM BusinessHours WHERE Name = :businessName];
  //   // If there's no business hours defined for the Jurisdiction, fallback to adding calendar days
  if (bHoursList.isEmpty()) {
 system.debug(
  'No BusinessHours defined for ' +
   jurisdiction +
    '. Adding calendar days instead.'
 );
  System.debug(baseDate.addDays(daysToAdd));
  return baseDate.addDays(daysToAdd);
 }
  BusinessHours bHours = bHoursList[0];
  //   //If baseDate is not within working days , take next working day
  baseDate = BusinessHours.nextStartDate(bHours.Id, baseDate);
  System.debug(baseDate);
  for (Integer elapsed = 0; elapsed < daysToAdd; elapsed++) {
  //     //Add 1 day
  baseDate = baseDate.addDays(1);

  //     //Check if new date is within working days
  if (!BusinessHours.isWithin(bHours.Id, baseDate)) {
  //       //If new date is not within working days, get new working day
   baseDate = BusinessHours.nextStartDate(bHours.Id, baseDate);
  }
  }
  system.debug(baseDate);
 return baseDate;
  }
}