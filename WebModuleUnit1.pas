unit WebModuleUnit1;

{
  Unit WebModuleUnit1
  
  คำอธิบาย:
  ยูนิตนี้ทำหน้าที่เป็นโมดูลเว็บที่จัดการคำขอ HTTP ไปยัง DataSnap server
  มันจัดเตรียมอินเตอร์เฟซเว็บสำหรับฟังก์ชันของเซิร์ฟเวอร์และจัดการการส่งคำขอต่าง ๆ
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
    
    คลาสโมดูลเว็บที่จัดการคำขอ HTTP และจัดการการบูรณาการกับ DataSnap server
    ประมวลผลคำขอเว็บที่เข้ามาและกระจายพวกมันไปยังตัวจัดการที่เหมาะสม
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
      กำหนดว่า server function invoker สามารถเข้าถึงได้จากที่อยู่ IP ของไคลเอนต์หรือไม่
      อนุญาตเฉพาะการเข้าถึงจาก localhost (127.0.0.1 หรือ ::1) เท่านั้น
      @return Boolean - True ถ้าการเข้าถึงได้รับอนุญาต, False ถ้าไม่ได้รับอนุญาต
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
  
  ประมวลผลแท็ก HTML ในเทมเพลต ServerFunctionInvoker และแทนที่พวกมัน
  ด้วยเนื้อหาแบบไดนามิก นี่ถูกใช้เพื่อแทรกข้อมูลและการตั้งค่าของเซิร์ฟเวอร์
  ลงในหน้า HTML
  
  @param Sender - คอมโพเนนต์ที่กระตุ้นเหตุการณ์
  @param Tag - แท็กที่กำลังประมวลผล
  @param TagString - ข้อความของแท็ก
  @param TagParams - พารามิเตอร์ที่เกี่ยวข้องกับแท็ก
  @param ReplaceText - ข้อความที่จะแทนที่แท็ก
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
  
  ตัวจัดการการกระทำเริ่มต้นสำหรับโมดูลเว็บ
  แสดงหน้าหลักหรือเปลี่ยนเส้นทางไปยังหน้าหลักถ้าไม่ได้ระบุเส้นทางหลัก
  
  @param Sender - คอมโพเนนต์ที่กระตุ้นเหตุการณ์
  @param Request - ออบเจ็กต์คำขอ HTTP
  @param Response - ออบเจ็กต์การตอบสนอง HTTP
  @param Handled - ตัวแปรบูลีนที่ระบุว่าคำขอถูกจัดการแล้วหรือไม่
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
  
  ทำงานก่อนที่ตัวส่งคำขอจะประมวลผลคำขอ
  ควบคุมการเข้าถึง server function invoker จากที่อยู่ IP ของไคลเอนต์
  
  @param Sender - คอมโพเนนต์ที่กระตุ้นเหตุการณ์
  @param Request - ออบเจ็กต์คำขอ HTTP
  @param Response - ออบเจ็กต์การตอบสนอง HTTP
  @param Handled - ตัวแปรบูลีนที่ระบุว่าคำขอถูกจัดการแล้วหรือไม่
}
procedure TWebModule1.WebModuleBeforeDispatch(Sender: TObject;
  Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
begin
  if FServerFunctionInvokerAction <> nil then
    FServerFunctionInvokerAction.Enabled := AllowServerFunctionInvoker;
end;

{
  AllowServerFunctionInvoker
  
  กำหนดว่าคำขอปัจจุบันควรได้รับอนุญาตให้เข้าถึง server function invoker หรือไม่
  อนุญาตเฉพาะการเข้าถึงจากที่อยู่ localhost (127.0.0.1, ::1) เท่านั้น
  
  @return Boolean - True ถ้าการเข้าถึงควรได้รับอนุญาต, False ถ้าไม่ควรอนุญาต
}
function TWebModule1.AllowServerFunctionInvoker: Boolean;
begin
  Result := (Request.RemoteAddr = '127.0.0.1') or
    (Request.RemoteAddr = '0:0:0:0:0:0:0:1') or (Request.RemoteAddr = '::1');
end;

{
  WebFileDispatcher1BeforeDispatch
  
  ทำงานก่อนที่ตัวส่งไฟล์เว็บจะประมวลผลคำขอไฟล์
  จัดการกรณีพิเศษสำหรับ serverfunctions.js โดยสร้างมันแบบไดนามิกถ้าจำเป็น
  
  @param Sender - คอมโพเนนต์ที่กระตุ้นเหตุการณ์
  @param AFileName - ชื่อของไฟล์ที่ถูกร้องขอ
  @param Request - ออบเจ็กต์คำขอ HTTP
  @param Response - ออบเจ็กต์การตอบสนอง HTTP
  @param Handled - ตัวแปรบูลีนที่ระบุว่าคำขอถูกจัดการแล้วหรือไม่
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
  
  เริ่มต้นโมดูลเว็บเมื่อถูกสร้างขึ้น
  ตั้งค่าคอมโพเนนต์ DataSnap server และเริ่ม HTTP dispatcher
  
  @param Sender - คอมโพเนนต์ที่กระตุ้นเหตุการณ์
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

