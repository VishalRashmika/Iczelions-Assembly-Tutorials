include windows.inc
includelib user32.lib
includelib kernel32.lib
includelib gdi32.lib

;DlgProc PROTO :DWORD,:DWORD,:DWORD,:DWORD

.data
DlgName db "MyDialog",0
AppName db "Our Second Dialog Box",0
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
        mov   eax, OFFSET DlgProc
        invoke DialogBoxParam, hInst, ADDR DlgName,NULL,eax,NULL
        ret
WinMain endp
DlgProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
	mov   eax,uMsg
        .IF eax==WM_INITDIALOG
                invoke GetDlgItem, hWnd,IDC_EDIT
                invoke SetFocus,eax
        .ELSEIF eax==WM_CLOSE
                invoke SendMessage,hWnd,WM_COMMAND,IDM_EXIT,0
        .ELSEIF eax==WM_COMMAND
                mov eax,wParam
                .IF lParam==0
                        .IF ax==IDM_GETTEXT
                                invoke GetDlgItemText,hWnd,IDC_EDIT,ADDR buffer,512
                                invoke MessageBox,NULL,ADDR buffer,ADDR AppName,MB_OK
                        .ELSEIF ax==IDM_CLEAR
                                invoke SetDlgItemText,hWnd,IDC_EDIT,NULL
                        .ELSEIF ax==IDM_EXIT
                                invoke EndDialog, hWnd,NULL
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
                mov eax,FALSE
                ret
	.ENDIF
        mov eax,TRUE
	ret
DlgProc endp
        end start

