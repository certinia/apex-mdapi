/**
 * Copyright (c) 2012, FinancialForce.com, inc
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification, 
 *   are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice, 
 *      this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice, 
 *      this list of conditions and the following disclaimer in the documentation 
 *      and/or other materials provided with the distribution.
 * - Neither the name of the FinancialForce.com, inc nor the names of its contributors 
 *      may be used to endorse or promote products derived from this software without 
 *      specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
 *  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES 
 *  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL 
 *  THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
 *  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 *  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 *  OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**/

/**
 * This file demonstrates how to call the Salesforce Metadata API from Apex 
 *   for warnings, limits and further todos of this approach please review the readme 
 *   at https://github.com/financialforcedev/apex-mdapi for more information
 **/
 
public with sharing class MetadataServiceExamples 
{
	public static void createObject()
	{
		MetadataService.MetadataPort service = createService();
		MetadataService.CustomObject customObject = new MetadataService.CustomObject();
		customObject.fullName = 'Test__c';
		customObject.label = 'Test';
		customObject.pluralLabel = 'Tests';
		customObject.nameField = new MetadataService.CustomField();
		customObject.nameField.type_x = 'Text';
		customObject.nameField.label = 'Test Record';
		customObject.deploymentStatus = 'Deployed';
		customObject.sharingModel = 'ReadWrite';
		List<MetadataService.SaveResult> results = 		
			service.createMetadata(
				new MetadataService.Metadata[] { customObject });		
		handleSaveResults(results[0]);
	}

	public static void upsertObject()
	{
		MetadataService.MetadataPort service = createService();
		MetadataService.CustomObject customObject = new MetadataService.CustomObject();
		customObject.fullName = 'Test__c';
		customObject.label = 'Test';
		customObject.pluralLabel = 'Tests Upsert';
		customObject.nameField = new MetadataService.CustomField();
		customObject.nameField.type_x = 'Text';
		customObject.nameField.label = 'Test Record Upsert';
		customObject.deploymentStatus = 'Deployed';
		customObject.sharingModel = 'ReadWrite';
		List<MetadataService.UpsertResult> results = 		
			service.upsertMetadata(
				new MetadataService.Metadata[] { customObject });		
		handleUpsertResults(results[0]);
	}

	public static void createLookupField()
	{
		MetadataService.MetadataPort service = createService();		
		MetadataService.CustomField customField = new MetadataService.CustomField();
		customField.fullName = 'Test__c.LookupField__c';
		customField.label = 'Lookup Field';
		customField.type_x = 'Lookup';
		customField.relationshipLabel = 'Tests';
		customField.relationshipName = 'Tests';
		customField.referenceTo = 'Test__c';
		List<MetadataService.SaveResult> results = 		
			service.createMetadata(
				new MetadataService.Metadata[] { customField });		
		handleSaveResults(results[0]);
	}

	public static void createExternalField()
	{
		MetadataService.MetadataPort service = createService();		
		MetadataService.CustomField customField = new MetadataService.CustomField();
		customField.fullName = 'Test__c.ExternalField__c';
		customField.label = 'External Field';
		customField.type_x = 'Text';
		customField.length = 42;
		customField.externalId = true;		
		List<MetadataService.SaveResult> results = 		
			service.createMetadata(
				new MetadataService.Metadata[] { customField });		
		handleSaveResults(results[0]);
	}
		
	public static void createLongTextAreaField()
	{
		MetadataService.MetadataPort service = createService();		
		MetadataService.CustomField customField = new MetadataService.CustomField();
		customField.fullName = 'Test__c.LongTextAreaField__c';
		customField.label = 'Long Text Area Field';
		customField.type_x = 'LongTextArea';
		customField.length = 32000;
		customField.visibleLines = 3;
		List<MetadataService.SaveResult> results = 		
			service.createMetadata(
				new MetadataService.Metadata[] { customField });		
		handleSaveResults(results[0]);
	}
	
	public static void createField()
	{
		MetadataService.MetadataPort service = createService();		
		MetadataService.CustomField customField = new MetadataService.CustomField();
		customField.fullName = 'Test__c.TestField__c';
		customField.label = 'Test Field';
		customField.type_x = 'Text';
		customField.length = 42;
		List<MetadataService.SaveResult> results = 		
			service.createMetadata(
				new MetadataService.Metadata[] { customField });				
		handleSaveResults(results[0]);
	}
	
	public static void deleteField()
	{
		MetadataService.MetadataPort service = createService();		
		List<MetadataService.DeleteResult> results = 		
			service.deleteMetadata(
				'CustomField', new String[] { 'Test__c.TestField__c' });		
		handleDeleteResults(results[0]);
	}
	
	public static void updateField()
	{
	    MetadataService.MetadataPort service = createService(); 
	    MetadataService.CustomField customField = new MetadataService.CustomField();
	    customField.fullName = 'Test__c.TestField__c';
	    customField.label='New Test Field Label';
	    customField.type_x = 'Text'; 
	    customField.length = 52;
		List<MetadataService.SaveResult> results = 		
			service.updateMetadata(
				new MetadataService.Metadata[] { customField });				
		handleSaveResults(results[0]);	    
	}

    public static void updateFieldLevelSecurity() 
    {
        MetadataService.MetadataPort service = createService();
        MetadataService.Profile admin = (MetadataService.Profile) service.readMetadata('Profile', new String[] { 'Admin' }).getRecords()[0];
        MetadataService.ProfileFieldLevelSecurity fieldSec = new MetadataService.ProfileFieldLevelSecurity();
        fieldSec.field='Test__c.TestField__c';
        fieldSec.editable=true;
        admin.fieldPermissions  = new MetadataService.ProfileFieldLevelSecurity[] {fieldSec} ;
		List<MetadataService.SaveResult> results = 		
			service.updateMetadata(
				new MetadataService.Metadata[] { admin });				
		handleSaveResults(results[0]);	    
    }

	public static void createPage()
	{
		MetadataService.MetadataPort service = createService();		
		MetadataService.ApexPage apexPage = new MetadataService.ApexPage();
		apexPage.apiVersion = 25;
		apexPage.fullName = 'test';
		apexPage.label = 'Test Page';
		apexPage.content = EncodingUtil.base64Encode(Blob.valueOf('<apex:page/>'));
		List<MetadataService.SaveResult> results = 		
			service.createMetadata(
				new MetadataService.Metadata[] { apexPage });				
		handleSaveResults(results[0]);
	}

	public static void createStaticResource()
	{
		MetadataService.MetadataPort service = createService();		
		MetadataService.StaticResource staticResource = new MetadataService.StaticResource();
		staticResource.fullName = 'test';
		staticResource.contentType = 'text';
		staticResource.cacheControl = 'public';
		staticResource.content = EncodingUtil.base64Encode(Blob.valueOf('Static stuff'));
		List<MetadataService.SaveResult> results = 		
			service.createMetadata(
				new MetadataService.Metadata[] { staticResource });				
		handleSaveResults(results[0]);
	}

	public static void updateStaticResource()
	{
		MetadataService.MetadataPort service = createService();		
		MetadataService.StaticResource staticResource = new MetadataService.StaticResource();
		staticResource.fullName = 'test';
		staticResource.contentType = 'text';
		staticResource.cacheControl = 'public';
		staticResource.content = EncodingUtil.base64Encode(Blob.valueOf('Static stuff Changed'));
		List<MetadataService.SaveResult> results = 		
			service.updateMetadata(
				new MetadataService.Metadata[] { staticResource });				
		handleSaveResults(results[0]);	    
	}
	
	public static void deleteStaticResource()
	{
		MetadataService.MetadataPort service = createService();		
		List<MetadataService.DeleteResult> results = 		
			service.deleteMetadata(
				'StaticResource', new String[] { 'test' });
		handleDeleteResults(results[0]);
	}
		
	public static void createWebLink()
	{
		MetadataService.MetadataPort service = createService();		
		MetadataService.WebLink webLink = new MetadataService.WebLink();
		webLink.fullName = 'Test__c.googleButton';
		webLink.availability = 'online';
		webLink.displayType = 'link';
		webLink.encodingKey = 'UTF-8';
		webLink.hasMenubar = false;
		webLink.hasScrollbars = true;
		webLink.hasToolbar = false;
		webLink.height = 600;
		webLink.isResizable = true;
		webLink.linkType = 'url';
		webLink.masterLabel = 'google';
		webLink.openType = 'newWindow';
		webLink.position = 'none';
		webLink.protected_x = false;
		webLink.showsLocation = false;
		webLink.showsStatus = false;
		webLink.url = 'http://www.google.com';
		webLink.width = 600;		
		List<MetadataService.SaveResult> results = 		
			service.createMetadata(
				new MetadataService.Metadata[] { webLink });		
		handleSaveResults(results[0]);
	}
	
	public static void listMetadata()
	{
		MetadataService.MetadataPort service = createService();		
		List<MetadataService.ListMetadataQuery> queries = new List<MetadataService.ListMetadataQuery>();		
		MetadataService.ListMetadataQuery queryWorkflow = new MetadataService.ListMetadataQuery();
		queryWorkflow.type_x = 'Workflow';
		queries.add(queryWorkflow);		
		MetadataService.ListMetadataQuery queryValidationRule = new MetadataService.ListMetadataQuery();
		queryValidationRule.type_x = 'ValidationRule';
		queries.add(queryValidationRule);		
		MetadataService.ListMetadataQuery queryCustomField = new MetadataService.ListMetadataQuery();
		queryCustomField.type_x = 'CustomField';
		queries.add(queryCustomField);		
		MetadataService.FileProperties[] fileProperties = service.listMetadata(queries, 25);
		for(MetadataService.FileProperties fileProperty : fileProperties)
			System.debug(fileProperty.fullName);
	}
	
	public static void createPicklistField()
	{
	    MetadataService.MetadataPort service = createService();     
	    MetadataService.CustomField customField = new MetadataService.CustomField();
	    customField.fullName = 'Lead.picklist__c';
	    customField.label = 'picklist';
	    customField.type_x = 'Picklist';
	    metadataservice.Picklist pt = new metadataservice.Picklist();
	    pt.sorted= false;
	    metadataservice.PicklistValue one = new metadataservice.PicklistValue();
	    one.fullName= 'first';
	    one.default_x=false ;
	    pt.picklistValues = new List<MetadataService.PicklistValue>{one};
	    customField.picklist = pt ;
		List<MetadataService.SaveResult> results = 		
			service.createMetadata(
				new MetadataService.Metadata[] { customField });
		handleSaveResults(results[0]);
	}	

	public static void updatePicklistField()
	{
	    MetadataService.MetadataPort service = createService();     
	    MetadataService.CustomField customField = new MetadataService.CustomField();
	    customField.fullName = 'Lead.picklist__c';
	    customField.label = 'picklist';
	    customField.type_x = 'Picklist';
	    metadataservice.Picklist pt = new metadataservice.Picklist();
	    pt.sorted= false;
	    metadataservice.PicklistValue two = new metadataservice.PicklistValue();
	    two.fullName= 'second';
	    two.default_x=false ;
	    metadataservice.PicklistValue three = new metadataservice.PicklistValue();
	    three.fullName= 'third';
	    three.default_x=false ;
	    pt.picklistValues = new list<metadataservice.PicklistValue>{two,three};
	    customField.picklist = pt ;
	    MetadataService.UpdateMetadata ut = new MetadataService.UpdateMetadata();
	    ut.currentName='Lead.picklist__c';
	    ut.metadata= customField;	
		List<MetadataService.SaveResult> results = 		
			service.updateMetadata(
				new MetadataService.Metadata[] { customField });
		handleSaveResults(results[0]);	    
	}
	
	public static void createAddressSettings()
	{
	    MetadataService.MetadataPort service = createService();
	    MetadataService.AddressSettings addressSettings = new MetadataService.AddressSettings();
	    addressSettings.fullName = 'Address';	    
	    addressSettings.countriesAndStates = new MetadataService.CountriesAndStates();
		MetadataService.Country us = new MetadataService.Country();
		us.active = true;
		us.integrationValue = 'United States';
		us.isoCode = 'US';
		us.label = 'United States';
		MetadataService.State stateAL = new MetadataService.State();
		stateAL.active = true;
		stateAL.integrationValue = 'Alabama';
		stateAL.isoCode = 'AL';
		stateAL.label = 'Alabama';		
		MetadataService.State stateAK = new MetadataService.State();
		stateAK.active = true;
		stateAK.integrationValue = 'Alaska';
		stateAK.isoCode = 'AK';
		stateAK.label = 'Alaska';		
		us.states = new List<MetadataService.State> { stateAL, stateAK };
		addressSettings.countriesAndStates.countries = new List<MetadataService.Country> { us };
		List<MetadataService.SaveResult> results = 		
			service.createMetadata(
				new MetadataService.Metadata[] { addressSettings });
		handleSaveResults(results[0]);
	}
	
	public static void updateCaseSettings()
	{
	    MetadataService.MetadataPort service = createService();
	    MetadataService.CaseSettings caseSettings = new MetadataService.CaseSettings();
	    caseSettings.fullName = 'Case';
	    caseSettings.notifyOwnerOnCaseComment = true;
		List<MetadataService.SaveResult> results = 		
			service.updateMetadata(
				new MetadataService.Metadata[] { caseSettings });
		handleSaveResults(results[0]);	    
	}

	public static void dynamicCreation(String objectName)
	{
		// Define Metadata item to create a Custom Object
		MetadataService.CustomObject customObject = new MetadataService.CustomObject();
		customObject.fullName = objectName + '__c';
		customObject.label = objectName;
		customObject.pluralLabel = objectName+'s';
		customObject.nameField = new MetadataService.CustomField();
		customObject.nameField.type_x = 'Text';
		customObject.nameField.label = 'Test Record';
		customObject.deploymentStatus = 'Deployed';
		customObject.sharingModel = 'ReadWrite';
		
		// Define Metadata item to create a Custom Field on the above object
		MetadataService.CustomField customField1 = new MetadataService.CustomField();
		customField1.fullName = objectName+'__c.TestField1__c';
		customField1.label = 'Test Field 1';
		customField1.type_x = 'Text';
		customField1.length = 42;

		// Define Metadata item to create a Custom Field on the above object
		MetadataService.CustomField customField2 = new MetadataService.CustomField();
		customField2.fullName = objectName+'__c.TestField2__c';
		customField2.label = 'Test Field 2';
		customField2.type_x = 'Text';
		customField2.length = 42;
		
		// Define Metadata item to create a Visualforce page to display the above field
		MetadataService.ApexPage apexPage = new MetadataService.ApexPage();
		apexPage.apiVersion = 25;
		apexPage.fullName = objectName.toLowercase();
		apexPage.label = objectName + ' Page';
		apexPage.content = EncodingUtil.base64Encode(Blob.valueOf(
			'<apex:page standardController=\''+objectName+'__c\'>'+
				'{!' + objectName + '__c.TestField1__c}' +
				'{!' + objectName + '__c.TestField2__c}' + 
			'</apex:page>'));
		
		// Create components in the correct order
	    MetadataService.MetadataPort service = createService();
		List<MetadataService.SaveResult> results = 		
			service.createMetadata(
				new MetadataService.Metadata[] { customObject });		
		handleSaveResults(results[0]);				
		results = 		
			service.createMetadata(
				new MetadataService.Metadata[] { customField1, customField2 });		
		handleSaveResults(results[0]);				
		handleSaveResults(results[1]);		
		results = 		
			service.createMetadata(
				new MetadataService.Metadata[] { apexPage });		
		handleSaveResults(results[0]);				
	}
	
	public static void createRecordType()
	{
		MetadataService.RecordType recordType = new MetadataService.RecordType();
		recordType.active = true;
		recordType.fullName = 'Test__c.RecordTypeA';
		recordType.label = 'Record Type A';
		recordType.businessProcess = null;
		recordType.description = 'My new record type';		
		 
	    MetadataService.MetadataPort service = createService();
		List<MetadataService.SaveResult> results = 		
			service.createMetadata(
				new MetadataService.Metadata[] { recordType });		
		handleSaveResults(results[0]);				
	}
	
	public static void deleteRecordType()
	{
		// Salesforce bug? The follow results in 'Cannot delete record type through API' 
		//   yet the docs say otherwise, http://www.salesforce.com/us/developer/docs/api_meta/Content/meta_recordtype.htm
		//   'For more information, see “Record Types Overview” in the Salesforce online help. 
		//    Use this metadata type to create, update, or delete record type definitions for a custom object.'
		MetadataService.RecordType recordType = new MetadataService.RecordType();
		recordType.active = true;
		recordType.fullName = 'Test__c.RecordTypeA';
	    MetadataService.MetadataPort service = createService();
		List<MetadataService.DeleteResult> results = 		
			service.deleteMetadata(
				'RecordType', new String[] { 'Test__c.RecordTypeA' });
		handleDeleteResults(results[0]);
	}
	
	public static void installPackages()
	{
		// Install packageA, then pacakgeB
		MetadataService.InstalledPackage installedPackageA = new MetadataService.InstalledPackage();
		installedPackageA.password = 'fred1234';
		installedPackageA.versionNumber = '1.0';
		installedPackageA.fullName = 'packagea';
		MetadataService.InstalledPackage installedPackageB = new MetadataService.InstalledPackage();
		installedPackageB.versionNumber = '1.0';
		installedPackageB.fullName = 'packageb';
				 
		// Install the packages
	    MetadataService.MetadataPort service = createService();
		List<MetadataService.SaveResult> results = 		
			service.createMetadata(
				new MetadataService.Metadata[] { installedPackageA, installedPackageB });
		handleSaveResults(results[0]);
		handleSaveResults(results[1]);		
	}
	
	public static void uninstallPackages()
	{
		// Uninstall packages
	    MetadataService.MetadataPort service = createService();
		List<MetadataService.DeleteResult> results = 		
			service.deleteMetadata(
				'InstalledPackage', new String[] { 'packagea', 'packageb' });
		handleDeleteResults(results[0]);
		handleDeleteResults(results[1]);
	}
	
	public static void createCustomSite()
	{
		MetadataService.CustomSite customSite = new MetadataService.CustomSite();
		customSite.fullName = 'MyCustomSite';
		customSite.active = true;
		customSite.allowHomePage = true;
		customSite.allowStandardIdeasPages = true;		
		customSite.active = true;
		customSite.allowHomePage = true;
		customSite.allowStandardIdeasPages = true;
		customSite.allowStandardLookups = true;
		customSite.allowStandardSearch = true;
		customSite.authorizationRequiredPage = 'Unauthorized';
		customSite.bandwidthExceededPage = 'BandwidthExceeded';
		customSite.changePasswordPage = 'ChangePassword';
		customSite.chatterAnswersForgotPasswordConfirmPage = null;
		customSite.chatterAnswersForgotPasswordPage = null;
		customSite.chatterAnswersHelpPage = null;
		customSite.chatterAnswersLoginPage = null;
		customSite.chatterAnswersRegistrationPage = null;
		customSite.favoriteIcon = null;
		customSite.fileNotFoundPage = 'FileNotFound';
		customSite.genericErrorPage = 'Exception';
		customSite.inMaintenancePage = 'InMaintenance';
		customSite.serverIsDown =  null;
		customSite.indexPage = 'UnderConstruction';
		customSite.masterLabel = 'customSite';
		customSite.portal = null;
		customSite.requireInsecurePortalAccess = false;
		customSite.siteAdmin = 'admin@mysiteorg.com';
		customSite.siteTemplate = 'SiteTemplate';
		customSite.siteType = 'Visualforce';
	    MetadataService.MetadataPort service = createService();
		List<MetadataService.SaveResult> results = 		
			service.createMetadata(
				new MetadataService.Metadata[] { customSite });
		handleSaveResults(results[0]);
	}	
	
	public static void createDetailObject()
	{
		// Define Metadata item to create a Custom Object
		MetadataService.CustomObject customObject = new MetadataService.CustomObject();
		customObject.fullName = 'TestDetail__c';
		customObject.label = 'Test Detail';
		customObject.pluralLabel = 'Test Details';
		customObject.nameField = new MetadataService.CustomField();
		customObject.nameField.type_x = 'Text';
		customObject.nameField.label = 'Test Detail Record';
		customObject.deploymentStatus = 'Deployed';
		customObject.sharingModel = 'ReadWrite';
		
		// Define Metadata item to create a Custom Formula Field on the above object
		MetadataService.CustomField customField1 = new MetadataService.CustomField();
        customField1.fullName = 'TestDetail__c.FormulaField__c';
        customField1.externalId = false;
        customField1.formula = '42';
        customField1.formulaTreatBlanksAs = 'BlankAsZero';
        customField1.label = 'Formula Field';
        customField1.precision = 18;
        customField1.required = false;
        customField1.scale = 2;
        customField1.type_x = 'Number';
        customField1.unique = false;		

		// Define Metadata item to create a Custom Field on the above object
		MetadataService.CustomField customField2 = new MetadataService.CustomField();
        customField2.fullName = 'TestDetail__c.Test__c';
        customField2.externalId = false;
        customField2.label = 'Test';
        customField2.referenceTo = 'Test__c';
        customField2.relationshipLabel = 'Test Children';
        customField2.relationshipName = 'Test_Children';
        customField2.relationshipOrder = 0;
        customField2.type_x = 'MasterDetail';
        customField2.writeRequiresMasterRead = false;
		
		// Create components in the correct order
	    MetadataService.MetadataPort service = createService();
		List<MetadataService.SaveResult> results = 		
			service.createMetadata(
				new MetadataService.Metadata[] { customObject });
		handleSaveResults(results[0]);
		results = 		
			service.createMetadata(
				new MetadataService.Metadata[] { customField1, customField2 });
		handleSaveResults(results[0]);
		handleSaveResults(results[1]);
	}	
	
	public static void createFieldSet()
	{
		MetadataService.MetadataPort service = createService();	
		
		// FieldSet 	
		MetadataService.FieldSet fieldSet = new MetadataService.FieldSet();
		fieldSet.fullName = 'Test__c.MyFieldSet';
		fieldSet.label = 'My FieldSet';
		fieldSet.description = 'Used by my VF page';
		MetadataService.FieldSetItem myAvailableField = new MetadataService.FieldSetItem();
		myAvailableField.field = 'TestField__c';
		myAvailableField.isFieldManaged = true;
		myAvailableField.isRequired = true;
		fieldSet.availableFields = new List<MetadataService.FieldSetItem>();
		fieldSet.availableFields.add(myAvailableField);
		
		// Create
		List<MetadataService.SaveResult> results = 		
			service.createMetadata(
				new MetadataService.Metadata[] { fieldSet });
		handleSaveResults(results[0]);
	}

	public static void updateFieldSet()
	{
		MetadataService.MetadataPort service = createService();
		
		// FieldSet		
		MetadataService.FieldSet fieldSet = new MetadataService.FieldSet();
		fieldSet.fullName = 'Test__c.MyFieldSet';
		fieldSet.label = 'My FieldSet';
		fieldSet.description = 'Used by my VF page';			
		MetadataService.FieldSetItem myAvailableField = new MetadataService.FieldSetItem();
		myAvailableField.field = 'TestField__c';
		myAvailableField.isFieldManaged = true;
		myAvailableField.isRequired = true;
		MetadataService.FieldSetItem myAvailableFieldNew = new MetadataService.FieldSetItem();
		myAvailableFieldNew.field = 'ExternalField__c';
		myAvailableFieldNew.isFieldManaged = true;
		myAvailableFieldNew.isRequired = true;
		fieldSet.availableFields = new List<MetadataService.FieldSetItem>();
		fieldSet.availableFields.add(myAvailableField);
		fieldSet.availableFields.add(myAvailableFieldNew);
		
		// Update
		List<MetadataService.SaveResult> results = 		
			service.updateMetadata(
				new MetadataService.Metadata[] { fieldSet });
		handleSaveResults(results[0]);	    
	}
	
	public static void addActionOverride()
	{
		MetadataService.MetadataPort service = createService();		
		MetadataService.CustomObject customObject = new MetadataService.CustomObject();
		customObject.fullName = 'Test__c';
		customObject.label = 'Test';
		customObject.pluralLabel = 'Tests';
		customObject.nameField = new MetadataService.CustomField();
		customObject.nameField.type_x = 'Text';
		customObject.nameField.label = 'Test Record';
		customObject.deploymentStatus = 'Deployed';
		customObject.sharingModel = 'ReadWrite';		
		customObject.actionOverrides = new List<MetadataService.ActionOverride>();
		customObject.actionOverrides.add(new MetadataService.ActionOverride());
		customObject.actionOverrides[0].actionName = 'Edit';
		customObject.actionOverrides[0].content = 'TestPage';
		customObject.actionOverrides[0].type_x = 'visualforce';
		customObject.actionOverrides[0].skipRecordTypeSelect = false;
		customObject.actionOverrides[0].comment = 'A comment for edit action';
		List<MetadataService.SaveResult> results = 		
			service.updateMetadata(
				new MetadataService.Metadata[] { customObject });
		handleSaveResults(results[0]);	    
	}
	
	public static void createListView()
	{
		MetadataService.MetadataPort service = createService();		
		MetadataService.ListView listView = new MetadataService.ListView();
		listView.fullName = 'Test__c.MyListView';
		listView.label = 'My List View';
		listView.filterScope = 'Everything';
		listView.columns = new List<String> { 'NAME' };
		List<MetadataService.SaveResult> results = 		
			service.createMetadata(
				new MetadataService.Metadata[] { listView });
		handleSaveResults(results[0]);		
	}
	
	public static void deleteListView()
	{
		MetadataService.MetadataPort service = createService();		
		List<MetadataService.DeleteResult> results = 		
			service.deleteMetadata(
				'ListView', new String[] { 'Test__c.MyListView' });
		handleDeleteResults(results[0]);
	}
	
	public static void listListViews()
	{
		MetadataService.MetadataPort service = createService();		
		List<MetadataService.ListMetadataQuery> queries = new List<MetadataService.ListMetadataQuery>();		
		MetadataService.ListMetadataQuery listView = new MetadataService.ListMetadataQuery();
		listView.type_x = 'ListView';
		queries.add(listView);		
		MetadataService.FileProperties[] fileProperties = service.listMetadata(queries, 25);
		for(MetadataService.FileProperties fileProperty : fileProperties)
			System.debug(fileProperty.fullName);		
	}
	
	public static void readListView()
	{
	    MetadataService.MetadataPort service = createService();     	    

	    // Read List View definition
	    MetadataService.ListView listView = 
			(MetadataService.ListView) service.readMetadata('ListView', 
				new String[] { 'Test__c.MyListView' }).getRecords()[0];
		if(listView.columns!=null)	    
			for(String column : listView.columns)
				System.debug('Column ' + column);
		if(listView.filters!=null)
			for(MetadataService.ListViewFilter filter : listView.filters)
				System.debug('Filter ' + filter.field + ' ' + filter.operation + ' ' + filter.value);
	}
	
	public static void createApprovalProcess()
	{
		MetadataService.MetadataPort service = createService();
		MetadataService.ApprovalProcess approvalProcess = new MetadataService.ApprovalProcess();
        approvalProcess.fullName = 'Test__c.TestApproval';
        approvalProcess.label = 'Test Approval';
        approvalProcess.active = false;
        approvalProcess.allowRecall = false;
        approvalProcess.showApprovalHistory = true;
        approvalProcess.recordEditability = 'AdminOnly';
        approvalProcess.finalApprovalRecordLock = false;
        approvalProcess.finalRejectionRecordLock = false;
        approvalProcess.showApprovalHistory = false;
        MetadataService.ApprovalSubmitter submitter = new MetadataService.ApprovalSubmitter();
        submitter.type_x = 'user';
        submitter.submitter = UserInfo.getUserName();
        approvalProcess.allowedSubmitters = new List<MetadataService.ApprovalSubmitter> { submitter };
		List<MetadataService.SaveResult> results = 		
			service.createMetadata(
				new MetadataService.Metadata[] { approvalProcess });
		handleSaveResults(results[0]);
	}
	
	public static void readAndUpdateLayout()
	{
		MetadataService.MetadataPort service = createService();
		
		// Create Button
		MetadataService.WebLink webLink = new MetadataService.WebLink();
		webLink.fullName = 'Test__c.googleButton';
		webLink.availability = 'online';
		webLink.displayType = 'button';
		webLink.encodingKey = 'UTF-8';
		webLink.hasMenubar = false;
		webLink.hasScrollbars = true;
		webLink.hasToolbar = false;
		webLink.height = 600;
		webLink.isResizable = true;
		webLink.linkType = 'url';
		webLink.masterLabel = 'google';
		webLink.openType = 'newWindow';
		webLink.position = 'none';
		webLink.protected_x = false;
		webLink.showsLocation = false;
		webLink.showsStatus = false;
		webLink.url = 'http://www.google.com';
		webLink.width = 600;	
		handleSaveResults(
			service.createMetadata(
				new List<MetadataService.Metadata> { webLink })[0]);

		// Read the Layout		
		MetadataService.Layout layout = 
			(MetadataService.Layout) service.readMetadata('Layout', 
				new String[] { 'Test__c-Test Layout' }).getRecords()[0];
				
		// Add the Custom Button to the Layout
		if(layout.customButtons==null)
			layout.customButtons = new List<String>();
		layout.customButtons.add('googleButton');
		
		// Update the Layout
		handleSaveResults(
			service.updateMetadata(
				new MetadataService.Metadata[] { layout })[0]);
	}

	
	public static void addFieldToLayout()
	{
		MetadataService.MetadataPort service = createService();

		// Read the Layout		
		MetadataService.Layout layout = 
			(MetadataService.Layout) service.readMetadata('Layout', 
				new String[] { 'Test__c-Test Layout' }).getRecords()[0];

		// Add Layout section, layout, item and field
		if(layout.layoutSections==null)
			layout.layoutSections = new List<MetadataService.LayoutSection>();
		MetadataService.LayoutSection newLayoutSection = new MetadataService.LayoutSection();
		newLayoutSection.style = 'OneColumn';
		MetadataService.LayoutColumn newLayoutColumn = new MetadataService.LayoutColumn();
		MetadataService.LayoutItem newLayoutItem = new MetadataService.LayoutItem();
		newLayoutItem.field = 'TestField__c';
		newLayoutColumn.layoutItems = new List<MetadataService.LayoutItem> { newLayoutItem }; 
		newLayoutSection.layoutColumns = new List<MetadataService.LayoutColumn> { newLayoutColumn };        
		layout.layoutSections.add(newLayoutSection);		       		
		
		// Update the Layout
		handleSaveResults(
			service.updateMetadata(
				new MetadataService.Metadata[] { layout })[0]);
	}

	public static void updatePicklist()
	{
	    MetadataService.MetadataPort service = createService();     	    

	    // Read Custom Field
	    MetadataService.CustomField customField = 
			(MetadataService.CustomField) service.readMetadata('CustomField', 
				new String[] { 'Lead.picklist__c' }).getRecords()[0];	    

		// Add pick list values
	    metadataservice.PicklistValue two = new metadataservice.PicklistValue();
	    two.fullName= 'second';
	    two.default_x=false;
	    metadataservice.PicklistValue three = new metadataservice.PicklistValue();
	    three.fullName= 'third';
	    three.default_x=false;
	    customField.picklist.picklistValues.add(two);
	    customField.picklist.picklistValues.add(three);	    

	    // Update Custom Field
		handleSaveResults(
			service.updateMetadata(
				new MetadataService.Metadata[] { customField })[0]);		
	}

	public static void copyLayoutSection()
	{
	    MetadataService.MetadataPort service = createService();     	    

		// Read the source Layout		
		MetadataService.Layout sourceLayout = 
			(MetadataService.Layout) service.readMetadata('Layout', 
				new String[] { 'Test__c-Test Template Layout' }).getRecords()[0];

		// Read the target Layout		
		MetadataService.Layout targetLayout = 
			(MetadataService.Layout) service.readMetadata('Layout', 
				new String[] { 'Test__c-Test Layout' }).getRecords()[0];

		// Add section from source Layout to target Layout
		targetLayout.layoutSections.add(
			sourceLayout.layoutSections[0]);

		// Update target Layout
		handleSaveResults(
			service.updateMetadata(
				new MetadataService.Metadata[] { targetLayout })[0]);
	}

	public static void readWorkflowAlert()
	{
		MetadataService.MetadataPort service = createService();
		
		// Read Workflow Alert		
		MetadataService.WorkflowAlert wfa = 
			(MetadataService.WorkflowAlert) service.readMetadata('WorkflowAlert', 
				new String[] { 'Test__c.Test' }).getRecords()[0];
		System.debug('Description ' + wfa.description);
		System.debug('Sender Address ' + wfa.senderAddress);				
	}

	public static void readCustomObject()
	{
		MetadataService.MetadataPort service = createService();
		
		MetadataService.CustomObject customObject = 
			(MetadataService.CustomObject) service.readMetadata('CustomObject', 
				new String[] { 'Test__c' }).getRecords()[0];
		for(MetadataService.CustomField field : customObject.fields)
			System.debug(field.fullName);
	}

	public static void addComponentsToHomePageLayout()
	{
		// Retrieve Home Page Layout
		MetadataService.MetadataPort service = createService();		
		MetadataService.HomePageLayout homePageLayout = 
			(MetadataService.HomePageLayout) service.readMetadata('HomePageLayout', 
				new String[] { 'DE Default' }).getRecords()[0];

		// Create Home Page Component
		MetadataService.HomePageComponent homePageComponent = 
			new MetadataService.HomePageComponent();
		homePageComponent.width = 'wide';
		homePageComponent.pageComponentType = 'htmlArea';
		homePageComponent.fullName = 'helloworld';
		homePageComponent.body = '<p>Hello World</p>';
		handleSaveResults(
			service.createMetadata(
				new MetadataService.Metadata[] { homePageComponent })[0]);		

		// Add component to Home Page Layout and Update
		if(homePageLayout.wideComponents==null)
			homePageLayout.wideComponents = new List<String>();
		homePageLayout.wideComponents.add('helloworld');		
		handleSaveResults(
			service.updateMetadata(
				new MetadataService.Metadata[] { homePageLayout })[0]);		
	}

	public static void readFolder()
	{
		// Retrieve Folder
		MetadataService.MetadataPort service = createService();		
		MetadataService.ReportFolder folder = 
			(MetadataService.ReportFolder) service.readMetadata('ReportFolder', 
				new String[] { 'MyFolder' }).getRecords()[0];
		MetadataService.SharedTo shareTo = folder.SharedTo;
		for(String groupName : shareTo.group_x)
			System.debug('Shared to Group ' + groupName);
	}

	public class MetadataServiceExamplesException extends Exception { }

	public static MetadataService.MetadataPort createService()
	{ 
		MetadataService.MetadataPort service = new MetadataService.MetadataPort();
		service.SessionHeader = new MetadataService.SessionHeader_element();
		service.SessionHeader.sessionId = UserInfo.getSessionId();
		return service;		
	}

	/**
	 * Example helper method to interpret a SaveResult, throws an exception if errors are found
	 **/
	private static void handleSaveResults(MetadataService.SaveResult saveResult)
	{
		// Nothing to see?
		if(saveResult==null || saveResult.success)
			return;
		// Construct error message and throw an exception
		List<String> messages = new List<String>();
		messages.add(
			(saveResult.errors.size()==1 ? 'Error ' : 'Errors ') + 
				'occured processing component ' + saveResult.fullName + '.');
		for(MetadataService.Error error : saveResult.errors)
			messages.add(
				error.message + ' (' + error.statusCode + ').' + 
				( error.fields!=null && error.fields.size()>0 ? 
					' Fields ' + String.join(error.fields, ',') + '.' : '' ) );
		if(messages.size()>0)
			throw new MetadataServiceExamplesException(String.join(messages, ' '));
	}	

	/**
	 * Example helper method to interpret a SaveResult, throws an exception if errors are found
	 **/
	private static void handleDeleteResults(MetadataService.DeleteResult deleteResult)
	{
		// Nothing to see?
		if(deleteResult==null || deleteResult.success)
			return;
		// Construct error message and throw an exception
		List<String> messages = new List<String>();
		messages.add(
			(deleteResult.errors.size()==1 ? 'Error ' : 'Errors ') + 
				'occured processing component ' + deleteResult.fullName + '.');
		for(MetadataService.Error error : deleteResult.errors)
			messages.add(
				error.message + ' (' + error.statusCode + ').' + 
				( error.fields!=null && error.fields.size()>0 ? 
					' Fields ' + String.join(error.fields, ',') + '.' : '' ) );
		if(messages.size()>0)
			throw new MetadataServiceExamplesException(String.join(messages, ' '));
	}
	
	/**
	 * Example helper method to interpret a UpsertResult, throws an exception if errors are found
	 **/
	private static void handleUpsertResults(MetadataService.UpsertResult upsertResult)
	{
		// Nothing to see?
		if(upsertResult==null || upsertResult.success)
			return;
		// Construct error message and throw an exception
		List<String> messages = new List<String>();
		messages.add(
			(upsertResult.errors.size()==1 ? 'Error ' : 'Errors ') + 
				'occured processing component ' + upsertResult.fullName + '.');
		for(MetadataService.Error error : upsertResult.errors)
			messages.add(
				error.message + ' (' + error.statusCode + ').' + 
				( error.fields!=null && error.fields.size()>0 ? 
					' Fields ' + String.join(error.fields, ',') + '.' : '' ) );
		if(messages.size()>0)
			throw new MetadataServiceExamplesException(String.join(messages, ' '));
	}
}