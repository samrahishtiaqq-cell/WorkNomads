/**
 Comprehensive test class for Service Request functionality
 */
@isTest
private class ServiceRequestTest {
    
    /// Setup test data

    @TestSetup
    static void setupTestData() {
        // Create test Service Requests
        List<Service_Request__c> testRequests = new List<Service_Request__c>();
        
        for (Integer i = 0; i < 5; i++) {
            testRequests.add(new Service_Request__c(
                Customer_Email__c = 'test' + i + '@example.com',
                Description__c = 'Test Description ' + i,
                Priority__c = 'Medium',
                Status__c = 'New'
            ));
        }
        
        insert testRequests;
    }
    
    // ==================== ServiceRequestService Tests ====================
    
    //Test successful creation of Service Requests

    @isTest
    static void testServiceCreateRequests_Success() {
        List<ServiceRequestService.ServiceRequestInput> inputs = new List<ServiceRequestService.ServiceRequestInput>();
        inputs.add(new ServiceRequestService.ServiceRequestInput(
            'customer1@test.com',
            'Need assistance with my account',
            'High'
        ));
        inputs.add(new ServiceRequestService.ServiceRequestInput(
            'customer2@test.com',
            'Product inquiry',
            'Low'
        ));
        
        Test.startTest();
        List<Service_Request__c> results = ServiceRequestService.createServiceRequests(inputs);
        Test.stopTest();
        
        System.assertEquals(2, results.size(), 'Should create 2 service requests');
       
    }
    
    //Test bulk creation

    @isTest
    static void testServiceCreateRequests_Bulk() {
        List<ServiceRequestService.ServiceRequestInput> inputs = new List<ServiceRequestService.ServiceRequestInput>();
        
        for (Integer i = 0; i < 200; i++) {
            inputs.add(new ServiceRequestService.ServiceRequestInput(
                'bulk' + i + '@test.com',
                'Bulk description ' + i,
                'Medium'
            ));
        }
        
        Test.startTest();
        List<Service_Request__c> results = ServiceRequestService.createServiceRequests(inputs);
        Test.stopTest();
        
        System.assertEquals(200, results.size(), 'Should create 200 service requests');
    }
    
    //Test validation - invalid email
    @isTest
    static void testServiceValidation_InvalidEmail() {
        List<ServiceRequestService.ServiceRequestInput> inputs = new List<ServiceRequestService.ServiceRequestInput>();
        inputs.add(new ServiceRequestService.ServiceRequestInput(
            'invalid-email',
            'Test description',
            'High'
        ));
        
        Test.startTest();
        try {
            ServiceRequestService.createServiceRequests(inputs);
            System.assert(false, 'Should throw exception for invalid email');
        } catch (ServiceRequestService.ServiceRequestException e) {
            System.assert(e.getMessage().contains('Email format is invalid'));
        }
        Test.stopTest();
    }
    
    // Test validation - missing fields
    @isTest
    static void testServiceValidation_MissingFields() {
        List<ServiceRequestService.ServiceRequestInput> inputs = new List<ServiceRequestService.ServiceRequestInput>();
        inputs.add(new ServiceRequestService.ServiceRequestInput('', 'Description', 'High'));
        
        Test.startTest();
        try {
            ServiceRequestService.createServiceRequests(inputs);
            System.assert(false, 'Should throw exception for missing email');
        } catch (ServiceRequestService.ServiceRequestException e) {
            System.assert(e.getMessage().contains('Email is required'));
        }
        Test.stopTest();
    }
    
    //Test resolving Service Requests
    @isTest
    static void testServiceResolveRequests_Success() {
        List<Service_Request__c> testRequests = [SELECT Id FROM Service_Request__c LIMIT 3];
        
        Set<Id> requestIds = new Set<Id>();
        Map<Id, String> resolutionNotes = new Map<Id, String>();
        
        for (Service_Request__c sr : testRequests) {
            requestIds.add(sr.Id);
            resolutionNotes.put(sr.Id, 'Resolved: ' + sr.Id);
        }
        
        Test.startTest();
        List<Service_Request__c> results = ServiceRequestService.resolveServiceRequests(
            requestIds, 
            resolutionNotes
        );
        Test.stopTest();
        
        System.assertEquals(3, results.size(), 'Should update 3 records');
        
        for (Service_Request__c sr : results) {
            System.assertEquals('Resolved', sr.Status__c, 'Status should be Resolved');
            System.assertNotEquals(null, sr.Resolution_Notes__c, 'Resolution notes should be set');
        }
    }
   
    
    //Test getting recent Service Requests

    @isTest
    static void testServiceGetRecent() {
        Test.startTest();
        List<Service_Request__c> results = ServiceRequestService.getRecentServiceRequests(5);
        Test.stopTest();
        
        System.assertNotEquals(null, results, 'Should return results');
        System.assert(results.size() <= 5, 'Should return max 5 records');
        System.assert(results.size() > 0, 'Should return at least one record');
    }
    
    // ==================== ServiceRequestController Tests ====================
    
    //Test controller create method - success

    @isTest
    static void testControllerCreate_Success() {
        Test.startTest();
        Id recordId = ServiceRequestController.createServiceRequest(
            'controller@test.com',
            'Controller test description',
            'High'
        );
        Test.stopTest();
        
        System.assertNotEquals(null, recordId, 'Should return record ID');
        
        Service_Request__c createdRecord = [
            SELECT Id, Customer_Email__c, Description__c, Priority__c, Status__c
            FROM Service_Request__c
            WHERE Id = :recordId
        ];
        
        System.assertEquals('controller@test.com', createdRecord.Customer_Email__c);
        System.assertEquals('Controller test description', createdRecord.Description__c);
        System.assertEquals('High', createdRecord.Priority__c);
        System.assertEquals('New', createdRecord.Status__c);
    }
    
    /**
     * Test controller create method - validation error
     */
    @isTest
    static void testControllerCreate_ValidationError() {
        Test.startTest();
        try {
            ServiceRequestController.createServiceRequest(
                'invalid-email',
                'Test description',
                'High'
            );
            System.assert(false, 'Should throw AuraHandledException');
        } catch (AuraHandledException e) {
            System.assertNotEquals(null, e.getMessage(), 'Error message should not be null');
            
        }
        Test.stopTest();
    }
    
   
    @isTest
    static void testControllerGetRecent_Success() {
        Test.startTest();
        List<Service_Request__c> results = ServiceRequestController.getRecentServiceRequests(3);
        Test.stopTest();
        
        System.assertNotEquals(null, results, 'Should return results');
        System.assert(results.size() <= 3, 'Should return max 3 records');
    }
    
    
  
   
    
   //Test service validation - missing description

    @isTest
    static void testServiceValidation_MissingDescription() {
        List<ServiceRequestService.ServiceRequestInput> inputs = new List<ServiceRequestService.ServiceRequestInput>();
        inputs.add(new ServiceRequestService.ServiceRequestInput(
            'test@example.com',
            '',
            'High'
        ));
        
        Test.startTest();
        try {
            ServiceRequestService.createServiceRequests(inputs);
            System.assert(false, 'Should throw exception for missing description');
        } catch (ServiceRequestService.ServiceRequestException e) {
            System.assert(e.getMessage().contains('Description is required'));
        }
        Test.stopTest();
    }
    
    //Test service validation - missing priority

    @isTest
    static void testServiceValidation_MissingPriority() {
        List<ServiceRequestService.ServiceRequestInput> inputs = new List<ServiceRequestService.ServiceRequestInput>();
        inputs.add(new ServiceRequestService.ServiceRequestInput(
            'test@example.com',
            'Test description',
            ''
        ));
        
        Test.startTest();
        try {
            ServiceRequestService.createServiceRequests(inputs);
            System.assert(false, 'Should throw exception for missing priority');
        } catch (ServiceRequestService.ServiceRequestException e) {
            System.assert(e.getMessage().contains('Priority is required'));
        }
        Test.stopTest();
    }
    
    
    @isTest
    static void testServiceResolve_EmptyIds() {
        Set<Id> emptyIds = new Set<Id>();
        Map<Id, String> notes = new Map<Id, String>();
        
        Test.startTest();
        try {
            ServiceRequestService.resolveServiceRequests(emptyIds, notes);
            System.assert(false, 'Should throw exception for empty IDs');
        } catch (ServiceRequestService.ServiceRequestException e) {
            System.assertNotEquals(null, e.getMessage());
        }
        Test.stopTest();
    }
    
   
   
    
    //Test controller create with null values

    @isTest
    static void testControllerCreate_NullValues() {
        Test.startTest();
        try {
            ServiceRequestController.createServiceRequest(null, null, null);
            System.assert(false, 'Should throw AuraHandledException');
        } catch (AuraHandledException e) {
            System.assertNotEquals(null, e.getMessage());
        }
        Test.stopTest();
    }
    
    
}