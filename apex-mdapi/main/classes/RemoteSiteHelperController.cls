global class RemoteSiteHelperController {
	
	public String Host {get;set;}
	global String rssNameString {get;set;}
	public String MetadataResponse {get;set;}
	public Boolean MetadataConnectionWarning {get;set;}
	public String MetadataApiException {get;set;}
	global static Exception LastMetadataAPIConnectionException {get; private set;}
	
	global RemoteSiteHelperController() {
		Host = ApexPages.currentPage().getHeaders().get('Host');
				
		// Attempt to connect to the Metadata API
		MetadataConnectionWarning = false;
		if(!RemoteSiteHelperController.checkMetadataAPIConnection())
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Unable to connect to the Salesforce Metadata API.'));
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'A Remote Site Setting must be created in your org before you can use this tool.'));
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Press the Create Remote Site Setting button to perform this step or refer to the post install step below to perform this manually.'));
			MetadataConnectionWarning = true;
			MetadataApiException = '';
			if(RemoteSiteHelperController.LastMetadataAPIConnectionException!=null)
				MetadataApiException = RemoteSiteHelperController.LastMetadataAPIConnectionException.getMessage();
		}
		
	}
	
	public PageReference displayMetadataResponse()
	{
		// Display the response from the client side Metadata API callout
		if(metadataResponse.length()==0)
		{
			String infoString = String.format('Remote Site Setting {0} has been created.',new String[]{rssNameString});
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, infoString));
			MetadataConnectionWarning = false;
		}
		else
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, metadataResponse));
			MetadataConnectionWarning = true;
		}
		return null;
	}

	global static Boolean checkMetadataAPIConnection()
	{
		try {
			MetadataService.MetadataPort service = new MetadataService.MetadataPort();
			service.SessionHeader = new MetadataService.SessionHeader_element();
			service.SessionHeader.sessionId = UserInfo.getSessionId();
			List<MetadataService.ListMetadataQuery> queries = new List<MetadataService.ListMetadataQuery>();		
			MetadataService.ListMetadataQuery remoteSites = new MetadataService.ListMetadataQuery();
			remoteSites.type_x = 'RemoteSiteSetting';
			queries.add(remoteSites);					
			service.listMetadata(queries, 28);			
		} catch (Exception e) {
			LastMetadataAPIConnectionException = e;
			return false;
		}
		LastMetadataAPIConnectionException = null;
		return true;
	}
}