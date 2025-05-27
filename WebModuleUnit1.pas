unit WebModuleUnit1;

{
  Unit WebModuleUnit1
  
  Description:
  This unit implements the web module that handles HTTP requests to the DataSnap server.
  It provides the web interface for the server functions and manages dispatching of requests.
}

interface

uses
  System.SysUtils, System.Classes, Web.HTTPApp, Datasnap.DSHTTPCommon,
  Datasnap.DSHTTPWebBroker, Datasnap.DSServer,
  Web.WebFileDispatcher, Web.HTTPProd,
  DataSnap.DSAuth,
  Datasnap.DSProxyJavaScript, IPPeerServer, Datasnap.DSMetadata,
  Datasnap.DSServerMetadata, Datasnap.DSClientMetadata, Datasnap.DSCommonServer,
  Datasnap.DSHTTP;

type
  {
    TWebModule1
    
    Web module class that handles HTTP requests and manages DataSnap server integration.
    Processes incoming web requests and dispatches them to appropriate handlers.
  }
  TWebModule1 = class(TWebModule)
    DSHTTPWebDispatcher1: TDSHTTPWebDispatcher;
    ServerFunctionInvoker: TPageProducer;
    ReverseString: TPageProducer;
    WebFileDispatcher1: TWebFileDispatcher;
    DSProxyGenerator1: TDSProxyGenerator;
    DSServerMetaDataProvider1: TDSServerMetaDataProvider;
    procedure ServerFunctionInvokerHTMLTag(Sender: TObject; Tag: TTag;
      const TagString: string; TagParams: TStrings; var ReplaceText: string);
    procedure WebModuleDefaultAction(Sender: TObject;
      Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
    procedure WebModuleBeforeDispatch(Sender: TObject;
      Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
    procedure WebFileDispatcher1BeforeDispatch(Sender: TObject;
      const AFileName: string; Request: TWebRequest; Response: TWebResponse;
      var Handled: Boolean);
    procedure WebModuleCreate(Sender: TObject);
  private
    { Private declarations }
    FServerFunctionInvokerAction: TWebActionItem;
    
    { AllowServerFunctionInvoker
      Determines if the server function invoker is accessible based on the client's IP address.
      Only allows access from localhost (127.0.0.1 or ::1).
      @return Boolean - True if access is allowed, False otherwise
    }
    function AllowServerFunctionInvoker: Boolean;
  public
    { Public declarations }
  end;

var
  WebModuleClass: TComponentClass = TWebModule1;

implementation

{%CLASSGROUP 'System.Classes.TPersistent'}

{$R *.dfm}

uses ServerMethodsUnit1, ServerContainerUnit1, Web.WebReq;

{
  ServerFunctionInvokerHTMLTag
  
  Processes HTML tags in the ServerFunctionInvoker template and replaces them
  with dynamic content. This is used to inject server information and configuration
  into the HTML page.
  
  @param Sender - The component that triggered the event
  @param Tag - The tag being processed
  @param TagString - The string representation of the tag
  @param TagParams - Parameters associated with the tag
  @param ReplaceText - The text to replace the tag with
}
procedure TWebModule1.ServerFunctionInvokerHTMLTag(Sender: TObject; Tag: TTag;
  const TagString: string; TagParams: TStrings; var ReplaceText: string);
begin
  if SameText(TagString, 'urlpath') then
    ReplaceText := string(Request.InternalScriptName)
  else if SameText(TagString, 'port') then
    ReplaceText := IntToStr(Request.ServerPort)
  else if SameText(TagString, 'host') then
    ReplaceText := string(Request.Host)
  else if SameText(TagString, 'classname') then
    ReplaceText := ServerMethodsUnit1.TServerMethods1.ClassName
  else if SameText(TagString, 'loginrequired') then
    if DSHTTPWebDispatcher1.AuthenticationManager <> nil then
      ReplaceText := 'true'
    else
      ReplaceText := 'false'
  else if SameText(TagString, 'serverfunctionsjs') then
    ReplaceText := string(Request.InternalScriptName) + '/js/serverfunctions.js'
  else if SameText(TagString, 'servertime') then
    ReplaceText := DateTimeToStr(Now)
  else if SameText(TagString, 'serverfunctioninvoker') then
    if AllowServerFunctionInvoker then
      ReplaceText :=
      '<div><a href="' + string(Request.InternalScriptName) +
      '/ServerFunctionInvoker" target="_blank">Server Functions</a></div>'
    else
      ReplaceText := '';
end;

{
  WebModuleDefaultAction
  
  Default action handler for the web module. 
  Serves the main page or redirects to it if the root path is not specified.
  
  @param Sender - The component that triggered the event
  @param Request - The HTTP request object
  @param Response - The HTTP response object
  @param Handled - Boolean flag indicating if the request has been handled
}
procedure TWebModule1.WebModuleDefaultAction(Sender: TObject;
  Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
begin
  if (Request.InternalPathInfo = '') or (Request.InternalPathInfo = '/')then
    Response.Content := ReverseString.Content
  else
    Response.SendRedirect(Request.InternalScriptName + '/');
end;

{
  WebModuleBeforeDispatch
  
  Executes before the dispatcher processes a request.
  Controls access to server function invoker based on client IP.
  
  @param Sender - The component that triggered the event
  @param Request - The HTTP request object
  @param Response - The HTTP response object
  @param Handled - Boolean flag indicating if the request has been handled
}
procedure TWebModule1.WebModuleBeforeDispatch(Sender: TObject;
  Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
begin
  if FServerFunctionInvokerAction <> nil then
    FServerFunctionInvokerAction.Enabled := AllowServerFunctionInvoker;
end;

{
  AllowServerFunctionInvoker
  
  Determines if the current request should be allowed access to the server function invoker.
  Only allows access from localhost addresses (127.0.0.1, ::1).
  
  @return Boolean - True if access should be granted, False otherwise
}
function TWebModule1.AllowServerFunctionInvoker: Boolean;
begin
  Result := (Request.RemoteAddr = '127.0.0.1') or
    (Request.RemoteAddr = '0:0:0:0:0:0:0:1') or (Request.RemoteAddr = '::1');
end;

{
  WebFileDispatcher1BeforeDispatch
  
  Executes before the web file dispatcher processes a file request.
  Handles special case for serverfunctions.js, generating it dynamically if needed.
  
  @param Sender - The component that triggered the event
  @param AFileName - The name of the requested file
  @param Request - The HTTP request object
  @param Response - The HTTP response object
  @param Handled - Boolean flag indicating if the request has been handled
}
procedure TWebModule1.WebFileDispatcher1BeforeDispatch(Sender: TObject;
  const AFileName: string; Request: TWebRequest; Response: TWebResponse;
  var Handled: Boolean);
var
  D1, D2: TDateTime;
begin
  Handled := False;
  if SameFileName(ExtractFileName(AFileName), 'serverfunctions.js') then
    if not FileExists(AFileName) or (FileAge(AFileName, D1) and FileAge(WebApplicationFileName, D2) and (D1 < D2)) then
    begin
      DSProxyGenerator1.TargetDirectory := ExtractFilePath(AFileName);
      DSProxyGenerator1.TargetUnitName := ExtractFileName(AFileName);
      DSProxyGenerator1.Write;
    end;
end;

{
  WebModuleCreate
  
  Initializes the web module when it is created.
  Sets up the DataSnap server components and starts the HTTP dispatcher.
  
  @param Sender - The component that triggered the event
}
procedure TWebModule1.WebModuleCreate(Sender: TObject);
begin
  FServerFunctionInvokerAction := ActionByName('ServerFunctionInvokerAction');
  DSServerMetaDataProvider1.Server := DSServer;
  DSHTTPWebDispatcher1.Server := DSServer;
  if DSServer.Started then
  begin
    DSHTTPWebDispatcher1.DbxContext := DSServer.DbxContext;
    DSHTTPWebDispatcher1.Start;
  end;
end;

initialization
finalization
  Web.WebReq.FreeWebModules;

end.

