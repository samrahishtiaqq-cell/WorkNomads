/**
 * @description Service class for Service Request operations
 */
public with sharing class ServiceRequestService {
    
 
    public class ServiceRequestException extends Exception {}
    
   // Wrapper class for Service Request creation input
    public class ServiceRequestInput {
        public String customerEmail;
        public String description;
        public String priority;
        public String status;
        
        public ServiceRequestInput(String email, String description, String priority) {
            this.customerEmail = email;
            this.description = description;
            this.priority = priority;
            this.status = 'New'; // Default status
        }
    }
    
     //Creates Service Request records with validation
    
    public static List<Service_Request__c> createServiceRequests(List<ServiceRequestInput> inputs) {
        if (inputs == null || inputs.isEmpty()) {
            throw new ServiceRequestException('Input list cannot be null or empty');
        }
        
        List<Service_Request__c> serviceRequests = new List<Service_Request__c>();
        
        // Build Service Request records with validation
        for (ServiceRequestInput input : inputs) {
            validateInput(input);
            
            Service_Request__c sr = new Service_Request__c(
                Customer_Email__c = input.customerEmail,
                Description__c = input.description,
                Priority__c = input.priority,
                Status__c = input.status != null ? input.status : 'New'
            );
            
            serviceRequests.add(sr);
        }
        
        // Bulk insert
        try {
            insert serviceRequests;
        } catch (DmlException e) {
            throw new ServiceRequestException('Failed to create Service Requests: ' + e.getMessage());
        }
        
        return serviceRequests;
    }
    
     // Updates Service Request status to Resolved with resolution notes
    
    public static List<Service_Request__c> resolveServiceRequests(
        Set<Id> serviceRequestIds, 
        Map<Id, String> resolutionNotesMap
    ) {
        if (serviceRequestIds == null || serviceRequestIds.isEmpty()) {
            throw new ServiceRequestException('Service Request IDs cannot be null or empty');
        }
        
        // Query existing records
        List<Service_Request__c> serviceRequests = [
            SELECT Id, Status__c, Resolution_Notes__c
            FROM Service_Request__c
            WHERE Id IN :serviceRequestIds
            WITH SECURITY_ENFORCED
        ];
        
        if (serviceRequests.isEmpty()) {
            throw new ServiceRequestException('No Service Requests found for the provided IDs');
        }
        
        // Update records
        for (Service_Request__c sr : serviceRequests) {
            sr.Status__c = 'Resolved';
            
            // Add resolution notes if provided
            if (resolutionNotesMap != null && resolutionNotesMap.containsKey(sr.Id)) {
                String notes = resolutionNotesMap.get(sr.Id);
                if (String.isNotBlank(notes)) {
                    sr.Resolution_Notes__c = notes;
                }
            }
        }
        
        // Bulk update
        try {
            update serviceRequests;
        } catch (DmlException e) {
            throw new ServiceRequestException('Failed to resolve Service Requests: ' + e.getMessage());
        }
        
        return serviceRequests;
    }
    
      // Retrieves recent Service Requests
    
    public static List<Service_Request__c> getRecentServiceRequests(Integer recordLimit) {
        Integer limitCount = recordLimit != null && recordLimit > 0 ? recordLimit : 5;
        
        return [
            SELECT Id, Name, Customer_Email__c, Description__c, Priority__c, 
                   Status__c, Resolution_Notes__c, CreatedDate
            FROM Service_Request__c
            WITH SECURITY_ENFORCED
            ORDER BY CreatedDate DESC
            LIMIT :limitCount
        ];
    }
    
    //Validates Service Request input data
    
    private static void validateInput(ServiceRequestInput input) {
        List<String> errors = new List<String>();
        
        // Validate email
        if (String.isBlank(input.customerEmail)) {
            errors.add('Customer Email is required');
        } else if (!isValidEmail(input.customerEmail)) {
            errors.add('Customer Email format is invalid');
        }
        
        // Validate description
        if (String.isBlank(input.description)) {
            errors.add('Description is required');
        }
        
        // Priority validation - only check if blank (picklist handles valid values)
        if (String.isBlank(input.priority)) {
            errors.add('Priority is required');
        }
        
        // Throw exception if any validation errors
        if (!errors.isEmpty()) {
            throw new ServiceRequestException('Validation failed: ' + String.join(errors, '; '));
        }
    }
    
   
    private static Boolean isValidEmail(String email) {
        String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$';
        Pattern pattern = Pattern.compile(emailRegex);
        Matcher matcher = pattern.matcher(email);
        return matcher.matches();
    }
}