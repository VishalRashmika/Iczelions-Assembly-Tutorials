include windows.inc
includelib user32.lib
includelib kernel32.lib
includelib gdi32.lib

DlgProc PROTO :HWND, :DWORD, :DWORD, :DWORD

.data
ClassName db "SimpleWinClass",0
AppName  db "Our Main Window",0
MenuName db "FirstMenu",0
DlgName db "MyDialog",0
TestString db "Hello, everybody",0

.data?
hInstance HINSTANCE ?
CommandLine LPSTR ?

.const
IDM_EXIT equ 1
IDM_ABOUT equ 2
IDC_EDIT  equ 3000
IDC_BUTTON equ 3001
IDC_EXIT equ 3002

.code
start:
	invoke GetModuleHandle, NULL
	mov    hInstance,eax
	invoke GetCommandLine
        invoke WinMain, hInstance,NULL,CommandLine, SW_SHOWDEFAULT
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
        mov   wc.hbrBackground,COLOR_WINDOW+1
        mov   wc.lpszMenuName,OFFSET MenuName
	mov   wc.lpszClassName,OFFSET ClassName
        invoke LoadIcon,NULL,IDI_APPLICATION
	mov   wc.hIcon,eax
        mov   wc.hIconSm,0
        invoke LoadCursor,NULL,IDC_ARROW
	mov   wc.hCursor,eax
        invoke RegisterClassEx, addr wc
        INVOKE CreateWindowEx,WS_EX_CLIENTEDGE,ADDR ClassName,ADDR AppName,\
           WS_OVERLAPPEDWINDOW,CW_USEDEFAULT,\
           CW_USEDEFAULT,300,200,NULL,NULL,\
           hInst,NULL
        mov   hwnd,eax
        INVOKE ShowWindow, hwnd,SW_SHOWNORMAL
        INVOKE UpdateWindow, hwnd
        .WHILE TRUE
                INVOKE GetMessage, ADDR msg,NULL,0,0
                .BREAK .IF (!eax)
                INVOKE TranslateMessage, ADDR msg
                INVOKE DispatchMessage, ADDR msg
        .ENDW
        mov     eax,msg.wParam
        ret
WinMain endp
WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
	mov   eax,uMsg
	.IF eax==WM_DESTROY
		invoke PostQuitMessage,NULL
        .ELSEIF eax==WM_COMMAND
                mov eax,wParam
                .if ax==IDM_ABOUT
                        invoke DialogBoxParam,hInstance, addr DlgName,hWnd,OFFSET DlgProc,NULL
                .else
                        invoke DestroyWindow, hWnd
                .endif
        .ELSE
                invoke DefWindowProc,hWnd,uMsg,wParam,lParam
                ret
	.ENDIF
        xor    eax,eax
	ret
WndProc endp

DlgProc PROC hWnd:HWND,iMsg:DWORD,wParam:WPARAM, lParam:LPARAM
        mov  eax,iMsg
        .if eax==WM_INITDIALOG
                invoke GetDlgItem,hWnd,IDC_EDIT
                invoke SetFocus,eax
        .elseif eax==WM_CLOSE
                invoke EndDialog,hWnd,NULL
        .elseif eax==WM_COMMAND
                mov eax,wParam
                .if eax==IDC_EXIT
                        invoke SendMessage,hWnd,WM_CLOSE,NULL,NULL
                .elseif eax==IDC_BUTTON
                        invoke SetDlgItemText,hWnd,IDC_EDIT,ADDR TestString
                .endif
        .else
                mov eax,FALSE
                ret
        .endif
        mov  eax,TRUE
        ret
DlgProc endp
        end start
