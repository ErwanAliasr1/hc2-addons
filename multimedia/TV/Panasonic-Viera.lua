-- Unknown License
-- 
-- Note :
-- TCPPORT should be 55000
local command = "NRC_MUTE-ONOFF";
--------------------------------------------------------
local selfId = fibaro:getSelfId();
local _deviceIp = fibaro:get(selfId, "IPAddress");
local _devicePort = fibaro:get(selfId, "TCPPort");
panasonicTvTcp = Net.FTcpSocket(_deviceIp, _devicePort)

requestMethod = "POST /nrc/control_0 HTTP/1.1"
custom_header = "SOAPACTION: \"urn:panasonic-com:service:p00NetworkControl:1#X_SendKey\""

local payload = "<s:Envelope xmlns:s=\"http://schemas.xmlsoap.org/soap/envelope/\" s:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\"><s:Body><u:X_SendKey xmlns:u=\"urn:panasonic-com:service:p00NetworkControl:1\"><X_KeyEvent>"..command.."</X_KeyEvent></u:X_SendKey></s:Body></s:Envelope>"
tcpstring = requestMethod .. "\r\n" .. "CONTENT-LENGTH: " .. string.len(payload) .. "\r\n" .. custom_header .. "\r\n\r\n" .. payload
 
bytes, errorCode = panasonicTvTcp:write(tcpstring)
if errorCode == 0 then
        fibaro:debug("tcp write OK")
else
        fibaro:debug("tcp write failed")
end


--- command should be part of this list :
--"NRC_CH_DOWN-ONOFF", // channel down
--"NRC_CH_UP-ONOFF", // channel up
--"NRC_VOLUP-ONOFF", // volume up
--"NRC_VOLDOWN-ONOFF", // volume down
--"NRC_MUTE-ONOFF", // mute
--"NRC_TV-ONOFF", // TV
--"NRC_CHG_INPUT-ONOFF", // AV,
--"NRC_RED-ONOFF", // red
--"NRC_GREEN-ONOFF", // green
--"NRC_YELLOW-ONOFF", // yellow
--"NRC_BLUE-ONOFF", // blue
--"NRC_VTOOLS-ONOFF", // VIERA tools
--"NRC_CANCEL-ONOFF", // Cancel / Exit
--"NRC_SUBMENU-ONOFF", // Option
--"NRC_RETURN-ONOFF", // Return
--"NRC_ENTER-ONOFF", // Control Center click / enter
--"NRC_RIGHT-ONOFF", // Control RIGHT
--"NRC_LEFT-ONOFF", // Control LEFT
--"NRC_UP-ONOFF", // Control UP
--"NRC_DOWN-ONOFF", // Control DOWN
--"NRC_3D-ONOFF", // 3D button
--"NRC_SD_CARD-ONOFF", // SD-card
--"NRC_DISP_MODE-ONOFF", // Display mode / Aspect ratio
--"NRC_MENU-ONOFF", // Menu
--"NRC_INTERNET-ONOFF", // VIERA connect
--"NRC_VIERA_LINK-ONOFF", // VIERA link
--"NRC_EPG-ONOFF", // Guide / EPG
--"NRC_TEXT-ONOFF", // Text / TTV
--"NRC_STTL-ONOFF", // STTL / Subtitles
--"NRC_INFO-ONOFF", // info
--"NRC_INDEX-ONOFF", // TTV index
--"NRC_HOLD-ONOFF", // TTV hold / image freeze
--"NRC_R_TUNE-ONOFF", // Last view
--"NRC_POWER-ONOFF", // Power off
--"NRC_REW-ONOFF", // rewind
--"NRC_PLAY-ONOFF", // play
--"NRC_FF-ONOFF", // fast forward
--"NRC_SKIP_PREV-ONOFF", // skip previous
--"NRC_PAUSE-ONOFF", // pause
--"NRC_SKIP_NEXT-ONOFF", // skip next
--"NRC_STOP-ONOFF", // stop
--"NRC_REC-ONOFF", // record
 
--numeric buttons
--"NRC_D1-ONOFF", "NRC_D2-ONOFF", "NRC_D3-ONOFF", "NRC_D4-ONOFF", "NRC_D5-ONOFF",
--"NRC_D6-ONOFF", "NRC_D7-ONOFF", "NRC_D8-ONOFF", "NRC_D9-ONOFF", "NRC_D0-ONOFF",
 
-- The below commands were not avaliable in the iPhone app when using my
-- VIERA G30 - they were pulled out from a disassembly instead
-- only these top three did anything on my TV
 
--"NRC_P_NR-ONOFF", // P-NR (Noise reduction)
--"NRC_OFFTIMER-ONOFF", // off timer
--"NRC_R_TUNE-ONOFF", // Seems to do the same as INFO
 
--"NRC_CHG_NETWORK-ONOFF",
--"NRC_CC-ONOFF",
--"NRC_SAP-ONOFF",
--"NRC_RECLIST-ONOFF",
--"NRC_DRIVE-ONOFF",
--"NRC_DATA-ONOFF",
--"NRC_BD-ONOFF",
--"NRC_FAVORITE-ONOFF",
--"NRC_DIGA_CTL-ONOFF",
--"NRC_VOD-ONOFF",
--"NRC_ECO-ONOFF",
--"NRC_GAME-ONOFF",
--"NRC_EZ_SYNC-ONOFF",
--"NRC_PICTAI-ONOFF",
--"NRC_MPX-ONOFF",
--"NRC_SPLIT-ONOFF",
--"NRC_SWAP-ONOFF",
--"NRC_R_SCREEN-ONOFF",
--"NRC_30S_SKIP-ONOFF",
--"NRC_PROG-ONOFF",
--"NRC_TV_MUTE_ON-ONOFF",
--"NRC_TV_MUTE_OFF-ONOFF",
--"NRC_DMS_CH_UP-ONOFF",
--"NRC_DMS_CH_DOWN-ONOFF"
