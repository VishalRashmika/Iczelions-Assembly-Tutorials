+++
authors = [""]
title = "12. Memory Management and File I/O"
description = ""
date = 2024-07-09
[taxonomies]
tags = ["masm32"]
[extra]
toc = false
+++



We will learn the rudimentary of memory management and file i/o operation in this tutorial. In addition we'll use common dialog boxes as input-output devices.

Download the example here.
Theory:
Memory management under Win32 from the application's point of view is quite simple and straightforward. Each process owns a 4 GB memory address space. The memory model used is called flat memory model. In this model, all segment registers (or selectors) point to the same starting address and the offset is 32-bit so an application can access memory at any point in its own address space without the need to change the value of selectors. This simplifies memory management a lot. There's no "near" or "far" pointer anymore.
Under Win16, there are two main categories of memory API functions: Global and Local. Global-type API calls deal with memory allocated in other segments thus they're "far" memory functions. Local-type API calls deal with the local heap of the process so they're "near" memory functions. Under Win32, these two types are identical. Whether you call GlobalAlloc or LocalAlloc, you get the same result.
Steps in allocating and using memory are as follows:

    Allocate a block of memory by calling GlobalAlloc. This function returns a handle to the requested memory block.
    "Lock" the memory block by calling GlobalLock. This function accepts a handle to the memory block and returns a pointer to the memory block.
    You can use the pointer to read or write memory.
    "Unlock" the memory block by calling GlobalUnlock . This function invalidates the pointer to the memory block.
    Free the memory block by calling GlobalFree. This function accepts the handle to the memory block.

You can also substitute "Global" by "Local" such as LocalAlloc, LocalLock,etc.
The above method can be further simplified by using a flag in GlobalAlloc call, GMEM_FIXED. If you use this flag, the return value from Global/LocalAlloc will be the pointer to the allocated memory block, not the memory block handle. You don't have to call Global/LocalLock and you can pass the pointer to Global/LocalFree without calling Global/LocalUnlock first. But in this tutorial, I'll use the "traditional" approach since you may encounter it when reading the source code of other programs.

File I/O under Win32 bears remarkable semblance to that under DOS. The steps needed are the same. You only have to change interrupts to API calls and it's done. The required steps are the followings:
 

    Open or Create the file by calling CreateFile function. This function is very versatile: in addition to files, it can open communication ports, pipes, disk drives or console. On success, it returns a handle to file or device. You can then use this handle to perform operations on the file or device.

    Move the file pointer to the desired location by calling SetFilePointer.
    Perform read or write operation by calling ReadFile or WriteFile. These functions transfer data from a block of memory to or from the file. So you have to allocate a block of memory large enough to hold the data.
    Close the file by calling CloseHandle. This function accepts the file handle.

Content:
The program listed below displays an open file dialog box. It lets the user select a text file to open and shows the content of that file in an edit control in its client area. The user can modify the text in the edit control as he wishes, and can choose to save the content in a file.

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
IDM_SAVE equ 2
IDM_EXIT equ 3
MAXSIZE equ 260
MEMSIZE equ 65535

EditID equ 1                            ; ID of the edit control

.data
ClassName db "Win32ASMEditClass",0
AppName  db "Win32 ASM Edit",0
EditClass db "edit",0
MenuName db "FirstMenu",0
ofn   OPENFILENAME <>
FilterString db "All Files",0,"*.*",0
             db "Text Files",0,"*.txt",0,0
buffer db MAXSIZE dup(0)

.data?
hInstance HINSTANCE ?
CommandLine LPSTR ?
hwndEdit HWND ?                               ; Handle to the edit control
hFile HANDLE ?                                   ; File handle
hMemory HANDLE ?                            ;handle to the allocated memory block
pMemory DWORD ?                            ;pointer to the allocated memory block
SizeReadWrite DWORD ?                   ; number of bytes actually read or write

.code
start:
    invoke GetModuleHandle, NULL
    mov    hInstance,eax
    invoke GetCommandLine
    mov CommandLine,eax
    invoke WinMain, hInstance,NULL,CommandLine, SW_SHOWDEFAULT
    invoke ExitProcess,eax

WinMain proc hInst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:SDWORD
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

WndProc proc uses ebx hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
    .IF uMsg==WM_CREATE
        invoke CreateWindowEx,NULL,ADDR EditClass,NULL,\
                   WS_VISIBLE or WS_CHILD or ES_LEFT or ES_MULTILINE or\
                   ES_AUTOHSCROLL or ES_AUTOVSCROLL,0,\
                   0,0,0,hWnd,EditID,\
                   hInstance,NULL
        mov hwndEdit,eax
        invoke SetFocus,hwndEdit
;==============================================
;        Initialize the members of OPENFILENAME structure
;==============================================
        mov ofn.lStructSize,SIZEOF ofn
        push hWnd
        pop  ofn.hWndOwner
        push hInstance
        pop  ofn.hInstance
        mov  ofn.lpstrFilter, OFFSET FilterString
        mov  ofn.lpstrFile, OFFSET buffer
        mov  ofn.nMaxFile,MAXSIZE
    .ELSEIF uMsg==WM_SIZE
        mov eax,lParam
        mov edx,eax
        shr edx,16
        and eax,0ffffh
        invoke MoveWindow,hwndEdit,0,0,eax,edx,TRUE
    .ELSEIF uMsg==WM_DESTROY
        invoke PostQuitMessage,NULL
    .ELSEIF uMsg==WM_COMMAND
        mov eax,wParam
        .if lParam==0
            .if ax==IDM_OPEN
                mov  ofn.Flags, OFN_FILEMUSTEXIST or \
                                OFN_PATHMUSTEXIST or OFN_LONGNAMES or\
                                OFN_EXPLORER or OFN_HIDEREADONLY
                invoke GetOpenFileName, ADDR ofn
                .if eax==TRUE
                    invoke CreateFile,ADDR buffer,\
                                GENERIC_READ or GENERIC_WRITE ,\
                                FILE_SHARE_READ or FILE_SHARE_WRITE,\
                                NULL,OPEN_EXISTING,FILE_ATTRIBUTE_ARCHIVE,\
                                NULL
                    mov hFile,eax
                    invoke GlobalAlloc,GMEM_MOVEABLE or GMEM_ZEROINIT,MEMSIZE
                    mov  hMemory,eax
                    invoke GlobalLock,hMemory
                    mov  pMemory,eax
                    invoke ReadFile,hFile,pMemory,MEMSIZE-1,ADDR SizeReadWrite,NULL
                    invoke SendMessage,hwndEdit,WM_SETTEXT,NULL,pMemory
                    invoke CloseHandle,hFile
                    invoke GlobalUnlock,pMemory
                    invoke GlobalFree,hMemory
                .endif
                invoke SetFocus,hwndEdit
            .elseif ax==IDM_SAVE
                mov ofn.Flags,OFN_LONGNAMES or\
                                OFN_EXPLORER or OFN_HIDEREADONLY
                invoke GetSaveFileName, ADDR ofn
                    .if eax==TRUE
                        invoke CreateFile,ADDR buffer,\
                                                GENERIC_READ or GENERIC_WRITE ,\
                                                FILE_SHARE_READ or FILE_SHARE_WRITE,\
                                                NULL,CREATE_NEW,FILE_ATTRIBUTE_ARCHIVE,\
                                                NULL
                        mov hFile,eax
                        invoke GlobalAlloc,GMEM_MOVEABLE or GMEM_ZEROINIT,MEMSIZE
                        mov  hMemory,eax
                        invoke GlobalLock,hMemory
                        mov  pMemory,eax
                        invoke SendMessage,hwndEdit,WM_GETTEXT,MEMSIZE-1,pMemory
                        invoke WriteFile,hFile,pMemory,eax,ADDR SizeReadWrite,NULL
                        invoke CloseHandle,hFile
                        invoke GlobalUnlock,pMemory
                        invoke GlobalFree,hMemory
                    .endif
                    invoke SetFocus,hwndEdit
                .else
                    invoke DestroyWindow, hWnd
                .endif
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
        invoke CreateWindowEx,NULL,ADDR EditClass,NULL,\
                   WS_VISIBLE or WS_CHILD or ES_LEFT or ES_MULTILINE or\
                   ES_AUTOHSCROLL or ES_AUTOVSCROLL,0,\
                   0,0,0,hWnd,EditID,\
                   hInstance,NULL
        mov hwndEdit,eax

In WM_CREATE section, we create an edit control. Note that the parameters that specify x, y, width,height of the control are all zeroes since we will resize the control later to cover the whole client area of the parent window.
Note that in this case, we don't have to call ShowWindow to make the edit control appear on the screen because we include WS_VISIBLE style. You can use this trick in the parent window too.

;==============================================
;        Initialize the members of OPENFILENAME structure
;==============================================
        mov ofn.lStructSize,SIZEOF ofn
        push hWnd
        pop  ofn.hWndOwner
        push hInstance
        pop  ofn.hInstance
        mov  ofn.lpstrFilter, OFFSET FilterString
        mov  ofn.lpstrFile, OFFSET buffer
        mov  ofn.nMaxFile,MAXSIZE

After creating the edit control, we take this time to initialize the members of ofn. Because we want to reuse ofn in the save as dialog box too, we fill in only the *common* members that're used by both GetOpenFileName and GetSaveFileName.
WM_CREATE section is a great place to do once-only initialization.

    .ELSEIF uMsg==WM_SIZE
        mov eax,lParam
        mov edx,eax
        shr edx,16
        and eax,0ffffh
        invoke MoveWindow,hwndEdit,0,0,eax,edx,TRUE

We receive WM_SIZE messages when the size of the client area of our main window changes. We also receive it when the window is first created. In order to be able to receive this message, the window class styles must include CS_VREDRAW and CS_HREDRAW styles. We use this opportunity to resize our edit control to the same size as the client area of the parent window. First we have to know the current width and height of the client area of the parent window. We get this info from lParam. The high word of lParam contains the height and the low word of lParam the width of the client area. We then use the information to resize the edit control by calling MoveWindow function which, in addition to changing the position of the window, can alter the size too.

            .if ax==IDM_OPEN
                mov  ofn.Flags, OFN_FILEMUSTEXIST or \
                                OFN_PATHMUSTEXIST or OFN_LONGNAMES or\
                                OFN_EXPLORER or OFN_HIDEREADONLY
                invoke GetOpenFileName, ADDR ofn

When the user selects File/Open menu item, we fill in the Flags member of ofn structure and call GetOpenFileName function to display the open file dialog box.

                .if eax==TRUE
                    invoke CreateFile,ADDR buffer,\
                                GENERIC_READ or GENERIC_WRITE ,\
                                FILE_SHARE_READ or FILE_SHARE_WRITE,\
                                NULL,OPEN_EXISTING,FILE_ATTRIBUTE_ARCHIVE,\
                                NULL
                    mov hFile,eax

After the user selects a file to open, we call CreateFile to open the file. We specifies that the function should try to open the file for read and write. After the file is opened, the function returns the handle to the opened file which we store in a global variable for future use. This function has the following syntax:

CreateFile proto lpFileName:DWORD,\
                           dwDesiredAccess:DWORD,\
                           dwShareMode:DWORD,\
                           lpSecurityAttributes:DWORD,\
                           dwCreationDistribution:DWORD\,
                           dwFlagsAndAttributes:DWORD\,
                           hTemplateFile:DWORD

dwDesiredAccess specifies which operation you want to perform on the file.

    0  Open the file to query its attributes. You have to rights to read or write the data.
    GENERIC_READ   Open the file for reading.
    GENERIC_WRITE  Open the file for writing.

dwShareMode specifies which operation you want to allow other processes to perform on the file that 's being opened.

    0  Don't share the file with other processes.
    FILE_SHARE_READ  allow other processes to read the data from the file being opened
    FILE_SHARE_WRITE  allow other processes to write data to the file being opened.

lpSecurityAttributes has no significance under Windows 95.
dwCreationDistribution specifies the action CreateFile will perform when the file specified in lpFileName exists or when it doesn't exist.

    CREATE_NEW Creates a new file. The function fails if the specified file already exists.
    CREATE_ALWAYS Creates a new file. The function overwrites the file if it exists.
    OPEN_EXISTING Opens the file. The function fails if the file does not exist.
    OPEN_ALWAYS Opens the file, if it exists. If the file does not exist, the function creates the file as if dwCreationDistribution were CREATE_NEW.
    TRUNCATE_EXISTING Opens the file. Once opened, the file is truncated so that its size is zero bytes. The calling process must open the file with at least GENERIC_WRITE access. The function fails if the file does not exist.

dwFlagsAndAttributes specifies the file attributes

    FILE_ATTRIBUTE_ARCHIVE The file is an archive file. Applications use this attribute to mark files for backup or removal.
    FILE_ATTRIBUTE_COMPRESSED The file or directory is compressed. For a file, this means that all of the data in the file is compressed. For a directory, this means that compression is the default for newly created files and subdirectories.
    FILE_ATTRIBUTE_NORMAL The file has no other attributes set. This attribute is valid only if used alone.
    FILE_ATTRIBUTE_HIDDEN The file is hidden. It is not to be included in an ordinary directory listing.
    FILE_ATTRIBUTE_READONLY The file is read only. Applications can read the file but cannot write to it or delete it.
    FILE_ATTRIBUTE_SYSTEM The file is part of or is used exclusively by the operating system.

                    invoke GlobalAlloc,GMEM_MOVEABLE or GMEM_ZEROINIT,MEMSIZE
                    mov  hMemory,eax
                    invoke GlobalLock,hMemory
                    mov  pMemory,eax

When the file is opened, we allocate a block of memory for use by ReadFile and WriteFile functions. We specify GMEM_MOVEABLE flag  to let Windows move the memory block around to consolidate memory. GMEM_ZEROINIT flag tells GlobalAlloc to fill the newly allocated memory block with zeroes.
When GlobalAlloc returns successfully, eax contains the handle to the allocated memory block. We pass this handle to GlobalLock function which returns a pointer to the memory block.

                    invoke ReadFile,hFile,pMemory,MEMSIZE-1,ADDR SizeReadWrite,NULL
                    invoke SendMessage,hwndEdit,WM_SETTEXT,NULL,pMemory

When the memory block is ready for use, we call ReadFile function to read data from the file. When a file is first opened or created, the file pointer is at offset 0. So in this case, we start reading from the first byte in the file onwards. The first parameter of ReadFile is the handle of the file to read, the second is the pointer to the memory block to hold the data, next is the number of bytes to read from the file, the fourth param is the address of the variable of DWORD size that will be filled with the number of bytes actually read from the file.
After we fill the memory block with the data, we put the data into the edit control by sending WM_SETTEXT message to the edit control with lParam containing the pointer to the memory block. After this call, the edit control shows the data in its client area.

                    invoke CloseHandle,hFile
                    invoke GlobalUnlock,pMemory
                    invoke GlobalFree,hMemory
                .endif

At this point, we have no need to keep the file open any longer since our purpose is to write the modified data from the edit control to another file, not the original file. So we close the file by calling CloseHandle with the file handle as its parameter. Next we unlock the memory block and free it. Actually you don't have to free the memory at this point, you can reuse the memory block during the save operation later. But for demonstration purpose , I choose to free it here.

                invoke SetFocus,hwndEdit

When the open file dialog box is displayed on the screen, the input focus shifts to it. So after the open file dialog is closed, we must move the input focus back to the edit control.
This end the read operation on the file. At this point, the user can edit the content of the edit control.And when he wants to save the data to another file, he must select File/Save as menuitem which displays a save as dialog box. The creation of the save as dialog box is not much different from the open file dialog box. In fact, they differ in only the name of the functions, GetOpenFileName and GetSaveFileName. You can reuse most members of the ofn structure too except the Flags member.

                mov ofn.Flags,OFN_LONGNAMES or\
                                OFN_EXPLORER or OFN_HIDEREADONLY

In our case, we want to create a new file, so OFN_FILEMUSTEXIST and OFN_PATHMUSTEXIST must be left out else the dialog box will not let us create a file that doesn't already exist.
The dwCreationDistribution parameter of the CreateFile function must be changed to CREATE_NEW since we want to create a new file.
The remaining code is identical to those in the open file section except the following:

                        invoke SendMessage,hwndEdit,WM_GETTEXT,MEMSIZE-1,pMemory
                        invoke WriteFile,hFile,pMemory,eax,ADDR SizeReadWrite,NULL

We send WM_GETTEXT message to the edit control to copy the data from it to the memory block we provide, the return value in eax is the length of the data inside the buffer. After the data is in the memory block, we write them to the new file.
[Iczelion's Win32 Assembly HomePage]
