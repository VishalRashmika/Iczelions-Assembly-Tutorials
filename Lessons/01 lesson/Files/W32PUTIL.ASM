    Page 60,190
    TITLE W32PUtil - Windows 95 prototype - Utility routines.

                .586
                .MODEL FLAT,STDCALL

                .NOLISTMACRO
                .NOLIST

UniCode         = 0

                INCLUDE INSTR32.MAC

                INCLUDE WIN32INC.EQU

                INCLUDE KERNEL32.EQU
                INCLUDE USER32.EQU

                .LIST

; External references.

                PAGE

; ==========================================================================
; Give error message.
; On entry,
;   EAX => ASCIIZ error message,
; On exit,
;   EAX undefined, other registers unchanged.
; ==========================================================================

    .CONST

ErrorTitle BYTE 'Ka-Boooom!',0
           ALIGN DWORD

    .CODE

ErrorBox        PROTO lpszErrorMsg:DWORD
ErrorBox        PROC  PUBLIC lpszErrorMsg:DWORD

    INVOKE MessageBox,                  ;Complain to the user.
             0,                         ;No owner window,
             lpszErrorMsg,              ;user message,
             OFFSET ErrorTitle,         ;dialog box title,
             MB_OK                      ;wait for OK from user.

    RET

ErrorBox        ENDP

; ==========================================================================
; Display system error message and return system error code.
; This function is reentrant (thread enabled).
; ==========================================================================

    .DATA

    .CODE

DisplayLastError PROTO
DisplayLastError PROC PUBLIC USES EBX EDI ESI

    LOCAL lpszMessage:DWORD


    INVOKE GetLastError                 ;See why.
    MOV EBX,EAX                         ;Keep a copy of error code in EBX.
                                        ;Get/Format system error message.
                                        ;no lpSource format string,
                                        ;MessageID from GetLastError,
                                        ;no language ID,
                                        ;pointer to message returned by fnc,
                                        ;no use for buffer length,
    INVOKE FormatMessage,               ;no use of arguments array.
             FORMAT_MESSAGE_ALLOCATE_BUFFER or FORMAT_MESSAGE_FROM_SYSTEM,
             0,EBX,0,ADDR lpszMessage,0,0
    INVOKE ErrorBox,                    ;Display error message.
             lpszMessage
    INVOKE LocalFree,                   ;Free memory allocated by
             lpszMessage                ;FormatMessage.

    MOV EAX,EBX                         ;Restore error code.
RET

DisplayLastError ENDP


; ==========================================================================
;  Convert bin number in EAX into (ECX) digit ASCII field at [EDI]
;  Non significant positions on the left appear as zeroes (e.g. 000012).
;  EAX = source integer,
;  ECX = number of bytes to output,
;  EDI = dest address
;  If output field is too small for input value, high order digits
;     are truncated and lost.
;  On exit,
;   EAX undefined,
;   all other registers unchanged.
; ==========================================================================

CvDec PROTO
CvDec PROC PUBLIC USES EBX ECX EDX EDI
      .IF ECX != 0                      ;Just exit if null (bad) length.
      LEA EDI,[EDI][ECX]                ;Get EDI => past last digit in field.
      MOV EBX,10                        ;Setup divisor.
        .REPEAT
        DEC EDI                         ;Point to previous ASCII slot,
        XOR EDX,EDX                     ;EDX:EAX = Dividend.
          .IF EAX != 0                  ;Save bunch of cycles if no more to divide.
          DIV EBX                       ;EAX = EAX/10, EDX = remainder.
          .ENDIF
        OR DL,'0'                       ;Turn BCD digit to ASCII,
        MOV [EDI],DL                    ;store ASCII digit,
        DEC ECX                         ;decrement loop count,
        .UNTIL ZERO?                    ;loop again if digit(s) left.
      .ENDIF
      RET
CvDec ENDP


; ==========================================================================
;  Convert bin number in EAX into 2 digit ASCII field at [EDI]
;  EAX = source integer,
;  EDI = dest address
;  If output field is too small to hold input value, high order digits
;     are truncated and lost.
;  On exit,
;   EAX undefined,
;   all other registers unchanged.
; ==========================================================================

CvDec2 PROTO
CvDec2 PROC PUBLIC USES ECX
    MOV ECX,2
    INVOKE CvDec
    RET
CvDec2 ENDP


    END
