@isTest
private class DecisionEngine_Utility_Test {

    @isTest static void test_mapReasons_shouldReturnEmptyMapForNull() {
        Test.startTest();
            Map<String,Set<String>> reasons_map = DecisionEngine_Utility.mapReasons(null);
        Test.stopTest();
        System.assertNotEquals(null, reasons_map);
        System.assertEquals(0, reasons_map.size());
    }

    @isTest static void test_mapReasons_shouldReturnMapWithKeyForRuleNameAndDetailInSet() {
        List<DecisionEngineIntegration.Reason> reasons = new List<DecisionEngineIntegration.Reason>();
        reasons.add(createReason('Rule1','Something'));
        Test.startTest();
            Map<String,Set<String>> reasons_map = DecisionEngine_Utility.mapReasons(reasons);
        Test.stopTest();
        System.assertEquals(1, reasons_map.size());
        System.assert(reasons_map.containsKey('Rule1'));
        System.assert(reasons_map.get('Rule1').contains('Something'));
    }

    @isTest static void test_mapReasons_shouldDeDuplicateCommonReasonsForSameRule() {
        List<DecisionEngineIntegration.Reason> reasons = new List<DecisionEngineIntegration.Reason>();
        reasons.add(createReason('Rule1','Something'));
        reasons.add(createReason('Rule1','Something'));
        Test.startTest();
            Map<String,Set<String>> reasons_map = DecisionEngine_Utility.mapReasons(reasons);
        Test.stopTest();
        System.assertEquals(1, reasons_map.size());
        System.assertEquals(1, reasons_map.values().size());
        System.assertEquals(1, reasons_map.get('Rule1').size());
    }

    @isTest static void test_mapReasons_shouldAddDifferentDetailsToSet() {
        List<DecisionEngineIntegration.Reason> reasons = new List<DecisionEngineIntegration.Reason>();
        reasons.add(createReason('Rule1','Something'));
        reasons.add(createReason('Rule1','Something else'));
        Test.startTest();
            Map<String,Set<String>> reasons_map = DecisionEngine_Utility.mapReasons(reasons);
        Test.stopTest();
        System.assertEquals(1, reasons_map.size());
        System.assertEquals(1, reasons_map.values().size());
        System.assertEquals(2, reasons_map.get('Rule1').size());
    }

    @isTest static void test_mapReasons_shouldCreateNewSetForCommonReasonsButDifferentRule() {
        List<DecisionEngineIntegration.Reason> reasons = new List<DecisionEngineIntegration.Reason>();
        reasons.add(createReason('Rule1','Something'));
        reasons.add(createReason('Rule2','Something'));
        Test.startTest();
            Map<String,Set<String>> reasons_map = DecisionEngine_Utility.mapReasons(reasons);
        Test.stopTest();
        System.assertEquals(2, reasons_map.size());
        System.assertEquals(2, reasons_map.values().size());
        System.assertEquals(1, reasons_map.get('Rule1').size());
        System.assertEquals(1, reasons_map.get('Rule2').size());
    }

    @isTest static void test_mergeReasonsMap_shouldAddNewUniqueRuelsToNewElement() {
        List<DecisionEngineIntegration.Reason> reasons = new List<DecisionEngineIntegration.Reason>();
        reasons.add(createReason('Rule1','Something'));
        Map<String,Set<String>> original_map = DecisionEngine_Utility.mapReasons(reasons);
        List<DecisionEngineIntegration.Reason> new_reasons = new List<DecisionEngineIntegration.Reason>();
        new_reasons.add(createReason('Rule2','Something'));
        Test.startTest();
            Map<String,Set<String>> reasons_map = DecisionEngine_Utility.mergeReasonsMap(new_reasons, original_map);
        Test.stopTest();
        System.assertEquals(2, reasons_map.size());
    }

    @isTest static void test_mergeReasonsMap_shouldMergeDetailsForSameRule() {
        List<DecisionEngineIntegration.Reason> reasons = new List<DecisionEngineIntegration.Reason>();
        reasons.add(createReason('Rule1','Something'));
        Map<String,Set<String>> original_map = DecisionEngine_Utility.mapReasons(reasons);
        List<DecisionEngineIntegration.Reason> new_reasons = new List<DecisionEngineIntegration.Reason>();
        new_reasons.add(createReason('Rule1','Something else'));
        Test.startTest();
            Map<String,Set<String>> reasons_map = DecisionEngine_Utility.mergeReasonsMap(new_reasons, original_map);
        Test.stopTest();
        System.assertEquals(1, reasons_map.size());
        System.assertEquals(2, reasons_map.get('Rule1').size());
    }

    @isTest static void test_formatReasonsToHtml_shouldGenerateEmptyStringForNullMap() {
        Test.startTest();
            String response = DecisionEngine_Utility.formatReasonsToHtml(null);
        Test.stopTest();
        System.assertEquals('', response);
    }

    @isTest static void test_formatReasonsToHtml_shouldGenerateValidListforMap() {
        List<DecisionEngineIntegration.Reason> reasons = new List<DecisionEngineIntegration.Reason>();
        reasons.add(createReason('Rule1','Something'));
        Map<String,Set<String>> reasons_map = DecisionEngine_Utility.mapReasons(reasons);
        Test.startTest();
            String response = DecisionEngine_Utility.formatReasonsToHtml(reasons_map);
        Test.stopTest();
        System.assertEquals('Rule: Rule1: <br/><ul><li>Something</li></ul>', response);
    }

    private static DecisionEngineIntegration.Reason createReason(String rule_name, String detail){
        DecisionEngineIntegration.Reason reason = new DecisionEngineIntegration.Reason();
        reason.RuleName = rule_name;
        reason.Detail = detail;
        return reason;
    }

}