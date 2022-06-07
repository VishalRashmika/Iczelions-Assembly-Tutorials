    Page 60,190
    TITLE Title

                .586
                .MODEL FLAT,STDCALL

                .NOLISTMACRO
                .NOLIST

UniCode         = 0
                INCLUDE INSTR32.MAC
                INCLUDE WIN32INC.EQU

                INCLUDE WINRES32.EQU
                INCLUDE WIN32.MAC

                INCLUDE KERNEL32.EQU
                INCLUDE USER32.EQU

;                INCLUDE W32PROTO.EQU
                .LIST

; External references.

;               EXTRN hInst:DWORD       ;Our process instance.

; Forward references (ML can't handle them for INVOKE/PROTOs. Phooey.)

;Proc           PROTO

    PAGE
; ==================================================================
; Global Data section.
; ==================================================================

    .DATA


; ==========================================================================
; Some proc.
; ==========================================================================

    .DATA


    .CODE

    END
