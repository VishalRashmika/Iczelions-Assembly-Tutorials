.386
.model flat,stdcall
option casemap:none
WinMain proto :DWORD,:DWORD,:DWORD,:DWORD
include \masm32\include\windows.inc
include \masm32\include\user32.inc
include \masm32\include\kernel32.inc
includelib \masm32\lib\user32.lib
includelib \masm32\lib\kernel32.lib

.const
IDM_START_THREAD equ 1
IDM_STOP_THREAD equ 2
IDM_EXIT equ 3
WM_FINISH equ WM_USER+100h

.data
ClassName db "Win32ASMEventClass",0
AppName  db "Win32 ASM Event Example",0
MenuName db "FirstMenu",0
SuccessString db "The calculation is completed!",0
StopString db "The thread is stopped",0
EventStop BOOL FALSE

.data?
hInstance HINSTANCE ?
CommandLine LPSTR ?
hwnd HANDLE ?
hMenu HANDLE ?
ThreadID DWORD ?
ExitCode DWORD ?
hThread DWORD ?
hEventStart HANDLE ?

.code
start:
	invoke GetModuleHandle, NULL
	mov    hInstance,eax
	invoke GetCommandLine
	mov CommandLine,eax
	invoke WinMain, hInstance,NULL,CommandLine, SW_SHOWDEFAULT
	invoke ExitProcess,eax

WinMain proc hInst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD
	LOCAL wc:WNDCLASSEX
	LOCAL msg:MSG
	mov   wc.cbSize,SIZEOF WNDCLASSEX
	mov   wc.style, CS_HREDRAW or CS_VREDRAW
	mov   wc.lpfnWndProc, OFFSET WndProc
	mov   wc.cbClsExtra,NULL
	mov   wc.cbWndExtra,NULL
	push  hInst
	pop   wc.hInstance
	mov   wc.hbrBackground,COLOR_WINDOW+1
	mov   wc.lpszMenuName,OFFSET MenuName
	mov   wc.lpszClassName,OFFSET ClassName
	invoke LoadIcon,NULL,IDI_APPLICATION
	mov   wc.hIcon,eax
	mov   wc.hIconSm,eax
	invoke LoadCursor,NULL,IDC_ARROW
	mov   wc.hCursor,eax
	invoke RegisterClassEx, addr wc
	invoke CreateWindowEx,WS_EX_CLIENTEDGE,ADDR ClassName,ADDR AppName,\
           WS_OVERLAPPEDWINDOW,CW_USEDEFAULT,\
           CW_USEDEFAULT,300,200,NULL,NULL,\
           hInst,NULL
	mov   hwnd,eax
	invoke ShowWindow, hwnd,SW_SHOWNORMAL
	invoke UpdateWindow, hwnd
	invoke GetMenu,hwnd
	mov  hMenu,eax
	.WHILE TRUE
                invoke GetMessage, ADDR msg,NULL,0,0
                .BREAK .IF (!eax)
                invoke TranslateMessage, ADDR msg
                invoke DispatchMessage, ADDR msg
	.ENDW
	mov     eax,msg.wParam
	ret
WinMain endp
WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
	.IF uMsg==WM_CREATE
		invoke CreateEvent,NULL,FALSE,FALSE,NULL
		mov  hEventStart,eax
		mov  eax,OFFSET ThreadProc
		invoke CreateThread,NULL,NULL,eax,\
                             NULL,NORMAL_PRIORITY_CLASS,\
                             ADDR ThreadID
		mov  hThread,eax
	.ELSEIF uMsg==WM_DESTROY
		invoke PostQuitMessage,NULL
	.ELSEIF uMsg==WM_COMMAND
		mov eax,wParam
		.if lParam==0
			.if ax==IDM_START_THREAD
				invoke SetEvent,hEventStart
				invoke EnableMenuItem,hMenu,IDM_START_THREAD,MF_GRAYED
				invoke EnableMenuItem,hMenu,IDM_STOP_THREAD,MF_ENABLED
			.elseif ax==IDM_STOP_THREAD
				mov  EventStop,TRUE
				invoke EnableMenuItem,hMenu,IDM_START_THREAD,MF_ENABLED
				invoke EnableMenuItem,hMenu,IDM_STOP_THREAD,MF_GRAYED
			.else
				invoke DestroyWindow,hWnd
			.endif
		.endif
	.ELSEIF uMsg==WM_FINISH
		invoke MessageBox,NULL,ADDR SuccessString,ADDR AppName,MB_OK
	.ELSE
		invoke DefWindowProc,hWnd,uMsg,wParam,lParam
		ret
	.ENDIF
	xor    eax,eax
	ret
WndProc endp

ThreadProc PROC USES ecx Param:DWORD
        invoke WaitForSingleObject,hEventStart,INFINITE
        mov  ecx,600000000
        .WHILE ecx!=0
                .if EventStop==FALSE
                        add  eax,eax
                        dec  ecx
                .else
                        invoke MessageBox,hwnd,ADDR StopString,ADDR AppName,MB_OK
                        mov  EventStop,FALSE
                        jmp ThreadProc
                .endif
        .ENDW
        invoke PostMessage,hwnd,WM_FINISH,NULL,NULL
        invoke EnableMenuItem,hMenu,IDM_START_THREAD,MF_ENABLED
        invoke EnableMenuItem,hMenu,IDM_STOP_THREAD,MF_GRAYED
        jmp   ThreadProc
        ret
ThreadProc ENDP
end start
