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

public with sharing class MetadataDataController 
{
	private static final Integer METADATA_API_VERSION = 
		Integer.valueOf(new MetadataService.MetadataPort().endpoint_x.substringAfterLast('/'));
	
	public String Data {get; set;}
	
	public PageReference constructResponse()
	{
		try {
			List<Node> nodes = new List<Node>();
			String node = ApexPages.currentPage().getParameters().get('node');
			if(node=='root')
			{
				// List available Metadata Types via the 'describeMetadata' API call
				MetadataService.MetadataPort service = MetadataServiceExamples.createService();					
				MetadataService.DescribeMetadataResult describeResult = service.describeMetadata(METADATA_API_VERSION);
				for(MetadataService.DescribeMetadataObject metadataObject : describeResult.metadataObjects)
				{
					nodes.add(new FolderNode(metadataObject.xmlName, metadataObject.xmlName, false, null));
					// Include child Metadata Types (such as CustomField, ValidationRule etc..)
					if(metadataObject.childXmlNames!=null)
						for(String childXmlName : metadataObject.childXmlNames)
							if(childXmlName!=null)
								nodes.add(new FolderNode(childXmlName, childXmlName, false, null));
				}
			}			
			else
			{
				// List Metadata for the given type via the listMetadata API call
				MetadataService.MetadataPort service = MetadataServiceExamples.createService();		
				List<MetadataService.ListMetadataQuery> queries = new List<MetadataService.ListMetadataQuery>();		
				MetadataService.ListMetadataQuery query = new MetadataService.ListMetadataQuery();
				query.type_x = node;
				queries.add(query);		
				MetadataService.FileProperties[] fileProperties = service.listMetadata(queries, METADATA_API_VERSION);
				
				// Emit leaf nodes (ensure unique IDs)
				if(fileProperties!=null) {
					Integer index = 0;
					for(MetadataService.FileProperties fileProperty : fileProperties)
						nodes.add(new LeafNode(fileProperty.fullName + ':' + index++, EncodingUtil.urlDecode(fileProperty.fullName, 'UTF-8'), false));					
				}
			}
			Data = JSON.serialize(nodes);			
		}
		catch (Exception e) {
			Data = JSON.serialize(new List<Node> { new FolderNode('error', e.getMessage(), false, null) });	
		}
		return null;	
	}
	
	public abstract class Node
	{
		public String id;
		public String text;
		public String cls;
		public boolean leaf;
		public boolean checked;
		public boolean expanded;
		public List<Node> children;			
	}
	
	public class FolderNode extends Node
	{
		public FolderNode(String id, String text, boolean expanded, List<Node> children)
		{	
			this.id = id;
			this.text = text;
			this.cls = 'folder';
			this.leaf = false;
			this.checked = false;
			this.expanded = expanded;
			this.children = children;
		}		
	}
	
	public class LeafNode extends Node
	{
		public LeafNode(String id, String text, boolean checked)
		{	
			this.id = id;
			this.text = text;
			this.cls = null;
			this.leaf = true;
			this.checked = checked;
			this.expanded = false;
			this.children = null;
		}		
	}
}