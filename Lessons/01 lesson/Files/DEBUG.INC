; Include for Debug.

; FatalError & FatalErrorGLE are mentionned here for documentation.
; Both should not be prototypes as they are defined in the MUSTBE set
; of macros.

;FatalError      PROTO C \
;                  lpAbendMessage:DWORD,
;                  Formatparms:VARARG
;FatalErrorGLE   PROTO C \
;                  lpAbendMessage:DWORD,
;                  Formatparms:VARARG

FatalErrorInit  PROTO \
                  lpTitleName:DWORD


GetSectionData  PROTO Address:DWORD,
                      lpszModuleName:DWORD,
                      lpszSectionBuffer:DWORD

GetCodeBase     PROTO lpszModuleName:DWORD
GetDataBase     PROTO lpszModuleName:DWORD
GetPEHeader     PROTO lpszModuleName:DWORD
