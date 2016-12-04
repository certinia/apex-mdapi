Apex Wrapper Salesforce Metadata API
====================================

<a href="https://githubsfdeploy.herokuapp.com?owner=financialforcedev&repo=apex-mdapi">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/src/main/webapp/resources/img/deploy.png">
</a>

Documentation 
-------------

In addition to the documentation in this README, the following blogs also cover the library.

- [Automating the Creation of Flow Screens with Apex Metadata API](http://andyinthecloud.com/2015/11/28/automating-the-creation-of-flow-screens-with-apex-metadata-api/)
- [Apex Metadata API Q&A](http://andyinthecloud.com/2014/11/22/apex-metadata-api-qa/)
- [Apex Metadata API Streamlined and Simplified for Summer’14](http://andyinthecloud.com/2014/08/14/apex-metadata-api-streamlined-and-simplified-for-summer14/)
- [Post Install Apex Metadata API Configuration Solved!](http://andyinthecloud.com/2014/07/29/post-install-apex-metadata-api-configuration-solved/)
- [Apex Metadata API and Spring’14 : Keys to the Kingdom!](http://andyinthecloud.com/2014/04/24/apex-metadata-api-and-spring14-keys-to-the-kingdom/)
- [Introduction to calling the Metadata API from Apex](http://andyinthecloud.com/2013/10/27/introduction-to-calling-the-metadata-api-from-apex/). 
- [Spring’14 Pre-Release : Updating Layouts in Apex](http://andyinthecloud.com/category/metadata-api/)
- [“Look ma, no hands!” : Automating Install and Uninstall of Packages!](http://andyinthecloud.com/2013/06/23/look-ma-no-hands-automating-install-and-uninstall-of-packages/)
- [Scripting the Apex Metadata API and Batch Apex Support](http://andyinthecloud.com/2013/05/06/scripting-the-apex-metadata-api-and-batch-apex-support/)
- [Apex Metadata API Spring’13 Update : Org Settings Access](http://andyinthecloud.com/2013/03/10/apex-metadata-api-spring13-update-org-settings-access/)

This API mirrors as much as possible the API types and operations described in the standard documentation. The behaviour and functionality provided is also as described in the Salesforce documentation, in terms of what metadata is available and accessable via the specific operations.

- [Salesforce Metadata API Developers Guide](https://developer.salesforce.com/docs/atlas.en-us.api_meta.meta/api_meta/)

Showcase
--------

This new section aims to showcase cool tools and applications people are building with this library. If you would like your name and creation in lights here pleaes raise a GitHub issue with the details and we will gladly showcase it!

![Demo Screenshot](https://raw.githubusercontent.com/financialforcedev/apex-mdapi/master/images/showcase-layouteditingviamdapi.png)
**Layout Editing Tool** by [BoonPlus](https://github.com/BoonPlus)

Background and Motivation
-------------------------

There seems to be a growing number of Apex developers wanting to develop solutions or just handy utils that embrace the declarative nature of the platform. Including those in FinancialForce.com for that matter! Such solutions are dynamically adapting to custom fields or objects that need to be created by the administrator and/or customisations to objects in existing packages.

As administrators leverage more and more of these solutions the topic of automation arises. Can the developers of these solutions help the administrator by implementing wizards or self configuring solutions without asking the administrator to create these manually and then have to reference them back into the solution?

Strategies for calling from Apex
--------------------------------

Salesforce provides a great number of API's for developers to consume, both off and on platform (as Apex developers). If you happen to be off platform (say in Heroku) and developing code to help automate administration. Then you can utilise the Salesforce Metadata API (via the Salesforce WebService Connector) to help with this. It is a robust and readily available API for creating objects, fields, pages and many other component types.

While Salesforce offers on platform Apex developers a means to query some of this information (a subset of the Metadata API coverage) via Apex Describe, it does not as yet provide a means to manipulate this metadata from Apex natively. We are told this is in the pipeline, though I am personally not aware of when this will arrive.

Before you read on, stop by and [up vote this idea](https://success.salesforce.com/ideaView?id=08730000000l4TkAAI) to have a native Metadata API!

So what can we do in the meantime as Apex developers? Well it turns out that Apex is quite good at making outbound calls to Web Services and more recently REST based API's, all be it as always with a few governors to be aware. So why can Apex not call out to the Metadata Web Services API? After all, there is a WSDL for it and you have the ability as an Apex developer to import a WSDL into Apex and consume the code it generates to make the call...

Examples
--------

The following examples are a subset of those found in the [MetadataServiceExamples.cls](https://github.com/financialforcedev/apex-mdapi/blob/master/apex-mdapi/src/classes/MetadataServiceExamples.cls). 

```java
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
		List<MetadataService.SaveResult> results = 		
			service.createMetadata(
				new MetadataService.Metadata[] { customObject });		
		handleSaveResults(results[0]);
	}
	
	public static void createField()
	{
		MetadataService.MetadataPort service = createService();		
		MetadataService.CustomField customField = new MetadataService.CustomField();
		customField.fullName = 'Test__c.TestField__c';
		customField.label = 'Test Field';
		customField.type_x = 'Text';
		customField.length = 42;
		List<MetadataService.SaveResult> results = 		
			service.createMetadata(
				new MetadataService.Metadata[] { customField });				
		handleSaveResults(results[0]);
	}

	public static void createPage()
	{
		MetadataService.MetadataPort service = createService();		
		MetadataService.ApexPage apexPage = new MetadataService.ApexPage();
		apexPage.apiVersion = 25;
		apexPage.fullName = 'test';
		apexPage.label = 'Test Page';
		apexPage.content = EncodingUtil.base64Encode(Blob.valueOf('<apex:page/>'));
		List<MetadataService.SaveResult> results = 		
			service.createMetadata(
				new MetadataService.Metadata[] { apexPage });				
		handleSaveResults(results[0]);
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
		MetadataService.FileProperties[] fileProperties = service.listMetadata(queries, 25);
		for(MetadataService.FileProperties fileProperty : fileProperties)
			System.debug(fileProperty.fullName);
	}
	
	public static MetadataService.MetadataPort createService()
	{ 
		MetadataService.MetadataPort service = new MetadataService.MetadataPort();
		service.SessionHeader = new MetadataService.SessionHeader_element();
		service.SessionHeader.sessionId = UserInfo.getSessionId();
		return service;		
	}
```

You can view more examples [here](https://github.com/financialforcedev/apex-mdapi/blob/master/apex-mdapi/src/classes/MetadataServiceExamples.cls). 

Community Examples
------------------

- Thanks to [mohit-address](https://github.com/mohit-address) for submitting examples relating to updating picklist values.
- Thanks to [KGFTW](https://github.com/KGFTW) for submitting an excellent example relating to [cloning reports](https://github.com/financialforcedev/apex-mdapi/issues/147).

**Report Cloning with Apex Metadata API**

```
	/**
	 * Method cloneReport(String sFolderApiName, String sReportApiName, String tFolderApiName, String tReportApiName)
	 * @param sFolderApiName: api name of the (source) folder of the report to clone
	 * @param sReportApiName: api name of the (source) report to clone
	 * @param tFolderApiName: api name of the (target) folder to create the cloned report in
	 * @param tReportApiName: api name of the (target) cloned report 
	 */
	public static void cloneReport(String sFolderApiName, String sReportApiName, String tFolderApiName, String tReportApiName) {
	    MetadataService.MetadataPort service = new MetadataService.MetadataPort();
	    service.SessionHeader = new MetadataService.SessionHeader_element();
	    service.SessionHeader.sessionId = UserInfo.getSessionId();
	
	    // Get the report to clone
	    MetadataService.Report reportToClone = (MetadataService.Report) service.readMetadata('Report', new String[] { sFolderApiName+'/'+sReportApiName }).getRecords()[0];
	
	    // Instanciate a new one to attribute the same metadata from the report to clone
	    MetadataService.Report apexReport = new MetadataService.Report();
	    // Set the cloned report properties from parameters and the source report
	    apexReport.name = reportToClone.name + ' Clone';
	    apexReport.fullName = tFolderApiName + '/' + tReportApiName;
	    apexReport.reportType = reportToClone.reportType;
	    apexReport.description = reportToClone.description;
	    apexReport.format = reportToClone.format;
	    apexReport.filter = reportToClone.filter;
	    apexReport.showDetails = reportToClone.showDetails;
	    apexReport.sortColumn = reportToClone.sortColumn;
	    apexReport.sortOrder = reportToClone.sortOrder;
	    apexReport.groupingsAcross = reportToClone.groupingsAcross;
	    apexReport.groupingsDown = reportToClone.groupingsDown;
	    apexReport.chart = reportToClone.chart;
	    apexReport.timeFrameFilter = reportToClone.timeFrameFilter;
	    apexReport.columns = reportToClone.columns;
	
	    // Create the report clone
	    List<MetadataService.SaveResult> results = service.createMetadata(new MetadataService.Metadata[] { apexReport });
	
	    // Handle results
	    handleSaveResults(results[0]);
	}
```

You can use the [report clone example](https://github.com/financialforcedev/apex-mdapi/blob/master/apex-mdapi/src/classes/MetadataServiceExamples.cls#L1542) like this...

```
MetadataServiceExamples.cloneReport('Source_Folder_Api_Name','Source_Report_Api_Name','Target_Folder_Api_Name','Target_Report_Api_Name');
```

Metadata Retrieve Demo
----------------------

The [MetadataRetrieveController](https://github.com/financialforcedev/apex-mdapi/blob/master/apex-mdapi/src/classes/MetadataRetrieveController.cls) and [metadataretrieve.page](https://github.com/financialforcedev/apex-mdapi/blob/master/apex-mdapi/src/pages/metadataretrieve.page) samples demonstrate using the excellent [JSZip](http://stuartk.com/jszip/) library to handle the zip retrieve file contents, passing the zip entries back to the controller for handling in Apex. This sample stores the file data in a list in the controller, though you could send or process the file anyway you see fit. It also shows how to handle the AsyncRequest and checkStatus calls. Enjoy and here is a screenshot!

![Metadata Retrieve Demo Screenshot](https://raw.github.com/financialforcedev/apex-mdapi/master/images/mdretrievedemo.png)

**NOTE:** I nearly got this working without using [JSZip](http://stuartk.com/jszip/), in a pure 100% native Apex and Visualforce way. I utilised the Metadata CRUD API to dynamically upload the zip file as a Static Resource. Then used PageReference.getContent to peak into it! However there seems to be a bug with Static Resources containing files with spaces in their names! No matter how I escaped the URL, I got a 404. I'm researching this further. So watch this space...

Metadata Deploy Demo
---------------------

**IMPORTANT NOTE:** This demo allows you (in theory since I've not tested all) to deploy any Metadata Component types, including ApexClass. In many use cases it is possible to deploy Apex using the existing tools Salesforce provides: changesets, migration toolkit (aka Ant ) and packages. Only utilise this capability if you're sure your use case requires it. Note that this does not bypass the need to deploy test code with the correct coverage when deploying into production environments.

The ability to deploy Apex code (and other Metadata component types not covered by the CRUD operations) is something it seems a lot of people have been asking about. Using the JSZip library I have got this working. I also decided to create some Visualforce components to wrap this library to make it a little easier to use. These components are called zip, zipEntry and unzip, you can see them in action on the pages used by this demo and the one above. 

To illustrate error handling, I've shown in the screen shot a deliberate failed deploy, since getting the feedback is just as an important aspect of the solution as a successful one! The key implementation parts of the sample are shown below, enjoy!

![Metadata Deploy Demo Screenshot](https://raw.github.com/financialforcedev/apex-mdapi/master/images/mddeploydemo.png)

```java
	public String getPackageXml()
	{
		return '<?xml version="1.0" encoding="UTF-8"?>' + 
			'<Package xmlns="http://soap.sforce.com/2006/04/metadata">' + 
    			'<types>' + 
        			'<members>HelloWorld</members>' +
        			'<name>ApexClass</name>' + 
    			'</types>' + 
    			'<version>26.0</version>' + 
			'</Package>';		
	}
	
	public String getHelloWorldMetadata()
	{
		return '<?xml version="1.0" encoding="UTF-8"?>' +
			'<ApexClass xmlns="http://soap.sforce.com/2006/04/metadata">' +
			    '<apiVersion>26.0</apiVersion>' + 
			    '<status>Active</status>' +
			'</ApexClass>';		
	}

	public String getHelloWorld()	
	{
		return 'public class HelloWorld' + 
			'{' + 
				'public static void helloWorld()' +
				'{' + 
					'System.debug(\' Hello World\');' +
				'}' +
			'}';
	}

	<apex:actionFunction name="deployZip" action="{!deployZip}" rendered="{!ISNULL(AsyncResult)}" rerender="form">
		<apex:param name="data" assignTo="{!ZipData}" value=""/>
	</apex:actionFunction>

	<c:zip name="generateZip" oncomplete="deployZip(data);" rendered="{!ISNULL(AsyncResult)}">
		<c:zipEntry path="package.xml" data="{!PackageXml}"/>
		<c:zipEntry path="classes/HelloWorld.cls-meta.xml" data="{!HelloWorldMetadata}"/>
		<c:zipEntry path="classes/HelloWorld.cls" data="{!HelloWorld}"/>
	</c:zip>
	
	<input type="button" onclick="generateZip();" value="Deploy"/>

	public PageReference deployZip()
	{
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Deploying...'));

		// Deploy zip file posted back from the page action function				
		MetadataService.MetadataPort service = createService();
		MetadataService.DeployOptions deployOptions = new MetadataService.DeployOptions();
        deployOptions.allowMissingFiles = false;
        deployOptions.autoUpdatePackage = false;
        deployOptions.checkOnly = false;
        deployOptions.ignoreWarnings = false;
        deployOptions.performRetrieve = false;
        deployOptions.purgeOnDelete = false;
        deployOptions.rollbackOnError = true;
        deployOptions.runAllTests = false;
        deployOptions.runTests = null;
        deployOptions.singlePackage = true;		
		AsyncResult = service.deploy(ZipData, DeployOptions);				
		return null;
	}
	
```

**NOTE:** I am using Visualforce state (aka Viewstate) and Visualforce AJAX in the above two examples. This will limit the size of the files and zip file being exchanged. Use of JavaScript Remoting will give you increased flexibility in file size (docs state a response size of 15MB is supported). However this will mean storing state in a Custom Object, the slight additional complexity of this I wanted to avoid in these samples. As noted below I have recently (December 2012) enhanced the zip components in another repo, they are based on those in this repo, so are fairly simple to retro fit, take a look at the samples there first. Finally, keep in mind that you can also for most other Metadata Component types use the CRUD operations as shown above, which avoid any zip file handling.

You can review the [MetadataDeployController](https://github.com/financialforcedev/apex-mdapi/blob/master/apex-mdapi/src/classes/MetadataDeployController.cls) and [metadatadeploy.page](https://github.com/financialforcedev/apex-mdapi/blob/master/apex-mdapi/src/pages/metadatadeploy.page) for the full code. I have also included some zip VF components. Starting from December 2012, I created a dedicated repo for zip handling [here](https://github.com/financialforcedev/apex-zip) so if you're interested in these, please refer to this repo for the latest.

Metadata Explore Demo
---------------------

With my recent Sencha skills, I decided to see if I could start the roots of a Metadata Explorer tool, using the **describeMetadata** API call. I've commited the basics of it into the repo, here is a screenshot to give you an idea. It works by using Sencha Stores and the Tree control to incrementally load the tree as the user expands the Metadata Types, quite fun!

![Metadata Browse Demo Screenshot](https://raw.github.com/financialforcedev/apex-mdapi/master/images/mdbrowsedemo.png)

You can study the Visualforce page [here](https://github.com/financialforcedev/apex-mdapi/blob/master/apex-mdapi/src/pages/metadatabrowser.page) which mostly contains the Sencha code, making use of the [metadatadata](https://github.com/financialforcedev/apex-mdapi/blob/master/apex-mdapi/src/pages/metadatadata.page) page as a data proxy for the Sencha store. The controller for this data proxy page is [here](https://github.com/financialforcedev/apex-mdapi/blob/master/apex-mdapi/src/classes/MetadataDataController.cls). Which emits the JSON data (using calls to the describeMetadata API call) used by the Sencha store .

Known Issues and Resolutions
----------------------------

- If you recieve the error message *'Insufficient access; cannot execute Metadata operation with PAC enabled session id'* within Apex code within a managed package utilising this library. Please ensure to changed the API access from Restricted to Unrestricted on your Package definition. Many thanks to the great work from [vipulpahwa](https://github.com/vipulpahwa) and [Daniel Blackhall](https://github.com/seeflat) to getting to the bottom of this rather cryptic error message.
- If you receive the error messag *'System.CalloutException: IO Exception: Read timed out'* then take a look at this excellent resolution to the problem [here](https://github.com/financialforcedev/apex-mdapi/issues/77).

How to call the Salesforce Metadata API from Apex
-------------------------------------------------

Salesforce have been promoting recently the Metadata REST API. While this is still not a native API to Apex, it would be a lot easier to call than the Web Service one, though you would have develop your own wrapper classes. Unfortunatly this API is still in pilot and I have been told by Salesforce its appearance as a GA API is still someway out, sadly.

One option is to download the Metadata WSDL from the Tools page under the Develop menu and attempt to generate Apex code from this, using the Generate from WSDL button. This does not work straight away, some changes to the WSDL and updates to the generated code is required. Fortunately this library has done all this for you, so all you need to do is take the MetadataService.cls and MetadataServiceTest.cls and get started with the examples included.

- [MetadataService.cls](https://github.com/financialforcedev/apex-mdapi/blob/master/apex-mdapi/src/classes/MetadataService.cls)
- [MetadataServiceTest.cls](https://github.com/financialforcedev/apex-mdapi/blob/master/apex-mdapi/src/classes/MetadataServiceTest.cls)
- The following so called CRUD operations are useable within Apex, **createMetadata**, **readMetadata**, **updateMetadata**, **upsertMetadata**, **renameMetadata** and **deleteMetadata**. 
- As well as **listMetadata** and **describeMetadata**. 
- With a bit of help from a Javascript library, the infamous **retrieve** and **deploy** also become workable.

**Note:** The CRUD operations do not support Apex Class or Apex Trigger components sadly, this is a API restriction and not an issue with calling from Apex as such.

I've created this Github repo to capture a modified version of the generated Apex class around the Metadata API, which addresses the problems above so that you can download it and get started straight away.

Remote Site Settings are a must; the tool can help!
---------------------------------------------------
A recent contribution has taken much of the work that was done in the [DLRS Tool](https://github.com/afawcett/declarative-lookup-rollup-summaries) for automating the creation of a remote site setting and turned it into a visualforce component that is easily extensible for anyone needing a remote site setting created. See the [remotesitepage.page](https://github.com/financialforcedev/apex-mdapi/blob/master/apex-mdapi/src/pages/remotesitepage.page) as well as the [remotesitehelper.component](https://github.com/financialforcedev/apex-mdapi/blob/master/apex-mdapi/src/components/remotesitehelper.component) for full code. In short, this page will automatically detect if the salesforce instance you're using can access the metadata api; and if it cannot access, it gives you the ability to specify the remote site setting you want, and automatically populate the correct url. It also allows you to have a simple "welcome style" page that has some fanciness. Here are the component parameters:
- rssName="mdapi"
- rssDescription="SFDC to SFDC metadata api."
- pageOverview="This is an awesome overview of my tool."
- pageOverviewLinkURL="http://google.com"
- pageOverviewLinkText="Google This tool!"
- pageSectionTitle="My Awesome Package Welcome Page"
- pageSectionSubTitle="Welcome"
- pageImageURL="http://someurltoanimage.com/image.png"

Here is what the page will look like with the above configuration.
![Demo Screenshot](https://raw.githubusercontent.com/financialforcedev/apex-mdapi/master/images/remotesitehelper.png)

How to create your own MetadataService.cls
------------------------------------------

**IMPORTANT NOTE:** This library contains a pre-build version of the Metadata API, you only need to follow these steps if the version of the Metadata API you want is not reflected in the repository currently or if you have modified the patcher script to customise it for your own needs.

     - Generating a valid Apex MetadataService class
          - Download and edit the WSDL
               - Change the Port name from 'Metadata' to 'MetadataPort'
               - Add displayLocationInDecimal to the CustomField definition.
                 <xsd:element name="displayLocationInDecimal" minOccurs="0" type="xsd:boolean"/>
               - Add gracePeriodDays to the HistoryRetentionPolicy definition.
                 <xsd:element name="gracePeriodDays" type="xsd:int"/>
               - Locate the CustomMetadataValue complextype, change the type of the 'value' element to 'xsd:string'
               - Locate the FieldValue complextype, change the type of the 'value' element to 'xsd:string'
          - Generate Apex from this WSDL
               - When prompted give it a name of MetadataServiceImported
               - Verify a MetadataServiceImported class has been created
          - Run the Patch script to generate a new MetadataService class (as a Document)
               - Check the Release Notes for API changes, locate the Metadata API section and update MetadataServicePatcher.METADATA_TYPES
               - Update MetadataServicePatcher.API_VERSION
               - Ensure you have a Document Folder called MetadataServicePatcher (Developer Name)
               - Run the following code from execute annoynmous in Developer Console
                     MetadataServicePatcher.patch();
               - Verify this has created a MetadataServicePatched Document in the abov folder
          - Update MetadataService.cls
               - Open the MetadataServicePatched Document and copy the code          
               - Paste the code over the current or new MetadataService.cls class 
                   (recommend MavensMate for this as the file is some 8000+ lines long)
               - Check for any left over references to MetadataServiceImported in MetadataService and change them to MetadataService
          - Update MetadataServiceTest.cls
               - See this for guidelines http://andyinthecloud.com/2013/05/11/code-coverage-for-wsdl2apex-generated-classes
               - Future releases of the patch script may also generate this class
          - Update all the Metadata files to the latest API

**NOTE:** You can review the changes made to the standard Saleforce generated Web Service Apex class for the Metadata API, by reading the comments at the top of the [MetadataServicePatcher.cls](https://github.com/financialforcedev/apex-mdapi/blob/master/apex-mdapi/src/classes/MetadataServicePatcher.cls) class.

Release History
---------------

**Update: 25th June 2016:**
- Updated to Summer'16 v37.0 Metadata API

**Update: 17th April 2016:**
- Updated to Spring'16 v36.0 Metadata API

**Update: 2nd Nov 2015:**
- Updated to Winter'16 v35.0 Metadata API

**Update: 4th May 2015:**
- Created new Remote Site Helper Page.

**Update: 7th April 2015:**
- Updated to **Spring'15 Metadata API (v33.0)**

**Update: 20th November 2014:**
- Updated to **Winter'15 Metadata API (v32.0)**
- Minor changes, some new component types, blog to follow.

**Update: 14th August 2014:**
- Updated to **Summer'14 Metadata API (v31.0)**, signifcant changes to the API, see [blog](http://andyinthecloud.com/2014/08/14/apex-metadata-api-streamlined-and-simplified-for-summer14/).

**Update: 24th April 2014:**
- Updated to **Spring'14 Metadata API (v30.0)**, significant new features, see [blog](http://andyinthecloud.com/2014/04/24/apex-metadata-api-and-spring14-keys-to-the-kingdom/).

**Update: 27th October 2013:**
- A new introduction to the API has been published [here](http://andyinthecloud.com/2013/10/27/introduction-to-calling-the-metadata-api-from-apex/)
- A new supporting Visualforce example has also been created to show how to use apex:actionPoller

**Update: 30th August 2013:**
- Very interesting fix for the 'delete' CRUD operation (for fields), see this StackExchange [answer](http://salesforce.stackexchange.com/questions/15902/how-to-dynamically-set-type-x-value-for-metadata-customfield/15913#15913) for more and the MetadataServiceExamples.deleteField method

**Update: 20th June 2013:**
- Updated to **Summer'13 Metadata API (v28.0)**, more cool stuff to follow on this, such an Apex package installer UI!

**Update: 6th May 2013:**
- Updated MetadataCreateJob.cls, new feature to process Metadata API requests in Batch Apex, see examples.

**Update: 5th May 2013:**
- Updated MetadataServiceTest.cls, now provides 100% code coverage of MetadataService.cls!

**Update: 10th March 2013:**
- Updated to **Spring'13 Metadata API (v27.0)**, more info on new features of this version [here](http://developer.force.com/releases/release/Spring13/Bulk+Metadata+and+Streaming+API+Updates). Also added new samples for Settings configuraiton, see blog [here](http://andyinthecloud.com/2013/03/10/apex-metadata-api-spring13-update-org-settings-access).

**Update: 3rd March 2013:**
- Updated MetadataServiceExample.cls with more sample code creating various field types.

**Update: 11th November 2012:**
- Updated the Retrieve Demo to utilise 'describeMetadata' API call to allow the user to select which Metadata Type to list and retrieve.
- Added 'Metadata Explore' demo (see below) a Sencha powered demo of 'describeMetadata' and 'listMetadata' API's


About the Author
----------------

My name is Andrew Fawcett, I am the CTO of FinancialForce.com, if you want to ask questions you can do so via the Issues tab or just follow me on Twitter, my name is [andyinthecloud](http://twitter.com/andyinthecloud)

I enjoy making life easier and enabling more people to help me in this endeavour! And thus API's are one of my main passions. Hence this article! Enjoy and do let me know what cool time saving solutions you create!
