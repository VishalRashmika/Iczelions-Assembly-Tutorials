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

WORDINFO struct
	WordLen dd ?		; the length of the word: used as a quick comparison
	pszWord dd ?		; pointer to the word
	pColor dd ?		; point to the dword that contains the color used to hilite the word
	NextLink dd ?		; point to the next WORDINFO structure
WORDINFO ends

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
IDR_MAINACCEL                 equ  105
IDD_FINDDLG                    equ 102
IDD_GOTODLG                    equ 103
IDD_REPLACEDLG                 equ 104
IDC_FINDEDIT                  equ  1000
IDC_MATCHCASE                  equ 1001
IDC_REPLACEEDIT                 equ 1001
IDC_WHOLEWORD                  equ 1002
IDC_DOWN                       equ 1003
IDC_UP                       equ   1004
IDC_LINENO                   equ   1005
IDM_FIND                       equ 40014
IDM_FINDNEXT                  equ  40015
IDM_REPLACE                     equ 40016
IDM_GOTOLINE                   equ 40017
IDM_FINDPREV                  equ  40018
RichEditID 			equ 300

.data
ClassName db "IczEditClass",0
AppName  db "IczEdit version 3.0",0
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
WordFileName db "\wordfile.txt",0
ASMSection db "ASSEMBLY",0
C1Key db "C1",0
C2Key db "C2",0
C3Key db "C3",0
C4Key db "C4",0
C5Key db "C5",0
C6Key db "C6",0
C7Key db "C7",0
C8Key db "C8",0
C9Key db "C9",0
C10Key db "C10",0
ZeroString db 0
ASMColorArray dd 0FF0000h,0805F50h,0FFh,666F00h,44F0h,5F8754h,4 dup(0FF0000h)
CommentColor dd 808000h

.data?
hInstance dd ?
hRichEdit dd ?
hwndRichEdit dd ?
FileName db 256 dup(?)
AlternateFileName db 256 dup(?)
CustomColors dd 16 dup(?)
FindBuffer db 256 dup(?)
ReplaceBuffer db 256 dup(?)
uFlags dd ?
findtext FINDTEXTEX <>
ASMSyntaxArray dd 256 dup(?)
hSearch dd ?		; handle to the search/replace dialog box
hAccel dd ?
hMainHeap dd ?		; heap handle
OldWndProc dd ?
RichEditVersion dd ?

.code
start:
	mov byte ptr [FindBuffer],0
	mov byte ptr [ReplaceBuffer],0
	invoke GetModuleHandle, NULL
	mov    hInstance,eax
	invoke LoadLibrary,addr RichEditDLL
	.if eax!=0
		mov hRichEdit,eax
		invoke GetProcessHeap
		mov hMainHeap,eax
		;===========================================================
		; Load the words to be hilighted
		;===========================================================
		call FillHiliteInfo
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
	invoke LoadAccelerators,hInstance,IDR_MAINACCEL
	mov hAccel,eax
	.while TRUE
		invoke GetMessage, ADDR msg,0,0,0
		.break .if (!eax)
		invoke IsDialogMessage,hSearch,addr msg
		.if eax==FALSE
			invoke TranslateAccelerator,hwnd,hAccel,addr msg
			.if eax==0
				invoke TranslateMessage, ADDR msg
				invoke DispatchMessage, ADDR msg
			.endif
		.endif
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

SearchProc proc hWnd:DWORD, uMsg:DWORD, wParam:DWORD, lParam:DWORD
	.if uMsg==WM_INITDIALOG
		push hWnd
		pop hSearch
		;===================================================
		; Select the default search down option
		;===================================================
		invoke CheckRadioButton,hWnd,IDC_DOWN,IDC_UP,IDC_DOWN
		invoke SendDlgItemMessage,hWnd,IDC_FINDEDIT,WM_SETTEXT,0,addr FindBuffer
	.elseif uMsg==WM_COMMAND
		mov eax,wParam
		shr eax,16
		.if ax==BN_CLICKED
			mov eax,wParam
			.if ax==IDOK
				mov uFlags,0
				invoke SendMessage,hwndRichEdit,EM_EXGETSEL,0,addr findtext.chrg
				invoke GetDlgItemText,hWnd,IDC_FINDEDIT,addr FindBuffer,sizeof FindBuffer
				.if eax!=0
					invoke IsDlgButtonChecked,hWnd,IDC_DOWN
					.if eax==BST_CHECKED
						or uFlags,FR_DOWN
						mov eax,findtext.chrg.cpMin
						.if eax!=findtext.chrg.cpMax
							push findtext.chrg.cpMax
							pop findtext.chrg.cpMin
						.endif
						mov findtext.chrg.cpMax,-1
					.else
						mov findtext.chrg.cpMax,0
					.endif
					invoke IsDlgButtonChecked,hWnd,IDC_MATCHCASE
					.if eax==BST_CHECKED
						or uFlags,FR_MATCHCASE
					.endif
					invoke IsDlgButtonChecked,hWnd,IDC_WHOLEWORD
					.if eax==BST_CHECKED
						or uFlags,FR_WHOLEWORD
					.endif
					mov findtext.lpstrText,offset FindBuffer
					invoke SendMessage,hwndRichEdit,EM_FINDTEXTEX,uFlags,addr findtext
					.if eax!=-1
						invoke SendMessage,hwndRichEdit,EM_EXSETSEL,0,addr findtext.chrgText
					.endif
				.endif
			.elseif ax==IDCANCEL
				invoke SendMessage,hWnd,WM_CLOSE,0,0
			.else
				mov eax,FALSE
				ret
			.endif
		.endif
	.elseif uMsg==WM_CLOSE
		mov hSearch,0
		invoke EndDialog,hWnd,0
	.else
		mov eax,FALSE
		ret
	.endif
	mov eax,TRUE
	ret
SearchProc endp

ReplaceProc proc hWnd:DWORD, uMsg:DWORD, wParam:DWORD, lParam:DWORD
	LOCAL settext:SETTEXTEX
	.if uMsg==WM_INITDIALOG
		push hWnd
		pop hSearch
		invoke SetDlgItemText,hWnd,IDC_FINDEDIT,addr FindBuffer
		invoke SetDlgItemText,hWnd,IDC_REPLACEEDIT,addr ReplaceBuffer
	.elseif uMsg==WM_COMMAND
		mov eax,wParam
		shr eax,16
		.if ax==BN_CLICKED
			mov eax,wParam
			.if ax==IDCANCEL
				invoke SendMessage,hWnd,WM_CLOSE,0,0
			.elseif ax==IDOK
				invoke GetDlgItemText,hWnd,IDC_FINDEDIT,addr FindBuffer,sizeof FindBuffer
				invoke GetDlgItemText,hWnd,IDC_REPLACEEDIT,addr ReplaceBuffer,sizeof ReplaceBuffer
				mov findtext.chrg.cpMin,0
				mov findtext.chrg.cpMax,-1
				mov findtext.lpstrText,offset FindBuffer
				mov settext.flags,ST_SELECTION
				mov settext.codepage,CP_ACP
				.while TRUE
					invoke SendMessage,hwndRichEdit,EM_FINDTEXTEX,FR_DOWN,addr findtext
					.if eax==-1
						.break
					.else
						invoke SendMessage,hwndRichEdit,EM_EXSETSEL,0,addr findtext.chrgText
						invoke SendMessage,hwndRichEdit,EM_SETTEXTEX,addr settext,addr ReplaceBuffer
					.endif
				.endw
			.endif
		.endif
	.elseif uMsg==WM_CLOSE
		mov hSearch,0
		invoke EndDialog,hWnd,0
	.else
		mov eax,FALSE
		ret
	.endif
	mov eax,TRUE
	ret
ReplaceProc endp

GoToProc proc hWnd:DWORD, uMsg:DWORD, wParam:DWORD, lParam:DWORD
	LOCAL LineNo:DWORD
	LOCAL chrg:CHARRANGE
	.if uMsg==WM_INITDIALOG
		push hWnd
		pop hSearch
	.elseif uMsg==WM_COMMAND
		mov eax,wParam
		shr eax,16
		.if ax==BN_CLICKED
			mov eax,wParam
			.if ax==IDCANCEL
				invoke SendMessage,hWnd,WM_CLOSE,0,0
			.elseif ax==IDOK
				invoke GetDlgItemInt,hWnd,IDC_LINENO,NULL,FALSE
				mov LineNo,eax
				invoke SendMessage,hwndRichEdit,EM_GETLINECOUNT,0,0
				.if eax>LineNo
					invoke SendMessage,hwndRichEdit,EM_LINEINDEX,LineNo,0
					invoke SendMessage,hwndRichEdit,EM_SETSEL,eax,eax
					invoke SetFocus,hwndRichEdit
				.endif
			.endif
		.endif
	.elseif uMsg==WM_CLOSE
		mov hSearch,0
		invoke EndDialog,hWnd,0
	.else
		mov eax,FALSE
		ret
	.endif
	mov eax,TRUE
	ret
GoToProc endp

PrepareEditMenu proc hSubMenu:DWORD
	LOCAL chrg:CHARRANGE
	;=============================================================================
	; Check whether there is some text in the clipboard. If so, we enable the paste menuitem
	;=============================================================================
	invoke SendMessage,hwndRichEdit,EM_CANPASTE,CF_TEXT,0
	.if eax==0		; no text in the clipboard
		invoke EnableMenuItem,hSubMenu,IDM_PASTE,MF_GRAYED
	.else
		invoke EnableMenuItem,hSubMenu,IDM_PASTE,MF_ENABLED
	.endif
	;==========================================================
	; check whether the undo queue is empty
	;==========================================================
	invoke SendMessage,hwndRichEdit,EM_CANUNDO,0,0
	.if eax==0
		invoke EnableMenuItem,hSubMenu,IDM_UNDO,MF_GRAYED
	.else
		invoke EnableMenuItem,hSubMenu,IDM_UNDO,MF_ENABLED
	.endif
	;=========================================================
	; check whether the redo queue is empty
	;=========================================================
	invoke SendMessage,hwndRichEdit,EM_CANREDO,0,0
	.if eax==0
		invoke EnableMenuItem,hSubMenu,IDM_REDO,MF_GRAYED
	.else
		invoke EnableMenuItem,hSubMenu,IDM_REDO,MF_ENABLED
	.endif
	;=========================================================
	; check whether there is a current selection in the richedit control.
	; If there is, we enable the cut/copy/delete menuitem
	;=========================================================
	invoke SendMessage,hwndRichEdit,EM_EXGETSEL,0,addr chrg
	mov eax,chrg.cpMin
	.if eax==chrg.cpMax		; no current selection
		invoke EnableMenuItem,hSubMenu,IDM_COPY,MF_GRAYED
		invoke EnableMenuItem,hSubMenu,IDM_CUT,MF_GRAYED
		invoke EnableMenuItem,hSubMenu,IDM_DELETE,MF_GRAYED
	.else
		invoke EnableMenuItem,hSubMenu,IDM_COPY,MF_ENABLED
		invoke EnableMenuItem,hSubMenu,IDM_CUT,MF_ENABLED
		invoke EnableMenuItem,hSubMenu,IDM_DELETE,MF_ENABLED
	.endif
	ret
PrepareEditMenu endp

ParseBuffer proc uses edi esi hHeap:DWORD,pBuffer:DWORD, nSize:DWORD, ArrayOffset:DWORD,pArray:DWORD
	LOCAL buffer[128]:BYTE
	LOCAL InProgress:DWORD
	mov InProgress,FALSE
	lea esi,buffer
	mov edi,pBuffer
	invoke CharLower,edi
	mov ecx,nSize
SearchLoop:
	or ecx,ecx
	jz Finished
	cmp byte ptr [edi]," "
	je EndOfWord
	cmp byte ptr [edi],9 	; tab
	je EndOfWord
	mov InProgress,TRUE
	mov al,byte ptr [edi]
	mov byte ptr [esi],al
	inc esi
SkipIt:
	inc edi
	dec ecx
	jmp SearchLoop
EndOfWord:
	cmp InProgress,TRUE
	je WordFound
	jmp SkipIt
WordFound:
	mov byte ptr [esi],0
	push ecx
	;========================================================
	; store the word in a WORDINFO structure
	;========================================================
	invoke HeapAlloc,hHeap,HEAP_ZERO_MEMORY,sizeof WORDINFO
	push esi
	mov esi,eax
	assume esi:ptr WORDINFO
	invoke lstrlen,addr buffer
	mov [esi].WordLen,eax
	push ArrayOffset
	pop [esi].pColor
	inc eax
	invoke HeapAlloc,hHeap,HEAP_ZERO_MEMORY,eax
	mov [esi].pszWord,eax
	mov edx,eax
	invoke lstrcpy,edx,addr buffer
	mov eax,pArray
	movzx edx,byte ptr [buffer]
	shl edx,2		; multiply by 4
	add eax,edx
	.if dword ptr [eax]==0
		mov dword ptr [eax],esi
	.else
		push dword ptr [eax]
		pop [esi].NextLink
		mov dword ptr [eax],esi
	.endif
	pop esi
	pop ecx
	lea esi,buffer
	mov InProgress,FALSE
	jmp SkipIt
Finished:
	.if InProgress==TRUE
		;========================================================
		; store the word in a WORDINFO structure
		;========================================================
		invoke HeapAlloc,hHeap,HEAP_ZERO_MEMORY,sizeof WORDINFO
		push esi
		mov esi,eax
		assume esi:ptr WORDINFO
		invoke lstrlen,addr buffer
		mov [esi].WordLen,eax
		push ArrayOffset
		pop [esi].pColor
		inc eax
		invoke HeapAlloc,hHeap,HEAP_ZERO_MEMORY,eax
		mov [esi].pszWord,eax
		mov edx,eax
		invoke lstrcpy,edx,addr buffer
		mov eax,pArray
		movzx edx,byte ptr [buffer]
		shl edx,2		; multiply by 4
		add eax,edx
		.if dword ptr [eax]==0
			mov dword ptr [eax],esi
		.else
			push dword ptr [eax]
			pop [esi].NextLink
			mov dword ptr [eax],esi
		.endif
		pop esi
	.endif
	ret
ParseBuffer endp

FillHiliteInfo proc uses edi
	LOCAL buffer[1024]:BYTE
	LOCAL pTemp:DWORD
	LOCAL BlockSize:DWORD
	;===================================================================
	; Zero out the array
	;===================================================================
	invoke RtlZeroMemory,addr ASMSyntaxArray,sizeof ASMSyntaxArray
	;===================================================================
	; obtaining the path of this program instance
	;===================================================================
	invoke GetModuleFileName,hInstance,addr buffer,sizeof buffer
	invoke lstrlen,addr buffer
	mov ecx,eax
	dec ecx
	lea edi,buffer
	add edi,ecx
	std
	mov al,"\"
	repne scasb
	cld
	inc edi
	mov byte ptr [edi],0
	invoke lstrcat,addr buffer,addr WordFileName
	;==================================================================
	; Check whether the file exists
	;==================================================================
	invoke GetFileAttributes,addr buffer
	.if eax!=-1
		;===================================================================
		; allocate a block of memory from the heap for the strings
		;===================================================================
		mov BlockSize,1024*10
		invoke HeapAlloc,hMainHeap,0,BlockSize
		mov pTemp,eax
@@:		
		invoke GetPrivateProfileString,addr ASMSection,addr C1Key,addr ZeroString,pTemp,BlockSize,addr buffer
		.if eax!=0
			inc eax
			.if eax==BlockSize	; the buffer is too small
				add BlockSize,1024*10
				invoke HeapReAlloc,hMainHeap,0,pTemp,BlockSize
				mov pTemp,eax
				jmp @B
			.endif
			mov edx,offset ASMColorArray
			invoke ParseBuffer,hMainHeap,pTemp,eax,edx,addr ASMSyntaxArray
		.endif
@@:		
		invoke GetPrivateProfileString,addr ASMSection,addr C2Key,addr ZeroString,pTemp,BlockSize,addr buffer
		.if eax!=0
			inc eax
			.if eax==BlockSize	; the buffer is too small
				add BlockSize,1024*10
				invoke HeapReAlloc,hMainHeap,0,pTemp,BlockSize
				mov pTemp,eax
				jmp @B
			.endif
			mov edx,offset ASMColorArray
			add edx,4
			invoke ParseBuffer,hMainHeap,pTemp,eax,edx,addr ASMSyntaxArray
		.endif
@@:		
		invoke GetPrivateProfileString,addr ASMSection,addr C3Key,addr ZeroString,pTemp,BlockSize,addr buffer
		.if eax!=0
			inc eax
			.if eax==BlockSize	; the buffer is too small
				add BlockSize,1024*10
				invoke HeapReAlloc,hMainHeap,0,pTemp,BlockSize
				mov pTemp,eax
				jmp @B
			.endif
			mov edx,offset ASMColorArray
			add edx,8
			invoke ParseBuffer,hMainHeap,pTemp,eax,edx,addr ASMSyntaxArray
		.endif
@@:		
		invoke GetPrivateProfileString,addr ASMSection,addr C4Key,addr ZeroString,pTemp,BlockSize,addr buffer
		.if eax!=0
			inc eax
			.if eax==BlockSize	; the buffer is too small
				add BlockSize,1024*10
				invoke HeapReAlloc,hMainHeap,0,pTemp,BlockSize
				mov pTemp,eax
				jmp @B
			.endif
			mov edx,offset ASMColorArray
			add edx,12
			invoke ParseBuffer,hMainHeap,pTemp,eax,edx,addr ASMSyntaxArray
		.endif
@@:		
		invoke GetPrivateProfileString,addr ASMSection,addr C5Key,addr ZeroString,pTemp,BlockSize,addr buffer
		.if eax!=0
			inc eax
			.if eax==BlockSize	; the buffer is too small
				add BlockSize,1024*10
				invoke HeapReAlloc,hMainHeap,0,pTemp,BlockSize
				mov pTemp,eax
				jmp @B
			.endif
			mov edx,offset ASMColorArray
			add edx,16
			invoke ParseBuffer,hMainHeap,pTemp,eax,edx,addr ASMSyntaxArray
		.endif
@@:		
		invoke GetPrivateProfileString,addr ASMSection,addr C6Key,addr ZeroString,pTemp,BlockSize,addr buffer
		.if eax!=0
			inc eax
			.if eax==BlockSize	; the buffer is too small
				add BlockSize,1024*10
				invoke HeapReAlloc,hMainHeap,0,pTemp,BlockSize
				mov pTemp,eax
				jmp @B
			.endif
			mov edx,offset ASMColorArray
			add edx,20
			invoke ParseBuffer,hMainHeap,pTemp,eax,edx,addr ASMSyntaxArray
		.endif
@@:		
		invoke GetPrivateProfileString,addr ASMSection,addr C7Key,addr ZeroString,pTemp,BlockSize,addr buffer
		.if eax!=0
			inc eax
			.if eax==BlockSize	; the buffer is too small
				add BlockSize,1024*10
				invoke HeapReAlloc,hMainHeap,0,pTemp,BlockSize
				mov pTemp,eax
				jmp @B
			.endif
			mov edx,offset ASMColorArray
			add edx,24
			invoke ParseBuffer,hMainHeap,pTemp,eax,edx,addr ASMSyntaxArray
		.endif
@@:		
		invoke GetPrivateProfileString,addr ASMSection,addr C8Key,addr ZeroString,pTemp,BlockSize,addr buffer
		.if eax!=0
			inc eax
			.if eax==BlockSize	; the buffer is too small
				add BlockSize,1024*10
				invoke HeapReAlloc,hMainHeap,0,pTemp,BlockSize
				mov pTemp,eax
				jmp @B
			.endif
			mov edx,offset ASMColorArray
			add edx,28
			invoke ParseBuffer,hMainHeap,pTemp,eax,edx,addr ASMSyntaxArray
		.endif
@@:		
		invoke GetPrivateProfileString,addr ASMSection,addr C9Key,addr ZeroString,pTemp,BlockSize,addr buffer
		.if eax!=0
			inc eax
			.if eax==BlockSize	; the buffer is too small
				add BlockSize,1024*10
				invoke HeapReAlloc,hMainHeap,0,pTemp,BlockSize
				mov pTemp,eax
				jmp @B
			.endif
			mov edx,offset ASMColorArray
			add edx,32
			invoke ParseBuffer,hMainHeap,pTemp,eax,edx,addr ASMSyntaxArray
		.endif
@@:		
		invoke GetPrivateProfileString,addr ASMSection,addr C10Key,addr ZeroString,pTemp,BlockSize,addr buffer
		.if eax!=0
			inc eax
			.if eax==BlockSize	; the buffer is too small
				add BlockSize,1024*10
				invoke HeapReAlloc,hMainHeap,0,pTemp,BlockSize
				mov pTemp,eax
				jmp @B
			.endif
			mov edx,offset ASMColorArray
			add edx,36
			invoke ParseBuffer,hMainHeap,pTemp,eax,edx,addr ASMSyntaxArray
		.endif
		invoke HeapFree,hMainHeap,0,pTemp
	.endif
	ret
FillHiliteInfo endp

NewRichEditProc proc hWnd:DWORD, uMsg:DWORD, wParam:DWORD, lParam:DWORD
	LOCAL hdc:DWORD
	LOCAL hOldFont:DWORD
	LOCAL FirstChar:DWORD
	LOCAL rect:RECT
	LOCAL txtrange:TEXTRANGE
	LOCAL buffer[1024*10]:BYTE
	LOCAL hRgn:DWORD
	LOCAL hOldRgn:DWORD
	LOCAL RealRect:RECT
	LOCAL pString:DWORD
	LOCAL BufferSize:DWORD
	LOCAL pt:POINT
	.if uMsg==WM_PAINT
		push edi
		push esi
		invoke HideCaret,hWnd
		invoke CallWindowProc,OldWndProc,hWnd,uMsg,wParam,lParam
		push eax
		mov edi,offset ASMSyntaxArray
		invoke GetDC,hWnd
		mov hdc,eax
		invoke SetBkMode,hdc,TRANSPARENT
		;===================================================================
		; Do syntax hiliting here!
		;===================================================================
		invoke SendMessage,hWnd,EM_GETRECT,0,addr rect
		invoke SendMessage,hWnd,EM_CHARFROMPOS,0,addr rect
		;========================================================
		; obtain the line number
		;========================================================
		invoke SendMessage,hWnd,EM_LINEFROMCHAR,eax,0
		invoke SendMessage,hWnd,EM_LINEINDEX,eax,0
		mov txtrange.chrg.cpMin,eax
		mov FirstChar,eax
		invoke SendMessage,hWnd,EM_CHARFROMPOS,0,addr rect.right
		mov txtrange.chrg.cpMax,eax
		push rect.left
		pop RealRect.left
		push rect.top
		pop RealRect.top
		push rect.right
		pop RealRect.right
		push rect.bottom
		pop RealRect.bottom
		invoke CreateRectRgn,RealRect.left,RealRect.top,RealRect.right,RealRect.bottom
		mov hRgn,eax
		invoke SelectObject,hdc,hRgn
		mov hOldRgn,eax
		invoke SetTextColor,hdc,CommentColor
		;===================================================================
		; Get the visible text into buffer
		;===================================================================
		lea eax,buffer
		mov txtrange.lpstrText,eax
		invoke SendMessage,hWnd,EM_GETTEXTRANGE,0,addr txtrange
		mov esi,eax		; esi == size of the text	
		.if esi>0
			mov BufferSize,eax
			;=========================================================
			; Search for comments first
			;=========================================================
			push edi
			push ebx
			lea edi,buffer
			mov edx,edi		; used as the reference point
			mov ecx,esi
			mov al,";"
	ScanMore:
			repne scasb
			je NextSkip
			jmp NoMoreHit
	NextSkip:
			dec edi
			inc ecx
			mov pString,edi
			mov ebx,edi
			sub ebx,edx
			add ebx,FirstChar
			mov txtrange.chrg.cpMin,ebx
			;===================================================
			; search the end of line or the end of buffer
			;===================================================
			push eax
			mov al,0Dh
			repne scasb
			pop eax
	HiliteTheComment:
			.if ecx>0
				mov byte ptr [edi-1],0
			.endif
			mov ebx,edi
			sub ebx,edx
			add ebx,FirstChar
			mov txtrange.chrg.cpMax,ebx
			pushad
			;====================================================================
			; Now we must search the range for the tabs
			;====================================================================
			mov edi,pString
			mov esi,txtrange.chrg.cpMax
			sub esi,txtrange.chrg.cpMin		; esi contains the length of the buffer
			mov eax,esi
			push edi
			.while eax>0
				.if byte ptr [edi]==9
					mov byte ptr [edi],0
				.endif
				inc edi
				dec eax
			.endw
			pop edi
			.while esi>0
				.if byte ptr [edi]!=0
					invoke lstrlen,edi
					push eax
					mov ecx,edi
					lea edx,buffer
					sub ecx,edx
					add ecx,FirstChar
					.if RichEditVersion==3
						invoke SendMessage,hWnd,EM_POSFROMCHAR,addr rect,ecx
					.else
						invoke SendMessage,hWnd,EM_POSFROMCHAR,ecx,0
						mov ecx,eax
						and ecx,0FFFFh
						mov rect.left,ecx
						shr eax,16
						mov rect.top,eax
					.endif
					invoke DrawText,hdc,edi,-1,addr rect,0
					pop eax
					add edi,eax
					sub esi,eax
				.else
					inc edi
					dec esi
				.endif			
			.endw
			mov ecx,txtrange.chrg.cpMax
			sub ecx,txtrange.chrg.cpMin
			invoke RtlZeroMemory,pString,ecx
			popad
			.if ecx>0
				jmp ScanMore
			.endif
	NoMoreHit:
			pop ebx
			pop edi
			;==============================================================================
			; Now that the comments are out of our way, Get rid of the separators
			;==============================================================================
			mov ecx,BufferSize
			lea esi,buffer
			.while ecx>0
				mov al,byte ptr [esi]
				.if al==" " || al==0Dh || al=="/" || al=="," || al=="|" || al=="+" || al=="-" || al=="*" || al=="&" || al=="<" || al==">" || al=="=" || al=="(" || al==")" || al=="{" || al=="}" || al=="[" || al=="]" || al=="^" || al==":" || al==9
					mov byte ptr [esi],0
				.endif
				dec ecx
				inc esi
			.endw
			;============================================================================
			; Begin the search 
			;============================================================================
			lea esi,buffer
			mov ecx,BufferSize
			.while ecx>0
				mov al,byte ptr [esi]
				.if al!=0
					push ecx
					invoke lstrlen,esi
					push eax
					mov edx,eax		; edx contains the length of the string
					movzx eax,byte ptr [esi]
					.if al>="A" && al<="Z"
						sub al,"A"
						add al,"a"
					.endif
					shl eax,2
					add eax,edi		; edi contains the pointer to the WORDINFO pointer array
					.if dword ptr [eax]!=0
						mov eax,dword ptr [eax]
						assume eax:ptr WORDINFO
						.while eax!=0
							.if edx==[eax].WordLen
								pushad
								invoke lstrcmpi,[eax].pszWord,esi
								.if eax==0								
									popad
									;=================================================
									; hilite the word
									;=================================================
									mov ecx,esi
									lea edx,buffer
									sub ecx,edx
									add ecx,FirstChar
									pushad
									.if RichEditVersion==3
										invoke SendMessage,hWnd,EM_POSFROMCHAR,addr rect,ecx
									.else
										invoke SendMessage,hWnd,EM_POSFROMCHAR,ecx,0
										mov ecx,eax
										and ecx,0FFFFh
										mov rect.left,ecx
										shr eax,16
										mov rect.top,eax
									.endif
									popad
									mov edx,[eax].pColor
									invoke SetTextColor,hdc,dword ptr [edx]								
									invoke DrawText,hdc,esi,-1,addr rect,0
									.break
								.endif
								popad
							.endif
							push [eax].NextLink
							pop eax
						.endw
					.endif
					pop eax
					pop ecx
					add esi,eax
					sub ecx,eax
				.else
					inc esi
					dec ecx
				.endif
			.endw
		.endif
		invoke SelectObject,hdc,hOldRgn
		invoke DeleteObject,hRgn
		invoke SelectObject,hdc,hOldFont
		invoke ReleaseDC,hWnd,hdc
		invoke ShowCaret,hWnd
		pop eax
		pop esi
		pop edi
		ret
	.elseif uMsg==WM_CLOSE
		invoke SetWindowLong,hWnd,GWL_WNDPROC,OldWndProc		
	.else
		invoke CallWindowProc,OldWndProc,hWnd,uMsg,wParam,lParam
		ret
	.endif
NewRichEditProc endp

WndProc proc hWnd:DWORD, uMsg:DWORD, wParam:DWORD, lParam:DWORD
	LOCAL ofn:OPENFILENAME
	LOCAL buffer[256]:BYTE
	LOCAL editstream:EDITSTREAM
	LOCAL hFile:DWORD
	LOCAL hPopup:DWORD
	LOCAL pt:POINT
	LOCAL chrg:CHARRANGE
	.if uMsg==WM_CREATE
		invoke CreateWindowEx,WS_EX_CLIENTEDGE,addr RichEditClass,0,WS_CHILD or WS_VISIBLE or ES_MULTILINE or WS_VSCROLL or WS_HSCROLL or ES_NOHIDESEL,\
				CW_USEDEFAULT,CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT,hWnd,RichEditID,hInstance,0
		mov hwndRichEdit,eax
		;=======================================================
		; Check the richedit version
		;=======================================================
		invoke SendMessage,hwndRichEdit,EM_SETTYPOGRAPHYOPTIONS,TO_SIMPLELINEBREAK,TO_SIMPLELINEBREAK
		invoke SendMessage,hwndRichEdit,EM_GETTYPOGRAPHYOPTIONS,1,1
		.if eax==0		; means this message is not processed
			mov RichEditVersion,2
		.else
			mov RichEditVersion,3
			;=============================================================================
			; Make it emulate system edit control so the text color update doesn't  take very long
			;=============================================================================
			invoke SendMessage,hwndRichEdit,EM_SETEDITSTYLE,SES_EMULATESYSEDIT,SES_EMULATESYSEDIT
		.endif
		;=======================================================
		; Subclass the richedit control
		;=======================================================
		invoke SetWindowLong,hwndRichEdit,GWL_WNDPROC, addr NewRichEditProc
		mov OldWndProc,eax
		;=============================================================
		; Set the text limit. The default is 64K
		;=============================================================
		invoke SendMessage,hwndRichEdit,EM_LIMITTEXT,-1,0
		;=============================================================
		; Set the default text/background color
		;=============================================================
		invoke SetColor
		invoke SendMessage,hwndRichEdit,EM_SETMODIFY,FALSE,0
		;============================================================
		; set event mask
		;============================================================
		invoke SendMessage,hwndRichEdit,EM_SETEVENTMASK,0,ENM_MOUSEEVENTS
		invoke SendMessage,hwndRichEdit,EM_EMPTYUNDOBUFFER,0,0
	.elseif uMsg==WM_NOTIFY
		push esi
		mov esi,lParam
		assume esi:ptr NMHDR
		.if [esi].code==EN_MSGFILTER
			assume esi:ptr MSGFILTER
			.if [esi].msg==WM_RBUTTONDOWN
				invoke GetMenu,hWnd
				invoke GetSubMenu,eax,1
				mov hPopup,eax
				invoke PrepareEditMenu,hPopup
				mov edx,[esi].lParam
				mov ecx,edx
				and edx,0FFFFh
				shr ecx,16
				mov pt.x,edx
				mov pt.y,ecx
				invoke ClientToScreen,hWnd,addr pt
				invoke TrackPopupMenu,hPopup,TPM_LEFTALIGN or TPM_BOTTOMALIGN,pt.x,pt.y,NULL,hWnd,NULL
			.endif
		.endif
		pop esi
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
			invoke PrepareEditMenu,wParam
		.elseif ax==2		; search menu bar
			.if FileOpened==TRUE
				invoke EnableMenuItem,wParam,IDM_FIND,MF_ENABLED
				invoke EnableMenuItem,wParam,IDM_FINDNEXT,MF_ENABLED
				invoke EnableMenuItem,wParam,IDM_FINDPREV,MF_ENABLED
				invoke EnableMenuItem,wParam,IDM_REPLACE,MF_ENABLED
				invoke EnableMenuItem,wParam,IDM_GOTOLINE,MF_ENABLED
			.else
				invoke EnableMenuItem,wParam,IDM_FIND,MF_GRAYED
				invoke EnableMenuItem,wParam,IDM_FINDNEXT,MF_GRAYED
				invoke EnableMenuItem,wParam,IDM_FINDPREV,MF_GRAYED
				invoke EnableMenuItem,wParam,IDM_REPLACE,MF_GRAYED
				invoke EnableMenuItem,wParam,IDM_GOTOLINE,MF_GRAYED
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
			.elseif ax==IDM_FIND
				.if hSearch==0
					invoke CreateDialogParam,hInstance,IDD_FINDDLG,hWnd,addr SearchProc,0
				.endif
			.elseif ax==IDM_REPLACE
				.if hSearch==0
					invoke CreateDialogParam,hInstance,IDD_REPLACEDLG,hWnd,addr ReplaceProc,0
				.endif
			.elseif ax==IDM_GOTOLINE
				.if hSearch==0
					invoke CreateDialogParam,hInstance,IDD_GOTODLG,hWnd,addr GoToProc,0
				.endif
			.elseif ax==IDM_FINDNEXT
				invoke lstrlen,addr FindBuffer
				.if eax!=0
					invoke SendMessage,hwndRichEdit,EM_EXGETSEL,0,addr findtext.chrg
					mov eax,findtext.chrg.cpMin
					.if eax!=findtext.chrg.cpMax
						push findtext.chrg.cpMax
						pop findtext.chrg.cpMin
					.endif
					mov findtext.chrg.cpMax,-1
					mov findtext.lpstrText,offset FindBuffer
					invoke SendMessage,hwndRichEdit,EM_FINDTEXTEX,FR_DOWN,addr findtext
					.if eax!=-1
						invoke SendMessage,hwndRichEdit,EM_EXSETSEL,0,addr findtext.chrgText
					.endif
				.endif
			.elseif ax==IDM_FINDPREV
				invoke lstrlen,addr FindBuffer
				.if eax!=0
					invoke SendMessage,hwndRichEdit,EM_EXGETSEL,0,addr findtext.chrg
					mov findtext.chrg.cpMax,0
					mov findtext.lpstrText,offset FindBuffer
					invoke SendMessage,hwndRichEdit,EM_FINDTEXTEX,0,addr findtext
					.if eax!=-1
						invoke SendMessage,hwndRichEdit,EM_EXSETSEL,0,addr findtext.chrgText
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