@IsTest
private class MetadataRetrieveControllerTest {

	static testMethod void initTest() {
		MetadataService.DescribeMetadataObject metadataObject = new MetadataService.DescribeMetadataObject();
		metadataObject.xmlName = 'CustomObject';
		metadataObject.childXmlNames = new String[] {'CustomField'};
		MetadataService.DescribeMetadataObject[] metadataObjects = new MetadataService.DescribeMetadataObject[] {metadataObject};

		MetadataService.DescribeMetadataResult describeResult = new MetadataService.DescribeMetadataResult();
		describeResult.metadataObjects = metadataObjects;

		MetadataService.FileProperties fileProperty = new MetadataService.FileProperties();
		fileProperty.fullName = 'Account';
		MetadataService.FileProperties[] fileProperties = new MetadataService.FileProperties[] {fileProperty};

		MetadataPortStub.newInstance().withResultDescribeMetadata(describeResult).withResultListMetadata(fileProperties);

		Test.startTest();
		MetadataRetrieveController controller = new MetadataRetrieveController();
		controller.MetaDataFolder = 'foo';
		PageReference resultPage = controller.init();
		Test.stopTest();
		System.assertNotEquals(null, controller.MetaDataType, 'Selected metadata type is null');
		System.assertNotEquals(null, controller.MetaDataTypes, 'Metadata types is null');
		System.assertEquals(2, controller.MetaDataTypes.size(), 'Metadata types options count does not match');
		System.assertNotEquals(null, controller.MetaDataItems, 'Metadata items are null');
		System.assertEquals(1, controller.MetaDataItems.size(), 'Metadata items size does not match');
	}

	static testMethod void retrieveMetadataItemTest() {
		MetadataService.AsyncResult asyncResult = new MetadataService.AsyncResult();
		MetadataPortStub.newInstance().withResultRetrieve(asyncResult);
		Test.startTest();
		MetadataRetrieveController controller = new MetadataRetrieveController();
		PageReference resultPage = controller.retrieveMetadataItem();
		Test.stopTest();
		System.assertNotEquals(null, controller.AsyncResult, 'AsyncResult was not set');
	}

	static void checkAsyncRequestTest(Boolean done, String status, String errorMessage) {
		MetadataService.RetrieveResult retrieveStatus = new MetadataService.RetrieveResult();
		retrieveStatus.done = done;
		retrieveStatus.status = status;
		retrieveStatus.errorMessage = errorMessage;
		MetadataPortStub.newInstance().withResultCheckRetrieveStatus(retrieveStatus);
		Test.startTest();
		MetadataService.AsyncResult asyncResult = new MetadataService.AsyncResult();
		asyncResult.id = 'foo Id';
		MetadataRetrieveController controller = new MetadataRetrieveController();
		controller.AsyncResult = asyncResult;
		PageReference resultPage = controller.checkAsyncRequest();
		Test.stopTest();
	}

	static testMethod void checkAsyncRequestSucceededDoneTest() {
		checkAsyncRequestTest(true, 'Succeeded', null);
	}

	static testMethod void checkAsyncRequestFailureDoneTest() {
		checkAsyncRequestTest(true, 'Failures', 'Failure message');
	}

	static testMethod void checkAsyncRequestPendingTest() {
	checkAsyncRequestTest(false, 'Pending', null);
	}


		static testMethod void receiveMetadataZipFileTest() {
		Test.startTest();
		MetadataRetrieveController controller = new MetadataRetrieveController();
		controller.MetadataFiles = new List<MetadataRetrieveController.MetadataFile>();
		PageReference resultPage = controller.receiveMetadataZipFile();
		Test.stopTest();
		System.assertEquals(null, resultPage);
		System.assertNotEquals(null, controller.MetadataFiles, 'MetadataFiles are null');
		System.assert(!controller.MetadataFiles.isEmpty(), 'MetadataFiles is empty');
		System.assertEquals(1, controller.MetadataFiles.size(), 'There are more than 1 file');
	}

	static testMethod void receiveCompleteTest() {
		Test.startTest();
		MetadataRetrieveController controller = new MetadataRetrieveController();
		PageReference resultPage = controller.receiveComplete();
		Test.stopTest();
		System.assertEquals(null, resultPage);
		System.assertEquals(null, controller.MetaDataRetrieveZip);
	}



}
