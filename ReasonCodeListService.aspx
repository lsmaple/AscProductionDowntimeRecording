<%@ Assembly Name="System.Core, Version=3.5.0.0, Culture=neutral, PublicKeyToken=B77A5C561934E089" %>
<%@ Assembly Name="System.Data.DataSetExtensions, Version=3.5.0.0, Culture=neutral, PublicKeyToken=B77A5C561934E089" %>
<%@ Assembly Name="System.Web.Extensions, Version=3.5.0.0, Culture=neutral, PublicKeyToken=31BF3856AD364E35" %>
<%@ Assembly Name="System.Xml.Linq, Version=3.5.0.0, Culture=neutral, PublicKeyToken=B77A5C561934E089" %>
<%@ Assembly Name="System.DirectoryServices.AccountManagement, Version=3.5.0.0, Culture=neutral, PublicKeyToken=B77A5C561934E089" %>

<%@ Assembly Name="Newtonsoft.Json"%>


<%@ Import Namespace="System.Configuration" %>

<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.DataSetExtensions" %>
<%@ Import Namespace="System.Drawing" %>
<%@ Import Namespace="System.EnterpriseServices" %>
<%@ Import Namespace="System.Web" %>

<%@ Import Namespace="System.Web.Mobile" %>
<%@ Import Namespace="System.Web.Services" %>
<%@ Import Namespace="System.Xml" %>
<%@ Import Namespace="System.Xml.Linq" %>

<%@ Import Namespace="System.Net" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.IO.Compression" %>
<%@ Import Namespace="System.Collections.Specialized" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="Microsoft.SharePoint" %>
<%@ Import Namespace="Microsoft.SharePoint.Utilities" %>
<%@ Import Namespace="SDSAM=System.DirectoryServices.AccountManagement" %>
<%@ Import Namespace="Newtonsoft.Json" %>

<%@ Page Language="c#" debug="false" trace="false" %>

<script runat="server">
public class ListResult
{
    private string _DisplayName;
	private DataTable _ListData;

    public ListResult() { }

    public string DisplayName
    {
        get { return _DisplayName; }
        set { _DisplayName = value; }
    }

	public DataTable ListData
	{
		get { return _ListData; }
		set { _ListData = value; }
	}
}

private void Page_Load(object sender, System.EventArgs e)
{
    Response.Clear();

    //prevent browser caching
    Response.AppendHeader("Cache-Control", "no-cache"); //HTTP 1.1
    Response.AppendHeader("Cache-Control", "private"); // HTTP 1.1
    Response.AppendHeader("Cache-Control", "no-store"); // HTTP 1.1
    Response.AppendHeader("Cache-Control", "must-revalidate"); // HTTP 1.1
    Response.AppendHeader("Cache-Control", "max-stale=0"); // HTTP 1.1 
    Response.AppendHeader("Cache-Control", "post-check=0"); // HTTP 1.1 
    Response.AppendHeader("Cache-Control", "pre-check=0"); // HTTP 1.1 
    Response.AppendHeader("Pragma", "no-cache"); // HTTP 1.0 
    Response.AppendHeader("Expires", "Mon, 26 Jul 1997 05:00:00 GMT"); // HTTP 1.0

    // Indicate JSON Content
    Response.ContentType = "application/json; charset=utf-8";
    
    string json = "{}";
    
    string[] creds = Request.ServerVariables.Get("AUTH_USER").Split('\\');
    string displayName = "";
    // Authenticate:
    SDSAM.UserPrincipal user = null;
    try
    {
        using (System.Web.Hosting.HostingEnvironment.Impersonate())
        { 	// Run in application pool user context
            using (SDSAM.PrincipalContext ctx = new SDSAM.PrincipalContext(SDSAM.ContextType.Domain, creds[0]))
            {
                user = SDSAM.UserPrincipal.FindByIdentity(ctx, SDSAM.IdentityType.SamAccountName, creds[1]);
                // Response.Write(user.GivenName + " " + user.Surname + "<br>");
                //we actually do need to return the DisplayName (Display-Name	displayName)
                displayName = user.DisplayName.Trim();
            }
        }
    }
    catch (Exception ex)
    {
        Newtonsoft.Json.Linq.JObject jObj = new Newtonsoft.Json.Linq.JObject();
        jObj["error"] = ex.ToString();
        json = jObj.ToString();
    }
    if (user == null)
    {
        Response.StatusCode = 401;
        Response.End();
        return;
    }

    // Grab list - this is VERY fast
    try
    {
        SPSecurity.RunWithElevatedPrivileges(delegate()
        {
            using (SPSite site = new SPSite(SPContext.Current.Site.ID))
            {
                if (site == null) throw new ApplicationException("site is null");
                using (SPWeb web = site.AllWebs[SPContext.Current.Web.ID])
                {
                    if (web == null) throw new ApplicationException("web is null");
                    SPList list = web.Lists["Production Downtime Reason Codes"];
                    if (list == null) throw new ApplicationException("list is null");
                    //DataTable dtItems = list.Items.GetDataTable(); //faster, but way more content (so, slower to compress)

                    if (list.Items == null) throw new ApplicationException("ListItems is null");
                    DataTable dtItems = list.Items.GetDataTable();
                    if (dtItems == null) throw new ApplicationException("dtItems is null");

                    //When SharePoint isn't sure, it just gives up and makes it a string!
                    DataTable dtCloned = dtItems.Clone();
                    if (dtCloned == null) throw new ApplicationException("dtCloned is null");
                    // not required because there are no boolean, yes/no fields
                    //List<string> intColumns = new List<string>(new string[] {
                    //    "Blocked","ItVpPriorityWanted","ItSmtPriorityWanted","ItSmtPriorityLocked"	
                    //});
                    ////
                    //foreach (string columnName in intColumns) dtCloned.Columns[columnName].DataType = typeof(Int32);
                    dtCloned.Load(dtItems.CreateDataReader());

                    ListResult lr = new ListResult();
                    lr.DisplayName = displayName;
                    lr.ListData = dtCloned;
                    json = JsonConvert.SerializeObject(lr, Newtonsoft.Json.Formatting.None);
                    //Formatting.Indented if you want it all fancy, makes it bigger though
                }
            }
        });
    }
    catch (Exception ex)
    {
        Newtonsoft.Json.Linq.JObject jObj = new Newtonsoft.Json.Linq.JObject();
        jObj["error"] = ex.ToString();
        json = jObj.ToString();
    }

    Response.Write(json);
    Response.End();
    return;
}

</script>