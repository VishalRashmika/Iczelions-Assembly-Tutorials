    Page 60,190
    TITLE ASM Skeleton - Module title here.
; ==========================================================================
; General module purpose and comments.
; ==========================================================================


; ==========================================================================
; ToDo List:
; ==========================================================================


                .586
                .MODEL FLAT,STDCALL

                .NOLISTMACRO
                .NOLIST

UniCode         = 0

                INCLUDE INSTR32.MAC
                INCLUDE WIN32INC.EQU

                INCLUDE KERNEL32.EQU

                .LIST

                .CODE


    PAGE
; =========================================================================
; Global Constants and data.
; =========================================================================

    .CONST

    .DATA

    PAGE
; =========================================================================
; First procedure.
; =========================================================================

    .CONST

MsgDone         BYTE 'All done. Press <Enter> to continue.',
                     CR,LF

%MsgSignon      BYTE 'Signon message - ',
                     "&@Date &@Time",   ;Generates assembly date/time here.
                      CR,LF,LF

    .DATA


    .CODE

Skel PROC
    RET
Skel ENDP

    END
