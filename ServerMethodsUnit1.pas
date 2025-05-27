unit ServerMethodsUnit1;

{ 
  Unit ServerMethodsUnit1
  
  คำอธิบาย:
  ยูนิตนี้ประกอบด้วยเมธอดของเซิร์ฟเวอร์ที่เปิดเผยผ่านทาง DataSnap เซิร์ฟเวอร์
  มันให้บริการเมธอดในการจัดการกับสตริงอย่างง่ายที่สามารถเรียกใช้จากระยะไกลได้
}

interface

uses System.SysUtils, System.Classes, System.Json,
    DataSnap.DSProviderDataModuleAdapter,
    Datasnap.DSServer, Datasnap.DSAuth;

type
  { TServerMethods1
    
    คลาสนี้กำหนดเมธอดของเซิร์ฟเวอร์ที่มีให้ใช้สำหรับการเรียกระยะไกล
    มันสืบทอดจาก TDSServerModule ซึ่งทำให้เมธอดสาธารณะของมัน
    สามารถเข้าถึงได้จากระยะไกลผ่าน DataSnap
  }
  TServerMethods1 = class(TDSServerModule)
  private
    { Private declarations }
  public
    { Public declarations }
    { EchoString - ส่งคืนสตริงที่รับเข้ามาโดยไม่มีการเปลี่ยนแปลง
      @param Value - สตริงที่จะถูกส่งคืน
      @return - สตริงเดิมที่ไม่มีการเปลี่ยนแปลง
    }
    function EchoString(Value: string): string;
    
    { ReverseString - กลับลำดับอักขระของสตริงที่รับเข้ามา
      @param Value - สตริงที่จะถูกกลับลำดับ
      @return - สตริงที่ถูกกลับลำดับแล้ว
    }
    function ReverseString(Value: string): string;
    
    { ToUpperCase - แปลงสตริงที่รับเข้ามาเป็นตัวพิมพ์ใหญ่
      @param Value - สตริงที่จะถูกแปลงเป็นตัวพิมพ์ใหญ่
      @return - เวอร์ชันตัวพิมพ์ใหญ่ของสตริงที่รับเข้ามา
    }
    function ToUpperCase(Value: string): string;
    
    { ToLowerCase - แปลงสตริงที่รับเข้ามาเป็นตัวพิมพ์เล็ก
      @param Value - สตริงที่จะถูกแปลงเป็นตัวพิมพ์เล็ก
      @return - เวอร์ชันตัวพิมพ์เล็กของสตริงที่รับเข้ามา
    }
    function ToLowerCase(Value: string): string;
  end;

implementation

{%CLASSGROUP 'System.Classes.TPersistent'}

{$R *.dfm}


uses System.StrUtils;

{ TServerMethods1.EchoString
  
  ส่งคืนสตริงที่ป้อนเข้ามาโดยไม่มีการเปลี่ยนแปลงใดๆ
  ฟังก์ชันนี้แสดงให้เห็นถึงฟังก์ชันการทำงานพื้นฐานของเมธอดเซิร์ฟเวอร์
}
function TServerMethods1.EchoString(Value: string): string;
begin
  Result := Value;
end;

{ TServerMethods1.ReverseString

  กลับลำดับอักขระในสตริงที่ป้อนเข้ามา
  ใช้ System.StrUtils.ReverseString เพื่อดำเนินการ
}
function TServerMethods1.ReverseString(Value: string): string;
begin
  Result := System.StrUtils.ReverseString(Value);
end;

{ TServerMethods1.ToUpperCase

  แปลงอักขระทั้งหมดในสตริงที่ป้อนเข้ามาเป็นตัวพิมพ์ใหญ่
  ใช้ System.SysUtils.UpperCase เพื่อดำเนินการแปลง
}
function TServerMethods1.ToUpperCase(Value: string): string;
begin
  Result := System.SysUtils.UpperCase(Value);
end;

{ TServerMethods1.ToLowerCase

  แปลงอักขระทั้งหมดในสตริงที่ป้อนเข้ามาเป็นตัวพิมพ์เล็ก
  ใช้ System.SysUtils.LowerCase เพื่อดำเนินการแปลง
}
function TServerMethods1.ToLowerCase(Value: string): string;
begin
  Result := System.SysUtils.LowerCase(Value);
end;

end.

