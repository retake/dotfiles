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

;���
vkEB & h::Send, {Blind}{Left}
vkEB & j::Send, {Blind}{Down}
vkEB & k::Send, {Blind}{Up}
vkEB & l::Send, {Blind}{Right}
vkFF & h::Send, {Blind}{Left}
vkFF & j::Send, {Blind}{Down}
vkFF & k::Send, {Blind}{Up}
vkFF & l::Send, {Blind}{Right}

;Backspace,Enter
vkEB & p::Send, {Blind}{BS}
vkEB & [::Send, {Blind}{BS}
vkEB & ]::Send, {Blind}{BS}
vkEB & `;::Send, {Blind}{ENTER}
vkEB  & '::Send, {Blind}{ENTER}
vkFF & p::Send, {Blind}{BS}
vkFF & [::Send, {Blind}{BS}
vkFF & ]::Send, {Blind}{BS}
vkFF & `;::Send, {Blind}{ENTER}
vkFF & '::Send, {Blind}{ENTER}

;Ctrl+c
vkEB & s::Send, {Blind}^s
vkFF & s::Send, {Blind}^s

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


;���{����͐ؑ�
vkEB & vkFF::Send, {vk19}
vkFF & vkEB::Send, {vk19}


;��肽�����A��
;���{��L�[�{�[�h�ł̓��{��؂�ւ��V���[�g�J�b�g�쐬


