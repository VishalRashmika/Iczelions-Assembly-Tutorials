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

.data
ClassName db "Win32ASMFileMappingClass",0
AppName  db "Win32 ASM File Mapping Example",0
MenuName db "FirstMenu",0
ofn   OPENFILENAME <>
FilterString db "All Files",0,"*.*",0
             db "Text Files",0,"*.txt",0,0
buffer db MAXSIZE dup(0)
hMapFile HANDLE 0

.data?
hInstance HINSTANCE ?
CommandLine LPSTR ?
hFileRead HANDLE ?
hFileWrite HANDLE ?
hMenu HANDLE ?
pMemory DWORD ?
SizeWritten DWORD ?

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
	.IF uMsg==WM_CREATE
		invoke GetMenu,hWnd
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
					mov  hMapFile,eax
					mov    eax,OFFSET buffer
					movzx  edx,ofn.nFileOffset
					add    eax,edx
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
