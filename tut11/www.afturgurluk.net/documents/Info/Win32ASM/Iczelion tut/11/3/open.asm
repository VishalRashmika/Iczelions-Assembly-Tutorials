include windows.inc
includelib user32.lib
includelib kernel32.lib
includelib gdi32.lib
includelib comdlg32.lib

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
        push  hInstance
        pop   wc.hInstance
        mov   wc.hbrBackground,COLOR_WINDOW+1
        mov   wc.lpszMenuName,OFFSET MenuName
	mov   wc.lpszClassName,OFFSET ClassName
        invoke LoadIcon,NULL,IDI_APPLICATION
	mov   wc.hIcon,eax
        mov   wc.hIconSm,0
        invoke LoadCursor,NULL,IDC_ARROW
	mov   wc.hCursor,eax
        invoke RegisterClassEx, addr wc
        INVOKE CreateWindowEx,WS_EX_CLIENTEDGE,ADDR ClassName,ADDR AppName,\
           WS_OVERLAPPEDWINDOW,CW_USEDEFAULT,\
           CW_USEDEFAULT,300,200,NULL,NULL,\
           hInst,NULL
        mov   hwnd,eax
        INVOKE ShowWindow, hwnd,SW_SHOWNORMAL
        INVOKE UpdateWindow, hwnd
        .WHILE TRUE
                INVOKE GetMessage, ADDR msg,NULL,0,0
                .BREAK .IF (!eax)
                INVOKE TranslateMessage, ADDR msg
                INVOKE DispatchMessage, ADDR msg
        .ENDW
        mov     eax,msg.wParam
        ret
WinMain endp
WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
	mov   eax,uMsg
	.IF eax==WM_DESTROY
		invoke PostQuitMessage,NULL
        .ELSEIF eax==WM_COMMAND
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
                                invoke FillMemory,offset OutputString,OUTPUTSIZE,0
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
