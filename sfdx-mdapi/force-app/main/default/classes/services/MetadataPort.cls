public class MetadataPort {

	public static String SOAP_M_URI = 'http://soap.sforce.com/2006/04/metadata';

	public String endpoint_x = URL.getOrgDomainUrl().toExternalForm() + '/services/Soap/m/42.0';
	public Map<String,String> inputHttpHeaders_x;
	public Map<String,String> outputHttpHeaders_x;
	public String clientCertName_x;
	public String clientCert_x;
	public String clientCertPasswd_x;
	public Integer timeout_x;
	public MetadataService.SessionHeader_element SessionHeader;
	public MetadataService.DebuggingInfo_element DebuggingInfo;
	public MetadataService.DebuggingHeader_element DebuggingHeader;
	public MetadataService.CallOptions_element CallOptions;
	public MetadataService.AllOrNoneHeader_element AllOrNoneHeader;
	private String SessionHeader_hns = 'SessionHeader=http://soap.sforce.com/2006/04/metadata';
	private String DebuggingInfo_hns = 'DebuggingInfo=http://soap.sforce.com/2006/04/metadata';
	private String DebuggingHeader_hns = 'DebuggingHeader=http://soap.sforce.com/2006/04/metadata';
	private String CallOptions_hns = 'CallOptions=http://soap.sforce.com/2006/04/metadata';
	private String AllOrNoneHeader_hns = 'AllOrNoneHeader=http://soap.sforce.com/2006/04/metadata';
	private String[] ns_map_type_info = new String[]{SOAP_M_URI, 'MetadataService'};



	public static MetadataPort service = null;

	public static MetadataPort createService() {
		if (service != null)
			return service;
		service = new MetadataPort();
		service.SessionHeader = new MetadataService.SessionHeader_element();
		service.SessionHeader.sessionId = UserInfo.getSessionId();
		return service;
	}


	public MetadataService.DeleteResult[] deleteMetadata(String type_x,String[] fullNames) {
		MetadataService.deleteMetadata_element request_x = new MetadataService.deleteMetadata_element();
		request_x.type_x = type_x;
		request_x.fullNames = fullNames;
		MetadataService.deleteMetadataResponse_element response_x;
		Map<String, MetadataService.deleteMetadataResponse_element> response_map_x = new Map<String, MetadataService.deleteMetadataResponse_element>();
		response_map_x.put('response_x', response_x);
		WebServiceCallout.invoke(
		  this,
		  request_x,
		  response_map_x,
		  new String[]{endpoint_x,
		  '',
		  SOAP_M_URI,
		  'deleteMetadata',
		  SOAP_M_URI,
		  'deleteMetadataResponse',
		  'MetadataService.deleteMetadataResponse_element'}
		);
		response_x = response_map_x.get('response_x');
		return response_x.result;
	}

	public MetadataService.SaveResult renameMetadata(String type_x,String oldFullName,String newFullName) {
		MetadataService.renameMetadata_element request_x = new MetadataService.renameMetadata_element();
		request_x.type_x = type_x;
		request_x.oldFullName = oldFullName;
		request_x.newFullName = newFullName;
		MetadataService.renameMetadataResponse_element response_x;
		Map<String, MetadataService.renameMetadataResponse_element> response_map_x = new Map<String, MetadataService.renameMetadataResponse_element>();
		response_map_x.put('response_x', response_x);
		WebServiceCallout.invoke(
		  this,
		  request_x,
		  response_map_x,
		  new String[]{endpoint_x,
		  '',
		  SOAP_M_URI,
		  'renameMetadata',
		  SOAP_M_URI,
		  'renameMetadataResponse',
		  'MetadataService.renameMetadataResponse_element'}
		);
		response_x = response_map_x.get('response_x');
		return response_x.result;
	}

	public MetadataService.SaveResult[] updateMetadata(MetadataService.Metadata[] metadata) {
		MetadataService.updateMetadata_element request_x = new MetadataService.updateMetadata_element();
		request_x.metadata = metadata;
		MetadataService.updateMetadataResponse_element response_x;
		Map<String, MetadataService.updateMetadataResponse_element> response_map_x = new Map<String, MetadataService.updateMetadataResponse_element>();
		response_map_x.put('response_x', response_x);
		WebServiceCallout.invoke(
		  this,
		  request_x,
		  response_map_x,
		  new String[]{endpoint_x,
		  '',
		  SOAP_M_URI,
		  'updateMetadata',
		  SOAP_M_URI,
		  'updateMetadataResponse',
		  'MetadataService.updateMetadataResponse_element'}
		);
		response_x = response_map_x.get('response_x');
		return response_x.result;
	}

	public MetadataService.DescribeMetadataResult describeMetadata(Double asOfVersion) {
		MetadataService.describeMetadata_element request_x = new MetadataService.describeMetadata_element();
		request_x.asOfVersion = asOfVersion;
		MetadataService.describeMetadataResponse_element response_x;
		Map<String, MetadataService.describeMetadataResponse_element> response_map_x = new Map<String, MetadataService.describeMetadataResponse_element>();
		response_map_x.put('response_x', response_x);
		WebServiceCallout.invoke(
		  this,
		  request_x,
		  response_map_x,
		  new String[]{endpoint_x,
		  '',
		  SOAP_M_URI,
		  'describeMetadata',
		  SOAP_M_URI,
		  'describeMetadataResponse',
		  'MetadataService.describeMetadataResponse_element'}
		);
		response_x = response_map_x.get('response_x');
		return response_x.result;
	}

	public MetadataService.DeployResult checkDeployStatus(String asyncProcessId,Boolean includeDetails) {
		MetadataService.checkDeployStatus_element request_x = new MetadataService.checkDeployStatus_element();
		request_x.asyncProcessId = asyncProcessId;
		request_x.includeDetails = includeDetails;
		MetadataService.checkDeployStatusResponse_element response_x;
		Map<String, MetadataService.checkDeployStatusResponse_element> response_map_x = new Map<String, MetadataService.checkDeployStatusResponse_element>();
		response_map_x.put('response_x', response_x);
		WebServiceCallout.invoke(
		  this,
		  request_x,
		  response_map_x,
		  new String[]{endpoint_x,
		  '',
		  SOAP_M_URI,
		  'checkDeployStatus',
		  SOAP_M_URI,
		  'checkDeployStatusResponse',
		  'MetadataService.checkDeployStatusResponse_element'}
		);
		response_x = response_map_x.get('response_x');
		return response_x.result;
	}

	public MetadataService.RetrieveResult checkRetrieveStatus(String asyncProcessId,Boolean includeZip) {
		MetadataService.checkRetrieveStatus_element request_x = new MetadataService.checkRetrieveStatus_element();
		request_x.asyncProcessId = asyncProcessId;
		request_x.includeZip = includeZip;
		MetadataService.checkRetrieveStatusResponse_element response_x;
		Map<String, MetadataService.checkRetrieveStatusResponse_element> response_map_x = new Map<String, MetadataService.checkRetrieveStatusResponse_element>();
		response_map_x.put('response_x', response_x);
		WebServiceCallout.invoke(
		  this,
		  request_x,
		  response_map_x,
		  new String[]{endpoint_x,
		  '',
		  SOAP_M_URI,
		  'checkRetrieveStatus',
		  SOAP_M_URI,
		  'checkRetrieveStatusResponse',
		  'MetadataService.checkRetrieveStatusResponse_element'}
		);
		response_x = response_map_x.get('response_x');
		return response_x.result;
	}

	public MetadataService.AsyncResult retrieve(MetadataService.RetrieveRequest retrieveRequest) {
		MetadataService.retrieve_element request_x = new MetadataService.retrieve_element();
		request_x.retrieveRequest = retrieveRequest;
		MetadataService.retrieveResponse_element response_x;
		Map<String, MetadataService.retrieveResponse_element> response_map_x = new Map<String, MetadataService.retrieveResponse_element>();
		response_map_x.put('response_x', response_x);
		WebServiceCallout.invoke(
		  this,
		  request_x,
		  response_map_x,
		  new String[]{endpoint_x,
		  '',
		  SOAP_M_URI,
		  'retrieve',
		  SOAP_M_URI,
		  'retrieveResponse',
		  'MetadataService.retrieveResponse_element'}
		);
		response_x = response_map_x.get('response_x');
		return response_x.result;
	}

	public MetadataService.CancelDeployResult cancelDeploy(String String_x) {
		MetadataService.cancelDeploy_element request_x = new MetadataService.cancelDeploy_element();
		request_x.String_x = String_x;
		MetadataService.cancelDeployResponse_element response_x;
		Map<String, MetadataService.cancelDeployResponse_element> response_map_x = new Map<String, MetadataService.cancelDeployResponse_element>();
		response_map_x.put('response_x', response_x);
		WebServiceCallout.invoke(
		  this,
		  request_x,
		  response_map_x,
		  new String[]{endpoint_x,
		  '',
		  SOAP_M_URI,
		  'cancelDeploy',
		  SOAP_M_URI,
		  'cancelDeployResponse',
		  'MetadataService.cancelDeployResponse_element'}
		);
		response_x = response_map_x.get('response_x');
		return response_x.result;
	}

	public String deployRecentValidation(String validationId) {
		MetadataService.deployRecentValidation_element request_x = new MetadataService.deployRecentValidation_element();
		request_x.validationId = validationId;
		MetadataService.deployRecentValidationResponse_element response_x;
		Map<String, MetadataService.deployRecentValidationResponse_element> response_map_x = new Map<String, MetadataService.deployRecentValidationResponse_element>();
		response_map_x.put('response_x', response_x);
		WebServiceCallout.invoke(
		  this,
		  request_x,
		  response_map_x,
		  new String[]{endpoint_x,
		  '',
		  SOAP_M_URI,
		  'deployRecentValidation',
		  SOAP_M_URI,
		  'deployRecentValidationResponse',
		  'MetadataService.deployRecentValidationResponse_element'}
		);
		response_x = response_map_x.get('response_x');
		return response_x.result;
	}

	public MetadataService.DescribeValueTypeResult describeValueType(String type_x) {
		MetadataService.describeValueType_element request_x = new MetadataService.describeValueType_element();
		request_x.type_x = type_x;
		MetadataService.describeValueTypeResponse_element response_x;
		Map<String, MetadataService.describeValueTypeResponse_element> response_map_x = new Map<String, MetadataService.describeValueTypeResponse_element>();
		response_map_x.put('response_x', response_x);
		WebServiceCallout.invoke(
		  this,
		  request_x,
		  response_map_x,
		  new String[]{endpoint_x,
		  '',
		  SOAP_M_URI,
		  'describeValueType',
		  SOAP_M_URI,
		  'describeValueTypeResponse',
		  'MetadataService.describeValueTypeResponse_element'}
		);
		response_x = response_map_x.get('response_x');
		return response_x.result;
	}

	public MetadataService.SaveResult[] createMetadata(MetadataService.Metadata[] metadata) {
		MetadataService.createMetadata_element request_x = new MetadataService.createMetadata_element();
		request_x.metadata = metadata;
		MetadataService.createMetadataResponse_element response_x;
		Map<String, MetadataService.createMetadataResponse_element> response_map_x = new Map<String, MetadataService.createMetadataResponse_element>();
		response_map_x.put('response_x', response_x);
		WebServiceCallout.invoke(
		  this,
		  request_x,
		  response_map_x,
		  new String[]{endpoint_x,
		  '',
		  SOAP_M_URI,
		  'createMetadata',
		  SOAP_M_URI,
		  'createMetadataResponse',
		  'MetadataService.createMetadataResponse_element'}
		);
		response_x = response_map_x.get('response_x');
		return response_x.result;
	}

	public MetadataService.AsyncResult deploy(String ZipFile,MetadataService.DeployOptions DeployOptions) {
		MetadataService.deploy_element request_x = new MetadataService.deploy_element();
		request_x.ZipFile = ZipFile;
		request_x.DeployOptions = DeployOptions;
		MetadataService.deployResponse_element response_x;
		Map<String, MetadataService.deployResponse_element> response_map_x = new Map<String, MetadataService.deployResponse_element>();
		response_map_x.put('response_x', response_x);
		WebServiceCallout.invoke(
		  this,
		  request_x,
		  response_map_x,
		  new String[]{endpoint_x,
		  '',
		  SOAP_M_URI,
		  'deploy',
		  SOAP_M_URI,
		  'deployResponse',
		  'MetadataService.deployResponse_element'}
		);
		response_x = response_map_x.get('response_x');
		return response_x.result;
	}

	public MetadataService.IReadResult readMetadata(String type_x,String[] fullNames) {
		MetadataService.readMetadata_element request_x = new MetadataService.readMetadata_element();
		request_x.type_x = type_x;
		request_x.fullNames = fullNames;
		MetadataService.IReadResponseElement response_x;
		Map<String, MetadataService.IReadResponseElement> response_map_x = new Map<String, MetadataService.IReadResponseElement>();
		response_map_x.put('response_x', response_x);
		WebServiceCallout.invoke(
		  this,
		  request_x,
		  response_map_x,
		  new String[]{endpoint_x,
		  '',
		  SOAP_M_URI,
		  'readMetadata',
		  SOAP_M_URI,
		  'readMetadataResponse',
		  'MetadataService.read' + type_x + 'Response_element'}
		);
		response_x = response_map_x.get('response_x');
		return response_x.getResult();
	}

	public MetadataService.UpsertResult[] upsertMetadata(MetadataService.Metadata[] metadata) {
		MetadataService.upsertMetadata_element request_x = new MetadataService.upsertMetadata_element();
		request_x.metadata = metadata;
		MetadataService.upsertMetadataResponse_element response_x;
		Map<String, MetadataService.upsertMetadataResponse_element> response_map_x = new Map<String, MetadataService.upsertMetadataResponse_element>();
		response_map_x.put('response_x', response_x);
		WebServiceCallout.invoke(
		  this,
		  request_x,
		  response_map_x,
		  new String[]{endpoint_x,
		  '',
		  SOAP_M_URI,
		  'upsertMetadata',
		  SOAP_M_URI,
		  'upsertMetadataResponse',
		  'MetadataService.upsertMetadataResponse_element'}
		);
		response_x = response_map_x.get('response_x');
		return response_x.result;
	}

	public MetadataService.FileProperties[] listMetadata(MetadataService.ListMetadataQuery[] queries,Double asOfVersion) {
		MetadataService.listMetadata_element request_x = new MetadataService.listMetadata_element();
		request_x.queries = queries;
		request_x.asOfVersion = asOfVersion;
		MetadataService.listMetadataResponse_element response_x;
		Map<String, MetadataService.listMetadataResponse_element> response_map_x = new Map<String, MetadataService.listMetadataResponse_element>();
		response_map_x.put('response_x', response_x);
		WebServiceCallout.invoke(
		  this,
		  request_x,
		  response_map_x,
		  new String[]{endpoint_x,
		  '',
		  SOAP_M_URI,
		  'listMetadata',
		  SOAP_M_URI,
		  'listMetadataResponse',
		  'MetadataService.listMetadataResponse_element'}
		);
		response_x = response_map_x.get('response_x');
		return response_x.result;
	}
}
