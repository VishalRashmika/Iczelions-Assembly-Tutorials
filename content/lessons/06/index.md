+++
authors = [""]
title = "6. Keyboard Input"
description = ""
date = 2024-07-09
[taxonomies]
tags = ["masm32"]
[extra]
toc = false
+++



We will learn how a Windows program receives keyboard input.

Download the example here.
Theory:
Since normally there's only one keyboard in each PC, all running Windows programs must share it between them. Windows is responsible for sending the key strokes to the window which has the input focus.
Although there may be several windows on the screen, only one of them has the input focus. The window which has input focus is the only one which can receive key strokes. You can differentiate the window which has input focus from other windows by looking at the title bar. The title bar of the window which has input focus is highlighted.
Actually, there are two main types of keyboard messages, depending on your view of the keyboard. You can view a keyboard as a collection of keys. In this case, if you press a key, Windows sends a WM_KEYDOWN message to the window which has input focus, notifying that a key is pressed. When you release the key, Windows sends a WM_KEYUP message. You treat a key as a button. Another way to look at the keyboard is that it's a character input device. When you press "a" key, Windows sends a WM_CHAR message to the window which has input focus, telling it that the user sends "a" character to it. In fact, Windows sends WM_KEYDOWN and WM_KEYUP messages to the window which has input focus and those messages will be translated to WM_CHAR messages by TranslateMessage call. The window procedure may decide to process all three messages or only the messages it's interested in. Most of the time, you can ignore WM_KEYDOWN and WM_KEYUP since TranslateMessage function call in the message loop translate WM_KEYDOWN and WM_KEYUP messages to WM_CHAR messages. We will focus on WM_CHAR in this tutorial.
 
Example:
.386
.model flat,stdcall
option casemap:none

WinMain proto :DWORD,:DWORD,:DWORD,:DWORD

include \masm32\include\windows.inc
include \masm32\include\user32.inc
include \masm32\include\kernel32.inc
include \masm32\include\gdi32.inc
includelib \masm32\lib\user32.lib
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\gdi32.lib

.data
ClassName db "SimpleWinClass",0
AppName  db "Our First Window",0
char WPARAM 20h                         ; the character the program receives from keyboard

.data?
hInstance HINSTANCE ?
CommandLine LPSTR ?

.code
start:
    invoke GetModuleHandle, NULL
    mov    hInstance,eax
    invoke GetCommandLine
    mov CommandLine,eax
    invoke WinMain, hInstance,NULL,CommandLine, SW_SHOWDEFAULT
    invoke ExitProcess,eax

WinMain proc hInst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD
    LOCAL wc:WNDCLASSEX
    LOCAL msg:MSG
    LOCAL hwnd:HWND
    mov   wc.cbSize,SIZEOF WNDCLASSEX
    mov   wc.style, CS_HREDRAW or CS_VREDRAW
    mov   wc.lpfnWndProc, OFFSET WndProc
    mov   wc.cbClsExtra,NULL
    mov   wc.cbWndExtra,NULL
    push  hInst
    pop   wc.hInstance
    mov   wc.hbrBackground,COLOR_WINDOW+1
    mov   wc.lpszMenuName,NULL
    mov   wc.lpszClassName,OFFSET ClassName
    invoke LoadIcon,NULL,IDI_APPLICATION
    mov   wc.hIcon,eax
    mov   wc.hIconSm,eax
    invoke LoadCursor,NULL,IDC_ARROW
    mov   wc.hCursor,eax
    invoke RegisterClassEx, addr wc
    invoke CreateWindowEx,NULL,ADDR ClassName,ADDR AppName,\
           WS_OVERLAPPEDWINDOW,CW_USEDEFAULT,\
           CW_USEDEFAULT,CW_USEDEFAULT,CW_USEDEFAULT,NULL,NULL,\
           hInst,NULL
    mov   hwnd,eax
    invoke ShowWindow, hwnd,SW_SHOWNORMAL
    invoke UpdateWindow, hwnd
    .WHILE TRUE
                invoke GetMessage, ADDR msg,NULL,0,0
                .BREAK .IF (!eax)
                invoke TranslateMessage, ADDR msg
                invoke DispatchMessage, ADDR msg
        .ENDW
    mov     eax,msg.wParam
    ret
WinMain endp

WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
    LOCAL hdc:HDC
    LOCAL ps:PAINTSTRUCT

    .IF uMsg==WM_DESTROY
        invoke PostQuitMessage,NULL
    .ELSEIF uMsg==WM_CHAR
        push wParam
        pop  char
        invoke InvalidateRect, hWnd,NULL,TRUE
    .ELSEIF uMsg==WM_PAINT
        invoke BeginPaint,hWnd, ADDR ps
        mov    hdc,eax
        invoke TextOut,hdc,0,0,ADDR char,1
        invoke EndPaint,hWnd, ADDR ps
    .ELSE
        invoke DefWindowProc,hWnd,uMsg,wParam,lParam
        ret
    .ENDIF
    xor    eax,eax
    ret
WndProc endp
end start
 
Analysis:


char WPARAM 20h                         ; the character the program receives from keyboard

This is the variable that will store the character received from the keyboard. Since the character is sent in WPARAM of the window procedure, we define the variable as type WPARAM for simplicity. The initial value is 20h or the space since when our window refreshes its client area the first time, there is no character input. So we want to display space instead.

    .ELSEIF uMsg==WM_CHAR
        push wParam
        pop  char
        invoke InvalidateRect, hWnd,NULL,TRUE

This is added in the window procedure to handle the WM_CHAR message. It just puts the character into the variable named "char" and then calls InvalidateRect. InvalidateRect makes the specified rectangle in the client area invalid which forces Windows to send WM_PAINT message to the window procedure. Its syntax is as follows:

InvalidateRect proto hWnd:HWND,\
                                 lpRect:DWORD,\
                                 bErase:DWORD

lpRect is a pointer to the rectagle in the client area that we want to declare invalid. If this parameter is null, the entire client area will be marked as invalid.
bErase is a flag telling Windows if it needs to erase the background. If this flag is TRUE, then Windows will erase the backgroud of the invalid rectangle when BeginPaint is called.

So the strategy we used here is that: we store all necessary information relating to painting the client area and generate WM_PAINT message to paint the client area. Of course, the codes in WM_PAINT section must know beforehand what's expected of them. This seems a roundabout way of doing things but it's the way of Windows.
Actually we can paint the client area during processing WM_CHAR message by calling GetDC and ReleaseDC pair. There is no problem there. But the fun begins when our window needs to repaint its client area. Since the codes that paint the character are in WM_CHAR section, the window procedure will not be able to repaint our character in the client area. So the bottom line is: put all necessary data and codes that do painting in WM_PAINT. You can send WM_PAINT message from anywhere in your code anytime you want to repaint the client area.

        invoke TextOut,hdc,0,0,ADDR char,1

When InvalidateRect is called, it sends a WM_PAINT message back to the window procedure. So the codes in WM_PAINT section is called. It calls BeginPaint as usual to get the handle to device context and then call TextOut which draws our character in the client area at x=0, y=0. When you run the program and press any key, you will see that character echo in the upper left corner of the client window. And when the window is minimized and maximized again, the character is still there since all the codes and data essential to repaint are all gathered in WM_PAINT section.
[Iczelion's Win32 Assembly HomePage]
