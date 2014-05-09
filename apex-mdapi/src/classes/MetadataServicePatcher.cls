/**
 * Copyright (c) 2014, FinancialForce.com, inc
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
This patch script performs the following changes to the default WSDL2Apex tool output

- Modify the end point to be dynamic
   - public String endpoint_x = URL.getSalesforceBaseUrl().toExternalForm() + '/services/Soap/m/28.0';
- Make 'Metadata' inner class 'virtual'
- Make 'MetadataWithContent' inner class 'virtual'
- Review WSDL for types that extend 'tns:Metadata' and update related Apex classes to also extend Metadata
- Review WSDL for types that extend 'tns:MetadataWithContent' and update related Apex classes to also extend MetadataWithContent
- Apply the following to each class that extends Metadata, e.g. for CustomObject
   Add the following at the top of the class
        public String type = 'CustomObject';
        public String fullName;
   Add the following at the top of the private static members
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] fullName_type_info = new String[]{'fullName','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
   Add 'fullName' as the first item in the field_order_type_info String array, e.g.
        private String[] field_order_type_info = new String[]{'fullName', 'actionOverrides' …. 'webLinks'};
- Apply the following to each class that extends MetadataWithContent, e.g. for ApexPage
   Add the following after 'fullName'
        public String content;
   Add the following after 'fullName_type_info'
        private String[] content_type_info = new String[]{'content','http://www.w3.org/2001/XMLSchema','base64Binary','0','1','false'};
   Add 'content' after 'fullName' in the field_order_type_info String array, e.g.
        private String[] field_order_type_info = new String[]{'fullName', 'content', 'apiVersion','description','label','packageVersions'};
- Patches the readMetadata operaton with a revised version returning IReadResult
	(this supports the polymorphic responses returned by the readMetadata operation)
- Injects IReadResult and IReadResultResponse interfaces
- Injects implementations of each of these interfaces to support the revised readMetadata option
**/

/**
 * See the README file for instructions on how to use this class should
 *   should you want to generate your own MetadataService.cls instead of using the one supplied
 **/
public with sharing class MetadataServicePatcher {

	private static final String API_VERSION = '30.0';
	
	// List of classes to modify so that they extend appropirte base class (parse WSDL in future?)
	private static final Map<String, String> METADATA_TYPES = 
		new Map<String, String> { 
			'CustomSite' => 'Metadata',
			'ListView' => 'Metadata',			 
			'InstalledPackage' => 'Metadata',
			'CustomField' => 'Metadata',
			'FieldSet' => 'Metadata',
			'PicklistValue' => 'Metadata',
			'RecordType' => 'Metadata',
			'WebLink' => 'Metadata',
			'AddressSettings' => 'Metadata',
			'CaseSettings' => 'Metadata',
			'CustomObject' => 'Metadata',
			'Layout' => 'Metadata',
			'EmailTemplate' => 'MetadataWithContent',
			'Scontrol' => 'MetadataWithContent',
			'ApexPage' => 'MetadataWithContent',
			'ApexComponent' => 'MetadataWithContent',
			'ApexClass' => 'MetadataWithContent',
			'ApexTrigger' => 'MetadataWithContent',
			'StaticResource' => 'MetadataWithContent',
			'Document' => 'MetadataWithContent',
			'CustomLabels' => 'Metadata',
			'CustomLabel' => 'Metadata',
			'AccountSettings' => 'Metadata',
			'Queue' => 'Metadata',
			'CustomDataType' => 'Metadata',
			'ExternalDataSource' => 'Metadata',
			'Group_x' => 'Metadata',
			'BusinessProcess' => 'Metadata',
			'CompactLayout' => 'Metadata',
			'SharingReason' => 'Metadata',
			'ValidationRule' => 'Metadata',
			'WebLink' => 'Metadata',
			'ReportType' => 'Metadata',
			'Report' => 'Metadata',
			'Dashboard' => 'Metadata',
			'AnalyticSnapshot' => 'Metadata',
			'AnalyticSnapshot' => 'Metadata',
			'CustomPageWebLink' => 'Metadata',
			'QuickAction' => 'Metadata',
			'FlexiPage' => 'Metadata',
			'CustomTab' => 'Metadata',
			'CustomApplicationComponent' => 'Metadata',
			'CustomApplication' => 'Metadata',
			'Portal' => 'Metadata',
			'Letterhead' => 'Metadata',
			'Flow' => 'Metadata',
			'Workflow' => 'Metadata',
			'WorkflowRule' => 'Metadata',
			'AssignmentRules' => 'Metadata',
			'AssignmentRule' => 'Metadata',
			'AutoResponseRules' => 'Metadata',
			'AutoResponseRule' => 'Metadata',
			'EscalationRules' => 'Metadata',
			'EscalationRule' => 'Metadata',
			'PostTemplate' => 'Metadata',
			'ApprovalProcess' => 'Metadata',
			'HomePageComponent' => 'Metadata',
			'HomePageLayout' => 'Metadata',
			'CustomObjectTranslation' => 'Metadata',
			'Translations' => 'Metadata',
			'Profile' => 'Metadata',
			'PermissionSet' => 'Metadata',
			'DataCategoryGroup' => 'Metadata',
			'RemoteSiteSetting' => 'Metadata',
			'Package_x' => 'Metadata',
			'AuthProvider' => 'Metadata',
			'CustomSite' => 'Metadata',
			'KnowledgeSettings' => 'Metadata',
			'BaseSharingRule' => 'Metadata',
			'SharingRules' => 'Metadata',
			'SharingSet' => 'Metadata',
			'SecuritySettings' => 'Metadata',
			'IdeasSettings' => 'Metadata',
			'ChatterAnswersSettings' => 'Metadata',
			'Community' => 'Metadata',
			'ActivitiesSettings' => 'Metadata',
			'ContractSettings' => 'Metadata',
			'OrderSettings' => 'Metadata',
			'OpportunitySettings' => 'Metadata',
			'ProductSettings' => 'Metadata',
			'QuoteSettings' => 'Metadata',
			'CallCenter' => 'Metadata',
			'EntitlementProcess' => 'Metadata',
			'MilestoneType' => 'Metadata',
			'EntitlementTemplate' => 'Metadata',
			'EntitlementSettings' => 'Metadata',
			'BusinessHoursSettings' => 'Metadata',
			'BusinessHoursEntry' => 'Metadata',
			'CaseSettings' => 'Metadata',
			'ConnectedApp' => 'Metadata',
			'AppMenu' => 'Metadata',
			'MobileSettings' => 'Metadata',
			'Network' => 'Metadata',
			'CompanySettings' => 'Metadata',
			'ForecastingSettings' => 'Metadata',
			'SamlSsoConfig' => 'Metadata',
			'LiveAgentSettings' => 'Metadata',
			'Skill' => 'Metadata',
			'LiveChatDeployment' => 'Metadata',
			'LiveChatButton' => 'Metadata',
			'LiveChatAgentConfig' => 'Metadata',
			'SynonymDictionary' => 'Metadata',
			'Folder' => 'Metadata',
			'ReportFolder' => 'Folder',
			'DashboardFolder' => 'Folder',
			'DocumentFolder' => 'Folder',
			'EmailFolder' => 'Folder',
			'RoleOrTerritory' => 'Metadata',
			'WorkflowAction' => 'Metadata',
			'SiteDotCom' => 'MetadataWithContent',
			'WorkflowTask' => 'WorkflowAction',
			'WorkflowSend' => 'WorkflowAction',
			'WorkflowOutboundMessage' => 'WorkflowAction',
			'WorkflowKnowledgePublish' => 'WorkflowAction',
			'WorkflowFieldUpdate' => 'WorkflowAction',
			'WorkflowAlert' => 'WorkflowAction',
			'WorkflowAction' => 'Metadata'
			}; // TODO: Inheritance modifications for Sharing Rules, Role, Flow and Custom Shortcut
	
	public static void patch()
	{
		// Query the current Apex Class
		ApexClass apexClass = 
			[select Id, Body 
			  from ApexClass 
			  where Name = 'MetadataServiceImported'];
			
		// Process and scan for lines to modify and/or insert
		LineReader lineReader = new LineReader(apexClass.Body);
		List<String> newLines = new List<String>();
		addCopyright(newLines);
		newLines.add('');
		newLines.add('//Patched by MetadataServicePatcher v' + API_VERSION + ' ' + System.today());
		newLines.add('');
		while(lineReader.hasNext())
		{
			// Read line
			String line = lineReader.next();
			String trimmedLine = line.trim();
			// Adjust class name?
			if(trimmedLine.contains('MetadataServiceImported'))
				line = line.replace('MetadataServiceImported', 'MetadataService');			
			// Adjust end point logic?
			if(trimmedLine.startsWith('public String endpoint_x'))
				line = '        public String endpoint_x = URL.getSalesforceBaseUrl().toExternalForm() + \'/services/Soap/m/' + API_VERSION + '\';';
			// Adjust update_x method name?
			else if(trimmedLine.contains('update_x('))
				line = line.replace('update_x', 'updateMetadata');			
			// Adjust delete_x method name?
			else if(trimmedLine.contains('delete_x('))
				line = line.replace('delete_x', 'deleteMetadata');			
			// Adjust retrieve_x method name?
			else if(trimmedLine.contains('retrieve_x('))
				line = line.replace('retrieve_x', 'retrieve');
			// Make Metadata virtual?
			else if(trimmedLine.startsWith('public class Metadata '))
				line = line.replace('public class', 'public virtual class');				
			// Make MetadataWithContent virtual?
			else if(trimmedLine.startsWith('public class MetadataWithContent '))
				line = line.replace('public class MetadataWithContent', 'public virtual class MetadataWithContent extends Metadata');
			// Make Folder virtual and extend from Metadata?
			else if(trimmedLine.startsWith('public class Folder '))
				line = line.replace('public class Folder ', 'public virtual class Folder extends Metadata');
			// Make WorkflowAction virtual and extend from Metadata?
			else if(trimmedLine.startsWith('public class WorkflowAction '))
				line = line.replace('public class WorkflowAction ', 'public virtual class WorkflowAction extends Metadata');				
			// Add interfaces to read?
			else if(trimmedLine.startsWith('public class ReadResult'))
			{			
			    newlines.add('    public interface IReadResult {');
			    newlines.add('        MetadataService.Metadata[] getRecords();');			    
			    newlines.add('    }');
			    newlines.add('    public interface IReadResponseElement {');
			    newlines.add('        IReadResult getResult();');
			    newlines.add('    }');
			    for(String metadataType : METADATA_TYPES.keySet())
			    {
			    	String apexClassType = metadataType;
			    	if(metadataType == 'Group_x')
			    		apexClassType = 'Group';
			    	else if(metadataType == 'Package_x')
			    		apexClassType = 'Package';
					newlines.add('    public class Read'+apexClassType+'Result implements IReadResult {');
					newlines.add('        public MetadataService.'+metadataType+'[] records;');
					newlines.add('        public MetadataService.Metadata[] getRecords() { return records; }');
					newlines.add('        private String[] records_type_info = new String[]{\'records\',\'http://soap.sforce.com/2006/04/metadata\',null,\'0\',\'-1\',\'false\'};');
					newlines.add('        private String[] apex_schema_type_info = new String[]{\'http://soap.sforce.com/2006/04/metadata\',\'true\',\'false\'};');
					newlines.add('        private String[] field_order_type_info = new String[]{\'records\'};');
					newlines.add('    }');
					newlines.add('    public class read'+apexClassType+'Response_element implements IReadResponseElement {');
					newlines.add('        public MetadataService.Read'+apexClassType+'Result result;');
					newlines.add('        public IReadResult getResult() { return result; }');
					newlines.add('        private String[] result_type_info = new String[]{\'result\',\'http://soap.sforce.com/2006/04/metadata\',null,\'1\',\'1\',\'false\'};');
					newlines.add('        private String[] apex_schema_type_info = new String[]{\'http://soap.sforce.com/2006/04/metadata\',\'true\',\'false\'};');
					newlines.add('        private String[] field_order_type_info = new String[]{\'result\'};');
					newlines.add('    }');
			    }
			}
			// readMetadata method?
			else if(trimmedLine.startsWith('public MetadataServiceImported.ReadResult readMetadata(String type_x,String[] fullNames) {'))
			{
					// Swallow up the generated readMetadata method
					while(lineReader.hasNext())
					{
						line = (String) lineReader.next();
						trimmedLine = line.trim();
						if(trimmedLine == '}')
							break;
					}					
					// Skip the closing brace
					line = lineReader.next(); 
					// Emit the new readMetadata method returnin the IReadResult interface
					newlines.add('        public MetadataService.IReadResult readMetadata(String type_x,String[] fullNames) {');
					newlines.add('            MetadataService.readMetadata_element request_x = new MetadataService.readMetadata_element();');
					newlines.add('            request_x.type_x = type_x;');
					newlines.add('            request_x.fullNames = fullNames;');
					newlines.add('            MetadataService.IReadResponseElement response_x;');
					newlines.add('            Map<String, MetadataService.IReadResponseElement> response_map_x = new Map<String, MetadataService.IReadResponseElement>();');
					newlines.add('            response_map_x.put(\'response_x\', response_x);');
					newlines.add('            WebServiceCallout.invoke(');
					newlines.add('              this,');
					newlines.add('              request_x,');
					newlines.add('              response_map_x,');
					newlines.add('              new String[]{endpoint_x,');
					newlines.add('              \'\',');
					newlines.add('              \'http://soap.sforce.com/2006/04/metadata\',');
					newlines.add('              \'readMetadata\',');
					newlines.add('              \'http://soap.sforce.com/2006/04/metadata\',');
					newlines.add('              \'readMetadataResponse\',');
					newlines.add('              \'MetadataService.read\' + type_x + \'Response_element\'}');
					newlines.add('            );');
					newlines.add('            response_x = response_map_x.get(\'response_x\');');
					newlines.add('            return response_x.getResult();');
					newlines.add('        }');
			}
			// Class definition?
			else if(trimmedLine.startsWith('public class'))
			{			
				List<String> parts = trimmedLine.split(' ');
				String className = parts[2];
				if(METADATA_TYPES.containsKey(className))
				{
					// Adjust class to extend base class and add base class members (XML serialiser does not support inheritance)
					String extendsClassName = METADATA_TYPES.get(className); 
					line = line.replace('public class ' + className, 'public class ' + className + ' extends ' + extendsClassName);
					newLines.add(line);
					newLines.add('        public String type = \'' + className + '\';');
					newLines.add('        public String fullName;');
					if(extendsClassName.equals('MetadataWithContent'))
						newLines.add('        public String content;');
					// Move forward until field_order_type_info member
					while(lineReader.hasNext())
					{
						line = (String) lineReader.next();
						trimmedLine = line.trim();
						// Adjust class name?
						if(trimmedLine.contains('MetadataServiceImported'))
							line = line.replace('MetadataServiceImported', 'MetadataService');									
						else if(trimmedLine.startsWith('private String[] field_order_type_info'))
						{
							// Add type info descriptors and adjust field_order_type_info list
							newLines.add('        private String[] type_att_info = new String[]{\'xsi:type\'};');
							newLines.add('        private String[] fullName_type_info = new String[]{\'fullName\',\'http://www.w3.org/2001/XMLSchema\',\'string\',\'0\',\'1\',\'false\'};');
							if(extendsClassName.equals('MetadataWithContent'))
							{
								newLines.add('        private String[] content_type_info = new String[]{\'content\',\'http://www.w3.org/2001/XMLSchema\',\'base64Binary\',\'0\',\'1\',\'false\'};');
								line = line.replace('new String[]{', 'new String[]{\'fullName\', \'content\', ');
							}
							else
							{
								if(line.endsWith('new String[]{};'))
									line = line.replace('new String[]{', 'new String[]{\'fullName\'');
								else
									line = line.replace('new String[]{', 'new String[]{\'fullName\', ');
							}
							newLines.add(line);
							break;														
						}
						newLines.add(line);
					}
					continue;
				}
			}
			newLines.add(line);
		}		
		String patchClass = String.join(newLines, '\n');
				
		// Upload the generated code to a Document 
		//   (this can be included in a MavensMate or Eclipse project for easy access via Refresh from Server)
		List<Document> docs = [select Id from Document where DeveloperName = 'MetadataServicePatched'];
		Document generatedCode = docs.size()>0 ? docs[0] : new Document();
		generatedCode.Name = 'MetadataService';
		generatedCode.Body = Blob.valueOf(patchClass);
		generatedCode.DeveloperName = 'MetadataServicePatched';
		generatedCode.FolderId = [select Id from Folder where DeveloperName = 'MetadataServicePatcher'].Id;
		if(generatedCode.Id == null)
			insert generatedCode;
		else
			update generatedCode;
	}
	
	public class PatchException extends Exception { }
	
	/**
	 * Utility class to iterate over lines in Apex source code
	 **/
	public class LineReader 
		implements Iterator<string>, Iterable<string>
	{		
		private String LF = '\n';
		
		private String textData;
		
		public LineReader(String textData)
		{		
			this.textData = textData;
		}
		
		public Boolean hasNext()
		{
			return textData.length() > 0 ? true : false;
		}	
		
		public String next()
		{
			String row = null;
			Integer endPos = textData.indexOf(LF);
			if(endPos == -1)
			{
				row = textData;
				textData = '';
			}
			else
			{
				row = textData.subString(0, endPos);
				textData = textData.subString(endPos + LF.length(), textData.length());				
			}
			return row;
   		}
   		
		public Iterator<String> Iterator()
		{
			return this;   
		}   		
	}
	
	private static void addCopyright(List<String> lines)
	{
		lines.add('/**');
		lines.add(' * Copyright (c) 2012, FinancialForce.com, inc');
		lines.add(' * All rights reserved.');
		lines.add(' *');
		lines.add(' * Redistribution and use in source and binary forms, with or without modification,'); 
		lines.add(' *   are permitted provided that the following conditions are met:');
		lines.add(' *');
		lines.add(' * - Redistributions of source code must retain the above copyright notice,'); 
		lines.add(' *      this list of conditions and the following disclaimer.');
		lines.add(' * - Redistributions in binary form must reproduce the above copyright notice,'); 
		lines.add(' *      this list of conditions and the following disclaimer in the documentation'); 
		lines.add(' *      and/or other materials provided with the distribution.');
		lines.add(' * - Neither the name of the FinancialForce.com, inc nor the names of its contributors'); 
		lines.add(' *      may be used to endorse or promote products derived from this software without'); 
		lines.add(' *      specific prior written permission.');
		lines.add(' *');
		lines.add(' * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND'); 
		lines.add(' *  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES'); 
		lines.add(' *  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL'); 
		lines.add(' *  THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,'); 
		lines.add(' *  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS');
		lines.add(' *  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY');
		lines.add(' *  OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)');
		lines.add(' *  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.');
		lines.add('**/');		
	}
}