public with sharing class BoxAPIv2 {
	private static string endpoint = 'https://api.box.com/2.0';

	private static String getBoxResponse(String method, String request, Boolean doDML) {
		return getBoxResponse(method, request, null, doDML);
	}
    
  private static String getBoxResponse(String method, String request, String payload, Boolean doDML) {
    Http h = new Http();
    HttpRequest req = new HttpRequest();
    req.setEndpoint(endpoint + request);
    req.setHeader('Authorization', 'Bearer ' + BoxAuth.authInfo.Auth_Token__c);
    req.setMethod(method);
    if (payload != null) {
    	req.setBody(payload);
    }
    
    HttpResponse res = h.send(req); 
    System.debug(res.getBody());
    if (res.getStatusCode() > 299 ) {
    		error = (BoxObject2.Error)JSON.deserialize(res.getBody(), BoxObject2.Error.class);
        throw new BoxException(error.message);
    }

    // Now that we are done with callouts, we can update the oauth tokens if they changed.
    // if doDML then upsert - is not then do it elsewhere
    if (doDML){
      upsert BoxAuth.authInfo;
    }

    String jsonString = res.getBody();
    // The Box API returns some reserved words. Find and replace them so we can deserialize
    jsonString = jsonString.replace('"limit":', '"limit_x":');
    return jsonString;
  }

  public static BoxObject2.Error error;
  
  public static BoxObject2.FolderFile getFolder(String folderId, Boolean isTrashed, Boolean doDML) {
  	String path = '/folders/' + folderId;
  	if (isTrashed) {
  		path = path + '/trash';
  	}
    return (BoxObject2.FolderFile)JSON.deserialize(getBoxResponse('GET', path, doDML), BoxObject2.FolderFile.class);
  }

  public static BoxObject2.FolderFile getFolder(String folderId, Boolean doDML) {
  	return getFolder(folderId, false, doDML);  
  }

  public static BoxObject2.ItemCollection getFolderContents(String folderId, Boolean doDML){
    return (BoxObject2.ItemCollection)JSON.deserialize(getBoxResponse('GET', '/folders/'+folderId+'/items', doDML), BoxObject2.ItemCollection.class);
  }

  public static BoxObject2.FolderFile createFolder(String name, String parentId, Boolean doDML) {
  	String payload = '{"name":"' + name + '", "parent": {"id": "' + parentId + '"}}';
    return (BoxObject2.FolderFile)JSON.deserialize(getBoxResponse('POST', '/folders', payload, doDML), BoxObject2.FolderFile.class);    
  }

  public static void deleteFolder(String folderId, Boolean doDML) {
  	getBoxResponse('DELETE', '/folders/' + folderId + '?recursive=true', doDML);
  }

  public static BoxObject2.FolderFile getFile(String fileId, Boolean doDML) {
    return (BoxObject2.FolderFile)JSON.deserialize(getBoxResponse('GET', '/files/' + fileId, doDML), BoxObject2.FolderFile.class);    
  }

  public static BoxObject2.FolderFile putFileDefualtShareURL(String fileId, Boolean doDML) {
    String payload = '{"shared_link": {}}';
    return (BoxObject2.FolderFile)JSON.deserialize(getBoxResponse('PUT', '/files/'+ fileId,payload, doDML), BoxObject2.FolderFile.class);
  }

  public static void deleteFile(String fileId, Boolean doDML) {
    getBoxResponse('DELETE', '/files/' + fileId, doDML);
  }

  public static BoxObject2.Collaboration addCollaboration(String folderId, String email, String role, Boolean doDML) {
  	String payload = '{"item": { "id": "' + folderId + '", "type": "folder"}, "accessible_by": { "login": "' + email + '", "type": "user" }, "role": "' + role + '"}';
  	return (BoxObject2.Collaboration)JSON.deserialize(getBoxResponse('POST', '/collaborations', payload, doDML), BoxObject2.Collaboration.class);
  }

  public static BoxObject2.CollaborationCollection getFolderCollaboration(String folderId, Boolean doDML) {
  	return (BoxObject2.CollaborationCollection)JSON.deserialize(getBoxResponse('GET', '/folders/' + folderId + '/collaborations', doDML), BoxObject2.CollaborationCollection.class); 
  }

  public static BoxObject2.User getCurrentUser(Boolean doDML) {
  	return (BoxObject2.User)JSON.deserialize(getBoxResponse('GET', '/users/me', doDML), BoxObject2.User.class); 
  }

  public static BoxObject2.ItemCollection search(String searchquery, Boolean doDML){
    return (BoxObject2.ItemCollection)JSON.deserialize(getBoxResponse('GET', '/search' + searchquery, doDML), BoxObject2.ItemCollection.class);    
 }

  public static PageReference getFileDownloadLink(String fileId) {
    Http h = new Http();
    HttpRequest req = new HttpRequest();
    req.setEndpoint(endpoint + '/files/' + fileId + '/content');
    req.setHeader('Authorization', 'Bearer ' + BoxAuth.authInfo.Auth_Token__c);
    req.setMethod('GET');

    HttpResponse res = h.send(req);
    PageReference pr;
    // Box returns a redirect to download the file
    if (res.getStatusCode() == 302) {
      pr = new PageReference(res.getHeader('Location'));
    }
    return pr;
  }
}