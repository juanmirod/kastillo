;*****************************************************************
;  Nombre:    Juan Miguel
;  Apellidos: Rodr¡guez Cer¢n
;  D.N.I.:    74879016
;
;  I.T.I.S. 2§ A
;******************************************************************

;******************************************************************
;   MODULO PARA EL MOVIMIENTO DEL KOKO Y DEL FANTASMA
;------------------------------------------------------------------
; En este m¢dulo se implementan las siguientes funciones:
;
; * Signo(numero)    .- devuelve en AX el signo del n£mero (1 si <0 y -1 si >0)
; * Absoluto(numero) .- devuelve en AX el valor absoluto
;                       de n£mero (AX <- |numero|)
; * Random(@semilla) .- devuelve un n£mero aleatorio segun las
;                       semilla q se le pasa por referencia
; * Mov_koko         .- mueve el koko en la direcci¢n indicada por su vector
;                       de movimiento
; * Mov_fan          .- mueve al fantasma . . .
;
;  (Para m s informaci¢n ver la cabecera de cada funci¢n y los comentarios
;   en su interior)
;------------------------------------------------------------------
;
;******************************************************************

  ente struc

       X db ?               ; - coordenada X
       Y db ?               ; - coordenada Y
       oldX db ?            ;
       oldY db ?            ;
       Cprev db ?           ; - caracter anterior
       Aprev db ?           ; - atributo anterior

  ente ends

;------------------------------------------------
; IMPORTACION DE VARIABLES GLOBALES
;------------------------------------------------

  EXTRN koko:BYTE
  EXTRN fantasma:BYTE
  EXTRN atrib_koko:BYTE
  EXTRN caracter_koko:BYTE
  EXTRN atrib_fantasma:BYTE
  EXTRN caracter_fantasma:BYTE
  EXTRN atrib_moneda:BYTE
  EXTRN caracter_moneda:BYTE
  EXTRN atrib_obst:BYTE
  EXTRN caracter_obst:BYTE
  EXTRN dir_fila_koko:BYTE
  EXTRN dir_colu_koko:BYTE
  EXTRN dir_fila_fantasma:BYTE
  EXTRN dir_colu_fantasma:BYTE
  EXTRN pagina:WORD
  EXTRN modo:BYTE
  EXTRN FinDeJuego:BYTE
  EXTRN monedas:BYTE
  EXTRN jugadores:BYTE

;-----------------------------------------------
;  FUNCIONES EXTERNAS
;-----------------------------------------------

  include ks_mac.asm
  extrn escribe:far
  extrn lee:far
  extrn son:far

;--------------------------
; SEGMENTO DE CODIGO
;--------------------------

CODIGOM SEGMENT

   ASSUME CS:CODIGOM

;-------------------------------

 PUBLIC SIGNO

;funci¢n q devuelve en AX 1 si numero<0
; y -1 si numero>0
; el numero q se pasa como par debe ser un word
;------------------------------------------------

 SIGNO PROC FAR

   push BP
   mov BP, SP

   push BX

        mov BX, word PTR [BP+6]

        cmp BX, 0
        jl dev_neg
        jmp dev_pos

        dev_neg: mov AX, -1
                 jmp fin_signo

        dev_pos: mov AX, 1
                 jmp fin_signo

        fin_signo:

   pop BX

   pop BP

  ret 2

 SIGNO ENDP

;-------------------------------------

 PUBLIC ABSOLUTO

; funci¢n q devuelve en AX el valor absoluto del
; n£mero q se le pasa como £nico argumento
;--------------------------------------------------

 ABSOLUTO PROC FAR

     push BP
     mov BP, SP

     push BX

          mov BX, [BP+6]

          cmp BX, 0000h
          jl si_es_neg
          jmp fin_abs

          si_es_neg: neg BX  ; le quita el signo

          fin_abs: mov AX, BX

     pop BX

     pop BP

   ret 2

 ABSOLUTO ENDP

;--------------------------------------

 PUBLIC RANDOM

; funci¢n q dada una semilla como par metro (por referencia)
; devuelve un n£mero aleatorio en [0, Rango-1] (parametro por valor)
; en AX
;--------------------------------------------------------

  PRANDOM STRUC

   BPOLDRA   DW ?
   RETORNORA DD ?
   SEMILLA   DD ?
   RANGO     DW ?

  PRANDOM ENDS

;--------------------------

 RANDOM PROC FAR

    push BP
    mov BP, SP

    push BX
    push DX
    push ES
    push SI

         mov AX, 0040h     ;
         mov ES, AX        ;> pone en AX el valor del contador de ticks
         mov SI, 006Ch     ;    (solo la palabra menos significativa)
         mov AX, ES:SI     ;

         LES SI, [BP].SEMILLA    ; ES:SI apunta a la variable q contiene
         mov BX, [BP].RANGO      ; la semilla  y BX contiene el rango

         add AX, ES:SI     ; suma al valor del contador de ticks la semilla
         shl AX, 4         ; transforma el resultado de la suma

         mov ES:SI, AX     ; actualiza la semilla

         mov DX, 0000h
         div BX            ; AX contiene el numero aleatorio modulo rango
         mov AX, DX        ;

    pop SI
    pop ES
    pop DX
    pop BX

    pop BP

  ret 6

 RANDOM ENDP

;-------------------------------------

 PUBLIC MOV_KOKO

; controla el movimientro del koko
;-------------------------------------

 MOV_KOKO PROC FAR

     push BP
     mov BP, SP

     push AX
     push BX
     push CX
     push SI
     push DS

          mov AX, seg koko
          mov DS, AX              ; DS contiene el segmento
          mov SI, offset koko     ; SI contiene la direcci¢n del koko

          mov AL, [SI].X        ;
          mov [SI].oldX, AL     ;> guarda la antigua posici¢n del koko
                                ;
          mov AH, [SI].Y        ;
          mov [SI].oldY, AH     ;

          mov BL, [dir_fila_koko]  ;
          add [SI].X, BL           ;> suma el vector de direcci¢n a la
                                   ;    posici¢n actual, obteniendo
          mov BH, [dir_colu_koko]  ;      la posici¢n siguiente
          add [SI].Y, BH           ;

          ; miramos q hay en la nueva posici¢n del koko para comprobar
          ; q no hay un obst culo

           mov CX, 12d
           push CX
           mov CX, 0b1h
           push CX
           mov CX, [pagina]
           push CX
           mov CH, 00h
           mov CL, [SI].X
           push CX
           mov CL, [SI].Y
           push CX
           call lee

           cmp AX, 1
           jne se_puede
           jmp nose_puede

           ; si se puede comprobamos si hay una moneda para
           ; restar uno al contador de monedas
           se_puede:
                     mov CX, 14d
                     push CX
                     mov CX, 07h
                     push CX
                     mov CX, [pagina]
                     push CX
                     mov CH, 00h
                     mov CL, [SI].X
                     push CX
                     mov CL, [SI].Y
                     push CX
                     call lee

                     cmp AX, 1         ; si hab¡a una moneda
                     je rest_cont      ; resta uno al contador
                     jmp es_meta       ; sino comprueba si ha llegado a meta

                     rest_cont:
                                DEC monedas

                                mov AX, 200d
                                push AX
                                mov AX, 5
                                push AX
                                call son
                                jmp finmov_koko

                     es_meta:
                              mov CX, 14d
                              push CX
                              mov CX, 0B1h
                              push CX
                              mov CX, [pagina]
                              push CX
                              mov CH, 00h
                              mov CL, [SI].X
                              push CX
                              mov CL, [SI].Y
                              push CX
                              call lee

                              cmp AX, 1
                              je acaba
                              jmp finmov_koko

                              acaba:
                                     cmp [monedas], word ptr 00h
                                     je gana_koko
                                     jmp pierde_koko

                                     gana_koko: mov [FinDeJuego], byte ptr 1d
                                                jmp finmov_koko

                                   pierde_koko: mov [FinDeJuego], byte ptr 2d
                                                jmp finmov_koko

           ; si hab¡a un obst culo el koko tendr  q girar...
           ; esto se hace intercambiando las componentes del vector
           ; de direcci¢n
           nose_puede:
                      mov AX, 350d    ;
                      push AX         ;> sonido de chocar
                      mov AX, 5       ;
                      push AX         ;
                      call son        ;

                      mov [dir_fila_koko], BH  ; intercambia las coordenadas
                      mov [dir_colu_koko], BL  ; del vector direccion
                                               ; (q se encontraban en BX)

                      mov AL, [SI].oldX        ; recupera la antigua posici¢n
                      mov AH, [SI].oldY        ; del koko

                      add AL, [dir_fila_koko]  ; obtiene la nueva posici¢n
                      add AH, [dir_colu_koko]  ; del koko

                      mov [SI].X, AL           ; actualiza las variables
                      mov [SI].Y, AH           ; del koko

                      ; volvemos a comprobar si la posici¢n es correcta
                      mov CX, 12d
                      push CX
                      mov CX, 0b1h
                      push CX
                      mov CX, [pagina]
                      push CX
                      mov CH, 00h
                      mov CL, [SI].X
                      push CX
                      mov CL, [SI].Y
                      push CX
                      call lee

                      cmp AX, 1
                      je sigue_sinpoder
                      jmp se_puede

               ; si aun no se puede es q nos encontramos en una esquina
               ; por tanto habr  q cambiar el signo de los componentes
               ; del vector
               sigue_sinpoder:

                      mov AL, [SI].oldX        ; recupera la antigua posici¢n
                      mov AH, [SI].oldY        ; del koko

                      neg [dir_fila_koko]      ; obtiene el nuevo vector
                      neg [dir_colu_koko]      ; de direccion del koko

                      add AL, [dir_fila_koko]  ; obtiene la nueva posici¢n
                      add AH, [dir_colu_koko]  ; del koko

                      mov [SI].X, AL           ; actualiza las variables
                      mov [SI].Y, AH           ; del koko

                      ; volvemos a comprobar si la posici¢n es correcta
                      mov CX, 12d
                      push CX
                      mov CX, 0b1h
                      push CX
                      mov CX, [pagina]
                      push CX
                      mov CH, 00h
                      mov CL, [SI].X
                      push CX
                      mov CL, [SI].Y
                      push CX
                      call lee

                      cmp AX, 1
                      je sigue_sinpoder2
                      jmp se_puede

               ; si aun no se puede mover quiere decir q el koko
               ; est  en un callej¢n sin salida (entre 3 obs)
               sigue_sinpoder2:
                      mov BL, [dir_fila_koko]  ; intercambia las coordenadas
                      mov BH, [dir_colu_koko]  ; del vector direccion
                                               ; qdando este igual q al prin.
                      mov [dir_fila_koko], BH  ; pero con signo inverso
                      mov [dir_colu_koko], BL  ; (el koko "rebota")

                      mov AL, [SI].oldX        ; recupera la antigua posici¢n
                      mov AH, [SI].oldY        ; del koko

                      add AL, [dir_fila_koko]  ; obtiene la nueva posici¢n
                      add AH, [dir_colu_koko]  ; del koko

                      mov [SI].X, AL           ; actualiza las variables
                      mov [SI].Y, AH           ; del koko

                      jmp se_puede

         finmov_koko:

         BORRA [SI].oldX, [SI].oldY, [pagina]
         ESCRIBELO 09D, 02h, [pagina], [SI].X, [SI].Y

     pop DS
     pop SI
     pop CX
     pop BX
     pop AX

     pop BP

     ret

 MOV_KOKO ENDP

;-------------------------------------

 PUBLIC MOV_FAN

; controla el movimiento del fantasma
;-------------------------------------

 MOV_FAN PROC FAR

     push BP
     mov BP, SP

     push AX
     push BX
     push CX
     push DX
     push SI
     push DI
     push DS

          mov AX, seg koko
          mov DS, AX              ; DS contiene el segmento
          mov SI, offset koko     ; SI contiene la direcci¢n del koko

          mov DI, offset fantasma ; DS:DI contiene la direc. de la
                                  ; estructura del fantasma

          mov AL, [SI].X     ; resta a la fila del koko la fila
          sub AL, [DI].X     ; del fantasma y lo mete en AL
                             ;
          mov AH, [SI].Y     ; AX = coord_koko - coord_fantasma
          sub AH, [DI].Y     ;

          cmp AX, 0000h                  ;
          jne no_come_koko               ;> comprueba si ha pillado
          jmp come_koko                  ;         al koko

         no_come_koko:

         BORRA [DI].X, [DI].Y, [pagina]
         ESCRIBELO [DI].Aprev, [DI].Cprev, [pagina], [DI].X, [DI].Y


;--------------si est  en modo 1 jugador: algoritmo q persigue al koko

          cmp [jugadores], byte ptr 1
          je busca_koko
          jmp fin_busca

          busca_koko: cmp AL, 00h
                      je misma_fila
                      cmp AH, 00h
                      je misma_colu
                      jmp misma_nada


             misma_fila: cmp AH, 00h
                         jg a_la_der
                         jmp a_la_izq

                      a_la_der: mov [dir_fila_fantasma],byte ptr 0
                                mov [dir_colu_fantasma],byte ptr 1
                                jmp fin_busca

                      a_la_izq: mov [dir_fila_fantasma],byte ptr 0
                                mov [dir_colu_fantasma],byte ptr -1
                                jmp fin_busca

             misma_colu: cmp AL, 00h
                         jg ve_abajo
                         jmp ve_arriba

                      ve_abajo: mov [dir_fila_fantasma],byte ptr 1
                                mov [dir_colu_fantasma],byte ptr 0
                                jmp fin_busca

                      ve_arriba: mov [dir_fila_fantasma],byte ptr -1
                                 mov [dir_colu_fantasma],byte ptr  0
                                 jmp fin_busca

             misma_nada: mov CX, AX    ; salvaguarda AX en CX

                         cbw
                         push AX
                         call ABSOLUTO ; hace el valor absoluto de Dfila

                         mov BX, AX    ; y lo mete en BX

                         mov AL, CH
                         cbw
                         push AX
                         call ABSOLUTO ; hace el valor absoluto de Dcolu

                         cmp AX, BX
                         jle BXmayorAX
                         jmp AXmayorBX

                         ; si Dfila>Dcolu (A>B)
                     BXmayorAX:
                                mov AL, CL
                                cbw
                                push AX
                                call signo

                                mov [dir_fila_fantasma], AL
                                mov [dir_colu_fantasma], 0

                                jmp fin_busca

                         ; si Dcolu>=Dfila (A<=B)
                     AXmayorBX:
                                mov AL, CH
                                cbw
                                push AX
                                call signo

                                mov [dir_fila_fantasma], 0
                                mov [dir_colu_fantasma], AL

          fin_busca:

          mov AL, [DI].X        ;
          mov [DI].oldX, AL     ;> guarda la antigua posici¢n del
                                ;  fantasma
          mov AH, [DI].Y        ;
          mov [DI].oldY, AH     ;

          mov BL, [dir_fila_fantasma]  ;
          add [DI].X, BL               ;> suma el vector de direcci¢n a la
                                       ;    posici¢n actual, obteniendo
          mov BH, [dir_colu_fantasma]  ;      la posici¢n siguiente
          add [DI].Y, BH               ;

          ; miramos q hay en la nueva posici¢n del fantasma para comprobar
          ; q no hay un obst culo

           mov CX, 12d
           push CX
           mov CX, 0b1h
           push CX
           mov CX, [pagina]
           push CX
           mov CH, 00h
           mov CL, [DI].X
           push CX
           mov CL, [DI].Y
           push CX
           call lee

           cmp AX, 1
           jne se_puedef
           jmp nose_puedef

           ; si se puede comprobamos si hay una moneda para
           ; guardarla y restaurarla cuando ande
           se_puedef:
                     mov CX, 14d
                     push CX
                     mov CX, 07h
                     push CX
                     mov CX, [pagina]
                     push CX
                     mov CH, 00h
                     mov CL, [DI].X
                     push CX
                     mov CL, [DI].Y
                     push CX
                     call lee

                     cmp AX, 1         ; si hab¡a una moneda
                     je monedaf        ; la guarda en Cprev y Aprev
                     jmp no_monedaf    ; sino pone en estos campos un espacio

                        monedaf: mov [DI].Cprev, 07h
                                 mov [DI].Aprev, 14d
                                 jmp fin_mov_fan

                     no_monedaf:
                                 mov CX, 14d
                                 push CX
                                 mov CX, 0b1h
                                 push CX
                                 mov CX, [pagina]
                                 push CX
                                 mov CH, 00h
                                 mov CL, [DI].X
                                 push CX
                                 mov CL, [DI].Y
                                 push CX
                                 call lee

                                 cmp AX, 1
                                 je guarda_meta
                                 jmp guarda_spacio

                                 guarda_meta:

                                        mov [DI].Cprev, BYTE PTR 0b1h
                                        mov [DI].Aprev, BYTE PTR 14d
                                        jmp fin_mov_fan

                                 guarda_spacio:

                                        mov [DI].Cprev, BYTE PTR 00h
                                        mov [DI].Aprev, BYTE PTR 07h
                                        jmp fin_mov_fan

           ; si hab¡a un obst culo el fantasma tendr  q girar...
           ; esto se hace intercambiando las componentes del vector
           ; de direcci¢n
           nose_puedef:
                  mov [dir_fila_fantasma], BH  ; intercambia las coordenadas
                  mov [dir_colu_fantasma], BL  ; del vector direccion
                                               ; (q se encontraban en BX)

                  mov AL, [DI].oldX        ; recupera la antigua posici¢n
                  mov AH, [DI].oldY        ; del fantasma

                  add AL, [dir_fila_fantasma]  ; obtiene la nueva posici¢n
                  add AH, [dir_colu_fantasma]  ; del fantasma

                  mov [DI].X, AL           ; actualiza las variables
                  mov [DI].Y, AH           ; del fantasma

                      ; volvemos a comprobar si la posici¢n es correcta
                      mov CX, 12d
                      push CX
                      mov CX, 0b1h
                      push CX
                      mov CX, [pagina]
                      push CX
                      mov CH, 00h
                      mov CL, [DI].X
                      push CX
                      mov CL, [DI].Y
                      push CX
                      call lee

                      cmp AX, 1
                      je sigue_sinpoderf
                      jmp se_puedef

               ; si aun no se puede es q nos encontramos en una esquina
               ; por tanto habr  q cambiar el signo de los componentes
               ; del vector
               sigue_sinpoderf:

                  mov AL, [DI].oldX        ; recupera la antigua posici¢n
                  mov AH, [DI].oldY        ; del fantasma

                  neg [dir_fila_fantasma]      ; obtiene el nuevo vector
                  neg [dir_colu_fantasma]      ; de direccion del fantasma

                  add AL, [dir_fila_fantasma]  ; obtiene la nueva posici¢n
                  add AH, [dir_colu_fantasma]  ; del fantasma

                  mov [DI].X, AL           ; actualiza las variables
                  mov [DI].Y, AH           ; del fantasma

                      ; volvemos a comprobar si la posici¢n es correcta
                      mov CX, 12d
                      push CX
                      mov CX, 0b1h
                      push CX
                      mov CX, [pagina]
                      push CX
                      mov CH, 00h
                      mov CL, [DI].X
                      push CX
                      mov CL, [DI].Y
                      push CX
                      call lee

                      cmp AX, 1
                      je sigue_sinpoder2f
                      jmp se_puedef

               ; si aun no se puede mover quiere decir q el koko
               ; est  en un callej¢n sin salida (entre 3 obs)
               sigue_sinpoder2f:
                  mov BL, [dir_fila_fantasma]  ; intercambia las coordenadas
                  mov BH, [dir_colu_fantasma]  ; del vector direccion
                                               ; con lo q qda igual
                  mov [dir_fila_fantasma], BH  ; q al principio pero con
                  mov [dir_colu_fantasma], BL  ; signo inverso

                  mov AL, [DI].oldX        ; recupera la antigua posici¢n
                  mov AH, [DI].oldY        ; del fantasma

                  add AL, [dir_fila_fantasma]  ; obtiene la nueva posici¢n
                  add AH, [dir_colu_fantasma]  ; del fantasma

                  mov [DI].X, AL           ; actualiza las variables
                  mov [DI].Y, AH           ; del fantasma

                  jmp se_puedef

         ; una vez calculada la nueva posici¢n del fantasma
         ; borramos el fantasma en su posici¢n anterior
         ; escribimos lo q hubiera antes de estar el fantasma
         ; y escribimos el fantasma en su nueva posici¢n

         fin_mov_fan:

          mov AL, [SI].X     ; resta a la fila del koko la fila
          sub AL, [DI].X     ; del fantasma y lo mete en AL
                             ;
          mov AH, [SI].Y     ; AX = coord_koko - coord_fantasma
          sub AH, [DI].Y     ;

          cmp AX, 0000h                  ;
          je come_koko                   ;> comprueba si ha pillado
          jmp muevelo_ya                 ;
                                         ;         al koko
          come_koko: mov FinDeJuego, 2   ;

         muevelo_ya:
         ESCRIBELO [atrib_fantasma], [caracter_fantasma], [pagina], [DI].X, [DI].Y

     pop DS
     pop DI
     pop SI
     pop DX
     pop CX
     pop BX
     pop AX

     pop BP

   ret

 MOV_FAN ENDP

CODIGOM ENDS
        END
                                                 