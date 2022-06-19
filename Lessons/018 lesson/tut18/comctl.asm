.386
.model flat,stdcall
option casemap:none
include \masm32\include\windows.inc
include \masm32\include\user32.inc
include \masm32\include\kernel32.inc
include \masm32\include\comctl32.inc
includelib \masm32\lib\comctl32.lib
includelib \masm32\lib\user32.lib
includelib \masm32\lib\kernel32.lib

WinMain PROTO :DWORD,:DWORD,:DWORD,:DWORD

.const
IDC_PROGRESS	equ 1
IDC_STATUS		equ 2
IDC_TIMER		equ 3

.data
ClassName 		db "CommonControlWinClass",0
AppName  		db "Common Control Demo",0
ProgressClass 	db "msctls_progress32",0
Message		db "Finished!",0
TimerID		dd 0

.data?
hInstance		HINSTANCE ?
hwndProgress	dd ?
hwndStatus	dd ?
CurrentStep	dd ?

.code
start:
	invoke GetModuleHandle, NULL
	mov    hInstance,eax
	invoke WinMain, hInstance,NULL,NULL, SW_SHOWDEFAULT
	invoke ExitProcess,eax
	invoke InitCommonControls

WinMain proc hInst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD
	LOCAL wc:WNDCLASSEX
	LOCAL msg:MSG
	LOCAL hwnd:HWND
	mov   wc.cbSize,SIZEOF WNDCLASSEX
	mov   wc.style, CS_HREDRAW or CS_VREDRAW
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
           CW_USEDEFAULT,CW_USEDEFAULT,CW_USEDEFAULT,NULL,NULL,\
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
	.if uMsg==WM_CREATE
		invoke CreateWindowEx,NULL,ADDR ProgressClass,NULL,\
     	      WS_CHILD+WS_VISIBLE,100,\
          	 200,300,20,hWnd,IDC_PROGRESS,\
	           hInstance,NULL
		mov hwndProgress,eax
		mov eax,1000
		mov CurrentStep,eax
		shl eax,16
		invoke SendMessage,hwndProgress,PBM_SETRANGE,0,eax
		invoke SendMessage,hwndProgress,PBM_SETSTEP,10,0
		invoke CreateStatusWindow,WS_CHILD+WS_VISIBLE,NULL,hWnd,IDC_STATUS
		mov hwndStatus,eax
		invoke SetTimer,hWnd,IDC_TIMER,100,NULL
		mov TimerID,eax
	.elseif uMsg==WM_DESTROY
		invoke PostQuitMessage,NULL
		.if TimerID!=0
			invoke KillTimer,hWnd,TimerID
		.endif
	.elseif uMsg==WM_TIMER
		invoke SendMessage,hwndProgress,PBM_STEPIT,0,0
		sub CurrentStep,10
		.if CurrentStep==0
			invoke KillTimer,hWnd,TimerID
			mov TimerID,0
			invoke SendMessage,hwndStatus,SB_SETTEXT,0,addr Message
			invoke MessageBox,hWnd,addr Message,addr AppName,MB_OK+MB_ICONINFORMATION
			invoke SendMessage,hwndStatus,SB_SETTEXT,0,0
			invoke SendMessage,hwndProgress,PBM_SETPOS,0,0
		.endif
	.else
		invoke DefWindowProc,hWnd,uMsg,wParam,lParam		
		ret
	.endif
	xor eax,eax
	ret
WndProc endp

end start
