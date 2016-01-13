public with sharing class ApplicationAssignment{
// *******************************************
// Developer:   Eddie Bates
// Name:        ApplicationAssignment - Unit test is in ApplicationTriggerHandler_Test
// Created:     06/01/2015
// Description: JIRA SEC-199. This simply gets Users of a certain Role to assign as Case Owner, Case Manager or Processor of an Application
//				It then updates the Application Stage Last Assignment fields of the User Object
// *******************************************
/* +-----------------------------------------------------------------------------------------------------------------------------+
   | Updates                                                                                                                     |
   |-----------------------------------------------------------------------------------------------------------------------------|
   | Developer    Date          Description                                                                                      |
   +-----------------------------------------------------------------------------------------------------------------------------+
    
   |-----------------------------------------------------------------------------------------------------------------------------|
*/    
    
    public ApplicationAssignment() {
        
    }
    
    public static Map<Application__c, Id> getSalesUser(List<Application__c> sales_user_applications){
        
        Map<Application__c, Id> applications_to_update_map = new Map<Application__c, Id>();
        
        for (Application__c application : sales_user_applications) {

            applications_to_update_map.put(application, application.LastModifiedById);

        }
        
    return applications_to_update_map;
    }

    public static Map<Application__c, Id> getCaseManager(List<Application__c> case_manager_applications){
        
        Map<Application__c, Id> applications_to_update_map = new Map<Application__c, Id>();        
        
        for (Application__c application : case_manager_applications) {
            
            User users_to_update = getAssignedUser(application, 'case_manager');            
	        if(users_to_update != null){
				updateUserAssignment(users_to_update);                        
	            applications_to_update_map.put(application, users_to_update.Id);
			}    				
        }
        
    return applications_to_update_map;
    }

    public static Map<Application__c, Id> getProcessor(List<Application__c> processor_applications){
        
        Map<Application__c, Id> applications_to_update_map = new Map<Application__c, Id>();        
        
        for (Application__c application : processor_applications) {
            
            User users_to_update = getAssignedUser(application, 'processor');  
			if(users_to_update != null){
				updateUserAssignment(users_to_update);                        
            	applications_to_update_map.put(application, users_to_update.Id);
			}            
        }
        
    return applications_to_update_map;
    }      
    
    public static void updateUserAssignment(User update_user_assignment){
        
        // Create a savepoint to Rollback on Error
        Savepoint sp = Database.setSavepoint();
        
        //Set last assignment datetime for the User, this is used for the Round Robin functionality
        //so that each Role is assigned Applications equally
        datetime now = datetime.now();
        update_user_assignment.Application_Stage_Last_Assignment__c = now;
        update_user_assignment.Application_Stage_Millisecond__c = now.millisecondGMT();
            
        try 
        {
            update update_user_assignment;                                                          
        } 
        catch (System.DmlException e)
        {                   
            System.debug('ERROR: Not able to Update User Last Assignment Dates: ' + e);
            // Rollback
            Database.rollback(sp);
        }
    }
    
    public static User getAssignedUser(Application__c application, String user_role_type){
    
        User user_to_auto_assign_object = null;      
        Set<Id> auto_assign_user_ids = new Set<id>();
		user_role_type = '%' + user_role_type + '%';
        
        Id user_role_id = [SELECT UserRoleId FROM User WHERE Id=: application.Case_Owner__c].UserRoleId;
        Id parent_role_id = [SELECT ParentRoleId FROM UserRole WHERE Id =: user_role_id].ParentRoleId;
        
        Group_Util group_util = new Group_Util(); 
        auto_assign_user_ids = group_util.roleSubordinateUsers.get(parent_role_id);
		
        List<User> user_to_auto_assign_today = [SELECT U.Id, U.Application_Stage_Last_Assignment__c, U.Application_Stage_Millisecond__c 
                            FROM User U WHERE U.Id IN :auto_assign_user_ids AND 
                            UserRole.DeveloperName LIKE :user_role_type
							AND U.LastLoginDate = TODAY
                            ORDER BY U.Application_Stage_Last_Assignment__c ASC, 
                            U.Application_Stage_Millisecond__c 
                            DESC LIMIT 1];
		
		if(user_to_auto_assign_today.size() == 1) {
			user_to_auto_assign_object = user_to_auto_assign_today[0];							
		} 
		else{
			List<User> user_to_auto_assign = [SELECT U.Id, U.Application_Stage_Last_Assignment__c, U.Application_Stage_Millisecond__c 
                            FROM User U WHERE U.Id IN :auto_assign_user_ids AND 
                            UserRole.DeveloperName LIKE :user_role_type
                            ORDER BY U.Application_Stage_Last_Assignment__c ASC, 
                            U.Application_Stage_Millisecond__c 
                            DESC LIMIT 1];
			if(user_to_auto_assign != null && user_to_auto_assign.size() == 1) {
				user_to_auto_assign_object = user_to_auto_assign[0];
			}
		}
                
    return user_to_auto_assign_object;
    }
    
}