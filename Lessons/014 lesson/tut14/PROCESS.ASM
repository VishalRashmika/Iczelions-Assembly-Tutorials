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
IDM_CREATE_PROCESS equ 1
IDM_TERMINATE equ 2
IDM_EXIT equ 3

.data
ClassName db "Win32ASMProcessClass",0
AppName  db "Win32 ASM Process Example",0
MenuName db "FirstMenu",0
processInfo PROCESS_INFORMATION <>
programname db "msgbox.exe",0

.data?
hInstance HINSTANCE ?
CommandLine LPSTR ?
hMenu HANDLE ?
ExitCode DWORD ?

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
	LOCAL hwnd:HWND
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
	LOCAL startInfo:STARTUPINFO
	.IF uMsg==WM_DESTROY
		invoke PostQuitMessage,NULL
	.ELSEIF uMsg==WM_INITMENUPOPUP
		invoke GetExitCodeProcess,processInfo.hProcess,ADDR ExitCode
		.if eax==TRUE
			.if ExitCode==STILL_ACTIVE
				invoke EnableMenuItem,hMenu,IDM_CREATE_PROCESS,MF_GRAYED
				invoke EnableMenuItem,hMenu,IDM_TERMINATE,MF_ENABLED
			.else
				invoke EnableMenuItem,hMenu,IDM_CREATE_PROCESS,MF_ENABLED
				invoke EnableMenuItem,hMenu,IDM_TERMINATE,MF_GRAYED
			.endif
		.else
			invoke EnableMenuItem,hMenu,IDM_CREATE_PROCESS,MF_ENABLED
			invoke EnableMenuItem,hMenu,IDM_TERMINATE,MF_GRAYED
		.endif
	.ELSEIF uMsg==WM_COMMAND
		mov eax,wParam
		.if lParam==0
			.if ax==IDM_CREATE_PROCESS
				.if processInfo.hProcess!=0
					invoke CloseHandle,processInfo.hProcess
					mov processInfo.hProcess,0
				.endif
				invoke GetStartupInfo,ADDR startInfo
				invoke CreateProcess,ADDR programname,NULL,NULL,NULL,FALSE,\
                                        NORMAL_PRIORITY_CLASS,\
                                        NULL,NULL,ADDR startInfo,ADDR processInfo
				invoke CloseHandle,processInfo.hThread
			.elseif ax==IDM_TERMINATE
				invoke GetExitCodeProcess,processInfo.hProcess,ADDR ExitCode
				.if ExitCode==STILL_ACTIVE
					invoke TerminateProcess,processInfo.hProcess,0
				.endif
				invoke CloseHandle,processInfo.hProcess
				mov processInfo.hProcess,0
			.else
				invoke DestroyWindow,hWnd
			.endif
		.endif
	.ELSE
		invoke DefWindowProc,hWnd,uMsg,wParam,lParam
		ret
	.ENDIF
	xor    eax,eax
	ret
WndProc endp
end start
