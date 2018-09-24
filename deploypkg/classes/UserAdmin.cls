/*
* Desc: Class for User Admin
* Author: Marian Baleros
* Created: October 24, 2012
* User Story: 
* History:
* Date        Author           Description
* 18/04/2013  Tobias Hastings  Added Desk Number and FT Region columns
* 19/04/2013  Tobias Hastings  Modified the constructor, cancel and save methods to no longer
*                              require a standardController
*                              added lookupUser method
* 21/05/2013  Tobias Hastings  Modified sendParam and added 2nd lookupUser method
*                              Removed code for searching for a user
* 22/05/2013  Tobias Hastings  Added showNoSearchMessage and companyDirectoryTabId
* 04/02/2014  Tobias Hastings  Added request and modified all methods to account for it
* 07/02/2014  Tobias Hastings  Updated lookupUser and save to retreive and check the part time work days
* 17/02/2014  Tobias Hastings  Added Title to lookupUser query and save check for differences
* 30/07/2014  Tammy Mistry     Added getUserHistory method
* 05/08/2014  Tammy Mistry     Added PA Details and Notes fields
* 13/03/2015  T.Sotiraki       Refactored class to use remote actions and origami
* 03/03/2016  Tammy Mistry     Added getCurrentUser remote action
*/
global with sharing class UserAdmin{

    
    @RemoteAction
    public static PageReference cancel(){
        
        PageReference home = new PageReference('/');
        return home;
    }  
     

    @RemoteAction
    public static User getUser(string userId){

        User u = [Select Id, Name, ManagerId, Joining_Date__c, Desk_Number__c, FT_Region__c, User_Type__c,
                        Work_on_Monday__c, Work_on_Tuesday__c, Work_on_Wednesday__c, Work_on_Thursday__c, 
                        Work_on_Friday__c, Work_on_Saturday__c, Work_on_Sunday__c, Title, FT_Employee_Payroll_Number__c,PA_Details__r.Name,
                        Cost_Center_Name__c, Cost_Center_Number__c, BusinessArea__c, PA_Details__c, Notes__c, Manager.FirstName, Manager.LastName
                  From User 
                  Where Id = :userId 
                  Limit 1];
        
        return u;
    }


    @RemoteAction
    public static List<USERHISTORY__User_Field_History__c> getUserHistory(string userId){

        List<USERHISTORY__User_Field_History__c> history = new List<USERHISTORY__User_Field_History__c>();

        history = [SELECT USERHISTORY__Field_Label__c, USERHISTORY__Previous_Value__c,
                USERHISTORY__Previous_Date_Time_Value__c, USERHISTORY__Previous_Date_Value__c,
                USERHISTORY__Previous_Rich_Text_Area_Value__c, USERHISTORY__Previous_Text_Area_Multi_Picklist_Value__c,
                USERHISTORY__New_Value__c, USERHISTORY__New_Date_Time_Value__c, USERHISTORY__New_Date_Value__c,
                USERHISTORY__New_Rich_Text_Area_Value__c,USERHISTORY__New_Text_Area_Multi_Picklist_Value__c,            
                USERHISTORY__Changed_By__c, USERHISTORY__Date_Time_Changed__c, USERHISTORY__Changed_By__r.Name           
                FROM USERHISTORY__User_Field_History__c
                WHERE USERHISTORY__User__c = :userId
                ORDER BY USERHISTORY__Date_Time_Changed__c DESC limit 20];
    	system.debug(history);
        return history;
   	}

    


    /**
     * @Name: getAllCompanyUsers
     * @Description: Remote action method that returns a list of all the current active users with a UserType of 'Standard' 
     * or 'CSNOnly' 
     * @Return: List<User> allCompanyUsers
     */
    @RemoteAction
    public static List<User> getAllCompanyUsers(){
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


    /**
     * @Name: save
     * @Description: Remote action method that returns a list of all the current active users with a UserType of 'Standard' 
     * or 'CSNOnly' 
     * @Return: string
     */
    @RemoteAction
    public static string save(string userId, string manager, string userType, string deskNumber, string businessArea,
                              string title, string region, string joinDate, boolean monday, boolean tuesday, boolean wednesday,
                              boolean thursday, boolean friday, boolean saturday, boolean sunday, string payroll, string ccName, 
                              string ccNumber, string pa, string notes){

        User checkUser = getUser(userId);

        String existingManagerName = checkUser.Manager.FirstName + '' + checkUser.Manager.LastName;
        String existingPA = checkUser.PA_Details__r.Name;
        
            if(checkUser.Desk_Number__c != deskNumber && deskNumber != null){
                checkUser.Desk_Number__c = deskNumber;
            }
            if(checkUser.Title != title && title != null){
                checkUser.Title = title;
            }
            if(checkUser.BusinessArea__c != businessArea && businessArea != null){
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

            if(pa.length() > 0){ 
                if(existingPA != pa){
                    //Get new pa Id from Name
                
                    User newPA = new User();

                    newPa = [Select Id, Name 
                             From User
                             Where Name = :pa
                             Limit 1]; 



                    if(newPA != null){
                        checkUser.PA_Details__c = newPA.Id;
                    }
                }
                
            }          
            
            if(checkUser.FT_Region__c != region){
              checkUser.FT_Region__c = region;
            }

            if(checkUser.Joining_Date__c != Date.parse(joinDate)){
              checkUser.Joining_Date__c = Date.parse(joinDate);
            }

            if(checkUser.User_Type__c != userType){
              checkUser.User_Type__c = userType;
            }

            if(checkUser.Work_on_Monday__c != monday){
              checkUser.Work_on_Monday__c = monday;
            }

            if(checkUser.Work_on_Tuesday__c != tuesday){
              checkUser.Work_on_Tuesday__c = tuesday;
            }

            if(checkUser.Work_on_Wednesday__c != wednesday){
              checkUser.Work_on_Wednesday__c = wednesday;
            }

            if(checkUser.Work_on_Thursday__c != thursday){
              checkUser.Work_on_Thursday__c = thursday;
            }

            if(checkUser.Work_on_Friday__c != friday){
              checkUser.Work_on_Friday__c = friday;
            }

            if(checkUser.Work_on_Saturday__c != saturday){
              checkUser.Work_on_Saturday__c = saturday;
            }

             if(checkUser.Work_on_Sunday__c != sunday){
              checkUser.Work_on_Sunday__c = sunday;
            }
            
            if(checkUser.FT_Employee_Payroll_Number__c != payroll){
              checkUser.FT_Employee_Payroll_Number__c = payroll;
            }

            if(checkUser.Cost_Center_Name__c != ccName){
              checkUser.Cost_Center_Name__c = ccName;
            }

            if(checkUser.Cost_Center_Number__c != ccNumber){
              checkUser.Cost_Center_Number__c = ccNumber;
            }

           // if(checkUser.PA_Details__c != pa && pa != null){
            //  checkUser.PA_Details__c = pa;
            //}

             if(checkUser.Notes__c != notes){
              checkUser.Notes__c = notes;
            }


            try{
                update checkUser;

                return 'The User has been updated'; 
            }
            catch (Exception e){
                return e.getMessage();
            }


        }            
    
    //Returns the current User's details
    @RemoteAction
    public static User getCurrentUser()
    {
        User currentUser = [Select Id, Name, LocaleSidKey From User
							Where Id =: UserInfo.getUserID() Limit 1];
		
		return currentUser;
    }   
}