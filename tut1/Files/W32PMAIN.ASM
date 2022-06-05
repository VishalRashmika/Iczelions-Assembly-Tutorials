    Page 60,190
    TITLE W32PMain - Windows 95 prototype - MainProc module.

                .586
                .MODEL FLAT,STDCALL

                .NOLISTMACRO
                .NOLIST

UniCode         = 0

                INCLUDE INSTR32.MAC
                INCLUDE WIN32INC.EQU

                INCLUDE USER32.EQU
                INCLUDE WIN32RES.EQU
                INCLUDE WIN32.MAC

                INCLUDE W32PROTO.EQU

                .LIST


                .CODE

WinProc         PROTO

                PAGE
; ==================================================================
; Data section.
; ==================================================================




;===================================================================
; WndProc
;===================================================================

; The core of the Winproc is reduced to an absolute minimum, kinda
; unorthodox but carefully thought of and shouldn't be changed:

; - It doesn't save any register nor creates a stackframe upon entry.
;   Each of the message processing proc is responsible for doing so.
;   As a result, the WndProc code can't alter any register either (but EAX).
;   The benefits of this are:
;   - Everything looks like if the message processing code got called
;     directly from the Windows code, minimizing overhead. The overhead
;     in the WinProc message dispatcher is absolutely minimal, too.
;   - Each message processor is a proc, that can be implemented in
;     any external module, can declares its own local parms, save the
;     registers it needs to, etc...
;   - The structure of the win program becomes more apparent and clearer
;     to follow
;   The only drawback is that the entry/exit code is duplicated in each
;   message processing proc. Not necessarily duplicated tho, since each
;   message processor might have its own specific requirements.
;   This brings a slight code size penalty, but no speed penalty (the
;   entry/exit sequence is executed once per message anyway).
; - It doesn't call DefWindowProc, but jumps to it, passing the parm and
;   return address it got from its caller.
;   This saves some overhead, and provides tail recursion elimination:
;   This way, when DefWinProc calls the WinProc (which occurs quite often),
;   we don't nest the stack yet another level.


; ==========================================================================
; WinProc main dispatcher.
; ==========================================================================


    .CODE

WinProc PROC PUBLIC                     ;No entry sequence generated here!
    MOV EAX,ESPwMsg                     ;Get wMsg parm, and dispatch it.

    CALLBACK WinProc
    MESSAGE WM_MOUSEMOVE
    MESSAGE WM_PAINT
    MESSAGE WM_SIZE
    MESSAGE WM_CREATE
    MESSAGE WM_DESTROY
    MESSAGE WM_NOTIFY
    MESSAGE WM_TIMER
    MESSAGE WM_RBUTTONDOWN
    MESSAGE WM_LBUTTONDOWN
    MESSAGE WM_MENUSELECT
    MSGCHAIN WM_COMMAND,WinProcCMD
    CALLBACKDEFAULT DefWindowProc

WinProc ENDP



; ==========================================================================
; WinProc Command dispatcher.
; ==========================================================================

WinProcCMD PROC PUBLIC
    XOR EAX,EAX                         ;Prepare for DWORD extension,
    MOV AX,WORD PTR ESPwParam           ;get wParam in EAX.

    CALLBACK WinProcCMD
    MESSAGE ID_FILE_EXIT
    MESSAGE ID_FILE_OPEN
    MESSAGE ID_FILE_SAVE
    MESSAGE ID_FILE_SAVEAS
    MESSAGE ID_FILE_PRINT
    MESSAGE ID_OPTIONS_TITLE
    MESSAGE ID_HELP_ABOUT
    MESSAGE ID_HELP_CONTENT
    CALLBACKDEFAULT DefWindowProc

WinProcCMD ENDP

    END
