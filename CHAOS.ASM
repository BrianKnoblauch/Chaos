;=============================================================================
;FILE:  chaos.asm
;=============================================================================

include         MODEL.INC

.codeseg        lib
.extrn          start:auto, exit:auto, exit_ok:auto
.extrn          rand_init:auto, randr_w:auto
.ends


.dataseg
.ends


IF NOT __TINY__
.stackseg
                db      1024 dup(?)     ;define a 1024 byte stack
.ends
ENDIF


;=============================================================================
;FUNC:  MAIN
;
;DESC:  Main body of program.
;
;IN:    DX              segment address of PSP
;
;ASUMS: DS,ES           @DATASEG  (same as @CODESEG in TINY model)
;       SS@STACKSEG (same as @CODESEG in TINY model)
;=============================================================================

.codeseg

IF __TINY__
assume          cs:@codeseg, ds:@dataseg, es:@dataseg, ss:@dataseg
ELSE
assume          cs:@codeseg, ds:@dataseg, es:@dataseg, ss:@stackseg
ENDIF

.public         main
.proc           main            auto
                mov     ax,0012h
                int     10h
                call    rand_init
                mov     cx,319
                mov     dx,239
again:          mov     bx,3
                call    randr_w
                cmp     ax,1
                jb      zero
                je      one
                add     cx,639
                shr     cx,1
                add     dx,479
                shr     dx,1
                mov     al,4
                jmp     continue
zero:           add     cx,319
                shr     cx,1
                shr     dx,1
                mov     al,1
                jmp     continue
one:            shr     cx,1
                add     dx,479
                shr     dx,1
                mov     al,2
continue:       mov     ah,0ch
                int     10h
                mov     ah,01h
                int     16h
                jz      again
                mov     ax,0003h
                int     10h
                xor     ah,ah
                int     16h
                ret                     ;exit to DOS with ERRORLEVEL=0
.endp           main

;----------------------------------------------------------
; Declare additional functions here...
;----------------------------------------------------------

.ends







;=============================================================================
; Stack normalization and memory management initialization labels
;
; NOTE: These declarations must remain after the declaration of the stack
; and anything in the stack segment. These labels define the end of the
; stack and the program, which is where the near and far heaps are placed
; by default. These declarations do not affect the size of the program and
; may be left here even if the stack is not normalized and the heaps are
; not used.
;=============================================================================

.public         nheap_default, fheap_default
IF NOT __TINY__
.stackseg
  IF __SMALL__ OR __MEDIUM__
.public         stack_end               ;used by START to normalize stack
.label          stack_end       word    ;must be defined past entire stack
  ENDIF
.label          nheap_default   word    ;used by the near heap
.label          fheap_default   word    ;used by the far heap
.ends
ELSE
_BSSEND         segment byte public 'STACK'
.label          nheap_default   word    ;used by the near heap
.label          fheap_default   word    ;used by the far heap
_BSSEND         ends
% @codeseg      group   _BSSEND
ENDIF


                end     start           ;specify START as starting address
