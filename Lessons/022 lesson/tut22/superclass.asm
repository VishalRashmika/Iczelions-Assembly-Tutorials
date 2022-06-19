.386
.model flat,stdcall
option casemap:none
include \masm32\include\windows.inc
include \masm32\include\user32.inc
include \masm32\include\kernel32.inc
includelib \masm32\lib\user32.lib
includelib \masm32\lib\kernel32.lib

WM_SUPERCLASS equ WM_USER+5
WinMain PROTO :DWORD,:DWORD,:DWORD,:DWORD
EditWndProc PROTO :DWORD,:DWORD,:DWORD,:DWORD

.data
ClassName 	db "SuperclassWinClass",0
AppName	db "Superclassing Demo",0
EditClass 	db "EDIT",0
OurClass	db "SUPEREDITCLASS",0
Message	db "You pressed the Enter key in the text box!",0

.data?
hInstance	dd ?
hwndEdit	dd 6 dup(?)
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

	mov wc.cbSize,SIZEOF WNDCLASSEX
	mov wc.style, CS_HREDRAW or CS_VREDRAW
	mov wc.lpfnWndProc, OFFSET WndProc
	mov wc.cbClsExtra,NULL
	mov wc.cbWndExtra,NULL
	push hInst
	pop wc.hInstance
	mov wc.hbrBackground,COLOR_APPWORKSPACE
	mov wc.lpszMenuName,NULL
	mov wc.lpszClassName,OFFSET ClassName
	invoke LoadIcon,NULL,IDI_APPLICATION
	mov wc.hIcon,eax
	mov wc.hIconSm,eax
	invoke LoadCursor,NULL,IDC_ARROW
	mov wc.hCursor,eax
	invoke RegisterClassEx, addr wc
	invoke CreateWindowEx,WS_EX_CLIENTEDGE+WS_EX_CONTROLPARENT,ADDR ClassName,ADDR AppName,\
           WS_OVERLAPPED+WS_CAPTION+WS_SYSMENU+WS_MINIMIZEBOX+WS_MAXIMIZEBOX+WS_VISIBLE,CW_USEDEFAULT,\
           CW_USEDEFAULT,350,220,NULL,NULL,\
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

WndProc proc uses ebx edi hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
	LOCAL wc:WNDCLASSEX	
	.if uMsg==WM_CREATE
		mov wc.cbSize,sizeof WNDCLASSEX
		invoke GetClassInfoEx,NULL,addr EditClass,addr wc
		push wc.lpfnWndProc
		pop OldWndProc
		mov wc.lpfnWndProc, OFFSET EditWndProc
		push hInstance
		pop wc.hInstance
		mov wc.lpszClassName,OFFSET OurClass
		invoke RegisterClassEx, addr wc
		xor ebx,ebx
		mov edi,20
		.while ebx<6
			invoke CreateWindowEx,WS_EX_CLIENTEDGE,ADDR OurClass,NULL,\
     		      WS_CHILD+WS_VISIBLE+WS_BORDER,20,\
          		 edi,300,25,hWnd,ebx,\
		           hInstance,NULL		
			mov dword ptr [hwndEdit+4*ebx],eax
			add edi,25
			inc ebx
		.endw
		invoke SetFocus,hwndEdit
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
		.elseif al==VK_TAB
			invoke GetKeyState,VK_SHIFT
			test eax,80000000
			.if ZERO?
				invoke GetWindow,hEdit,GW_HWNDNEXT
				.if eax==NULL
					invoke GetWindow,hEdit,GW_HWNDFIRST
				.endif
			.else
				invoke GetWindow,hEdit,GW_HWNDPREV
				.if eax==NULL
					invoke GetWindow,hEdit,GW_HWNDLAST
				.endif
			.endif
			invoke SetFocus,eax
			xor eax,eax
			ret
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
