@IsTest
public class MetadataPortStub implements StubProvider {

	private MetadataService.DescribeMetadataResult describeResult;
	private MetadataService.FileProperties[] listMetadata;

	public static MetadataPortStub newInstance() {
		MetadataPortStub stub = new MetadataPortStub();
		MetadataPort.service = (MetadataPort) Test.createStub(MetadataPort.class, stub);
		return stub;
	}

	public Object handleMethodCall(Object stubbedObject, String stubbedMethodName, System.Type returnType, List<System.Type> listOfParamTypes, List<String> listOfParamNames, List<Object> listOfArgs) {
		if (stubbedMethodName == 'describeMetadata')
			return this.describeResult;
		if (stubbedMethodName == 'listMetadata')
			return this.listMetadata;
		return null;
	}

	public MetadataPortStub withResultDescribeMetadata(MetadataService.DescribeMetadataResult describeResult) {
		this.describeResult = describeResult;
		return this;
	}

	public MetadataPortStub withResultListMetadata(MetadataService.FileProperties[] listMetadata) {
		this.listMetadata = listMetadata;
		return this;
	}
}
