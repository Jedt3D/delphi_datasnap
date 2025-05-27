unit ServerContainerUnit1;

{
  Unit ServerContainerUnit1
  
  คำอธิบาย:
  ยูนิตนี้ทำหน้าที่เป็นคอนเทนเนอร์สำหรับคอมโพเนนต์ของ DataSnap server
  มีหน้าที่จัดการวงจรชีวิตของ DataSnap server และการลงทะเบียนคลาส
}

interface

uses System.SysUtils, System.Classes,
  Datasnap.DSServer, Datasnap.DSCommonServer,
  IPPeerServer, IPPeerAPI, Datasnap.DSAuth;

type
  {
    TServerContainer1
    
    โมดูลข้อมูลที่ทำหน้าที่เป็นคอนเทนเนอร์สำหรับคอมโพเนนต์ DataSnap server
    จัดการการลงทะเบียนคลาสของเซิร์ฟเวอร์และให้การเข้าถึงอินสแตนซ์ของเซิร์ฟเวอร์
  }
  TServerContainer1 = class(TDataModule)
    DSServer1: TDSServer;
    DSServerClass1: TDSServerClass;
    procedure DSServerClass1GetClass(DSServerClass: TDSServerClass;
      var PersistentClass: TPersistentClass);
  private
    { Private declarations }
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

{
  DSServer
  
  ฟังก์ชันส่วนกลางสำหรับเข้าถึงอินสแตนซ์ของ DataSnap server
  @return TDSServer - อินสแตนซ์ของ DataSnap server
}
function DSServer: TDSServer;

implementation

{%CLASSGROUP 'System.Classes.TPersistent'}

{$R *.dfm}

uses
  ServerMethodsUnit1;

var
  FModule: TComponent;
  FDSServer: TDSServer;

{
  DSServer
  
  การทำงานของฟังก์ชันส่วนกลางสำหรับเข้าถึงอินสแตนซ์ของ DataSnap server
  @return TDSServer - อินสแตนซ์ของ DataSnap server
}
function DSServer: TDSServer;
begin
  Result := FDSServer;
end;

{
  TServerContainer1.Create
  
  คอนสตรัคเตอร์สำหรับคอนเทนเนอร์ของเซิร์ฟเวอร์
  เริ่มต้นการอ้างอิงส่วนกลางของ DataSnap server
  
  @param AOwner - คอมโพเนนต์ที่เป็นเจ้าของคอนเทนเนอร์นี้
}
constructor TServerContainer1.Create(AOwner: TComponent);
begin
  inherited;
  FDSServer := DSServer1;
end;

{
  TServerContainer1.Destroy
  
  ดีสตรัคเตอร์สำหรับคอนเทนเนอร์ของเซิร์ฟเวอร์
  ล้างการอ้างอิงส่วนกลางของ DataSnap server
}
destructor TServerContainer1.Destroy;
begin
  inherited;
  FDSServer := nil;
end;

{
  TServerContainer1.DSServerClass1GetClass
  
  ตัวจัดการเหตุการณ์ที่จัดหาคลาสที่จะใช้สำหรับการเรียกเมธอดของเซิร์ฟเวอร์
  ลงทะเบียนคลาส TServerMethods1 เป็นคลาสของเซิร์ฟเวอร์
  
  @param DSServerClass - คลาสของเซิร์ฟเวอร์ที่ต้องการคลาสแบบ persistent
  @param PersistentClass - คลาสที่จะใช้สำหรับเมธอดของเซิร์ฟเวอร์
}
procedure TServerContainer1.DSServerClass1GetClass(
  DSServerClass: TDSServerClass; var PersistentClass: TPersistentClass);
begin
  PersistentClass := ServerMethodsUnit1.TServerMethods1;
end;

initialization
  FModule := TServerContainer1.Create(nil);
finalization
  FModule.Free;
end.

