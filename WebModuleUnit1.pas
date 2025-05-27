unit WebModuleUnit1;

{
  Unit WebModuleUnit1
  
  คำอธิบาย:
  ยูนิตนี้ใช้ในการจัดการโมดูลเว็บที่รับผิดชอบการจัดการคำขอ HTTP ไปยังเซิร์ฟเวอร์ DataSnap
  มันจัดเตรียมอินเทอร์เฟซเว็บสำหรับฟังก์ชันของเซิร์ฟเวอร์และจัดการการส่งต่อคำขอ
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
    
    คลาสโมดูลเว็บที่จัดการคำขอ HTTP และจัดการการรวม DataSnap เซิร์ฟเวอร์
    ประมวลผลคำขอเว็บขาเข้าและส่งต่อไปยังตัวจัดการที่เหมาะสม
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
      กำหนดว่าตัวเรียกฟังก์ชันเซิร์ฟเวอร์สามารถเข้าถึงได้หรือไม่ โดยขึ้นอยู่กับที่อยู่ IP ของไคลเอนต์
      อนุญาตการเข้าถึงจากเครื่องโลคัลโฮสต์ (127.0.0.1 หรือ ::1) เท่านั้น
      @return Boolean - ค่าจริงถ้าการเข้าถึงได้รับอนุญาต ค่าเท็จหากไม่ได้รับอนุญาต
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
  ด้วยเนื้อหาแบบไดนามิก สิ่งนี้ใช้เพื่อแทรกข้อมูลเซิร์ฟเวอร์และการกำหนดค่า
  ลงในหน้า HTML
  
  @param Sender - คอมโพเนนต์ที่ทริกเกอร์เหตุการณ์
  @param Tag - แท็กที่กำลังประมวลผล
  @param TagString - ตัวแทนสตริงของแท็ก
  @param TagParams - พารามิเตอร์ที่เชื่อมโยงกับแท็ก
  @param ReplaceText - ข้อความที่จะแทนที่แท็กด้วย
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
  แสดงหน้าหลักหรือเปลี่ยนเส้นทางไปยังหน้านั้นหากไม่ได้ระบุเส้นทางราก
  
  @param Sender - คอมโพเนนต์ที่ทริกเกอร์เหตุการณ์
  @param Request - อ็อบเจกต์คำขอ HTTP
  @param Response - อ็อบเจกต์การตอบสนอง HTTP
  @param Handled - แฟล็กบูลีนที่ระบุว่าคำขอได้รับการจัดการแล้วหรือไม่
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
  ควบคุมการเข้าถึงตัวเรียกฟังก์ชันเซิร์ฟเวอร์ตาม IP ของไคลเอนต์
  
  @param Sender - คอมโพเนนต์ที่ทริกเกอร์เหตุการณ์
  @param Request - อ็อบเจกต์คำขอ HTTP
  @param Response - อ็อบเจกต์การตอบสนอง HTTP
  @param Handled - แฟล็กบูลีนที่ระบุว่าคำขอได้รับการจัดการแล้วหรือไม่
}
procedure TWebModule1.WebModuleBeforeDispatch(Sender: TObject;
  Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
begin
  if FServerFunctionInvokerAction <> nil then
    FServerFunctionInvokerAction.Enabled := AllowServerFunctionInvoker;
end;

{
  AllowServerFunctionInvoker
  
  กำหนดว่าคำขอปัจจุบันควรได้รับอนุญาตให้เข้าถึงตัวเรียกฟังก์ชันเซิร์ฟเวอร์หรือไม่
  อนุญาตการเข้าถึงจากที่อยู่โลคัลโฮสต์เท่านั้น (127.0.0.1, ::1)
  
  @return Boolean - ค่าจริงถ้าควรให้สิทธิ์การเข้าถึง ค่าเท็จหากไม่ใช่
}
function TWebModule1.AllowServerFunctionInvoker: Boolean;
begin
  Result := (Request.RemoteAddr = '127.0.0.1') or
    (Request.RemoteAddr = '0:0:0:0:0:0:0:1') or (Request.RemoteAddr = '::1');
end;

{
  WebFileDispatcher1BeforeDispatch
  
  ทำงานก่อนที่ตัวส่งไฟล์เว็บจะประมวลผลคำขอไฟล์
  จัดการกรณีพิเศษสำหรับ serverfunctions.js โดยสร้างไฟล์แบบไดนามิกหากจำเป็น
  
  @param Sender - คอมโพเนนต์ที่ทริกเกอร์เหตุการณ์
  @param AFileName - ชื่อของไฟล์ที่ร้องขอ
  @param Request - อ็อบเจกต์คำขอ HTTP
  @param Response - อ็อบเจกต์การตอบสนอง HTTP
  @param Handled - แฟล็กบูลีนที่ระบุว่าคำขอได้รับการจัดการแล้วหรือไม่
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
  
  เริ่มต้นโมดูลเว็บเมื่อมันถูกสร้างขึ้น
  ตั้งค่าคอมโพเนนต์เซิร์ฟเวอร์ DataSnap และเริ่มต้นตัวส่ง HTTP
  
  @param Sender - คอมโพเนนต์ที่ทริกเกอร์เหตุการณ์
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

