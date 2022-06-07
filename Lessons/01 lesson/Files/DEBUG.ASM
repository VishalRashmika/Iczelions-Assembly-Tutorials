    Page 60,190
    TITLE Debugging routines.
; ==========================================================================
; Debugging routines and helpers.
; ==========================================================================
; $Header: /ASMLib32/Debug.asm 3     10/11/97 19:40 Philippe $
; ============================================================================
; $Log: /ASMLib32/Debug.asm $
; 
; 3     10/11/97 19:40 Philippe
; Made some tool routines PUBLIC.
;
; 2     18/09/97 14:49 Philippe
; Added FatalErrorInit routine.
; Caption for FatalError dialog box now set to calling .EXE path name.
;
; 1     4/09/97 4:48 Philippe
; Initial insertion in SourceSafe.
; ============================================================================


; ==========================================================================
; ToDo List:
; - ...
; ==========================================================================

                .586
                .MODEL FLAT,STDCALL

                .NOLISTMACRO
                .NOLIST

UniCode         = 0

                INCLUDE Instr32.mac
                INCLUDE Win32Inc.equ

                INCLUDE Kernel32.equ
                INCLUDE User32.equ
                INCLUDE PEImage.equ

                INCLUDE ASMLib32.inc

                .LIST

    PAGE
; =========================================================================
; FatalError:
; Called to abend the current process.
; The Call instruction is followed by:
; - a length byte (containing the length of the message that follows)
; - an ASCIIZ string, describing the cause for the abend.
; =========================================================================

                .CONST

FatalFormat     BYTE 'FatalError at %1!#x! (offset 0x%3!.8X! in image section ''%4!s!%''):'
                BYTE '%n'
                BYTE '%2!s!.'
                BYTE '%n'
                BYTE 'Now about to attempt debugger call (INT 01)...'
NullByte        BYTE 0

FatalFormatGLE  BYTE 'FatalError at %1!#x! (offset 0x%3!.8X! in image section ''%4!s!''):'
                BYTE '%n'
                BYTE '%2!s!.'
                BYTE '%n'
                BYTE 'GetLastError returned %5!i!: %6!s!'
                BYTE '%n'
                BYTE 'Now about to attempt debugger call (INT 01)...'
                BYTE 0

NoMessage       BYTE '(No FatalError message)'
NullMsg         BYTE 0

    .DATA

FatalBoxTitle   BYTE 40 DUP (0)
                BYTE 0                  ;Terminating byte.

    ALIGN DWORD


; The following are not data definitions, but data masks that apply to the
; stack. This allows the following routines to be fully reentrant.

; Define the various fields on the stack during a FatalError.

LocalData   STRUCT
FatalCall   DWORD ?                     ;%1 Address of fatal error call.
MessageAddr DWORD ?                     ;%2 FatalError message address,
SectRelAddr DWORD ?                     ;%3 Section relative address,
SectNamePtr DWORD ?                     ;%4 section name pointer.
LastError   DWORD ?                     ;%5 GetLastError error code.
lpErrorMsg  DWORD ?                     ;%6 GetLastError Message.
                                        ; <-- Add other FormatMessage parms
                                        ;above this point.
                                        ;Add any further FormatMessage address
                                        ;up there for display in the FatalFormat
                                        ;message. FormatMessage parms start
                                        ;at FatalCall downwards, as directed
                                        ;by the format string.
BufferAddr  DWORD 0                     ;System-returned buffer address,
FatalFlags  BYTE 0                      ;Non-zero if FatalErrStd.
SectName    BYTE 9 DUP (?)              ;Section name.
LocalData   ENDS


; Defines the bits in FatalFlags.

FFErrASM        = 00000000b             ;ASM Proc non-flag (called from HLL)
FFErrStd        = 00000001b             ;Std Proc flag (called from HLL)
FFGetLastError  = 00000010b             ;GetLastError flag (must call GetLastError)


StackSave   STRUCT
FieldEDI    DWORD 0                     ;Result of PUSHAD
FieldESI    DWORD 0
FieldEBP    DWORD 0
FieldESP    DWORD 0
FieldEBX    DWORD 0
FieldEDX    DWORD 0
FieldECX    DWORD 0
FieldEAX    DWORD 0
FieldFlags  DWORD 0                     ;Result of PUSHFD
StackSave   ENDS

StackImage STRUCT
            LocalData <>                ;Local data (see LocalData struct)
            StackSave <>                ;PUSHFD/PUSHAD
FieldRetAd  DWORD 0                     ;"Return" address from FatalError.
StdMessage  DWORD 0                     ;Message Address for FatalErrorStd call.
StackImage ENDS


                .CODE

; ============================================================================
; FatalInit:
; Initialize FatalError routine.
; This allows one to specify the ASCIIZ string that will appear in the
; title of the FatalError box if it ever pops up.
; ============================================================================

FatalErrorInit PROC PUBLIC USES ECX EDI ESI,
                 lpNewString:DWORD

    LEA EDI,FatalBoxTitle
    MOV ESI,lpNewString
    MOV ECX,SIZEOF FatalBoxTitle

      .REPEAT
      MOV AL,[ESI]                      ;Get byte from source,
      INC ESI                           ;bump source cursor.
      DEC ECX                           ;Decrement byte count,
      MOV [EDI],AL                      ;copy byte.
      .BREAK .IF ZERO?                  ;Exit loop if output field full,
      INC EDI                           ;bump output cursor,
      .UNTIL AL==0                      ;exit if end of source.

    INC EDI

    MOV [EDI],BYTE PTR 0                ;Force next character to null.
    RET
FatalErrorInit ENDP


; ============================================================================
; FatalError / FatalErrorGLE:
; Called with message address on stack to abend the current process.
;
; void FatalErrorStd(char *Message);
;
; We use EXTERNDEF C definitions rather PROTOs here because we DO NOT want
; to use the regular stack frame and MASM generated entry sequence here.
; The strange manoeuvers we need to play here preclude it, and we don't want
; MASM to mess with the stack nor with any of our registers either. We have
; to keep this under full control.
; ============================================================================


EXTERNDEF C FatalErrorGLE@4:NEAR
FatalErrorGLE@4 PROC C PUBLIC

    PUSHFD                              ;Save CPU flags,
    PUSHAD                              ;save registers at time of abend.
    SUB ESP,SIZEOF LocalData            ;Allocate local variables,
    MOV EBP,ESP                         ;get EBP => first local var.

    ASSUME EBP:PTR StackImage
                                        ;This is FatalError, not FatalErrorASM,
                                        ;and we need a GetLastError call.
    MOV [EBP].FatalFlags,FFErrStd or FFGetLastError
    JMP FatalErrorCommon
FatalErrorGLE@4 ENDP

;; The following one is obsolete.
;; Embedding data straight inside the code segment is a total performance
;; killer on 486 and upper processors.
;
;EXTERNDEF C FatalErrorASM:NEAR
;FatalErrorASM PROC C
;
;    PUSHFD                              ;Save CPU flags,
;    PUSHAD                              ;save registers at time of abend.
;    SUB ESP,SIZEOF LocalData            ;Allocate local variables,
;    MOV EBP,ESP                         ;get EBP => first local var.
;
;    ASSUME EBP:PTR StackImage
;    MOV [EBP].FatalFlags,FFErrASM       ;This is FatalErrorASM, not FatalError.
;    JMP FatalErrorCommon
;FatalErrorASM ENDP


EXTERNDEF C FatalError@4:NEAR
FatalError@4 PROC C PUBLIC
    PUSHFD                              ;Save CPU flags,
    PUSHAD                              ;save registers at time of abend.
    SUB ESP,SIZEOF LocalData            ;Allocate local variables,
    MOV EBP,ESP                         ;get EBP => first local var.

    ASSUME EBP:PTR StackImage
    MOV [EBP].FatalFlags,FFErrStd       ;This is FatalErr, not FatalErrorASM.
;   JMP FatalErrorCommon                ;Fall thru to common part.

FatalErrorCommon::

      .IF FatalBoxTitle == 0            ;If title not initialized,
      INVOKE GetModuleFileName,         ;stuff module name there.
               NULL,
               OFFSET FatalBoxTitle,
               SIZEOF FatalBoxTitle
      .ENDIF

    MOV EAX,[EBP].FieldRetAd            ;Get 'return' address in EAX (actually
                                        ;points to code-embedded error message).
    MOV EDX,EAX                         ;Get a copy in EDX,
    SUB EDX,5                           ;compute address of fatalerr call,
    MOV [EBP].FatalCall,EDX             ;save on stack for later display.

    LEA EAX,[EBP].SectNamePtr           ;Compute EAX => pointer to SectionName,
    LEA ECX,[EBP].SectName              ;        ECX => Section name storage,
    MOV [EAX],ECX                       ;store SectName address in pointer.

    INVOKE GetSectionData,              ;Get section relative address
             EDX,                       ;for this virtual address,
             NULL,                      ;in this process module,
             ECX                        ;dest address for section name.

    MOV [EBP].SectRelAddr,EAX           ;Save section relative address.
                                        ;Assume FatalErr call supplied
                                        ;no FatalErr message, so
                                        ;set default fatalerror message.
    MOV [EBP].MessageAddr,OFFSET NoMessage

      .IF EAX != -1                     ;If address belongs to our module,
                                        ;(this could trigger an GP otherwise)
      MOV AL,[EBP].FatalFlags           ;Get FatalError flags.
      TEST AL,FFErrStd                  ;Is Std bit set?
        .IF ZERO?                       ;No, assembly call:
        MOV EAX,[EBP].FieldRetAd        ;Get FatalErr message addr back again:
          .IF BYTE PTR [EAX] != 0       ;and if we seem to have a message,
          INC EAX                       ;Bump past message length,
          MOV [EBP].MessageAddr,EAX     ;store actual message address.
          .ENDIF
        .ELSE                           ;FatalErrorStd call.
        MOV EAX,[EBP].StdMessage        ;Get message address from stack.
        MOV [EBP].MessageAddr,EAX
        .ENDIF

;     DEBUG                             ;Debugging aid.

      MOV AL,[EBP].FatalFlags           ;Get FatalError flags,
      TEST AL,FFGetLastError            ;Do we need to call GetLastError?
      LEA EBX,[EBP].lpErrorMsg          ;(get EBX => GLE sysmsg pointer holder)
      MOV EAX,0                         ;Zero EAX without changing flags anyhow,
      MOV [EBX],EAX                     ;and zero GLE system msg pointer too.
        .IF !ZERO?                      ;Yes, need to call GetLastError.
        INVOKE GetLastError             ;Get LastError in EAX,
        MOV [EBP].LastError,EAX         ;and save in stack for FormatMessage,
        MOV ECX,EAX                     ;copy of LastError in ECX.
        .ENDIF
      .ENDIF

    OR EAX,EAX                          ;Did we need to call GetLastError?

      .IF !ZERO?                        ;Yes. Get system message
      INVOKE FormatMessage,             ;message pointer in [EBX] (lpErrorMsg).
             FORMAT_MESSAGE_ALLOCATE_BUFFER or FORMAT_MESSAGE_FROM_SYSTEM,
             0,ECX,0,EBX,0,0
      MOV ECX,OFFSET FatalFormatGLE     ;and point to ad hoc format string.
      .ELSE
      MOV ECX,OFFSET FatalFormat        ;Otherwise, straight FatalErr msg.
      .ENDIF

    LEA EDX,[EBP].FatalCall             ;Get EDX => our argument array,
    LEA EBX,[EBP].lpErrorMsg            ;Get EBX => storage place for
                                        ;FormatMessage allocated buffer.
                                        ;Now format our full FatalError msg
                                        ;(that might embed the GetLastError msg).
    INVOKE FormatMessage,
             FORMAT_MESSAGE_ALLOCATE_BUFFER or FORMAT_MESSAGE_FROM_STRING or\
             FORMAT_MESSAGE_ARGUMENT_ARRAY,
             ECX,0,0,EBX,0,EDX

    MOV EBX,[EBX]                       ;Get EBX => FormatMessage allocated
                                        ;buffer,
    INVOKE MessageBox,                  ;display formatted message.
             0,EBX,ADDR FatalBoxTitle,
             MB_OK or MB_ICONSTOP or MB_APPLMODAL or \
             MB_SETFOREGROUND or MB_TOPMOST or MB_SERVICE_NOTIFICATION

    INVOKE LocalFree,                   ;Free latest FormatMessage allocated buffer.
             EBX

    MOV EAX,[EBP].lpErrorMsg            ;Did we use a formatted GetLastError msg?
      .IF EAX != 0                      ;Yes.
      INVOKE LocalFree,                 ;Then free GetLastError - FormatMessage
               EAX                      ;allocated buffer too.
      .ENDIF

    ADD EBP,SIZEOF LocalData            ;Release stack variables,
    MOV ESP,EBP                         ;and restore stack pointer.
    POPAD                               ;Restore registers,
    POPFD                               ;restore flags like they were when
                                        ;error happened, and then
    DEBUG                               ;enter debugger if any.

    INVOKE ExitProcess,                 ;All done, exit process.
             -1
    RET
FatalError@4 ENDP


; ============================================================================
; Given a virtual address and a module name, return a section name and
; compute the relative offset of the virtual address inside the section.
;
; On entry,
; 1st parm is a virtual address inside the process,
; 2nd parm is a pointer to an ASCIIZ module name (such as "FOO.EXE" or
;   "BAR.DLL"). Set to NULL if the address belongs to the .EXE file used to
;   create the calling process.
; 3rd parm is a pointer to a 9-byte field that will receive the ASCIIZ name
; of the section where the virtual address belongs.
;
; On exit,
;   If module or section not found, the relocated address returned will be
;   set to -1 (0FFFFFFFFh) and the SectionName field will be set to
;   the ASCIIZ string '>Unknown',0
;   Otherwise, EAX will contain the section-relative address of original
;   address and szSectionBuffer will contain the ASCIIZ section name (like
;   '_TEXT',0 or '.rdata',0 or...).
; ============================================================================

                .CONST

Unknown         BYTE '>Unknown',0

                .CODE


GetSectionData PROC PUBLIC USES ECX EDX EDI ESI,
                       Address:DWORD,
                       lpszModuleName:DWORD,
                       lpszSectionBuffer:DWORD

    MOV EAX,lpszModuleName              ;Get EAX => name of module looked for,
    CALL LocateSectionTable             ;Get its section table address.

      .IF EAX != 0                      ;and if found it,
      MOV EDI,EAX                       ;Get EDI => section table,
      ASSUME EDI:PTR SectHeader         ;and tell MASM.

      MOV EAX,Address                   ;Get virtual address to locate (in EAX),
      SUB EAX,EDX                       ;Compute corresponding RVA.

                                        ;ECX still contains number of entries in
                                        ;section table.
      CALL FindRelocAddress             ;Get section where address lives.
                                        ;If we don't find it, EAX will be set
                                        ;to -1 by FindRelocAddress.
        .IF EDI != 0                    ;Found it! EAX = section relative addr,
                                        ;EDI => section entry.
        LEA ESI,[EDI].SectName          ;Get ESI => section name,
        MOV EDI,lpszSectionBuffer       ;and EDI => user destination address.
        MOV ECX,SIZEOF SectHeader.SectName ;Get ECX = max section name,
        CLD                             ;make sure forward copy.
        REP MOVSB                       ;Copy section name.
        MOV BYTE PTR [EDI],0            ;Section names are zero padded, but
        .ENDIF                          ;add zero in case 8-bytes names.

      .ELSE
      MOV EAX,-1                        ;GetModuleAddress returned null addr.
      .ENDIF

      .IF EAX == -1                     ;If address not solved,
      LEA ESI,OFFSET Unknown            ;Assume we won't find section name.
      MOV EDI,lpszSectionBuffer         ;"Unknown".
      MOV ECX,SIZEOF Unknown
      CLD
      REP MOVSB
      .ENDIF

    RET
GetSectionData ENDP

; ============================================================================
; On entry:
;   EAX = RVA to locate,
;   EDI = section table virtual address,
;   ECX = number of entries in section table.
; On exit,
;   EDI == 0 :
;     Address doesn't belong to a section in this module,
;     EAX = -1.
;   EDI != 0 :
;     EDI => section table entry this address belongs to,
;     EAX = relocatable (section relative) address.
; ============================================================================


FindRelocAddress PROC USES EDX

      .REPEAT
      MOV EDX,[EDI].SectRVA             ;Get low boundary RVA of section:
      CMP EAX,EDX                       ;Set carry if lower sect boundary
        .IF !CARRY?                     ;greater than address. If inside,
        ADD EDX,[EDI].SectRawDataSize   ;compute section high boundary RVA:
        CMP EDX,EAX                     ;Address above section?
        .ENDIF                          ;(set carry if so.)
      .BREAK .IF !CARRY?                ;Inside this section, exit loop.
      SUB EDI,-(SIZEOF SectHeader)      ;No, bump to next section table entry
                                        ;and set carry (in case loop is over),
      .UNTILCXZ                         ;loop till all entries done.

      .IF !CARRY?                       ;Target belongs to this section.
      SUB EAX,[EDI].SectRVA             ;Set EAX to section-relative address.
      .ELSE
      MOV EDI,0                         ;Target not found, return EDI == 0
      MOV EAX,-1                        ;and RVA = 0.
      .ENDIF

    RET
FindRelocAddress ENDP

; ============================================================================
; On entry:
;   EAX = pointer to module name,
; On exit:
;   EAX => section table,
;   ECX =  number of sections in module,
;   EDX => module load address.
; ============================================================================


LocateSectionTable PROC USES ESI

    INVOKE GetModuleHandle,             ;Get module load address.
             EAX

      .IF EAX != 0                      ;If module found:
      MOV EDX,EAX                       ;save module address in EDX.
      ASSUME EAX:PTR DOSHeader          ;EAX => load image (DOS header).

      ADD EAX,[EAX].RVAPEHeader         ;Get RVA of PE header,
      ASSUME EAX:PTR ImageFileHeader    ;Now EAX => PE image header.

      XOR ECX,ECX                       ;zero high word of ECX for later.
      MOV ESI,EAX                       ;Get ESI => ImageFileHeader.
      MOV CX,[EAX].IFHNumberOfSections  ;get number of sections in ECX.
      MOVZX EAX,[EAX].IFHOptionalHeaderSize    ;Get optional header size in EAX,
      LEA EAX,[ESI][EAX]+SIZEOF ImageFileHeader;skip regular and optional header,
      .ENDIF                                   ;EAX now points to section table.

    RET
LocateSectionTable ENDP

; ============================================================================
; Get the address of the PE header for a module.
; On entry,
;   1st parm => ASCIIZ module name (NULL if process main module),
; On exit,
;   Return value = PE Header address,
;   (EDX == module load address)
; ============================================================================


GetPEHeader  PROC PUBLIC lpszModuleName:DWORD

    INVOKE GetModuleHandle,             ;Get our load address.
             lpszModuleName

      .IF EAX != 0                      ;Got our load address. and if found:
      MOV EDX,EAX                       ;keep a copy of module load address,
      ASSUME EAX:PTR DOSHeader          ;EAX => load image (DOS header).
      ADD EAX,[EAX].RVAPEHeader         ;Compute address of PE header.
      .ENDIF
    RET
GetPEHeader  ENDP

; ============================================================================
; Get the base address of the code of a module.
; On entry,
;   1st parm => ASCIIZ module name (NULL if process main module),
; On exit,
;   Return value = Code base address.
; ============================================================================


GetCodeBase  PROC PUBLIC lpszModuleName:DWORD

    INVOKE GetPEHeader,                 ;Get EAX == PEHeader:
             lpszModuleName

      .IF EAX !=0                       ;If if found,
      ASSUME EAX:PTR PEHeader           ;tell MASM,
      MOV EAX,[EAX].BaseOfCode          ;get RVA of code address,
      ADD EAX,EDX                       ;Compute virtual address of code.
      .ENDIF
    RET
GetCodeBase  ENDP

; ============================================================================
; Get the base address of the data of a module.
; On entry,
;   1st parm => ASCIIZ module name (NULL if process main module),
; On exit,
;   Return value = Data base address.
; ============================================================================


GetDataBase  PROC PUBLIC lpszModuleName:DWORD

    INVOKE GetPEHeader,                 ;Get EAX == PEHeader:
             lpszModuleName

      .IF EAX !=0                       ;And if found,
      ASSUME EAX:PTR PEHeader           ;tell MASM,
      MOV EAX,[EAX].BaseOfData          ;get RVA of data address,
      ADD EAX,EDX                       ;Compute virtual address of code.
      .ENDIF
    RET
GetDataBase  ENDP


    END
