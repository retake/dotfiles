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


;デスクトップ切替

;日本語入力切替
vkEB & vkFF::Send, {vk19}
vkFF & vkEB::Send, {vk19}
alt::vk19