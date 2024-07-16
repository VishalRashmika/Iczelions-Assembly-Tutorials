+++
authors = [""]
title = "7. Mouse Input"
description = ""
date = 2024-07-09
[taxonomies]
tags = ["masm32"]
[extra]
toc = false
+++



We will learn how to receive and respond to mouse input in our window procedure. The example program will wait for left mouse clicks and display a text string at the exact clicked spot in the client area.

Download the example here.
Theory:
As with keyboard input, Windows detects and sends notifications about mouse activities that are relevant to each window. Those activities include left and right clicks, mouse cursor movement over window, double clicks. Unlike keyboard input which is directed to the window that has input focus, mouse messages are sent to any window that the mouse cursor is over, active or not. In addition, there are mouse messages about the non-client area too. But most of the time, we can blissfully ignore them. We can focus on those relating to the client area.
There are two messages for each mouse button: WM_LBUTTONDOWN,WM_RBUTTONDOWN and WM_LBUTTONUP, WM_RBUTTONUP messages. For a mouse with three buttons, there are also WM_MBUTTONDOWN and WM_MBUTTONUP. When the mouse cursor moves over the client area, Windows sends WM_MOUSEMOVE messages to the window under the cursor.
A window can receive double click messages, WM_LBUTTONDBCLK or WM_RBUTTONDBCLK, if and only if its window class has CS_DBLCLKS style flag, else the window will receive only a series of mouse button up and down messages.
For all these messages, the value of lParam contains the position of the mouse. The low word is the x-coordinate, and the high word is the y-coordinate relative to upper left corner of the client area of the window. wParam indicates the state of the mouse buttons and Shift and Ctrl keys.
 
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
MouseClick db 0         ; 0=no click yet

.data?
hInstance HINSTANCE ?
CommandLine LPSTR ?
hitpoint POINT <>

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
    .ELSEIF uMsg==WM_LBUTTONDOWN
        mov eax,lParam
        and eax,0FFFFh
        mov hitpoint.x,eax
        mov eax,lParam
        shr eax,16
        mov hitpoint.y,eax
        mov MouseClick,TRUE
        invoke InvalidateRect,hWnd,NULL,TRUE
    .ELSEIF uMsg==WM_PAINT
        invoke BeginPaint,hWnd, ADDR ps
        mov    hdc,eax
        .IF MouseClick
            invoke lstrlen,ADDR AppName
            invoke TextOut,hdc,hitpoint.x,hitpoint.y,ADDR AppName,eax
        .ENDIF
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
    .ELSEIF uMsg==WM_LBUTTONDOWN
        mov eax,lParam
        and eax,0FFFFh
        mov hitpoint.x,eax
        mov eax,lParam
        shr eax,16
        mov hitpoint.y,eax
        mov MouseClick,TRUE
        invoke InvalidateRect,hWnd,NULL,TRUE

The window procedure waits for left mouse button click. When it receives WM_LBUTTONDOWN, lParam contains the coordinate of the mouse cursor in the client area. It saves the coordinate in a variable of type POINT which is defined as:

POINT STRUCT
    x   dd ?
    y   dd ?
POINT ENDS

and sets the flag, MouseClick, to TRUE, meaning that there's at least a left mouse button click in the client area.

        mov eax,lParam
        and eax,0FFFFh
        mov hitpoint.x,eax

Since x-coordinate is the low word of lParam and the members of POINT structure are 32-bit in size, we have to zero out the high word of eax prior to storing it in hitpoint.x.

        shr eax,16
        mov hitpoint.y,eax

Because y-coordinate is the high word of lParam, we must put it in the low word of eax prior to storing it in hitpoint.y. We do this by shifting eax 16 bits to the right.
After storing the mouse position, we set the flag, MouseClick, to TRUE in order to let the painting code in WM_PAINT section know that there's at least a click in the client area so it can draw the string at the mouse position. Next  we call InvalidateRect function to force the window to repaint its entire client area.

        .IF MouseClick
            invoke lstrlen,ADDR AppName
            invoke TextOut,hdc,hitpoint.x,hitpoint.y,ADDR AppName,eax
        .ENDIF

The painting code in WM_PAINT section must check if MouseClick is true, since when the window was created, it received a WM_PAINT message which at that time, no mouse click had occurred so it should not draw the string in the client area. We initialize MouseClick to FALSE and change its value to TRUE when an actual mouse click occurs.
If at least one mouse click has occurred, it draws the string in the client area at the mouse position. Note that it calls lstrlen to get the length of the string to display and sends the length as the last parameter of TextOut function.
[Iczelion's Win32 Assembly HomePage]
