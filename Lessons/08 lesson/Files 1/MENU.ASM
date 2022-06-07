include windows.inc
includelib user32.lib
includelib kernel32.lib
includelib gdi32.lib

.data
ClassName db "SimpleWinClass",0
AppName  db "Our First Window",0
MenuName db "FirstMenu",0
Test_string db "You selected Test menu item",0
Hello_string db "Hello, my friend",0
Goodbye_string db "See you again, bye",0

.data?
hInstance HINSTANCE ?
CommandLine LPSTR ?

.const
IDM_TEST equ 1
IDM_HELLO equ 2
IDM_GOODBYE equ 3
IDM_EXIT equ 4

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
        INVOKE CreateWindowEx,NULL,ADDR ClassName,ADDR AppName,\
           WS_OVERLAPPEDWINDOW,CW_USEDEFAULT,\
           CW_USEDEFAULT,CW_USEDEFAULT,CW_USEDEFAULT,NULL,NULL,\
           hInst,NULL
        mov   hwnd,eax
        INVOKE ShowWindow, hwnd,SW_SHOWNORMAL
        INVOKE UpdateWindow, hwnd
        .WHILE TRUE
                INVOKE GetMessage, ADDR msg,NULL,0,0
                .BREAK .IF (!eax)
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
                .IF ax==IDM_TEST
                        invoke MessageBox,NULL,ADDR Test_string,OFFSET AppName,MB_OK
                .ELSEIF ax==IDM_HELLO
                        invoke MessageBox, NULL,ADDR Hello_string, OFFSET AppName,MB_OK
                .ELSEIF ax==IDM_GOODBYE
                        invoke MessageBox,NULL,ADDR Goodbye_string, OFFSET AppName, MB_OK
                .ELSE
                        invoke DestroyWindow,hWnd
                .ENDIF
        .ELSE
                invoke DefWindowProc,hWnd,uMsg,wParam,lParam
                ret
	.ENDIF
        xor    eax,eax
	ret
WndProc endp
        end start
