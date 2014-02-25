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
 *
 * NOTE: You need to handle the AsyncResult value, via checkStatus and related methods e.g. checkDeployStatus
 *       refer to the Metadata API developers guide for more information and the read me of this repo for other samples 
 **/
 
/**
 * Note: Most of the examples don't check the AsyncResult, see the repo readme for more details on how to do this
 *       or add a debug to output the AsyncResult Id and issue the following code from anonymous Apex some time after
 *
 *         String[] asyncProcessId = new String[] { '04sG00000041iElIAI' };
 *         MetadataService.AsyncResult[] results = MetadataServiceExamples.createService().checkStatus(asyncProcessId);
 *         System.debug(results[0].message);
 */
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
		MetadataService.AsyncResult[] results = service.create(new List<MetadataService.Metadata> { customObject });
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
 		MetadataService.AsyncResult[] results = service.create(new List<MetadataService.Metadata> { customField });
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
 		MetadataService.AsyncResult[] results = service.create(new List<MetadataService.Metadata> { customField });
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
 		MetadataService.AsyncResult[] results = service.create(new List<MetadataService.Metadata> { customField });
	}

	
	public static void createField()
	{
		MetadataService.MetadataPort service = createService();		
		MetadataService.CustomField customField = new MetadataService.CustomField();
		customField.fullName = 'Test__c.TestField__c';
		customField.label = 'Test Field';
		customField.type_x = 'Text';
		customField.length = 42;
 		MetadataService.AsyncResult[] results = service.create(new List<MetadataService.Metadata> { customField });
	}
	
	public static void deleteField()
	{
		MetadataService.MetadataPort service = createService();		
		MetadataService.CustomField customField = new MetadataService.CustomField();
		customField.fullName = 'Test__c.TestField__c';
 		MetadataService.AsyncResult[] results = service.deleteMetadata(new List<MetadataService.Metadata> { customField });		
	}
	
	public static void updateField()
	{
	    MetadataService.MetadataPort service = createService(); 
	    MetadataService.CustomField customField = new MetadataService.CustomField();
	    customField.fullName = 'Test__c.TestField__c';
	    customField.label='New Test Field Label';
	    customField.type_x = 'Text'; 
	    customField.length = 52;
	    MetadataService.UpdateMetadata ut = new MetadataService.UpdateMetadata();
	    ut.currentName='Test__c.TestField__c';
	    ut.metadata= customField;
	    MetadataService.AsyncResult[] results = service.updateMetadata(new List<MetadataService.updateMetadata> {ut});	
	}	

	public static void createPage()
	{
		MetadataService.MetadataPort service = createService();		
		MetadataService.ApexPage apexPage = new MetadataService.ApexPage();
		apexPage.apiVersion = 25;
		apexPage.fullName = 'test';
		apexPage.label = 'Test Page';
		apexPage.content = EncodingUtil.base64Encode(Blob.valueOf('<apex:page/>'));
 		MetadataService.AsyncResult[] results = service.create(new List<MetadataService.Metadata> { apexPage });
	}

	public static void createStaticResource()
	{
		MetadataService.MetadataPort service = createService();		
		MetadataService.StaticResource staticResource = new MetadataService.StaticResource();
		staticResource.fullName = 'test';
		staticResource.contentType = 'text';
		staticResource.cacheControl = 'public';
		staticResource.content = EncodingUtil.base64Encode(Blob.valueOf('Static stuff'));
 		MetadataService.AsyncResult[] results = service.create(new List<MetadataService.Metadata> { staticResource });
	}

	public static void updateStaticResource()
	{
		MetadataService.MetadataPort service = createService();		
		MetadataService.StaticResource staticResource = new MetadataService.StaticResource();
		staticResource.fullName = 'test';
		staticResource.contentType = 'text';
		staticResource.cacheControl = 'public';
		staticResource.content = EncodingUtil.base64Encode(Blob.valueOf('Static stuff Changed'));
	    MetadataService.UpdateMetadata ut = new MetadataService.UpdateMetadata();
	    ut.currentName='test';
	    ut.metadata= staticResource;
	    MetadataService.AsyncResult[] results = service.updateMetadata(new List<MetadataService.updateMetadata> {ut});	
	}
	
	public static void deleteStaticResource()
	{
		MetadataService.MetadataPort service = createService();		
		MetadataService.StaticResource staticResource = new MetadataService.StaticResource();
		staticResource.fullName = 'test';
		staticResource.contentType = 'text';
		staticResource.cacheControl = 'public';
 		MetadataService.AsyncResult[] results = service.deleteMetadata(new List<MetadataService.Metadata> { staticResource });		
	}
	
	
	public static void createWebLink()
	{
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
		MetadataCreateJob.run(
			new List<MetadataCreateJob.Item> { new MetadataCreateJob.Item(webLink) },
			new MetadataCreateJob.EmailNotificationMetadataAsyncCallback());				
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
	    pt.picklistValues = new list<metadataservice.PicklistValue>{one};
	    customField.picklist = pt ;
	    MetadataService.AsyncResult[] results = service.create (new List<MetadataService.Metadata> { customField });
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
	    MetadataService.AsyncResult[] results = service.updateMetadata(new List<MetadataService.UpdateMetadata> {ut});
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
	    MetadataService.AsyncResult[] results = service.create(new List<MetadataService.Metadata> {addressSettings});		
	}
	
	public static void updateCaseSettings()
	{
	    MetadataService.MetadataPort service = createService();
	    MetadataService.CaseSettings caseSettings = new MetadataService.CaseSettings();
	    caseSettings.fullName = 'Case';
	    caseSettings.notifyOwnerOnCaseComment = true;
	    MetadataService.UpdateMetadata updateMetadata = new MetadataService.UpdateMetadata();
	    updateMetadata.currentName='Case.settings';
	    updateMetadata.metadata= caseSettings;		    	    		
	    MetadataService.AsyncResult[] results = service.updateMetadata(new List<MetadataService.UpdateMetadata> { updateMetadata });		
	}
	
	public static void createJob()
	{
		MetadataService.CustomField customField = new MetadataService.CustomField();
		customField.fullName = 'Test__c.TestField__c';
		customField.label = 'Test Field';
		customField.type_x = 'Text';
		customField.length = 42;
		MetadataCreateJob.run(
			new List<MetadataCreateJob.Item> { 
				new MetadataCreateJob.Item(customField) },
			new MetadataCreateJob.EmailNotificationMetadataAsyncCallback());				
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
		
		// Pass the Metadata items to the job for processing, indicating any dependencies
		MetadataCreateJob.run(
			new List<MetadataCreateJob.Item> { 
					new MetadataCreateJob.Item(customObject),					
					new MetadataCreateJob.Item(customField1, null, true), // Set wait to true, to process after object creation
					new MetadataCreateJob.Item(customField2),  
					new MetadataCreateJob.Item(apexPage, null, true) // Set wait to true, to process after field creation
				},
			new MetadataCreateJob.EmailNotificationMetadataAsyncCallback());				
	}
	
	public static void createRecordType()
	{
		MetadataService.RecordType recordType = new MetadataService.RecordType();
		recordType.active = true;
		recordType.fullName = 'Test__c.RecordTypeA';
		recordType.label = 'Record Type A';
		recordType.businessProcess = null;
		recordType.description = 'My new record type';		
		 
		// Pass the Metadata items to the job for processing, indicating any dependencies
		MetadataCreateJob.run(
			new List<MetadataCreateJob.Item> { new MetadataCreateJob.Item(recordType) },
			new MetadataCreateJob.EmailNotificationMetadataAsyncCallback());				
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
		MetadataService.AsyncResult[] results = service.deleteMetadata(new List<MetadataService.Metadata> { recordType });
	}
	
	public static void installPackages()
	{
		// Install packageA, then pacakgeB
		MetadataService.InstalledPackage installedPackageA = new MetadataService.InstalledPackage();
		installedPackageA.versionNumber = '1.0';
		installedPackageA.password = 'fred1234';
		installedPackageA.fullName = 'packagea';
		MetadataService.InstalledPackage installedPackageB = new MetadataService.InstalledPackage();
		installedPackageB.versionNumber = '1.0';
		installedPackageB.fullName = 'packageb';
		MetadataService.AsyncResult[] results = createService().create(new List<MetadataService.Metadata> { installedPackageA, installedPackageB });		
	}
	
	public static void installPackagesCreateJob()
	{
		// Install packageA, then pacakgeB
		MetadataService.InstalledPackage installedPackageA = new MetadataService.InstalledPackage();
		installedPackageA.versionNumber = '1.0';
		installedPackageA.fullName = 'packagea';
		MetadataService.InstalledPackage installedPackageB = new MetadataService.InstalledPackage();
		installedPackageB.versionNumber = '1.0';
		installedPackageB.fullName = 'packageb';
				 
		// Pass the Metadata items to the job for processing, indicating any dependencies
		MetadataCreateJob.run(
			new List<MetadataCreateJob.Item> { 
				new MetadataCreateJob.Item(installedPackageA ),
				new MetadataCreateJob.Item(installedPackageB ) },
			new MetadataCreateJob.EmailNotificationMetadataAsyncCallback());				
	}
	
	public static void uninstallPackages()
	{
		// Uninstall packages
		MetadataService.InstalledPackage installedPackageA = new MetadataService.InstalledPackage();
		installedPackageA.fullName = 'packagea';
		MetadataService.InstalledPackage installedPackageB = new MetadataService.InstalledPackage();
		installedPackageB.fullName = 'packageb';
		MetadataService.AsyncResult[] results = createService().deleteMetadata(new List<MetadataService.Metadata> { installedPackageA, installedPackageB });
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
		MetadataCreateJob.run(
			new List<MetadataCreateJob.Item> { 
				new MetadataCreateJob.Item(customSite ) },
			new MetadataCreateJob.EmailNotificationMetadataAsyncCallback());						
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
		
		// Pass the Metadata items to the job for processing
		MetadataCreateJob.run(
			new List<MetadataCreateJob.Item> { 
					new MetadataCreateJob.Item(customObject),					
					new MetadataCreateJob.Item(new List<MetadataService.Metadata> { customField1, customField2 }, null, true) }, // Set wait to true, to process after object creation
			new MetadataCreateJob.EmailNotificationMetadataAsyncCallback());								
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
		MetadataService.AsyncResult[] results = service.create(new List<MetadataService.Metadata> { fieldSet });
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
		List<MetadataService.UpdateMetadata> updateMetadataList = new List<MetadataService.UpdateMetadata>();
		updateMetadataList.add(new MetadataService.UpdateMetadata());
		updateMetadataList[0].currentName = 'Test__c.MyFieldSet';
		updateMetadataList[0].metadata = fieldSet;
		MetadataService.AsyncResult[] results = service.updateMetadata(updateMetadataList);
	}
	
	/**
	 * Test via Execute Annoymous (Eclipse/Developer Console) 
	 * 1. First run this System.debug('AsyncId is ' + MetadataServiceExamples.addActionOverride().id);
	 * 2. Note the Id output in the debug log and update the follow statement before executing it
	 * 3. Wait for a few seconds then run this System.debug(MetadataServiceExamples.checkAsync('04sG00000041ndgIAA'));
	 * See README for notes on how to use BatchApex or apex:actionPoller to implement this in an application  
	 **/ 
	public static MetadataService.AsyncResult addActionOverride()
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
		List<MetadataService.UpdateMetadata> updateMetadataList = new List<MetadataService.UpdateMetadata>();
		updateMetadataList.add(new MetadataService.UpdateMetadata());
		updateMetadataList[0].currentName = 'Test__c';
		updateMetadataList[0].metadata = customObject;
		MetadataService.AsyncResult[] results = service.updateMetadata(updateMetadataList);
		return results[0];		
	}
	
	public static void createListView()
	{
		MetadataService.MetadataPort service = createService();		
		MetadataService.ListView listView = new MetadataService.ListView();
		listView.fullName = 'Test__c.MyListView';
		listView.label = 'My List View';
		listView.filterScope = 'Everything';
		listView.columns = new List<String> { 'NAME' };
		MetadataCreateJob.run(
			new List<MetadataCreateJob.Item> { new MetadataCreateJob.Item(listView) },
			new MetadataCreateJob.EmailNotificationMetadataAsyncCallback());						
	}
	
	public static void deleteListView()
	{
		MetadataService.MetadataPort service = createService();		
		MetadataService.ListView listView = new MetadataService.ListView();
		listView.fullName = 'Test__c.MyListView';
		listView.filterScope = 'Everything';
 		MetadataService.AsyncResult[] results = service.deleteMetadata(new List<MetadataService.Metadata> { listView });				
	}
	
	public static String checkAsync(String asyncId)
	{
		MetadataService.MetadataPort service = createService();		
		return service.checkStatus(new List<String> { asyncId })[0].message;		
	}
		
	public static MetadataService.MetadataPort createService()
	{ 
		MetadataService.MetadataPort service = new MetadataService.MetadataPort();
		service.SessionHeader = new MetadataService.SessionHeader_element();
		service.SessionHeader.sessionId = UserInfo.getSessionId();
		return service;		
	}
}