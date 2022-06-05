    Page 60,190
    TITLE W32PStatBar - Windows 95 prototype - Status bar handling.

                .586
                .MODEL FLAT,STDCALL

                .NOLISTMACRO
                .NOLIST

UniCode         = 0
                INCLUDE INSTR32.MAC
                INCLUDE WIN32INC.EQU

                INCLUDE WIN32RES.EQU

                INCLUDE COMCTL32.EQU
                INCLUDE USER32.EQU

                INCLUDE W32PROTO.EQU
                .LIST

; External references.

ErrorBox PROTO lpszErrorMsg:DWORD

    PAGE
; ==================================================================
; Global Data section.
; ==================================================================

    .DATA

Parts     DWORD SBPARTS DUP(0)          ;Parts array.
hWndStatB DWORD 0                       ;Status bar handle.

    .CODE

; ==========================================================================
; Create the status bar.
; On entry,
;   ECX = main window handle,
;   EDX = this process handle.
; On exit,
;   EAX undefined,
;   other registers unchanged.
; ==========================================================================

    .CONST

ErrorStatB BYTE 'Could not create status bar',0


    .CODE

SBCreate PROTO hWnd:DWORD
SBCreate PROC PUBLIC USES EBX EDI ESI,
           hWnd:DWORD

    INVOKE CreateStatusWindow,          ;Create status bar. describe style,
             WS_CHILD or WS_BORDER or WS_VISIBLE or SBS_SIZEGRIP,
             0,                         ;no name in first part,
             hWnd,                      ;parent window handle,
             IDXX_STATUSBAR             ;Status bar control identifier.
    MOV hWndStatB,EAX                   ;save the handle to statusbar

      .IF EAX == 0                      ;If create failed,
      INVOKE ErrorBox,                  ;give error,
               OFFSET ErrorStatB
      XOR EAX,EAX                       ;set return reg back to zero.
      .ENDIF
    RET

SBCreate ENDP


SBResize PROTO lParam:DWORD
SBResize PROC PUBLIC lParam:DWORD

      .IF hWndStatB != 0                ;If we have a status handle,
      XOR EBX,EBX                       ;ebx = loword(lparam) = width
      MOV BX,WORD PTR lParam
      XOR EAX,EAX                       ;eax = hiword(lparam) = height
      MOV AX,WORD PTR lParam+2

      INVOKE MoveWindow,                ;adjust window
               hWndStatB,               ;handle to status bar,
               0,                       ;x
               EAX,                     ;y
               EBX,                     ;width,
               EAX,                     ;height,
               TRUE                     ;set repaint flag.

      XOR EAX,EAX
      MOV AX,WORD PTR lParam            ;get width

      SHR EAX,2                         ;/4
      MOV ECX,EAX                       ;save factor
      MOV Parts+0,EAX                   ;make part 1 1/4 the width
      ADD EAX,ECX
      MOV Parts+4,EAX                   ;and also part2, .. etc
      ADD EAX,ECX
      MOV Parts+8,EAX
      MOV Parts+12,-1                   ;the last part extends to the end

      INVOKE SendMessage,               ;set the sections in the statusbar
               hWndStatB,
               SB_SETPARTS,
               SBPARTS,
               OFFSET Parts

      .ENDIF
    RET
SBResize ENDP

; ==========================================================================
; Display a message on the status bar.
; ==========================================================================

SBDisplay PROTO uSBPart:DWORD,lpszMsg:DWORD

SBDisplay PROC PUBLIC uSBPart:DWORD,
            lpszMsg:DWORD

      .IF hWndStatB                     ;If we have a status bar,
      INVOKE SendMessage,               ;Send a message
               hWndStatB,               ;to the status bar
               SB_SETTEXT,              ;display text there
               uSBPart,                 ;status bar section
               lpszMsg                  ;Message to display.
      .ENDIF
    RET
SBDisplay ENDP
    END
