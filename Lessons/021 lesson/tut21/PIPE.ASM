.386
.model flat,stdcall
option casemap:none
include \masm32\include\windows.inc
include \masm32\include\user32.inc
include \masm32\include\kernel32.inc
include \masm32\include\gdi32.inc
includelib \masm32\lib\gdi32.lib
includelib \masm32\lib\user32.lib
includelib \masm32\lib\kernel32.lib

WinMain PROTO :DWORD,:DWORD,:DWORD,:DWORD

.const
IDR_MAINMENU	equ 101
IDM_ASSEMBLE	equ 40001


.data
ClassName 	db "PipeWinClass",0
AppName  	db "One-way Pipe Example",0
EditClass	db "EDIT",0
CreatePipeError db "Error during pipe creation",0
CreateProcessError db "Error during process creation",0
CommandLine db "ml /c /coff /Cp test.asm",0

.data?
hInstance	HINSTANCE ?
hwndEdit	dd ?
.code
start:
	invoke GetModuleHandle, NULL
	mov    hInstance,eax
	invoke WinMain, hInstance,NULL,NULL, SW_SHOWDEFAULT
	invoke ExitProcess,eax

WinMain proc hInst:DWORD,hPrevInst:DWORD,CmdLine:DWORD,CmdShow:DWORD
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
	mov   wc.lpszMenuName,IDR_MAINMENU
	mov   wc.lpszClassName,OFFSET ClassName
	invoke LoadIcon,NULL,IDI_APPLICATION
	mov   wc.hIcon,eax
	mov   wc.hIconSm,eax
	invoke LoadCursor,NULL,IDC_ARROW
	mov   wc.hCursor,eax
	invoke RegisterClassEx, addr wc
	invoke CreateWindowEx,WS_EX_CLIENTEDGE,ADDR ClassName,ADDR AppName,\
           WS_OVERLAPPEDWINDOW+WS_VISIBLE,CW_USEDEFAULT,\
           CW_USEDEFAULT,400,200,NULL,NULL,\
           hInst,NULL
	mov hwnd,eax
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
	LOCAL rect:RECT
	LOCAL hRead:DWORD
	LOCAL hWrite:DWORD
	LOCAL startupinfo:STARTUPINFO
	LOCAL pinfo:PROCESS_INFORMATION
	LOCAL buffer[1024]:byte
	LOCAL bytesRead:DWORD
	LOCAL hdc:DWORD
	LOCAL sat:SECURITY_ATTRIBUTES
	.if uMsg==WM_CREATE
		invoke CreateWindowEx,NULL,addr EditClass,NULL,WS_CHILD+WS_VISIBLE+ES_MULTILINE+ES_AUTOHSCROLL+ES_AUTOVSCROLL,0,0,0,0,hWnd,NULL,hInstance,NULL
		mov hwndEdit,eax
	.elseif uMsg==WM_CTLCOLOREDIT
		invoke SetTextColor,wParam,Yellow
		invoke SetBkColor,wParam,Black
		invoke GetStockObject,BLACK_BRUSH
		ret
	.elseif uMsg==WM_SIZE
		mov edx,lParam
		mov ecx,edx
		shr ecx,16
		and edx,0ffffh
		invoke MoveWindow,hwndEdit,0,0,edx,ecx,TRUE
	.elseif uMsg==WM_COMMAND
		.if lParam==0
			mov eax,wParam
			.if ax==IDM_ASSEMBLE
				mov sat.nLength,sizeof SECURITY_ATTRIBUTES
				mov sat.lpSecurityDescriptor,NULL
				mov sat.bInheritHandle,TRUE
				invoke CreatePipe,addr hRead,addr hWrite,addr sat,NULL
				.if eax==NULL
					invoke MessageBox,hWnd,addr CreatePipeError,addr AppName,MB_ICONERROR+MB_OK
				.else
					mov startupinfo.cb,sizeof STARTUPINFO
					invoke GetStartupInfo,addr startupinfo
					mov eax,hWrite
					mov startupinfo.hStdOutput,eax
					mov startupinfo.hStdError,eax
					mov startupinfo.dwFlags,STARTF_USESHOWWINDOW+STARTF_USESTDHANDLES
					mov startupinfo.wShowWindow,SW_HIDE
					;-------------------------------------------------
					; Create process
					;-------------------------------------------------
					invoke CreateProcess,NULL,addr CommandLine,NULL,NULL,TRUE,NULL,NULL,NULL,addr startupinfo,addr pinfo
					.if eax==NULL
						invoke MessageBox,hWnd,addr CreateProcessError,addr AppName,MB_ICONERROR+MB_OK
					.else
						invoke CloseHandle,hWrite
						.while TRUE
							invoke RtlZeroMemory,addr buffer,1024
							invoke ReadFile,hRead,addr buffer,1023,addr bytesRead,NULL
							.if eax==NULL
								.break
							.else
								invoke SendMessage,hwndEdit,EM_SETSEL,-1,0
								invoke SendMessage,hwndEdit,EM_REPLACESEL,FALSE,addr buffer
							.endif
						.endw
					.endif
					invoke CloseHandle,hRead
					invoke CloseHandle,pinfo.hProcess
					invoke CloseHandle,pinfo.hThread
				.endif
			.endif
		.endif
	.elseif uMsg==WM_DESTROY
		invoke PostQuitMessage,NULL
	.else
		invoke DefWindowProc,hWnd,uMsg,wParam,lParam		
		ret
	.endif
	xor eax,eax
	ret
WndProc endp

end start
