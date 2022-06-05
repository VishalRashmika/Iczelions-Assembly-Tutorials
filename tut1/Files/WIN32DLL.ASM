   Page 60,190
   TITLE MAPI32TS - Console test prog for Win32 DLL demo.


; CREATED:       26 Apr 97 by Philippe Auphelle

; MODIFIED:      dd mmm yy by Philippe Auphelle


; ============================================================================
; Yes, it can be done:
; Test program using the Sample Win32 DLL.
; ============================================================================


                .386
                .MODEL FLAT,STDCALL

                .SALL
                .NOLIST


UniCode         = 0                     ;No Unicode, just plain ASCII.

                INCLUDE INSTR32.MAC
                INCLUDE WIN32INC.EQU
                INCLUDE KERNEL32.EQU

                INCLUDE Win32DLL.inc

                .LIST

DoDisplay       PROTO Message:DWORD,       ;Because INVOKE doesn't handle
                      MessageLength:DWORD  ;forward references (boo).

                SUBTITLE Macros & Data
                PAGE
                .DATA

Display         MACRO String
                INVOKE DoDisplay,
                         OFFSET String,
                         SIZEOF String
                ENDM

MsgSignon       BYTE 'Shell DLL test program.',CR,LF

MsgCommandLine  BYTE 'Command line was: '
MsgCRLF         BYTE CR,LF

                ALIGN DWORD

hStdOut         DWORD 0                 ;Standard output handle.

    SUBTITLE Main Entry Point code.
    PAGE
    .CODE

; This is a console application.
; It's not a great example of what assembly might achieve against HLL, since
; it hardly does anything but using a few syscall.
; It's only purpose is to demonstrate DLL construction and use using assembly
; language.

Start PROC PUBLIC
    INVOKE GetStdHandle,
        STD_OUTPUT_HANDLE               ;Get handle for screen,
                                        ;(might want to test retcode here...)
    MOV hStdOut,EAX                     ;remember it.

    Display MsgSignon                   ;Display signon message.
    Display MsgCommandLine              ;'Command line was:'

    INVOKE GetCommandLine               ;Get command line pointer in EAX.
    XOR ECX,ECX                         ;Init byte count,
    MOV EBX,EAX                         ;save command line pointer in EBX.
      .WHILE BYTE PTR [EAX] != 0        ;Count command line size.
      INC ECX                           ;Bump byte count,
      INC EAX                           ;bump string pointer,
      .ENDW                             ;till ending Z found.

      .IF ECX != 0                      ;If anything to display,
      INVOKE DoDisplay,                 ;Display message
               EBX,                     ;at [EBX],
               ECX                      ;size in ECX.
      CALL RollUp                       ;rollup one line.
      .ENDIF

    CALL Foo                            ;Call the great Foo DLL function,
    CALL Bar                            ;then the remakable Bar function.

    INVOKE ExitProcess,                 ;We're done:
        0                               ;Null return code.

    RET
Start ENDP


; Roll up one line (display CRLF).

RollUp PROC
    Display MsgCRLF
    RET
RollUp ENDP

; Display a console message.
; Note that in the following, we must use ADDR rather than OFFSET:
; MASM doesn't take OFFSET to LOCALs.

DoDisplay PROC Message:DWORD,
               MessageLength:DWORD

          LOCAL BWritten

    INVOKE WriteFile,                   ;Rollup one line.
        hStdOut,                        ;File handle for screen,
        Message,                        ;address of string,
        MessageLength,                  ;length of string,
        ADDR BWritten,                  ;location to return bytes written,
        0                               ;No overlapped mode.
    MOV EAX,BWritten                    ;Return # of bytes actually written
    RET                                 ;in EAX.
DoDisplay ENDP

    END Start
