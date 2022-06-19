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
EditWndProc PROTO :DWORD,:DWORD,:DWORD,:DWORD

.data
ClassName 	db "SubclassWinClass",0
AppName  	db "Subclassing Demo",0
EditClass 	db "EDIT",0
Message	db "You pressed the Enter key in the text box!",0

.data?
hInstance	HINSTANCE ?
hwndEdit	dd ?
OldWndProc	dd ?

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
	.if uMsg==WM_CREATE
		invoke CreateWindowEx,WS_EX_CLIENTEDGE,ADDR EditClass,NULL,\
     	      WS_CHILD+WS_VISIBLE+WS_BORDER,20,\
          	 20,300,25,hWnd,NULL,\
	           hInstance,NULL
		mov hwndEdit,eax
		invoke SetFocus,eax
		;-----------------------------------------
		; Subclass it!
		;-----------------------------------------
		invoke SetWindowLong,hwndEdit,GWL_WNDPROC,addr EditWndProc
		mov OldWndProc,eax
	.elseif uMsg==WM_DESTROY
		invoke PostQuitMessage,NULL
	.else
		invoke DefWindowProc,hWnd,uMsg,wParam,lParam		
		ret
	.endif
	xor eax,eax
	ret
WndProc endp

EditWndProc PROC hEdit:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD
	.if uMsg==WM_CHAR
		mov eax,wParam
		.if (al>="0" && al<="9") || (al>="A" && al<="F") || (al>="a" && al<="f") || al==VK_BACK
			.if al>="a" && al<="f"
				sub al,20h
			.endif
			invoke CallWindowProc,OldWndProc,hEdit,uMsg,eax,lParam
			ret
		.endif
	.elseif uMsg==WM_KEYDOWN
		mov eax,wParam
		.if al==VK_RETURN
			invoke MessageBox,hEdit,addr Message,addr AppName,MB_OK+MB_ICONINFORMATION
			invoke SetFocus,hEdit
		.else
			invoke CallWindowProc,OldWndProc,hEdit,uMsg,wParam,lParam
			ret
		.endif
	.else
		invoke CallWindowProc,OldWndProc,hEdit,uMsg,wParam,lParam
		ret
	.endif
	xor eax,eax
	ret
EditWndProc endp
end start
