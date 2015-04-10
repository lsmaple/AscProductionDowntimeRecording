q2wse`  q <%@ Assembly Name="System.Core, Version=3.5.0.0, Culture=neutral, PublicKeyToken=B77A5C561934E089" %>
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

<%@ Page Language="c#" debug="true" trace="false" %>

<script runat="server">

public class ProductionRuntime
{
    public ProductionRuntime()
    {
        this.ProfileChanges = new List<ProfileChange>();
        this.UnscheduledDowntimes = new List<UnscheduledDowntime>();
    }
    
    private int _id;
    [Newtonsoft.Json.JsonProperty("ID")]
    public int ID { 
        get { return _id; }
        set { _id = value; }
    }

    private string _workCenter;
    [Newtonsoft.Json.JsonProperty("WorkCenter")]
    public string WorkCenter
    {
        get { return _workCenter; }
        set { _workCenter = value; }
    }

    private DateTime _shiftStartDate;
    [Newtonsoft.Json.JsonProperty("ShiftStartDate")]
    public DateTime ShiftStartDate
    {
        get { return _shiftStartDate; }
        set { _shiftStartDate = value; }
    }

    private int _scheduledShiftLength;
    [Newtonsoft.Json.JsonProperty("ScheduledShiftLength")]
    public int ScheduledShiftLength
    {
        get { return _scheduledShiftLength; }
        set { _scheduledShiftLength = value; }
    }

    private int _machineUpTime;
    [Newtonsoft.Json.JsonProperty("MachineUpTime")]
    public int MachineUpTime
    {
        get { return _machineUpTime; }
        set { _machineUpTime = value; }
    }

    private int _primeLinearFeet;
    [Newtonsoft.Json.JsonProperty("PrimeLinearFeet")]
    public int PrimeLinearFeet
    {
        get { return _primeLinearFeet; }
        set { _primeLinearFeet = value; }
    }

    private int _coilChanges;
    [Newtonsoft.Json.JsonProperty("CoilChanges")]
    public int CoilChanges
    {
        get { return _coilChanges; }
        set { _coilChanges = value; }
    }

    private List<ProfileChange> _profileChanges;
    [Newtonsoft.Json.JsonProperty("profileChanges")]
    public List<ProfileChange> ProfileChanges
    {
        get { return _profileChanges; }
        set { _profileChanges = value; }
    }

    private List<UnscheduledDowntime> _unscheduledDowntimes;
    [Newtonsoft.Json.JsonProperty("unscheduledDowntime")]
    public List<UnscheduledDowntime> UnscheduledDowntimes
    {
        get { return _unscheduledDowntimes; }
        set { _unscheduledDowntimes = value; }
    }
}

public class ProfileChange
{
    private int _id;
    [Newtonsoft.Json.JsonProperty("ID")]
    public int ID
    {
        get { return _id; }
        set { _id = value; }
    }

    private string _profileFrom;
    [Newtonsoft.Json.JsonProperty("ProfileFrom")]
    public string ProfileFrom
    {
        get { return _profileFrom; }
        set { _profileFrom = value; }
    }

    private string _profileTo;
    [Newtonsoft.Json.JsonProperty("ProfileTo")]
    public string ProfileTo
    {
        get { return _profileTo; }
        set { _profileTo = value; }
    }

    private string _status;
    [Newtonsoft.Json.JsonProperty("status")]
    public string Status
    {
        get { return _status; }
        set { _status = value; }
    }
}

public class UnscheduledDowntime
{
    private int _id;
    [Newtonsoft.Json.JsonProperty("ID")]
    public int ID
    {
        get { return _id; }
        set { _id = value; }
    }

    private string _profileRunning;
    [Newtonsoft.Json.JsonProperty("ProfileRunning")]
    public string ProfileRunning
    {
        get { return _profileRunning; }
        set { _profileRunning = value; }
    }

    private int _downTime;
    [Newtonsoft.Json.JsonProperty("DownTime")]
    public int DownTime
    {
        get { return _downTime; }
        set { _downTime = value; }
    }

    private string _reasonCode;
    [Newtonsoft.Json.JsonProperty("ReasonCode")]
    public string ReasonCode
    {
        get { return _reasonCode; }
        set { _reasonCode = value; }
    }

    private string _details;
    [Newtonsoft.Json.JsonProperty("Details")]
    public string Details
    {
        get { return _details; }
        set { _details = value; }
    }

    private string _status;
    [Newtonsoft.Json.JsonProperty("status")]
    public string Status
    {
        get { return _status; }
        set { _status = value; }
    }
}


private void Page_Load(object sender, System.EventArgs e)
{
	// This is a very small wrapper around SPList.Items.GetDataTable & Newtonsoft.Json.JsonConvert.SerializeObject
	
	// If you get an error about Newtonsoft, make sure that Newtonsoft.Json.dll & Newtonsoft.Json.xml (.NET v3.5) are in this folder:
	// Request.ServerVariables.Get("APPL_PHYSICAL_PATH") + "\_app_bin", for example:
	// \\svk-spprd01\c$\inetpub\wwwroot\wss\VirtualDirectories\infoscape.steelscape.com80\_app_bin
	
	string json = "{}";
	
	string[] creds = Request.ServerVariables.Get("AUTH_USER").Split('\\');
	string displayName = "";
	// Authenticate:
	SDSAM.UserPrincipal user = null;
	try {
		using (System.Web.Hosting.HostingEnvironment.Impersonate()) { 	// Run in application pool user context
			using (SDSAM.PrincipalContext ctx = new SDSAM.PrincipalContext(SDSAM.ContextType.Domain, creds[0])){
				user = SDSAM.UserPrincipal.FindByIdentity(ctx, SDSAM.IdentityType.SamAccountName,creds[1]);
				// Response.Write(user.GivenName + " " + user.Surname + "<br>");
				//we actually do need to return the DisplayName (Display-Name	displayName)
				displayName = user.DisplayName;
			}
		}
	} catch (Exception ex){
		Newtonsoft.Json.Linq.JObject jObj = new Newtonsoft.Json.Linq.JObject();
        jObj["error"] = ex.ToString();
		json = jObj.ToString();
	}
	if (user == null) {
		Response.StatusCode = 401;
		Response.End();
		return;
	}
	// Indicate JSON Content
	Response.Clear();
	Response.ContentType = "application/json; charset=utf-8";
	//Response.ContentType = "text/plain; charset=utf-8";
	
	
	//StringBuilder log = new StringBuilder();
	string step = "init";
	string fields = "";
	// Grab list - this is VERY fast
	try {
		SPSecurity.RunWithElevatedPrivileges(delegate()
		{
		    using (SPSite site = new SPSite(SPContext.Current.Site.ID)){
				 
				 
				//this aspx file is in http://infoscape.steelscape.com/it/, that's how it knows that we're talking about an IT list
                using (SPWeb web = site.AllWebs[SPContext.Current.Web.ID]){
                    SPList oList = web.Lists["Production Runtime"];
					step = "extract types";
					
					Dictionary<string,Type> columnTypes = new Dictionary<string,Type>();
					foreach(SPField field in oList.Fields){
						columnTypes.Add(field.InternalName, field.FieldValueType);
					}
					
					step = "read json";
					if (Request.RequestType == "POST")
					{
						using (StreamReader sr = new StreamReader(Request.InputStream))
						{
							string srcJson = sr.ReadToEnd();
							Newtonsoft.Json.Linq.JObject jObj = new Newtonsoft.Json.Linq.JObject();
							jObj["srcJson"] = srcJson; //for verification purposes
							Newtonsoft.Json.Linq.JObject jSrc = Newtonsoft.Json.Linq.JObject.Parse(srcJson);
                            ProductionRuntime prodRuntime = Newtonsoft.Json.JsonConvert.DeserializeObject<ProductionRuntime>(srcJson);

                            if (prodRuntime == null) throw new ArgumentException("Unable to get parse data provided.");
                            StringBuilder strb = new StringBuilder();
                            strb.AppendFormat(@"WorkCenter: {0}
ShiftStart: {1}
ShiftLength: {2}
UpTIme: {3}
PrimeLength: {4}
CoilChanges: {5}
ProfileChanges: {6}
UnschedDowntimes: {7}",
                      prodRuntime.WorkCenter, prodRuntime.ShiftStartDate, prodRuntime.ScheduledShiftLength,
                      prodRuntime.MachineUpTime, prodRuntime.PrimeLinearFeet, prodRuntime.CoilChanges,
                      prodRuntime.ProfileChanges.Count, prodRuntime.UnscheduledDowntimes.Count);
                            foreach (ProfileChange pfc in prodRuntime.ProfileChanges)
                            {
                                strb.AppendLine();
                                strb.AppendFormat("ProfileChange: ID: {0}, From: {1}, To: {2}",
                                    pfc.ID, pfc.ProfileFrom, pfc.ProfileTo);
                                strb.AppendLine();
                            }
                            foreach (UnscheduledDowntime usdt in prodRuntime.UnscheduledDowntimes)
                            {
                                strb.AppendLine();
                                strb.AppendFormat("UnscheduledDowntime: ID: {0}, Profile: {1}, Reason: {2}, Duration: {3}, Details: {4}",
                                    usdt.ID, usdt.ProfileRunning, usdt.ReasonCode, usdt.DownTime, usdt.Details);
                                strb.AppendLine();
                                
                            }
                            step = strb.ToString();
                            
							//jObj["test"] = "OK";

                            //int ID = jSrc.GetValue("ID").ToObject<int>();
                            step = "getting item " + prodRuntime.ID.ToString();
                            SPListItem runtimeItem = GetItem(oList, prodRuntime.ID);

                            if (runtimeItem != null)
                            {
                                step = "starting loop";
                                
                                runtimeItem["Scheduled Shift Length"] = Convert.ToDouble(prodRuntime.ScheduledShiftLength);
                                runtimeItem["Machine Up Time"] = Convert.ToDouble(prodRuntime.MachineUpTime);
                                runtimeItem["Prime Linear Feet"] = Convert.ToDouble(prodRuntime.PrimeLinearFeet);
                                runtimeItem["Coil Changes"] = Convert.ToDouble(prodRuntime.CoilChanges);
                                runtimeItem["Shift Start"] = prodRuntime.ShiftStartDate.ToLocalTime();
                                runtimeItem["Work Center"] = prodRuntime.WorkCenter;
                                runtimeItem["Title"] = string.Format("{0} - {1:yyyyMMdd hhmm}",
                                    runtimeItem["Work Center"],
                                    runtimeItem["Shift Start"]);
                                web.AllowUnsafeUpdates = true;
                                runtimeItem.Update();
                                web.AllowUnsafeUpdates = false;
                                
                                if (prodRuntime.ProfileChanges.Count > 0)
                                {
                                    foreach (ProfileChange pc in prodRuntime.ProfileChanges)
                                    {
                                        oList = web.Lists.TryGetList("Production Profile Changes");
                                        SPListItem pcItem = GetItem(oList, pc.ID);
                                        if (pcItem != null)
                                        {
                                            if (pc.Status == "deleted")
                                            {
                                                web.AllowUnsafeUpdates = true;
                                                pcItem.Delete();
                                                web.AllowUnsafeUpdates = false;
                                            }
                                            else
                                            {
                                                pcItem["Work Center"] = prodRuntime.WorkCenter;
                                                pcItem["Shift Start"] = prodRuntime.ShiftStartDate.ToLocalTime();
                                                pcItem["Profile From"] = pc.ProfileFrom;
                                                pcItem["Profile To"] = pc.ProfileTo;
                                                pcItem["Title"] = string.Format(
                                                    "{0} - {1:yyyyMMdd hhmm} - {2} - {3}",
                                                    prodRuntime.WorkCenter,
                                                    prodRuntime.ShiftStartDate.ToLocalTime(),
                                                    pc.ProfileFrom,
                                                    pc.ProfileTo);

                                                web.AllowUnsafeUpdates = true;
                                                pcItem.Update();
                                                web.AllowUnsafeUpdates = false;
                                            }
                                        }
                                    }
                                }
                                
                                if (prodRuntime.UnscheduledDowntimes.Count > 0)
                                {
                                    foreach (UnscheduledDowntime usdt in prodRuntime.UnscheduledDowntimes)
                                    {
                                        oList = web.Lists.TryGetList("Production Unscheduled Downtime");
                                        SPListItem usdtItem = GetItem(oList, usdt.ID);
                                        if (usdtItem != null)
                                        {
                                            if (usdt.Status == "deleted")
                                            {
                                                web.AllowUnsafeUpdates = true;
                                                usdtItem.Delete();
                                                web.AllowUnsafeUpdates = false;
                                            }
                                            else
                                            {
                                                usdtItem["Work Center"] = prodRuntime.WorkCenter;
                                                usdtItem["Shift Start"] = prodRuntime.ShiftStartDate.ToLocalTime();
                                                usdtItem["Profile Running"] = usdt.ProfileRunning;
                                                usdtItem["Down Time"] = Convert.ToDouble(usdt.DownTime);
                                                usdtItem["Reason Code"] = usdt.ReasonCode;
                                                usdtItem["Details"] = usdt.Details;
                                                usdtItem["Title"] = string.Format(
                                                    "{0} - {1:yyyyMMdd hhmm} - {2} - {3}",
                                                    prodRuntime.WorkCenter,
                                                    prodRuntime.ShiftStartDate.ToLocalTime(),
                                                    usdt.ReasonCode, usdt.DownTime);

                                                web.AllowUnsafeUpdates = true;
                                                usdtItem.Update();
                                                web.AllowUnsafeUpdates = false;
                                            }
                                        }
                                    }
                                }
                                json = jObj.ToString();
                            }
						}
					}
				}
			}
		});
	} catch (Exception ex){
		Newtonsoft.Json.Linq.JObject jObj = new Newtonsoft.Json.Linq.JObject();
        jObj["error"] = "outer step: " + step + ", " + ex.Message.ToString() + ", " + ex.StackTrace.ToString();
		jObj[ID.ToString()+"_FieldList"] = fields;
		json = jObj.ToString();
	}
	
	Response.Write(json);
	Response.End();
}

private SPListItem GetItem(SPList list, int ID)
{
    SPListItem item = null;
    if (ID < 0) // new item
    {
        item = list.Items.Add();
    }
    else
    {
        SPQuery query = new SPQuery();
        query.Query = string.Concat(
                       "<Where><Eq>",
                          "<FieldRef Name='ID'/>",
                          "<Value Type='Integer'>",
                           ID.ToString(),
                          "</Value></Eq></Where>"
                         );
        query.RowLimit = 1;
        SPListItemCollection items = list.GetItems(query);
        if (items.Count > 0) item = items[0];
    }
    return item;
}

</script>