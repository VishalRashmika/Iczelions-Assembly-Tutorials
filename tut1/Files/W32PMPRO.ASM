   Page 60,190
    TITLE W32MProcs - Windows 95 prototype - Message Procedures.
               .586
                .MODEL FLAT,STDCALL

                .NOLISTMACRO
                .NOLIST

UniCode         = 0

                INCLUDE INSTR32.MAC
                INCLUDE WIN32INC.EQU

                INCLUDE WIN32.MAC

                INCLUDE COMDLG32.EQU
                INCLUDE GDI32.EQU
                INCLUDE KERNEL32.EQU
                INCLUDE USER32.EQU

                INCLUDE WINMM.EQU

                INCLUDE W32PROTO.EQU
                .LIST

                EXTERN hInst:DWORD

                .CODE



CvDec                   PROTO                   ;Binary to decimal conversion routine.
DisplayLastError        PROTO                   ;GetLastError & Display it.
ErrorBox                PROTO lpszErrorMsg:DWORD
SBCreate                PROTO hWnd:DWORD        ;Status bar create routine.
SBDisplay               PROTO uSBPart:DWORD,lpszMsg:DWORD
SBResize                PROTO lParam:DWORD      ;Status bar resize routine.
TBCreate                PROTO hWnd:DWORD        ;Toolbar create routine.
TBResize                PROTO                   ;Toolbar resize routine.
TMCreate                PROTO hWnd:DWORD        ;Timer create routine.
TMKill                  PROTO hWnd:DWORD        ;Timer kill routine.

                PAGE
; ==================================================================
; Global Data section.
; ==================================================================

                .DATA


                PAGE
                .CODE
; ==========================================================================
; Main WinProc Message processing procedures.
; Must return with EAX = Error code.
; ==========================================================================


; ==========================================================================
; We received a WM_Create message.
; Play some sound.
; ==========================================================================

                .CONST

szMeow       BYTE 'IDR_MEOW',0

                .CODE

WinProc_WM_CREATE PROC PUBLIC,
                    hWnd:DWORD,
                    wMsg:DWORD,
                    wParam:DWORD,
                    lParam:DWORD

; Make some noise.

    INVOKE PlaySound,
             IDR_MEOW,
             hInst,
             SND_RESOURCE or SND_ASYNC

    MOV ECX,hWnd                        ;Get our Win handle
    MOV EDX,hInst                       ;and our instance handle,
    INVOKE TBCreate,                    ;Create toolbar,
             hWnd                       ;main window handle.
                                        ;(EAX == 0 if failed,
                                        ; TB handle otherwise)
    INVOKE SBCreate,                    ;Create status bar.
             hWnd                       ;main window handle.
                                        ;(EAX == 0 if failed,
                                        ; SB handle otherwise)
    INVOKE TMCreate,                    ;Create and fire timer.
             hWnd
                                        ;(EAX == 0 if failed,
                                        ; timer handle otherwise)

    XOR EAX,EAX
    RET

    UnusedParm wMsg
    UnusedParm wParam
    UnusedParm lParam

WinProc_WM_CREATE ENDP



; ==========================================================================
; Received a paint message.
; Repaint the main window.
; ==========================================================================

    .CONST

szHello BYTE 'Hi, Windows95!',0

    .DATA

Rect RECT <?>
PS   PAINTSTRUCT <?>


    .CODE

WinProc_WM_PAINT PROC PUBLIC,
                   hWnd:DWORD,
                   wMsg:DWORD,
                   wParam:DWORD,
                   lParam:DWORD

    LOCAL TheDC:DWORD

    INVOKE BeginPaint,
             hWnd,
             OFFSET PS
    MOV TheDC,EAX                       ;Remember Device Context.

    INVOKE GetWindowRect,               ;get size of window
             hWnd,                      ;Our window handle,
             OFFSET Rect                ;rectangle structure.

    INVOKE DrawText,
             TheDC,
             OFFSET szHello,
             -1,
             OFFSET Rect,
             DT_SINGLELINE or DT_CENTER or DT_VCENTER

    INVOKE EndPaint,
             hWnd,
             OFFSET PS

    XOR EAX,EAX
    RET

    UnusedParm wMsg
    UnusedParm wParam
    UnusedParm lParam

WinProc_WM_PAINT ENDP



; ==========================================================================
; Received a WM_SIZE message.
; Resize the window.
; ==========================================================================


WinProc_WM_SIZE PROC PUBLIC,
                  hWnd:DWORD,
                  wMsg:DWORD,
                  wParam:DWORD,
                  lParam:DWORD


    INVOKE TBResize                     ;Resize the toolbar,
    INVOKE SBResize,                    ;resize the status bar.
             lParam

    XOR EAX,EAX
    RET

    UnusedParm hWnd
    UnusedParm wMsg
    UnusedParm wParam
    UnusedParm lParam

WinProc_WM_SIZE ENDP


; ==========================================================================
; Received a mouse click.
; Make some pseudo-random noise.
; ==========================================================================


WinProc_WM_LBUTTONDOWN PROC PUBLIC,
                         hWnd:DWORD,
                         wMsg:DWORD,
                         wParam:DWORD,
                         lParam:DWORD

    MOV EAX,OFFSET RightClick           ;Select table origin for RClick,
    CALL MakeSomeNoise                  ;Go make noise below.
    RET

    UnusedParm hWnd
    UnusedParm wMsg
    UnusedParm wParam
    UnusedParm lParam

WinProc_WM_LBUTTONDOWN ENDP


WinProc_WM_RBUTTONDOWN PROC PUBLIC,
                         hWnd:DWORD,
                         wMsg:DWORD,
                         wParam:DWORD,
                         lParam:DWORD

    MOV EAX,OFFSET LeftClick            ;Select table origin for LClick.
    CALL MakeSomeNoise                  ;Go make noise below.
    RET

    UnusedParm hWnd
    UnusedParm wMsg
    UnusedParm wParam
    UnusedParm lParam

WinProc_WM_RBUTTONDOWN ENDP

    .CONST

RightClick      DWORD MB_ICONASTERISK      ;SystemAsterisk
LeftClick       DWORD MB_ICONEXCLAMATION   ;SystemExclamation
                DWORD MB_ICONHAND          ;SystemHand
                DWORD MB_ICONQUESTION      ;SystemQuestion
                DWORD MB_OK                ;SystemDefault

    .CODE

MakeSomeNoise PROC
    SAVE EAX                            ;Save table origin.
    INVOKE GetTickCount                 ;Get current tick count,
    RESTORE EDX                         ;EDX = noise table origin,
    AND EAX,011b                        ;turn ticks into 0-3 index,
    ADD EAX,EDX                         ;use as random index into table,
    MOV EAX,[EAX]                       ;get noise,
    INVOKE MessageBeep,                 ;make noise.
             EAX
    RET
MakeSomeNoise ENDP




; ==========================================================================
; Received a MENUSELECT message.
; The user pointer moved to a menu item.
; ==========================================================================

    .DATA

szBuffer BYTE 80 DUP(0)

    .CODE

WinProc_WM_MENUSELECT PROC PUBLIC,
                        hWnd:DWORD,
                        wMsg:DWORD,
                        wParam:DWORD,
                        lParam:DWORD


      .IF (WORD PTR wParam+2 == 0FFFFh) && (lParam == 0)
                                        ;If the user closed a menu,
      MOV BYTE PTR szBuffer,0           ;we didn't process this message.
      MOV EAX,1                         ;so we must return NZ.
      .ELSE
      XOR EAX,EAX
      MOV AX,WORD PTR wParam
      INVOKE LoadString,                ;load the tip from stringtable
               hInst,                   ;instance,
               EAX,                     ;menu item message,
               OFFSET szBuffer,         ;buffer to load string into,
               (SIZEOF szBuffer)-1      ;size of our buffer.
      .ENDIF

      .IF EAX != 0                      ;If LoadString worked,
      INVOKE SBDisplay,                 ;display menu help.
               SBPART_MESSAGE,
               OFFSET szBuffer
      XOR EAX,EAX
      .ENDIF

    RET

    UnusedParm hWnd
    UnusedParm wMsg

WinProc_WM_MENUSELECT ENDP



; ==========================================================================
; Received a Destroy message.
; Kill the timer, post a Quit message.
; ==========================================================================



WinProc_WM_DESTROY PROC PUBLIC,
                     hWnd:DWORD,
                     wMsg:DWORD,
                     wParam:DWORD,
                     lParam:DWORD

    INVOKE TMKill,                      ;Kill our timer,
             hWnd

    INVOKE PostQuitMessage,             ;Quit
             0
    XOR EAX,EAX
    RET

    UnusedParm hWnd
    UnusedParm wMsg
    UnusedParm wParam
    UnusedParm lParam

WinProc_WM_DESTROY ENDP


; ==========================================================================
; Main WinProc Command Message processing procedures.
; Must return with EAX = Error code.
; ==========================================================================


; ==========================================================================
; Received an ID_FILE_EXIT menu command.
; Same code as WM_DESTROY.
; ==========================================================================


WinProcCMD_ID_FILE_EXIT PROC PUBLIC,
                          hWnd:DWORD,
                          wMsg:DWORD,
                          wParam:DWORD,
                          lParam:DWORD

    INVOKE PostQuitMessage,             ;quit
             0
    XOR EAX,EAX
    RET

    UnusedParm hWnd
    UnusedParm wMsg
    UnusedParm wParam
    UnusedParm lParam

WinProcCMD_ID_FILE_EXIT ENDP



; ==========================================================================
; Received an ID_HELP_CONTENT menu command.
; Invoke external help system.
; ==========================================================================

    .CONST

szHelp BYTE 'W32Proto.hlp',0

    .CODE

WinProcCMD_ID_HELP_CONTENT PROC PUBLIC,
                             hWnd:DWORD,
                             wMsg:DWORD,
                             wParam:DWORD,
                             lParam:DWORD

    INVOKE WinHelp,
              hWnd,                     ;handle of window requiring help,
              OFFSET szHelp,            ;addess of dir/path string,
              HELP_CONTENTS,            ;type of help,
              0                         ;additional data.
    XOR EAX,EAX
    RET

    UnusedParm wMsg
    UnusedParm wParam
    UnusedParm lParam

WinProcCMD_ID_HELP_CONTENT ENDP



; ==========================================================================
; Received an ID_FILE_OPEN menu command.
; Invoke FileOpen dialog.
; Call the getopenfilename common dialog to retrieve the path in szfile
; ==========================================================================

    .CONST

szOFTitle  BYTE 'Open File',
                 0
szOFFilter BYTE 'Text Files (*.txt)',0,'*.txt',0,
                 0
szOFExt    BYTE '*.txt',
                 0

    .DATA

    ALIGN DWORD

OFNx        OPENFILENAME <?>
OFSx        OFSTRUCT <?>
hOFFile     DWORD 0

szOFFile    BYTE MAX_PATH DUP(0)
OFBytesRead DWORD 0
OFMsgBuff   BYTE 'Test Win32 Assembler Program',
               0,
               64 DUP(?)

    .CODE


WinProcCMD_ID_FILE_OPEN PROC PUBLIC,
                          hWnd:DWORD,
                          wMsg:DWORD,
                          wParam:DWORD,
                          lParam:DWORD

    MOV ECX,SIZEOF OFNx
    MOV EDI,OFFSET OFNx                 ;Fill in the OFN structure.
    XOR EAX,EAX
    REP STOSB
    MOV OFNx.lStructSize,SIZEOF OFNx
    MOV EAX,hWnd                        ;Window handle
    MOV OFNx.hwndOwner,EAX
    MOV EAX,hInst                       ;Process instance
    MOV OFNx.hInstance,EAX
    MOV OFNx.lpstrFilter,OFFSET szOFFilter
    MOV OFNx.lpstrFile,OFFSET szOFFile
    MOV OFNx.nMaxFile,LENGTH szOFFile
    MOV OFNx.lpstrInitialDir,0
    MOV OFNx.lpstrTitle,OFFSET szOFTitle
    MOV OFNx.lpstrDefExt,OFFSET szOFExt
    MOV OFNx.Flags,OFN_PATHMUSTEXIST or OFN_FILEMUSTEXIST
    INVOKE GetOpenFileName,
             OFFSET OFNx                ;OpenFileName structure.

      .IF EAX != 0                      ;If no error, no cancel:
                                        ; Open the file and read in a some data.
                                        ; OpenFile is 16 bits compat, should use
                                        ; CreateFile, nowadays...
      INVOKE OpenFile,
               OFFSET szOFFile,         ;Pointer to where filename now is.
               OFFSET OFSx,             ;Receive OFSTRUCT open info there.
               OF_READ                  ;Open file as Read Only.
        .IF EAX != -1                   ;If Open happened properly,
        MOV [hOFFile],EAX               ;remember file handle.
        INVOKE ReadFile,
                 EAX,                   ;File handle,
                 OFFSET OFMsgBuff,      ;buffer to receive data,
                 (SIZEOF OFMsgBuff)-1,  ;number of bytes to read,
                 OFFSET OFBytesRead,    ;Bytes actually read
                 0                      ;No overlapped structure.
          .IF EAX != 0                  ;If good read,
          MOV EDI,OFBytesRead           ;force a terminating 0.
          MOV BYTE PTR OFMsgBuff[EDI],0
          INVOKE CloseHandle,           ;Now close file.
                   hOFFile
          MOV AL,CR                     ;Look for first carriage return.
          MOV ECX,OFBytesRead
          LEA EDI,OFMsgBuff
          CLD
          REPNZ SCASB
            .IF !ZERO?                  ;If found a CR, overwrite with
            MOV BYTE PTR [EDI-1],0      ;terminating zero
            .ENDIF                      ;Endif "found a CR"
          .ENDIF                        ;Endif "if good read"
        .ELSE                           ;Open didn't work properly.
        INVOKE DisplayLastError         ;See and say why.
        .ENDIF                          ;Endif "if OpenFile happened properly"
      .ENDIF                            ;If "no Cancel from OpenDialog"
    XOR EAX,EAX
    RET

    UnusedParm wMsg
    UnusedParm wParam
    UnusedParm lParam

WinProcCMD_ID_FILE_OPEN ENDP


; ==========================================================================
; Invoke FileSave dialog.
; Call the getopenfilename common dialog to retrieve the path in szfile
; ==========================================================================

    .CONST

szOFSvTitle  BYTE 'Save File',0
szOFSvFilter BYTE 'Text Files (*.txt)',0,'*.txt',0,
                0
szOFSvExt    BYTE '*.txt',0


    .DATA

szOFSvFile      BYTE MAX_PATH DUP(0)

    ALIGN DWORD

OFNSave         OPENFILENAME <?>


    .CODE

WinProcCMD_ID_FILE_SAVE PROC PUBLIC,
                          hWnd:DWORD,
                          wMsg:DWORD,
                          wParam:DWORD,
                          lParam:DWORD


                                        ;First, setup OFN struct.
    MOV ECX,SIZEOF OFNSave              ;Zero whole structure first.
    MOV EDI,OFFSET OFNSave
    XOR EAX,EAX
    REP STOSB
    MOV OFNSave.lStructSize,SIZEOF OFNSave
    MOV EAX,hWnd
    MOV OFNSave.hwndOwner,EAX
    MOV EAX,hInst                       ;Process instance
    MOV OFNSave.hInstance,EAX
    MOV OFNSave.lpstrFilter,OFFSET szOFSvFilter
    MOV OFNSave.lpstrFile,OFFSET szOFSvFile
    MOV OFNSave.nMaxFile,LENGTH szOFSvFile
    MOV OFNSave.lpstrInitialDir,0
    MOV OFNSave.lpstrTitle,OFFSET szOFSvTitle
    MOV OFNSave.lpstrDefExt,OFFSET szOFSvExt
    MOV OFNSave.Flags,OFN_PATHMUSTEXIST

    INVOKE GetSaveFileName,
             OFFSET OFNSave

    XOR EAX,EAX
    RET

    UnusedParm wMsg
    UnusedParm wParam
    UnusedParm lParam

WinProcCMD_ID_FILE_SAVE ENDP



WinProcCMD_ID_FILE_SAVEAS PROC PUBLIC,
                            hWnd:DWORD,
                            wMsg:DWORD,
                            wParam:DWORD,
                            lParam:DWORD

    INVOKE WinProcCMD_ID_FILE_SAVE,
             hWnd,
             wMsg,
             wParam,
             lParam
    RET

    UnusedParm hWnd
    UnusedParm wMsg
    UnusedParm wParam
    UnusedParm lParam

WinProcCMD_ID_FILE_SAVEAS ENDP


; ==========================================================================
; Call the printdlg common dialog function and print some garbage.
; ==========================================================================

    .CONST

PrintTitle BYTE 'W32Proto Assembly Language Generic Program',
                    0
PrintMsg   BYTE 'This is a silly dummy message.'

    .DATA

    ALIGN DWORD

PD   PRINTDLG <?>
DocI DOCINFO  <?>

    .CODE

WinProcCMD_ID_FILE_PRINT PROC PUBLIC,
                           hWnd:DWORD,
                           wMsg:DWORD,
                           wParam:DWORD,
                           lParam:DWORD


    LOCAL Y:DWORD

    MOV ECX,SIZEOF PD                   ;Setup print dialog structure.
    MOV EDI,OFFSET PD                   ;First, zero it.
    XOR EAX,EAX
    REP STOSB

    MOV PD.lStructSize,SIZEOF PD        ;Then init its fields.
    MOV EAX,hWnd
    MOV PD.hwndOwner,EAX
    MOV EAX,hInst                       ;Process instance
    MOV PD.hInstance,EAX
    MOV PD.Flags,PD_RETURNDC or PD_USEDEVMODECOPIES or PD_COLLATE\
                   or PD_NOSELECTION or PD_PRINTSETUP
    INVOKE PrintDlg,
             OFFSET PD                  ;Popup Print dialog.

      .IF EAX == TRUE                   ;If no error,
      MOV DocI.cbSize,SIZEOF DocI
      MOV DocI.lpszDocName,OFFSET PrintTitle
      MOV DocI.lpszOutput,0
      MOV DocI.fwType,0
      INVOKE StartDoc,                  ;Start print job.
               PD.hDC,
               OFFSET DocI
        .IF EAX > 0                     ;If succesful,
        INVOKE StartPage,               ;Prepare printer driver.
                 PD.hDC
          .IF EAX > 0                   ;If OK,

          MOV Y,50                      ;Init loop count / y position.

            .REPEAT
            INVOKE TextOut,             ;Print a line of text
                     PD.hDC,            ;DC handle,
                     40,                ;x,
                     Y,                 ;y of starting position.
                     OFFSET PrintMsg,   ;String to print,
                     SIZEOF PrintMsg    ;length of string.
            ADD Y,50                    ;Next "line".
            .UNTIL Y > 50 * 50

          INVOKE EndPage,
                   PD.hDC
          .ENDIF

        INVOKE EndDoc,
                 PD.hDC
        .ENDIF

      INVOKE DeleteDC,
               PD.hDC
      .ENDIF

    XOR EAX,EAX
    RET

    UnusedParm wMsg
    UnusedParm wParam
    UnusedParm lParam

WinProcCMD_ID_FILE_PRINT ENDP

    END
