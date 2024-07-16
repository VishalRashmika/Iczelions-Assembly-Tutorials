+++
authors = [""]
title = "13. Memory Mapped Files"
description = ""
date = 2024-07-09
[taxonomies]
tags = ["masm32"]
[extra]
toc = false
+++

I'll show you what memory mapped files are and how to use them to your advantages. Using a memory mapped file is quite easy as you'll see in this tutorial.

Download the example here.
Theory:
If you examine the example in the previous tutorial closely, you'll find that it has a serious shortcoming: what if the file you want to read is larger than the allocated memory block? or what if the string you want to search for is cut off in half at the end of the memory block? The traditional answer for the first question is that you should repeatedly read in the data from the file until the end of file is encountered. The answer to the second question is that you should prepare for the special case at the end of the memory block. This is called a boundary value problem. It presents headaches to programmers and causes innumerable bugs.
It would be nice if we can allocate a very large block of memory, enough to store the whole file but our program would be a resource hog. File mapping to the rescue. By using file mapping, you can think of the whole file as being already loaded into memory and you can use a memory pointer to read or write data from the file. As easy as that. No need to use memory API functions and separate File I/O API functions anymore, they are one and the same under file mapping. File mapping is also used as a means to share data between processes. Using file mapping in this way, there's no actual file involved. It's more like a reserved memory block that every process can *see*. But sharing data between processes is a delicate subject, not to be treated lightly. You have to implement process and thread synchronization else your applications will crash in very short order.
We will not touch the subject of file mapping as a means to create a shared memory region in this tutorial. We'll concentrate on how to use file mapping as a means to "map" a file into memory. In fact, the PE loader uses file mapping to load executable files into memory. It is very convenient since only the necessary portions can be selectively read from the file on the disk. Under Win32, you should use file mapping as much as possible.
There are some limitation to file mapping though. Once you create a memory mapped file, its size cannot be changed during that session. So file mapping is great for read-only files or file operations that don't affect the file size. That doesn't mean that you cannot use file mapping if you want to increase the file size. You can estimate the new size and create the memory mapped file based on the new size and the file will grow to that size. It's just inconvenient, that's all.
Enough for the explanation. Let's dive into implementation of file mapping. In order to use file mapping, these steps must be performed:

    call CreateFile to open the file you want to map.
    call CreateFileMapping with the file handle returned by CreateFile as one of its parameter. This function creates a file mapping object from the file opened by CreateFile.
    call MapViewOfFile to map a selected file region or the whole file to memory. This function returns a pointer to the first byte of the mapped file region.
    Use the pointer to read or write the file
    call UnmapViewOfFile to unmap the file.
    call CloseHandle with the handle to the mapped file as the parameter to close the mapped file.
    call CloseHandle again this time with the file handle returned by CreateFile to close the actual file.

Example:
The program listed below lets you open a file via an open file dialog box. It opens the file using file mapping, if it's successful, the window caption is changed to the name of the opened file. You can save the file in another name by select File/Save as menuitem. The program will copy the whole content of the opened file to the new file. Note that you don't have to call GlobalAlloc to allocate a memory block in this program.

.386
.model flat,stdcall
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

.data
ClassName db "Win32ASMFileMappingClass",0
AppName  db "Win32 ASM File Mapping Example",0
MenuName db "FirstMenu",0
ofn   OPENFILENAME <>
FilterString db "All Files",0,"*.*",0
             db "Text Files",0,"*.txt",0,0
buffer db MAXSIZE dup(0)
hMapFile HANDLE 0                            ; Handle to the memory mapped file, must be
                                                                    ;initialized with 0 because we also use it as
                                                                    ;a flag in WM_DESTROY section too

.data?
hInstance HINSTANCE ?
CommandLine LPSTR ?
hFileRead HANDLE ?                               ; Handle to the source file
hFileWrite HANDLE ?                                ; Handle to the output file
hMenu HANDLE ?
pMemory DWORD ?                                 ; pointer to the data in the source file
SizeWritten DWORD ?                               ; number of bytes actually written by WriteFile

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
    invoke CreateWindowEx,WS_EX_CLIENTEDGE,ADDR ClassName,\
                ADDR AppName, WS_OVERLAPPEDWINDOW,CW_USEDEFAULT,\
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
    .IF uMsg==WM_CREATE
        invoke GetMenu,hWnd                       ;Obtain the menu handle
        mov  hMenu,eax
        mov ofn.lStructSize,SIZEOF ofn
        push hWnd
        pop  ofn.hWndOwner
        push hInstance
        pop  ofn.hInstance
        mov  ofn.lpstrFilter, OFFSET FilterString
        mov  ofn.lpstrFile, OFFSET buffer
        mov  ofn.nMaxFile,MAXSIZE
    .ELSEIF uMsg==WM_DESTROY
        .if hMapFile!=0
            call CloseMapFile
        .endif
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
                                                GENERIC_READ ,\
                                                0,\
                                                NULL,OPEN_EXISTING,FILE_ATTRIBUTE_ARCHIVE,\
                                                NULL
                    mov hFileRead,eax
                    invoke CreateFileMapping,hFileRead,NULL,PAGE_READONLY,0,0,NULL
                    mov     hMapFile,eax
                    mov     eax,OFFSET buffer
                    movzx  edx,ofn.nFileOffset
                    add      eax,edx
                    invoke SetWindowText,hWnd,eax
                    invoke EnableMenuItem,hMenu,IDM_OPEN,MF_GRAYED
                    invoke EnableMenuItem,hMenu,IDM_SAVE,MF_ENABLED
                .endif
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
                    mov hFileWrite,eax
                    invoke MapViewOfFile,hMapFile,FILE_MAP_READ,0,0,0
                    mov pMemory,eax
                    invoke GetFileSize,hFileRead,NULL
                    invoke WriteFile,hFileWrite,pMemory,eax,ADDR SizeWritten,NULL
                    invoke UnmapViewOfFile,pMemory
                    call   CloseMapFile
                    invoke CloseHandle,hFileWrite
                    invoke SetWindowText,hWnd,ADDR AppName
                    invoke EnableMenuItem,hMenu,IDM_OPEN,MF_ENABLED
                    invoke EnableMenuItem,hMenu,IDM_SAVE,MF_GRAYED
                .endif
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

CloseMapFile PROC
        invoke CloseHandle,hMapFile
        mov    hMapFile,0
        invoke CloseHandle,hFileRead
        ret
CloseMapFile endp

end start
 
Analysis:
                    invoke CreateFile,ADDR buffer,\
                                                GENERIC_READ ,\
                                                0,\
                                                NULL,OPEN_EXISTING,FILE_ATTRIBUTE_ARCHIVE,\
                                                NULL

When the user selects a file in the open file dialog, we call CreateFile to open it. Note that we specify GENERIC_READ to open this file for read-only access and dwShareMode is zero because we don't want some other process to modify the file during our operation.

                    invoke CreateFileMapping,hFileRead,NULL,PAGE_READONLY,0,0,NULL

Then we call CreateFileMapping to create a memory mapped file from the opened file. CreateFileMapping has the following syntax:

CreateFileMapping proto hFile:DWORD,\
                                         lpFileMappingAttributes:DWORD,\
                                         flProtect:DWORD,\
                                         dwMaximumSizeHigh:DWORD,\
                                         dwMaximumSizeLow:DWORD,\
                                         lpName:DWORD

You should know first that CreateFileMapping doesn't have to map the whole file to memory. You can use this function to map only a part of the actual file to memory. You specify the size of the memory mapped file in dwMaximumSizeHigh and dwMaximumSizeLow params. If you specify the size that 's larger than the actual file, the actual file will be expanded to the new size. If you want the memory mapped file to be the same size as the actual file, put zeroes in both params.
You can use NULL in lpFileMappingAttributes parameter to have Windows creates a memory mapped file with default security attributes.
flProtect defines the protection desired for the memory mapped file. In our example, we use PAGE_READONLY to allow only read operation on the memory mapped file. Note that this attribute must not contradict the attribute used in CreateFile else CreateFileMapping will fail.
lpName points to the name of the memory mapped file. If you want to share this file with other process, you must provide it a name. But in our example, our process is the only one that uses this file so we ignore this parameter.

                    mov     eax,OFFSET buffer
                    movzx  edx,ofn.nFileOffset
                    add      eax,edx
                    invoke SetWindowText,hWnd,eax

If CreateFileMapping is successful, we change the window caption to the name of the opened file. The filename with full path is stored in buffer, we want to display only the filename in the caption so we must add the value of nFileOffset member of the OPENFILENAME structure to the address of buffer.

                    invoke EnableMenuItem,hMenu,IDM_OPEN,MF_GRAYED
                    invoke EnableMenuItem,hMenu,IDM_SAVE,MF_ENABLED

As a precaution, we don't want the user to open multiple files at once, so we gray out the Open menu item and enable the Save menu item. EnableMenuItem is used to change the attribute of menu item.
After this, we wait for the user to select File/Save as menu item or close our program. If the user chooses to close our program, we must close the memory mapped file and the actual file like the code below:

    .ELSEIF uMsg==WM_DESTROY
        .if hMapFile!=0
            call CloseMapFile
        .endif
        invoke PostQuitMessage,NULL

In the above code snippet, when the window procedure receives the WM_DESTROY message, it checks the value of hMapFile first whether it is zero or not. If it's not zero, it calls CloseMapFile function which contains the following code:

CloseMapFile PROC
        invoke CloseHandle,hMapFile
        mov    hMapFile,0
        invoke CloseHandle,hFileRead
        ret
CloseMapFile endp

CloseMapFile closes the memory mapped file and the actual file so that there 'll be no resource leakage when our program exits to Windows.
If the user chooses to save that data to another file, the program presents him with a save as dialog box. After he types in the name of the new file, the file is created by CreateFile function.

                    invoke MapViewOfFile,hMapFile,FILE_MAP_READ,0,0,0
                    mov pMemory,eax

Immediately after the output file is created, we call MapViewOfFile to map the desired portion of the memory mapped file into memory. This function has the following syntax:

MapViewOfFile proto hFileMappingObject:DWORD,\
                                   dwDesiredAccess:DWORD,\
                                   dwFileOffsetHigh:DWORD,\
                                   dwFileOffsetLow:DWORD,\
                                   dwNumberOfBytesToMap:DWORD

dwDesiredAccess specifies what operation we want to do to the file. In our example, we want to read the data only so we use FILE_MAP_READ.
dwFileOffsetHigh and dwFileOffsetLowspecify the starting file offset of the file portion that you want to map into memory. In our case, we want to read in the whole file so we start mapping from offset 0 onwards.
dwNumberOfBytesToMap specifies the number of bytes to map into memory. If you want to map the whole file (specified by CreateFileMapping), pass 0 to MapViewOfFile.
After calling MapViewOfFile, the desired portion is loaded into memory. You'll be given the pointer to the memory block that contains the data from the file.

                    invoke GetFileSize,hFileRead,NULL

Find out how large the file is. The file size is returned in eax. If the file is larger than 4 GB,  the high DWORD of the file size is stored in FileSizeHighWord. Since we don't expect to handle such large file, we can ignore it.

                    invoke WriteFile,hFileWrite,pMemory,eax,ADDR SizeWritten,NULL

Write the data that is mapped into memory into the output file.

                    invoke UnmapViewOfFile,pMemory

When we're through with the input file, unmap it from memory.

                    call   CloseMapFile
                    invoke CloseHandle,hFileWrite

And close all the files.

                    invoke SetWindowText,hWnd,ADDR AppName

Restore the original caption text.

                    invoke EnableMenuItem,hMenu,IDM_OPEN,MF_ENABLED
                    invoke EnableMenuItem,hMenu,IDM_SAVE,MF_GRAYED

Enable the Open menu item and gray out the Save As menu item.
[Iczelion's Win32 Assembly HomePage]
