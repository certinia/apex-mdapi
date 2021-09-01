@IsTest
private class MetadataDataControllerTest {
	static testMethod void constructResponseRootTest() {
		String root = 'root';
		MetadataService.DescribeMetadataResult describeResult = new MetadataService.DescribeMetadataResult();

		MetadataService.DescribeMetadataObject metadataObject = new MetadataService.DescribeMetadataObject();
		metadataObject.xmlName = 'MetadataName';
		metadataObject.childXmlNames = new String[] {'Child1', 'Child2'};
		describeResult.metadataObjects = new MetadataService.DescribeMetadataObject[] {metadataObject};
		MetadataAPIStub stub = MetadataAPIStub.newInstance().withResultDescribeMetadata(describeResult);

		ApexPages.currentPage().getParameters().put('node', root);
		Test.startTest();
		MetadataDataController controller = new MetadataDataController();
		PageReference responsePage = controller.constructResponse();
		Test.stopTest();
		System.assertEquals(null, responsePage, 'This action will always returns null');
		System.assert(String.isNotBlank(controller.data), 'No data found in controller');
		System.assert(controller.data.startsWith('['), 'Error getting JSON data: ' + controller.data);
		MetadataDataController.Node[] nodes =  (MetadataDataController.Node[])JSON.deserialize(controller.data, List<MetadataDataController.FolderNode>.class);
		System.assert(nodes != null && !nodes.isEmpty(), 'There is no node results.');
		for (MetadataDataController.Node node : nodes) {
			System.assertNotEquals('error', node.id, 'There is an error getting metadata. ' + node.text);
		}
	}

	static testMethod void constructResponseNoRootTest() {
		String root = 'ApexClass';
		MetadataService.FileProperties fileProperty = new MetadataService.FileProperties();
		fileProperty.fullName = 'ClassName';
		MetadataService.FileProperties[] properties = new MetadataService.FileProperties[] {fileProperty};
		MetadataAPIStub stub = MetadataAPIStub.newInstance().withResultListMetadata(properties);

		ApexPages.currentPage().getParameters().put('node', root);
		Test.startTest();
		MetadataDataController controller = new MetadataDataController();
		PageReference responsePage = controller.constructResponse();
		Test.stopTest();
		System.assertEquals(null, responsePage, 'This action will always returns null');
		System.assert(String.isNotBlank(controller.data), 'No data found in controller');
		System.assert(controller.data.startsWith('['), 'Error getting JSON data: ' + controller.data);
		MetadataDataController.Node[] nodes =  (MetadataDataController.Node[])JSON.deserialize(controller.data, List<MetadataDataController.LeafNode>.class);
		System.assert(nodes != null && !nodes.isEmpty(), 'There is no node results.');
		for (MetadataDataController.Node node : nodes) {
			System.assertNotEquals('error', node.id, 'There is an error getting metadata. ' + node.text);
		}
	}
}
