public without sharing class Utility {
// copied from Moneywise Org
// 09/10/2014 - Simon Parker

   /**
     * Generates a random 8 character password.
     * @return  A random 8 character password
     */
    public static String generatePassword(){
        Blob blobKey = crypto.generateAesKey(128);
        String key = EncodingUtil.convertToHex(blobKey);

        return key.substring(0,8);
    }

    //adds a standard info message to a visualforce page
    public static void addInfoMessage(String message_text){
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, message_text));
    }

    //adds a standard error message to a visualforce page
    public static void addErrorMessage(String message_text){
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, message_text));
    }

    //adds a standard confirm message to a visualforce page
    public static void addConfirmMessage(String message_text){
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM, message_text));
    }

    //Checks to see if the code is currently running from a sandbox
    public static Boolean isRunningInSandbox() {
        String s  =  System.URL.getSalesforceBaseUrl().getHost();
        return (Pattern.matches('(.*\\.)?cs[0-9]*(-api)?\\..*force.com',s));
    }


    public static String getSObjectNameFromKeyPrefix(String sObjectKeyPrefix) {
        //  map to hold global describe data
        //  private static Map<String,Schema.SObjectType> globalDescribeMap;

        //  map to store objects and their prefixes
        //  private static Map<String, String> keyPrefixMap;

        //  to hold set of all sObject prefixes
        //  private static Set<String> keyPrefixSet;

        // get all objects from the org
        Map<String,Schema.SObjectType> globalDescribeMap = Schema.getGlobalDescribe();

        // to store objects and their prefixes
        Map<String, String> keyPrefixMap = new Map<String, String>{};

        //get the object prefix in IDs
        Set<String> keyPrefixSet = globalDescribeMap.keySet();

        // fill up the prefixes map
        for (String sObj : keyPrefixSet) {
            Schema.DescribeSObjectResult r =  globalDescribeMap.get(sObj).getDescribe();
            String tempName = r.getName();
            String tempPrefix = r.getKeyPrefix();
            keyPrefixMap.put(tempPrefix, tempName);
        }

        String tPrefix = sObjectKeyPrefix;
        tPrefix = tPrefix.subString(0,3);

        //get the object type now
        String objectType = keyPrefixMap.get(tPrefix);
        return objectType;
    }


// **************************************************************************************************************************************************
// ******** Get All The Fields That Exist On An Object Into A Single String That Can Be Used On a SOQL Statement So All Fields Are Included *********
// **************************************************************************************************************************************************
// JJ added 16/12/2013
    public static string getAllFieldsForObjectSOQL(string ObjectName)
    {
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Map <String, Schema.SObjectField> fieldMap = gd.get(ObjectName).getDescribe().fields.getMap();
        string Returnstring;
        for(Schema.SObjectField sfield : fieldMap.Values())
        {
           schema.describefieldresult dfield = sfield.getDescribe();
           if (returnstring == null)
           {
                returnstring = dfield.getname().toLowerCase();
           }
           else
           {
                returnstring = returnstring + ',' + dfield.getname().toLowerCase();
           }
        }
        return returnstring;
    }

    public static DateTime getDateAsDateTime(Date input_date){
        if(input_date != null){
            return  DateTime.newInstanceGMT(input_date.year(), input_date.month(),input_date.day());
        }
        return null;

    }

    public static Integer getTimeInMonthFromYearAndMonthStrings(String years, String months){
        Integer timeinmonths = 0;
        Integer timeinyears = 0;
        if(months != null && months.isNumeric()){
            timeinmonths = Integer.valueOf(months);
        }
        if(years != null){
            if(years.isNumeric()){
                timeinyears = Integer.valueOf(years);
            } else {
                if(years.replace('+','').isNumeric()){
                    timeinyears = Integer.valueOf(years.replace('+',''));
                }
            }
        }
        return (timeinmonths + (timeinyears * 12));
    }

    //safe split avoids regex erros on really large files
    public static List<String> safeSplit(String inStr, String delim){
        Integer regexFindLimit = 100;
        Integer regexFindCount = 0;

        List<String> output = new List<String>();

        Matcher m = Pattern.compile(delim).matcher(inStr);

        Integer lastEnd = 0;

        while(!m.hitEnd())
        {
            while(regexFindCount < regexFindLimit && !m.hitEnd())
            {
                if(m.find())
                {
                    output.add(inStr.substring(lastEnd, m.start()));
                    lastEnd = m.end();
                }
                else
                {
                    output.add(inStr.substring(lastEnd));
                    lastEnd = inStr.length();
                }

                regexFindCount++;
            }

            m.reset(inStr);
            m.region(lastEnd, m.regionEnd());

            regexFindCount = 0;
        }

        return output;
    }

    //Parces a CSV and returns the data as a list of rows each containing a list of columns
    public static List<List<String>> parseCSV(String contents,Boolean skipHeaders) {
        List<List<String>> allFields = new List<List<String>>();

        // replace instances where a double quote begins a field containing a comma
        // in this case you get a double quote followed by a doubled double quote
        // do this for beginning and end of a field
        contents = contents.replaceAll(',"""',',"DBLQT').replaceall('""",','DBLQT",');
        // now replace all remaining double quotes - we do this so that we can reconstruct
        // fields with commas inside assuming they begin and end with a double quote
        contents = contents.replaceAll('""','DBLQT');
        // we are not attempting to handle fields with a newline inside of them
        // so, split on newline to get the spreadsheet rows
        List<String> lines = new List<String>();
        try {
            lines = Utility.safeSplit(contents,'\n');
        } catch (System.ListException e) {
            System.debug('Limits exceeded?' + e.getMessage());
        }
        Integer num = 0;
        for(String line: lines) {
            // check for blank CSV lines (only commas)
            if (line.replaceAll(',','').trim().length() == 0) break;

            List<String> fields = Utility.safeSplit(line,',');
            List<String> cleanFields = new List<String>();
            String compositeField;
            Boolean makeCompositeField = false;
            for(String field : fields) {
                if (field.startsWith('"') && field.endsWith('"')) {
                    cleanFields.add(field.replaceAll('DBLQT','"'));
                } else if (field.startsWith('"')) {
                    makeCompositeField = true;
                    compositeField = field;
                } else if (field.endsWith('"')) {
                    compositeField += ',' + field;
                    cleanFields.add(compositeField.replaceAll('DBLQT','"'));
                    makeCompositeField = false;
                } else if (makeCompositeField) {
                    compositeField +=  ',' + field;
                } else {
                    cleanFields.add(field.replaceAll('DBLQT','"'));
                }
            }

            allFields.add(cleanFields);
        }
        if (skipHeaders) allFields.remove(0);
        return allFields;
    }

 


}