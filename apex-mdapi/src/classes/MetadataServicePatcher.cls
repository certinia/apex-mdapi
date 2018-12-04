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
   - public String endpoint_x = URL.getOrgDomainUrl().toExternalForm() + '/services/Soap/m/44.0';
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
public with sharing class MetadataServicePatcher
{

    private static final String API_VERSION = '44.0';

    private static final String MD_IMPORTED_CLASS = 'MetadataServiceImported';
    private static final String MD_SERVICE_CLASS = 'MetadataService';

    // List of classes to modify so that they extend appropirte base class (parse WSDL in future?)
    private static final Map<String, String> METADATA_TYPES =
        new Map<String, String>
    {
        'CustomSite' => 'Metadata'
        ,'ListView' => 'Metadata'
        ,'InstalledPackage' => 'Metadata'
        ,'CustomField' => 'Metadata'
        ,'FieldSet' => 'Metadata'
        ,'PicklistValue' => 'Metadata'
        ,'RecordType' => 'Metadata'
        ,'WebLink' => 'Metadata'
        ,'AddressSettings' => 'Metadata'
        ,'CaseSettings' => 'Metadata'
        ,'CustomObject' => 'Metadata'
        ,'Layout' => 'Metadata'
        ,'EmailTemplate' => 'MetadataWithContent'
        ,'Scontrol' => 'MetadataWithContent'
        ,'ApexPage' => 'MetadataWithContent'
        ,'ApexComponent' => 'MetadataWithContent'
        ,'ApexClass' => 'MetadataWithContent'
        ,'ApexTrigger' => 'MetadataWithContent'
        ,'StaticResource' => 'MetadataWithContent'
        ,'Document' => 'MetadataWithContent'
        ,'CustomLabels' => 'Metadata'
        ,'CustomLabel' => 'Metadata'
        ,'AccountSettings' => 'Metadata'
        ,'Queue' => 'Metadata'
        ,'CustomDataType' => 'Metadata'
        ,'ExternalDataSource' => 'Metadata'
        ,'Group_x' => 'Metadata'
        ,'BusinessProcess' => 'Metadata'
        ,'CompactLayout' => 'Metadata'
        ,'SharingReason' => 'Metadata'
        ,'ValidationRule' => 'Metadata'
        ,'WebLink' => 'Metadata'
        ,'ReportType' => 'Metadata'
        ,'Report' => 'Metadata'
        ,'Dashboard' => 'Metadata'
        ,'AnalyticSnapshot' => 'Metadata'
        ,'AnalyticSnapshot' => 'Metadata'
        ,'CustomPageWebLink' => 'Metadata'
        ,'QuickAction' => 'Metadata'
        ,'FlexiPage' => 'Metadata'
        ,'CustomTab' => 'Metadata'
        ,'CustomApplicationComponent' => 'Metadata'
        ,'CustomApplication' => 'Metadata'
        ,'Portal' => 'Metadata'
        ,'Letterhead' => 'Metadata'
        ,'Flow' => 'Metadata'
        ,'Workflow' => 'Metadata'
        ,'WorkflowRule' => 'Metadata'
        ,'AssignmentRules' => 'Metadata'
        ,'AssignmentRule' => 'Metadata'
        ,'AutoResponseRules' => 'Metadata'
        ,'AutoResponseRule' => 'Metadata'
        ,'EscalationRules' => 'Metadata'
        ,'EscalationRule' => 'Metadata'
        ,'PostTemplate' => 'Metadata'
        ,'ApprovalProcess' => 'Metadata'
        ,'HomePageComponent' => 'Metadata'
        ,'HomePageLayout' => 'Metadata'
        ,'CustomObjectTranslation' => 'Metadata'
        ,'Translations' => 'Metadata'
        ,'Profile' => 'Metadata'
        ,'PermissionSet' => 'Metadata'
        ,'DataCategoryGroup' => 'Metadata'
        ,'RemoteSiteSetting' => 'Metadata'
        ,'Package_x' => 'Metadata'
        ,'AuthProvider' => 'Metadata'
        ,'CustomSite' => 'Metadata'
        ,'KnowledgeSettings' => 'Metadata'
        ,'SharingSet' => 'Metadata'
        ,'SecuritySettings' => 'Metadata'
        ,'IdeasSettings' => 'Metadata'
        ,'ChatterAnswersSettings' => 'Metadata'
        ,'Community' => 'Metadata'
        ,'ActivitiesSettings' => 'Metadata'
        ,'ContractSettings' => 'Metadata'
        ,'OrderSettings' => 'Metadata'
        ,'OpportunitySettings' => 'Metadata'
        ,'ProductSettings' => 'Metadata'
        ,'QuoteSettings' => 'Metadata'
        ,'CallCenter' => 'Metadata'
        ,'EntitlementProcess' => 'Metadata'
        ,'MilestoneType' => 'Metadata'
        ,'EntitlementTemplate' => 'Metadata'
        ,'EntitlementSettings' => 'Metadata'
        ,'BusinessHoursSettings' => 'Metadata'
        ,'BusinessHoursEntry' => 'Metadata'
        ,'CaseSettings' => 'Metadata'
        ,'ConnectedApp' => 'Metadata'
        ,'AppMenu' => 'Metadata'
        ,'MobileSettings' => 'Metadata'
        ,'Network' => 'Metadata'
        ,'CompanySettings' => 'Metadata'
        ,'ForecastingSettings' => 'Metadata'
        ,'SamlSsoConfig' => 'Metadata'
        ,'LiveAgentSettings' => 'Metadata'
        ,'Skill' => 'Metadata'
        ,'LiveChatDeployment' => 'Metadata'
        ,'LiveChatButton' => 'Metadata'
        ,'LiveChatAgentConfig' => 'Metadata'
        ,'SynonymDictionary' => 'Metadata'
        ,'Folder' => 'Metadata'
        ,'ReportFolder' => 'Folder'
        ,'DashboardFolder' => 'Folder'
        ,'DocumentFolder' => 'Folder'
        ,'EmailFolder' => 'Folder'
        ,'RoleOrTerritory' => 'Metadata'
        ,'WorkflowAction' => 'Metadata'
        ,'SiteDotCom' => 'MetadataWithContent'
        ,'WorkflowTask' => 'WorkflowAction'
        ,'WorkflowSend' => 'WorkflowAction'
        ,'WorkflowOutboundMessage' => 'WorkflowAction'
        ,'WorkflowKnowledgePublish' => 'WorkflowAction'
        ,'WorkflowFieldUpdate' => 'WorkflowAction'
        ,'WorkflowAlert' => 'WorkflowAction'
        ,'WorkflowAction' => 'Metadata'
        ,'VisualizationPlugin' => 'Metadata'
        ,'CustomMetadata' => 'Metadata'
        ,'NameSettings' => 'Metadata'
        ,'MarketingActionSettings' => 'Metadata'
        ,'CustomPermission' => 'Metadata'
        ,'AuraDefinitionBundle' => 'Metadata'
        ,'CorsWhitelistOrigin' => 'Metadata'
        ,'ManagedTopics' => 'Metadata'
        ,'Territory2' => 'Metadata'
        ,'Territory2Model' => 'Metadata'
        ,'Territory2Settings' => 'Metadata'
        ,'Territory2Type' => 'Metadata'
        // ,'XOrgHub' => 'Metadata' // (option not enabled by default?)
        ,'ActionLinkGroupTemplate' => 'Metadata'
        ,'LicenseDefinition' => 'Metadata'
        ,'MarketingResourceType' => 'Metadata'
        ,'MatchingRule' => 'Metadata'
        ,'MatchingRules' => 'Metadata'
        ,'NamedCredential' => 'Metadata'
        ,'SharingRules' => 'Metadata'
        ,'SharingBaseRule' => 'Metadata'
        ,'SharingCriteriaRule' => 'SharingBaseRule'
        ,'SharingOwnerRule' => 'SharingBaseRule'
        ,'SharingTerritoryRule' => 'SharingBaseRule'
        ,'FlowElement' => 'FlowBaseElement'
        ,'FlowNode' => 'FlowElement'
        ,'FlowActionCall' => 'FlowNode'
        ,'FlowApexPluginCall' => 'FlowNode'
        ,'FlowAssignment' => 'FlowNode'
        ,'FlowDecision' => 'FlowNode'
        ,'FlowLoop' => 'FlowNode'
        ,'FlowRecordCreate' => 'FlowNode'
        ,'FlowRecordDelete' => 'FlowNode'
        ,'FlowRecordLookup' => 'FlowNode'
        ,'FlowRecordUpdate' => 'FlowNode'
        ,'FlowScreen' => 'FlowNode'
        ,'FlowStep' => 'FlowNode'
        ,'FlowSubflow' => 'FlowNode'
        ,'FlowWait' => 'FlowNode'
        ,'FlowActionCall' => 'FlowNode'
        ,'FlowChoice' => 'FlowElement'
        ,'FlowConstant' => 'FlowElement'
        ,'FlowDynamicChoiceSet' => 'FlowElement'
        ,'FlowFormula' => 'FlowElement'
        ,'FlowRule' => 'FlowElement'
        ,'FlowScreenField' => 'FlowElement'
        ,'FlowTextTemplate' => 'FlowElement'
        ,'FlowVariable' => 'FlowElement'
        ,'FlowWaitEvent' => 'FlowElement'
        ,'FlowActionCallInputParameter' => 'FlowBaseElement'
        ,'FlowActionCallOutputParameter' => 'FlowBaseElement'
        ,'FlowApexPluginCallInputParameter' => 'FlowBaseElement'
        ,'FlowApexPluginCallOutputParameter' => 'FlowBaseElement'
        ,'FlowAssignmentItem' => 'FlowBaseElement'
        ,'FlowChoiceUserInput' => 'FlowBaseElement'
        ,'FlowCondition' => 'FlowBaseElement'
        ,'FlowConnector' => 'FlowBaseElement'
        ,'FlowInputFieldAssignment' => 'FlowBaseElement'
        ,'FlowOutputFieldAssignment' => 'FlowBaseElement'
        ,'FlowRecordFilter' => 'FlowBaseElement'
        ,'FlowSubflowInputAssignment' => 'FlowBaseElement'
        ,'FlowSubflowOutputAssignment' => 'FlowBaseElement'
        ,'FlowWaitEventInputParameter' => 'FlowBaseElement'
        ,'FlowWaitEventOutputParameter' => 'FlowBaseElement'
        ,'MetadataWithContent' => 'Metadata'
        ,'DelegateGroup' => 'Metadata'
        ,'EventDelivery' => 'Metadata'
        ,'EventSubscription' => 'Metadata'
        //,'EventType' => 'Metadata' // replaced with PlatformEventType?
        ,'Certificate' => 'MetadataWithContent'
        ,'ModerationRule' => 'Metadata'
        ,'WaveApplication' => 'Metadata'
        ,'WaveDataset' => 'Metadata'
        ,'WaveDashboard' => 'MetadataWithContent'
        ,'WaveDataflow' => 'MetadataWithContent'
        ,'WaveLens' => 'MetadataWithContent'
        ,'OrgPreferenceSettings' => 'Metadata'
        ,'SearchSettings' => 'Metadata'
        ,'GlobalValueSet' => 'Metadata'
        ,'GlobalPicklistValue' => 'Metadata'
        ,'PicklistValue' => 'GlobalPicklistValue'
        ,'StandardValueSet' => 'Metadata'
        ,'StandardValue' => 'CustomValue'
        ,'CustomValue' => 'Metadata'
        ,'ApexTestSuite' => 'Metadata'
        ,'ChannelLayout' => 'Metadata'
        ,'ContentAsset' => 'Metadata'
        // Added Spring '17 v39.0 (https://releasenotes.docs.salesforce.com/en-us/spring17/release-notes/rn_api_meta.htm)
        ,'CspTrustedSite' => 'Metadata'
        ,'EclairGeoData' => 'MetadataWithContent'
        ,'ExternalServiceRegistration' => 'Metadata'
        ,'FileUploadAndDownloadSecuritySettings' => 'Metadata'
        ,'LeadConvertSettings' => 'Metadata'
        // ,'PersonalJourneySettings' => 'Metadata' // (option not enabled by default?)
        ,'UserCriteria' => 'Metadata'
        ,'WaveXmd' => 'Metadata'
        // Added Summer '17 v40.0 (https://releasenotes.docs.salesforce.com/en-us/summer17/release-notes/rn_api_meta.htm)
        ,'BrandingSet' => 'Metadata'
        // ,'ChatterExtensions' => 'Metadata' // (option not enabled by default?)
        ,'ProfilePasswordPolicy' => 'Metadata'
        ,'ProfileSessionSetting' => 'Metadata'
        // Added Winter '18 v41.0 (https://releasenotes.docs.salesforce.com/en-us/winter18/release-notes/rn_api_meta.htm)
        //,'CaseSubjectParticle' => 'Metadata'
        ,'EventDelivery' => 'Metadata'
        ,'EventSubscription' => 'Metadata'
        ,'Index' => 'Metadata'
        //,'NetworkBranding' => 'MetadataWithContent'
        //,'SocialCustomerServiceSettings' => 'Metadata'
        //,'TopicsForObjects' => 'Metadata'
		// Added Spring '18 v42.0 (https://releasenotes.docs.salesforce.com/en-us/spring18/release-notes/rn_api_meta.htm)
		,'EmailServicesFunction' => 'Metadata'
		,'EmbeddedServiceBranding' => 'Metadata'
		,'EmbeddedServiceConfig' => 'Metadata'
		,'EmbeddedServiceLiveAgent' => 'Metadata'
		// Added Summer '18 v43.0 (https://releasenotes.docs.salesforce.com/en-us/summer18/release-notes/rn_api_meta.htm)
		,'Bot' => 'Metadata'
		,'BotVersion' => 'Metadata'
		,'CMSConnectSource' => 'Metadata'
		,'EmbeddedServiceFieldService' => 'Metadata'
		,'FlowCategory' => 'Metadata'
		,'LightningBolt' => 'Metadata'
		,'MlDomain' => 'Metadata'
		// Added Winter '19 v44.0 (https://releasenotes.docs.salesforce.com/en-us/winter19/release-notes/rn_api_meta.htm)
		,'Audience' => 'Metadata'
		,'LightningExperienceTheme' => 'Metadata'
		,'OmniChannelSettings' => 'Metadata'
		,'PresenceDeclineReason' => 'Metadata'
		,'PresenceUserConfig' => 'Metadata'
		,'QueueRoutingConfig' => 'Metadata'
		,'ServiceChannel' => 'Metadata'
		,'ServicePresenceStatus' => 'Metadata'
    }; // TODO: Inheritance modifications for Role and Custom Shortcut

    // List of base types to prescan for merging into derived types
    private static final Set<String> METADATA_BASE_TYPES = new Set<String>(METADATA_TYPES.values());

    private static final Set<String> NON_VIRTUAL_TYPES = new Set<String> {
        'CustomValue',
        'GlobalPicklistValue'
    };

    public static void patch()
    {
		// check for objects that we will query in this method (avoid PMD warnings)
		if (!Schema.sObjectType.ApexClass.isQueryable())
		{
			throw new PatchException('You do not have permission to query the "ApexClass" object!');
		}
		if (!Schema.sObjectType.Document.isQueryable())
		{
			throw new PatchException('You do not have permission to query the "Document" object!');
		}
		if (!Schema.sObjectType.Folder.isQueryable())
		{
			throw new PatchException('You do not have permission to query the "Folder" object!');
		}
		// check that we can create/update the 'Document' object (avoid PMD warnings)
		if (!Schema.sObjectType.Document.isCreateable())
		{
			throw new PatchException('You do not have permission to create the "Document" object!');
		}
		if (!Schema.sObjectType.Document.isUpdateable())
		{
			throw new PatchException('You do not have permission to update the "Document" object!');
		}

		// Query the Apex Class generated by the platform WSDL to Apex generator
		ApexClass apexClass = [SELECT Id, Body FROM ApexClass WHERE Name =: MD_IMPORTED_CLASS];

        // Read base types
        Map<String, List<String>> typeBodyByBaseClass = new Map<String, List<String>>();
        LineReader lineReader = new LineReader(apexClass.Body);
        while (lineReader.hasNext())
        {
            // Read line
            String line = commonReplacements(lineReader.next());
            String trimmedLine = line.trim();
            // Class definition?
            if (trimmedLine.startsWith('public class'))
            {
                List<String> parts = trimmedLine.split(' ');
                String className = parts[2];
                // Capture the body of this base type to later inject into another deriving type
                if (METADATA_BASE_TYPES.contains(className))
                {
                    List<String> baseTypeLines = new List<String>();
                    typeBodyByBaseClass.put(className, baseTypeLines);
                    // Move forward until field_order_type_info member
                    while (lineReader.hasNext())
                    {
                        line = commonReplacements(lineReader.next());

                        // Recording content of type for inclusion in deriving types
                        baseTypeLines.add(line);
                        // Stop here
                        if (line.trim().startsWith('private String[] field_order_type_info'))
                        {
                            break;
                        }
                    }
                }
            }
        }

        // Process and scan for lines to modify and/or insert
        lineReader = new LineReader(apexClass.Body);
        List<String> newLines = new List<String>();
        addCopyright(newLines);
        newLines.add('');
        newLines.add('// Patched by MetadataServicePatcher v' + API_VERSION + ' ' + System.today());
        newLines.add('');
        while (lineReader.hasNext())
        {
            // Read line
            String line = commonReplacements(lineReader.next());
            String trimmedLine = line.trim();

            // add static XML Namespace
            if (trimmedLine.startsWith('public class ' + MD_SERVICE_CLASS + ' {'))
            {
                newLines.add(line);
                newLines.add('\tprivate static final String NS = \'http://soap.sforce.com/2006/04/metadata\';');
                continue;
            }

            // Adjust end point logic?
            if (trimmedLine.startsWith('public String endpoint_x'))
            {
                line = '\t\tpublic String endpoint_x = URL.getOrgDomainUrl().toExternalForm() + \'/services/Soap/m/' + API_VERSION + '\';';
            }
            // Adjust update_x method name?
            else if (trimmedLine.contains('update_x('))
            {
                line = line.replace('update_x', 'updateMetadata');
            }
            // Adjust delete_x method name?
            else if (trimmedLine.contains('delete_x('))
            {
                line = line.replace('delete_x', 'deleteMetadata');
            }
            // Adjust retrieve_x method name?
            else if (trimmedLine.contains('retrieve_x('))
            {
                line = line.replace('retrieve_x', 'retrieve');
            }
            // Make Metadata virtual?
            else if (trimmedLine.startsWith('public class Metadata '))
            {
                line = line.replace('public class', 'public virtual class');
                newLines.add(line);
                while (lineReader.hasNext())
                {
                    // read the line and make common replacements
                    line = commonReplacements(lineReader.next());

                    // Skip these, not needed as duplciated in derived classes and cause JSON serialise issues for types
                    if (line.contains('fullName_type_info') ||
                            line.contains('apex_schema_type_info') ||
                            line.contains('field_order_type_info'))
                    {
                        continue;
                    }
                    // add the line
                    newLines.add(line);

                    // loop for the end of the class/method
                    if (line.trim() == '}')
                    {
                        break;
                    }
                }
                continue;
            }
            // Add interfaces to read?
            else if (trimmedLine.startsWith('public class ReadResult'))
            {
                newlines.add('\tpublic interface IReadResult {');
                newlines.add('\t\t' + MD_SERVICE_CLASS + '.Metadata[] getRecords();');
                newlines.add('\t}');
                newlines.add('\tpublic interface IReadResponseElement {');
                newlines.add('\t\tIReadResult getResult();');
                newlines.add('\t}');
                for (String metadataType : METADATA_TYPES.keySet())
                {
                    // Only emit for types extending Metadata or MetadataWithContent
                    String baseClass = METADATA_TYPES.get(metadataType);
                    while (baseClass != null)
                    {
                        if (baseClass == 'Metadata' || baseClass == 'MetadataWithContent')
                        {
                            break;
                        }
                        baseClass = METADATA_TYPES.get(baseClass);
                    }
                    if (baseClass == 'Metadata' || baseClass == 'MetadataWithContent')
                    {
                        String apexClassType = metadataType;
                        if (metadataType == 'Group_x')
                        {
                            apexClassType = 'Group';
                        }
                        else if (metadataType == 'Package_x')
                        {
                            apexClassType = 'Package';
                        }
                        newlines.add('\tpublic class Read' + apexClassType + 'Result implements IReadResult {');
                        newlines.add('\t\tpublic ' + MD_SERVICE_CLASS + '.' + metadataType + '[] records;');
                        newlines.add('\t\tpublic ' + MD_SERVICE_CLASS + '.Metadata[] getRecords() { return records; }');
                        newlines.add('\t\tprivate String[] records_type_info = new String[]{\'records\',NS,null,\'0\',\'-1\',\'false\'};');
                        newlines.add('\t\tprivate String[] apex_schema_type_info = new String[]{NS,\'true\',\'false\'};');
                        newlines.add('\t\tprivate String[] field_order_type_info = new String[]{\'records\'};');
                        newlines.add('\t}');
                        newlines.add('\tpublic class read' + apexClassType + 'Response_element implements IReadResponseElement {');
                        newlines.add('\t\tpublic ' + MD_SERVICE_CLASS + '.Read' + apexClassType + 'Result result;');
                        newlines.add('\t\tpublic IReadResult getResult() { return result; }');
                        newlines.add('\t\tprivate String[] result_type_info = new String[]{\'result\',NS,null,\'1\',\'1\',\'false\'};');
                        newlines.add('\t\tprivate String[] apex_schema_type_info = new String[]{NS,\'true\',\'false\'};');
                        newlines.add('\t\tprivate String[] field_order_type_info = new String[]{\'result\'};');
                        newlines.add('\t}');
                    }
                }
            }
            // readMetadata method?
            else if (trimmedLine.startsWith('public ' + MD_SERVICE_CLASS + '.ReadResult readMetadata(String type_x,String[] fullNames) {'))
            {
                // Swallow up the generated readMetadata method
                while (lineReader.hasNext())
                {
                    // read the line
                    line = lineReader.next();

                    // check if it is the end of the class/method
                    if (line.trim() == '}')
                    {
                        line = commonReplacements(line);
                        break;
                    }
                }
                // Emit the new readMetadata method returnin the IReadResult interface
                newlines.add('\t\tpublic ' + MD_SERVICE_CLASS + '.IReadResult readMetadata(String type_x,String[] fullNames) {');
                newlines.add('\t\t\t' + MD_SERVICE_CLASS + '.readMetadata_element request_x = new ' + MD_SERVICE_CLASS + '.readMetadata_element();');
                newlines.add('\t\t\trequest_x.type_x = type_x;');
                newlines.add('\t\t\trequest_x.fullNames = fullNames;');
                newlines.add('\t\t\t' + MD_SERVICE_CLASS + '.IReadResponseElement response_x;');
                newlines.add('\t\t\tMap<String, ' + MD_SERVICE_CLASS + '.IReadResponseElement> response_map_x = new Map<String, ' + MD_SERVICE_CLASS + '.IReadResponseElement>();');
                newlines.add('\t\t\tresponse_map_x.put(\'response_x\', response_x);');
                newlines.add('\t\t\tWebServiceCallout.invoke(');
                newlines.add('\t\t\t\tthis,');
                newlines.add('\t\t\t\trequest_x,');
                newlines.add('\t\t\t\tresponse_map_x,');
                newlines.add('\t\t\t\tnew String[]{endpoint_x,');
                newlines.add('\t\t\t\t\'\',');
                newlines.add('\t\t\t\tNS,');
                newlines.add('\t\t\t\t\'readMetadata\',');
                newlines.add('\t\t\t\tNS,');
                newlines.add('\t\t\t\t\'readMetadataResponse\',');
                newlines.add('\t\t\t\t\'' + MD_SERVICE_CLASS + '.read\' + type_x + \'Response_element\'}');
                newlines.add('\t\t\t);');
                newlines.add('\t\t\tresponse_x = response_map_x.get(\'response_x\');');
                newlines.add('\t\t\treturn response_x.getResult();');
            }
            // Class definition?
            else if (trimmedLine.startsWith('public class'))
            {
                List<String> parts = trimmedLine.split(' ');
                String className = parts[2];
                // Processing a base type?
                if (METADATA_BASE_TYPES.contains(className) &&
                    // don't make some base types virtual...
                    !NON_VIRTUAL_TYPES.contains(className))
                {
                    String extendsClassName = METADATA_TYPES.get(className);
                    line = line.replace('public class ' + className,
                                        extendsClassName != null ?
                                        'public virtual class ' + className + ' extends ' + extendsClassName :
                                        'public virtual class ' + className);
                    newLines.add(line);
                    while (lineReader.hasNext())
                    {
                        // read the line and make common replacements
                        line = commonReplacements(lineReader.next());
                        trimmedLine = line.trim();

                        // Skip these, not needed as duplciated in derived classes and cause JSON serialise issues for types
                        if (trimmedLine.startsWith('private String[]'))
                        {
                            continue;
                        }

                        // add the line
                        newLines.add(line);

                        // search for end of class/method
                        if (line.trim() == '}')
                        {
                            break;
                        }
                    }
                    continue;
                }
                // Processing a top level type which has a base type?
                else if (METADATA_TYPES.containsKey(className))
                {
                    // Adjust class to extend base class and add base class members (XML serialiser does not support inheritance)
                    String extendsClassName = METADATA_TYPES.get(className);
                    String replace = 'public ' +
                        (METADATA_BASE_TYPES.contains(className) && !NON_VIRTUAL_TYPES.contains(className) ? 'virtual ' : '') +
                        'class ' + className + ' extends ' +
                        // There are a couple types that extend another type that extends 'Metadata', for instance:
                        // PicklistValue extends GlobalPicklistValue extends Metadata
                        // StandardValue extends CustomValue extends Metadata
                        // We need the 'intermediate' class (GlobalPicklistValue or CustomValue in the above examples)
                        // to NOT be virtual, but we need to extend from them. So instead, we will extend the from the
                        // class that the 'intermediate' class extends. If we need more than 3 levels of this, the code
                        // will need to be refactored with a while loop similar to the one below for pulling in fields
                        // from inherited (extended) classes.
                        (NON_VIRTUAL_TYPES.contains(extendsClassName) ? METADATA_TYPES.get(extendsClassName) : extendsClassName);

                    line = line.replace('public class ' + className, replace);
                    newLines.add(line);
                    newLines.add('\t\tpublic String type = \'' + className + '\';');
                    // Keep going all the way down to the last base class
                    List<String> fieldOrderTypeInfoFromBaseType = new List<String>();
                    List<String> baseTypes = new List<String>();
                    String baseClassName = extendsClassName;
                    while (baseClassName != null)
                    {
                        baseTypes.add(baseClassName);
                        baseClassName = METADATA_TYPES.get(baseClassName);
                    }

                    // Merge base class members from the base class upwards
                    for (Integer idx = baseTypes.size() - 1; ; idx--)
                    {
                        baseClassName = baseTypes[idx];

                        for (String baseClassLine : typeBodyByBaseClass.get(baseClassName))
                        {
                            // Skip this base class member as the top level derived type will have one
                            if (baseClassLine.contains('apex_schema_type_info'))
                            {
                                continue;
                            }
                            // Extract the field order type info list to add to the dervived type one
                            if (baseClassLine.contains('field_order_type_info'))
                            {
                                // Extract the list of base type fields
                                if (baseClassLine.indexOf('\'') > 0)
                                {
                                    fieldOrderTypeInfoFromBaseType.add(
                                        baseClassLine.substring(
                                            baseClassLine.indexOf('\''),
                                            baseClassLine.lastIndexOf('\'') + 1));
                                }
                                // Skip it as the top level derived type will have one
                                continue;
                            }
                            newLines.add(baseClassLine);
                        }
                        if (idx == 0)
                        {
                            break;
                        }
                    }
                    // Move forward until field_order_type_info member
                    while (lineReader.hasNext())
                    {
                        line = commonReplacements(lineReader.next());
                        trimmedLine = line.trim();

                        // Adjust the fields listed in the field_order_type_info metadata
                        if (trimmedLine.startsWith('private String[] field_order_type_info'))
                        {
                            // Add type info descriptors and adjust field_order_type_info list
                            newLines.add('\t\tprivate String[] type_att_info = new String[]{\'xsi:type\'};');
                            String newFieldOrderType =
                                fieldOrderTypeInfoFromBaseType.size() > 0 ?
                                String.join(fieldOrderTypeInfoFromBaseType, ',') : '';
                            if (line.endsWith('new String[]{};'))
                            {
                                line = line.replace('new String[]{', 'new String[]{' + newFieldOrderType);
                            }
                            else
                            {
                                line = line.replace('new String[]{', 'new String[]{' + newFieldOrderType + ',');
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
        List<Document> docs = [SELECT Id FROM Document WHERE DeveloperName = 'MetadataServicePatchedCopy'];
        Document generatedCode = docs.size() > 0 ? docs[0] : new Document();
        generatedCode.Name = MD_SERVICE_CLASS;
        generatedCode.Body = Blob.valueOf(patchClass);
        generatedCode.DeveloperName = 'MetadataServicePatchedCopy';
        generatedCode.FolderId = [SELECT Id FROM Folder WHERE DeveloperName = 'MetadataServicePatcher'].Id;
        if (generatedCode.Id == null)
        {
            insert generatedCode;
        }
        else
        {
            update generatedCode;
        }
    }

    public class PatchException extends Exception { }

    /**
     * Utility class to iterate over lines in Apex source code
     **/
    public class LineReader
        implements Iterator<String>, Iterable<String>
    {
        private final String LF = '\n';

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
            if (endPos == -1)
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

        public Iterator<String> iterator()
        {
            return this;
        }
    }

    private static String commonReplacements(String line)
    {

        return line
            // replace spaces with tabs
            .replace('    ', '\t')
            .replace('\t  ', '\t\t')
            // replace the service class name
            .replace(MD_IMPORTED_CLASS, MD_SERVICE_CLASS)
            // replace XML Namespace
            .replace('\'http://soap.sforce.com/2006/04/metadata\'', 'NS')
            .replace('=http://soap.sforce.com/2006/04/metadata\'', '=\' + NS');
    }

    private static void addCopyright(List<String> lines)
    {
        lines.add('/**');
        lines.add(' * Copyright (c), FinancialForce.com, inc');
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