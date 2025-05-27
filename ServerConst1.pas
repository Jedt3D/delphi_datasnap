unit ServerConst1;

{
  Unit ServerConst1
  
  คำอธิบาย:
  ยูนิตนี้ประกอบด้วยค่าคงที่และสตริงทรัพยากรที่ใช้ทั่วทั้งแอปพลิเคชัน DataSnap เซิร์ฟเวอร์
  มันรวมศูนย์ข้อความและสตริงคำสั่งสำหรับอินเทอร์เฟซคอนโซล
}

interface

{
  สตริงทรัพยากรที่ใช้สำหรับข้อความเอาท์พุทคอนโซล
}
resourcestring
  sPortInUse = '- Error: Port %s already in use';
  sPortSet = '- Port set to %s';
  sServerRunning = '- The Server is already running';
  sStartingServer = '- Starting HTTP Server on port %d';
  sStoppingServer = '- Stopping Server';
  sServerStopped = '- Server Stopped';
  sServerNotRunning = '- The Server is not running';
  sInvalidCommand = '- Error: Invalid Command';
  sIndyVersion = '- Indy Version: ';
  sActive = '- Active: ';
  sPort = '- Port: ';
  sSessionID = '- Session ID CookieName: ';
  sCommands = 'Enter a Command: ' + slineBreak +
    '   - "start" to start the server'+ slineBreak +
    '   - "stop" to stop the server'+ slineBreak +
    '   - "set port" to change the default port'+ slineBreak +
    '   - "status" for Server status'+ slineBreak +
    '   - "help" to show commands'+ slineBreak +
    '   - "exit" to close the application';

{
  ค่าคงที่ที่ใช้สำหรับการประมวลผลคำสั่ง
}
const
  cArrow = '->';
  cCommandStart = 'start';
  cCommandStop = 'stop';
  cCommandStatus = 'status';
  cCommandHelp = 'help';
  cCommandSetPort = 'set port';
  cCommandExit = 'exit';

implementation

end.
