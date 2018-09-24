/*
* Date        Author           Change Description
* -----------------------------------------------------------------------------
* 02/03/2015  T.Sotiraki       Class Created  
*
*/
global with sharing class PeopleFinderController {
    

    /**
     * @Name: getCompanyUsers
     * @Description: Remote action method that returns a list of users
     * @Param: String businessArea, String searchInput, Boolean searchAllFields
     * @Return: List<User>
     */
    @RemoteAction
    global static List<User> getCompanyUsers(String businessArea, String searchInput, Boolean searchAllFields){
        List<User> users = new List<User>();
        system.debug('APEX searchInput : ' + searchInput);
        String query = 'Select Id, LastName, FirstName, Email, Title, BusinessArea__c, Cost_Center_Name__c, Cost_Center_Number__c, Extension, Manager.Name, Manager.FirstName, Manager.LastName,Desk_Number__c, FT_Region__c, User_Type__c, PA_Details__r.Name, Notes__c, User_Has_Notes__c, IsActive, IsPortalEnabled, Joining_Date__c, ManagerId From User Where IsActive = true And IsPortalEnabled = false ';

        if(searchInput != null && searchInput != ''){
            List<String> fieldList = new List<String>();

            if(searchAllFields == true){
                fieldList.add('Name');
                fieldList.add('FirstName');
                fieldList.add('LastName');
                fieldList.add('Title');
                fieldList.add('BusinessArea__c');
                fieldList.add('User_Type__c');
                fieldList.add('Extension');
                fieldList.add('Manager.Name');
                fieldList.add('Manager.FirstName');
                fieldList.add('Manager.LastName');
                fieldList.add('Desk_Number__c');
                fieldList.add('FT_Region__c');
                fieldList.add('PA_Details__r.Name');
                fieldList.add('Notes__c');
                fieldList.add('User_Has_Notes__c');
            }
            else{
                fieldList.add('Name');
                fieldList.add('FirstName');
                fieldList.add('LastName');
            }

            String formatedSearchStr = searchInput.replace('*', '%');
            formatedSearchStr = formatedSearchStr.replace('\\', '\\\\');
            formatedSearchStr = formatedSearchStr.replace('\'', '\\\'');
            formatedSearchStr = formatedSearchStr.trim();
            String formatedStartStr = '%' + formatedSearchStr;
            String formatedEndStr = formatedSearchStr + '%';
            String formatedBothStr = '%' + formatedSearchStr + '%';

            Boolean firstEntry = true;
            for (String fieldName : fieldList){
                if (firstEntry){
                    query += ' And (UserType = \'Standard\' OR UserType = \'CSNOnly\') and (';
                    firstEntry = false;
                }
                else{
                    query += ' or ';
                }
                query += '' + fieldName + ' like \'' + formatedSearchStr + '\' or ' + fieldName + ' like \'' + formatedStartStr + '\' or ' + 
                              fieldName + ' like \'' + formatedEndStr + '\' or ' + fieldName + ' like \'' + formatedBothStr + '\'';
                
            }
            query += ')';
        }
        
        if(businessArea != 'Please select a business area'){

            query += ' And BusinessArea__c = \'' + businessArea + '\' Order by FirstName ASC' ;


        }else{
            query += ' Order by FirstName ASC' ;
        }
                
        if(query != null){
            users = Database.query(query);
        }
        return users;
    }

    /**
     * @Name: doesUserHaveEditPermission
     * @Description: Remote action method that returns true/false is the current user has edit permissions
     * @Return: Boolean
     */
    @RemoteAction
    global static boolean doesUserHaveEditPermission(){
        
        Boolean result = false;
        
        User currentUser = [select Id from User where Id = :UserInfo.getUserId() Limit 1];
    
        List<PermissionSetAssignment> editPermissionAssignment = new List<PermissionSetAssignment>();
        String editPermission = 'Company Directory Edit';

        PermissionSet permission = [Select Id, Label
                                    From PermissionSet
                                    Where Label = :editPermission
                                    Limit 1];

        if(permission != null){
            editPermissionAssignment = [Select Id, AssigneeId, PermissionSetId
                                        From PermissionSetAssignment
                                        Where PermissionSetId = :permission.Id
                                        And AssigneeId = :currentUser.Id
                                        Limit 1];
        }
        
        
        if(editPermissionAssignment.size() > 0){
            result = true;
        }else{
            result = false;
        }

        return result;
        
    }

    /**
     * @Name: doesUserHaveExportPermission
     * @Description: Remote action method that returns true/false is the current user has export permissions
     * @Return: Boolean
     */
    @RemoteAction
    global static boolean doesUserHaveExportPermission(){
        
        Boolean result = false;
        
        User currentUser = [select Id from User where Id = :UserInfo.getUserId() Limit 1];
    
        List<GroupMember> exportPermissionAssignment = new List<GroupMember>();
        
        String exportPermission = 'Editorial Management';

        Group gr = [Select Id, Name
                            From Group
                            Where Name = :exportPermission
                            Limit 1];

        if(gr != null){
            exportPermissionAssignment = [Select Id, GroupId, UserOrGroupId
                                        From GroupMember
                                        Where GroupId = :gr.Id
                                        And UserOrGroupId = :currentUser.Id
                                        Limit 1];
        }
        
         
        if(exportPermissionAssignment.size() > 0){
            result = true;
        }else{
            result = false;
        }

        return result;
        
    }

    /**
     * @Name: doesUserHaveExportPermission
     * @Description: Remote action method that updates the users record
     * @Param: String title, String desknumber, String businessArea
     * @Return: User
     */
    @RemoteAction
    global static User updateMyDetails(String title, String desknumber, String businessArea){
        
        User currentUser = [select Id, Title, BusinessArea__c, Desk_Number__c from User where Id = :UserInfo.getUserId() Limit 1];
    
        try{
            currentUser.Title = title;
            currentUser.BusinessArea__c = businessArea;
            currentUser.Desk_Number__c = desknumber;
        }catch(Exception ex){

        }
        return currentUser;
        
    }

    /**
     * @Name: editMyDetails
     * @Description: Remote action method that returns a PageReference to the Edit My Details page
     * @Return: PageReference
     */
    @RemoteAction
    global static PageReference editMyDetails(){
        
        PageReference editDetails = new PageReference('/apex/EditMyDetails?Id=' + UserInfo.getUserId());

        return editDetails;
        
    }

    /**
     * @Name: returnToHomepage
     * @Description: Remote action method that returns a PageReference to the homepage
     * @Return: PageReference
     */
    @RemoteAction
    global static PageReference returnToHomepage(){
        
        PageReference homepage = new PageReference('/');

        return homepage;
        
    }

    /**
     * @Name: exportToExcel
     * @Description: Remote action method that returns a PageReference value to the Export To Excel page 
     * @Return: PageReference
     */
    @RemoteAction
    global static String exportToExcel(){
        
        String x= '';
        //PageReference xls = new PageReference('/apex/CompanyDirectoryExportPage');
        //xls.getParameters().put('searchStr',lastSearchStr);
        /*xls.getParameters().put('query',lastQuery);
        xls.getParameters().put('soqlexecute',SOQLEXECUTE);
        xls.getParameters().put('pageSize',String.valueOf(LIST_SIZE));
        xls.getParameters().put('sortField',sortField);
        xls.getParameters().put('sortDir',sortDir);
        xls.setRedirect(false);*/
        
        return x;
    }

    /**
     * @Name: editUserDetails
     * @Description: Remote action method that returns a PageReference value to the HR User Admin page for 
     * a specific user 
     * @Param: String userId
     * @Return: PageReference
     */
    @RemoteAction
    global static PageReference editUserDetails(String userId){
        
        PageReference editDetails = new PageReference('/apex/UserAdmin?Id=' + userId);

        return editDetails;
        
    }

    /**
     * @Name: viewUserDetails
     * @Description: Remote action method that returns a PageReference value to a user's profile  
     * @Return: PageReference
     */
    @RemoteAction
    global static PageReference viewUserDetails(String userId){
        
        PageReference viewUserRecord = new PageReference('/' + userId);

        return viewUserRecord;
        
    }

    /**
     * @Name: returnToPeopleFinder
     * @Description: Remote action method that returns a PageReference value to the People Finder app 
     * @Return: PageReference
     */
    @RemoteAction
    global static PageReference returnToPeopleFinder(){
        
        PageReference peopleFinder = new PageReference('/apex/PeopleFinder');

        return peopleFinder;
        
    }
}