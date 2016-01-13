public with sharing class Group_Util{

	private static final String userPrefix = User.SObjectType.getDescribe().getKeyPrefix();

    public Map<Id, Set<Id>> roleUsers { get; private set; }
    public Map<Id, Set<Id>> roleSubordinateUsers { get; private set; }
    public Map<Id, Set<Id>> groupsUsers { get; private set; }
    public Map<Id, Set<Id>> usersGroups { get; private set; }
    public Map<Id, Set<Id>> usersQueues { get; private set; }
	
	public Group_Util() {
        this.roleUsers = new Map<Id, Set<Id>>();
        this.roleSubordinateUsers = new Map<Id, Set<Id>>();
        this.groupsUsers = new Map<Id, Set<Id>>();
        this.usersGroups = new Map<Id, Set<Id>>();
        this.usersQueues = new Map<Id, Set<Id>>();
        refresh(true, true);
    }
	
    public void refresh(Boolean refreshRoles, Boolean refreshGroups) {
        if(refreshRoles) {
            refreshRoles();
        }
        if(refreshGroups) {
            refreshGroups();
        }
    }

    public void refreshRoles() {
        roleUsers.clear();
        roleSubordinateUsers.clear();
        //Populate a Map with the role Id and all the users
        Map<Id, UserRole> roles = new Map<Id, UserRole>([
            SELECT Id, Name, ParentRoleId, ( SELECT Id, Name FROM Users ) FROM UserRole]);
        Set<Id> userIds;
        Id subordinateId;
        for(UserRole role : roles.values()) {
            //Add the User Ids of the current role
            roleUsers.put(role.Id, (new Map<Id, User>(role.Users)).keySet());
            //Loop throuh and populate the role and subordinate Map
            subordinateId = null;
            while(role != null) {
                if(!roleSubordinateUsers.containsKey(role.Id)) {
                    roleSubordinateUsers.put(role.Id, new Set<Id>());
                }
                userIds = roleSubordinateUsers.get(role.Id);
                if(roleSubordinateUsers.containsKey(subordinateId)) {
                    userIds.addAll(roleSubordinateUsers.get(subordinateId));
                }
                for(User user : role.Users) {
                    userIds.add(user.Id);
                }
                subordinateId = role.Id;
                role = roles.get(role.ParentRoleId);
            }
        }
    }

    public void refreshGroups() {
        groupsUsers.clear();
        usersGroups.clear();
        Map<Id, Group> groups = new Map<Id, Group>([ SELECT Id, Name, Type,  RelatedId,
                ( SELECT UserOrGroupId FROM GroupMembers ),
                ( SELECT Id, SobjectType FROM QueueSobjects )  FROM Group]);

        List<Id> stack;
        Set<Id> userIds, queueIds;
        Group groop;
        for(Id groupId : groups.keySet()) {
            stack = new List<Id> { groupId };
            userIds = new Set<Id>();
            do {
                groop = groups.get(stack.remove(0));
                //This is extra cautious, it should not be possible to get a null value
                if(groop != null) {
                    if(groop.RelatedId != null) {
                        if(groop.Type == 'Role') {
                            userIds.addAll(roleUsers.get(groop.RelatedId));
                        } else if(groop.Type == 'RoleAndSubordinates') {
                            userIds.addAll(roleSubordinateUsers.get(groop.RelatedId));
                        }
                    } else {
                        for(GroupMember member : groop.GroupMembers) {
                            if(isPrefix(member.UserOrGroupId, userPrefix)) {
                                userIds.add(member.UserOrGroupId);
                            } else {
                                //When the Id is not a user Id it is reliably a group Id, that we can add to the stack for processing
                                stack.add(member.UserOrGroupId);
                            }
                        }
                    }
                }
            } while(!stack.isEmpty());
            if(userIds.size() > 0) {
                groupsUsers.put(groupId, userIds);
                for(Id userId : userIds) {
                    if(!usersGroups.containsKey(userId)) {
                        usersGroups.put(userId, new Set<Id>());
                    }
                    usersGroups.get(userId).add(groupId);
                }
            }
        }
        for(Id userId : usersGroups.keySet()) {
            if(!usersQueues.containsKey(userId)) {
                usersQueues.put(userId, new Set<Id>());
            }
            for(Id groupId : usersGroups.get(userId)) {
                groop = groups.get(groupId);
                if(groop.Type == 'Queue' && groop.QueueSobjects.size() > 0) {
                    usersQueues.get(userId).addAll((new Map<Id, QueueSobject>(groop.QueueSobjects)).keySet());
                }
            }
        }
    }

    public static Boolean isPrefix(Id sfdcId, String prefix) {
        if(sfdcId == null || prefix == null || prefix.length() != 3) {
            return false;
        } else {
            return String.valueOf(sfdcId).startsWith(prefix);
        }
    }
}