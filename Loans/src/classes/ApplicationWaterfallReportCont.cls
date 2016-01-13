public class ApplicationWaterfallReportCont {

    public Application__c DateHolderApp {get; private set;}
    public String SelectedSortField {get; set;}
    public String SelectedFilterField {get; set;}
    public List<String> SelectedFilterOptions {get; set;}
    public String SelectedDateField {get; set;}
    public String SelectedRowsIdsToIgnore {get; set;}
    public Map<String, Map<Id, StageInfo>> SortedByStageMap {get; private set;}
    private Map<String, Set<String>> FilterOptionsMap;
    private Map<String, String> SortedObjectsIdName;
    private Map<String, String> AccountNameId;
    private Map<String, String> LenderNameId;
    private Map<String, String> UserNameId;
    private Set<String> IgnoredRowsIds;
    private String BorderWidth = '2px';
    private String LeftB = 'border-left:black ' + BorderWidth + ' solid;';
    private String RightB = 'border-right:black ' + BorderWidth + ' solid;';
    private String TopB = 'border-top:black ' + BorderWidth + ' solid;';
    private String BottomB = 'border-bottom:black ' + BorderWidth + ' solid;';

    public ApplicationWaterfallReportCont(){
        IgnoredRowsIds = new Set<String>();
        DateHolderApp = new Application__c();
        DateHolderApp.Completed_Date__c = Date.today();

        DateHolderApp.Cancelled_Date__c = DateHolderApp.Completed_Date__c.addDays(-30);
        //DateHolderApp.Cancelled_Date__c = DateHolderApp.Completed_Date__c.addDays(-3000);

        SelectedSortField = 'Account__c';
        SelectedFilterField = 'Account__c';
        SelectedDateField = 'Application';
        loadApplications();
    }

    public List<SelectOption> getGroupByOptions(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Account__c', 'Account'));
        options.add(new SelectOption('Lender__c', 'Lender'));
        options.add(new SelectOption('Case_Manager__c', 'Case Manager'));
        options.add(new SelectOption('Case_Owner__c', 'Case Owner'));
        options.add(new SelectOption('Processor__c', 'Processor'));
        options.add(new SelectOption('Business__c', 'Business'));
        return options;
    }

    public void loadApplications(){
        FilterOptionsMap = new Map<String, Set<String>>();
        SortedByStageMap = new Map<String, Map<Id, StageInfo>>();
        if(SelectedDateField == 'Application'){
            for(Application__c app:[SELECT Id, Account__c, Lender__c, Case_Manager__c, Case_Owner__c, Processor__c, Business__c, Broker_Fee__c, Application_Value__c,
                              (SELECT Id, Application_Stage_lkup__c, Hours_in_Stage__c FROM Stage_Histories__r)
                               FROM Application__c WHERE CreatedDate>=:DateHolderApp.Cancelled_Date__c AND CreatedDate<:DateHolderApp.Completed_Date__c.addDays(1)]){
                considerApplication(app);
            }
        }else{
            for(Application__c app:[SELECT Id, Account__c, Lender__c, Case_Manager__c, Case_Owner__c, Processor__c, Business__c, Broker_Fee__c, Application_Value__c,
                              (SELECT Id, Application_Stage_lkup__c, Hours_in_Stage__c FROM Stage_Histories__r WHERE CreatedDate>=:DateHolderApp.Cancelled_Date__c AND CreatedDate<:DateHolderApp.Completed_Date__c.addDays(1))
                               FROM Application__c WHERE CreatedDate>=:DateHolderApp.Cancelled_Date__c AND CreatedDate<:DateHolderApp.Completed_Date__c.addDays(1)]){
                considerApplication(app);
            }
        }
        queryObjectsNamesGroupedBy();
    }

    private void considerApplication(Application__c app){
        populateFilterOptionsWithApplication(app);
        if(!IgnoredRowsIds.contains('' + app.get(SelectedSortField)) && IsFilteredInApplication(app)){
            Set<Id> considered_stages = new Set<id>();
            for(Stage_History__c sh:app.Stage_Histories__r){
                if(!considered_stages.contains(sh.Application_Stage_lkup__c)){
                    considered_stages.add(sh.Application_Stage_lkup__c);
                    incrementTotalCounterForStage(app, sh);
                    incrementSpecificCounterForStage(app, sh, (String)app.get(SelectedSortField));
                }
            }
        }
    }

    private void populateFilterOptionsWithApplication(Application__c app){
        for(SelectOption option:getGroupByOptions()){
           putFilterOption(option.getValue(), (String)app.get(option.getValue()));
        }
    }

    private void putFilterOption(String sort_field, String option){
        Set<String> filter_options_set = FilterOptionsMap.get(sort_field);
        if(filter_options_set == null){
            filter_options_set = new Set<String>();
        }
        filter_options_set.add(option);
        FilterOptionsMap.put(sort_field, filter_options_set);
    }

    public List<SelectOption> getFilterOptions(){
        Set<String> filter_options_id_set = FilterOptionsMap.get(SelectedFilterField).clone();
        Boolean set_contains_null = filter_options_id_set.contains(null);
        if(set_contains_null){
            filter_options_id_set.remove(null);
        }
        List<String> filter_options_name_list = new List<String>();
        if(SelectedFilterField == 'Business__c'){
            filter_options_name_list.addAll(filter_options_id_set);
        }else{
            for(String key:filter_options_id_set){
                filter_options_name_list.add(SortedObjectsIdName.get(key));
            }
        }
        filter_options_name_list.sort();

        List<SelectOption> filter_options = new List<SelectOption>();
        for(String name:filter_options_name_list){
            filter_options.add(new SelectOption(getSortedFieldId(name, SelectedFilterField), name));
        }
        if(set_contains_null){
            filter_options.add(new SelectOption('null', 'N/A'));
        }
        return filter_options;
    }

    private Boolean IsFilteredInApplication(Application__c app){
        if(SelectedFilterOptions == null || SelectedFilterOptions.isEmpty()){
            return true;
        }else{
            String sorted_field_value = '' + app.get(SelectedFilterField);
            Set<String> filter_options_set = new Set<String>(SelectedFilterOptions);
            return filter_options_set.contains(sorted_field_value);
        }
    }

    private void incrementTotalCounterForStage(Application__c app, Stage_History__c sh){
        incrementMapCounterForStage(app, sh, 'total_line');
    }

    private void incrementSpecificCounterForStage(Application__c app, Stage_History__c sh, String sorted_field_value){
        incrementMapCounterForStage(app, sh, sorted_field_value);
    }

    private void incrementMapCounterForStage(Application__c app, Stage_History__c sh, String map_id){
        Map<Id, StageInfo> the_map = SortedByStageMap.get(map_id);
        if(the_map == null){
            the_map = new Map<Id, StageInfo>();
            SortedByStageMap.put(map_id, the_map);
        }
        if(the_map.containsKey(sh.Application_Stage_lkup__c)){
            StageInfo stage_info = the_map.get(sh.Application_Stage_lkup__c);
            stage_info.Amount += 1;
            stage_info.TotalHoursInStage += (sh.Hours_in_Stage__c != null ? sh.Hours_in_Stage__c : 0);
            stage_info.TotalBrokerFees += (app.Broker_Fee__c != null ? app.Broker_Fee__c : 0);
            stage_info.TotalAppValue += (app.Application_Value__c != null ? app.Application_Value__c : 0);
        }else{
            StageInfo stage_info = new StageInfo();
            stage_info.Amount = 1;
            stage_info.TotalHoursInStage = (sh.Hours_in_Stage__c != null ? sh.Hours_in_Stage__c : 0);
            stage_info.TotalBrokerFees = (app.Broker_Fee__c != null ? app.Broker_Fee__c : 0);
            stage_info.TotalAppValue = (app.Application_Value__c != null ? app.Application_Value__c : 0);
            the_map.put(sh.Application_Stage_lkup__c, stage_info);
        }
    }

    private void queryObjectsNamesGroupedBy(){
        SortedObjectsIdName = new Map<String, String>();
        AccountNameId = new Map<String, String>();
        LenderNameId = new Map<String, String>();
        UserNameId = new Map<String, String>();
        if(!FilterOptionsMap.isEmpty()){
            List<SObject> objects = [SELECT Id, Name FROM Account WHERE Id IN :FilterOptionsMap.get('Account__c')];
            populateObjectNameToIdMaps(objects, AccountNameId);

            objects = [SELECT Id, Name FROM Lender__c WHERE Id IN :FilterOptionsMap.get('Lender__c')];
            populateObjectNameToIdMaps(objects, LenderNameId);

            Set<String> user_ids = new Set<String>();
            user_ids.addAll(FilterOptionsMap.get('Case_Manager__c'));
            user_ids.addAll(FilterOptionsMap.get('Case_Owner__c'));
            user_ids.addAll(FilterOptionsMap.get('Processor__c'));
            objects = [SELECT Id, Name FROM User WHERE Id IN :user_ids];
            populateObjectNameToIdMaps(objects, UserNameId);
        }
        AccountNameId.put('total_line', 'total_line');
        LenderNameId.put('total_line', 'total_line');
        UserNameId.put('total_line', 'total_line');
    }

    private void populateObjectNameToIdMaps(List<SObject> objects, Map<String, String> map_to_put_data){
        for(SObject obj:objects){
            SortedObjectsIdName.put('' + obj.get('Id'), (String)obj.get('Name'));
            map_to_put_data.put((String)obj.get('Name'), '' + obj.get('Id'));
        }
    }

    public Component.Apex.OutputText getTable(){
        Component.Apex.OutputText table = new Component.Apex.OutputText();
        table.escape = false;
        table.value = '<table class="list" border="0" cellpadding="0" cellspacing="0" style="display:inline-block;width:auto;">';
        List<String> sorted_grouped_by_object_names = getSortedListOfGroupedByObjectNames();
        List<Application_Stage__c> stages = [SELECT Id, Stage__c, Stage_Order__c FROM Application_Stage__c WHERE Stage_Order__c<30 ORDER BY Stage_Order__c ASC];
        String fixed_table = '<table class="list" border="0" cellpadding="0" cellspacing="0" style="display:inline-block;width:auto;">' + formatFixedTableHead(stages) + '<tbody>';
        table.value += formatTableHead(stages) + '<tbody>';
        for(Integer line=0;line<sorted_grouped_by_object_names.size();line++){
            Boolean is_last_line = line == sorted_grouped_by_object_names.size() - 1;
            Integer amount_of_prev_stage = 0;
            String sorted_field_id = getSortedFieldId(sorted_grouped_by_object_names.get(line), SelectedSortField);

            fixed_table += '<tr class="dataRow" style="height:30px;' + (is_last_line && sorted_field_id == 'total_line' ? 'font-weight:bold;' : '') + '">';
            table.value += '<tr class="dataRow" style="height:30px;' + (is_last_line && sorted_field_id == 'total_line' ? 'font-weight:bold;' : '') + '">';
            fixed_table += '<td class="dataCell"><input type="checkbox" id="' + sorted_field_id + '"/></td>';
            fixed_table += '<td class="dataCell" style="white-space:nowrap;">' + getSortedFieldLink(sorted_field_id) + '</td>';
            Map<Id, StageInfo> current_line = SortedByStageMap.get(sorted_field_id);

            for(Integer i=0;i<stages.size();i++){
                Boolean is_last_stage = i == stages.size() - 1;
                Integer amount_for_stage = current_line.containsKey(stages.get(i).Id) ? current_line.get(stages.get(i).Id).Amount : 0;
                if(stages.get(i).Stage_Order__c == 1){
                    fixed_table += '<td class="dataCell">' + amount_for_stage.format() + '</td>';
                    amount_of_prev_stage = amount_for_stage;
                    continue;
                }
                table.value += '<td class="dataCell" style="' + LeftB + (is_last_line ? BottomB : '') + '">' + amount_for_stage.format() + '</td>';
                Integer total_for_stage = current_line.get(stages.get(0).Id).Amount;
                Decimal percent_total = 0;
                if(total_for_stage > 0){
                    percent_total = ((Decimal)amount_for_stage)/total_for_stage * 100;
                }
                Decimal percent_of_prev_stage = 0;
                if(amount_of_prev_stage > 0){
                    percent_of_prev_stage = ((Decimal)amount_for_stage)/amount_of_prev_stage * 100;
                }
                Decimal total_hours = current_line.containsKey(stages.get(i).Id) ? current_line.get(stages.get(i).Id).TotalHoursInStage : 0;
                Decimal avg_hours = 0;
                if(total_hours > 0){
                    avg_hours = total_hours/amount_for_stage;
                }
                Decimal total_fees = current_line.containsKey(stages.get(i).Id) ? current_line.get(stages.get(i).Id).TotalBrokerFees : 0;
                Decimal total_value = current_line.containsKey(stages.get(i).Id) ? current_line.get(stages.get(i).Id).TotalAppValue : 0;
                table.value += '<td class="dataCell" style="' + (is_last_line ? BottomB : '') + '">' + percent_total.setScale(2) + '%</td>';
                table.value += '<td class="dataCell" style="' + (is_last_line ? BottomB : '') + '">' + percent_of_prev_stage.setScale(2) + '%</td>';
                table.value += '<td class="dataCell" style="' + (is_last_line ? BottomB : '') + '">' + avg_hours.setScale(2) + '</td>';
                table.value += '<td class="dataCell" style="' + (is_last_line ? BottomB : '') + '">&pound;' + total_fees.setScale(2) + '</td>';
                table.value += '<td class="dataCell" style="' + (is_last_line ? BottomB : '') + (is_last_stage ? RightB : '') + '">&pound;' + total_value.setScale(2) + '</td>';
                amount_of_prev_stage = amount_for_stage;
            }
            table.value += '</tr>';
            fixed_table += '</tr>';
        }
        table.value += '</tbody></table>';
        fixed_table += '</tbody></table>';
        table.value = '<div style="float:left;">' + fixed_table + '</div>'
                    + '<div style="overflow:auto;">' + table.value + '</div>';
        return table;
    }

    private String getSortedFieldId(String name, String selected_field){
        if(selected_field == 'Business__c'){
            return name;
        }else if(selected_field == 'Account__c'){
            return AccountNameId.get(name);
        }else if(selected_field == 'Lender__c'){
            return LenderNameId.get(name);
        }else{
            return UserNameId.get(name);
        }
    }

    private List<String> getSortedListOfGroupedByObjectNames(){
        List<String> sorted_field_values = new List<String>();
        Set<String> keys = SortedByStageMap.keySet().clone();
        keys.remove('total_line');
        Boolean keys_contain_null = keys.contains(null);
        if(keys_contain_null){
            keys.remove(null);
        }
        if(SelectedSortField == 'Business__c'){
            sorted_field_values.addAll(keys);
        }else{
            for(String key:keys){
                sorted_field_values.add(SortedObjectsIdName.get(key));
            }
        }
        sorted_field_values.sort();
        if(keys_contain_null){
            sorted_field_values.add(null);
        }
        if(!IgnoredRowsIds.contains('total_line')){
            sorted_field_values.add('total_line');
        }
        return sorted_field_values;
    }

    private String formatTableHead(List<Application_Stage__c> stages){
        String table_head = '<thead><tr class="headerRow" style="height:60px;line-height:1;">';
        for(Integer i=1;i<stages.size();i++){
            table_head += '<th class="headerRow" style="white-space:normal;' + LeftB + TopB + '">' + stages.get(i).Stage__c + '</th>';
            table_head += '<th class="headerRow" style="' + TopB + '">% Tot</th>';
            table_head += '<th class="headerRow" style="' + TopB + '">% Prev</th>';
            table_head += '<th class="headerRow" style="' + TopB + '">Hours</th>';
            table_head += '<th class="headerRow" style="' + TopB + '">Fees</th>';
            table_head += '<th class="headerRow" style="' + TopB + ((i == stages.size() - 1) ? RightB : '') + '">Earnings</th>';
        }
        table_head += '</tr></thead>';
        return table_head;
    }

    private String formatFixedTableHead(List<Application_Stage__c> stages){
        String sort_field_label = Schema.SObjectType.Application__c.fields.getMap().get(SelectedSortField).getDescribe().getLabel();
        String table_head = '<thead><tr class="headerRow" style="height:60px;line-height:1;">';
        table_head += '<th class="headerRow">Select</th>';
        table_head += '<th class="headerRow">' + sort_field_label + '</th>';
        if(stages.size() > 0){
            table_head += '<th class="headerRow" style="white-space:normal;">' + stages.get(0).Stage__c + '</th>';
        }
        table_head += '</tr></thead>';
        return table_head;
    }

    private String getSortedFieldLink(String sorted_field_value){
        if(sorted_field_value == 'total_line'){
            return 'TOTAL';
        } else if(sorted_field_value == null){
            return 'N/A';
        }else if(SelectedSortField == 'Business__c'){
            return sorted_field_value;
        }else{
            return '<a href="/' + sorted_field_value + '">' + SortedObjectsIdName.get(sorted_field_value) + '</a>';
        }
    }

    public Boolean getDisplayIgnoredMessage(){
        return !IgnoredRowsIds.IsEmpty();
    }

    public void hideSelectedRows(){
        List<String> ids_to_hide = SelectedRowsIdsToIgnore.split(',');
        IgnoredRowsIds.addAll(ids_to_hide);
        loadApplications();
    }

    class StageInfo{
        public Integer Amount {get; set;}
        public Decimal TotalHoursInStage {get; set;}
        public Decimal TotalBrokerFees {get; set;}
        public Decimal TotalAppValue {get; set;}
    }
}