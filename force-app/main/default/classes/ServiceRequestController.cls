/**
 * Exposes methods for LWC to interact with Service Request functionality
 */
public with sharing class ServiceRequestController {
    
    //Creates a new Service Request record

    @AuraEnabled
    public static Id createServiceRequest(String customerEmail, String description, String priority) {
        try {
            // Create input wrapper
            ServiceRequestService.ServiceRequestInput input = 
                new ServiceRequestService.ServiceRequestInput(customerEmail, description, priority);
            
            // Call service to create request
            List<Service_Request__c> createdRequests = 
                ServiceRequestService.createServiceRequests(new List<ServiceRequestService.ServiceRequestInput>{input});
            
            // Return the ID of the created record
            if (!createdRequests.isEmpty()) {
                return createdRequests[0].Id;
            }
            
            throw new AuraHandledException('Failed to create Service Request');
            
        } catch (ServiceRequestService.ServiceRequestException e) {
            throw new AuraHandledException(e.getMessage());
        } 
    }
    
    //description Retrieves recent Service Requests
    
    @AuraEnabled(cacheable=true)
    public static List<Service_Request__c> getRecentServiceRequests(Integer recordLimit) {
        try {
            return ServiceRequestService.getRecentServiceRequests(recordLimit);
        } catch (Exception e) {
            throw new AuraHandledException('Failed to retrieve Service Requests: ' + e.getMessage());
        }
    }
    
    
}