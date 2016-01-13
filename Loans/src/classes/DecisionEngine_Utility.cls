public class DecisionEngine_Utility {
    private DecisionEngine_Utility() {}

    public static Map<String,Set<String>> mapReasons(List<DecisionEngineIntegration.Reason> reasons){
        return mergeReasonsMap(reasons, null);
    }

    public static Map<String,Set<String>> mergeReasonsMap(List<DecisionEngineIntegration.Reason> reasons, Map<String,Set<String>> existing_map){
        Map<String,Set<String>> all_reasons;
        if(existing_map == null){
            all_reasons = new Map<String,Set<String>>();
        } else {
            all_reasons = existing_map;
        }
        if(reasons != null){
            for(DecisionEngineIntegration.Reason reason:reasons){
                if(all_reasons.containsKey(reason.RuleName)){
                    if(!all_reasons.get(reason.RuleName).contains(reason.Detail)){
                        all_reasons.get(reason.RuleName).add(reason.Detail);
                    }
                } else {
                    all_reasons.put(reason.RuleName, new Set<String>{reason.Detail});
                }
            }
        }
        return all_reasons;
    }

    public static String formatReasonsToHtml(Map<String,Set<String>> existing_map){
        String html_string = '';
        if(existing_map != null){
            for(String rule_name:existing_map.keySet()){
                html_string += ('Rule: ' + rule_name + ': <br/>' + '<ul>');
                for(String reason:existing_map.get(rule_name)){
                    html_string += ('<li>' + reason + '</li>');
                }
                html_string += '</ul>';
            }
        }
        return html_string;
    }
}