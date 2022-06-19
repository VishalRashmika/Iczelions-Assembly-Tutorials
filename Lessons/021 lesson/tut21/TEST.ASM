.386
.model flat,stdcall
include windows.inc
include user32.inc
include kernel32.inc
includelib user32.lib
includelib kernel32.lib

WinMain PROTO :DWORD,:DWORD,:DWORD,:SDWORD
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

WinMain proc hInst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:SDWORD
	LOCAL wc:WNDCLASSEX
	LOCAL msg:MSG
	LOCAL hwnd:HWND
	mov   wc.cbSize,SIZEOF WNDCLASSEX
	mov   wc.style, CS_HREDRAW or CS_VREDRAW
	mov   wc.lpfnWndProc, OFFSET WndProc
	mov   wc.cbClsExtra,NULL
	mov   wc.cbWndExtra,NULL
	push  hInstance
	pop   wc.hInstance
	mov   wc.hbrBackground,COLOR_APPWORKSPACE
	mov   wc.lpszMenuName,IDR_MAINMENU
	mov   wc.lpszClassName,OFFSET ClassName
	invoke LoadIcon,NULL,IDI_APPLICATION
	mov   wc.hIcon,eax
	mov   wc.hIconSm,0
	invoke LoadCursor,NULL,IDC_ARROW
	mov   wc.hCursor,eax
	invoke RegisterClassEx, addr wc
	invoke CreateWindowEx,WS_EX_CLIENTEDGE,ADDR ClassName,ADDR AppName,\
           WS_OVERLAPPEDWINDOW+WS_VISIBLE,CW_USEDEFAULT,\
           CW_USEDEFAULT,400,200,NULL,NULL,\
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
	LOCAL rect:RECT
	LOCAL hRead:DWORD
	LOCAL hWrite:DWORD
	LOCAL startupinfo:STARTUPINFO
	LOCAL pinfo:PROCESS_INFORMATION
	LOCAL buffer[1024]:byte
	LOCAL bytesRead:DWORD
	mov   eax,uMsg
	.if eax==WM_CREATE
		invoke CreateWindowEx,NULL,addr EditClass,NULL,WS_CHILD+WS_VISIBLE++ES_READONLY+ES_MULTILINE+ES_AUTOHSCROLL,0,0,0,0,hWnd,NULL,hInstance,NULL
		mov hwndEdit,eax
	.elseif eax==WM_SIZE
		mov edx,lParam
		mov ecx,edx
		shr ecx,16
		and edx,0ffffh
		invoke MoveWindow,hwndEdit,0,0,edx,ecx,FALSE
	.elseif eax==WM_COMMAND
		.if lParam==0
			mov eax,wParam
			.if ax==IDM_ASSEMBLE
				invoke CreatePipe,addr hRead,addr hWrite,NULL,NULL
				.if eax==NULL
					invoke MessageBox,hWnd,addr CreatePipeError,addr AppName,MB_ICONERROR+MB_OK
				.else
					mov startupinfo.cb,sizeof STARTUPINFO
					invoke GetStartupInfo,addr startupinfo
					push hWrite
					pop startupinfo.hStdOutput
					push hWrite
					pop startupinfo.hStdError
					or startupinfo.dwFlags,STARTF_USESHOWWINDOW+STARTF_USESTDHANDLES
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
				.endif
			.endif
		.endif
	.elseif eax==WM_DESTROY
		invoke PostQuitMessage,NULL
	.else
		invoke DefWindowProc,hWnd,uMsg,wParam,lParam		
		ret
	.endif
	xor eax,eax
	ret
WndProc endp

end start
