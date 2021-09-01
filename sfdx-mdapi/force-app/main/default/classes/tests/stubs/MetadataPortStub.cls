@IsTest
public class MetadataPortStub implements StubProvider {

	private MetadataService.DescribeMetadataResult describeResult;
	private MetadataService.FileProperties[] listMetadata;
	private MetadataService.AsyncResult asyncResult;
	private MetadataService.DeployResult deployStatus;
	private MetadataService.RetrieveResult retrieveStatus;

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
		if (stubbedMethodName == 'deploy')
			return this.asyncResult;
		if (stubbedMethodName == 'checkDeployStatus')
			return this.deployStatus;
		if (stubbedMethodName == 'checkRetrieveStatus')
			return this.retrieveStatus;
		if (stubbedMethodName == 'retrieve')
			return this.asyncResult;
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

	public MetadataPortStub withResultDeploy(MetadataService.AsyncResult asyncResult) {
		this.asyncResult = asyncResult;
		return this;
	}

	public MetadataPortStub withResultCheckDeployStatus(MetadataService.DeployResult deployStatus) {
		this.deployStatus = deployStatus;
		return this;
	}

	public MetadataPortStub withResultRetrieve(MetadataService.AsyncResult asyncResult) {
		this.asyncResult = asyncResult;
		return this;
	}

	public MetadataPortStub withResultCheckRetrieveStatus(MetadataService.RetrieveResult retrieveStatus) {
		this.retrieveStatus = retrieveStatus;
		return this;
	}
}
