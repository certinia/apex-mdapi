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
 * Demonstrates how to use the apex:actionPoller with the Metadata API
 **/
public with sharing class MetadataController {

	public MetadataService.AsyncResult result {get;set;}
	
	public PageReference createField()
	{
		// Create a Custom Field
		MetadataService.CustomField customField = new MetadataService.CustomField();
		customField.fullName = 'Test__c.TestField__c';
		customField.label = 'Test Field';
		customField.type_x = 'Text';
		customField.length = 42;
		result = createService().create(new List<MetadataService.Metadata> { customField })[0];		
	
		// Display status of the request
		displayStatus();
		return null;
	}

	public PageReference deleteField()
	{
		// Delete a Custom Field
		MetadataService.CustomField customField = new MetadataService.CustomField();
		customField.fullName = 'Test__c.TestField__c';
		result = createService().deleteMetadata(new List<MetadataService.Metadata> { customField })[0];		
	
		// Display status of the request
		displayStatus();
		return null;
	}
	
	public PageReference checkStatus()
	{
		// Check status of the request
		result = createService().checkStatus(new List<String> { result.Id })[0];
		displayStatus();		
		return null;	
	}
	
	private void displayStatus()
	{
		// Inspect the AsyncResult and display the result
		ApexPages.addMessage(
			new ApexPages.Message(ApexPages.Severity.Info, 
				result.done ? 'Request completed' : 'Request in progress...'));
		if(result.state == 'Error')
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, result.message));
		if(result.done)
			result = null;
	}
		
	private static MetadataService.MetadataPort createService()
	{ 
		// Create the Metadata API service stub and authenticate
		MetadataService.MetadataPort service = new MetadataService.MetadataPort();
		service.SessionHeader = new MetadataService.SessionHeader_element();
		service.SessionHeader.sessionId = UserInfo.getSessionId();
		return service;		
	}
	
}