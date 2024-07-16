+++
authors = [""]
title = "10. Dialog Box as Main Window"
description = ""
date = 2024-07-09
[taxonomies]
tags = ["masm32"]
[extra]
toc = false
+++

Now comes the really interesting part about GUI, the dialog box. In this tutorial (and the next), we will learn how to use a dialog box as our main window.

Download the first example here, the second example here.
Theory:
If you play with the examples in the previous tutorial long enough, you 'll find out that you cannot change input focus from one child window control to another with Tab key. The only way you can do that is by clicking the control you want it to gain input focus. This situation is rather cumbersome. Another thing you might notice is that I changed the background color of the parent window to gray instead of normal white as in previous examples. This is done so that the color of the child window controls can blend seamlessly with the color of the client area of the parent window. There is a way to get around this problem but it's not easy. You have to subclass all child window controls in your parent window.
The reason why such inconvenience exists is that child window controls are originally designed to work with a dialog box, not a normal window. The default color of child window controls such as a button is gray because the client area of a dialog box is normally gray so they blend into each other without any sweat on the programmer's part.
Before we get deep into the detail, we should know first what a dialog box is. A dialog box is nothing more than a normal window which is designed to work with child window controls. Windows also provides internal "dialog box manager" which is responsible for most of the keyboard logic such as shifting input focus when the user presses Tab, pressing the default pushbutton if Enter key is pressed, etc so programmers can deal with higher level tasks. Dialog boxes are primarily used as input/output devices. As such a dialog box can be considered as an input/output "black box" meaning that you don't have to know how a dialog box works internally in order to be able to use it, you only have to know how to interact with it. That's a principle of object oriented programming (OOP) called information hiding. If the black box is *perfectly* designed, the user can make use of it without any knowledge on how it operates. The catch is that the black box must be perfect, that's hard to achieve in the real world. Win32 API is also designed as a black box too.
Well, it seems we stray from our path. Let's get back to our subject. Dialog boxes are designed to reduce workload of a programmer. Normally if you put child window controls on a normal window, you have to subclass them and write keyboard logic yourself. But if you put them on a dialog box, it will handle the logic for you. You only have to know how to get the user input from the dialog box or how to send commands to it.
A dialog box is defined as a resource much the same way as a menu. You write a dialog box template describing the characteristics of the dialog box and its controls and then compile the resource script with a resource editor.
Note that all resources are put together in the same resource script file. You can use any text editor to write a dialog box template but I don't recommend it. You should use a resource editor to do the job visually since arranging child window controls on a dialog box is hard to do manually. Several excellent resource editors are available. Most of the major compiler suites include their own resource editors. You can use them to create a resource script for your program and then cut out irrelevant lines such as those related to MFC.
There are two main types of dialog box: modal and modeless. A modeless dialog box lets you change input focus to other window. The example is the Find dialog of MS Word. There are two subtypes of modal dialog box: application modal and system modal. An application modal dialog box doesn't let you change input focus to other window in the same application but you can change the input focus to the window of OTHER application. A system modal dialog box doesn't allow you to change input focus to any other window until you respond to it first.
A modeless dialog box is created by calling CreateDialogParam API function. A modal dialog box is created by calling DialogBoxParam. The only distinction between an application modal dialog box and a system modal one is the DS_SYSMODAL style. If you include DS_SYSMODAL style in a dialog box template, that dialog box will be a system modal one.
You can communicate with any child window control on a dialog box by using SendDlgItemMessage function. Its syntax is like this:
 

    SendDlgItemMessage proto hwndDlg:DWORD,\
                                                 idControl:DWORD,\
                                                 uMsg:DWORD,\
                                                 wParam:DWORD,\
                                                 lParam:DWORD

This API call is immensely useful for interacting with a child window control. For example, if you want to get the text from an edit control, you can do this:

    call SendDlgItemMessage, hDlg, ID_EDITBOX, WM_GETTEXT, 256, ADDR text_buffer

In order to know which message to send, you should consult your Win32 API reference.
Windows also provides several control-specific API functions to get and set data quickly, for example, GetDlgItemText, CheckDlgButton etc. These control-specific functions are provided for programmer's convenience so he doesn't have to look up the meanings of wParam and lParam for each message. Normally, you should use control-specific API calls when they're available since they make source code maintenance easier. Resort to SendDlgItemMessage only if no control-specific API calls are available.
The Windows dialog box manager sends some messages to a specialized callback function called a dialog box procedure which has the following format:

    DlgProc  proto hDlg:DWORD ,\
                            iMsg:DWORD ,\
                            wParam:DWORD ,\
                            lParam:DWORD

The dialog box procedure is very similar to a window procedure except for the type of return value which is TRUE/FALSE instead of LRESULT. The internal dialog box manager inside Windows IS the true window procedure for the dialog box. It calls our dialog box procedure with some messages that it received. So the general rule of thumb is that: if our dialog box procedure processes a message,it MUST return TRUE in eax and if it does not process the message, it must return FALSE in eax. Note that a dialog box procedure doesn't pass the messages it does not process to the DefWindowProc call since it's not a real window procedure.
There are two distinct uses of a dialog box. You can use it as the main window of your application or use it as an input device. We 'll examine the first approach in this tutorial.
"Using a dialog box as main window" can be interpreted in two different senses.

    You can use the dialog box template as a class template which you register with RegisterClassEx call. In this case, the dialog box behaves like a "normal" window: it receives messages via a window procedure referred to by lpfnWndProc member of the window class, not via a dialog box procedure. The benefit of this approach is that you don't have to create child window controls yourself, Windows creates them for you when the dialog box is created. Also Windows handles the keyboard logic for you such as Tab order etc. Plus you can specify the cursor and icon of your window in the window class structure.

    Your program just creates the dialog box without creating any parent window. This approach makes a message loop unnecessary since the messages are sent directly to the dialog box procedure. You don't even have to register a window class!

This tutorial is going to be a long one. I'll present the first approach followed by the second.
Examples:
dialog.asm

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
ClassName db "DLGCLASS",0
MenuName db "MyMenu",0
DlgName db "MyDialog",0
AppName db "Our First Dialog Box",0
TestString db "Wow! I'm in an edit box now",0

.data?
hInstance HINSTANCE ?
CommandLine LPSTR ?
buffer db 512 dup(?)

.const
IDC_EDIT        equ 3000
IDC_BUTTON      equ 3001
IDC_EXIT        equ 3002
IDM_GETTEXT     equ 32000
IDM_CLEAR       equ 32001
IDM_EXIT        equ 32002

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
    LOCAL hDlg:HWND
    mov   wc.cbSize,SIZEOF WNDCLASSEX
    mov   wc.style, CS_HREDRAW or CS_VREDRAW
    mov   wc.lpfnWndProc, OFFSET WndProc
    mov   wc.cbClsExtra,NULL
    mov   wc.cbWndExtra,DLGWINDOWEXTRA
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
    invoke CreateDialogParam,hInstance,ADDR DlgName,NULL,NULL,NULL
    mov   hDlg,eax
    invoke ShowWindow, hDlg,SW_SHOWNORMAL
    invoke UpdateWindow, hDlg
    invoke GetDlgItem,hDlg,IDC_EDIT
    invoke SetFocus,eax
    .WHILE TRUE
        invoke GetMessage, ADDR msg,NULL,0,0
        .BREAK .IF (!eax)
       invoke IsDialogMessage, hDlg, ADDR msg
        .IF eax ==FALSE
            invoke TranslateMessage, ADDR msg
            invoke DispatchMessage, ADDR msg
        .ENDIF
    .ENDW
    mov     eax,msg.wParam
    ret
WinMain endp

WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
    .IF uMsg==WM_DESTROY
        invoke PostQuitMessage,NULL
    .ELSEIF uMsg==WM_COMMAND
        mov eax,wParam
        .IF lParam==0
            .IF ax==IDM_GETTEXT
                invoke GetDlgItemText,hWnd,IDC_EDIT,ADDR buffer,512
                invoke MessageBox,NULL,ADDR buffer,ADDR AppName,MB_OK
            .ELSEIF ax==IDM_CLEAR
                invoke SetDlgItemText,hWnd,IDC_EDIT,NULL
            .ELSE
                invoke DestroyWindow,hWnd
            .ENDIF
        .ELSE
            mov edx,wParam
            shr edx,16
            .IF dx==BN_CLICKED
                .IF ax==IDC_BUTTON
                    invoke SetDlgItemText,hWnd,IDC_EDIT,ADDR TestString
                .ELSEIF ax==IDC_EXIT
                    invoke SendMessage,hWnd,WM_COMMAND,IDM_EXIT,0
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
Dialog.rc

#include "resource.h"

#define IDC_EDIT                                       3000
#define IDC_BUTTON                                3001
#define IDC_EXIT                                       3002

#define IDM_GETTEXT                             32000
#define IDM_CLEAR                                  32001
#define IDM_EXIT                                      32003
 

MyDialog DIALOG 10, 10, 205, 60
STYLE 0x0004 | DS_CENTER | WS_CAPTION | WS_MINIMIZEBOX |
WS_SYSMENU | WS_VISIBLE | WS_OVERLAPPED | DS_MODALFRAME | DS_3DLOOK
CAPTION "Our First Dialog Box"
CLASS "DLGCLASS"
BEGIN
    EDITTEXT         IDC_EDIT,   15,17,111,13, ES_AUTOHSCROLL | ES_LEFT
    DEFPUSHBUTTON   "Say Hello", IDC_BUTTON,    141,10,52,13
    PUSHBUTTON      "E&xit", IDC_EXIT,  141,26,52,13, WS_GROUP
END
 

MyMenu  MENU
BEGIN
    POPUP "Test Controls"
    BEGIN
        MENUITEM "Get Text", IDM_GETTEXT
        MENUITEM "Clear Text", IDM_CLEAR
        MENUITEM "", , 0x0800 /*MFT_SEPARATOR*/
        MENUITEM "E&xit", IDM_EXIT
    END
END
Analysis:
Let's analyze this first example.
This example shows how to register a dialog template as a window class and create a "window" from that class. It simplifies your program since you don't have to create the child window controls yourself.
Let's first analyze the dialog template.

MyDialog DIALOG 10, 10, 205, 60

Declare the name of a dialog, in this case, "MyDialog" followed by the keyword "DIALOG". The following four numbers are: x, y , width, and height of the dialog box in dialog box units (not the same as pixels).

STYLE 0x0004 | DS_CENTER | WS_CAPTION | WS_MINIMIZEBOX |
WS_SYSMENU | WS_VISIBLE | WS_OVERLAPPED | DS_MODALFRAME | DS_3DLOOK

Declare the styles of the dialog box.

CAPTION "Our First Dialog Box"

This is the text that will appear in the dialog box's title bar.

CLASS "DLGCLASS"

This line is crucial. It's this CLASS keyword that allows us to use the dialog box template as a window class. Following the keyword is the name of the "window class"

BEGIN
    EDITTEXT         IDC_EDIT,   15,17,111,13, ES_AUTOHSCROLL | ES_LEFT
    DEFPUSHBUTTON   "Say Hello", IDC_BUTTON,    141,10,52,13
    PUSHBUTTON      "E&xit", IDC_EXIT,  141,26,52,13
END

The above block defines the child window controls in the dialog box. They're defined between BEGIN and END keywords. Generally the syntax is as follows:

    control-type  "text"   ,controlID, x, y, width, height [,styles]

control-types are resource compiler's constants so you have to consult the manual.
Now we go to the assembly source code. The interesting part is in the window class structure:

    mov   wc.cbWndExtra,DLGWINDOWEXTRA
    mov   wc.lpszClassName,OFFSET ClassName

Normally, this member is left NULL, but if we want to register a dialog box template as a window class, we must set this member to the value DLGWINDOWEXTRA. Note that the name of the class must be identical to the one following the CLASS keyword in the dialog box template. The remaining members are initialized as usual. After you fill the window class structure, register it with RegisterClassEx. Seems familiar? This is the same routine you have to do in order to register a normal window class.

    invoke CreateDialogParam,hInstance,ADDR DlgName,NULL,NULL,NULL

After registering the "window class", we create our dialog box. In this example, I create it as a modeless dialog box with CreateDialogParam function. This function takes 5 parameters but you only have to fill in the first two: the instance handle and the pointer to the name of the dialog box template. Note that the 2nd parameter is not a pointer to the class name.
At this point, the dialog box and its child window controls are created by Windows. Your window procedure will receive WM_CREATE message as usual.

    invoke GetDlgItem,hDlg,IDC_EDIT
    invoke SetFocus,eax

After the dialog box is created, I want to set the input focus to the edit control. If I put these codes in WM_CREATE section, GetDlgItem call will fail since at that time, the child window controls are not created yet. The only way you can do this is to call it after the dialog box and all its child window controls are created. So I put these two lines after the UpdateWindow call. GetDlgItem function gets the control ID and returns the associated control's window handle. This is how you can get a window handle if you know its control ID.

       invoke IsDialogMessage, hDlg, ADDR msg
        .IF eax ==FALSE
            invoke TranslateMessage, ADDR msg
            invoke DispatchMessage, ADDR msg
        .ENDIF

The program enters the message loop and before we translate and dispatch messages, we call IsDialogMessage function to let the dialog box manager handles the keyboard logic of our dialog box for us. If this function returns TRUE , it means the message is intended for the dialog box and is processed by the dialog box manager. Note another difference from the previous tutorial. When the window procedure wants to get the text from the edit control, it calls GetDlgItemText function instead of GetWindowText. GetDlgItemText accepts a control ID instead of a window handle. That makes the call easier in the case you use a dialog box.

Now let's go to the second approach to using a dialog box as a main window. In the next example, I 'll create an application modal dialog box. You'll not find a message loop or a window procedure because they're not necessary!
dialog.asm (part 2)

.386
.model flat,stdcall
option casemap:none

DlgProc proto :DWORD,:DWORD,:DWORD,:DWORD

include \masm32\include\windows.inc
include \masm32\include\user32.inc
include \masm32\include\kernel32.inc
includelib \masm32\lib\user32.lib
includelib \masm32\lib\kernel32.lib

.data
DlgName db "MyDialog",0
AppName db "Our Second Dialog Box",0
TestString db "Wow! I'm in an edit box now",0

.data?
hInstance HINSTANCE ?
CommandLine LPSTR ?
buffer db 512 dup(?)

.const
IDC_EDIT            equ 3000
IDC_BUTTON     equ 3001
IDC_EXIT            equ 3002
IDM_GETTEXT  equ 32000
IDM_CLEAR       equ 32001
IDM_EXIT           equ 32002
 

.code
start:
    invoke GetModuleHandle, NULL
    mov    hInstance,eax
    invoke DialogBoxParam, hInstance, ADDR DlgName,NULL, addr DlgProc, NULL
    invoke ExitProcess,eax

DlgProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
    .IF uMsg==WM_INITDIALOG
        invoke GetDlgItem, hWnd,IDC_EDIT
        invoke SetFocus,eax
    .ELSEIF uMsg==WM_CLOSE
        invoke SendMessage,hWnd,WM_COMMAND,IDM_EXIT,0
    .ELSEIF uMsg==WM_COMMAND
        mov eax,wParam
        .IF lParam==0
            .IF ax==IDM_GETTEXT
                invoke GetDlgItemText,hWnd,IDC_EDIT,ADDR buffer,512
                invoke MessageBox,NULL,ADDR buffer,ADDR AppName,MB_OK
            .ELSEIF ax==IDM_CLEAR
                invoke SetDlgItemText,hWnd,IDC_EDIT,NULL
            .ELSEIF ax==IDM_EXIT
                invoke EndDialog, hWnd,NULL
            .ENDIF
        .ELSE
            mov edx,wParam
            shr edx,16
            .if dx==BN_CLICKED
                .IF ax==IDC_BUTTON
                    invoke SetDlgItemText,hWnd,IDC_EDIT,ADDR TestString
                .ELSEIF ax==IDC_EXIT
                    invoke SendMessage,hWnd,WM_COMMAND,IDM_EXIT,0
                .ENDIF
            .ENDIF
        .ENDIF
    .ELSE
        mov eax,FALSE
        ret
    .ENDIF
    mov eax,TRUE
    ret
DlgProc endp
end start
dialog.rc (part 2)

#include "resource.h"

#define IDC_EDIT                                       3000
#define IDC_BUTTON                                3001
#define IDC_EXIT                                       3002

#define IDR_MENU1                                  3003

#define IDM_GETTEXT                              32000
#define IDM_CLEAR                                   32001
#define IDM_EXIT                                       32003
 

MyDialog DIALOG 10, 10, 205, 60
STYLE 0x0004 | DS_CENTER | WS_CAPTION | WS_MINIMIZEBOX |
WS_SYSMENU | WS_VISIBLE | WS_OVERLAPPED | DS_MODALFRAME | DS_3DLOOK
CAPTION "Our Second Dialog Box"
MENU IDR_MENU1
BEGIN
    EDITTEXT         IDC_EDIT,   15,17,111,13, ES_AUTOHSCROLL | ES_LEFT
    DEFPUSHBUTTON   "Say Hello", IDC_BUTTON,    141,10,52,13
    PUSHBUTTON      "E&xit", IDC_EXIT,  141,26,52,13
END
 

IDR_MENU1  MENU
BEGIN
    POPUP "Test Controls"
    BEGIN
        MENUITEM "Get Text", IDM_GETTEXT
        MENUITEM "Clear Text", IDM_CLEAR
        MENUITEM "", , 0x0800 /*MFT_SEPARATOR*/
        MENUITEM "E&xit", IDM_EXIT
    END
END


The analysis follows:

    DlgProc proto :DWORD,:DWORD,:DWORD,:DWORD

We declare the function prototype for DlgProc so we can refer to it with addr operator in the line below:

    invoke DialogBoxParam, hInstance, ADDR DlgName,NULL, addr DlgProc, NULL

The above line calls DialogBoxParam function which takes 5 parameters: the instance handle, the name of the dialog box template, the parent window handle, the address of the dialog box procedure, and the dialog-specific data. DialogBoxParam creates a modal dialog box. It will not return until the dialog box is destroyed.

    .IF uMsg==WM_INITDIALOG
        invoke GetDlgItem, hWnd,IDC_EDIT
        invoke SetFocus,eax
    .ELSEIF uMsg==WM_CLOSE
        invoke SendMessage,hWnd,WM_COMMAND,IDM_EXIT,0

The dialog box procedure looks like a window procedure except that it doesn't receive WM_CREATE message. The first message it receives is WM_INITDIALOG. Normally you can put the initialization code here. Note that you must return the value TRUE in eax if you process the message.
The internal dialog box manager doesn't send our dialog box procedure the WM_DESTROY message by default when WM_CLOSE is sent to our dialog box. So if we want to react when the user presses the close button on our dialog box, we must process WM_CLOSE message. In our example, we send WM_COMMAND message with the value IDM_EXIT in wParam. This has the same effect as when the user selects Exit menu item. EndDialog is called in response to IDM_EXIT.
The processing of WM_COMMAND messages remains the same.
When you want to destroy the dialog box, the only way is to call EndDialog function. Do not try DestroyWindow! EndDialog doesn't destroy the dialog box immediately. It only sets a flag for the internal dialog box manager and continues to execute the next instructions.
Now let's examine the resource file. The notable change is that instead of using a text string as menu name we use a value, IDR_MENU1. This is necessary if you want to attach a menu to a dialog box created with DialogBoxParam. Note that in the dialog box template, you have to add the keyword MENU followed by the menu resource ID.
A difference between the two examples in this tutorial that you can readily observe is the lack of an icon in the latter example. However, you can set the icon by sending the message WM_SETICON to the dialog box during WM_INITDIALOG.
[Iczelion's Win32 Assembly Homepage]
