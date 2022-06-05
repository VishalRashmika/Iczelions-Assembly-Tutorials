    Page 60,190
    TITLE W32PToolBar - Windows 95 prototype - Toolbar handling.

                .586
                .MODEL FLAT,STDCALL

                .NOLISTMACRO
                .NOLIST

UniCode         = 0

                INCLUDE INSTR32.MAC

                INCLUDE WIN32INC.EQU
                INCLUDE WIN32RES.EQU
                INCLUDE WIN32.MAC

                INCLUDE COMCTL32.EQU
                INCLUDE USER32.EQU

                INCLUDE W32PROTO.EQU
                .LIST

; External references.

                EXTERN hInst:DWORD

ErrorBox        PROTO lpszErrorMsg:DWORD

                PAGE
; ==================================================================
; Global Data section.
; ==================================================================

    .DATA

hWndTool DWORD 0                        ;Toolbar handle.

    .CODE

; ==========================================================================
; Create the toolbar.
; On exit,
;   EAX undefined,
;   other registers unchanged.
; ==========================================================================

                .CONST

ErrorToolB      BYTE 'Could not create toolbar',0
                ALIGN DWORD

                .DATA

TB              TBBUTTON <0,ID_FILE_NEW,  TBSTATE_ENABLED,TBSTYLE_BUTTON,,0,0>
                TBBUTTON <1,ID_FILE_OPEN, TBSTATE_ENABLED,TBSTYLE_BUTTON,,0,0>
                TBBUTTON <2,ID_FILE_SAVE, TBSTATE_ENABLED,TBSTYLE_BUTTON,,0,0>
                TBBUTTON <0,0,            TBSTATE_ENABLED,TBSTYLE_SEP,   ,0,0>
                TBBUTTON <3,ID_EDIT_CUT,  TBSTATE_ENABLED,TBSTYLE_BUTTON,,0,0>
                TBBUTTON <4,ID_EDIT_COPY, TBSTATE_ENABLED,TBSTYLE_BUTTON,,0,0>
                TBBUTTON <5,ID_EDIT_PASTE,TBSTATE_ENABLED,TBSTYLE_BUTTON,,0,0>
                TBBUTTON <0,0,            TBSTATE_ENABLED,TBSTYLE_SEP,   ,0,0>
                TBBUTTON <6,ID_FILE_PRINT,TBSTATE_ENABLED,TBSTYLE_BUTTON,,0,0>
TBB             TBBUTTON <7,ID_HELP_ABOUT,TBSTATE_ENABLED,TBSTYLE_BUTTON,,0,0>

                ALIGN DWORD

    .CODE

TBCreate PROTO hWnd:DWORD
TBCreate PROC PUBLIC hWnd:DWORD

; now create the toolbar

                                        ;Window handle
                                        ;toolbar style,
                                        ;toolbar id,
                                        ;number of bitmaps
                                        ;our process handle,
                                        ;resource id
                                        ;address of button structures,
                                        ;number of buttons (includes sep.)
                                        ;button width
                                        ;button height
                                        ;bitmap width
    INVOKE CreateToolbarEx,             ;bitmap height
             hWnd,                       ;button structure size.
             WS_CHILD or WS_BORDER or WS_VISIBLE or TBSTYLE_TOOLTIPS\
              or CCS_ADJUSTABLE,
             IDR_TOOLBAR,8,hInst,IDR_TOOLBAR,OFFSET TB,
             10,16,15,16,15,(SIZEOF TBB)

    MOV hWndTool,EAX                    ;save the handle to toolbar

      .IF EAX==0                        ;CreateToolbarEx failed?
      INVOKE ErrorBox,
               OFFSET ErrorToolB        ;Give message.
      SUB EAX,EAX                       ;Return null handle.
      .ENDIF

    RET

TBCreate ENDP


; ==========================================================================
; Received a WM_SIZE message.
; Resize the window.
; ==========================================================================


TBResize PROC PUBLIC

      .IF hWndTool != 0                 ;If there is a valid toolbar:
        INVOKE SendMessage,             ;tell the toolbar to size itself
                 hWndTool,
                 TB_AUTOSIZE,
                 0,
                 0
      .ENDIF
    RET

TBResize ENDP



; ==========================================================================
; Received a Notify message.
; The toolbar is asking for a tooltip message.
; We declared the help strings in the .RC file with the same ID as the menu
; commands we used for both the menu and the toolbar command messages,
; because the idFrom that Win gives us is actually the message ID that the
; tool button is associated to.
; ==========================================================================

               .CODE


WinProc_WM_NOTIFY PROC PUBLIC,
                    hWnd:DWORD,
                    wMsg:DWORD,
                    wParam:DWORD,
                    lParam:DWORD

    MOV EBX,lParam                           ;Get pointer to NMHDR:
      .IF ([EBX].NMHDR.code == TTN_NEEDTEXT) ;is Notification a TTN_NEEDTEXT
                                             ;query?
      MOV EAX,hInst                     ;Yes. get our proc instance,
      MOV [EBX].TOOLTIPTEXT.hInst,EAX   ;get icon from our own instance.
      MOV EAX,[EBX].NMHDR.idFrom        ;Get id of command requiring help,
      MOV [EBX].TOOLTIPTEXT.lpszText,EAX;stuff in lpszText so Win displays it.
      SUB EAX,EAX                       ;No error.

      .ELSE
      INVOKE DefWindowProc,             ;Some other notify, pass to default.
               hWnd,
               wMsg,
               wParam,
               lParam
      .ENDIF
    RET

    UnusedParm hWnd
    UnusedParm wMsg
    UnusedParm wParam

WinProc_WM_NOTIFY ENDP

    END
