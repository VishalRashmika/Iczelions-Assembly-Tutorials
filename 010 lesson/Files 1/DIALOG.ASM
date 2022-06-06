include windows.inc
includelib user32.lib
includelib kernel32.lib
includelib gdi32.lib

.data
ClassName db "DLGCLASS",0
MenuName db "MyMenu",0
DlgName db "MyDialog",0
AppName db "Our First Dialog Box",0
TestString db "Wow! I'm in an edit box now",0

.data?
hInstance HINSTANCE ?
CommandLine LPSTR ?
buffer db 512 dup(?),0

.const
IDC_EDIT        equ 3000
IDC_BUTTON      equ 3001
IDC_EXIT        equ 3002
IDM_GETTEXT     equ 32000
IDM_CLEAR       equ 32001
IDM_EXIT        equ 32002

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
        LOCAL hDlg:HWND
	mov   wc.cbSize,SIZEOF WNDCLASSEX
	mov   wc.style, CS_HREDRAW or CS_VREDRAW
	mov   wc.lpfnWndProc, OFFSET WndProc
	mov   wc.cbClsExtra,NULL
        mov   wc.cbWndExtra,DLGWINDOWEXTRA
        push  hInstance
        pop   wc.hInstance
        mov   wc.hbrBackground,COLOR_BTNFACE+1
        mov   wc.lpszMenuName,OFFSET MenuName
	mov   wc.lpszClassName,OFFSET ClassName
        invoke LoadIcon,NULL,IDI_APPLICATION
	mov   wc.hIcon,eax
        mov   wc.hIconSm,0
        invoke LoadCursor,NULL,IDC_ARROW
	mov   wc.hCursor,eax
        invoke RegisterClassEx, addr wc
        invoke CreateDialogParam,hInstance,ADDR DlgName,NULL,NULL,NULL
        mov   hDlg,eax
        INVOKE ShowWindow, hDlg,SW_SHOWNORMAL
        INVOKE UpdateWindow, hDlg
        invoke GetDlgItem,hDlg,IDC_EDIT
        invoke SetFocus,eax
        .WHILE TRUE
                INVOKE GetMessage, ADDR msg,NULL,0,0
                .BREAK .IF (!eax)
                invoke IsDialogMessage, hDlg, ADDR msg
                .if eax==FALSE
                        INVOKE TranslateMessage, ADDR msg
                        INVOKE DispatchMessage, ADDR msg
                .endif
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
                .IF lParam==0
                        .IF ax==IDM_GETTEXT
                                invoke GetDlgItemText,hWnd,IDC_EDIT,ADDR buffer,512
                                invoke MessageBox,NULL,ADDR buffer,ADDR AppName,MB_OK
                        .ELSEIF ax==IDM_CLEAR
                                invoke SetDlgItemText,hWnd,IDC_EDIT,NULL
                        .ELSE
                                invoke DestroyWindow,hWnd
                        .ENDIF
                .ELSE
                        .IF ax==IDC_BUTTON
                                shr eax,16
                                .IF ax==BN_CLICKED
                                        invoke SetDlgItemText,hWnd,IDC_EDIT,ADDR TestString
                                .ENDIF
                        .ELSEIF ax==IDC_EXIT
                                shr eax,16
                                .IF ax==BN_CLICKED
                                        invoke SendMessage,hWnd,WM_COMMAND,IDM_EXIT,0
                                .ENDIF
                        .ENDIF
                .ENDIF
        .ELSE
                invoke DefWindowProc,hWnd,uMsg,wParam,lParam
                ret
	.ENDIF
        xor    eax,eax
	ret
WndProc endp
        end start
