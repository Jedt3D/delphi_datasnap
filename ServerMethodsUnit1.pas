unit ServerMethodsUnit1;

{ 
  Unit ServerMethodsUnit1
  
  Description:
  This unit contains the server methods that are exposed via DataSnap server.
  It provides simple string manipulation methods that can be called remotely.
}

interface

uses System.SysUtils, System.Classes, System.Json,
    DataSnap.DSProviderDataModuleAdapter,
    Datasnap.DSServer, Datasnap.DSAuth;

type
  { TServerMethods1
    
    This class defines the server methods available for remote calls.
    It inherits from TDSServerModule which makes its public methods
    available for remote access via DataSnap.
  }
  TServerMethods1 = class(TDSServerModule)
  private
    { Private declarations }
  public
    { Public declarations }
    { EchoString - Returns the input string unchanged
      @param Value - The string to be echoed
      @return - The input string unchanged
    }
    function EchoString(Value: string): string;
    
    { ReverseString - Reverses the characters of the input string
      @param Value - The string to be reversed
      @return - The reversed string
    }
    function ReverseString(Value: string): string;
    
    { ToUpperCase - Converts the input string to uppercase
      @param Value - The string to be converted to uppercase
      @return - The uppercase version of the input string
    }
    function ToUpperCase(Value: string): string;
    
    { ToLowerCase - Converts the input string to lowercase
      @param Value - The string to be converted to lowercase
      @return - The lowercase version of the input string
    }
    function ToLowerCase(Value: string): string;
  end;

implementation

{%CLASSGROUP 'System.Classes.TPersistent'}

{$R *.dfm}


uses System.StrUtils;

{ TServerMethods1.EchoString
  
  Simply returns the input string without any changes.
  This function demonstrates the basic functionality of a server method.
}
function TServerMethods1.EchoString(Value: string): string;
begin
  Result := Value;
end;

{ TServerMethods1.ReverseString

  Reverses the order of characters in the input string.
  Uses System.StrUtils.ReverseString to perform the operation.
}
function TServerMethods1.ReverseString(Value: string): string;
begin
  Result := System.StrUtils.ReverseString(Value);
end;

{ TServerMethods1.ToUpperCase

  Converts all characters in the input string to uppercase.
  Uses System.SysUtils.UpperCase to perform the conversion.
}
function TServerMethods1.ToUpperCase(Value: string): string;
begin
  Result := System.SysUtils.UpperCase(Value);
end;

{ TServerMethods1.ToLowerCase

  Converts all characters in the input string to lowercase.
  Uses System.SysUtils.LowerCase to perform the conversion.
}
function TServerMethods1.ToLowerCase(Value: string): string;
begin
  Result := System.SysUtils.LowerCase(Value);
end;

end.

