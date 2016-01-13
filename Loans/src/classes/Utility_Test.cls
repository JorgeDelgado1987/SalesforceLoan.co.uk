@isTest
private class Utility_Test {


   static testMethod void testgeneratePassword(){

   	Utility.generatePassword();
   }



	static testMethod void testgetSObjectNameFromKeyPrefix(){
		Account account = new Account();
        account.Name = 'First';
        insert account;

        string prefix = string.valueOf(account.id).left(3);

        Utility.getSObjectNameFromKeyPrefix(prefix);
	}


	static testMethod void testIsRunningInSandbox() {

		Utility.isRunningInSandbox();
	}

	static testMethod void testGetAllFieldsForObjectSOQL() {

		Utility.getAllFieldsForObjectSOQL('Application__c');
	}

    @isTest static void testGetDateAsDateTimeReturnsCorrectDatetime(){
        Date test_date = Date.newInstance(2011, 11, 11);
        Test.startTest();
            Datetime result = Utility.getDateAsDateTime(test_date);
        Test.stopTest();
        System.assertEquals(DateTime.newInstanceGMT(2011, 11, 11, 0, 0, 0), result, 'DateTime should be same date but with time of midnight');
    }

    @isTest static void testGetDateAsDateTimeReturnsNullforNullEntry(){
        Test.startTest();
            DateTime result = Utility.getDateAsDateTime(null);
        Test.stopTest();
        System.assertEquals(null, result, 'result should be null for null entry');
    }

    @isTest static void testGetEmploymentMonthsFromYearsAndMonthsStringsRetunrsCorrectMonths(){
        System.assertEquals(3, Utility.getTimeInMonthFromYearAndMonthStrings('0','3'), 'Should be 3 months');
        System.assertEquals(15, Utility.getTimeInMonthFromYearAndMonthStrings('1','3'), 'Should be 15 months');
        System.assertEquals(120, Utility.getTimeInMonthFromYearAndMonthStrings('10+','0'), 'Should be 120 months');
        System.assertEquals(65, Utility.getTimeInMonthFromYearAndMonthStrings('5','5'), 'Should be 65 months');
        System.assertEquals(119, Utility.getTimeInMonthFromYearAndMonthStrings('9','11'), 'Should be 119 months');
    }

    @isTest static void testsafeSplitSplitsData(){
        String original_string = 'bob,mary,jim,tim,frank,john';
        Test.startTest();
            List<String> result= Utility.safeSplit(original_string,',');
        Test.stopTest();
        System.assertEquals(6, result.size(), 'result should be size of 6');
    }

    @isTest static void testParseCSVReturnsCorrectRowsAndColumnsIncludingHeaders(){
        String csv = getSampleCSVIncludingEmptyLine();
        Test.startTest();
            List<List<String>> report_data = Utility.parseCSV(csv,false);
        Test.stopTest();
        System.assertEquals(8, report_data.size(), 'there should be 8 rows including headers');
        System.assertEquals(11, report_data.get(0).size(), 'each row should contain 11 columns');
    }


    private static String getSampleCSVIncludingEmptyLine(){
        return '"first_name","last_name","company_name","address","city","county","postal","phone1","phone2","email","web"\n"Aleshia","Tomkiewicz","Alan D Rosenburg Cpa Pc","14 Taylor St","St. Stephens Ward","Kent","CT2 7PP","01835-703597","01944-369967","atomkiewicz@hotmail.com","http://www.alandrosenburgcpapc.co.uk"\n"Evan","Zigomalas","Cap Gemini America","5 Binney St","Abbey Ward","Buckinghamshire","HP11 2AX","01937-864715","01714-737668","evan.zigomalas@gmail.com","http://www.capgeminiamerica.co.uk"\n"France","Andrade","Elliott, John W Esq","8 Moor Place","East Southbourne and Tuckton W","Bournemouth","BH6 3BE","01347-368222","01935-821636","france.andrade@hotmail.com","http://www.elliottjohnwesq.co.uk"\n"Ulysses","Mcwalters","Mcmahan, Ben L","505 Exeter Rd","Hawerby cum Beesby","Lincolnshire","DN36 5RP","01912-771311","01302-601380","ulysses@hotmail.com","http://www.mcmahanbenl.co.uk"\n"Tyisha","Veness","Champagne Room","5396 Forth Street","Greets Green and Lyng Ward","West Midlands","B70 9DT","01547-429341","01290-367248","tyisha.veness@hotmail.com","http://www.champagneroom.co.uk"\n"Eric","Rampy","Thompson, Michael C Esq","9472 Lind St","Desborough","Northamptonshire","NN14 2GH","01969-886290","01545-817375","erampy@rampy.co.uk","http://www.thompsonmichaelcesq.co.uk"\n"","","","","","","","","","",""\n';
    }
}