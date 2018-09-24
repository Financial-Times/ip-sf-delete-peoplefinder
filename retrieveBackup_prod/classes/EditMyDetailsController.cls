/*
* Date        Author            Change Description
* -----------------------------------------------------------------------------
* 26/06/2014  Aaron Fairtlough  Initial Class Creation
* 26/06/2014  Aaron Fairtlough  Save Method Added
* 01/07/2014  Aaron Fairtlough  Cancel Method Added
* 23/02/2015  Aaron Fairtlough  Remove URL paramertised user passthrough.
* 15/03/2015  T.Sotiraki        Updated class to use Origami 
*/

global with sharing class EditMyDetailsController {

	public String currentUserId {get; private set;}
	
    /**
     * @Name: getUser
     * @Description: Remote action method that returns the user details of the current user
     * @Param: String userId
     * @Return: User currentUser
     */
    @RemoteAction
    global static User getUser(string userId){
        User u;

        if(userId != null){
         u = [Select Id, Name, ManagerId, Manager.FirstName, Manager.LastName, Joining_Date__c, Desk_Number__c, FT_Region__c, Title, BusinessArea__c 
                  From User 
                  Where Id = :userId 
                 Limit 1];
        }else{
            String s = getCurrentUserId();

            u = [Select Id, Name, ManagerId, Manager.FirstName, Manager.LastName, Joining_Date__c, Desk_Number__c, FT_Region__c, Title, BusinessArea__c 
                  From User 
                  Where Id = :s 
                 Limit 1];
        }
        
        
    	return u;
    }

    /**
     * @Name: getCurrentUserId
     * @Description: Remote action method that returns the Id of the current user
     * @Return: String currentUserId
     */
    @RemoteAction
    global static String getCurrentUserId(){
        String currentUserId = UserInfo.getUserId();

        return currentUserId;
    }
    
    /**
     * @Name: cancel
     * @Description: Remote action method that returns the PageReference for the Salesforce Homepage
     * @Return: PageReference homepage
     */
    @RemoteAction
    global static PageReference cancel(){
    	
    	PageReference home = new PageReference('/');
    	return home;
    }    
    
    /**
     * @Name: save
     * @Description: Remote action method that saves any changes made to the User record
     * @Param: String userId, String deskNumber, String title, String businessArea, String manager
     * @Return: String result
     */
    @RemoteAction
    global static String save(string userId, string deskNumber, string title, string businessArea, string manager){

		User checkUser = getUser(userId); 
	  	
        String existingManagerName = checkUser.Manager.FirstName + '' + checkUser.Manager.LastName;

            if(checkUser.Desk_Number__c != deskNumber){
                checkUser.Desk_Number__c = deskNumber;
            }
            if(checkUser.Title != title){
                checkUser.Title = title;
            }
            if(checkUser.BusinessArea__c != businessArea){
                 checkUser.BusinessArea__c = businessArea;
            }
            if(manager.length() > 0){     
                if(existingManagerName != manager){
                    //Get new manager Id from Name
                
                    User newManager = [Select Id, Name 
                                       From User
                                       Where Name = :manager
                                       Limit 1]; 



                    if(newManager != null){
                        checkUser.ManagerId = newManager.Id;
                    }
                }
                
            }          
            
            try{
                update checkUser;

                return 'The User has been updated'; 
            }
            catch (Exception e){
                return e.getMessage();
            }
	 	 
       
    }    

 
    /**
     * @Name: getAllCompanyUsers
     * @Description: Remote action method that returns a list of all the current active users with a UserType of 'Standard' 
     * or 'CSNOnly' 
     * @Return: List<User> allCompanyUsers
     */
    @RemoteAction
    global static List<User> getAllCompanyUsers(){
        List<User> users = new List<User>();
        
        try{
                users = [Select Id, Name, UserType, isActive
                         From User
                         Where (UserType = 'Standard' OR UserType = 'CSNOnly')
                         And isActive = true
                         Order by Name ASC];

               
            }
            catch (Exception e){ 
                system.debug(e.getMessage());
            }
         
        return users;
    }    
}