.386			; 32-Bit when .386 appears before .MODEL
.MODEL	FLAT, STDCALL
;ีออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออธ
;ณ ************************************************************************ ณ
;ณ									    ณ
;ณ       MICROSOFT WINDOWS 32-BIT API ASSEMBLY LANGUAGE HEADER FILE	    ณ
;ณ                             by Steve Gibson				    ณ
;ณ									    ณ
;ณ ************************************************************************ ณ
;ิออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออพ

;ีออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออธ
;ณ ************************************************************************ ณ
;ณ       MODIFYED BY ICZELION                                           ณ
;ณ ************************************************************************ ณ
;ิออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออพ
option	casemap:none


;ีออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออธ
;ณ                      Steve's Personal  MASM MACROS			    ณ
;ิออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออพ

LocalReturn	MACRO
;ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
		BYTE	0C3h	; a local "ret" instruction
		ENDM

;ฤฤฤฤฤฤฤฤฤฤฤฤฤ Sometimes ya just gotta Complement the ZERO flag ฤฤฤฤฤฤฤฤฤฤฤฤฤ
cmz		MACRO
		push	eax		; save AX
		lahf			; load AH from FLAGS
		xor	ah, ZERO_FLAG_BIT ; invert the ZERO flag's bit
		sahf			; store AH into FLAGS
		pop	eax		; restore AX
		ENDM

;ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ ZERO a register and clear statuses ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
zero		MACRO p1
		xor	p1,p1
		ENDM

;ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ Set statuses on a register ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
check		MACRO p1
		or	p1,p1
		ENDM

;ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ Double "N" ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
double		MACRO p1
		shl	p1,1
		ENDM

;ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
halve		MACRO p1
		shr	p1,1
		ENDM

;ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
bool		MACRO p1
		test	p1, -1
		ENDM

;ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
iftrue		MACRO p1
		jnz	p1
		ENDM

;ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
iffalse		MACRO p1
		jz	p1
		ENDM

;ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
set		MACRO p1
		mov	p1, -1
		ENDM

;ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
reset		MACRO p1
		mov	p1, 0
		ENDM

;ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
pupop		MACRO p1, p2
		push	p2
		pop	p1
		ENDM

;ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
movmov		MACRO p1, p2, p3
		mov	p2, p3
		mov	p1, p2
		ENDM

;ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
pushem		MACRO p1
	 	 IRP	p2,<p1>
	  	  push	p2
		 ENDM
		ENDM

;ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
popem		MACRO p1
		 IRP	p2,<p1>
		  pop	p2
		 ENDM
		ENDM

;ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
swap	MACRO p1, p2
		xchg	p1,p2
	ENDM


;ีออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออธ
;ณ          S T A N D A R D    E Q U A T E S    A N D    D E F S	    ณ
;ิออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออพ
MAX_PATH	equ	0104h

NULL		equ	0h
FALSE		equ	0h
TRUE		equ	1h

CALLBACK	TYPEDEF	PROTO STDCALL
WINAPI		TYPEDEF	PROTO STDCALL

BOOL		TYPEDEF	SDWORD
LPBYTE		TYPEDEF	PTR BYTE
LPDWORD		TYPEDEF	PTR DWORD
LPVOID		TYPEDEF	PTR
LPCVOID		TYPEDEF	PTR
LPSTR		TYPEDEF	DWORD
LPCSTR		TYPEDEF	DWORD

UINT		TYPEDEF	DWORD
LONG		TYPEDEF	DWORD

WPARAM		TYPEDEF	UINT
LPARAM		TYPEDEF	DWORD

HANDLE		TYPEDEF	DWORD
HWND		TYPEDEF	DWORD
HGLOBAL		TYPEDEF	DWORD
HGDIOBJ		TYPEDEF	DWORD
HACCEL		TYPEDEF	DWORD
HBITMAP		TYPEDEF	DWORD
HBRUSH		TYPEDEF	DWORD
HDC		TYPEDEF	DWORD
HFONT		TYPEDEF	DWORD
HICON		TYPEDEF	DWORD
HMENU		TYPEDEF	DWORD
HINSTANCE	TYPEDEF	DWORD
HRGN		TYPEDEF	DWORD
HRSRC		TYPEDEF	DWORD
HCURSOR		TYPEDEF	DWORD
COLORREF	TYPEDEF	DWORD


RECT		STRUCT
;ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
	left	LONG	?
	top	LONG	?
	right	LONG	?
	bottom	LONG	?
RECT		ENDS
LPRECT		TYPEDEF	PTR RECT

_SIZE STRUCT
  _cx DWORD ?
  _cy DWORD ?
_SIZE ENDS
LPSIZE TYPEDEF PTR _SIZE

POINT		STRUCT
;ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
	x	LONG	?
	y	LONG	?
POINT		ENDS
LPPOINT		TYPEDEF	PTR POINT

LoadMenuA PROTO, :HINSTANCE, :LPSTR
LoadMenu TEXTEQU <LoadMenuA>

;ีออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออธ
;ณ                            Bits from WINNT.H				    ณ
;ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

FILE_ATTRIBUTE_READONLY	equ	0001h
FILE_ATTRIBUTE_HIDDEN	equ	0002h
FILE_ATTRIBUTE_SYSTEM	equ	0004h
FILE_ATTRIBUTE_DIRECTORY equ	0010h
FILE_ATTRIBUTE_ARCHIVE	equ	0020h
FILE_ATTRIBUTE_NORMAL	equ	0080h
FILE_ATTRIBUTE_TEMPORARY equ	0100h
FILE_ATTRIBUTE_COMPRESSED equ	0800h

GENERIC_READ		equ	080000000h
GENERIC_WRITE		equ	040000000h
GENERIC_EXECUTE		equ	020000000h
GENERIC_ALL		equ	010000000h

DLL_PROCESS_ATTACH	equ	01h
DLL_THREAD_ATTACH	equ	02h
DLL_THREAD_DETACH	equ	03h
DLL_PROCESS_DETACH	equ	00h

RtlMoveMemory		PROTO	STDCALL :DWORD, :DWORD, :DWORD
MoveMemory		textequ	<RtlMoveMemory>
RtlFillMemory		PROTO	STDCALL :DWORD, :DWORD, :BYTE
FillMemory		textequ	<RtlFillMemory>


;ีออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออธ
;ณ                          Stuff from WINERROR.H			    ณ
;ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

ERROR_SUCCESS		equ	000h
ERROR_INVALID_HANDLE	equ	006h
ERROR_ALREADY_EXISTS	equ	0B7h

;ีออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออธ
;ณ                     From KERNEL32.LIB and WINBASE.H			    ณ
;ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

INVALID_HANDLE_VALUE	equ	-1

CREATE_NEW		equ	01h
CREATE_ALWAYS		equ	02h
OPEN_EXISTING		equ	03h
OPEN_ALWAYS		equ	04h
TRUNCATE_EXISTING	equ	05h

OVERLAPPED		STRUCT
	Internal	DWORD	?
	InternalHigh	DWORD	?
	_Offset		DWORD	?
	OffsetHigh	DWORD	?
	hEvent		HANDLE	?
OVERLAPPED		ENDS
LPOVERLAPPED		TYPEDEF	PTR OVERLAPPED

SECURITY_ATTRIBUTES	STRUCT
	nLength		DWORD	?
	lpSecurityDescriptor	LPVOID	?
	bInheritHandle	BOOL	?
SECURITY_ATTRIBUTES	ENDS
LPSECURITY_ATTRIBUTES	TYPEDEF	PTR SECURITY_ATTRIBUTES

PROCESS_INFORMATION	STRUCT
	hProcess	HANDLE	?
	hThread		HANDLE	?
	dwProcessID	DWORD	?
	dwThreadID	DWORD	?
PROCESS_INFORMATION	ENDS
LPPROCESS_INFORMATION	TYPEDEF	PTR PROCESS_INFORMATION

GMEM_FIXED		equ	00000h
GMEM_MOVEABLE		equ	00002h
GMEM_ZEROINIT		equ	00040h
GMEM_SHARE		equ	02000h

DEBUG_PROCESS		equ	001h
DEBUG_ONLY_THIS_PROCESS	equ	002h
CREATE_SUSPENDED	equ	004h
DETACHED_PROCESS	equ	008h
CREATE_NEWE_CONSOLE	equ	010h
NORMAL_PRIORITY_CLASS	equ	020h

WinMain			PROTO	WINAPI	:HINSTANCE, :HINSTANCE, :LPSTR, :SDWORD
GlobalAlloc		PROTO	WINAPI	:UINT, :DWORD
GlobalLock		PROTO	WINAPI	:HGLOBAL
GlobalUnlock		PROTO	WINAPI	:HGLOBAL
GlobalFree		PROTO	WINAPI	:HGLOBAL
ExitProcess		PROTO	WINAPI	:DWORD
GetLastError		PROTO	WINAPI
DebugBreak		PROTO	WINAPI
Sleep			PROTO	WINAPI	:DWORD
LoadResource		PROTO	WINAPI	:HINSTANCE, :HRSRC
GetFileSize		PROTO	WINAPI	:HANDLE, :LPDWORD
WriteFile		PROTO	WINAPI	:HANDLE, :LPCVOID, :DWORD, :LPDWORD, :LPOVERLAPPED
ReadFile		PROTO	WINAPI	:HANDLE, :LPVOID, :DWORD, :LPDWORD, :LPOVERLAPPED
CloseHandle		PROTO	WINAPI	:HANDLE
Beep			PROTO	WINAPI	:DWORD, :DWORD
lstrlenA		PROTO	WINAPI	:LPCSTR
lstrlen			textequ	<lstrlenA>
GetTextExtentPoint32A PROTO WINAPI :HDC, :LPCSTR,:DWORD, :LPSIZE
GetTextExtentPoint32 textequ <GetTextExtentPoint32A>

STARTF_USESHOWWINDOW	equ	0001h
STARTF_USESIZE		equ	0002h
STARTF_USEPOSITION	equ	0004h
STARTF_USECOUNTCHARS	equ	0008h
STARTF_USEFILLATTRIBUTE	equ	0010h
STARTF_RUNFULLSCREEN	equ	0020h
STARTF_FORCEONFEEDBACK	equ	0040h
STARTF_FORCEOFFFEEDBACK	equ	0080h
STARTF_USESTDHANDLES	equ	0100h
STARTF_USEHOTKEY	equ	0200h

STARTUPINFOA		STRUCT
	cb		DWORD		?
	lpReserved	LPSTR		?
	lpDesktop	LPSTR		?
	lpTitle		LPSTR		?
	dwX		DWORD		?
	dwY		DWORD		?
	dwXSize		DWORD		?
	dwYSize		DWORD		?
	dwXCountChars	DWORD		?
	dwYCountChars	DWORD		?
	dwFillAttribute	DWORD		?
	dwFlags		DWORD		?
	wShowWindow	WORD		?
	cbReserved2	WORD		?
	lpReserved2	LPBYTE		?
	hStdInput	HANDLE		?
	hStdOutput	HANDLE		?
	hStdError	HANDLE		?
STARTUPINFOA		ENDS
LPSTARTUPINFO		TYPEDEF	PTR STARTUPINFOA
STARTUPINFO		textequ	<STARTUPINFOA>

CreateSemaphoreA	PROTO	WINAPI	:LPSECURITY_ATTRIBUTES, :LONG, :LONG, :LPCSTR
CreateSemaphore		textequ	<CreateSemaphoreA>

GetModuleHandleA	PROTO	WINAPI	:DWORD
GetModuleHandle		textequ	<GetModuleHandleA>
CreateProcessA		PROTO	STDCALL	:LPCSTR, :LPSTR,\
					:LPSECURITY_ATTRIBUTES,\
					:LPSECURITY_ATTRIBUTES,\
					:BOOL, :DWORD, :LPVOID, :LPCSTR,\
					:LPSTARTUPINFO,\
					:LPPROCESS_INFORMATION
CreateProcess		textequ	<CreateProcessA>
GetStartupInfoA		PROTO	WINAPI	:LPSTARTUPINFO
GetStartupInfo		textequ	<GetStartupInfoA>
GetCommandLineA		PROTO	WINAPI
GetCommandLine		textequ	<GetCommandLineA>
OutputDebugStringA	PROTO	WINAPI	:LPCSTR
OutputDebugString	textequ	<OutputDebugStringA>
FindResourceA		PROTO	WINAPI	:HINSTANCE, :LPCSTR, :LPCSTR
FindResource		textequ	<FindResourceA>
CreateFileA		PROTO	WINAPI	:LPCSTR, :DWORD, :DWORD,\
					:LPSECURITY_ATTRIBUTES,\
					:DWORD, :DWORD, :HANDLE
CreateFile		textequ	<CreateFileA>
QueryPerformanceCounter	PROTO	WINAPI	:DWORD
QueryPerformanceFrequency PROTO	WINAPI	:DWORD

;ีออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออธ
;ณ                         GDI32.LIB and WINGDI.H			    ณ
;ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

SRCCOPY			equ	00CC0020h	;dest = source
SRCPAINT		equ	00EE0086h	;dest = source OR dest
SRCAND			equ	008800C6h	;dest = source AND dest
SRCINVERT		equ	00660046h	;dest = source XOR dest
SRCERASE		equ	00440328h	;dest = source AND (NOT dest)

TA_LEFT			equ	000h
TA_RIGHT		equ	002h
TA_CENTER		equ	006h
TA_TOP			equ	000h
TA_BOTTOM		equ	008h
TA_BASELINE		equ	018h

SP_ERROR		equ	-1

BITMAP			STRUCT
	bmType		LONG		?
	bmWidth		LONG		?
	bmHeight	LONG		?
	bmWidthBytes	LONG		?
	bmPlanes	WORD		?
	bmBitsPixel	WORD		?
	bmBits		LPVOID		?
BITMAP			ENDS

DRAFT_QUALITY		equ	002h
PROOF_QUALITY		equ	003h
FIXED_PITCH		equ	001h
VARIABLE_PITCH		equ	002h
FW_NORMAL		equ	400
FW_BOLD			equ	700
FF_ROMAN		equ	010h
FF_MODERN		equ	030h

TRANSPARENT		equ	01h
OPAQUE			equ	02h

WHITE_BRUSH		equ	00h
LTGRAY_BRUSH		equ	01h
GRAY_BRUSH		equ	02h
DKGRAY_BRUSH		equ	03h
BLACK_BRUSH		equ	04h

BitBlt			PROTO	WINAPI	:HDC, :DWORD, :DWORD, :DWORD, :DWORD,\
					:HDC, :DWORD, :DWORD, :DWORD
CreateCompatibleDC	PROTO	WINAPI	:HDC
CreateFontA		PROTO	WINAPI	:SDWORD, :SDWORD, :SDWORD, :SDWORD, :SDWORD, :DWORD, :DWORD,\
					:DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :LPCSTR
CreateFont		textequ	<CreateFontA>
CreateSolidBrush	PROTO	WINAPI	:COLORREF
DeleteDC		PROTO	WINAPI	:HDC
DeleteObject		PROTO	WINAPI	:HGDIOBJ
GetStockObject		PROTO	WINAPI	:SDWORD
LineTo			PROTO	WINAPI	:HDC, :UINT, :UINT
RectVisible		PROTO	WINAPI	:HDC, :LPRECT
SelectObject		PROTO	WINAPI	:HDC, :HGDIOBJ
SetBkColor		PROTO	WINAPI	:HDC, :COLORREF
SetBkMode		PROTO	WINAPI	:HDC, :SDWORD
StretchBlt		PROTO	WINAPI	:HDC, :SDWORD, :SDWORD, :SDWORD, :SDWORD,\
					:HDC, :SDWORD, :SDWORD, :SDWORD, :SDWORD, :DWORD
SetTextColor		PROTO	WINAPI	:HDC, :COLORREF
SetTextAlign		PROTO	WINAPI	:HDC, :UINT

ABORTPROC		TYPEDEF	PROTO STDCALL

OEM_CHARSET   equ 255
OUT_DEFAULT_PRECIS  equ 0
CLIP_DEFAULT_PRECIS  equ 0
DEFAULT_QUALITY equ 0
DEFAULT_PITCH equ 0
FF_SCRIPT equ 64

DOCINFOA		STRUCT
	cbSize		SDWORD	?
	lpszDocName	LPCSTR	?
	lpszOutput	LPCSTR	?
	lpszDataType	LPCSTR	?
	fwType		DWORD	?
DOCINFOA		ENDS
LPDOCINFO		TYPEDEF	PTR DOCINFOA
DOCINFO			textequ	<DOCINFOA>

StartDocA		PROTO	WINAPI	:HDC, :LPDOCINFO
StartDoc		textequ	<StartDocA>
EndDoc			PROTO	WINAPI	:HDC
StartPage		PROTO	WINAPI	:HDC
EndPage			PROTO	WINAPI	:HDC
AbortDoc		PROTO	WINAPI	:HDC
SetAbortProc		PROTO	WINAPI	:HDC, :ABORTPROC

MoveToEx		PROTO	WINAPI	:HDC, :UINT, :UINT, :LPPOINT
TextOutA		PROTO	WINAPI	:HDC, :DWORD, :DWORD, :LPCSTR, :DWORD
TextOut			textequ	<TextOutA>

;ีออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออธ
;ณ                        USER32.LIB and WINUSER.H			    ณ
;ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

DLGPROC		TYPEDEF	PROTO STDCALL

SB_HORZ			equ	0
SB_VERT			equ	1
SB_CTL			equ	2
SB_BOTH			equ	3
SB_THUMBPOSITION	equ	4
SB_ENDSCROLL		equ	8

SW_HIDE			equ	00h
SW_SHOWNORMAL		equ	01h
SW_SHOWMINIMIZED	equ	02h
SW_SHOWMAXIMIZED	equ	03h
SW_SHOW			equ	05h
SW_RESTORE		equ	09h
SW_SHOWDEFAULT		equ	0Ah

WNDCLASSEXA		STRUCT
	cbSize		UINT		?
	style		UINT		?
	lpfnWndProc	DWORD		?
	cbClsExtra	SDWORD		?
	cbWndExtra	SDWORD		?
	hInstance	HINSTANCE	?
	hIcon		HICON		?
	hCursor		HCURSOR		?
	hbrBackground	HBRUSH		?
	lpszMenuName	LPCSTR		?
	lpszClassName	LPCSTR		?
	hIconSm		HICON		?
WNDCLASSEXA		ENDS
WNDCLASSEX		textequ	<WNDCLASSEXA>

MSG			STRUCT
	hwnd		HWND	?
	message		UINT	?
	wParam		WPARAM	?
	lParam		LPARAM	?
	time		DWORD	?
	pt		POINT	<>
MSG			ENDS
LPMSG			TYPEDEF	DWORD

GWL_ID			equ	0FFFFFFF4h

WM_CREATE		equ	0001h
WM_DESTROY		equ	0002h
WM_SIZE			equ	0005h
WM_SETTEXT		equ	000Ch
WM_PAINT		equ	000Fh
WM_CLOSE		equ	0010h
WM_ERASEBKGND		equ	0014h
WM_NOTIFY		equ	004Eh
WM_HELP			equ	0053h
WM_CHAR			equ	0102h
WM_INITDIALOG		equ	0110h
WM_COMMAND		equ	0111h
WM_TIMER		equ	0113h
WM_HSCROLL		equ	0114h
WM_VSCROLL		equ	0115h
WM_MENUSELECT		equ	011Fh
WM_CTLCOLORDLG		equ	0136h
WM_MOUSEMOVE		equ	0200h
WM_LBUTTONDOWN		equ	0201h
WM_LBUTTONUP		equ	0202h
WM_LBUTTONDBLCLK	equ	0203h
WM_RBUTTONDOWN		equ	0204h
WM_RBUTTONUP		equ	0205h
WM_RBUTTONDBLCLK	equ	0206h
WM_CUT			equ	0300h
WM_COPY			equ	0301h
WM_PASTE		equ	0302h
WM_CLEAR		equ	0303h
WM_UNDO			equ	0304h
WM_USER			equ	0400h

WS_POPUP		equ	080000000h
WS_CHILD		equ	040000000h
WS_MINIMIZE		equ	020000000h
WS_VISIBLE		equ	010000000h
WS_MAXIMIZE		equ	001000000h
WS_CAPTION		equ	000C00000h
WS_BORDER		equ	000800000h
WS_DLGFRAME		equ	000400000h
WS_VSCROLL		equ	000200000h
WS_HSCROLL		equ	000100000h
WS_SYSMENU		equ	000080000h
WS_SIZEBOX		equ	000040000h
WS_MINIMIZEBOX		equ	000020000h
WS_MAXIMIZEBOX		equ	000010000h
WS_OVERLAPPEDWINDOW	equ	000CF0000h
WS_EX_NOPARENTNOTIFY	equ	000000004h
WS_EX_WINDOWEDGE	equ	000000100h
WS_EX_CLIENTEDGE	equ	000000200h
WS_EX_OVERLAPPEDWINDOW	equ	WS_EX_WINDOWEDGE + WS_EX_CLIENTEDGE

CS_VREDRAW		equ	00001h
CS_HREDRAW		equ	00002h
CS_PARENTDC		equ	00080h
CS_BYTEALIGNWINDOW	equ	02000h

BDR_RAISEDOUTER		equ	01h
BDR_SUNKENOUTER		equ	02h
BDR_RAISEDINNER		equ	04h
BDR_SUNKENINNER		equ	08h
EDGE_RAISED		equ	BDR_RAISEDOUTER + BDR_RAISEDINNER
EDGE_SUNKEN		equ	BDR_SUNKENOUTER + BDR_SUNKENINNER
EDGE_ETCHED		equ	BDR_SUNKENOUTER + BDR_RAISEDINNER
EDGE_BUMP		equ	BDR_RAISEDOUTER + BDR_SUNKENINNER
BF_LEFT			equ	01h
BF_TOP			equ	02h
BF_RIGHT		equ	04h
BF_BOTTOM		equ	08h
BF_RECT			equ	BF_LEFT + BF_TOP + BF_RIGHT + BF_BOTTOM
DrawEdge		PROTO	WINAPI	:HDC, :LPRECT, :UINT, :UINT

PAINTSTRUCT		STRUCT
	hdc		HDC	?
	fErase		BOOL	?
	rcPaint		RECT	<>
	fRestore	BOOL	?
	fIncUpdate	BOOL	?
	rgbReserved	BYTE	32 DUP (?)
PAINTSTRUCT		ENDS
LPPAINTSTRUCT		TYPEDEF PTR PAINTSTRUCT

NMHDR			STRUCT
	hwndFrom	HWND	?
	idFrom		UINT	?
	code		UINT	?
NMHDR			ENDS

GetMessageA		PROTO	WINAPI	:LPMSG, :HWND, :UINT, :UINT
GetMessage		textequ	<GetMessageA>
TranslateMessage	PROTO	WINAPI	:LPMSG
DispatchMessageA	PROTO	WINAPI	:LPMSG
DispatchMessage		textequ	<DispatchMessageA>

PeekMessageA		PROTO	WINAPI	:LPMSG, :HWND, :UINT, :UINT, :UINT
PeekMessage		textequ	<PeekMessageA>
PM_NOREMOVE		equ	00h
PM_REMOVE		equ	01h
PM_NOYIELD		equ	02h

SendMessageA		PROTO	WINAPI	:HWND, :UINT, :WPARAM, :LPARAM
SendMessage		textequ	<SendMessageA>
PostMessageA		PROTO	WINAPI	:HWND, :UINT, :WPARAM, :LPARAM
PostMessage		textequ	<PostMessageA>
DefWindowProcA		PROTO	WINAPI	:HWND, :UINT, :WPARAM, :LPARAM
DefWindowProc		textequ	<DefWindowProcA>
PostQuitMessage		PROTO	WINAPI	:SWORD
RegisterClassExA	PROTO	WINAPI	:DWORD
RegisterClassEx		textequ	<RegisterClassExA>
CreateWindowExA		PROTO	WINAPI	:DWORD, :LPCSTR, :LPCSTR, :DWORD, :SDWORD, :SDWORD,\
					:SDWORD, :SDWORD, :HWND, :HMENU, :HINSTANCE, :DWORD
CreateWindowEx		textequ	<CreateWindowExA>
DestroyWindow		PROTO	WINAPI	:HWND
ShowWindow		PROTO	WINAPI	:HWND, :SDWORD
MoveWindow		PROTO	WINAPI	:HWND, :UINT, :UINT, :UINT, :UINT, :BOOL
SetWindowPos		PROTO	WINAPI	:HWND, :HWND, :UINT, :UINT, :UINT, :UINT, :UINT
IsIconic		PROTO	WINAPI	:HWND


CW_USEDEFAULT equ 8000h

SWP_NOSIZE		equ	001h
SWP_NOMOVE		equ	002h
SWP_NOZORDER		equ	004h
SWP_FRAMECHANGED	equ	020h
SWP_DRAWFRAME		equ	SWP_FRAMECHANGED
HWND_TOP		equ	000h

DLGTEMPLATE		STRUCT
	style		DWORD	?
	dwExtendedStyle	DWORD	?
	cdit		WORD	?
	x		SWORD	?
	y		SWORD	?
	nx		SWORD	?
	ny		SWORD	?
DLGTEMPLATE		ENDS
LPCDLGTEMPLATE		TYPEDEF	PTR LPDLGTEMPLATE

CreateDialogParamA	PROTO	WINAPI	:HINSTANCE, :LPCSTR, :HWND, :DLGPROC, :LPARAM
CreateDialogParam	textequ	<CreateDialogParamA>
DialogBoxParamA		PROTO	WINAPI	:HINSTANCE, :LPCSTR, :HWND, :DLGPROC, :LPARAM
DialogBoxParam		textequ	<DialogBoxParamA>
EndDialog		PROTO	WINAPI	:HWND, :UINT
GetDlgItem		PROTO	WINAPI	:HWND, :UINT
SetDlgItemTextA		PROTO	WINAPI	:HWND, :SDWORD, :LPCSTR
SetDlgItemText		textequ	<SetDlgItemTextA>
SendDlgItemMessageA	PROTO	WINAPI	:HWND, :UINT, :UINT, :WPARAM, :LPARAM
SendDlgItemMessage	textequ	<SendDlgItemMessageA>
DefDlgProcA		PROTO	WINAPI	:HWND, :UINT, :WPARAM, :LPARAM
DefDlgProc		textequ	<DefDlgProcA>
DLGWINDOWEXTRA		equ	00000001Eh

SetFocus		PROTO	WINAPI	:HWND
SetTimer		PROTO	WINAPI	:HWND, :UINT, :UINT, :PTR DWORD
KillTimer		PROTO	WINAPI	:HWND, :UINT
EnableWindow		PROTO	WINAPI	:HWND, :BOOL
LoadAcceleratorsA	PROTO	WINAPI	:HINSTANCE, :LPCSTR
LoadAccelerators	textequ	<LoadAcceleratorsA>
TranslateAcceleratorA	PROTO	WINAPI	:HWND, :HACCEL, :LPMSG
TranslateAccelerator	textequ	<TranslateAcceleratorA>

SM_CXSCREEN		equ	000h
SM_CYSCREEN		equ	001h
SM_CXFULLSCREEN		equ	010h
SM_CYFULLSCREEN		equ	011h
GetSystemMetrics	PROTO	WINAPI	:UINT
DrawTextA		PROTO	WINAPI	:HDC, :LPCSTR, :UINT, :LPRECT, :UINT
DrawText		textequ	<DrawTextA>
UpdateWindow		PROTO	WINAPI	:HWND
SetForegroundWindow	PROTO	WINAPI	:HWND
GetDC			PROTO	WINAPI	:HWND
ReleaseDC		PROTO	WINAPI	:HWND, :HDC
BeginPaint		PROTO	WINAPI	:HWND, :LPPAINTSTRUCT
EndPaint		PROTO	WINAPI	:HWND, :LPPAINTSTRUCT
InvalidateRect		PROTO	WINAPI	:HWND, :LPRECT, :UINT
InvalidateRgn		PROTO	WINAPI	:HWND, :HRGN, :BOOL
GetScrollPos		PROTO	WINAPI	:HWND, :UINT
SetWindowTextA		PROTO	WINAPI	:HWND, :LPCSTR
SetWindowText		textequ	<SetWindowTextA>
GetClientRect		PROTO	WINAPI	:HWND, :LPRECT
GetWindowRect		PROTO	WINAPI	:HWND, :LPRECT

DT_SINGLELINE equ 20h
DT_CENTER    equ 1
DT_VCENTER   equ 4

MB_OK			equ	000h
MB_OKCANCEL		equ	001h
MB_ABORTRETRYIGNORE	equ	002h
MB_YESNOCANCEL		equ	003h
MB_YESNO		equ	004h
MB_RETRYCANCEL		equ	005h
MB_ICONERROR		equ	010h
MB_ICONWARNING		equ	030h
MessageBoxA		PROTO	WINAPI	:HWND, :LPCSTR, :LPCSTR, :UINT
MessageBox		textequ	<MessageBoxA>

COLOR_BACKGROUND	equ	001h
COLOR_WINDOW		equ	005h
COLOR_3DFACE		equ	00Fh
COLOR_3DSHADOW		equ	010h
COLOR_APPWORKSPACE	equ	00Ch
COLOR_3DLIGHT		equ	016h
GetSysColor		PROTO	WINAPI	:UINT
FillRect		PROTO	WINAPI	:HDC, :LPRECT, :HBRUSH
GetWindowLongA		PROTO	WINAPI	:HWND, :DWORD
GetWindowLong		textequ	<GetWindowLongA>
GetDesktopWindow	PROTO	WINAPI
FindWindowA		PROTO	WINAPI	:LPCSTR, :LPCSTR
FindWindow		textequ	<FindWindowA>
GetLastActivePopup	PROTO	WINAPI	:HWND

MF_POPUP		equ	00010h
MF_SYSMENU		equ	02000h
MFT_SEPARATOR		equ	00800h

SC_SIZE			equ	0F000h
SC_MOVE			equ	0F010h
SC_MINIMIZE		equ	0F020h
SC_MAXIMIZE		equ	0F030h
SC_CLOSE		equ	0F060h
SC_RESTORE		equ	0F120h

LoadBitmapA		PROTO	WINAPI	:HINSTANCE, :LPCSTR
LoadBitmap		textequ	<LoadBitmapA>
LoadCursorA		PROTO	WINAPI	:HINSTANCE, :LPCSTR
LoadCursor		textequ	<LoadCursorA>
LoadIconA		PROTO	WINAPI	:HINSTANCE, :LPCSTR
LoadIcon		textequ	<LoadIconA>


IDI_APPLICATION equ 32512

IMAGE_BITMAP		equ	00000h
IMAGE_ICON		equ	00001h
IMAGE_CURSOR		equ	00002h
LR_LOADTRANSPARENT	equ	00020h
LR_LOADMAP3DCOLORS	equ	01000h
LoadImageA		PROTO	WINAPI	:HINSTANCE, :LPCSTR, :UINT, :UINT, :UINT, :UINT
LoadImage		textequ	<LoadImageA>

IDC_ARROW		equ	07f00h

LoadStringA		PROTO	WINAPI	:HINSTANCE, :UINT, :LPCSTR, :UINT
LoadString		textequ	<LoadStringA>

IDOK			equ	01h
IDCANCEL		equ	02h
IDABORT			equ	03h
IDRETRY			equ	04h
IDIGNORE		equ	05h
IDYES			equ	06h
IDNO			equ	07h
IDCLOSE			equ	08h
IDHELP			equ	09h

ES_LEFT			equ	000h
ES_MULTILINE		equ	004h
ES_AUTOVSCROLL		equ	040h

BM_GETCHECK		equ	0F0h
BM_SETCHECK		equ	0F1h
BM_CLICK		equ	0F5h
BM_SETIMAGE		equ	0F7h

BST_UNCHECKED		equ	00h
BST_CHECKED		equ	01h
BST_INDETERMINATE	equ	02h

SS_LEFT			equ	00h
SS_CENTER		equ	01h
SS_RIGHT		equ	02h
SS_ICON			equ	03h
SS_BLACKFRAME		equ	07h

IsDialogMessageA	PROTO	WINAPI	:HWND, :LPMSG
IsDialogMessage		textequ	<IsDialogMessageA>

DS_MODALFRAME		equ	0080h
DS_NOIDLEMSG		equ	0100h
DS_3DLOOK		equ	0004h

HELP_CONTEXT		equ	01h
HELP_QUIT		equ	02h
HELP_INDEX		equ	03h
HELP_CONTENTS		equ	03h
HELP_HELPONHELP		equ	04h
HELP_CONTEXTMENU	equ	0Ah
HELP_FINDER		equ	0Bh
HELP_WM_HELP		equ	0Ch

WinHelpA		PROTO	WINAPI	:HWND, :LPCSTR, :UINT, :DWORD
WinHelp			textequ	<WinHelpA>

;ีออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออธ
;ณ                       COMDLG32.LIB and COMMDLG.H			    ณ
;ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

OPENFILENAMEA		STRUCT
	lStructSize	DWORD		?
	hwndOwner	HWND		?
	hInstance	HINSTANCE	?
	lpstrFilter	LPCSTR		?
	lpstrCustomFilter LPSTR		?
	nMaxCustFilter	DWORD		?
	nFilterIndex	DWORD		?
	lpstrFile	LPSTR		?
	nMaxFile	DWORD		?
	lpstrFileTitle	LPSTR		?
	nMaxFileTitle	DWORD		?
	lpstrInitialDir	LPCSTR		?
	lpstrTitle	LPCSTR		?
	Flags		DWORD		?
	nFileOffset	WORD		?
	nFileExtension	WORD		?
	lpstrDefExt	LPCSTR		?
	lCustData	LPARAM		?
	lpfnHook	DWORD		?
	lpTemplateName	LPCSTR		?
OPENFILENAMEA		ENDS
LPOPENFILENAME		TYPEDEF	PTR OPENFILENAMEA
OPENFILENAME		textequ	<OPENFILENAMEA>

GetOpenFileNameA	PROTO	WINAPI	:LPOPENFILENAME
GetOpenFileName		textequ	<GetOpenFileNameA>
GetSaveFileNameA	PROTO	WINAPI	:LPOPENFILENAME
GetSaveFileName		textequ	<GetSaveFileNameA>

OFN_READONLY		equ	00000001h
OFN_OVERWRITEPROMPT	equ	00000002h
OFN_HIDEREADONLY	equ	00000004h
OFN_NOCHANGEDIR		equ	00000008h
OFN_SHOWHELP		equ	00000010h
OFN_ENABLEHOOK		equ	00000020h
OFN_ENABLETEMPLATE	equ	00000040h
OFN_ENABLETEMPLATEHANDLE equ	00000080h
OFN_NOVALIDATE		equ	00000100h
OFN_ALLOWMULTISELECT	equ	00000200h
OFN_EXTENSIONDIFFERENT	equ	00000400h
OFN_PATHMUSTEXIST	equ	00000800h
OFN_FILEMUSTEXIST	equ	00001000h
OFN_CREATEPROMPT	equ	00002000h
OFN_SHAREAWARE		equ	00004000h
OFN_NOREADONLYRETURN	equ	00008000h
OFN_NOTESTFILECREATE	equ	00010000h
OFN_NONETWORKBUTTON	equ	00020000h
OFN_NOLONGNAMES		equ	00040000h
OFN_EXPLORER		equ	00080000h
OFN_NODEREFERENCELINKS	equ	00100000h
OFN_LONGNAMES		equ	00200000h

PRINTDLGA		STRUCT
	lStructSize	DWORD	?
	hwndOwner	HWND	?
	hDevMode	HGLOBAL	?
	hDevNames	HGLOBAL	?
	hDC		HDC	?
	Flags		DWORD	?
	nFromPage	WORD	?
	nToPage		WORD	?
	nMinPage	WORD	?
	nMaxPage	WORD	?
	nCopies		WORD	?
	hInstance	HINSTANCE ?
	lCustData	DWORD	?
	lpfnPrintHook	DWORD	?
	lpfnSetupHook	DWORD	?
	lpPrintTemplateName LPCSTR ?
	lpSetupTemplateName LPCSTR ?
	hPrintTemplate	HGLOBAL	?
	hSetupTemplate	HGLOBAL	?
PRINTDLGA		ENDS
LPPRINTDLG		TYPEDEF	PTR PRINTDLGA
PRINTDLG		textequ	<PRINTDLGA>

PrintDlgA		PROTO	WINAPI	:LPPRINTDLG
PrintDlg		textequ	<PrintDlgA>

PD_ALLPAGES		equ	00000h
PD_SELECTION		equ	00001h
PD_PAGENUMS		equ	00002h
PD_NOSELECTION		equ	00004h
PD_NOPAGENUMS		equ	00008h
PD_COLLATE		equ	00010h
PD_PRINTTOFILE		equ	00020h
PD_PRINTSETUP		equ	00040h
PD_NOWARNING		equ	00080h
PD_RETURNDC		equ	00100h
PD_RETURNIC		equ	00200h
PD_RETURNDEFAULT	equ	00400h
PD_SHOWHELP		equ	00800h
PD_ENABLEPRINTHOOK	equ	01000h
PD_ENABLESETUPHOOK	equ	02000h
PD_ENABLEPRINTTEMPLATE	equ	04000h
PD_ENABLESETUPTEMPLATE	equ	08000h
PD_ENABLEPRINTTEMPLATEHANDLE	equ	0010000h
PD_ENABLESETUPTEMPLATEHANDLE	equ	0020000h
PD_USEDEVMODECOPIES		equ	0040000h
PD_USEDEVMODECOPIESANDCOLLATE	equ	0040000h
PD_DISABLEPRINTTOFILE		equ	0080000h
PD_HIDEPRINTTOFILE		equ	0100000h
PD_NONETWORKBUTTON		equ	0200000h

CommDlgExtendedError	PROTO	WINAPI

PAGESETUPDLGA		STRUCT
	lStructSize	DWORD	?
	hwndOwner	HWND	?
	hDevMode	HGLOBAL	?
	hDevNames	HGLOBAL	?
	Flags		DWORD	?
	ptPaperSize	POINT	<>
	rtMinMargin	RECT	<>
	rtMargin	RECT	<>
	hInstance	HINSTANCE ?
	lCustData	LPARAM	?
	lpfnPageSetupHook	DWORD	?
	lpfnPagePaintHook	DWORD	?
	lpPageSetupTemplateName LPCSTR	?
	hPageSetupTemplate	HGLOBAL	?
PAGESETUPDLGA		ENDS
LPPAGESETUPDLG		TYPEDEF	PTR PAGESETUPDLGA
PAGESETUPDLG		textequ	<PAGESETUPDLGA>

PageSetupDlgA		PROTO	WINAPI	:LPPAGESETUPDLG
PageSetupDlg		textequ	<PageSetupDlgA>

PSD_DEFAULTMINMARGINS		equ	0000000h
PSD_MINMARGINS			equ	0000001h
PSD_MARGINS			equ	0000002h
PSD_INTHOUSANDTHSOFINCHES	equ	0000004h
PSD_INHUNDREDTHSOFMILLIMETERS	equ	0000008h
PSD_DISABLEMARGINS		equ	0000010h
PSD_DISABLEPRINTER		equ	0000020h
PSD_NOWARNING			equ	0000080h
PSD_DISABLEORIENTATION		equ	0000100h
PSD_DISABLEPAPER		equ	0000200h
PSD_RETURNDEFAULT		equ	0000400h
PSD_SHOWHELP			equ	0000800h
PSD_ENABLEPAGESETUPHOOK		equ	0002000h
PSD_ENABLEPAGESETUPTEMPLATE	equ	0008000h
PSD_ENABLEPAGESETUPTEMPLATEHANDLE equ	0020000h
PSD_ENABLEPAGEPAINTHOOK		equ	0040000h
PSD_DISABLEPAGEPAINTING		equ	0080000h
PSD_NONETWORKBUTTON		equ	0200000h

;ีออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออธ
;ณ                       COMCTL32.LIB and COMMCTRL.H			    ณ
;ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

InitCommonControls	PROTO	WINAPI

TBBUTTON		STRUCT
	iBitMap		SDWORD	?
	idCommand	SDWORD	?
	fsState		BYTE	?
	fsStyle		BYTE	?
	dwData		DWORD	?
	iString		SDWORD	?
TBBUTTON		ENDS
LPCTBBUTTON		TYPEDEF	PTR TBBUTTON

CreateToolbarEx		PROTO	WINAPI	:HWND, :DWORD, :UINT, :SDWORD,\
					:HINSTANCE, :UINT, :LPCTBBUTTON,\
					:SDWORD, :SDWORD, :SDWORD,\
					:SDWORD, :SDWORD, :UINT
TBSTATE_ENABLED		equ	4h
TBSTYLE_BUTTON		equ	0h
TBSTYLE_SEP		equ	1h
TBSTYLE_TOOLTIPS	equ	0100h

TB_ADDBITMAP		equ	WM_USER + 13h

TBADDBITMAP	STRUCT
	hInst	HINSTANCE	?
	nID	UINT		?
TBADDBITMAP	ENDS

HINST_COMMCTRL		equ	-1h
IDB_STD_SMALL_COLOR	equ	00h

STD_CUT			equ	00h
STD_COPY		equ	01h
STD_PASTE		equ	02h
STD_UNDO		equ	03h
STD_REDOW		equ	04h
STD_DELETE		equ	05h
STD_FILENEW		equ	06h
STD_FILEOPEN		equ	07h
STD_FILESAVE		equ	08h
STD_PRINTPRE		equ	09h
STD_PROPERTIES		equ	0Ah
STD_HELP		equ	0Bh
STD_FIND		equ	0Ch
STD_REPLACE		equ	0Dh
STD_PRINT		equ	0Eh

TTN_FIRST		equ	-520
TTN_NEEDTEXT		equ	TTN_FIRST - 0

TOOLTIPTEXTA		STRUCT
	hdr		NMHDR	<>
	lpszText	LPSTR	?
	szText		SBYTE	80 DUP (?)
	hinst		HINSTANCE ?
	uFlags		UINT	?
TOOLTIPTEXTA		ENDS
LPTOOLTIPTEXT		TYPEDEF	PTR TOOLTIPTEXTA
TOOLTIPTEXT		textequ	<TOOLTIPTEXTA>

CreateStatusWindow	PROTO	WINAPI	:LONG, :LPCSTR, :HWND, :UINT

SB_SETTEXTA		equ	(WM_USER+1)
SB_SETTEXT		equ	SB_SETTEXTA
SB_SIMPLE		equ	(WM_USER+9)
SBT_NOBORDERS		equ	0100h
SBT_POPOUT		equ	0200h

TBM_GETPOS		equ	(WM_USER)
TBM_SETPOS		equ	(WM_USER+5)
TBM_SETRANGE		equ	(WM_USER+6)
TBM_SETTICFREQ		equ	(WM_USER+20)
TBM_SETPAGESIZE		equ	(WM_USER+21)
TB_LINEUP		equ	00h
TB_LINEDOWN		equ	01h
TB_PAGEUP		equ	02h
TB_PAGEDOWN		equ	03h
TB_THUMBPOSITION	equ	04h
TB_THUMBTRACK		equ	05h
TB_TOP			equ	06h
TB_BOTTOM		equ	07h
TB_ENDTRACK		equ	08h

UDM_SETRANGE		equ	(WM_USER+101)
UDM_SETPOS		equ	(WM_USER+103)
UDM_GETPOS		equ	(WM_USER+104)

;ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
;ณ                       END OF THE WINDOWS.INC FILE			    ณ
;ิออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออพ

