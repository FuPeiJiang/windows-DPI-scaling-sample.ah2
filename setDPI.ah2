#SingleInstance force
ListLines 0
KeyHistory 0
SendMode "Input" ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir A_ScriptDir ; Ensures a consistent starting directory.

; https://github.com/lihas/windows-DPI-scaling-sample/blob/master/DPIHelper/DpiHelper.cpp
; https://stackoverflow.com/questions/35233182/how-can-i-change-windows-10-display-scaling-programmatically-using-c-sharp#57397039

DPI_ENUM:=
{
dpi_100:0,
dpi_125:1,
dpi_150:2,
dpi_175:3,
dpi_200:4,
dpi_225:5,
dpi_250:6,
dpi_300:7,
dpi_350:8,
dpi_400:9,
dpi_450:10,
dpi_500:11,
}


setDPI(monitorFriendlyDeviceName, dpi_enum_value) {
    DllCall("GetDisplayConfigBufferSizes", "Uint",0x00000002, "Uint*",&pathsCount:=0, "Uint*",&modesCount:=0) ;0x00000002=QDC_ONLY_ACTIVE_PATHS
    DISPLAYCONFIG_PATH_INFO_arr:=Buffer(72*pathsCount)
    DISPLAYCONFIG_MODE_INFO_arr:=Buffer(64*modesCount)
    DllCall("QueryDisplayConfig", "Uint",0x00000002, "Uint*",&pathsCount, "Ptr",DISPLAYCONFIG_PATH_INFO_arr, "Uint*",&modesCount, "Ptr",DISPLAYCONFIG_MODE_INFO_arr, "Ptr",0) ;0x00000002=QDC_ONLY_ACTIVE_PATHS

    i_:=0
    end:=DISPLAYCONFIG_PATH_INFO_arr.Size
    DISPLAYCONFIG_TARGET_DEVICE_NAME:=Buffer(420)
    NumPut("Int",2,DISPLAYCONFIG_TARGET_DEVICE_NAME,0) ;2=DISPLAYCONFIG_DEVICE_INFO_GET_TARGET_NAME
    NumPut("Uint",DISPLAYCONFIG_TARGET_DEVICE_NAME.Size,DISPLAYCONFIG_TARGET_DEVICE_NAME,4)
    while (i_ < end) {
        adapterID:=NumGet(DISPLAYCONFIG_PATH_INFO_arr, i_+0, "Uint64")
        sourceID:=NumGet(DISPLAYCONFIG_PATH_INFO_arr, i_+8, "Uint")
        targetID:=NumGet(DISPLAYCONFIG_PATH_INFO_arr, i_+28, "Uint")

        NumPut("Uint64",adapterID,DISPLAYCONFIG_TARGET_DEVICE_NAME,8)
        NumPut("Uint",targetID,DISPLAYCONFIG_TARGET_DEVICE_NAME,16)
        DllCall("DisplayConfigGetDeviceInfo", "Ptr",DISPLAYCONFIG_TARGET_DEVICE_NAME)
        temp_monitorFriendlyDeviceName:=StrGet(DISPLAYCONFIG_TARGET_DEVICE_NAME.Ptr + 36, "UTF-16")

        if (temp_monitorFriendlyDeviceName==monitorFriendlyDeviceName) {
            DISPLAYCONFIG_SOURCE_DPI_SCALE_GET:=Buffer(32)
            NumPut("Int",-3,DISPLAYCONFIG_SOURCE_DPI_SCALE_GET,0) ;-3=DISPLAYCONFIG_DEVICE_INFO_GET_DPI_SCALE
            NumPut("Uint",DISPLAYCONFIG_SOURCE_DPI_SCALE_GET.Size,DISPLAYCONFIG_SOURCE_DPI_SCALE_GET,4)
            NumPut("Uint64",adapterID,DISPLAYCONFIG_SOURCE_DPI_SCALE_GET,8)
            NumPut("Uint",sourceID,DISPLAYCONFIG_SOURCE_DPI_SCALE_GET,16)
            DllCall("DisplayConfigGetDeviceInfo", "Ptr",DISPLAYCONFIG_SOURCE_DPI_SCALE_GET)
            minScaleRel:=NumGet(DISPLAYCONFIG_SOURCE_DPI_SCALE_GET, 20, "Int")
            ; there should be an Abs() here but I'm omitting it..
            dpiRelativeVal:=dpi_enum_value - minScaleRel


            DISPLAYCONFIG_SOURCE_DPI_SCALE_SET:=Buffer(24)
            NumPut("Int",-4,DISPLAYCONFIG_SOURCE_DPI_SCALE_SET,0) ;-4=DISPLAYCONFIG_DEVICE_INFO_SET_DPI_SCALE
            NumPut("Uint",DISPLAYCONFIG_SOURCE_DPI_SCALE_SET.Size,DISPLAYCONFIG_SOURCE_DPI_SCALE_SET,4)
            NumPut("Uint64",adapterID,DISPLAYCONFIG_SOURCE_DPI_SCALE_SET,8)
            NumPut("Uint",sourceID,DISPLAYCONFIG_SOURCE_DPI_SCALE_SET,16)
            NumPut("Int",dpiRelativeVal,DISPLAYCONFIG_SOURCE_DPI_SCALE_SET,20)
            DllCall("DisplayConfigSetDeviceInfo", "Ptr",DISPLAYCONFIG_SOURCE_DPI_SCALE_SET)

            break
        }


        i_+=72
    }
}
setDPI("", DPI_ENUM.dpi_150)


Exitapp

f3::Exitapp