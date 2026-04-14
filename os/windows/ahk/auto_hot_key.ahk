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
vk1A & f::Send, {Blind}{Esc}


;矢印
vkEB & h::Send, {Blind}{Left}
vkEB & j::Send, {Blind}{Down}
vkEB & k::Send, {Blind}{Up}
vkEB & l::Send, {Blind}{Right}
vk1A & h::Send, {Blind}{Left}
vk1A & j::Send, {Blind}{Down}
vk1A & k::Send, {Blind}{Up}
vk1A & l::Send, {Blind}{Right}


;編集キー
vkEB & p::Send, {Blind}{BS}
vkEB & [::Send, {Blind}{Delete}
vkEB & `;::Send, {Blind}{ENTER}
vkEB & q::Send, {Blind}{Tab}
vk1A & p::Send, {Blind}{BS}
vk1A & [::Send, {Blind}{Delete}
vk1A & `;::Send, {Blind}{ENTER}
vk1A & q::Send, {Blind}{Tab}
vkFF & c::Send, ^c
vkFF & v::Send, ^v
vkFF & x::Send, ^x

;カタカナ
vkEB & i::Send, {F7}
vk1A & i::Send, {F7}

;Ctrl+s
vkEB & s::Send, {Blind}^s
vk1A & s::Send, {Blind}^s

;windowsデスクトップ切替
change_desktop(arrow_button) {
  Send {Blind}^#{%arrow_button%}
}

vkEB & '::change_desktop("Left")
vkFF & '::change_desktop("Left")
vkEB & \::change_desktop("Right")
vkFF & \::change_desktop("Right")
vk1A & '::change_desktop("Left")
vk1A & \::change_desktop("Right")


;日本語入力切替
vkEB & vkFF::Send, {vk19}
vkFF & vkEB::Send, {vk19}
vk1A & vkFF::Send, {vk19}
vkFF & vk1A::Send, {vk19}

;アプリショートカット
vkEB & Space::Send, !{Space}
vkFF & Space::Send, !{Space}
vk1A & Space::Send, !{Space}

;タブ移動
vk1A & vkBC::Send, ^+{Tab}
vk1A & .::Send, ^{Tab}
vkEB & vkBC::Send, ^+{Tab}
vkEB & .::Send, ^{Tab}


;ターミナルスクロール（1行単位）
vkEB & Up::Send, ^+{Up}
vkEB & Down::Send, ^+{Down}
vk1A & Up::Send, ^+{Up}
vk1A & Down::Send, ^+{Down}


;やりたいこと、メモ


