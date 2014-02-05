;x*******************************************************************
;  Nombre:    Juan Miguel
;  Apellidos: Rodr¡guez Cer¢n
;  D.N.I.:    74879016
;
;  I.T.I.S. 2§ A
;********************************************************************

;********************************************************************
;   MACROS DE USO GLOBAL/GENERAL
;--------------------------------------------------------------------
; En el m¢dulo se implementan las macros siguientes:
;
; * PON_PAG p gina  .- Establece "p gina" como p gina activa
; * ESCRIBELO atributo, caracter, p gina, fila, columna .- ver sig.
; * BORRA fila, columna, p gina .- estas macros hacen uso de la funcion
;   "escribe", pero no aportan ning£n cambio, su utilidad es hacer
;   el c¢digo m s legible
;
;  (Para m s informaci¢n ver los comentarios en cada macro)
;********************************************************************

;------------------------

 PON_PAG MACRO pagina

; cambia de p gina activa
;-------------------------------------------

  push AX
  push SI
  push DI
  push BP
  push BX

   mov BX, SP
   mov AH, 05h
   mov AL, byte ptr pagina
   int 10h

  pop BX
  pop BP
  pop DI
  pop SI
  pop AX

 ENDM

;-------------------------------

 ESCRIBELO MACRO atributo, caracter, pagina, fila, columna

; cabezera de la llamada a la rutina escribe
;----------------------------------------------------------
 push AX

      mov AX, word ptr atributo
      push AX
      mov AX, word ptr caracter
      push AX
      mov AX, word ptr pagina
      push AX
      mov AX, word ptr fila
      push AX
      mov AX, word ptr columna
      push AX
      call escribe

 pop AX

 endm

;-------------------------------

 BORRA MACRO fila, columna, pagina

; Pone un espacio en la posici¢n y la p gina indicadas
; borrando lo q hubiera anteriormente
;-------------------------------------------------------

  push AX

       mov AX, 8d
       push AX
       mov AX, 0000h
       push AX
       mov AX, word ptr pagina
       push AX
       mov AX, word ptr fila
       push AX
       mov AX, word ptr columna
       push AX
       call escribe

  pop AX

 ENDM
