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
 * Processes a list of Metdata components to create and calling an Apex callback when all are complete.
 *
 *   It currently processes each component in the order given, items can be marked as dependent on the
 *     proceeding item (via the wait flag) if there are dependencies, for example a VF page referencing an object
 * 
 *   It supports an email callback implementation though others can be implemented via 
 *     the IMetadataAsyncCallback interface
 **/
public with sharing class MetadataCreateJob 
	implements Database.Batchable<Item>, Database.Stateful, Database.AllowsCallouts
{	
	private String sessionId;	
	private List<Item> items;	
	private IMetadataAsyncCallback callback;
	private Map<Integer, Item> itemsByIndex;	
	
	/**
	 * Private constructor, this job can only be started via the run method
	 **/
	private MetadataCreateJob(String sessionId, List<Item> items, IMetadataAsyncCallback callback)
	{
		this.sessionId = sessionId;
		this.items = items;
		this.callback = callback;
		
		// Index the items such that the scope items passed during execute can 
		//  be mapped to these maintained in the job state
		Integer index = 0;
		itemsByIndex = new Map<Integer, Item>();
		for(Item item : items)
		{
			item.index = index++;
			itemsByIndex.put(item.index, item);
		}
	}
		
	/**
	 * Iterable implementation uses state to process only components not completed
	 **/
	public Iterable<Item> start(Database.BatchableContext info)
	{
		return new JobIterable(items);		
	}	
	
	public void execute(Database.batchableContext info, List<Item> scope)
	{
		// Process the given Metadata job items components 
		MetadataService.MetadataPort service = new MetadataService.MetadataPort();
		service.SessionHeader = new MetadataService.SessionHeader_element();
		service.SessionHeader.sessionId = sessionId;
		
		// The scope items passed in our not the same as those from the job state, lookup the actual job item
		Item item = itemsByIndex.get(scope[0].index);
		try
		{
			// Call create and check result
			if(item.aysncResult == null)				
				item.aysncResult = service.create(item.metaData)[0];
			// Check the status of the last create call
			else if(item.aysncResult != null)
				item.aysncResult = service.checkStatus(new String[] { item.aysncResult.Id } )[0];
		}
		catch(Exception e)
		{
			// Log exception
			item.createException = e;
		}
	}
	
	public void finish(Database.batchableContext info)
	{ 
		// Start new job for those not yet processed?
		if (new JobIterable(items).Iterator().hasNext())
			run(sessionId, items, callback); 
		else // If all components processed if all now processed
			callback.deployComplete(items);
	}

	/**
	 * Starts a job to create the given components, notify the caller via the callback interface
	 **/
	public static void run(List<Item> items, IMetadataAsyncCallback callback)
	{
		run(UserInfo.getSessionId(), items, callback);		
	}
		
	/**
	 * Starts a job to create the given components, notify the caller via the callback interface
	 **/
	public static void run(String sessionId, List<Item> items, IMetadataAsyncCallback callback)
	{		
		// Batch scope of 1 for now, though this code could be enhanced to group by Metadata component type
		//   and issue max of 10 components per call to 'create' (as per Metadata API Documentation)
		Integer maxScopeSize = 1;
				
		// Start a job in 1 minutes time to process the given components, inform the callback of the Id
		callback.batchId( System.scheduleBatch( new MetadataCreateJob(sessionId, items, callback), 'Metadata Create', 1, maxScopeSize ) );		
	}

	/**
	 * Interface used to call back once all Metadata components have been fully processed
	 **/	
	public interface IMetadataAsyncCallback
	{
		/**
		 * Notifies the caller when a new batch Id is created, useful for monitor via UI the job
		 **/
		void batchId(Id batchId);
		
		/**
		 * Once all Metadata components have been processed and the status confirmed this method is called
		 **/
		void deployComplete(List<MetadataCreateJob.Item> components);
	}
	
	/**
	 * Email the status of all given deployments once completed
	 **/
	public class EmailNotificationMetadataAsyncCallback
		implements IMetadataAsyncCallback
	{
		/**
		 * Email handler is not interested in the batch ID, 
		 *  other callbacks may update a control object being monitored by a UI?
		 **/
		public void batchId(Id batchId)
		{				
		}
		
		/**
		 * Email handler will iterator over the components and dump the results to the email body
		 **/
		public void deployComplete(List<Item> components)
		{
			// List any errors
			String results = '<ul>';
			for(Item item : components)
				if(item.createException!=null)
					results+= '<li>' + item.createException + '</li>';
				else if(item.aysncResult.state=='Error')
					results+= '<li>' + item.aysncResult.message + '</li>';
			results+= '</ul>';
			
			// Email them to the user running this job
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			mail.setToAddresses(new String[] { UserInfo.getUserEmail() } );
			mail.setSubject('Metadata Deployment Resutls');
			mail.setHtmlBody(results);
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
		}		
	}
	
	/**
	 * State of a specific Metadata component deployment
	 **/
	public class Item
	{
		// Index
		public Integer index {get; private set;}
		// Generic reference to caller context related to this job / metadata item (e.g. record id)
		public Object context;
		// Wait for the previous item to complete?
		public Boolean wait = false;
		// Metadata item to be created
		public List<MetadataService.Metadata> metaData {get; private set;}
		// Exceptions raised 
		public Exception createException {get; private set;}
		// Result of the checkStatus call
		public MetadataService.AsyncResult aysncResult {get; private set;}

		/**
		 * Constructs a Metadata work item to be processed by the job,
		*   it will be processed in parrell with its proceeding item
		 **/ 	
		public Item(MetadataService.Metadata metaData)
		{
			this(new List<MetadataService.Metadata> { metadata }, null, false);
		}
	
		/**
		 * Constructs a Metadata work item to be processed by the job, you may also store your 
		 *   own state in the 'context' property, this will be passed back via the callback on completion
		 *   Setting wait ensures that the item will not be processed until the proceeding item completes
		 **/ 	
		public Item(MetadataService.Metadata metaData, Object context, Boolean wait)
		{
			this(new List<MetadataService.Metadata> { metadata }, context, wait);
		}

		/**
		 * Constructs a Metadata work item to be processed by the job,
		*   it will be processed in parrell with its proceeding item
		 **/ 	
		public Item(List<MetadataService.Metadata> metaData)
		{
			this(metaData, null, false);
		}
	
		/**
		 * Constructs a Metadata work item to be processed by the job, you may also store your 
		 *   own state in the 'context' property, this will be passed back via the callback on completion
		 *   Setting wait ensures that the item will not be processed until the proceeding item completes
		 **/ 	
		public Item(List<MetadataService.Metadata> metaData, Object context, Boolean wait)
		{
			this.metaData = metaData;
			this.context = context;
			this.wait = wait;	
		}
	}
	
	/**
	 * Internal Metadata interator implementation for Batch Apex job
	 **/ 
	private class JobIterator
		implements Iterator<Item>
	{
		private List<Item> items;
		private Integer nextIdx;
		
		public JobIterator(List<Item> items)
		{
			this.items = items;
			this.nextIdx = 0;
		}
		
		public boolean hasNext()
		{
			return nextIdx >= items.size() ? false : true;
		}
		
		public Item next()
		{
			return items[nextIdx++];
		}
	}

	/**
	 * Internal Metadata Iterable implementation for Batch Apex job
	 **/
	private class JobIterable
		implements Iterable<Item>
	{
		private List<Item> iteratorItems;
		
		public JobIterable(List<Item> items)
		{
			// Only iterate over items that have not been completed
			iteratorItems = new List<Item>();
			for(Item item : items)
			{
				if(item.aysncResult!=null && item.aysncResult.done)
					continue;
				if(item.createException != null)
					continue;
				if(iteratorItems.size() > 0 && item.wait)
					break;
				iteratorItems.add(item);
			}
		}
		
		public Iterator<Item> Iterator()
		{
			return new JobIterator(iteratorItems);
		}		
	}
}