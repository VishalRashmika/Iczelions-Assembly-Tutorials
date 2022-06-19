.386
.model flat,stdcall
option casemap:none
include \masm32\include\windows.inc
include \masm32\include\user32.inc
include \masm32\include\kernel32.inc
include \masm32\include\comctl32.inc
include \masm32\include\gdi32.inc
includelib \masm32\lib\gdi32.lib
includelib \masm32\lib\comctl32.lib
includelib \masm32\lib\user32.lib
includelib \masm32\lib\kernel32.lib

WinMain PROTO :DWORD,:DWORD,:DWORD,:DWORD
.const
IDB_TREE	equ 4006
.data
ClassName 	db "TreeViewWinClass",0
AppName  		db "Tree View Demo",0
TreeViewClass 	db "SysTreeView32",0
Parent		db "Parent Item",0
Child1		db "child1",0
Child2		db "child2",0
DragMode		dd FALSE

.data?
hInstance		HINSTANCE ?
hwndTreeView	dd ?
hParent		dd ?
hImageList	dd ?
hDragImageList		dd ?

.code
start:
	invoke GetModuleHandle, NULL
	mov    hInstance,eax
	invoke WinMain, hInstance,NULL,NULL, SW_SHOWDEFAULT
	invoke ExitProcess,eax
	invoke InitCommonControls

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
	mov   wc.hbrBackground,COLOR_APPWORKSPACE
	mov   wc.lpszMenuName,NULL
	mov   wc.lpszClassName,OFFSET ClassName
	invoke LoadIcon,NULL,IDI_APPLICATION
	mov   wc.hIcon,eax
	mov   wc.hIconSm,eax
	invoke LoadCursor,NULL,IDC_ARROW
	mov   wc.hCursor,eax
	invoke RegisterClassEx, addr wc
	invoke CreateWindowEx,WS_EX_CLIENTEDGE,ADDR ClassName,ADDR AppName,\
           WS_OVERLAPPED+WS_CAPTION+WS_SYSMENU+WS_MINIMIZEBOX+WS_MAXIMIZEBOX+WS_VISIBLE,CW_USEDEFAULT,\
           CW_USEDEFAULT,200,400,NULL,NULL,\
           hInst,NULL
	mov   hwnd,eax
	.while TRUE
		invoke GetMessage, ADDR msg,NULL,0,0
		.BREAK .IF (!eax)
		invoke TranslateMessage, ADDR msg
		invoke DispatchMessage, ADDR msg
	.endw
	mov eax,msg.wParam
	ret
WinMain endp

WndProc proc uses edi hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
	LOCAL tvinsert:TV_INSERTSTRUCT
	LOCAL hBitmap:DWORD
	LOCAL tvhit:TV_HITTESTINFO
	.if uMsg==WM_CREATE
		invoke CreateWindowEx,NULL,ADDR TreeViewClass,NULL,\
     	      WS_CHILD+WS_VISIBLE+TVS_HASLINES+TVS_HASBUTTONS+TVS_LINESATROOT,0,\
          	 0,200,400,hWnd,NULL,\
	           hInstance,NULL
		mov hwndTreeView,eax
		invoke ImageList_Create,16,16,ILC_COLOR16,2,10
		mov hImageList,eax
		invoke LoadBitmap,hInstance,IDB_TREE
		mov hBitmap,eax
		invoke ImageList_Add,hImageList,hBitmap,NULL
		invoke DeleteObject,hBitmap
		invoke SendMessage,hwndTreeView,TVM_SETIMAGELIST,0,hImageList
		mov tvinsert.hParent,NULL
		mov tvinsert.hInsertAfter,TVI_ROOT
		mov tvinsert.item.imask,TVIF_TEXT+TVIF_IMAGE+TVIF_SELECTEDIMAGE
		mov tvinsert.item.pszText,offset Parent
		mov tvinsert.item.iImage,0
		mov tvinsert.item.iSelectedImage,1
		invoke SendMessage,hwndTreeView,TVM_INSERTITEM,0,addr tvinsert
		mov hParent,eax
		mov tvinsert.hParent,eax
		mov tvinsert.hInsertAfter,TVI_LAST
		mov tvinsert.item.pszText,offset Child1
		invoke SendMessage,hwndTreeView,TVM_INSERTITEM,0,addr tvinsert
		mov tvinsert.item.pszText,offset Child2
		invoke SendMessage,hwndTreeView,TVM_INSERTITEM,0,addr tvinsert
	.elseif uMsg==WM_MOUSEMOVE
		.if DragMode==TRUE
			mov eax,lParam
			and eax,0ffffh
			mov ecx,lParam
			shr ecx,16
			mov tvhit.pt.x,eax	; eax is the horizontal position of the drag image
			mov tvhit.pt.y,ecx	; ecx is the vertical position			
			invoke ImageList_DragMove,eax,ecx
			invoke ImageList_DragShowNolock,FALSE
			invoke SendMessage,hwndTreeView,TVM_HITTEST,NULL,addr tvhit	; check if an item is hit
			.if eax!=NULL
				invoke SendMessage,hwndTreeView,TVM_SELECTITEM,TVGN_DROPHILITE,eax
			.endif
			invoke ImageList_DragShowNolock,TRUE
		.endif
	.elseif uMsg==WM_LBUTTONUP
		.if DragMode==TRUE
			invoke ImageList_DragLeave,hwndTreeView
			invoke ImageList_EndDrag
			invoke ImageList_Destroy,hDragImageList
			invoke SendMessage,hwndTreeView,TVM_GETNEXTITEM,TVGN_DROPHILITE,0	; Get the currently hilited item
			invoke SendMessage,hwndTreeView,TVM_SELECTITEM,TVGN_CARET,eax
			invoke SendMessage,hwndTreeView,TVM_SELECTITEM,TVGN_DROPHILITE,0
			invoke ReleaseCapture
			mov DragMode,FALSE
		.endif
	.elseif uMsg==WM_NOTIFY
		mov edi,lParam
		assume edi:ptr NM_TREEVIEW
		.if [edi].hdr.code==TVN_BEGINDRAG
			invoke SendMessage,hwndTreeView,TVM_CREATEDRAGIMAGE,0,[edi].itemNew.hItem
			mov hDragImageList,eax
			invoke ImageList_BeginDrag,hDragImageList,0,0,0
			invoke ImageList_DragEnter,hwndTreeView,[edi].ptDrag.x,[edi].ptDrag.y
			invoke SetCapture,hWnd
			mov DragMode,TRUE
		.endif
		assume edi:nothing
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
