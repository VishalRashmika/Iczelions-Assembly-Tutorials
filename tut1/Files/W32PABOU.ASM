    Page 60,190
    TITLE W32PAbout - Windows 95 prototype - "About" dialog handling.

                .586
                .MODEL FLAT,STDCALL

                .NOLISTMACRO
                .NOLIST

UniCode         = 0
                INCLUDE INSTR32.MAC
                INCLUDE WIN32INC.EQU

                INCLUDE WIN32RES.EQU
                INCLUDE WIN32.MAC

                INCLUDE USER32.EQU

                INCLUDE W32PROTO.EQU
                .LIST

; External references.

                EXTRN hInst:DWORD       ;Our process instance.

; Forward references (ML can't handle them for INVOKE/PROTOs. Phooey.)

AboutDlgProc    PROTO

                PAGE
; ==================================================================
; Global Data section.
; ==================================================================

                .DATA


; ==========================================================================
; Received an ID_HELP_ABOUT menu command in the main window.
; Invoke About dialog box.
; ==========================================================================

                .CODE

WinProcCMD_ID_HELP_ABOUT PROC PUBLIC,
                           hWnd:DWORD,
                           wMsg:DWORD,
                           wParam:DWORD,
                           lParam:DWORD

    INVOKE DialogBoxParam,
             hInst,                     ;Process instance,
             IDD_ABOUTBOX,              ;"About" box template resource,
             hWnd,                      ;owner window,
             OFFSET AboutDlgProc,       ;dialog box procedure,
             0                          ;lparam for WM_DIALOGBOX message.
    XOR EAX,EAX
    RET

    UnusedParm wMsg
    UnusedParm wParam
    UnusedParm lParam

WinProcCMD_ID_HELP_ABOUT ENDP


; ==========================================================================
; AboutProc dispatcher.
; Called after we called DialogBoxParam above.
; ==========================================================================

AboutDlgProc PROC

    MOV EAX,ESPwMsg                     ;Get wMsg parm, and dispatch it.

    CALLBACK AboutProc
    MSGCHAIN WM_COMMAND,AboutDlgProcCMD
    CALLBACKDEFAULT None                ;NO defproc for dialogs, NEVER EVER!
                                        ;Dialogs just return FALSE!
AboutDlgProc ENDP



; ==========================================================================
; AboutProc Command dispatcher.
; ==========================================================================

AboutDlgProcCMD PROC

    SUB EAX,EAX                         ;Get wMsg parm, and dispatch it.
    MOV AX,WORD PTR ESPwParam

    CALLBACK AboutDlgProcCMD
    MESSAGE IDOK
    MESSAGE IDCANCEL
    CALLBACKDEFAULT None                ;NO defproc for dialogs, NEVER EVER!
                                        ;Dialogs just return FALSE!
AboutDlgProcCMD ENDP


; ==========================================================================
; About Dialog Message processing procedures.
; Must return with EAX = Error code.
; ==========================================================================


; ==========================================================================
; Received a WM_COMMAND message.
; End dialog anyway, param could be either OK or Cancel.
; ==========================================================================

AboutDlgProcCMD_IDCANCEL PROC,
                           hWnd:DWORD,
                           wMsg:DWORD,
                           wParam:DWORD,
                           lParam:DWORD

    INVOKE AboutDlgProcCMD_IDOK,
             hWnd,
             wMsg,
             wParam,
             lParam
    RET

AboutDlgProcCMD_IDCANCEL ENDP

AboutDlgProcCMD_IDOK PROC,
                       hWnd:DWORD,
                       wMsg:DWORD,
                       wParam:DWORD,
                       lParam:DWORD

    INVOKE EndDialog,                   ;End the dialog
             hWnd,
             wParam                     ;pass wParam as retcode.
    MOV EAX,TRUE                        ;In any case, ret True (Msg processed).
    RET

    UnusedParm wMsg
    UnusedParm lParam

AboutDlgProcCMD_IDOK ENDP


    END
