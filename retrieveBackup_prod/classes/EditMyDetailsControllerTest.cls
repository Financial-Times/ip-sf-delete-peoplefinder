/* Change Log  
*
* Date        Author          Change Description
* ------------------------------------------------------------------------------------
* 04/04/2015  T.Sotiraki      Refactored for test class performance
* 01/06/2015  T.Mistry		  Modified test to run as Test User
* 
*/
@isTest
private with sharing class EditMyDetailsControllerTest {
	
    public static User testManager;
    public static User testUser;
    
    private @testSetup static void setupData()
    {                
        List<User> users = new List<User>();
        
        testManager = testHelper.createUser();
        testManager.FirstName = 'TestClass';
        testManager.LastName = 'Manager';
        users.add(testManager);
        
        testUser = testHelper.createUser();
        testUser.FirstName = 'TestClass';
        testUser.LastName = 'User';
        users.add(testUser);
        
        insert users;
    }    
    
	public static testMethod void controllerTest()
    {	
        test.startTest();		
     
        testUser = [Select Id, FirstName, LastName From User Where FirstName = 'TestClass' And LastName = 'User' Limit 1];
        testManager = [Select Id, FirstName, LastName From User Where FirstName = 'TestClass' And LastName = 'Manager' Limit 1];
        
        system.runAs(testUser)
        {
            ApexPages.currentPage().getParameters().put('Id',String.valueOf(UserInfo.getUserId()));
     	
       		Id id = UserInfo.getUserId();
    		String deskNumber = '1234';
            String title = 'Senior Exec';
      		String businessArea = 'Tech';
       		String manager = 'TestClass Manager';
            
        	//Test Save functionality
       		EditMyDetailsController.save(id, deskNumber, title, businessArea, manager);   
            
	   		User u = [Select Id, Title, Desk_Number__c, BusinessArea__c From User Where Id =: UserInfo.getUserId()];                      

       		system.assertEquals(u.Desk_Number__c, deskNumber);
        	system.assertEquals(u.Title, title);
       		system.assertEquals(u.BusinessArea__c, businessArea);
	            
      		//Test Cancel functionality
        	PageReference cancelResult = EditMyDetailsController.cancel();
        
      		system.assertNotEquals(cancelResult, null); 
        }
       
        test.stopTest();		
	}
}