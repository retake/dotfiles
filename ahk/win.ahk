#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#InstallKeybdHook

;矢印/バックスペース，エンター/home,end
vkEB & h::Send, {Blind}{Left}
vkEB & j::Send, {Blind}{Down}
vkEB & k::Send, {Blind}{Up}
vkEB & l::Send, {Blind}{Right}
vkEB & a::Send, {Blind}{BS}
vkEB & s::Send, {Blind}{DELETE}
vkEB & Space::Send, {Blind}{ENTER}
vkEB & d::Send, {Blind}{TAB}

vkFF & h::Send, {Blind}{Left}
vkFF & j::Send, {Blind}{Down}
vkFF & k::Send, {Blind}{Up}
vkFF & l::Send, {Blind}{Right}
vkFF & a::Send, {Blind}{BS}
vkFF & s::Send, {Blind}{DELETE}
vkFF & Space::Send, {Blind}{Enter}
vkFF & d::Send, {Blind}{TAB}


;デスクトップ切替

;日本語入力切替
vkEB & vkFF::Send, {vk19}
vkFF & vkEB::Send, {vk19}

