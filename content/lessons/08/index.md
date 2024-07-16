+++
authors = [""]
title = "8. Menu"
description = ""
date = 2024-07-09
[taxonomies]
tags = ["masm32"]
[extra]
toc = false
+++

In this tutorial, we will learn how to incorporate a menu into our window.
Download the example 1 and example 2.
Theory:
Menu is one of the most important component in your window. Menu presents a list of services a program offers to the user. The user doesn't have to read the manual included with the program to be able to use it, he can peruse the menu to get an overview of the capability of a particular program and start playing with it immediately. Since a menu is a tool to get the user up and running quickly, you should follow the standard. Succintly put, the first two menu items should be File and Edit and the last should be Help. You can insert your own menu items between Edit and Help. If a menu item invokes a dialog box, you should append an ellipsis (...) to the menu string.
Menu is a kind of resource. There are several kinds of resources such as dialog box, string table, icon, bitmap, menu etc. Resources are described in a separated file called a resource file which normally has .rc extension. You then combine the resources with the source code during the link stage. The final product is an executable file which contains both instructions and resources.
You can write resource scripts using any text editor. They're composed of phrases which describe the appearances and other attributes of the resources used in a particular program Although you can write resource scripts with a text editor, it's rather cumbersome. A better alternative is to use a resource editor which lets you visually design resources with ease. Resource editors are usually included in compiler packages such as Visual C++, Borland C++, etc.
You describe a menu resource like this:
 

    MyMenu  MENU
    {
       [menu list here]
    }

C programmers may recognize that it is similar to declaring a structure. MyMenu being a menu name followed by MENU keyword and menu list within curly brackets. Alternatively, you can use BEGIN and END instead of the curly brackets if you wish. This syntax is more palatable to Pascal programmers.
Menu list can be either MENUITEM or POPUP statement.
MENUITEM statement defines a menu bar which doesn't invoke a popup menu when selected.The syntax is as follows:

    MENUITEM "&text", ID [,options]

It begins by MENUITEM keyword followed by the text you want to use as menu bar string. Note the ampersand. It causes the character that follows it to be underlined. Following the text string is the ID of the menu item. The ID is a number that will be used to identify the menu item in the message sent to the window procedure when the menu item is selected. As such, each menu ID must be unique among themselves.
Options are optional. Available options are as follows:

    GRAYED  The menu item is inactive, and it does not generate a WM_COMMAND message. The text is grayed.
    INACTIVE The menu item is inactive, and it does not generate a WM_COMMAND message. The text is displayed normally.
    MENUBREAK  This item and the following items appear on a new line of the menu.
    HELP  This item and the following items are right-justified.

You can use one of the above option or combine them with "or" operator. Beware that INACTIVE and GRAYED cannot be combined together.
POPUP statement has the following syntax:
 

POPUP "&text" [,options]
{
  [menu list]
}

POPUP statement defines a menu bar that, when selected, drops down a list of menu items in a small popup window. The menu list can be a MENUTIEM or POPUP statement. There's a special kind of MENUITEM statement, MENUITEM SEPARATOR, which will draw a horizontal line in the popup window.
The next step after you are finished with the menu resource script is to reference it in your program.
You can do this in two different places in your program.

    In lpszMenuName member of WNDCLASSEX structure. Say, if you have a menu named "FirstMenu", you can assigned the menu to your window like this:
            .DATA
                MenuName  db "FirstMenu",0 ...........................
            ...........................
            .CODE
                ...........................
                mov   wc.lpszMenuName, OFFSET MenuName
                ........................... 
    In menu handle parameter of CreateWindowEx like this:
            .DATA
                MenuName  db "FirstMenu",0
                hMenu HMENU ? ...........................
            ...........................
            .CODE
                ...........................
                invoke LoadMenu, hInst, OFFSET MenuName
                mov   hMenu, eax
                invoke CreateWindowEx,NULL,OFFSET ClsName,\
                            OFFSET Caption, WS_OVERLAPPEDWINDOW,\
                            CW_USEDEFAULT,CW_USEDEFAULT,\
                            CW_USEDEFAULT,CW_USEDEFAULT,\
                            NULL,\
                           hMenu,\
                            hInst,\
                            NULL\
                ........................... 

So you may ask, what's the difference between these two methods?
When you reference the menu in the WNDCLASSEX structure, the menu becomes the "default" menu for the window class. Every window of that class will have the same menu.
If you want each window created from the same class to have different menus, you must choose the second form. In this case, any window that is passed a menu handle in its CreateWindowEx function will have a menu that "overrides" the default menu defined in the WNDCLASSEX structure.
Next we will examine how a menu notifies the window procedure when the user selects a menu item.
When the user selects a menu item, the window procedure will receive a WM_COMMAND message. The low word of wParam contains the menu ID of the selected menu item.
Now we have sufficient information to create and use a menu. Let's do it.
Example:
The first example shows how to create and use a menu by specifying the menu name in the window class.

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
MenuName db "FirstMenu",0                ; The name of our menu in the resource file.
Test_string db "You selected Test menu item",0
Hello_string db "Hello, my friend",0
Goodbye_string db "See you again, bye",0

.data?
hInstance HINSTANCE ?
CommandLine LPSTR ?

.const
IDM_TEST equ 1                    ; Menu IDs
IDM_HELLO equ 2
IDM_GOODBYE equ 3
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
    mov   wc.hbrBackground,COLOR_WINDOW+1
    mov   wc.lpszMenuName,OFFSET MenuName        ; Put our menu name here
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
    .IF uMsg==WM_DESTROY
        invoke PostQuitMessage,NULL
    .ELSEIF uMsg==WM_COMMAND
        mov eax,wParam
        .IF ax==IDM_TEST
            invoke MessageBox,NULL,ADDR Test_string,OFFSET AppName,MB_OK
        .ELSEIF ax==IDM_HELLO
            invoke MessageBox, NULL,ADDR Hello_string, OFFSET AppName,MB_OK
        .ELSEIF ax==IDM_GOODBYE
            invoke MessageBox,NULL,ADDR Goodbye_string, OFFSET AppName, MB_OK
        .ELSE
            invoke DestroyWindow,hWnd
        .ENDIF
    .ELSE
        invoke DefWindowProc,hWnd,uMsg,wParam,lParam
        ret
    .ENDIF
    xor    eax,eax
    ret
WndProc endp
end start
**************************************************************************************************************************
Menu.rc
**************************************************************************************************************************

#define IDM_TEST 1
#define IDM_HELLO 2
#define IDM_GOODBYE 3
#define IDM_EXIT 4

FirstMenu MENU
{
 POPUP "&PopUp"
        {
         MENUITEM "&Say Hello",IDM_HELLO
         MENUITEM "Say &GoodBye", IDM_GOODBYE
         MENUITEM SEPARATOR
         MENUITEM "E&xit",IDM_EXIT
        }
 MENUITEM "&Test", IDM_TEST
}
 
Analysis:
Let's analyze the resource file first.
 

#define IDM_TEST 1                /* equal to IDM_TEST equ 1*/
#define IDM_HELLO 2
#define IDM_GOODBYE 3
#define IDM_EXIT 4
 

The above lines define the menu IDs used by the menu script. You can assign any value to the ID as long as the value is unique in the menu.

FirstMenu MENU

Declare your menu with MENU keyword.

 POPUP "&PopUp"
        {
         MENUITEM "&Say Hello",IDM_HELLO
         MENUITEM "Say &GoodBye", IDM_GOODBYE
         MENUITEM SEPARATOR
         MENUITEM "E&xit",IDM_EXIT
        }

Define a popup menu with four menu items, the third one is a menu separator.

 MENUITEM "&Test", IDM_TEST

Define a menu bar in the main menu.
Next we will examine the source code.
 

MenuName db "FirstMenu",0                ; The name of our menu in the resource file.
Test_string db "You selected Test menu item",0
Hello_string db "Hello, my friend",0
Goodbye_string db "See you again, bye",0
 

MenuName is the name of the menu in the resource file. Note that you can define more than one menu in the resource file so you must specify which menu you want to use. The remaining three lines define the text strings to be displayed in message boxes that are invoked when the appropriate menu item is selected by the user.
 

IDM_TEST equ 1                    ; Menu IDs
IDM_HELLO equ 2
IDM_GOODBYE equ 3
IDM_EXIT equ 4
 

Define menu IDs for use in the window procedure. These values MUST be identical to those defined in the resource file.

    .ELSEIF uMsg==WM_COMMAND
        mov eax,wParam
        .IF ax==IDM_TEST
            invoke MessageBox,NULL,ADDR Test_string,OFFSET AppName,MB_OK
        .ELSEIF ax==IDM_HELLO
            invoke MessageBox, NULL,ADDR Hello_string, OFFSET AppName,MB_OK
        .ELSEIF ax==IDM_GOODBYE
            invoke MessageBox,NULL,ADDR Goodbye_string, OFFSET AppName, MB_OK
        .ELSE
            invoke DestroyWindow,hWnd
        .ENDIF

In the window procedure, we process WM_COMMAND messages. When the user selects a menu item, the menu ID of that menu item is sended to the window procedure in the low word of wParam along with the WM_COMMAND message. So when we store the value of wParam in eax, we compare the value in ax to the menu IDs we defined previously and act accordingly. In the first three cases, when the user selects Test, Say Hello, and Say GoodBye menu items, we just display a text string in a message box.
If the user selects Exit menu item, we call DestroyWindow with the handle of our window as its parameter which will close our window.
As you can see, specifying menu name in a window class is quite easy and straightforward. However you can also use an alternate method to load a menu in your window. I won't show the entire source code here. The resource file is the same in both methods. There are some minor changes in the source file which I 'll show below.
 

.data?
hInstance HINSTANCE ?
CommandLine LPSTR ?
hMenu HMENU ?                    ; handle of our menu
 

Define a variable of type HMENU to store our menu handle.

        invoke LoadMenu, hInst, OFFSET MenuName
        mov    hMenu,eax
        INVOKE CreateWindowEx,NULL,ADDR ClassName,ADDR AppName,\
           WS_OVERLAPPEDWINDOW,CW_USEDEFAULT,\
           CW_USEDEFAULT,CW_USEDEFAULT,CW_USEDEFAULT,NULL,hMenu,\
           hInst,NULL

Before calling CreateWindowEx, we call LoadMenu with the instance handle and a pointer to the name of our menu. LoadMenu returns the handle of our menu in the resource file which we pass to CreateWindowEx.
[Iczelion's Win32 Assembly HomePage]

