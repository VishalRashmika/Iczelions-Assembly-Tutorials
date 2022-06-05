    Page 60,190
    TITLE W32PMouse - Windows 95 prototype - Mouse handling.

                .586
                .MODEL FLAT,STDCALL

                .NOLISTMACRO
                .NOLIST

UniCode         = 0
                INCLUDE INSTR32.MAC
                INCLUDE WIN32INC.EQU

                INCLUDE WIN32.MAC

                INCLUDE W32PROTO.EQU
                .LIST

; External references.

CvDec           PROTO
ErrorBox        PROTO lpszErrorMsg:DWORD
SBDisplay       PROTO uSBPart:DWORD,lpszMsg:DWORD
                PAGE
; ==================================================================
; Global Data section.
; ==================================================================

    .DATA


; ==========================================================================
; Received a MOUSEMOVE message.
; The mouse has moved, update the mouse position display on the status bar.
; ==========================================================================

    .DATA


MousePos        BYTE 'X:'
MousePosX       BYTE '????'
                BYTE ' Y:'
MousePosY       BYTE '????'
                BYTE 0

                ALIGN DWORD

    .CODE

WinProc_WM_MOUSEMOVE PROC PUBLIC,
                       hWnd:DWORD,
                       wMsg:DWORD,
                       wParam:DWORD,
                       lParam:DWORD

    SUB EAX,EAX
    MOV AX, WORD PTR lParam             ;get the Y position in EAX.
    LEA EDI,MousePosY                   ;dest
    MOV ECX,4                           ;#bytes
    INVOKE CvDec                        ;convert to displayable ascii decimal
    SUB EAX,EAX
    MOV AX,WORD PTR lParam+2            ;get the X position in EAX,
    LEA EDI,MousePosX                   ;dest
    MOV ECX,4                           ;#bytes
    INVOKE CvDec                        ;convert to displayable ascii decimal

    INVOKE SBDisplay,                   ;Display message on status area
             SBPART_MOUSEMOVE,          ;use the SBPART_MOUSEMOVE section,
             OFFSET MousePos            ;message to display.

    SUB EAX,EAX                         ;Good return.
    RET

    UnusedParm hWnd
    UnusedParm wMsg
    UnusedParm wParam

WinProc_WM_MOUSEMOVE ENDP

    END
