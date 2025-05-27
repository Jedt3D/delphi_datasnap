unit ServerConst1;

{
  Unit ServerConst1
  
  คำอธิบาย:
  ยูนิตนี้ประกอบด้วยค่าคงที่และข้อความทรัพยากรที่ใช้ทั่วไปในแอปพลิเคชัน DataSnap server
  เป็นศูนย์กลางของข้อความและสตริงคำสั่งสำหรับอินเตอร์เฟซคอนโซล
}

interface

{
  ข้อความทรัพยากรที่ใช้สำหรับข้อความแสดงผลในคอนโซล
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
  ค่าคงที่ที่ใช้สำหรับประมวลผลคำสั่ง
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
