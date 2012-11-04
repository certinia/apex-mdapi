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
		MetadataService.AsyncResult[] results = service.create(new List<MetadataService.Metadata> { customObject });
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

	public static void UpdatePicklistField()
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
	    MetadataService.AsyncResult[] results = service.updateMetadata(new List<MetadataService.updateMetadata> {ut});
	}
	
	public static MetadataService.MetadataPort createService()
	{ 
		MetadataService.MetadataPort service = new MetadataService.MetadataPort();
		service.SessionHeader = new MetadataService.SessionHeader_element();
		service.SessionHeader.sessionId = UserInfo.getSessionId();
		return service;		
	}
}