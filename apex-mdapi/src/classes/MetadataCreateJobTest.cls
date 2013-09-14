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
 * Initial test for the MetadataCreateJob utility class, 
 *   more testing will be permitted once Summer'13 is released and mixed mock callouts and DML permitted
 **/
@IsTest
private with sharing class MetadataCreateJobTest 
{
    /**
     * Metadata Web Service mock for testing MetadataCreateJob
     **/
	private class WebServiceMockImpl implements WebServiceMock 
	{
		public void doInvoke(
			Object stub, Object request, Map<String, Object> response,
			String endpoint, String soapAction, String requestName,
			String responseNS, String responseName, String responseType) 
		{
			// Mock response for 'create' operation?
			if(request instanceof MetadataService.create_element)
			{
				MetadataService.createResponse_element responseElement = new MetadataService.createResponse_element();
				MetadataService.AsyncResult asyncResult = new MetadataService.AsyncResult();
				asyncResult.done = false; // Emulate the need for a second job execution to poll via checkStatus
				responseElement.result = new MetadataService.AsyncResult[] { asyncResult };
				response.put('response_x', responseElement);				
			}			
			// Mock response for 'checkStatus' operation?			
			else if(request instanceof MetadataService.checkStatus_element)
			{				
				MetadataService.checkStatusResponse_element responseElement = new MetadataService.checkStatusResponse_element();
				MetadataService.AsyncResult asyncResult = new MetadataService.AsyncResult();
				asyncResult.done = true; // Emulate completion of the original 'create' operation
				responseElement.result = new MetadataService.AsyncResult[] { asyncResult };
				response.put('response_x', responseElement);
			}
			return;
		}
	}    

	private static testmethod void testCreateField()
	{
    	// Metadata Web Service mock implementation
        Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
		
		// Create a field
		Test.startTest();
		MetadataService.CustomField customField = new MetadataService.CustomField();
		customField.fullName = 'Test__c.TestField__c';
		customField.label = 'Test Field';
		customField.type_x = 'Text';
		customField.length = 42;
		MetadataCreateJob.Item item = new MetadataCreateJob.Item(customField);
		item.context = 'Some context';
		MetadataCreateJob.run(
			new List<MetadataCreateJob.Item> { item },
			new AssertMetadataAsyncCallback());
		Test.stopTest(); // Assertions are implemented in the AssertMetadataAsyncCallback methods 		
	}
	
	/**
	 * Class implements callback provided to the create job and asserts the results
	 **/
	public class AssertMetadataAsyncCallback
		implements MetadataCreateJob.IMetadataAsyncCallback
	{
		public void batchId(Id batchId)
		{
			// Must have received the Batch Apex Id (this allows clients to provide monitoring UIs)
			System.assert(batchId!=null, 'Batch Id is null');				
		}
		
		public void deployComplete(List<MetadataCreateJob.Item> items)
		{
			// Assert the completed item
			System.assertEquals('Some context', items[0].context);
			MetadataService.CustomField customField = (MetadataService.CustomField) items[0].metadata[0];
			System.assertEquals('Test__c.TestField__c', customField.fullName);
			System.assertEquals('Test Field', customField.label);
			System.assertEquals('Text', customField.type_x);
			System.assertEquals(42, customField.length); 
			
			// Currently the platform does not support testing callouts and DML (such as invoking Database.executeBatch)
			System.assertEquals('You have uncommitted work pending. Please commit or rollback before calling out', 
				items[0].createException.getMessage());
			
			// TODO: Once Summer'13 is released this can be tested properly, as the above restriction will not apply in a test context
			// System.assertEquals(true, items[0].aysncResult.done);
		}		
	}		
}