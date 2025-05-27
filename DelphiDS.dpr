program DelphiDS;
{
  DelphiDS - แอปพลิเคชัน Delphi DataSnap Server
  
  นี่เป็นไฟล์โปรเจ็กต์หลักสำหรับแอปพลิเคชัน DataSnap server
  เป็นแอปพลิเคชันคอนโซลที่โฮสต์ DataSnap server
  ซึ่งอนุญาตให้ไคลเอนต์ระยะไกลเรียกใช้เมธอดของเซิร์ฟเวอร์ผ่าน HTTP
}

{$APPTYPE CONSOLE}

{$R *.dres}

uses
  System.SysUtils,
  System.Types,
  IPPeerServer,
  IPPeerAPI,
  IdHTTPWebBrokerBridge,
  Web.WebReq,
  Web.WebBroker,
  Datasnap.DSSession,
  ServerMethodsUnit1 in 'ServerMethodsUnit1.pas' {ServerMethods1: TDSServerModule},
  ServerContainerUnit1 in 'ServerContainerUnit1.pas' {ServerContainer1: TDataModule},
  WebModuleUnit1 in 'WebModuleUnit1.pas' {WebModule1: TWebModule},
  ServerConst1 in 'ServerConst1.pas';

{$R *.res}

{
  TerminateThreads
  
  ยุติทุกเซสชัน DataSnap ก่อนปิดเซิร์ฟเวอร์
}
procedure TerminateThreads;
begin
  if TDSSessionManager.Instance <> nil then
    TDSSessionManager.Instance.TerminateAllSessions;
end;

{
  BindPort
  
  พยายามผูกกับพอร์ตที่ระบุเพื่อตรวจสอบว่าพร้อมใช้งานหรือไม่
  
  @param APort - หมายเลขพอร์ตที่ต้องการทดสอบ
  @return Boolean - คืนค่า True ถ้าพอร์ตพร้อมใช้งาน, False ถ้าไม่พร้อม
}
function BindPort(APort: Integer): Boolean;
var
  LTestServer: IIPTestServer;
begin
  Result := True;
  try
    LTestServer := PeerFactory.CreatePeer('', IIPTestServer) as IIPTestServer;
    LTestServer.TestOpenPort(APort, nil);
  except
    Result := False;
  end;
end;

{
  CheckPort
  
  ตรวจสอบว่าพอร์ตพร้อมใช้งานหรือไม่
  
  @param APort - หมายเลขพอร์ตที่ต้องการตรวจสอบ
  @return Integer - คืนค่า APort ถ้าพร้อมใช้งาน หรือ 0 ถ้าไม่พร้อม
}
function CheckPort(APort: Integer): Integer;
begin
  if BindPort(APort) then
    Result := APort
  else
    Result := 0;
end;

{
  SetPort
  
  เปลี่ยนพอร์ตที่เซิร์ฟเวอร์รับฟังหากเซิร์ฟเวอร์ยังไม่ถูกเปิดใช้งาน
  
  @param AServer - อินสแตนซ์ของเซิร์ฟเวอร์ HTTP
  @param APort - สตริงตัวเลขพอร์ตที่ต้องการกำหนด
}
procedure SetPort(const AServer: TIdHTTPWebBrokerBridge; APort: String);
begin
  if not AServer.Active then
  begin
    APort := APort.Replace(cCommandSetPort, '').Trim;
    if CheckPort(APort.ToInteger) > 0 then
    begin
      AServer.DefaultPort := APort.ToInteger;
      Writeln(Format(sPortSet, [APort]));
    end
    else
      Writeln(Format(sPortInUse, [APort]));
  end
  else
    Writeln(sServerRunning);
  Write(cArrow);
end;

{
  StartServer
  
  พยายามเริ่มเซิร์ฟเวอร์บนพอร์ตที่ระบุ
  
  @param AServer - อินสแตนซ์ของเซิร์ฟเวอร์ HTTP ที่ต้องการเริ่มทำงาน
}
procedure StartServer(const AServer: TIdHTTPWebBrokerBridge);
begin
  if not AServer.Active then
  begin
    if CheckPort(AServer.DefaultPort) > 0 then
    begin
      Writeln(Format(sStartingServer, [AServer.DefaultPort]));
      AServer.Bindings.Clear;
      AServer.Active := True;
    end
    else
      Writeln(Format(sPortInUse, [AServer.DefaultPort.ToString]));
  end
  else
    Writeln(sServerRunning);
  Write(cArrow);
end;

{
  StopServer
  
  หยุดเซิร์ฟเวอร์ที่กำลังทำงานอยู่และยุติเซสชันทั้งหมด
  
  @param AServer - อินสแตนซ์ของเซิร์ฟเวอร์ HTTP ที่ต้องการหยุด
}
procedure StopServer(const AServer: TIdHTTPWebBrokerBridge);
begin
  if AServer.Active then
  begin
    Writeln(sStoppingServer);
    TerminateThreads;
    AServer.Active := False;
    AServer.Bindings.Clear;
    Writeln(sServerStopped);
  end
  else
    Writeln(sServerNotRunning);
  Write(cArrow);
end;

{
  WriteCommands
  
  แสดงรายการคำสั่งที่ใช้ได้ในคอนโซล
}
procedure WriteCommands;
begin
  Writeln(sCommands);
  Write(cArrow);
end;

{
  WriteStatus
  
  แสดงสถานะปัจจุบันของเซิร์ฟเวอร์ HTTP
  
  @param AServer - อินสแตนซ์ของเซิร์ฟเวอร์ HTTP
}
procedure WriteStatus(const AServer: TIdHTTPWebBrokerBridge);
begin
  Writeln(sIndyVersion + AServer.SessionList.Version);
  Writeln(sActive + AServer.Active.ToString(TUseBoolStrs.True));
  Writeln(sPort + AServer.DefaultPort.ToString);
  Writeln(sSessionID + AServer.SessionIDCookieName);
  Write(cArrow);
end;

{
  RunServer
  
  ฟังก์ชันหลักของเซิร์ฟเวอร์ที่เริ่มต้นเซิร์ฟเวอร์ HTTP และจัดการคำสั่งคอนโซล
  ฟังก์ชันนี้จะเข้าสู่ลูปคำสั่งจนกว่าผู้ใช้จะออกจากโปรแกรม
  
  @param APort - พอร์ตเริ่มต้นที่จะใช้สำหรับเซิร์ฟเวอร์
}
procedure RunServer(APort: Integer);
var
  LServer: TIdHTTPWebBrokerBridge;
  LResponse: string;
begin
  WriteCommands;
  LServer := TIdHTTPWebBrokerBridge.Create(nil);
  try
    LServer.DefaultPort := APort;
    while True do
    begin
      Readln(LResponse);
      LResponse := LowerCase(LResponse);
      if LResponse.StartsWith(cCommandSetPort) then
        SetPort(LServer, LResponse)
      else if sametext(LResponse, cCommandStart) then
        StartServer(LServer)
      else if sametext(LResponse, cCommandStatus) then
        WriteStatus(LServer)
      else if sametext(LResponse, cCommandStop) then
        StopServer(LServer)
      else if sametext(LResponse, cCommandHelp) then
        WriteCommands
      else if sametext(LResponse, cCommandExit) then
        if LServer.Active then
        begin
          StopServer(LServer);
          break
        end
        else
          break
      else
      begin
        Writeln(sInvalidCommand);
        Write(cArrow);
      end;
    end;
    TerminateThreads();
  finally
    LServer.Free;
  end;
end;

{ 
  จุดเข้าสู่โปรแกรมหลัก 
  เริ่มต้น web module และเรียกใช้เซิร์ฟเวอร์บนพอร์ต 8989
}
begin
  try
  if WebRequestHandler <> nil then
    WebRequestHandler.WebModuleClass := WebModuleClass;
    RunServer(8989);
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end
end.
