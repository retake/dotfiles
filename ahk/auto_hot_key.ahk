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


;���
vkEB & h::Send, {Blind}{Left}
vkEB & j::Send, {Blind}{Down}
vkEB & k::Send, {Blind}{Up}
vkEB & l::Send, {Blind}{Right}
vkFF & h::Send, {Blind}{Left}
vkFF & j::Send, {Blind}{Down}
vkFF & k::Send, {Blind}{Up}
vkFF & l::Send, {Blind}{Right}

;Backspace,Tab,Enter,Delete
vkEB & a::Send, {Blind}{BS}
vkEB & d::Send, {Blind}{Tab}
vkEB & f::Send, {Blind}{ENTER}
vkEB & g::Send, {Blind}{DELETE}
vkFF & a::Send, {Blind}{BS}
vkFF & d::Send, {Blind}{Tab}
vkFF & f::Send, {Blind}{ENTER}
vkFF & g::Send, {Blind}{DELETE}

;windows�f�X�N�g�b�v�ؑ�
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

;�A�v���؂�ւ�
vkEB & m::send, !+{Esc}
vkFF & m::send, !+{Esc}
vkEB & <::send, !{Esc}
vkFF & <::Send, !{Esc}
LWin & WheelUp::Send, {Blind}!{Esc}
LWin & WheelDown::Send, {Blind}!+{Esc}

;�^�u�؂�ւ�
vkEB & >::send, ^+{Tab}
vkFF & >::send, ^+{Tab}
vkEB & /::send, ^{Tab}
vkFF & /::Send, ^{Tab}
Ctrl & WheelUp::Send, {Blind}^{Tab}
Ctrl & WheelDown::Send, {Blind}^+{Tab}

;���{����͐ؑ�
vkEB & vkFF::Send, {vk19}
vkFF & vkEB::Send, {vk19}

