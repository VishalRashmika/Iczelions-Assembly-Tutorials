.386
.model flat,stdcall
option casemap:none
include \masm32\include\windows.inc
include \masm32\include\user32.inc
include \masm32\include\kernel32.inc
include \masm32\include\shell32.inc
includelib \masm32\lib\user32.lib
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\shell32.lib

WM_SHELLNOTIFY equ WM_USER+5
IDI_TRAY equ 0
IDM_RESTORE equ 1000
IDM_EXIT	equ 1010
WinMain PROTO :DWORD,:DWORD,:DWORD,:DWORD

.data
ClassName 	db "TrayIconWinClass",0
AppName  		db "TrayIcon Demo",0
RestoreString	db "&Restore",0
ExitString	 	db "E&xit Program",0

.data?
hInstance	dd ?
note NOTIFYICONDATA <>
hPopupMenu	dd ?

.code
start:
	invoke GetModuleHandle, NULL
	mov    hInstance,eax
	invoke WinMain, hInstance,NULL,NULL, SW_SHOWDEFAULT
	invoke ExitProcess,eax

WinMain proc hInst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD
	LOCAL wc:WNDCLASSEX
	LOCAL msg:MSG
	LOCAL hwnd:HWND
	mov   wc.cbSize,SIZEOF WNDCLASSEX
	mov   wc.style, CS_HREDRAW or CS_VREDRAW or CS_DBLCLKS
	mov   wc.lpfnWndProc, OFFSET WndProc
	mov   wc.cbClsExtra,NULL
	mov   wc.cbWndExtra,NULL
	push  hInst
	pop   wc.hInstance
	mov   wc.hbrBackground,COLOR_APPWORKSPACE
	mov   wc.lpszMenuName,NULL
	mov   wc.lpszClassName,OFFSET ClassName
	invoke LoadIcon,NULL,IDI_APPLICATION
	mov   wc.hIcon,eax
	mov   wc.hIconSm,eax
	invoke LoadCursor,NULL,IDC_ARROW
	mov   wc.hCursor,eax
	invoke RegisterClassEx, addr wc
	invoke CreateWindowEx,WS_EX_CLIENTEDGE,ADDR ClassName,ADDR AppName,\
           WS_OVERLAPPED+WS_CAPTION+WS_SYSMENU+WS_MINIMIZEBOX+WS_MAXIMIZEBOX+WS_VISIBLE,CW_USEDEFAULT,\
           CW_USEDEFAULT,350,200,NULL,NULL,\
           hInst,NULL
	mov   hwnd,eax
	.while TRUE
		invoke GetMessage, ADDR msg,NULL,0,0
		.BREAK .IF (!eax)
		invoke TranslateMessage, ADDR msg
		invoke DispatchMessage, ADDR msg
	.endw
	mov eax,msg.wParam
	ret
WinMain endp

WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
	LOCAL pt:POINT
	LOCAL rect:RECT
	.if uMsg==WM_CREATE
		invoke CreatePopupMenu
		mov hPopupMenu,eax
		invoke AppendMenu,hPopupMenu,MF_STRING,IDM_RESTORE,addr RestoreString
		invoke AppendMenu,hPopupMenu,MF_STRING,IDM_EXIT,addr ExitString
	.elseif uMsg==WM_DESTROY
		invoke DestroyMenu,hPopupMenu
		invoke PostQuitMessage,NULL
	.elseif uMsg==WM_SIZE
		.if wParam==SIZE_MINIMIZED
			mov note.cbSize,sizeof NOTIFYICONDATA
			push hWnd
			pop note.hwnd
			mov note.uID,IDI_TRAY
			mov note.uFlags,NIF_ICON+NIF_MESSAGE+NIF_TIP
			mov note.uCallbackMessage,WM_SHELLNOTIFY
			invoke LoadIcon,NULL,IDI_WINLOGO
			mov note.hIcon,eax
			invoke lstrcpy,addr note.szTip,addr AppName
			invoke ShowWindow,hWnd,SW_HIDE
			invoke Shell_NotifyIcon,NIM_ADD,addr note
		.endif
	.elseif uMsg==WM_COMMAND
		.if lParam==0
			invoke Shell_NotifyIcon,NIM_DELETE,addr note
			mov eax,wParam
			.if ax==IDM_RESTORE
				invoke ShowWindow,hWnd,SW_RESTORE
			.else
				invoke DestroyWindow,hWnd
			.endif
		.endif
	.elseif uMsg==WM_SHELLNOTIFY
		.if wParam==IDI_TRAY
			.if lParam==WM_RBUTTONDOWN
				invoke GetCursorPos,addr pt
				invoke SetForegroundWindow,hWnd
				invoke TrackPopupMenu,hPopupMenu,TPM_RIGHTALIGN or TPM_RIGHTBUTTON,pt.x,pt.y,NULL,hWnd,NULL
				invoke PostMessage,hWnd,WM_NULL,0,0
			.elseif lParam==WM_LBUTTONDBLCLK
				invoke SendMessage,hWnd,WM_COMMAND,IDM_RESTORE,0
			.endif
		.endif
	.else
		invoke DefWindowProc,hWnd,uMsg,wParam,lParam		
		ret
	.endif
	xor eax,eax
	ret
WndProc endp

end start
