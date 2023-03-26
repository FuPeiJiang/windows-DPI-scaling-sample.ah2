#SingleInstance force
ListLines 0
KeyHistory 0
SendMode "Input" ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir A_ScriptDir ; Ensures a consistent starting directory.

; https://github.com/lihas/windows-DPI-scaling-sample/blob/master/DPIHelper/DpiHelper.cpp
; https://stackoverflow.com/questions/35233182/how-can-i-change-windows-10-display-scaling-programmatically-using-c-sharp#57397039

DllCall("GetDisplayConfigBufferSizes", "Uint",0x00000002, "Uint*",&pathsCount:=0, "Uint*",&modesCount:=0) ;0x00000002=QDC_ONLY_ACTIVE_PATHS
DISPLAYCONFIG_PATH_INFO_arr:=Buffer(72*pathsCount)
DISPLAYCONFIG_MODE_INFO_arr:=Buffer(64*modesCount)
DllCall("QueryDisplayConfig", "Uint",0x00000002, "Uint*",&pathsCount, "Ptr",DISPLAYCONFIG_PATH_INFO_arr, "Uint*",&modesCount, "Ptr",DISPLAYCONFIG_MODE_INFO_arr, "Ptr",0) ;0x00000002=QDC_ONLY_ACTIVE_PATHS

i_:=0
end:=DISPLAYCONFIG_PATH_INFO_arr.Size
DISPLAYCONFIG_TARGET_DEVICE_NAME:=Buffer(420)
NumPut("Int",2,DISPLAYCONFIG_TARGET_DEVICE_NAME,0) ;2=DISPLAYCONFIG_DEVICE_INFO_GET_TARGET_NAME
NumPut("Uint",DISPLAYCONFIG_TARGET_DEVICE_NAME.Size,DISPLAYCONFIG_TARGET_DEVICE_NAME,4)
finalStr:=""
while (i_ < end) {
    adapterID:=NumGet(DISPLAYCONFIG_PATH_INFO_arr, i_+0, "Uint64")
    sourceID:=NumGet(DISPLAYCONFIG_PATH_INFO_arr, i_+8, "Uint")
    targetID:=NumGet(DISPLAYCONFIG_PATH_INFO_arr, i_+28, "Uint")

    NumPut("Uint64",adapterID,DISPLAYCONFIG_TARGET_DEVICE_NAME,8)
    NumPut("Uint",targetID,DISPLAYCONFIG_TARGET_DEVICE_NAME,16)
    DllCall("DisplayConfigGetDeviceInfo", "Ptr",DISPLAYCONFIG_TARGET_DEVICE_NAME)
    monitorFriendlyDeviceName:=StrGet(DISPLAYCONFIG_TARGET_DEVICE_NAME.Ptr + 36, "UTF-16")

    finalStr.=monitorFriendlyDeviceName "`n"

    i_+=72
}

MsgBox A_Clipboard:=finalStr
Exitapp

f3::Exitapp