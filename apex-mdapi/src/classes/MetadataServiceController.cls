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
 * This example demonstrates how to utilise the Metadata API Retrieve operation inconjunction with the JSZip JavaScript library
 **/
public with sharing class MetadataServiceController 
{
	public List<SelectOption> Layouts {get; set;}
	public String LayoutName {get; set;}	
	public String MetadataFileName {get; set;}
	public String MetadataFileData {get; set;}
	public MetadataService.AsyncResult AsyncResult {get; private set;}
	public String MetaDataRetrieveZip { get; private set; }	
	public List<MetadataFile> MetadataFiles { get; set; }		
	
	public PageReference listLayouts()
	{
		// List Layouts
		Layouts = new List<SelectOption>();		
		MetadataService.MetadataPort service = createService();				
		List<MetadataService.ListMetadataQuery> queries = new List<MetadataService.ListMetadataQuery>();		
		MetadataService.ListMetadataQuery queryLayout = new MetadataService.ListMetadataQuery();
		queryLayout.type_x = 'Layout';
		queries.add(queryLayout);		
		MetadataService.FileProperties[] fileProperties = service.listMetadata(queries, 25);
		
		// Sort
		List<String> fullNames = new List<String>();
		for(MetadataService.FileProperties fileProperty : fileProperties)
			fullNames.add(fileProperty.fullName);
		fullNames.sort();
		for(String fullName : fullNames)
			Layouts.add(new SelectOption(fullName,EncodingUtil.urlDecode(fullName, 'UTF-8')));

		return null;	
	}
	
	public PageReference retrieveLayout()
	{		
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Retrieving metadata...'));
		
		// Reset state from any previous requests
		MetaDataRetrieveZip = null;
		MetadataFiles = null;
		 
		// Construct unmanaged package with list of desired components to retrieve in zip
		MetadataService.MetadataPort service = createService();				
		MetadataService.RetrieveRequest retrieveRequest = new MetadataService.RetrieveRequest();
		retrieveRequest.apiVersion = 25;
		retrieveRequest.packageNames = null;
		retrieveRequest.singlePackage = true;
		retrieveRequest.specificFiles = null;
		retrieveRequest.unpackaged = new MetadataService.Package_x();
		retrieveRequest.unpackaged.types = new List<MetadataService.PackageTypeMembers>();
		MetadataService.PackageTypeMembers layoutType = new MetadataService.PackageTypeMembers();
		layoutType.name = 'Layout'; 
		layoutType.members = new String[] { LayoutName };
		retrieveRequest.unpackaged.types.add(layoutType);
		AsyncResult = service.retrieve(retrieveRequest);
						
		return null;	
	}
	
	public PageReference checkAsyncRequest()
	{
		// Check the status of the retrieve request
		MetadataService.MetadataPort service = createService();
		MetadataService.AsyncResult[] aysncResults = service.checkStatus(new String[] { AsyncResult.Id });
		if(aysncResults[0].done)
		{
			// Errors?
			if(aysncResults[0].state == 'Error')
			{
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, aysncResults[0].message));
				AsyncResult = null;				
			}
			else
			{
				// Place Base64 encoded zip data onto the page for the JSZip library to handle
				MetadataService.RetrieveResult retrieveResult = service.checkRetrieveStatus(AsyncResult.id);
				MetaDataRetrieveZip = retrieveResult.zipFile;
				MetadataFiles = new List<MetadataFile>();
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Expanding...'));
				AsyncResult = null;
			}
		}
		else
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Retrieving metadata...'));
		}	

		return null;
	}
	
	public PageReference receiveMetadataZipFile()
	{
		// In this example the retrieved metadata is stored in viewstate in production cases you would probably use a custom object / attachment
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Expanding ' + MetaDataFileName + '...'));
		MetadataFile metaDataFile = new MetadataFile();
		metaDataFile.fullName = MetaDataFileName;
		metaDataFile.content = MetaDataFileData;
		MetadataFiles.add(metaDataFile);
		return null;
	}
	
	public PageReference receiveComplete()
	{
		// Completed, cleared Base64 encoded zip data from viewstate
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Metadata retrieve completed'));
		MetaDataRetrieveZip = null;		
		return null;
	}
	
	private static MetadataService.MetadataPort createService()
	{ 
		MetadataService.MetadataPort service = new MetadataService.MetadataPort();
		service.SessionHeader = new MetadataService.SessionHeader_element();
		service.SessionHeader.sessionId = UserInfo.getSessionId();
		return service;		
	}	
	
	/**
	 * Simple container class for retrieve metadata file, may as well leverage the Metadata API class for this
	 **/
	public class MetadataFile extends MetadataService.MetadataWithContent
	{
		public String getFullname()
		{
			return fullName;
		}
		
		public String getContent()
		{
			return content;
		}
	}
}