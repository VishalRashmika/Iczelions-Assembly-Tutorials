.386
.model flat, stdcall
option casemap:none
include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
includelib kernel32.lib
include \masm32\include\user32.inc
includelib user32.lib

.data
MsgCaption      db "Iczelion's tutorial no.2",0
MsgBoxText      db "Win32 Assembly is Great!",0

.code
start:
	invoke MessageBox, NULL,addr MsgBoxText, addr MsgCaption, MB_OK
	invoke ExitProcess,NULL
end start
