+++
authors = [""]
title = "4. Painting with Text"
description = ""
date = 2024-07-09
[taxonomies]
tags = ["masm32"]
[extra]
toc = false
+++

In this tutorial, we will learn how to "paint" text in the client area of a window. We'll also learn about device context.
You can download the source code here.
Theory:
Text in Windows is a type of GUI object.  Each character is composed of numerous pixels (dots) that are lumped together into a distinct pattern. That's why it's called "painting" instead of "writing". Normally, you paint text in your own client area (actually, you can paint outside client area but that's another story).  Putting text on screen in Windows is drastically different from DOS. In DOS, you can think of the screen in 80x25 dimension. But in Windows, the screen are shared by several programs. Some rules must be enforced to avoid programs writing over each other's screen. Windows ensures this by limiting painting area of each window to its own client area only. The size of client area of a window is also not constant. The user can change the size anytime. So you must determine the dimensions of your own client area dynamically.
Before you can paint something on the client area, you must ask for permission from Windows. That's right, you don't have absolute control of the screen as you were in DOS anymore.  You must ask Windows for permission to paint your own client area. Windows will determine the size of your client area, font, colors and other GDI attributes and sends a handle to device context back to your program. You can then use the device context as a passport to painting on your client area.
What is a device context? It's just a data structure maintained internally by Windows. A device context is associated with a particular device, such as a printer or video display. For a video display, a device context is usually associated with a particular window on the display.
Some of the values in the device context are graphic attributes such as colors, font etc. These are default values which you can change at will. They exist to help reduce the load from having to specify these attributes in every GDI function calls.
You can think of a device context as a default environment prepared for you by Windows. You can override some default settings later if you so wish.
When a program need to paint, it must obtain a handle to a device context. Normally, there are several ways to accomplish this.

    call BeginPaint in response to WM_PAINT message.
    call GetDC in response to other messages.
    call CreateDC to create your own device context

One thing you must remember, after you're through with the device context handle, you must release it during the processing of a single message. Don't obtain the handle in response to one message and release it in response to another.
Windows posts WM_PAINT messages to a window to notify that it's now time to repaint its client area. Windows does not save the content of client area of a window.  Instead, when a situation occurs that warrants a repaint of client area (such as when a window was covered by another and is just uncovered), Windows puts WM_PAINT message in that window's message queue. It's the responsibility of that window to repaint its own client area. You must gather all information about how to repaint your client area in the WM_PAINT section of your window procedure, so the window procudure can repaint the client area when WM_PAINT message arrives.
Another concept you must come to terms with is the invalid rectangle. Windows defines an invalid rectangle as the smallest rectangular area in the client area that needs to be repainted. When Windows detects an invalid rectangle in the client area of a window , it posts WM_PAINT message to that window. In response to WM_PAINT message, the window can obtain a paintstruct structure which contains, among others, the coordinate of the invalid rectangle. You call BeginPaint in response to WM_PAINT message to validate the invalid rectangle. If you don't process WM_PAINT message, at the very least you must call DefWindowProc or ValidateRect to validate the invalid rectangle else Windows will repeatedly send you WM_PAINT message.
Below are the steps you should perform in response to a WM_PAINT message:

    Get a handle to device context with BeginPaint.
    Paint the client area.
    Release the handle to device context with EndPaint

Note that you don't have to explicitly validate the invalid rectangle. It's automatically done by the BeginPaint call. Between BeginPaint-Endpaint pair, you can call any GDI functions to paint your client area. Nearly all of them require the handle to device context as a parameter.
Content:
We will write a program that displays a text string "Win32 assembly is great and easy!" in the center of the client area.
 

    .386
    .model flat,stdcall
    option casemap:none

    WinMain proto :DWORD,:DWORD,:DWORD,:DWORD

    include \masm32\include\windows.inc
    include \masm32\include\user32.inc
    includelib \masm32\lib\user32.lib
    include \masm32\include\kernel32.inc
    includelib \masm32\lib\kernel32.lib

    .DATA
    ClassName db "SimpleWinClass",0
    AppName  db "Our First Window",0
    OurText  db "Win32 assembly is great and easy!",0

    .DATA?
    hInstance HINSTANCE ?
    CommandLine LPSTR ?

    .CODE
    start:
        invoke GetModuleHandle, NULL
        mov    hInstance,eax
        invoke GetCommandLine
        mov CommandLine,eax
        invoke WinMain, hInstance,NULL,CommandLine, SW_SHOWDEFAULT
        invoke ExitProcess,eax

    WinMain proc hInst:HINSTANCE, hPrevInst:HINSTANCE, CmdLine:LPSTR, CmdShow:DWORD
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
        LOCAL rect:RECT
        .IF uMsg==WM_DESTROY
            invoke PostQuitMessage,NULL
        .ELSEIF uMsg==WM_PAINT
            invoke BeginPaint,hWnd, ADDR ps
            mov    hdc,eax
            invoke GetClientRect,hWnd, ADDR rect
            invoke DrawText, hdc,ADDR OurText,-1, ADDR rect, \
                    DT_SINGLELINE or DT_CENTER or DT_VCENTER
            invoke EndPaint,hWnd, ADDR ps
        .ELSE
            invoke DefWindowProc,hWnd,uMsg,wParam,lParam
            ret
        .ENDIF
        xor   eax, eax
        ret
    WndProc endp
    end start

Analysis:
The majority of the code is the same as the example in tutorial 3. I'll explain only the important changes.

    LOCAL hdc:HDC
    LOCAL ps:PAINTSTRUCT
    LOCAL rect:RECT

These are local variables that are used by GDI functions in our WM_PAINT section. hdc is used to store the handle to device context returned from BeginPaint call. ps is a PAINTSTRUCT structure. Normally you don't use the values in ps. It's passed to BeginPaint function and Windows fills it with appropriate values. You then pass ps to EndPaint function when you finish painting the client area. rect is a RECT structure defined as follows:
 

    RECT Struct
        left           LONG ?
        top           LONG ?
        right        LONG ?
        bottom    LONG ?
    RECT ends

Left and top are the coordinates of the upper left corner of a rectangle Right and bottom are the coordinates of the lower right corner. One thing to remember: The origin of the x-y axes is at the upper left corner of the client area. So the point y=10 is BELOW the point y=0.

        invoke BeginPaint,hWnd, ADDR ps
        mov    hdc,eax
        invoke GetClientRect,hWnd, ADDR rect
        invoke DrawText, hdc,ADDR OurText,-1, ADDR rect, \
                DT_SINGLELINE or DT_CENTER or DT_VCENTER
        invoke EndPaint,hWnd, ADDR ps

In response to WM_PAINT message, you call BeginPaint with handle to the window you want to paint and an uninitialized PAINTSTRUCT structure as parameters. After successful call, eax contains the handle to device context. Next you call GetClientRect to retrieve the dimension of the client area. The dimension is returned in rect variable which you pass to DrawText as one of its parameters. DrawText's syntax is:

DrawText proto hdc:HDC, lpString:DWORD, nCount:DWORD, lpRect:DWORD, uFormat:DWORD

DrawText is a high-level text output API function. It handles some gory details such as word wrap, centering etc. so you could concentrate on the string you want to paint. Its low-level brother, TextOut, will be examined in the next tutorial. DrawText formats a text string to fit within the bounds of a rectangle. It uses the currently selected font,color and background (in the device context) to draw the text.Lines are wrapped to fit within the bounds of the rectangle. It returns the height of the output text in device units, in our case, pixels. Let's see its parameters:

    hdc  handle to device context
    lpString  The pointer to the string you want to draw in the rectangle. The string must be null-terminated else you would have to specify its length in the next parameter, nCount.
    nCount  The number of characters to output. If the string is null-terminated, nCount must be -1. Otherwise nCount must contain the number of characters in the string you want to draw.
    lpRect  The pointer to the rectangle (a structure of type RECT) you want to draw the string in. Note that this rectangle is also a clipping rectangle, that is, you could not draw the string outside this rectangle.
    uFormat The value that specifies how the string is displayed in the rectangle. We use three values combined by "or" operator:
        DT_SINGLELINE  specifies a single line of text
        DT_CENTER  centers the text horizontally.
        DT_VCENTER centers the text vertically. Must be used with DT_SINGLELINE.

After you finish painting the client area, you must call EndPaint function to release the handle to device context.
That's it. We can summarize the salient points here:

    You call BeginPaint-EndPaint pair in response to WM_PAINT message.
    Do anything you like with the client area between the calls to BeginPaint and EndPaint.
    If you want to repaint your client area in response to other messages, you have two choices:
        Use GetDC-ReleaseDC pair and do your painting between these calls
        Call InvalidateRect or UpdateWindow  to invalidate the entire client area, forcing Windows to put WM_PAINT message in the message queue of your window and do your painting in WM_PAINT section

[Iczelion's Win32 Assembly HomePage]
