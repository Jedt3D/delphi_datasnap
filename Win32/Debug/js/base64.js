/* 
 * ลิขสิทธิ์ (c) 2006, Opera Software ASA 
 * สงวนลิขสิทธิ์ทั้งหมด 
 * การเผยแพร่และการใช้งานในรูปแบบซอร์สโค้ดและไบนารี ทั้งที่มีและไม่มี
 * การแก้ไข ได้รับอนุญาตเมื่อปฏิบัติตามเงื่อนไขต่อไปนี้: 
 * 
 *     * การเผยแพร่ซอร์สโค้ดต้องคงไว้ซึ่งข้อความลิขสิทธิ์ข้างต้น
 *       ประกาศนี้ รายการเงื่อนไข และข้อสงวนสิทธิ์ต่อไปนี้
 *     * การเผยแพร่ในรูปแบบไบนารีต้องทำซ้ำข้อความลิขสิทธิ์ข้างต้น
 *       ประกาศนี้ รายการเงื่อนไข และข้อสงวนสิทธิ์ต่อไปนี้
 *       ในเอกสารและ/หรือวัสดุอื่น ๆ ที่มาพร้อมกับการเผยแพร่
 *     * ห้ามใช้ชื่อ Opera Software ASA หรือ
 *       ชื่อของผู้มีส่วนร่วมเพื่อรับรองหรือส่งเสริมผลิตภัณฑ์
 *       ที่ได้มาจากซอฟต์แวร์นี้โดยไม่ได้รับอนุญาตเป็นลายลักษณ์อักษรล่วงหน้า
 * 
 * ซอฟต์แวร์นี้จัดเตรียมโดย OPERA SOFTWARE ASA และผู้มีส่วนร่วม "ตามที่เป็น" และไม่มี 
 * การรับประกันที่ชัดแจ้งหรือโดยนัย รวมถึง แต่ไม่จำกัดเพียง การรับประกันโดยนัย 
 * ในเรื่องความสามารถในการซื้อขายได้ หรือความเหมาะสมสำหรับวัตถุประสงค์เฉพาะ ซึ่ง 
 * ปฏิเสธความรับผิดชอบ ไม่มีกรณีใด ๆ ที่ OPERA SOFTWARE ASA และผู้มีส่วนร่วมจะรับผิดต่อความเสียหาย 
 * โดยตรง โดยอ้อม อุบัติเหตุ พิเศษ ตัวอย่าง หรือความเสียหายที่ตามมา 
 * (รวมถึง แต่ไม่จำกัดเพียง การจัดหาสินค้าหรือบริการทดแทน; 
 * การสูญเสียการใช้งาน ข้อมูล หรือกำไร; หรือการหยุดชะงักทางธุรกิจ) ไม่ว่าจะมีสาเหตุและ 
 * ตามทฤษฎีความรับผิดใด ๆ ไม่ว่าจะเป็นสัญญา ความรับผิดชอบโดยเคร่งครัด หรือการละเมิด 
 * (รวมถึงความประมาทหรืออื่น ๆ) ที่เกิดขึ้นในทางใด ๆ จากการใช้งาน
 * ซอฟต์แวร์นี้ แม้ว่าจะได้รับการแจ้งถึงความเป็นไปได้ของความเสียหายดังกล่าว
 */ 
function convertStringToBase64(string) 
{ 
  if (typeof window.btoa === "function") { 
    return window.btoa(unescape(encodeURIComponent(string)));
  }
  var out='', charCode=0, i=0, length=string.length; 
  var puffer=[];
  var base64EncodeChars ="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
  var dig1, dig2, dig3, dig4;

  var i = 0; 
  while(i < string.length) 
  { 
    charCode = string.charCodeAt(i++);
    if(charCode<0x80)  
    { 
      puffer[puffer.length]=charCode; 
    } 
    else if(charCode<0x800) 
    { 
      puffer[puffer.length]=0xc0|(charCode>>6); 
      puffer[puffer.length]=0x80|(charCode&0x3f); 
    }  
    else if(charCode<0x10000) 
    { 
      puffer[puffer.length]=0xe0|(charCode>>12); 
      puffer[puffer.length]=0x80|((charCode>>6)&0x3f); 
      puffer[puffer.length]=0x80|(charCode&0x3f); 
    }  
    else 
    { 
      puffer[puffer.length]=0xf0|(charCode>>18); 
      puffer[puffer.length]=0x80|((charCode>>12)&0x3f); 
      puffer[puffer.length]=0x80|((charCode>>6)&0x3f); 
      puffer[puffer.length]=0x80|(charCode&0x3f); 
    }  
    if(i==length) 
    { 
      while(puffer.length%3)  
      { 
        puffer[puffer.length]=NaN;
      } 
    } 
    if(puffer.length>2) 
    { 
      dig1 = puffer[0]>>2;
      dig2 = ((puffer[0]&3)<<4)|(puffer[1]>>4);
      dig3 = ((puffer[1]&15)<<2)|(puffer[2]>>6);
      dig4 = puffer[2]&63;

      if (isNaN(puffer[1])) {
        dig3 = dig4 = 64;
      } else if (isNaN(puffer[2])) {
        dig4 = 64;
      }

      puffer.shift();
      puffer.shift();
      puffer.shift();

      out+=base64EncodeChars.charAt(dig1); 
      out+=base64EncodeChars.charAt(dig2); 
      out+=base64EncodeChars.charAt(dig3); 
      out+=base64EncodeChars.charAt(dig4);
    } 
  } 
  return out; 
}
