public class MetadataAPI extends MetadataService.MetadataPort {

	public class MetadataAPIException extends Exception {}

	public static MetadataAPI api;

	public static MetadataAPI getInstance() {
		if (api != null)
			return api;
		api = new MetadataAPI();
		api.SessionHeader = new MetadataService.SessionHeader_element();
		api.SessionHeader.sessionId = UserInfo.getSessionId();
		return api;
	}

	public static void validate(Boolean condition, String message) {
		if (condition)
			throw new MetadataAPIException(message);
	}

	public MetadataService.FileProperties[] listMetadata(String[] types) {
		return listMetadata(null, types, null);
	}

	public MetadataService.FileProperties[] listMetadata(String[] folders, String[] types, Decimal version) {
		List<MetadataService.ListMetadataQuery> queries = new List<MetadataService.ListMetadataQuery>();
		for (Integer i=0; i < types.size(); i++) {
			MetadataService.ListMetadataQuery query = new MetadataService.ListMetadataQuery();
			query.type_x = types[i];
			query.folder = folders == null ? null : folders[i];
			queries.add(query);
		}
		return super.listMetadata(queries, version.doubleValue());
	}

	public MetadataService.SaveResult[] updateMetadata(MetadataService.Metadata[] metadatas, Boolean allOrNone) {
		return this.updateMetadata(metadatas);
	}
}
