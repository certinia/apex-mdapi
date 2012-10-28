Apex Wrapper for Salesforce Metadata API
========================================

Background
-----------

There seems to be a growing number of Apex developers wanting to develop solutions or just handy utils that embrace the declarative nature of the platform. Including those in FinancialForce.com for that matter! Such solutions are dynamically adapting to custom fields or objects that need to be created by the administrator and/or customisations to objects in existing packages.

As adminstrators leverage more and more of these solutions the topic of automation arrises. Can the developers of these solutions help the adminstrator by implementing wizards or self configuring solutions without asking the adminstrator to create these manually and then have to reference them back into the solution?

Strategies
----------

Salesforce provides a great number of API's for developers to consume, both off and on platform (as Apex developers). If you happen to be off platform (say in Heroku) and developing code to help automate adminstration. Then you can utilise the Salesforce Metadata API (via the Salesforce WebService Connector) to help with this. It is a robust and readily available API for creating objects, fields, pages and many other component types.

While Salesforce offer on platform Apex developers a means to query some of this information (a subset of the Metadata API coverage) via Apex Describe. It does not as yet provide a means to manipulate this metadata from Apex natively. We are told this is in the pipeline though I am personally not aware of when this will arrive.

So what can we do in the meantime as Apex developers? Well it turns out that Apex is quite good at making outbound calls to Web Services and more recently REST base API's, all be it as always with a few governors to be aware. So why can Apex not call out to the Metadata Web Services API? After all, there is a WSDL for it and you have the ability as an Apex developer to import a WSDL into Apex and consume the code it generates to make the call, right? Well...

Problems and Solutions
----------------------

Salesforce have been promoting recently the Metadata REST API. While this is still not a native API to Apex, it would be a lot easier to call than the Web Service one, though you would have develop your own wrapper classes. Unfortunatly this API is still in pilot and I have been told by Salesforce its appearance as a GA API is still someway out, sadly.

So you can download the Metadata WSDL from the Tools page under the Develop menu. If you attempt to use it directly (at version 25) you will encounter a number of issues before you can get the resulting Apex class to even compile. Getting it to then make a valid Metadata API call is then another task. 

The main reasons are as follows...

* The port name uses a reserved word, Metadata.
* Some operation names, such as create and update are also reserved words.
* The WSDL2Apex tool does not support polymorphic XML and the Metadata WSDL contains types that extend each other, e.g. CustomObject extends Metadata
* The Apex XML serialiser does not support inheritance (see above point). More specifically it does not see base class members nor does it emit the 'xsi:type' attribute to support polymorphic XML data binding. So the generated Apex code requires a bit of tweaking to support this.
* The Apex language does not support the Zip file format, so the **retrieve** and the **deploy** operations so these are a no go from a pure Apex perspective. However this doesnt stop the of Javascript to handle zips! See sections below on how this has been done.
* Most operations return **AsyncResult** which gives you an Id to call back on to determine the fate of your request. While this can be called, you will need to do this via AJAX, Apex Future or Apex Job. The deploy and retrieve samples utilise apex:actionPoller.

So once we resolve these issues and with a splash of AJAX and Javascript we can now get access to the Metadata API from Apex!

* The following so called CRUD operations appear useable (though I have only tested a subset so far) within Apex, **create**, **update** and **delete**. 
* As well as **listMetadata** and **describeMetadata** (though you may well hit a heap issue here in large orgs). 
* You can also call **checkStatus** to check the status of your requests. 
* With a bit of help from a Javascript library, the infamous **retrieve** and **deploy** also become workable.

**Note:** The CRUD operations do not support Apex Class or Apex Trigger components sadly, this is a API restriction and not an issue with calling from Apex as such.

So I've created this Github repo to capture a modified version of the generated Apex class around the Metadata API. Which addresses the problems above. So that you can download it and get started straight away. Be warned though I have only performed tweaks to some of the more popular component types. I am more than happy if others want to contribute tweaks to others!

Links
-----

**Salesforce Metadata API Developers Guide**
<http://www.salesforce.com/us/developer/docs/api_meta/index.htm>

Examples
--------

**NOTE:** The following examples do not show how to call the checkStatus method. This will need to be done in your Visualforce controller via a timed refresh or via a scheduled job. See the following Retrieve and Deploy demos for how to use apex:actionPoller for this.

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

Metadata Retrieve Demo
----------------------

The [MetadataRetrieveController](https://github.com/financialforcedev/apex-mdapi/blob/master/apex-mdapi/src/classes/MetadataRetrieveController.cls) and [metadataretrieve.page](https://github.com/financialforcedev/apex-mdapi/blob/master/apex-mdapi/src/pages/metadataretrieve.page) samples demonstrate using the excellent [JSZip](http://stuartk.com/jszip/) library to handle the zip retrieve file contents. Passing the zip entries back to the controller for handling in Apex. This sample stores the file data in a list in the controller, though you could send or process the file anyway you see fit. It also shows how to handle the AsyncRequest and checkStatus calls. Enjoy and here is a screenshot!

![Metadata Retrieve Demo Screenshot](https://raw.github.com/financialforcedev/apex-mdapi/master/images/mdretrievedemo.png)

**NOTE:** I nearly got this working without using [JSZip](http://stuartk.com/jszip/), in a pure 100% native Apex and Visualforce way. I utilised the Metadata CRUD API to dynamically upload the zip file as a Static Resource. Then used PageReference.getContent to peak into it! However there seems to be a bug with Static Resources containing files with spaces in their names! No matter how I escapted the URL, I got a 404. I'm researching this further. So watch this space...

Metadata Deploy Demo
---------------------

**IMPORTANT NOTE:** This demo allows you (in theory since I've not tested all) to deploy any Metadata Component types, including ApexClass. In many use cases it is possible to deploy Apex using the existing tools Salesforce provide, changesets, migration toolkit (aka Ant ) and packages. Only utilise this capability if your sure your use case requires it. Note that this does not bypass the need to deploy test code with the correct coverage when deploying into production environments.

The ability to deploy Apex code (and other Metadata component types not covered by the CRUD operations) is something it seems a lot of people have been asking about. Using the JSZip library I have got this working. I also decided to create some Visualforce components to wrap this library to make it a little easier to use. These components are called zip, zipEntry and unzip, you can see them in action on the pages used by this demo and the one above. 

To illustrate error handling, I've shown in the screen shot a deliberate failed deploy, since getting the feedback is just as an important aspect of the solution as a successful one! The key implementation parts of the sample are shown below, enjoy!

![Metadata Deploy Demo Screenshot](https://raw.github.com/financialforcedev/apex-mdapi/master/images/mddeploydemo.png)

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

**NOTE:** I am using Visualforce state (aka Viewstate) and Visualforce AJAX in the above two examples. This will limit the size of the files and zip file being exchanged. Use of JavaScript Remoting will give you increased flexibility in file size (docs state a response size of 15MB is supported). However this will mean storing state in a custom object. In a later revision I may enhance the zip VF components to support this automatically, leaving the controller to simply read and write to the custom object. Finally, keep in mind that you can also for most other Metadata Component types use the CRUD operations as shown above.

You can review the [MetadataDeployController](https://github.com/financialforcedev/apex-mdapi/blob/master/apex-mdapi/src/classes/MetadataDeployController.cls) and [metadatadeploy.page](https://github.com/financialforcedev/apex-mdapi/blob/master/apex-mdapi/src/pages/metadatadeploy.page) for the full code. I have also included for now the zip components, though I may move those out to another repo in due course.

How to create your own MetadataService.cls
------------------------------------------

If you want to repeat what I did on new version of the Metadata WSDL or just want to tweak further component types beyond the ones used in the above examples. Here is how I did it...

     - Generating a valid Apex MetadataService class
          - Edit the WSDL
               - Change the Port name from 'Metadata' to 'MetadataPort'
          - Attempt to generate Apex from this WSDL
               - Give it a better name if you want when prompted, e.g. MetadataService
               - It will error with unexpected name 'update'…. 
               - At this stage copy paste the Apex code from the browser
          - Open Eclipse (or your favourite editor)
               - Paste in the code
               - Edit the method name update to updateMetadata
               - Edit the method name delete to deleteMetadata
               - Upload to server and confirm its saved
     - Making further edits to the Apex code
          - Modify the end point to be dynamic
               - public String endpoint_x = URL.getSalesforceBaseUrl().toExternalForm() + '/services/Soap/m/25.0';
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
About the Author
----------------

My name is Andrew Fawcett, I am the CTO of FinancialForce.com, if you want to ask questions you can do so via the Issues tab or just follow me on Twitter, my name is [andyinthecloud](http://twitter.com/andyinthecloud)

I enjoy making life easier and enabling more people to help me in this endevour! And thus API's is one of my main passions. Hence this article! Enjoy and do let me know what cool time saving solutions you create!