    Page 60,190
    TITLE W32PPrompt - Windows 95 prototype - Prompting dialog handling.

                .586
                .MODEL FLAT,STDCALL

                .NOLISTMACRO
                .NOLIST

UniCode         = 0
                INCLUDE INSTR32.MAC
                INCLUDE WIN32INC.EQU

                INCLUDE WIN32RES.EQU
                INCLUDE WIN32.MAC

                INCLUDE KERNEL32.EQU
                INCLUDE USER32.EQU

                INCLUDE W32PROTO.EQU
                .LIST

; External references.

                EXTRN hInst:DWORD       ;Our process instance.

; Forward references (ML can't handle them for INVOKE/PROTOs. Phooey.)

PromptDlgProc   PROTO

    PAGE
; ==================================================================
; Global Data section.
; ==================================================================

    .DATA


; ==========================================================================
; Received an ID_OPTIONS_TITLE command.
; User selected Options/Title.
; Show the IDD_DIALOGBOX dialog box that initializes a prompt for a new
; title.
; ==========================================================================

    .DATA

InitialValue BYTE 'Prototype Win32 Assembler Program',
                   0,
                   64 DUP(?)


    .CODE

WinProcCMD_ID_OPTIONS_TITLE PROC PUBLIC,
                              hWnd:DWORD,
                              wMsg:DWORD,
                              wParam:DWORD,
                              lParam:DWORD


    INVOKE DialogBoxParam,
             hInst,                     ;Process instance,
             IDD_DIALOGBOX,             ;"Title" box template,
             hWnd,                      ;owner window,
             OFFSET PromptDlgProc,      ;dialog box procedure address,
             0                          ;lparam for WM_DIALOGBOX message.

    INVOKE InvalidateRect,              ;repaint window
             hWnd,                      ;handle to window to invalidate,
             0,                         ;invalidate whole client area,
             TRUE                       ;Erase background, repaint all.
    XOR EAX,EAX
    RET

    UnusedParm wMsg
    UnusedParm wParam
    UnusedParm lParam

WinProcCMD_ID_OPTIONS_TITLE ENDP



; ==========================================================================
; PromptDlgProc dispatcher.
; ==========================================================================

PromptDlgProc PROC

    MOV EAX,ESPwMsg                     ;Get wMsg parm, and dispatch it.

    CALLBACK PromptDlgProc
    MESSAGE WM_INITDIALOG                 ;Dialog initialization
    MSGCHAIN WM_COMMAND,PromptDlgProcCMD  ;End of dialog.
    CALLBACKDEFAULT None                ;NO defproc for dialogs, NEVER EVER!
                                        ;Dialogs just return FALSE!
PromptDlgProc ENDP


; ==========================================================================
; PromptDlgProc Command dispatcher.
; ==========================================================================

PromptDlgProcCMD PROC

    XOR EAX,EAX                         ;Get wMsg parm, and dispatch it.
    MOV AX,WORD PTR ESPwParam

    CALLBACK PromptDlgProcCMD
    MESSAGE IDOK
    MESSAGE IDCANCEL
    CALLBACKDEFAULT None                ;NO defproc for dialogs, NEVER EVER!
                                        ;Dialogs just return FALSE!
PromptDlgProcCMD ENDP



; ==========================================================================
; Prompt Dialog start.
; Must return with EAX = TRUE (if message processed).
;                        FALSE (let Windows default process message).
; ==========================================================================


    .CODE


PromptDlgProc_WM_INITDIALOG PROC PUBLIC,
                              hWnd:DWORD,
                              wMsg:DWORD,
                              wParam:DWORD,
                              lParam:DWORD

    INVOKE SetDlgItemText,              ;Set the Edit control to the
              hWnd,                     ;current text value.
              IDC_EDIT1,
              EAX

    INVOKE GetDlgItem,                  ;Get the handle of the Edit field.
             hWnd,                      ;Window/Dialog handle,
             IDC_EDIT1                  ;resource ID of Edit field.

    SAVE EAX                            ;Save Edit field handle.

    INVOKE SetFocus,                    ;SetFocus to
             EAX                        ;Edit field.
    RESTORE EAX

    INVOKE SendMessage,                 ;limit text size:
             EAX,                       ;Edit field handle,
             EM_LIMITTEXT,              ;limit the input text size,
             (SIZEOF InitialValue)-1,   ;wParam = max number of bytes to accept,
             0                          ;No lParam.

    MOV EAX,FALSE                       ;Tell Win to not bother about the
    RET                                 ;focus, we did it.

    UnusedParm wMsg
    UnusedParm wParam
    UnusedParm lParam

PromptDlgProc_WM_INITDIALOG ENDP


; ==========================================================================
; Prompt Dialog Message processing procedures (end of dialog).
; Must return with EAX = TRUE (if message processed).
;                        FALSE (let Windows default process message).
; ==========================================================================



PromptDlgProcCMD_IDOK PROC PUBLIC,
                              hWnd:DWORD,
                              wMsg:DWORD,
                              wParam:DWORD,
                              lParam:DWORD

    INVOKE GetDlgItemText,              ;Get the text stored in the Edit field,
             hWnd,                      ;handle to the dialog,
             IDC_EDIT1,                 ;get it from Edit field,
             OFFSET InitialValue,       ;move it to the address passed by
             (SIZEOF InitialValue)-1    ;the DialogBoxParam message.

    INVOKE EndDialog,                   ;Tear down the dialog box.
             hWnd,
             wParam
    MOV EAX,TRUE                        ;And return Done, message processed.
    RET

    UnusedParm wMsg
    UnusedParm lParam

PromptDlgProcCMD_IDOK ENDP


PromptDlgProcCMD_IDCANCEL PROC PUBLIC,
                              hWnd:DWORD,
                              wMsg:DWORD,
                              wParam:DWORD,
                              lParam:DWORD

    INVOKE Beep,                        ;Make some noise
             1000,                      ;frequency (hz),
             1000                       ;duration (ms).

    INVOKE EndDialog,                   ;Tear down the dialog box.
             hWnd,
             wParam
    MOV EAX,TRUE                        ;And return Done, message processed.
    RET

    UnusedParm wMsg
    UnusedParm lParam

PromptDlgProcCMD_IDCANCEL ENDP


    END
