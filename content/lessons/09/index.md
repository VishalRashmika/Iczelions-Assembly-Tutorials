+++
authors = [""]
title = "9. Child Window Controls"
description = ""
date = 2024-07-09
[taxonomies]
tags = ["masm32"]
[extra]
toc = false
+++



In this tutorial, we will explore child window controls which are very important input and output devices of our programs.

Download the example here.
Theory:
Windows provides several predefined window classes which we can readily use in our own programs. Most of the time we use them as components of a dialog box so they're usually called child window controls. The child window controls process their own mouse and keyboard messages and notify the parent window when their states have changed. They relieve the burden from programmers enormously so you should use them as much as possible. In this tutorial, I put them on a normal window just to demonstrate how you can create and use them but in reality you should put them in a dialog box.
Examples of predefined window classes are button, listbox, checkbox, radio button,edit etc.
In order to use a child window control, you must create it with CreateWindow or CreateWindowEx. Note that you don't have to register the window class since it's registered for you by Windows. The class name parameter MUST be the predefined class name. Say, if you want to create a button, you must specify "button" as the class name in CreateWindowEx. The other parameters you must fill in are the parent window handle and the control ID. The control ID must be unique among the controls. The control ID is the ID of that control. You use it to differentiate between the controls.
After the control was created, it will send messages notifying the parent window when its state has changed. Normally, you create the child windows during WM_CREATE message of the parent window. The child window sends WM_COMMAND messages to the parent window with its control ID in the low word of wParam,  the notification code in the high word of wParam, and its window handle in lParam. Each child window control has different notification codes, refer to your Win32 API reference for more information.
The parent window can send commands to the child windows too, by calling SendMessage function. SendMessage function sends the specified message with accompanying values in wParam and lParam to the window specified by the window handle. It's an extremely useful function since it can send messages to any window provided you know its window handle.
So, after creating the child windows, the parent window must process WM_COMMAND messages to be able to receive notification codes from the child windows.
Example:
We will create a window which contains an edit control and a pushbutton. When you click the button, a message box will appear showing the text you typed in the edit box. There is also a menu with 4 menu items:

    Say Hello  -- Put a text string into the edit box
    Clear Edit Box -- Clear the content of the edit box
    Get Text -- Display a message box with the text in the edit box
    Exit -- Close the program.

.386
.model flat,stdcall
option casemap:none

WinMain proto :DWORD,:DWORD,:DWORD,:DWORD

include \masm32\include\windows.inc
include \masm32\include\user32.inc
include \masm32\include\kernel32.inc
includelib \masm32\lib\user32.lib
includelib \masm32\lib\kernel32.lib

.data
ClassName db "SimpleWinClass",0
AppName  db "Our First Window",0
MenuName db "FirstMenu",0
ButtonClassName db "button",0
ButtonText db "My First Button",0
EditClassName db "edit",0
TestString db "Wow! I'm in an edit box now",0

.data?
hInstance HINSTANCE ?
CommandLine LPSTR ?
hwndButton HWND ?
hwndEdit HWND ?
buffer db 512 dup(?)                    ; buffer to store the text retrieved from the edit box

.const
ButtonID equ 1                                ; The control ID of the button control
EditID equ 2                                    ; The control ID of the edit control
IDM_HELLO equ 1
IDM_CLEAR equ 2
IDM_GETTEXT equ 3
IDM_EXIT equ 4

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
    mov   wc.hbrBackground,COLOR_BTNFACE+1
    mov   wc.lpszMenuName,OFFSET MenuName
    mov   wc.lpszClassName,OFFSET ClassName
    invoke LoadIcon,NULL,IDI_APPLICATION
    mov   wc.hIcon,eax
    mov   wc.hIconSm,eax
    invoke LoadCursor,NULL,IDC_ARROW
    mov   wc.hCursor,eax
    invoke RegisterClassEx, addr wc
    invoke CreateWindowEx,WS_EX_CLIENTEDGE,ADDR ClassName, \
                        ADDR AppName, WS_OVERLAPPEDWINDOW,\
                        CW_USEDEFAULT, CW_USEDEFAULT,\
                        300,200,NULL,NULL, hInst,NULL
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
    .IF uMsg==WM_DESTROY
        invoke PostQuitMessage,NULL
    .ELSEIF uMsg==WM_CREATE
        invoke CreateWindowEx,WS_EX_CLIENTEDGE, ADDR EditClassName,NULL,\
                        WS_CHILD or WS_VISIBLE or WS_BORDER or ES_LEFT or\
                        ES_AUTOHSCROLL,\
                        50,35,200,25,hWnd,8,hInstance,NULL
        mov  hwndEdit,eax
        invoke SetFocus, hwndEdit
        invoke CreateWindowEx,NULL, ADDR ButtonClassName,ADDR ButtonText,\
                        WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\
                        75,70,140,25,hWnd,ButtonID,hInstance,NULL
        mov  hwndButton,eax
    .ELSEIF uMsg==WM_COMMAND
        mov eax,wParam
        .IF lParam==0
            .IF ax==IDM_HELLO
                invoke SetWindowText,hwndEdit,ADDR TestString
            .ELSEIF ax==IDM_CLEAR
                invoke SetWindowText,hwndEdit,NULL
            .ELSEIF  ax==IDM_GETTEXT
                invoke GetWindowText,hwndEdit,ADDR buffer,512
                invoke MessageBox,NULL,ADDR buffer,ADDR AppName,MB_OK
            .ELSE
                invoke DestroyWindow,hWnd
            .ENDIF
        .ELSE
            .IF ax==ButtonID
                shr eax,16
                .IF ax==BN_CLICKED
                    invoke SendMessage,hWnd,WM_COMMAND,IDM_GETTEXT,0
                .ENDIF
            .ENDIF
        .ENDIF
    .ELSE
        invoke DefWindowProc,hWnd,uMsg,wParam,lParam
        ret
    .ENDIF
     xor    eax,eax
    ret
WndProc endp
end start
Analysis:
Let's analyze the program.

        .ELSEIF uMsg==WM_CREATE
            invoke CreateWindowEx,WS_EX_CLIENTEDGE, \
                            ADDR EditClassName,NULL,\
                            WS_CHILD or WS_VISIBLE or WS_BORDER or ES_LEFT\
                            or ES_AUTOHSCROLL,\
                            50,35,200,25,hWnd,EditID,hInstance,NULL
            mov  hwndEdit,eax
            invoke SetFocus, hwndEdit
            invoke CreateWindowEx,NULL, ADDR ButtonClassName,\
                            ADDR ButtonText,\
                            WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\
                            75,70,140,25,hWnd,ButtonID,hInstance,NULL
            mov  hwndButton,eax

We create the controls during processing of WM_CREATE message. We call CreateWindowEx with an extra window style, WS_EX_CLIENTEDGE, which makes the client area look sunken. The name of each control is a predefined one, "edit" for edit control, "button" for button control. Next we specify the child window's styles. Each control has extra styles in addition to the normal window styles. For example, the button styles are prefixed with "BS_" for "button style", edit styles are prefixed with "ES_" for "edit style". You have to look these styles up in a Win32 API reference. Note that you put a control ID in place of the menu handle. This doesn't cause any harm since a child window control cannot have a menu.
After creating each control, we keep its handle in a variable for future use.
SetFocus is called to give input focus to the edit box so the user can type the text into it immediately.
Now comes the really exciting part. Every child window control sends notification to its parent window with WM_COMMAND.

    .ELSEIF uMsg==WM_COMMAND
        mov eax,wParam
        .IF lParam==0

Recall that a menu also sends WM_COMMAND messages to notify the window about its state too. How can you differentiate between WM_COMMAND messages originated from a menu or a control? Below is the answer
 
	Low word of wParam 	High word of wParam 	lParam
Menu 	Menu ID 	0 	0
Control 	Control ID 	Notification code 	Child Window Handle

You can see that you should check lParam. If it's zero, the current WM_COMMAND message is from a menu. You cannot use wParam to differentiate between a menu and a control since the menu ID and control ID may be identical and the notification code may be zero.

            .IF ax==IDM_HELLO
                invoke SetWindowText,hwndEdit,ADDR TestString
            .ELSEIF ax==IDM_CLEAR
                invoke SetWindowText,hwndEdit,NULL
            .ELSEIF  ax==IDM_GETTEXT
                invoke GetWindowText,hwndEdit,ADDR buffer,512
                invoke MessageBox,NULL,ADDR buffer,ADDR AppName,MB_OK

You can put a text string into an edit box by calling SetWindowText. You clear the content of an edit box by calling SetWindowText with NULL. SetWindowText is a general purpose API function. You can use SetWindowText to change the caption of a window or the text on a button.
To get the text in an edit box, you use GetWindowText.

            .IF ax==ButtonID
                shr eax,16
                .IF ax==BN_CLICKED
                    invoke SendMessage,hWnd,WM_COMMAND,IDM_GETTEXT,0
                .ENDIF
            .ENDIF

The above code snippet deals with the condition when the user presses the button. First, it checks the low word of wParam to see if the control ID matches that of the button. If it is, it checks the high word of wParam to see if it is the notification code BN_CLICKED which is sent when the button is clicked.
The interesting part is after it's certain that the notification code is BN_CLICKED. We want to get the text from the edit box and display it in a message box. We can duplicate the code in the IDM_GETTEXT section above but it doesn't make sense. If we can somehow send a WM_COMMAND message with the low word of wParam containing the value IDM_GETTEXT to our own window procedure, we can avoid code duplication and simplify our program. SendMessage function is the answer. This function sends any message to any window with any wParam and lParam we want. So instead of duplicating the code, we call SendMessage with the parent window handle, WM_COMMAND, IDM_GETTEXT, and 0. This has identical effect to selecting "Get Text" menu item from the menu. The window procedure doesn't perceive any difference between the two.
You should use this technique as much as possible to make your code more organized.
Last but not least, do not forget the TranslateMessage function in the message loop. Since you must type in some text into the edit box, your program must translate raw keyboard input into readable text. If you omit this function, you will not be able to type anything into your edit box.
[Iczelion's Win32 Assembly HomePage]
