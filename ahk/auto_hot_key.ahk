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

;Esc
vkEB & f::Send, {Blind}{Esc}

;exit
vkEB & c::Send, {Blind}^c

;矢印
vkEB & h::Send, {Blind}{Left}
vkEB & j::Send, {Blind}{Down}
vkEB & k::Send, {Blind}{Up}
vkEB & l::Send, {Blind}{Right}


;周辺キー
vkEB & p::Send, {Blind}{BS}
vkEB & [::Send, {Blind}{Delete}
vkEB & `;::Send, {Blind}{ENTER}
vkEB & q::Send, {Blind}{Tab}

;カタカナ
vkEB & i::Send, {F7}

;Ctrl+c
vkEB & s::Send, {Blind}^s

;windowsデスクトップ切替
change_desktop(arrow_button) {
  Send {Blind}^#{%arrow_button%}
}

vkEB & '::change_desktop("Left")
vkFF & '::change_desktop("Left")
vkEB & \::change_desktop("Right")
vkFF & \::change_desktop("Right")


;日本語入力切替
vkEB & vkFF::Send, {vk19}
vkFF & vkEB::Send, {vk19}





;やりたい事、案


