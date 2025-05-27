unit ServerMethodsUnit1;

{ 
  Unit ServerMethodsUnit1
  
  คำอธิบาย:
  ยูนิตนี้ประกอบด้วยเมธอดของเซิร์ฟเวอร์ที่เปิดเผยผ่าน DataSnap server
  มันให้บริการเมธอดจัดการกับข้อความอย่างง่ายที่สามารถเรียกใช้จากระยะไกลได้
}

interface

uses System.SysUtils, System.Classes, System.Json,
    DataSnap.DSProviderDataModuleAdapter,
    Datasnap.DSServer, Datasnap.DSAuth;

type
  { TServerMethods1
    
    คลาสนี้กำหนดเมธอดของเซิร์ฟเวอร์ที่พร้อมให้บริการสำหรับการเรียกจากระยะไกล
    สืบทอดจาก TDSServerModule ซึ่งทำให้เมธอดสาธารณะของมัน
    พร้อมให้บริการสำหรับการเข้าถึงจากระยะไกลผ่าน DataSnap
  }
  TServerMethods1 = class(TDSServerModule)
  private
    { Private declarations }
  public
    { Public declarations }
    { EchoString - ส่งคืนข้อความเข้ามาโดยไม่มีการเปลี่ยนแปลง
      @param Value - ข้อความที่จะถูกส่งกลับ
      @return - ข้อความเข้ามาที่ไม่มีการเปลี่ยนแปลง
    }
    function EchoString(Value: string): string;
    
    { ReverseString - สลับลำดับตัวอักษรของข้อความที่เข้ามา
      @param Value - ข้อความที่จะถูกสลับลำดับ
      @return - ข้อความที่ถูกสลับลำดับแล้ว
    }
    function ReverseString(Value: string): string;
    
    { ToUpperCase - แปลงข้อความที่เข้ามาเป็นตัวพิมพ์ใหญ่
      @param Value - ข้อความที่จะถูกแปลงเป็นตัวพิมพ์ใหญ่
      @return - ข้อความที่เป็นตัวพิมพ์ใหญ่
    }
    function ToUpperCase(Value: string): string;
    
    { ToLowerCase - แปลงข้อความที่เข้ามาเป็นตัวพิมพ์เล็ก
      @param Value - ข้อความที่จะถูกแปลงเป็นตัวพิมพ์เล็ก
      @return - ข้อความที่เป็นตัวพิมพ์เล็ก
    }
    function ToLowerCase(Value: string): string;
  end;

implementation

{%CLASSGROUP 'System.Classes.TPersistent'}

{$R *.dfm}


uses System.StrUtils;

{ TServerMethods1.EchoString
  
  เพียงส่งคืนข้อความเข้ามาโดยไม่มีการเปลี่ยนแปลง
  ฟังก์ชันนี้แสดงให้เห็นถึงการทำงานพื้นฐานของเมธอดเซิร์ฟเวอร์
}
function TServerMethods1.EchoString(Value: string): string;
begin
  Result := Value;
end;

{ TServerMethods1.ReverseString

  สลับลำดับตัวอักษรในข้อความที่เข้ามา
  ใช้ System.StrUtils.ReverseString เพื่อดำเนินการ
}
function TServerMethods1.ReverseString(Value: string): string;
begin
  Result := System.StrUtils.ReverseString(Value);
end;

{ TServerMethods1.ToUpperCase

  แปลงตัวอักษรทั้งหมดในข้อความที่เข้ามาเป็นตัวพิมพ์ใหญ่
  ใช้ System.SysUtils.UpperCase เพื่อดำเนินการแปลง
}
function TServerMethods1.ToUpperCase(Value: string): string;
begin
  Result := System.SysUtils.UpperCase(Value);
end;

{ TServerMethods1.ToLowerCase

  แปลงตัวอักษรทั้งหมดในข้อความที่เข้ามาเป็นตัวพิมพ์เล็ก
  ใช้ System.SysUtils.LowerCase เพื่อดำเนินการแปลง
}
function TServerMethods1.ToLowerCase(Value: string): string;
begin
  Result := System.SysUtils.LowerCase(Value);
end;

end.

