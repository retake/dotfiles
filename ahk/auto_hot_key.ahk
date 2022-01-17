#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#InstallKeybdHook

; Shift +
; Ctrl ^
; Alt !
; Win #

WriteLog(log) {
  logText = [%A_Now%]%log%
  EnvGet, homepath, HOMEPATH
  LOG_FILE=C:%homepath%\ahk.log
  FileAppend,  %logText%, %LOG_FILE%
}

;exit
vkEB & c::Send, {Blind}^c
vkFF & c::Send, {Blind}^c

;矢印
vkEB & h::Send, {Blind}{Left}
vkEB & j::Send, {Blind}{Down}
vkEB & k::Send, {Blind}{Up}
vkEB & l::Send, {Blind}{Right}
vkFF & h::Send, {Blind}{Left}
vkFF & j::Send, {Blind}{Down}
vkFF & k::Send, {Blind}{Up}
vkFF & l::Send, {Blind}{Right}

;Backspace,Enter,Delete
vkEB & [::Send, {Blind}{BS}
vkEB & `;::Send, {Blind}{ENTER}
vkEB  & '::Send, {Blind}{ENTER}
vkEB & ]::Send, {Blind}{BS}
vkFF & [::Send, {Blind}{BS}
vkFF & `;::Send, {Blind}{ENTER}
vkFF & '::Send, {Blind}{ENTER}
vkFF & ]::Send, {Blind}{BS}

;Ctrl+c
vkEB & s::Send, {Blind}^s
vkFF & s::Send, {Blind}^s

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
vkEB & m::send, !+{Esc}
vkFF & m::send, !+{Esc}
vkEB & <::send, !{Esc}
vkFF & <::Send, !{Esc}
LWin & WheelUp::Send, {Blind}!{Esc}
LWin & WheelDown::Send, {Blind}!+{Esc}

;タブ切り替え
vkEB & >::send, ^+{Tab}
vkFF & >::send, ^+{Tab}
vkEB & /::send, ^{Tab}
vkFF & /::Send, ^{Tab}
Ctrl & WheelUp::Send, {Blind}^{Tab}
Ctrl & WheelDown::Send, {Blind}^+{Tab}

;日本語入力切替
vkEB & vkFF::Send, {vk19}
vkFF & vkEB::Send, {vk19}

