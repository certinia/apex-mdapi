@IsTest
public class MetadataAPIStub implements StubProvider {

	private MetadataService.DescribeMetadataResult describeResult;
	private MetadataService.FileProperties[] listMetadata;
	private MetadataService.AsyncResult asyncResult;
	private MetadataService.DeployResult deployStatus;
	private MetadataService.RetrieveResult retrieveStatus;

	public static MetadataAPIStub newInstance() {
		MetadataAPIStub stub = new MetadataAPIStub();
		MetadataAPI.api = (MetadataAPI) Test.createStub(MetadataAPI.class, stub);
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

	public MetadataAPIStub withResultDescribeMetadata(MetadataService.DescribeMetadataResult describeResult) {
		this.describeResult = describeResult;
		return this;
	}

	public MetadataAPIStub withResultListMetadata(MetadataService.FileProperties[] listMetadata) {
		this.listMetadata = listMetadata;
		return this;
	}

	public MetadataAPIStub withResultDeploy(MetadataService.AsyncResult asyncResult) {
		this.asyncResult = asyncResult;
		return this;
	}

	public MetadataAPIStub withResultCheckDeployStatus(MetadataService.DeployResult deployStatus) {
		this.deployStatus = deployStatus;
		return this;
	}

	public MetadataAPIStub withResultRetrieve(MetadataService.AsyncResult asyncResult) {
		this.asyncResult = asyncResult;
		return this;
	}

	public MetadataAPIStub withResultCheckRetrieveStatus(MetadataService.RetrieveResult retrieveStatus) {
		this.retrieveStatus = retrieveStatus;
		return this;
	}
}
