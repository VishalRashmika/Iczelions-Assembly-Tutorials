.386
.model flat, stdcall
include \masm32\include\windows.inc
include \masm32\include\user32.inc
include \masm32\include\kernel32.inc
include \masm32\include\gdi32.inc
includelib \masm32\lib\user32.lib
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\gdi32.lib
.data
BitmapName db "MySplashBMP",0
ClassName db "SplashWndClass",0
hBitMap dd 0
TimerID dd 0

.data
hInstance dd ?

.code

DllEntry proc hInst:DWORD, reason:DWORD, reserved1:DWORD
   .if reason==DLL_PROCESS_ATTACH  ; When the dll is loaded
      push hInst
      pop hInstance 
      call ShowBitMap      
   .endif
   mov eax,TRUE
   ret
DllEntry Endp
ShowBitMap proc
        LOCAL wc:WNDCLASSEX
        LOCAL msg:MSG
        LOCAL hwnd:HWND
        mov   wc.cbSize,SIZEOF WNDCLASSEX
        mov   wc.style, CS_HREDRAW or CS_VREDRAW
        mov   wc.lpfnWndProc, OFFSET WndProc
        mov   wc.cbClsExtra,NULL
        mov   wc.cbWndExtra,NULL
        push  hInstance
        pop   wc.hInstance
        mov   wc.hbrBackground,COLOR_WINDOW+1
        mov   wc.lpszMenuName,NULL
        mov   wc.lpszClassName,OFFSET ClassName
        invoke LoadIcon,NULL,IDI_APPLICATION
        mov   wc.hIcon,eax
        mov   wc.hIconSm,0
        invoke LoadCursor,NULL,IDC_ARROW
        mov   wc.hCursor,eax
        invoke RegisterClassEx, addr wc
        INVOKE CreateWindowEx,NULL,ADDR ClassName,NULL,\
           WS_POPUP,CW_USEDEFAULT,\
           CW_USEDEFAULT,250,250,NULL,NULL,\
           hInstance,NULL
        mov   hwnd,eax
        INVOKE ShowWindow, hwnd,SW_SHOWNORMAL
        .WHILE TRUE
                INVOKE GetMessage, ADDR msg,NULL,0,0
                .BREAK .IF (!eax)
                INVOKE TranslateMessage, ADDR msg
                INVOKE DispatchMessage, ADDR msg
        .ENDW
        mov     eax,msg.wParam        
        ret
ShowBitMap endp
WndProc proc hWnd:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD
        LOCAL ps:PAINTSTRUCT
        LOCAL hdc:HDC
        LOCAL hMemoryDC:HDC
        LOCAL hOldBmp:DWORD
        LOCAL bitmap:BITMAP
        LOCAL DlgHeight:DWORD
        LOCAL DlgWidth:DWORD
        LOCAL DlgRect:RECT
        LOCAL DesktopRect:RECT
        
        .if uMsg==WM_DESTROY
                .if hBitMap!=0
                        invoke DeleteObject,hBitMap
                .endif
                invoke PostQuitMessage,NULL
        .elseif uMsg==WM_CREATE
                invoke GetWindowRect,hWnd,addr DlgRect                   
                invoke GetDesktopWindow
                mov ecx,eax
                invoke GetWindowRect,ecx,addr DesktopRect
                push  0                              ;Part of the later call to MoveWindow (no repaint)
                mov  eax,DlgRect.bottom              ;Get the bottom of our dialogs window
                sub  eax,DlgRect.top                 ;subtract the y value at the top of our window
                mov  DlgHeight,eax                   ;And store it as the dialog's height
                push eax                             ;Push it for the call to MoveWindow
                mov  eax,DlgRect.right               ;The X coordinate of the right side of our dialog
                sub  eax,DlgRect.left                ;minus that of the left side
                mov  DlgWidth,eax                    ;gives us the width
                push eax                             ;Push it for the call to MoveWindow
                mov  eax,DesktopRect.bottom          ;Get the bottom of the desktop window
                sub  eax,DlgHeight                   ;Subtract the height of our dialog
                shr  eax,1                           ;and divide by 2...this gives the middle of the screen
                push eax                             ;Push for the movewindow call
                mov  eax,DesktopRect.right           ;Get the right side of the desktop
                sub  eax,DlgWidth                    ;Minus the width of our dialog
                shr  eax,1                           ;Divide by 2
                push eax                             ;Push it
                push hWnd                         ;Push the window handle
                call MoveWindow                      ;Move the window                
                invoke LoadBitmap,hInstance,addr BitmapName
                mov hBitMap,eax
                invoke SetTimer,hWnd,1,2000,NULL
                mov TimerID,eax
        .elseif uMsg==WM_TIMER
                invoke SendMessage,hWnd,WM_LBUTTONDOWN,NULL,NULL
                invoke KillTimer,hWnd,TimerID
        .elseif uMsg==WM_PAINT
                invoke BeginPaint,hWnd,addr ps
                mov hdc,eax
                invoke CreateCompatibleDC,hdc
                mov hMemoryDC,eax
                invoke SelectObject,eax,hBitMap
                mov hOldBmp,eax
                invoke GetObject,hBitMap,sizeof BITMAP,addr bitmap
                invoke StretchBlt,hdc,0,0,250,250,\
                        hMemoryDC,0,0,bitmap.bmWidth,bitmap.bmHeight,SRCCOPY
                invoke SelectObject,hMemoryDC,hOldBmp
                invoke DeleteDC,hMemoryDC
                invoke EndPaint,hWnd,addr ps
        .elseif uMsg==WM_LBUTTONDOWN               
                invoke DestroyWindow,hWnd
        .else
                invoke DefWindowProc,hWnd,uMsg,wParam,lParam
                ret
        .endif
        xor eax,eax
        ret
WndProc endp

End DllEntry
