+++
authors = [""]
title = "11. More about Dialog Box"
description = ""
date = 2024-07-09
[taxonomies]
tags = ["masm32"]
[extra]
toc = false
+++



We will learn more about dialog box in this tutorial. Specifically, we will explore the topic of how to use dialog boxs as our input-output devices. If you read the previous tutorial, this one will be a breeze since only a minor modification is all that's needed to be able to use dialog boxes as adjuncts to our main window. Also in this tutorial, we will learn how to use common dialog boxes.

Download the dialog box examples here and here. Download Common Dialog Box example here.
Theory:
Very little is to be said about how to use dialog boxes as input-output devices of our program. Your program creates the main window as usual and when you want to display the dialog box, just call CreateDialogParam or DialogBoxParam. With DialogBoxParam call, you don't have to do anything more, just process the messages in the dialog box procedure. With CreateDialogParam, you must insert IsDialogMessage call in the message loop to let dialog box manager handle the keyboard navigation in your dialog box for you. Since the two cases are trivial, I'll not put the source code here. You can download the examples and examine them yourself, here and here.
Let's go on to the common dialog boxes. Windows has prepared predefined dialog boxes for use by your applications. These dialog boxes exist to provide standardized user interface. They consist of file, print, color, font, and search dialog boxes. You should use them as much as possible. The dialog boxes reside in comdlg32.dll. In order to use them, you have to link to comdlg32.lib. You create these dialog boxes by calling appropriate functions in the common dialog library. For open file dialog, it is GetOpenFileName, for save as dialog it is GetSaveFileName, for print dialog it is PrintDlg and so on. Each one of these functions takes a pointer to a structure as its parameter. You should look them up in Win32 API reference. In this tutorial, I'll demonstrate how to create and use an open file dialog.
Below is the function prototype of GetOpenFileName function:
 

    GetOpenFileName proto lpofn:DWORD

You can see that it receives only one parameter, a pointer to an OPENFILENAME structure. The return value TRUE means the user selected a file to open, it's FALSE otherwise. We will look at OPENFILENAME structure next.
 

    OPENFILENAME  STRUCT

         lStructSize DWORD  ?
         hwndOwner HWND  ?
         hInstance HINSTANCE ?
         lpstrFilter LPCSTR  ?
         lpstrCustomFilter LPSTR  ?
         nMaxCustFilter DWORD  ?
         nFilterIndex DWORD  ?
         lpstrFile LPSTR  ?
         nMaxFile DWORD  ?
         lpstrFileTitle LPSTR  ?
         nMaxFileTitle DWORD  ?
         lpstrInitialDir LPCSTR  ?
         lpstrTitle LPCSTR  ?
         Flags  DWORD  ?
         nFileOffset WORD  ?
         nFileExtension WORD  ?
         lpstrDefExt LPCSTR  ?
         lCustData LPARAM  ?
         lpfnHook DWORD  ?
         lpTemplateName LPCSTR  ?

    OPENFILENAME  ENDS

Let's see the meaning of the frequently used members.
 
lStructSize 	The size of the OPENFILENAME structure , in bytes
hwndOwner 	The window handle of the open file dialog box.
hInstance 	Instance handle of the application that creates the open file dialog box
lpstrFilter 	The filter strings in the format of  pairs of null terminated strings. The first string in each pair is the description. The second string is the filter pattern. for example:
     FilterString   db "All Files (*.*)",0, "*.*",0
                            db "Text Files (*.txt)",0,"*.txt",0,0
Note that only the pattern in the second string in each pair is actually used by Windows to filter out the files. Also noted that you have to put an extra 0 at the end of the filter strings to denote the end of it.
nFilterIndex 	Specify which pair of the filter strings will be initially used when the open file dialog is first displayed. The index is 1-based, that is the first pair is 1, the second pair is 2 and so on. So in the above example, if we specify nFilterIndex as 2, the second pattern, "*.txt" will be used.
lpstrFile 	Pointer to the buffer that contains the filename used to initialize the filename edit control on the dialog box. The buffer should be at least 260 bytes long. 
After the user selects a file to open, the filename with full path is stored in this buffer. You can extract the information from it later.
nMaxFile 	The size of the lpstrFile buffer.
lpstrTitle 	Pointer to the title of the open file dialog box
Flags 	Determine the styles and characteristics of the dialog box.
nFileOffset 	After the user selects a file to open, this member contains the index to the first character of the actual filename. For example, if the full name with path is "c:\windows\system\lz32.dll", the this member will contain the value 18.
nFileExtension 	After the user selects a file to open, this member contains the index to the first character of the file extension
Example:
The following program displays an open file dialog box when the user selects File-> Open from the menu. When the user selects a file in the dialog box, the program displays a message box showing the full name, filename,and extension of the selected file.

.386
.model flat,stdcall
option casemap:none
WinMain proto :DWORD,:DWORD,:DWORD,:DWORD
include \masm32\include\windows.inc
include \masm32\include\user32.inc
include \masm32\include\kernel32.inc
include \masm32\include\comdlg32.inc
includelib \masm32\lib\user32.lib
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\comdlg32.lib

.const
IDM_OPEN equ 1
IDM_EXIT equ 2
MAXSIZE equ 260
OUTPUTSIZE equ 512

.data
ClassName db "SimpleWinClass",0
AppName  db "Our Main Window",0
MenuName db "FirstMenu",0
ofn   OPENFILENAME <>
FilterString db "All Files",0,"*.*",0
             db "Text Files",0,"*.txt",0,0
buffer db MAXSIZE dup(0)
OurTitle db "-=Our First Open File Dialog Box=-: Choose the file to open",0
FullPathName db "The Full Filename with Path is: ",0
FullName  db "The Filename is: ",0
ExtensionName db "The Extension is: ",0
OutputString db OUTPUTSIZE dup(0)
CrLf db 0Dh,0Ah,0

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
    mov   wc.lpszMenuName,OFFSET MenuName
    mov   wc.lpszClassName,OFFSET ClassName
    invoke LoadIcon,NULL,IDI_APPLICATION
    mov   wc.hIcon,eax
    mov   wc.hIconSm,eax
    invoke LoadCursor,NULL,IDC_ARROW
    mov   wc.hCursor,eax
    invoke RegisterClassEx, addr wc
    invoke CreateWindowEx,WS_EX_CLIENTEDGE,ADDR ClassName,ADDR AppName,\
           WS_OVERLAPPEDWINDOW,CW_USEDEFAULT,\
           CW_USEDEFAULT,300,200,NULL,NULL,\
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
    .IF uMsg==WM_DESTROY
        invoke PostQuitMessage,NULL
    .ELSEIF uMsg==WM_COMMAND
        mov eax,wParam
        .if ax==IDM_OPEN
            mov ofn.lStructSize,SIZEOF ofn
            push hWnd
            pop  ofn.hwndOwner
            push hInstance
            pop  ofn.hInstance
            mov  ofn.lpstrFilter, OFFSET FilterString
            mov  ofn.lpstrFile, OFFSET buffer
            mov  ofn.nMaxFile,MAXSIZE
            mov  ofn.Flags, OFN_FILEMUSTEXIST or \
                OFN_PATHMUSTEXIST or OFN_LONGNAMES or\
                OFN_EXPLORER or OFN_HIDEREADONLY
            mov  ofn.lpstrTitle, OFFSET OurTitle
            invoke GetOpenFileName, ADDR ofn
            .if eax==TRUE
                invoke lstrcat,offset OutputString,OFFSET FullPathName
                invoke lstrcat,offset OutputString,ofn.lpstrFile
                invoke lstrcat,offset OutputString,offset CrLf
                invoke lstrcat,offset OutputString,offset FullName
                mov  eax,ofn.lpstrFile
                push ebx
                xor  ebx,ebx
                mov  bx,ofn.nFileOffset
                add  eax,ebx
                pop  ebx
                invoke lstrcat,offset OutputString,eax
                invoke lstrcat,offset OutputString,offset CrLf
                invoke lstrcat,offset OutputString,offset ExtensionName
                mov  eax,ofn.lpstrFile
                push ebx
                xor ebx,ebx
                mov  bx,ofn.nFileExtension
                add eax,ebx
                pop ebx
                invoke lstrcat,offset OutputString,eax
                invoke MessageBox,hWnd,OFFSET OutputString,ADDR AppName,MB_OK
                invoke RtlZeroMemory,offset OutputString,OUTPUTSIZE
            .endif
        .else
            invoke DestroyWindow, hWnd
        .endif
    .ELSE
        invoke DefWindowProc,hWnd,uMsg,wParam,lParam
        ret
    .ENDIF
    xor    eax,eax
    ret
WndProc endp
 end start
Analysis:
            mov ofn.lStructSize,SIZEOF ofn
            push hWnd
            pop  ofn.hwndOwner
            push hInstance
            pop  ofn.hInstance

We fill in the routine members of ofn structures.

            mov  ofn.lpstrFilter, OFFSET FilterString

This FilterString is the filename filter that we specify as follows:

    FilterString db "All Files",0,"*.*",0
                 db "Text Files",0,"*.txt",0,0

Note that All four strings are zero terminated. The first string is the description of the following string. The actual pattern is the even number string, in this case, "*.*" and "*.txt". Actually we can specify any pattern we want here. We MUST put an extra zero after the last pattern string to denote the end of the filter string. Don't forget this else your dialog box will behave strangely.

            mov  ofn.lpstrFile, OFFSET buffer
            mov  ofn.nMaxFile,MAXSIZE

We specify where the dialog box will put the filename that the user selects. Note that we must specify its size in nMaxFile member. We can later extract the filename from this buffer.

            mov  ofn.Flags, OFN_FILEMUSTEXIST or \
                OFN_PATHMUSTEXIST or OFN_LONGNAMES or\
                OFN_EXPLORER or OFN_HIDEREADONLY

Flags specifies the characteristics of the dialog box.
OFN_FILEMUSTEXIST  and OFN_PATHMUSTEXIST flags demand that the filename and path that the user types in the filename edit control MUST exist.
OFN_LONGNAMES flag tells the dialog box to show long filenames.
OFN_EXPLORER flag specifies that the appearance of the dialog box must be explorer-like.
OFN_HIDEREADONLY flag hides the read-only checkbox on the dialog box.
There are many more flags that you can use. Consult your Win32 API reference.

            mov  ofn.lpstrTitle, OFFSET OurTitle

Specify the title of the dialog box.

            invoke GetOpenFileName, ADDR ofn

Call the GetOpenFileName function. Passing the pointer to the ofn structure as its parameter.
At this time, the open file dialog box is displayed on the screen. The function will not return until the user selects a file to open or presses the cancel button or closes the dialog box.
It 'll return the value TRUE in eax if the user selects a file to open. It returns FALSE otherwise.

            .if eax==TRUE
                invoke lstrcat,offset OutputString,OFFSET FullPathName
                invoke lstrcat,offset OutputString,ofn.lpstrFile
                invoke lstrcat,offset OutputString,offset CrLf
                invoke lstrcat,offset OutputString,offset FullName

In case the user selects a file to open, we prepare an output string to be displayed in a message box. We allocate a block of memory in OutputString variable and then we use an API function, lstrcat, to concatenate the strings together. In order to put the strings into several lines, we must separate each line with a carriage return-line feed pair.

                mov  eax,ofn.lpstrFile
                push ebx
                xor  ebx,ebx
                mov  bx,ofn.nFileOffset
                add  eax,ebx
                pop  ebx
                invoke lstrcat,offset OutputString,eax

The above lines require some explanation. nFileOffset contains the index into the ofn.lpstrFile. But you cannot add them together directly since nFileOffset is a WORD-sized variable and lpstrFile is a DWORD-sized one. So I have to put the value of nFileOffset into the low word of ebx and add it to the value of lpstrFile.

                invoke MessageBox,hWnd,OFFSET OutputString,ADDR AppName,MB_OK

We display the string in a message box.

                invoke RtlZerolMemory,offset OutputString,OUTPUTSIZE

We must *clear* the OutputString before we can fill in another string. So we use RtlZeroMemory function to do the job.
[Iczelion's Win32 Assembly HomePage]
