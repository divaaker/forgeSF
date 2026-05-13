public class CurrencyConverterClass 
{ 	
  public static Decimal convertCurrencyToINR(Decimal usd)
  {
      Decimal inr;
      HTTP h = new HTTP();
      //h is object of HTTP Class, what out this we cant call any API
      HTTPRequest req = new HTTPRequest();

      req.setEndpoint('https://free.currconv.com/api/v7/convert?q=USD_INR&apiKey=57865af342daf758fee3');
      req.setMethod('GET');
      fromJSON demo = new fromJSON();
      HTTPResponse res = h.send(req);
      system.debug(res.getBody());
      fromJSON results = (fromJSON) System.JSON.deserialize(string.valueof(res.getBody()), fromJSON.class); // Jsonstring is the above JSON
      system.debug(results);
      fromJSON.cls_results oCls = new fromJSON.cls_results();
      //oCls.USD_INR oUSDInr = new oCls.cls_USD_INR();
      fromJSON.cls_USD_INR oUSDInr;
      system.debug(oUSDInr);
      decimal conversionRate = oUSDInr.val;
      //system.debug(conversionRate);
      //inr = usd * conversionRate;
      system.debug(inr);
      return inr;
  }
}