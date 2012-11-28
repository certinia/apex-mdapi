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
 * Initial (in progress class) to illustrate using Metadata API in Batch Apex (aka using AysncResult)
 *   (resulted in a bug fix to MetadataService end point resolution code)
 **/
public with sharing class MetadataRetrieveBatchJob 
		implements Database.Batchable<sObject>, Database.AllowsCallouts
{
	private String SessionId;
	
	private MetadataService.AsyncResult AsyncResult;
	
	public MetadataRetrieveBatchJob(String sessionId)
	{
		this.SessionId = sessionId; 
	}
	
	public Database.QueryLocator start(Database.BatchableContext BC)
	{
		// TODO: Perhaps use a Custom Iterator over components to retrieve? 
		return Database.getQueryLocator('select Id from User limit 1');
	}
	
	public void execute(Database.BatchableContext BC, List<sObject> scope)
	{
		// Construct unmanaged package with list of desired components to retrieve in zip
		MetadataService.MetadataPort service = createService(SessionId);				
		MetadataService.RetrieveRequest retrieveRequest = new MetadataService.RetrieveRequest();
		retrieveRequest.apiVersion = 25;
		retrieveRequest.packageNames = null;
		retrieveRequest.singlePackage = true;
		retrieveRequest.specificFiles = null;
		retrieveRequest.unpackaged = new MetadataService.Package_x();
		retrieveRequest.unpackaged.types = new List<MetadataService.PackageTypeMembers>();
		MetadataService.PackageTypeMembers packageType = new MetadataService.PackageTypeMembers();
		packageType.name = 'CustomObject'; 
		packageType.members = new String[] { 'Test__c' };
		retrieveRequest.unpackaged.types.add(packageType);
		AsyncResult = service.retrieve(retrieveRequest);		
		System.debug('AsyncResult is ' + AsyncResult.id);		
	}
	
	public void finish(Database.BatchableContext BC)
	{
		// TODO: Utilise Winter'13 ability to resubmit jobs to loop back and check AsyncResult		
	}
	
	public static void run()
	{
		// TODO: Consider life time of session here
		Database.executeBatch(new MetadataRetrieveBatchJob(UserInfo.getSessionId()));
	}
	
	private static MetadataService.MetadataPort createService(String sessionId)
	{ 
		MetadataService.MetadataPort service = new MetadataService.MetadataPort();
		service.SessionHeader = new MetadataService.SessionHeader_element();
		service.SessionHeader.sessionId = sessionId;
		return service;		
	}		
}