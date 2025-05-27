unit ServerContainerUnit1;

{
  Unit ServerContainerUnit1
  
  Description:
  This unit implements the container for the DataSnap server components.
  It manages the DataSnap server lifecycle and class registration.
}

interface

uses System.SysUtils, System.Classes,
  Datasnap.DSServer, Datasnap.DSCommonServer,
  IPPeerServer, IPPeerAPI, Datasnap.DSAuth;

type
  {
    TServerContainer1
    
    Data module that serves as a container for the DataSnap server components.
    Manages server class registration and provides access to the server instance.
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
  
  Global function to access the DataSnap server instance.
  @return TDSServer - The DataSnap server instance
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
  
  Global function implementation to access the DataSnap server instance.
  @return TDSServer - The DataSnap server instance
}
function DSServer: TDSServer;
begin
  Result := FDSServer;
end;

{
  TServerContainer1.Create
  
  Constructor for the server container.
  Initializes the DataSnap server global reference.
  
  @param AOwner - The component that owns this container
}
constructor TServerContainer1.Create(AOwner: TComponent);
begin
  inherited;
  FDSServer := DSServer1;
end;

{
  TServerContainer1.Destroy
  
  Destructor for the server container.
  Cleans up the DataSnap server global reference.
}
destructor TServerContainer1.Destroy;
begin
  inherited;
  FDSServer := nil;
end;

{
  TServerContainer1.DSServerClass1GetClass
  
  Event handler that provides the class to be used for server method calls.
  Registers the TServerMethods1 class as the server class.
  
  @param DSServerClass - The server class requesting the persistent class
  @param PersistentClass - The class to be used for server methods
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

