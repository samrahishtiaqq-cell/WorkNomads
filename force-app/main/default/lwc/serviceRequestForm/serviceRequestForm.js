import { LightningElement, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createServiceRequest from '@salesforce/apex/ServiceRequestController.createServiceRequest';
import getRecentServiceRequests from '@salesforce/apex/ServiceRequestController.getRecentServiceRequests';

export default class ServiceRequestForm extends NavigationMixin(LightningElement) {
    // Form fields
    customerEmail = '';
    description = '';
    priority = '';
    
    // State management
    isLoading = false;
    showSuccess = false;
    createdRecordId = '';
    errorMessage = '';
    
    // Recent requests
    recentRequests = [];
    recentRequestsError = '';
    showRecentRequests = true;
    
    // Priority options for combobox
    priorityOptions = [
        { label: 'Low', value: 'Low' },
        { label: 'Medium', value: 'Medium' },
        { label: 'High', value: 'High' }
    ];
    
    /**
     * Wire method to fetch recent service requests
     */
    @wire(getRecentServiceRequests, { recordLimit: 5 })
    wiredRecentRequests({ error, data }) {
        if (data) {
            this.recentRequests = data;
            this.recentRequestsError = '';
        } else if (error) {
            this.recentRequestsError = error?.body?.message || error?.message || 'Error loading recent requests';
            this.recentRequests = [];
        }
    }
    
    /**
     * Computed property to check if there are recent requests
     */
    get hasRecentRequests() {
        return this.recentRequests && this.recentRequests.length > 0;
    }
    
    /**
     * Handle email input change
     */
    handleEmailChange(event) {
        this.customerEmail = event.target.value;
        this.clearError();
    }
    
    /**
     * Handle description input change
     */
    handleDescriptionChange(event) {
        this.description = event.target.value;
        this.clearError();
    }
    
    /**
     * Handle priority selection change
     */
    handlePriorityChange(event) {
        this.priority = event.target.value;
        this.clearError();
    }
    
    /**
     * Validate form inputs - simple check on the values
     */
    validateForm() {
        // Simple validation - check if all required fields have values
        const hasEmail = this.customerEmail && this.customerEmail.trim().length > 0;
        const hasDescription = this.description && this.description.trim().length > 0;
        const hasPriority = this.priority && this.priority.trim().length > 0;
        
        // Basic email format check
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        const isEmailValid = hasEmail && emailRegex.test(this.customerEmail);
        
        console.log('Validation check:', {
            hasEmail,
            hasDescription,
            hasPriority,
            isEmailValid
        });
        
        return isEmailValid && hasDescription && hasPriority;
    }
    
    /**
     * Handle form submission
     */
    async handleSubmit() {
        // Clear previous error
        this.clearError();
        
        // Validate form
        if (!this.validateForm()) {
            this.errorMessage = 'Please fill in all required fields correctly.';
            
            // Show validation error toast
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Validation Error',
                    message: 'Please fill in all required fields correctly (Email, Description, Priority).',
                    variant: 'warning',
                    mode: 'dismissable'
                })
            );
            return;
        }
        
        // Set loading state
        this.isLoading = true;
        
        try {
            // Call Apex method to create service request
            const recordId = await createServiceRequest({
                customerEmail: this.customerEmail,
                description: this.description,
                priority: this.priority
            });
            
            // Handle success
            this.createdRecordId = recordId;
            this.showSuccess = true;
            
            // Show success toast with record ID
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Service Request created successfully! Record ID: ' + recordId,
                    variant: 'success',
                    mode: 'dismissable'
                })
            );
            
        } catch (error) {
            // Log the full error for debugging
            console.error('Full error object:', JSON.stringify(error));
            console.error('Error details:', error);
            
            // Handle error - simple approach
            let errorMessage = 'Unknown error occurred';
            
            if (error && error.body && error.body.message) {
                errorMessage = error.body.message;
            } else if (error && error.message) {
                errorMessage = error.message;
            } else if (typeof error === 'string') {
                errorMessage = error;
            }
            
            this.errorMessage = errorMessage;
            
            // Show error toast
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: errorMessage,
                    variant: 'error',
                    mode: 'sticky'
                })
            );
        } finally {
            // Clear loading state
            this.isLoading = false;
        }
    }
    
    /**
     * Clear form and reset to initial state
     */
    handleClear() {
        this.customerEmail = '';
        this.description = '';
        this.priority = '';
        this.clearError();
    }
    
    /**
     * Clear error message
     */
    clearError() {
        this.errorMessage = '';
    }
    
    /**
     * Handle "View Record" button click
     */
    handleViewRecord() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.createdRecordId,
                objectApiName: 'Service_Request__c',
                actionName: 'view'
            }
        });
    }
    
    /**
     * Handle "Create Another" button click
     */
    handleCreateAnother() {
        this.showSuccess = false;
        this.createdRecordId = '';
        this.handleClear();
    }
    
    /**
     * Handle navigation to a record from recent requests table
     */
    handleNavigateToRecord(event) {
        event.preventDefault();
        const recordId = event.target.dataset.id;
        
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                objectApiName: 'Service_Request__c',
                actionName: 'view'
            }
        });
    }
    
}

