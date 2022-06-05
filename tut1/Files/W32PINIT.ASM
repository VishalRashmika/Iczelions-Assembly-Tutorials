    Page 60,190
    TITLE W32PInit - Windows 95 prototype - Initialization module.

; ==========================================================================
; ToDo:
; ...
; ==========================================================================


                .586
                .MODEL FLAT,STDCALL

                .NOLISTMACRO
                .NOLIST

UniCode         = 0

                INCLUDE INSTR32.MAC
                INCLUDE WIN32INC.EQU

                INCLUDE WIN32RES.EQU

                INCLUDE KERNEL32.EQU
                INCLUDE USER32.EQU
                INCLUDE COMCTL32.EQU

                INCLUDE W32PROTO.EQU
                .LIST

                PUBLIC WinStart         ; Our entry point.
                PUBLIC hInst            ; This process handle.

                .CODE

WinProc         PROTO NEAR

                PAGE
; =========================================================================
; Constants and data.
; =========================================================================

                .CONST

MyTitle         BYTE 'Prototype Win32 Assembly Language Program',0
Already         BYTE 'A copy of this program is already running',0
ClassName       BYTE 'W32Proto',0

                ALIGN DWORD

                .DATA

; The following fields could possibly be made local (stack based).

Msg             MSG <?>                 ; Win message structure.

NewhWnd         DWORD 0                 ; Handle for our main window.
hInst           DWORD 0                 ; Process instance.
hMenu           DWORD 0                 ; Menu handle.
hAccel          DWORD 0                 ;Accelerator table handle.

WC              WNDCLASS <?>

    PAGE
; =========================================================================
; Main entry point.
; =========================================================================

    .CODE

WinStart PROC PUBLIC

    INVOKE InitCommonControls           ;initialize the common ctrl lib
    INVOKE GetModuleHandle,
               0                        ;get hMod (in eax)
    MOV hInst,EAX                       ;hInstance is same as hmodule


      .REPEAT
      INVOKE FindWindow,
               OFFSET ClassName,        ;Look for windows of our
               0                        ;class, any name: already running?
      .BREAK .IF (EAX == 0)             ;No: No other instance, continue.
                                        ;Yes.
      INVOKE MessageBox,
               0,                       ;No window owner,
               OFFSET Already,          ;Text in msg box,
               OFFSET MyTitle,          ;title of msg box,
               MB_ABORTRETRYIGNORE      ;Ab/Ret/Ignore box.
        .IF (EAX == IDABORT)
        INVOKE ExitProcess,             ;She gives up,
                 0                      ;exit (retcode 0).
        .ENDIF
      .CONTINUE .IF (EAX == IDRETRY)
      .UNTIL (EAX == IDIGNORE)          ;Loop if IDRETRY,
                                        ;else, it's IDIGNORE, fall thru
                                        ;and open second instance.

; =========================================================================
; Initialize the wndclass structure and register our class
; =========================================================================


    MOV WC.style,CS_HREDRAW or CS_VREDRAW or CS_GLOBALCLASS
    MOV WC.lpfnWndProc,OFFSET WinProc
    MOV WC.cbClsExtra,0
    MOV WC.cbWndExtra,0
    MOV EAX,hInst
    MOV WC.hInstance,EAX

    INVOKE LoadIcon,
             EAX,                       ;Application instance,
             IDI_W32PROTO               ;Icon resource identifier.
    MOV WC.hIcon,EAX                    ;Store icon handle.

    INVOKE LoadCursor,
             0,                         ;Use predefined cursor,
             IDC_ARROW                  ;select standard arrow.
    MOV WC.hCursor,EAX                  ;Save cursor handle in Window Class.

    MOV WC.hbrBackground,COLOR_WINDOW+1 ;Set BG color.
    MOV WC.lpszMenuName,0
    MOV WC.lpszClassName,OFFSET ClassName

    INVOKE RegisterClass,
             OFFSET WC                  ;Register our Window Class.


; get our menu resource


                INVOKE LoadMenu,
                         hInst,         ;This process,
                         IDR_MENU1      ;give resource ID.
                MOV hMenu,EAX           ;Remember our menu handle.



; create the main window

    INVOKE CreateWindowEx,
       0,                               ;Extended Window style,
       OFFSET ClassName,OFFSET MyTitle, ;Class name, Window name,
       WS_EX_OVERLAPPEDWINDOW,          ;Window style,
       CW_USEDEFAULT,CW_USEDEFAULT,CW_USEDEFAULT,CW_USEDEFAULT,
       0,hMenu,hInst,0                  ;initial x,y,width,height of window.
                                        ;handle for parent window (none).
                                        ;window menu,
                                        ;instance of this process,
                                        ;lparam (none).
    MOV [NewhWnd],EAX                   ;Remember our window handle.


; Now show the window

    INVOKE ShowWindow,
             NewhWnd,                   ;Handle of just created window,
             SW_SHOWNORMAL              ;show it normally.

    INVOKE UpdateWindow,                ;Force window to
             NewhWnd                    ;paint itself.


; Load the keyboard accelerator resource.

    INVOKE LoadAccelerators,
             hInst,                     ;Process handle.
             IDR_ACCELERATOR1
    MOV hAccel,EAX                      ;Save accelerator handle.


; Finally fall into main message loop.


      .WHILE (TRUE)
      INVOKE GetMessage,
               OFFSET Msg,              ;Adress of Msg structure,
               0,                       ;Window to get msg from,
               0,                       ;Filter min,
               0                        ;filter max.
      .BREAK .IF (EAX == 0)             ;Exit loop if WM_QUIT message.
      INVOKE TranslateAccelerator,
               NewhWnd,                 ;Destination window (here),
               hAccel,                  ;Handle of accelerat.
               OFFSET Msg               ;table, addr of Msg str.
      .CONTINUE .IF (EAX != 0)          ;Non-null return, Msg processed, loop again.
      INVOKE TranslateMessage,          ;Otherwise,
               OFFSET Msg               ;translate keystrokes,
      INVOKE DispatchMessage,           ;dispatch msg to proper winproc, and
               OFFSET Msg               ;loop again.
      .ENDW

    INVOKE ExitProcess,
           Msg.wParam                   ;Pass Quit message code to ExitProc.
        RET

WinStart ENDP

    END WinStart


