public with sharing class BoxUtilities {
	public BoxUtilities() {
		
	}

	public static string getBoxFileShareURL(String Boxfileid){
		BoxObject2.FolderFile myfiledetails = BoxAPIv2.putFileDefualtShareURL(Boxfileid, false);
		BoxObject2.SharedLink mylink = myfiledetails.shared_link;
		return mylink.url;
	}

	public static string getRecentLenderDocID(String applicationid){
		String recentcreatedtime = (System.now().addMinutes(-30).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'-00:00\''));
		String nowtime = (System.now().formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'-00:00\''));
		String applicaitonname = [Select Name from Application__c WHERE id=:applicationid LIMIT 1].Name;
		String searchquery = '?query='+applicaitonname;
		searchquery += '&type=file&file_extensions=pdf';
		searchquery += '&created_at_range='+recentcreatedtime+','+nowtime;
		BoxObject2.ItemCollection searchresults = BoxAPIv2.search(searchquery, false);
		If (searchresults.total_count>0){
			List<BoxObject2.MiniFolderFile> myfolderfiles = searchresults.entries;
			return myfolderfiles[0].id;
		}
		return '';
	}

	public static string getRecentLenderDocShareURL(String applicationid){
		String lenderdocid = getMostRecentFileinFolder(applicationid);
		if (lenderdocid != null && lenderdocid !=''){
			return getBoxFileShareURL(lenderdocid);
		}
		return '';
	}

	public static string getMostRecentFileinFolder(String applicationid){
		String applicaitonname = [Select Name from Application__c WHERE id=:applicationid LIMIT 1].Name;
		String searchquery = '?query='+applicaitonname;
		searchquery += '&type=folder';
		BoxObject2.ItemCollection searchresults = BoxAPIv2.search(searchquery, false);
		if (searchresults.total_count==0){
			return '';
		}
		List<BoxObject2.MiniFolderFile> myfolders = searchresults.entries;
	 	BoxObject2.ItemCollection folderfiles = BoxAPIv2.getFolderContents(myfolders[0].id, false);

	 	System.debug(folderfiles);
	 	if (folderfiles.total_count==0){
	 		return '';
	 	}
	 	List<BoxObject2.MiniFolderFile> myfolderfiles = folderfiles.entries;

	 	return myfolderfiles[folderfiles.total_count-1].id;
		
	}
}