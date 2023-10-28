public class MetadataBrowserLwcController {
    public static final Double API_VERSION = 58.0;
    
    @Auraenabled(cacheable=true)
    public static String retrieveDescribeMetadata() {
        MetadataService.MetadataPort service = createService();
        MetadataService.DescribeMetadataResult descMetaResult = service.describeMetadata(API_VERSION);
        System.debug('descMetaResult.organizationNamespace: ' + descMetaResult.organizationNamespace);
        System.debug('descMetaResult.partialSaveAllowed: ' + descMetaResult.partialSaveAllowed);
        System.debug('descMetaResult.testRequired: ' + descMetaResult.testRequired);
        for(MetadataService.DescribeMetadataObject descMetaObj : descMetaResult.metadataObjects) {
            System.debug('descMetaObj.directoryName: ' + descMetaObj.directoryName);
            System.debug('descMetaObj.inFolder: ' + descMetaObj.inFolder);
            System.debug('descMetaObj.metaFile: ' + descMetaObj.metaFile);
            System.debug('descMetaObj.suffix: ' + descMetaObj.suffix);
            System.debug('descMetaObj.xmlName: ' + descMetaObj.xmlName);
            if(descMetaObj.childXmlNames != null) {
                for(String childXmlName : descMetaObj.childXmlNames) {
                    System.debug('childXmlName: ' + childXmlName);
                }
            }
        }
        String descMetaResultJson = JSON.serialize(descMetaResult);
        return descMetaResultJson;
    }
    
    @Auraenabled(cacheable=true)
    public static String retrieveListMetadata(String metadataTypeName) {
        MetadataService.ListMetadataQuery mdQuery = new MetadataService.ListMetadataQuery();
        mdQuery.folder = '';
        mdQuery.type_x = metadataTypeName;
        List<MetadataService.ListMetadataQuery> mdQueries = new List<MetadataService.ListMetadataQuery>{mdQuery};

        MetadataService.MetadataPort service = createService();
        List<MetadataService.FileProperties> listMetaResults = service.listMetadata(mdQueries, API_VERSION);
        String listMetaResultJson = JSON.serialize(listMetaResults);
        return listMetaResultJson;
    }
    
	private static MetadataService.MetadataPort createService() {
		MetadataService.MetadataPort service = new MetadataService.MetadataPort();
		service.SessionHeader = new MetadataService.SessionHeader_element();
		service.SessionHeader.sessionId = getSessionId();
		return service;
    }
    
    private static String getSessionId() {
        return Page.sessionid.getContent().toString();
    }
}