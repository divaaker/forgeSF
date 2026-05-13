trigger PreventMobile on Contact(Before insert)
{
  set<String> lstMobileno = new set<String>();
  for(Contact con: Trigger.new)
  {
      if(con.Phone!=null)
         lstMobileno.add(con.Phone);

 }

 //Query all existing records
 Map<String,Contact > mapMobileNo = new Map<String,Contact >();
 for(Contact c: [select id,Phone,Name from Contact where Phone in : lstMobileno])
 { 
  if(!mapMobileNo.containskey(c.Phone))
      mapMobileNo.put(c.Phone,c);
 }

//loop through the trigger.new
for(Contact con: Trigger.new)
 {
    if(con.Phone!=null && mapMobileNo.containskey(con.Phone))
    {
      con.addError('This Mobile no. is already used in ' + mapMobileNo.get(con.Phone).Name);
    }
 }
}