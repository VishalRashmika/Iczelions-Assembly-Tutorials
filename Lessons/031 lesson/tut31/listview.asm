.386
.model flat,stdcall
option casemap:none
include \masm32\include\windows.inc
include \masm32\include\user32.inc
include \masm32\include\kernel32.inc
include \masm32\include\comctl32.inc
includelib \masm32\lib\comctl32.lib
includelib \masm32\lib\user32.lib
includelib \masm32\lib\kernel32.lib

WinMain proto :DWORD,:DWORD,:DWORD,:DWORD

IDM_MAINMENU equ 10000
IDM_ICON equ LVS_ICON
IDM_SMALLICON equ LVS_SMALLICON
IDM_LIST equ  LVS_LIST
IDM_REPORT equ LVS_REPORT


RGB macro red,green,blue
        xor eax,eax
        mov ah,blue
        shl eax,8
        mov ah,green
        mov al,red
endm

.data
ClassName db "ListViewWinClass",0
AppName  db "Testing a ListView Control",0
ListViewClassName db "SysListView32",0
Heading1 db "Filename",0
Heading2 db "Size",0
FileNamePattern db "*.*",0
template db "%lu",0
FileNameSortOrder dd 0
SizeSortOrder dd 0

.data?
hInstance HINSTANCE ?
hList  dd  ?
hMenu dd ?

.code
start:
	invoke GetModuleHandle, NULL
	mov    hInstance,eax
	invoke WinMain, hInstance,NULL, NULL, SW_SHOWDEFAULT
	invoke ExitProcess,eax
	invoke InitCommonControls

WinMain proc hInst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD
	LOCAL wc:WNDCLASSEX
	LOCAL msg:MSG
	LOCAL hwnd:HWND
	mov   wc.cbSize,SIZEOF WNDCLASSEX
	mov   wc.style, NULL
	mov   wc.lpfnWndProc, OFFSET WndProc
	mov   wc.cbClsExtra,NULL
	mov   wc.cbWndExtra,NULL
	push  hInstance
	pop   wc.hInstance
	mov   wc.hbrBackground,COLOR_WINDOW+1
	mov   wc.lpszMenuName,IDM_MAINMENU
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
		invoke GetMessage, ADDR msg,NULL,0,0
		.break .if (!eax)
		invoke TranslateMessage, ADDR msg
		invoke DispatchMessage, ADDR msg
	.endw
	mov     eax,msg.wParam
	ret
WinMain endp

InsertColumn proc
	LOCAL lvc:LV_COLUMN
	mov lvc.imask,LVCF_TEXT+LVCF_WIDTH
	mov lvc.pszText,offset Heading1
	mov lvc.lx,150
	invoke SendMessage,hList, LVM_INSERTCOLUMN,0,addr lvc
	or lvc.imask,LVCF_FMT
	mov lvc.fmt,LVCFMT_RIGHT
	mov lvc.pszText,offset Heading2
	mov lvc.lx,100
	invoke SendMessage,hList, LVM_INSERTCOLUMN, 1 ,addr lvc	
	ret		
InsertColumn endp

ShowFileInfo proc uses edi row:DWORD, lpFind:DWORD
	LOCAL lvi:LV_ITEM
	LOCAL buffer[20]:BYTE
	
	mov edi,lpFind
	assume edi:ptr WIN32_FIND_DATA
	mov lvi.imask,LVIF_TEXT+LVIF_PARAM
	push row
	pop lvi.iItem	
	mov lvi.iSubItem,0
	lea eax,[edi].cFileName
	mov lvi.pszText,eax
	push row
	pop lvi.lParam
	invoke SendMessage,hList, LVM_INSERTITEM,0, addr lvi
	mov lvi.imask,LVIF_TEXT
	inc lvi.iSubItem
	invoke wsprintf,addr buffer, addr template,[edi].nFileSizeLow
	lea eax,buffer
	mov lvi.pszText,eax
	invoke SendMessage,hList,LVM_SETITEM, 0,addr lvi
	assume edi:nothing
	ret
ShowFileInfo endp

FillFileInfo proc uses edi
	LOCAL finddata:WIN32_FIND_DATA
	LOCAL FHandle:DWORD
	invoke FindFirstFile,addr FileNamePattern,addr finddata
	.if eax!=INVALID_HANDLE_VALUE
		mov FHandle,eax
		xor edi,edi
		.while eax!=0
			test finddata.dwFileAttributes,FILE_ATTRIBUTE_DIRECTORY
			.if ZERO?
				invoke ShowFileInfo,edi, addr finddata
				inc edi
			.endif
			invoke FindNextFile,FHandle,addr finddata
		.endw
		invoke FindClose,FHandle
	.endif
	ret
FillFileInfo endp

String2Dword proc uses ecx edi edx esi String:DWORD
	LOCAL Result:DWORD
	mov Result,0
        mov edi,String
        invoke lstrlen,String
        .while eax!=0
                xor edx,edx
                mov dl,byte ptr [edi]
                sub dl,"0"      ; subtrack each digit with "0" to convert it to hex value
                mov esi,eax
                dec esi
                push eax
                mov eax,edx
                push ebx
                mov ebx,10
                .while esi > 0
                        mul ebx
                        dec esi
                .endw
                pop ebx
                add Result,eax
                pop eax
                inc edi
                dec eax
        .endw
        mov eax,Result
        ret
String2Dword endp

CompareFunc proc uses edi lParam1:DWORD, lParam2:DWORD, SortType:DWORD
	LOCAL buffer[256]:BYTE
	LOCAL buffer1[256]:BYTE
	LOCAL lvi:LV_ITEM
	mov lvi.imask,LVIF_TEXT
	lea eax,buffer
	mov lvi.pszText,eax
	mov lvi.cchTextMax,256
	.if SortType==1
		mov lvi.iSubItem,1
		invoke SendMessage,hList,LVM_GETITEMTEXT,lParam1,addr lvi
		invoke String2Dword,addr buffer
		mov edi,eax
		invoke SendMessage,hList,LVM_GETITEMTEXT,lParam2,addr lvi
		invoke String2Dword,addr buffer
		sub edi,eax
		mov eax,edi
	.elseif SortType==2
		mov lvi.iSubItem,1
		invoke SendMessage,hList,LVM_GETITEMTEXT,lParam1,addr lvi
		invoke String2Dword,addr buffer
		mov edi,eax
		invoke SendMessage,hList,LVM_GETITEMTEXT,lParam2,addr lvi
		invoke String2Dword,addr buffer
		sub eax,edi
	.elseif SortType==3
		mov lvi.iSubItem,0
		invoke SendMessage,hList,LVM_GETITEMTEXT,lParam1,addr lvi
		invoke lstrcpy,addr buffer1,addr buffer
		invoke SendMessage,hList,LVM_GETITEMTEXT,lParam2,addr lvi
		invoke lstrcmpi,addr buffer1,addr buffer		
	.else
		mov lvi.iSubItem,0
		invoke SendMessage,hList,LVM_GETITEMTEXT,lParam1,addr lvi
		invoke lstrcpy,addr buffer1,addr buffer
		invoke SendMessage,hList,LVM_GETITEMTEXT,lParam2,addr lvi
		invoke lstrcmpi,addr buffer,addr buffer1
	.endif
	ret
CompareFunc endp

UpdatelParam proc uses edi
	LOCAL lvi:LV_ITEM
	invoke SendMessage,hList, LVM_GETITEMCOUNT,0,0
	mov edi,eax
	mov lvi.imask,LVIF_PARAM
	mov lvi.iSubItem,0
	mov lvi.iItem,0
	.while edi>0
		push lvi.iItem
		pop lvi.lParam
		invoke SendMessage,hList, LVM_SETITEM,0,addr lvi
		inc lvi.iItem
		dec edi
	.endw
	ret
UpdatelParam endp

ShowCurrentFocus proc 
	LOCAL lvi:LV_ITEM
	LOCAL buffer[256]:BYTE
	invoke SendMessage,hList,LVM_GETNEXTITEM,-1,LVNI_FOCUSED
	mov lvi.iItem,eax
	mov lvi.iSubItem,0
	mov lvi.imask,LVIF_TEXT
	lea eax,buffer
	mov lvi.pszText,eax
	mov lvi.cchTextMax,256
	invoke SendMessage,hList,LVM_GETITEM,0,addr lvi
	invoke MessageBox,0, addr buffer,addr AppName,MB_OK
	ret
ShowCurrentFocus endp

WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
	.if uMsg==WM_CREATE
		invoke CreateWindowEx, NULL, addr ListViewClassName, NULL, LVS_REPORT+WS_CHILD+WS_VISIBLE, 0,0,0,0,hWnd, NULL, hInstance, NULL
		mov hList, eax
		invoke InsertColumn
		invoke FillFileInfo
		RGB 255,255,255
		invoke SendMessage,hList,LVM_SETTEXTCOLOR,0,eax
		RGB 0,0,0
		invoke SendMessage,hList,LVM_SETBKCOLOR,0,eax
		RGB 0,0,0
		invoke SendMessage,hList,LVM_SETTEXTBKCOLOR,0,eax
		invoke GetMenu,hWnd
		mov hMenu,eax
		invoke CheckMenuRadioItem,hMenu,IDM_ICON,IDM_LIST, IDM_REPORT,MF_CHECKED
	.elseif uMsg==WM_COMMAND
		.if lParam==0
			invoke GetWindowLong,hList,GWL_STYLE
			and eax,not LVS_TYPEMASK
			mov edx,wParam
			and edx,0FFFFh			
			push edx
			or eax,edx
			invoke SetWindowLong,hList,GWL_STYLE,eax
			pop edx
			invoke CheckMenuRadioItem,hMenu,IDM_ICON,IDM_LIST, edx,MF_CHECKED
		.endif
	.elseif uMsg==WM_NOTIFY
		push edi
		mov edi,lParam
		assume edi:ptr NMHDR
		mov eax,[edi].hwndFrom
		.if eax==hList
			.if [edi].code==LVN_COLUMNCLICK
				assume edi:ptr NM_LISTVIEW				
				.if [edi].iSubItem==1
					.if SizeSortOrder==0 || SizeSortOrder==2
						invoke SendMessage,hList,LVM_SORTITEMS,1,addr CompareFunc
						invoke UpdatelParam
						mov SizeSortOrder,1
					.else
						invoke SendMessage,hList,LVM_SORTITEMS,2,addr CompareFunc
						invoke UpdatelParam
						mov SizeSortOrder,2
					.endif					
				.else
					.if FileNameSortOrder==0 || FileNameSortOrder==4
						invoke SendMessage,hList,LVM_SORTITEMS,3,addr CompareFunc
						invoke UpdatelParam
						mov FileNameSortOrder,3
					.else
						invoke SendMessage,hList,LVM_SORTITEMS,4,addr CompareFunc
						invoke UpdatelParam
						mov FileNameSortOrder,4
					.endif										
				.endif
			assume edi:ptr NMHDR
			.elseif [edi].code==NM_DBLCLK
				invoke ShowCurrentFocus
			.endif
		.endif
		pop edi
	.elseif uMsg==WM_SIZE
		mov eax,lParam
		mov edx,eax
		and eax,0ffffh
		shr edx,16
		invoke MoveWindow,hList, 0, 0, eax,edx,TRUE
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
