; vim: sw=4 ts=4 et
#Requires AutoHotkey v2.0+
#SingleInstance Force ; The script will Reload if launched while already running

SetWorkingDir(A_ScriptDir)

; Basic Key map
; #: Win
; +: Shift
; ^: Ctrl
; !: Alt

; Volume Up/Down
F5::
{
    SoundSetVolume "+5"
    SoundBeep 825, 200
}

F4::
{
    SoundSetVolume "-5"
    SoundBeep 660, 200
}

F3::{
  IsMuted := SoundGetMute()
  if IsMuted {
    SoundSetMute false
    SoundBeep 660, 200
  } else {
    SoundSetMute true
  }
}

; Window Swticher

; Path to the DLL, relative to the script
VDA_PATH := A_AppData . "\AutoHotkey\VirtualDesktopAccessor.dll"

hVirtualDesktopAccessor             := DllCall("LoadLibrary",    "Str", VDA_PATH,                "Ptr")
GetDesktopCountProc                 := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "GetDesktopCount", "Ptr")
GoToDesktopNumberProc               := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "GoToDesktopNumber", "Ptr")
GetCurrentDesktopNumberProc         := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "GetCurrentDesktopNumber", "Ptr")
IsWindowOnCurrentVirtualDesktopProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "IsWindowOnCurrentVirtualDesktop", "Ptr")
IsWindowOnDesktopNumberProc         := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "IsWindowOnDesktopNumber", "Ptr")
MoveWindowToDesktopNumberProc       := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "MoveWindowToDesktopNumber", "Ptr")
IsPinnedWindowProc                  := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "IsPinnedWindow", "Ptr")
GetDesktopNameProc                  := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "GetDesktopName", "Ptr")
SetDesktopNameProc                  := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "SetDesktopName", "Ptr")
CreateDesktopProc                   := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "CreateDesktop", "Ptr")
RemoveDesktopProc                   := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "RemoveDesktop", "Ptr")

; On change listeners
RegisterPostMessageHookProc         := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "RegisterPostMessageHook", "Ptr")
UnregisterPostMessageHookProc       := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "UnregisterPostMessageHook", "Ptr")

; Util Func
GetDesktopCount() {
    global GetDesktopCountProc
    count := DllCall(GetDesktopCountProc, "Int")
    return count
}

MoveCurrentWindowToDesktop(number) {
    global MoveWindowToDesktopNumberProc, GoToDesktopNumberProc
    activeHwnd := WinGetID("A")
    DllCall(MoveWindowToDesktopNumberProc, "Ptr", activeHwnd, "Int", number, "Int")
}

SetDesktopName(num, name) {
    global SetDesktopNameProc
    OutputDebug(name)
    name_utf8 := Buffer(1024, 0)
    StrPut(name, name_utf8, "UTF-8")
    ran := DllCall(SetDesktopNameProc, "Int", num, "Ptr", name_utf8, "Int")
    return ran
}

; Main Func
MoveCurrentWindowToPrevDesktop() {
    global GetCurrentDesktopNumberProc, GoToDesktopNumberProc
    current := DllCall(GetCurrentDesktopNumberProc, "Int")
    last_desktop := GetDesktopCount() - 1
    ; If current desktop is 0, do nothing
    if (current != 0) {
        MoveCurrentWindowToDesktop(current - 1)
    }
    return
}

MoveCurrentWindowToNextDesktop() {
    global GetCurrentDesktopNumberProc, GoToDesktopNumberProc
    current := DllCall(GetCurrentDesktopNumberProc, "Int")
    last_desktop := GetDesktopCount() - 1
    ; If current desktop is last, do nothing
    if (current != last_desktop) {
        MoveCurrentWindowToDesktop(current + 1)
    }
    return
}

SetDesktopName(0, "Win1 - 🐱")
SetDesktopName(1, "Win2 - 🐱🐱")
SetDesktopName(2, "Win3 - 🐱🐱🐱")
SetDesktopName(3, "Win4 - 🐱🐱🐱🐱")
SetDesktopName(4, "Win5 - 🐱🐱🐱🐱")

#h::#^Left
#l::#^Right

#+h::
{
    Send "#^{Left}"
    MoveCurrentWindowToPrevDesktop()
}

#+l::
{
    Send "#^{Right}"
    MoveCurrentWindowToNextDesktop()
}

; DllCall(RegisterPostMessageHookProc, "Ptr", A_ScriptHwnd, "Int", 0x1400 + 30, "Int")
; OnMessage(0x1400 + 30, OnChangeDesktop)
; OnChangeDesktop(wParam, lParam, msg, hwnd) {
;     Critical(1)
;     OldDesktop := wParam + 1
;     NewDesktop := lParam + 1
;     Name := GetDesktopName(NewDesktop - 1)
; 
;     ; Use Dbgview.exe to checkout the output debug logs
;     OutputDebug("Desktop changed to " Name " from " OldDesktop " to " NewDesktop)
;     ; TraySetIcon(".\Icons\icon" NewDesktop ".ico")
; }


#IfWinActive Alacritty
; Ctrl+Shift+V -- change line endings
^+v::
    ClipboardBackup := Clipboard                        ; To restore clipboard contents after paste
    FixString := StrReplace(Clipboard, "`r`n", "`n")    ; Change endings
    Clipboard := FixString                              ; Set to clipboard
    Send ^+v                                            ; Paste text
    Clipboard := ClipboardBackup                        ; Restore clipboard that has windows endings
    return
#IfWinActive
