;*****************************************************************
;  Nombre:    Juan Miguel
;  Apellidos: Rodr¡guez Cer¢n
;  D.N.I.:    74879016
;
;  I.T.I.S. 2§ A
;******************************************************************

;Subrutina SON                        
;------------------------------------
;Descripci¢n:
;  Genera un sonido de la frecuencia
;  resultante de dividir 1.19MHz
;  entre el parametro de entrada : p1.
;  El parametro p2 indica la duracion
;  del sonido en centesimas de
;  segundo.

;------------------------------------
;Par metros:
params     struc   ;
           dw ?    ;bp antiguo
dirret     dd ?    ;direccion de retorno.
p2         dw ?    ;segundo parametro |> los d¢s par metros se pasan por
p1         dw ?    ;primer parametro  |  valor
params     ends

;------------------------------------
;S¡mbolos
puertob    EQU 61H ;Puerto B del PPI
ck2        EQU 42H ;Canal 2 del 8253
ckreg      EQU 43H ;Registro control

NPAR       EQU 2


;------------------------------------
;Macros: Retardo para AT
     include ks_ret.asm


;------------------------------------
;Codigo
CODIGO SEGMENT
      ASSUME CS:CODIGO
      public son
SON   PROC  FAR
INI:  push  bp      ;guardar bp
      mov   bp,sp

;Salvar registros
      push  es      ;salvaguardar
      push  si      ;registros
      push  cx
      push  ax

;Recoger parametros
                       ;recuperar
                       ;primer par m.
      mov   cx,[bp].p1 ;en cx

      ;PROGRAMACION DEL PIT:
      ;-Pone el canal 2 en modo 3:
      ;(contador binario):
      ;10 11 011 0=B6h
      mov   al,0B6h
      out   ckreg,al
      ;-Carga valor de cuenta CR low:
      mov   al,cl
      out   ck2,al
      ;-Carga valor de cuenta CR high:
      mov   al,ch
      out   ck2,al

      ;Habilita puerta NAND y GATE2
      in    al,puertob
      or    al,3
      out   puertob,al

                        ;Recoger 2§
      mov   cx, [bp].p2 ;par metro
                        ;(duraci¢n)
      retarat cx   ;Retardo para AT

      ;Desconexion del altavoz (para
      ;que no se quede pitando):
      ;Inhabilita puerta NAND y GATE
      in    al,puertob
      and   al,0FCh
      out   puertob,al

;Recupera registros:
salir:pop   ax
      pop   cx
      pop   si
      pop   es
      mov   sp,bp
      pop   bp

;Desalojar parametros:
      ret   4

SON     ENDP
CODIGO  ENDS
;------------------------------------
        END
                                    