.386
.model flat,stdcall
option casemap:none
include \masm32\include\windows.inc
include \masm32\include\user32.inc
include \masm32\include\comdlg32.inc
include \masm32\include\gdi32.inc
include \masm32\include\kernel32.inc
includelib \masm32\lib\gdi32.lib
includelib \masm32\lib\comdlg32.lib
includelib \masm32\lib\user32.lib
includelib \masm32\lib\kernel32.lib

WinMain proto :DWORD,:DWORD,:DWORD,:DWORD

.const
IDR_MAINMENU                   equ 101
IDM_OPEN                      equ  40001
IDM_SAVE                       equ 40002
IDM_CLOSE                      equ 40003
IDM_SAVEAS                     equ 40004
IDM_EXIT                       equ 40005
IDM_COPY                      equ  40006
IDM_CUT                       equ  40007
IDM_PASTE                      equ 40008
IDM_DELETE                     equ 40009
IDM_SELECTALL                  equ 40010
IDM_OPTION 			equ 40011
IDM_UNDO			equ 40012
IDM_REDO			equ 40013
IDD_OPTIONDLG                  equ 101
IDC_BACKCOLORBOX               equ 1000
IDC_TEXTCOLORBOX               equ 1001

RichEditID 			equ 300

.data
ClassName db "IczEditClass",0
AppName  db "IczEdit version 1.0",0
RichEditDLL db "riched20.dll",0
RichEditClass db "RichEdit20A",0
NoRichEdit db "Cannot find riched20.dll",0
ASMFilterString 		db "ASM Source code (*.asm)",0,"*.asm",0
				db "All Files (*.*)",0,"*.*",0,0
OpenFileFail db "Cannot open the file",0
WannaSave db "The data in the control is modified. Want to save it?",0
FileOpened dd FALSE
BackgroundColor dd 0FFFFFFh		; default to white
TextColor dd 0		; default to black

.data?
hInstance dd ?
hRichEdit dd ?
hwndRichEdit dd ?
FileName db 256 dup(?)
AlternateFileName db 256 dup(?)
CustomColors dd 16 dup(?)

.code
start:
	invoke GetModuleHandle, NULL
	mov    hInstance,eax
	invoke LoadLibrary,addr RichEditDLL
	.if eax!=0
		mov hRichEdit,eax
		invoke WinMain, hInstance,0,0, SW_SHOWDEFAULT
		invoke FreeLibrary,hRichEdit
	.else
		invoke MessageBox,0,addr NoRichEdit,addr AppName,MB_OK or MB_ICONERROR
	.endif
	invoke ExitProcess,eax
	
WinMain proc hInst:DWORD,hPrevInst:DWORD,CmdLine:DWORD,CmdShow:DWORD
	LOCAL wc:WNDCLASSEX
	LOCAL msg:MSG
	LOCAL hwnd:DWORD
	mov   wc.cbSize,SIZEOF WNDCLASSEX
	mov   wc.style, CS_HREDRAW or CS_VREDRAW
	mov   wc.lpfnWndProc, OFFSET WndProc
	mov   wc.cbClsExtra,NULL
	mov   wc.cbWndExtra,NULL
	push  hInst
	pop   wc.hInstance
	mov   wc.hbrBackground,COLOR_WINDOW+1
	mov   wc.lpszMenuName,IDR_MAINMENU
	mov   wc.lpszClassName,OFFSET ClassName
	invoke LoadIcon,NULL,IDI_APPLICATION
	mov   wc.hIcon,eax
	mov   wc.hIconSm,eax
	invoke LoadCursor,NULL,IDC_ARROW
	mov   wc.hCursor,eax
	invoke RegisterClassEx, addr wc
	INVOKE CreateWindowEx,NULL,ADDR ClassName,ADDR AppName,\
           WS_OVERLAPPEDWINDOW,CW_USEDEFAULT,\
           CW_USEDEFAULT,CW_USEDEFAULT,CW_USEDEFAULT,NULL,NULL,\
           hInst,NULL
	mov   hwnd,eax
	invoke ShowWindow, hwnd,SW_SHOWNORMAL
	invoke UpdateWindow, hwnd
	.while TRUE
		invoke GetMessage, ADDR msg,0,0,0
		.break .if (!eax)
		invoke TranslateMessage, ADDR msg
		invoke DispatchMessage, ADDR msg
	.endw
	mov   eax,msg.wParam
	ret
WinMain endp

StreamInProc proc hFile:DWORD,pBuffer:DWORD, NumBytes:DWORD, pBytesRead:DWORD
	invoke ReadFile,hFile,pBuffer,NumBytes,pBytesRead,0
	xor eax,1
	ret
StreamInProc endp

StreamOutProc proc hFile:DWORD,pBuffer:DWORD, NumBytes:DWORD, pBytesWritten:DWORD
	invoke WriteFile,hFile,pBuffer,NumBytes,pBytesWritten,0
	xor eax,1
	ret
StreamOutProc endp

CheckModifyState proc hWnd:DWORD
	invoke SendMessage,hwndRichEdit,EM_GETMODIFY,0,0
	.if eax!=0
		invoke MessageBox,hWnd,addr WannaSave,addr AppName,MB_YESNOCANCEL
		.if eax==IDYES
			invoke SendMessage,hWnd,WM_COMMAND,IDM_SAVE,0
		.elseif eax==IDCANCEL
			mov eax,FALSE
			ret
		.endif
	.endif
	mov eax,TRUE
	ret
CheckModifyState endp

SetColor proc
	LOCAL cfm:CHARFORMAT
	invoke SendMessage,hwndRichEdit,EM_SETBKGNDCOLOR,0,BackgroundColor
	invoke RtlZeroMemory,addr cfm,sizeof cfm
	mov cfm.cbSize,sizeof cfm
	mov cfm.dwMask,CFM_COLOR
	push TextColor
	pop cfm.crTextColor
	invoke SendMessage,hwndRichEdit,EM_SETCHARFORMAT,SCF_ALL,addr cfm
	ret
SetColor endp

OptionProc proc hWnd:DWORD, uMsg:DWORD, wParam:DWORD, lParam:DWORD
	LOCAL clr:CHOOSECOLOR
	.if uMsg==WM_INITDIALOG
	.elseif uMsg==WM_COMMAND
		mov eax,wParam
		shr eax,16
		.if ax==BN_CLICKED
			mov eax,wParam
			.if ax==IDCANCEL
				invoke SendMessage,hWnd,WM_CLOSE,0,0
			.elseif ax==IDC_BACKCOLORBOX
				invoke RtlZeroMemory,addr clr,sizeof clr
				mov clr.lStructSize,sizeof clr
				push hWnd
				pop clr.hwndOwner
				push hInstance
				pop clr.hInstance
				push BackgroundColor
				pop clr.rgbResult
				mov clr.lpCustColors,offset CustomColors
				mov clr.Flags,CC_ANYCOLOR or CC_RGBINIT
				invoke ChooseColor,addr clr
				.if eax!=0
					push clr.rgbResult
					pop BackgroundColor
					invoke GetDlgItem,hWnd,IDC_BACKCOLORBOX
					invoke InvalidateRect,eax,0,TRUE
				.endif
			.elseif ax==IDC_TEXTCOLORBOX
				invoke RtlZeroMemory,addr clr,sizeof clr
				mov clr.lStructSize,sizeof clr
				push hWnd
				pop clr.hwndOwner
				push hInstance
				pop clr.hInstance
				push TextColor
				pop clr.rgbResult
				mov clr.lpCustColors,offset CustomColors
				mov clr.Flags,CC_ANYCOLOR or CC_RGBINIT
				invoke ChooseColor,addr clr
				.if eax!=0
					push clr.rgbResult
					pop TextColor
					invoke GetDlgItem,hWnd,IDC_TEXTCOLORBOX
					invoke InvalidateRect,eax,0,TRUE
				.endif
			.elseif ax==IDOK
				;==================================================================================
				; Save the modify state of the richedit control because changing the text color changes the
				; modify state of the richedit control.
				;==================================================================================
				invoke SendMessage,hwndRichEdit,EM_GETMODIFY,0,0
				push eax
				invoke SetColor
				pop eax
				invoke SendMessage,hwndRichEdit,EM_SETMODIFY,eax,0
				invoke EndDialog,hWnd,0
			.endif
		.endif
	.elseif uMsg==WM_CTLCOLORSTATIC
		invoke GetDlgItem,hWnd,IDC_BACKCOLORBOX
		.if eax==lParam
			invoke CreateSolidBrush,BackgroundColor			
			ret
		.else
			invoke GetDlgItem,hWnd,IDC_TEXTCOLORBOX
			.if eax==lParam
				invoke CreateSolidBrush,TextColor
				ret
			.endif
		.endif
		mov eax,FALSE
		ret
	.elseif uMsg==WM_CLOSE
		invoke EndDialog,hWnd,0
	.else
		mov eax,FALSE
		ret
	.endif
	mov eax,TRUE
	ret
OptionProc endp

WndProc proc hWnd:DWORD, uMsg:DWORD, wParam:DWORD, lParam:DWORD
	LOCAL chrg:CHARRANGE
	LOCAL ofn:OPENFILENAME
	LOCAL buffer[256]:BYTE
	LOCAL editstream:EDITSTREAM
	LOCAL hFile:DWORD
	.if uMsg==WM_CREATE
		invoke CreateWindowEx,WS_EX_CLIENTEDGE,addr RichEditClass,0,WS_CHILD or WS_VISIBLE or ES_MULTILINE or WS_VSCROLL or WS_HSCROLL or ES_NOHIDESEL,\
				CW_USEDEFAULT,CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT,hWnd,RichEditID,hInstance,0
		mov hwndRichEdit,eax
		;=============================================================
		; Set the text limit. The default is 64K
		;=============================================================
		invoke SendMessage,hwndRichEdit,EM_LIMITTEXT,-1,0
		;=============================================================
		; Set the default text/background color
		;=============================================================
		invoke SetColor
		invoke SendMessage,hwndRichEdit,EM_SETMODIFY,FALSE,0
		invoke SendMessage,hwndRichEdit,EM_EMPTYUNDOBUFFER,0,0
	.elseif uMsg==WM_INITMENUPOPUP
		mov eax,lParam
		.if ax==0		; file menu			
			.if FileOpened==TRUE	; a file is already opened
				invoke EnableMenuItem,wParam,IDM_OPEN,MF_GRAYED
				invoke EnableMenuItem,wParam,IDM_CLOSE,MF_ENABLED
				invoke EnableMenuItem,wParam,IDM_SAVE,MF_ENABLED
				invoke EnableMenuItem,wParam,IDM_SAVEAS,MF_ENABLED
			.else
				invoke EnableMenuItem,wParam,IDM_OPEN,MF_ENABLED
				invoke EnableMenuItem,wParam,IDM_CLOSE,MF_GRAYED
				invoke EnableMenuItem,wParam,IDM_SAVE,MF_GRAYED
				invoke EnableMenuItem,wParam,IDM_SAVEAS,MF_GRAYED
			.endif
		.elseif ax==1	; edit menu
			;=============================================================================
			; Check whether there is some text in the clipboard. If so, we enable the paste menuitem
			;=============================================================================
			invoke SendMessage,hwndRichEdit,EM_CANPASTE,CF_TEXT,0
			.if eax==0		; no text in the clipboard
				invoke EnableMenuItem,wParam,IDM_PASTE,MF_GRAYED
			.else
				invoke EnableMenuItem,wParam,IDM_PASTE,MF_ENABLED
			.endif
			;==========================================================
			; check whether the undo queue is empty
			;==========================================================
			invoke SendMessage,hwndRichEdit,EM_CANUNDO,0,0
			.if eax==0
				invoke EnableMenuItem,wParam,IDM_UNDO,MF_GRAYED
			.else
				invoke EnableMenuItem,wParam,IDM_UNDO,MF_ENABLED
			.endif
			;=========================================================
			; check whether the redo queue is empty
			;=========================================================
			invoke SendMessage,hwndRichEdit,EM_CANREDO,0,0
			.if eax==0
				invoke EnableMenuItem,wParam,IDM_REDO,MF_GRAYED
			.else
				invoke EnableMenuItem,wParam,IDM_REDO,MF_ENABLED
			.endif
			;=========================================================
			; check whether there is a current selection in the richedit control.
			; If there is, we enable the cut/copy/delete menuitem
			;=========================================================
			invoke SendMessage,hwndRichEdit,EM_EXGETSEL,0,addr chrg
			mov eax,chrg.cpMin
			.if eax==chrg.cpMax		; no current selection
				invoke EnableMenuItem,wParam,IDM_COPY,MF_GRAYED
				invoke EnableMenuItem,wParam,IDM_CUT,MF_GRAYED
				invoke EnableMenuItem,wParam,IDM_DELETE,MF_GRAYED
			.else
				invoke EnableMenuItem,wParam,IDM_COPY,MF_ENABLED
				invoke EnableMenuItem,wParam,IDM_CUT,MF_ENABLED
				invoke EnableMenuItem,wParam,IDM_DELETE,MF_ENABLED
			.endif
		.endif
	.elseif uMsg==WM_COMMAND
		.if lParam==0		; menu commands
			mov eax,wParam
			.if ax==IDM_OPEN
				invoke RtlZeroMemory,addr ofn,sizeof ofn
				mov ofn.lStructSize,sizeof ofn
				push hWnd
				pop ofn.hwndOwner
				push hInstance
				pop ofn.hInstance
				mov ofn.lpstrFilter,offset ASMFilterString
				mov ofn.lpstrFile,offset FileName
				mov byte ptr [FileName],0
				mov ofn.nMaxFile,sizeof FileName
				mov ofn.Flags,OFN_FILEMUSTEXIST or OFN_HIDEREADONLY or OFN_PATHMUSTEXIST
				invoke GetOpenFileName,addr ofn
				.if eax!=0
					invoke CreateFile,addr FileName,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0
					.if eax!=INVALID_HANDLE_VALUE
						mov hFile,eax
						;================================================================
						; stream the text into the richedit control
						;================================================================						
						mov editstream.dwCookie,eax
						mov editstream.pfnCallback,offset StreamInProc
						invoke SendMessage,hwndRichEdit,EM_STREAMIN,SF_TEXT,addr editstream
						;==========================================================
						; Initialize the modify state to false
						;==========================================================
						invoke SendMessage,hwndRichEdit,EM_SETMODIFY,FALSE,0
						invoke CloseHandle,hFile
						mov FileOpened,TRUE
					.else
						invoke MessageBox,hWnd,addr OpenFileFail,addr AppName,MB_OK or MB_ICONERROR
					.endif
				.endif
			.elseif ax==IDM_CLOSE
				invoke CheckModifyState,hWnd
				.if eax==TRUE
					invoke SetWindowText,hwndRichEdit,0
					mov FileOpened,FALSE
				.endif
			.elseif ax==IDM_SAVE
				invoke CreateFile,addr FileName,GENERIC_WRITE,FILE_SHARE_READ,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,0
				.if eax!=INVALID_HANDLE_VALUE
@@:				
					mov hFile,eax
					;================================================================
					; stream the text to the file
					;================================================================						
					mov editstream.dwCookie,eax
					mov editstream.pfnCallback,offset StreamOutProc
					invoke SendMessage,hwndRichEdit,EM_STREAMOUT,SF_TEXT,addr editstream
					;==========================================================
					; Initialize the modify state to false
					;==========================================================
					invoke SendMessage,hwndRichEdit,EM_SETMODIFY,FALSE,0
					invoke CloseHandle,hFile
				.else
					invoke MessageBox,hWnd,addr OpenFileFail,addr AppName,MB_OK or MB_ICONERROR
				.endif
			.elseif ax==IDM_COPY
				invoke SendMessage,hwndRichEdit,WM_COPY,0,0
			.elseif ax==IDM_CUT
				invoke SendMessage,hwndRichEdit,WM_CUT,0,0
			.elseif ax==IDM_PASTE
				invoke SendMessage,hwndRichEdit,WM_PASTE,0,0
			.elseif ax==IDM_DELETE
				invoke SendMessage,hwndRichEdit,EM_REPLACESEL,TRUE,0
			.elseif ax==IDM_SELECTALL
				mov chrg.cpMin,0
				mov chrg.cpMax,-1
				invoke SendMessage,hwndRichEdit,EM_EXSETSEL,0,addr chrg
			.elseif ax==IDM_UNDO
				invoke SendMessage,hwndRichEdit,EM_UNDO,0,0
			.elseif ax==IDM_REDO
				invoke SendMessage,hwndRichEdit,EM_REDO,0,0
			.elseif ax==IDM_OPTION
				invoke DialogBoxParam,hInstance,IDD_OPTIONDLG,hWnd,addr OptionProc,0
			.elseif ax==IDM_SAVEAS
				invoke RtlZeroMemory,addr ofn,sizeof ofn
				mov ofn.lStructSize,sizeof ofn
				push hWnd
				pop ofn.hwndOwner
				push hInstance
				pop ofn.hInstance
				mov ofn.lpstrFilter,offset ASMFilterString
				mov ofn.lpstrFile,offset AlternateFileName
				mov byte ptr [AlternateFileName],0
				mov ofn.nMaxFile,sizeof AlternateFileName
				mov ofn.Flags,OFN_FILEMUSTEXIST or OFN_HIDEREADONLY or OFN_PATHMUSTEXIST
				invoke GetSaveFileName,addr ofn
				.if eax!=0
					invoke CreateFile,addr AlternateFileName,GENERIC_WRITE,FILE_SHARE_READ,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,0
					.if eax!=INVALID_HANDLE_VALUE
						jmp @B
					.endif
				.endif
			.elseif ax==IDM_EXIT
				invoke SendMessage,hWnd,WM_CLOSE,0,0
			.endif
		.endif
	.elseif uMsg==WM_CLOSE
		invoke CheckModifyState,hWnd
		.if eax==TRUE
			invoke DestroyWindow,hWnd
		.endif
	.elseif uMsg==WM_SIZE
		mov eax,lParam
		mov edx,eax
		and eax,0FFFFh
		shr edx,16
		invoke MoveWindow,hwndRichEdit,0,0,eax,edx,TRUE		
	.elseif uMsg==WM_DESTROY
		invoke PostQuitMessage,NULL
	.else
		invoke DefWindowProc,hWnd,uMsg,wParam,lParam		
		ret
	.endif
	xor eax,eax
	ret
WndProc endp
end start