# Acme Services - Service Request Management System

A complete Salesforce solution for managing customer service requests with Lightning Web Components and Apex backend.

##  Salesforce DX Project Structure

This is a complete Salesforce DX project with the following configuration files:

- **`sfdx-project.json`** - Salesforce DX project configuration file (required)
- **`.forceignore`** - Specifies files to ignore during deployment
- **`force-app/`** - Contains all Salesforce metadata (the main deployment package)
- **`README.md`** - This file with complete instructions

## What's Included

This package contains:

- **Custom Object**: `Service_Request__c` with fields for customer email, status, description, resolution notes and priority
- **Lightning Web Component**: Interactive form for creating and viewing service requests
- **Apex Classes**: 
  - `ServiceRequestService` - Core business logic
  - `ServiceRequestController` - LWC integration layer
  - `ServiceRequestTest` - Comprehensive test coverage 
- **Custom App**: "Acme Services" with dedicated tabs
- **Permission Set**: `Acme_Services_User` for access management
- **Page Layouts & Tabs**: Pre-configured UI components

## Prerequisites

Before you begin, ensure you have:

1. **Salesforce CLI** installed ([Installation Guide](https://developer.salesforce.com/tools/sfdxcli))
2. **A Salesforce Org** (Developer Edition, Sandbox, or Scratch Org)
3. **VS Code** with Salesforce Extensions (recommended)

Verify your Salesforce CLI installation:
```bash
sf --version
```

## Deployment Instructions

### Step 1: Extract the Package

Extract the package to a directory:

```bash
unzip acme-services.zip -d acme-services
cd acme-services
```

**Note**: The package already includes `sfdx-project.json` and `.forceignore` files. If you're creating a new Salesforce DX project from scratch, use:
```bash
sf project generate --name "Acme Services"
```

### Step 2: Authenticate to Your Salesforce Org

```bash
sf org login web --alias my-org
```

This will open a browser window for you to log in to your Salesforce org.

### Step 3: Deploy the Metadata

Deploy all components to your org:

```bash
sf project deploy start --source-dir force-app/main/default --wait 10
```

Wait for the deployment to complete. You should see a success message.

### Step 4: Assign Permission Set

Assign the permission set to your user to access the app:

```bash
sf org assign permset --name Acme_Services_User
```

If you get a "Duplicate PermissionSetAssignment" error, the permission set is already assigned - you can ignore this.



## Accessing the Application

### Via App Launcher

1. Log in to your Salesforce org
2. Click the **App Launcher** (9 dots) in the top-left corner
3. Search for **"Acme Services"**
4. Click on the app to open it

### Available Tabs

The app contains two tabs:

1. **Service Request Form** - Create new service requests and view recent ones
2. **Service Requests** - View all service request records

##  Using the Service Request Form

### Creating a New Service Request

1. Navigate to the **Service Request Form** tab
2. Fill in the required fields:
   - **Customer Email**: Valid email address (required)
   - **Description**: Detailed description of the issue (required)
   - **Priority**: Select Low, Medium, or High (required)
3. Click **Submit**
4. You'll see a success message with the created Record ID

### Viewing Recent Service Requests

The form automatically displays the 5 most recently created service requests below the form, showing:
- Record Name
- Status
- Priority
- Customer Email
