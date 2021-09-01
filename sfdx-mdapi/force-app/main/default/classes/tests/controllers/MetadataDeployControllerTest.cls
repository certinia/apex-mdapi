@IsTest
private class MetadataDeployControllerTest {

	
	static testMethod void deployZipTest() {
		MetadataService.AsyncResult result = new MetadataService.AsyncResult();
		result.id = 'foo id';
		MetadataPortStub.newInstance().withResultDeploy(result);
		Test.startTest();
		MetadataDeployController controller = new MetadataDeployController();
		PageReference resultPage = controller.deployZip();
		Test.stopTest();
		System.assertEquals(null, resultPage);
		System.assertNotEquals(null, controller.asyncResult, 'AsyncResult is null');
		System.assertEquals(result.id, controller.AsyncResult.id, 'AsyncResult id does not match');
	}

	static void checkAsyncRequestTest(Boolean done, MetadataService.DeployDetails details) {
		MetadataService.DeployResult deployStatus = new MetadataService.DeployResult();
		deployStatus.done = done;
		deployStatus.details = details;
		MetadataPortStub.newInstance().withResultCheckDeployStatus(deployStatus);
		Test.startTest();
		MetadataDeployController controller = new MetadataDeployController();
		MetadataService.AsyncResult asyncResult = new MetadataService.AsyncResult();
		asyncResult.id = 'foo id';
		controller.asyncResult = asyncResult;
		PageReference resultPage = controller.checkAsyncRequest();
		Test.stopTest();
		System.assertEquals(null, resultPage);
	}

	static testMethod void checkAsyncRequestNotDoneTest() {
		checkAsyncRequestTest(false, null);
	}

	static void checkAsyncRequestDoneErrorsTest(String problem) {
		MetadataService.DeployMessage deployMessage = new MetadataService.DeployMessage();
		deployMessage.problem = problem;
		deployMessage.fileName = 'Filename';
		deployMessage.lineNumber = 451;
		deployMessage.columnNumber = 10;
		MetadataService.DeployMessage[] deployMessages = new MetadataService.DeployMessage[] {deployMessage};

		MetadataService.DeployDetails details = new MetadataService.DeployDetails();
		details.componentFailures =  deployMessages;
		checkAsyncRequestTest(true, details);
	}


	static testMethod void checkAsyncRequestDoneErrorsProblemNullTest() {
		checkAsyncRequestDoneErrorsTest(null);
				System.assert(ApexPages.hasMessages(), 'There is no messages');
		System.assertEquals(1, ApexPages.getMessages().size(), 'There are more than 1 message added.' + ApexPages.getMessages());
		ApexPages.Message message = ApexPages.getMessages()[0];
		System.assertEquals(ApexPages.Severity.INFO, message.getSeverity(), 'Severity does not match');
	}

	static testMethod void checkAsyncRequestDoneErrorsProblemNotNullTest() {
		checkAsyncRequestDoneErrorsTest('Problem Message');
		System.assert(ApexPages.hasMessages(), 'There is no messages');
		System.assertEquals(2, ApexPages.getMessages().size(), 'There are more than 1 message added.' + ApexPages.getMessages());
		ApexPages.Message message = ApexPages.getMessages()[1];
		System.assertEquals(ApexPages.Severity.ERROR, message.getSeverity(), 'Severity does not match');
	}

	static testMethod void checkAsyncRequestDoneNoErrorsTest() {
		checkAsyncRequestTest(true, null);
				System.assert(ApexPages.hasMessages(), 'There is no messages');
		System.assertEquals(1, ApexPages.getMessages().size(), 'There are more than 1 message added.' + ApexPages.getMessages());
		ApexPages.Message message = ApexPages.getMessages()[0];
		System.assertEquals(ApexPages.Severity.INFO, message.getSeverity(), 'Severity does not match');
	}

	static testMethod void getPackageXmlTest() {
		Test.startTest();
		MetadataDeployController controller = new MetadataDeployController();
		String xml = controller.getPackageXml();
		Test.stopTest();
		System.assertNotEquals(null, xml);
	}

	static testMethod void getHelloWorldMetadataTest() {
		Test.startTest();
		MetadataDeployController controller = new MetadataDeployController();
		String xml = controller.getHelloWorldMetadata();
		Test.stopTest();
		System.assertNotEquals(null, xml);
	}

	static testMethod void getHelloWorldTest() {
		Test.startTest();
		MetadataDeployController controller = new MetadataDeployController();
		String data = controller.getHelloWorld();
		Test.stopTest();
		System.assertNotEquals(null, data);
	}
}
