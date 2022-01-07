#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#InstallKeybdHook

WriteLog(log) {
  logText = [%A_Now%]%log%
  EnvGet, homepath, HOMEPATH
  LOG_FILE=C:%homepath%\ahk.log
  FileAppend,  %logText%, %LOG_FILE%
}


;矢印/バックスペース，エンター/home,end
vkEB & h::Send, {Blind}{Left}
vkEB & j::Send, {Blind}{Down}
vkEB & k::Send, {Blind}{Up}
vkEB & l::Send, {Blind}{Right}
vkEB & d::Send, {Blind}{BS}
vkEB & f::Send, {Blind}{DELETE}
vkEB & g::Send, {Blind}{ENTER}
vkEB & s::Send, {Blind}{Space}
vkEB & a::Send, {Blind}{Tab}

vkFF & h::Send, {Blind}{Left}
vkFF & j::Send, {Blind}{Down}
vkFF & k::Send, {Blind}{Up}
vkFF & l::Send, {Blind}{Right}
vkFF & d::Send, {Blind}{BS}
vkFF & f::Send, {Blind}{DELETE}
vkFF & g::Send, {Blind}{Enter}
vkFF & s::Send, {Blind}{Space}
vkFF & a::Send, {Blind}{Tab}


;windowsデスクトップ切替
change_desktop(arrow_button) {
  Send {Blind}^#{%arrow_button%}
}

vkEB & Left::change_desktop("Left")
vkFF & Left::change_desktop("Left")
vkEB & Right::change_desktop("Right")
vkFF & Right::change_desktop("Right")
vkEB & Up::Send, #{Tab}
vkFF & Up::Send, #{Tab}
;vkEB & Down::Send, ^#{F4}
;vkFF & Down::Send, ^#{F4}

MButton & WheelUp::change_desktop("Left")
MButton & WheelDown::change_desktop("Right")

;アプリ切り替え
vkEB & Tab::Send, !{Esc}
vkFF & Tab::Send, !{Esc}
LWin & WheelUp::Send, {Blind}!{Esc}
LWin & WheelDown::Send, {Blind}!+{Esc}

vkEB & t::Send, {Blind}^{Tab}
vkFF & t::Send, {Blind}^{Tab}
Ctrl & WheelUp::Send, {Blind}^{Tab}
Ctrl & WheelDown::Send, {Blind}^+{Tab}

;日本語入力切替
vkEB & vkFF::Send, {vk19}
vkFF & vkEB::Send, {vk19}

