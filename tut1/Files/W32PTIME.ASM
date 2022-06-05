    Page 60,190
    TITLE W32PTimer - Windows 95 prototype - Timer handling.

                .586
                .MODEL FLAT,STDCALL

                .NOLISTMACRO
                .NOLIST

UniCode         = 0
                INCLUDE INSTR32.MAC

                INCLUDE WIN32INC.EQU
                INCLUDE WIN32.MAC

                INCLUDE KERNEL32.EQU
                INCLUDE USER32.EQU

                INCLUDE W32PROTO.EQU
                .LIST

ErrorBox        PROTO lpszErrorMsg:DWORD
SBDisplay       PROTO uSBPart:DWORD,lpszMsg:DWORD
CvDec2          PROTO
                PAGE
; ==================================================================
; Global Data section.
; ==================================================================

    .DATA


; ==========================================================================
; Create the timer.
; ==========================================================================

    .CONST

ErrorTimer BYTE 'Couldn''t create timer',0


    .DATA

    ALIGN DWORD

hTimer DWORD 0

    .CODE

TMCreate PROTO hWnd:DWORD
TMCreate PROC PUBLIC hWnd:DWORD

    INVOKE SetTimer,                    ;set the timer
             hWnd,                      ;Window handle,
             IDXX_TIMER,                ;Timer handle,
             1000,                      ;every 1000 millisecs,
             0                          ;no timerproc.

    MOV hTimer,EAX                      ;Save timer handle.
      .IF EAX == 0                      ;If timer creation failed,
      INVOKE ErrorBox,                  ;Give error message.
               ErrorTimer
      SUB EAX,EAX                       ;and set EAX back to error.
      .ENDIF

    RET

TMCreate ENDP


; ==========================================================================
; Kill the timer.
; ==========================================================================


TMKill PROTO hWnd:DWORD
TMKill PROC PUBLIC hWnd:DWORD

    INVOKE KillTimer,
             hWnd,
             IDXX_TIMER
    RET

TMKill ENDP


; ==========================================================================
; Process WM_TIMER message:
;   format the current time and display it on the status bar.
; ==========================================================================

    .DATA

Time     SYSTEMTIME <?>

TMsg     LABEL BYTE
TMsgHour BYTE '??'
         BYTE ':'
TMsgMin  BYTE '??'
         BYTE ':'
TMsgSec  BYTE '??'
         BYTE ' '
TMsgAMPM BYTE '?'
         BYTE 'M'
         BYTE 0

    ALIGN DWORD

         .CODE

WinProc_WM_TIMER PROC PUBLIC,
                   hWnd:DWORD,
                   wMsg:DWORD,
                   wParam:DWORD,
                   lParam:DWORD

      .IF wParam == IDXX_TIMER          ;Is it our timer?

      CALL FmTime                       ;Yes. Format and display the time
      INVOKE SBDisplay,                 ;Display time in statusbar,
               SBPART_TIME,             ;SBPART_TIME section.
               OFFSET TMsg
      .ELSE
      INVOKE DefWindowProc,             ;Some other timer, pass to default.
               hWnd,
               wMsg,
               wParam,
               lParam
      .ENDIF

    SUB EAX,EAX
    RET

WinProc_WM_TIMER ENDP


; ==========================================================================
; Get the current time,
; Format it and display it on the status bar.
; ==========================================================================


    .CODE

FmTime PROC
    INVOKE GetLocalTime,                ;get the local time from win32
             OFFSET Time

    MOV TMsgAMPM,'A'                    ;Default to AM,
    SUB EAX,EAX
    MOV AX,Time.wHour                   ;Get hour

      .IF EAX > 12                      ;It's pm.
      MOV TMsgAMPM,'P'                  ;Reset to pm,
      SUB EAX,12                        ;back to 12 hours scale.
      .ENDIF

    LEA EDI,TMsgHour                    ;dest
    INVOKE CvDec2                       ;convert to displayable ascii decimal

    SUB EAX,EAX
    MOV AX,Time.wMinute                 ;integer load the minute
    LEA EDI,TMsgMin                     ;dest
    INVOKE CvDec2                       ;convert to displayable ascii decimal

    SUB EAX,EAX
    MOV AX,Time.wSecond                 ;integer load the second
    LEA EDI,TMsgSec                     ;dest
    INVOKE CvDec2                       ;convert to displayable ascii decimal
    RET
FmTime ENDP


    END
