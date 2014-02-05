;*****************************************************************
;  Nombre:    Juan Miguel
;  Apellidos: Rodr¡guez Cer¢n
;  D.N.I.:    74879016
;
;  I.T.I.S. 2§ A
;******************************************************************

;******************************************************************
;  MODULO CON LAS RUTINAS DE PANTALLA
;------------------------------------------------------------------
; Rutinas disponibles: (con una peque¤a indicaci¢n de su funci¢n)
;
; * pon_cadena   .- pone una cadena con atributo en pantalla
; * tostring     .- pasa a cadena un natural
; * escribe      .- escribe un caracter en pantalla
; * lee          .- comprueba si un caracter est  en una pos. de pantalla
; * limpia       .- limpia una p gina de pantalla
; * reloj        .- pone un reloj en pantalla
; * cuenta_carac .- cuenta las veces q aparece un caracter en una p gina
; * autopinta    .- pinta la mazmorra por defecto
; * pintamano    .- permite al usuario pintar la mazmorra
; * menu         .- pone el menu en pantalla
;
; A continuaci¢n se encuentan las descripciones de las rutinas y
; las estructuras de los par metros recibidos por cada una
;------------------------------------------------------------------
;
;******************************************************************

  include ks_mac.asm
  include ks_maz.asm

  extrn menu0:BYTE
  extrn menu1:BYTE
  extrn menu2:BYTE
  extrn menu3:BYTE
  extrn menu3:BYTE
  extrn menu4:BYTE
  extrn menu5:BYTE
  extrn menu6:BYTE
  extrn menu7:BYTE
  extrn nombre:BYTE
  extrn jugadores:BYTE
  extrn modo1:BYTE
  extrn pagina:WORD

;-------------------------------

  PUBLIC PON_CADENA

; pone en pantalla una cadena terminada en '$'
; q se pasa por referencia (es como el servicio 09h de la int 21h pero
; pudiendo elegir atributo y sitio (no depende del cursor)
;-----------------------------------------------------------

 PARAMSPC STRUC

   BPOLDPC DW ?
   RETORPC DD ?

   CADENA  DD ?
   PAGPC   DW ?
   COLUPC  DW ?
   FILAPC  DW ?
   ATRIBPC DW ?

 PARAMSPC ENDS

   NPC EQU 12

;-------------------------------

  PUBLIC TOSTRING

; pasa n£mero a una cadena de caracteres,
; y la devuelve en DX:AX
; n£mero debe estar entre 0 y 9999
; y ser un dato de 16 bits
;-------------------------------------------

  PTSTRING STRUC

   BPOLDTS DW ?
   RETORTS DD ?

   NUMERO  DW ?

  PTSTRING ENDS

;-----------------------------------------------
  PUBLIC ESCRIBE

; Procedimiento q escribe un caracter en pantalla
;-----------------------------------------------

PARAM1 STRUC

  BPOLD1 DW ?
  RETOR1 DD ?

  COLUMNA0  DW ?
  FILA0     DW ?
  PAGINA0   DW ?
  CARACTER0 DW ?
  ATRIBUTO0 DW ?

PARAM1 ENDS

 NESCR EQU 10  ; numero de bytes de los
               ; parametros (que
               ; habra que desapilar al final)


;-------------------------------------------------
    PUBLIC LEE

; Lee en la posici¢n y la p gina indicadas el caracter y atributo
; almacenados y comprueba si coinciden con CARAC y ATRIB
; esta funci¢n devuelve:
; AX = 0001h si coinciden
; AX = 0000h si no coinciden
;-------------------------------------------------

PARAM2 STRUC

 BPOLD2  DW ?
 RETOR2 DD ?

 COLUM1  DW ?
 FILA1   DW ?
 PAG1    DW ?
 CARAC   DW ?
 ATRIB   DW ?

PARAM2 ENDS

 NLEE EQU 10 ; numero de bytes q
             ; desalojar de la pila en el RET


;-------------------------------------------------------
   PUBLIC LIMPIA

; procedimiento q limpia la pagina q se le pasa
; (llena toda la pantalla de espacios)
;-------------------------------------------------------

PARAM3 STRUC

 BPOLD3 DW ?
 RETOR3 DD ?

 PAG2 DW ?

PARAM3 ENDS

  NLIM EQU 2 ; numero de par metros a
             ; eliminar en el RET

;-------------------------------
  PUBLIC RELOJ
; macro q pone en pantalla un reloj en el formato:
; 'mm:ss'  donde mm = son dos caracteres q indican los minutos
; y ss = otros dos para los segundos
;-------------------------------------------------

  PARAMR STRUC

     BPOLDR   DW ?
     RETORNOR DD ?
     SEGUNDOS DW ?
     MINUTOS  DW ?

  PARAMR ENDS

;---------------------------------------------------------
  PUBLIC CUENTA_CARAC
; funci¢n que cuenta las apariciones de un acar cter con
; un atributo concreto y en una p gina de 80x25, estos tres datos
; son par metros por valor y la salida es un natural en AX
;----------------------------------------------------------

  PARAMC STRUC

    BPOLDC    DW ?
    RETORNOC  DD ?
    PAGINAC   DW ?
    CARACTERC DW ?
    ATRIBUTOC DW ?

  PARAMC ENDS

  NCC EQU 6

;---------------------------------------------------------
   PUBLIC AUTOPINTA
; procedimiento que pinta los obst culos interiores
; y las monedas de la mazmorra por defecto
;---------------------------------------------------------

;--------------------------------------------------------
   PUBLIC PINTAMANO
; procedimiento que sirve de herramienta para pintar
; la mazmorra en el modo D
;--------------------------------------------------------

;-------------------------------------------------------
;    SEGMENTO DE CODIGO
;-------------------------------------------------------

CODIGO1 SEGMENT

  ASSUME CS:CODIGO1

  pon_cadena PROC FAR

     push BP
     mov BP, SP

     push AX
     push BX
     push DX
     push ES
     push DS
     push SI
     push DI

        mov BX, word ptr [BP].PAGPC       ;
        mov AX, 1000h                     ;
        mul BX                            ;
        mov SI, AX                        ; guarda en SI el primer despl
                                          ; de la p gina indicada en PAGINA0

        mov AL, BYTE PTR [BP].FILAPC
        mov BL, 00A0H
        mul BL
        add SI, AX                  ; sumamos fila*160 a SI ya q
                                    ; cada fila son 160 bytes (A0H)

        mov AL, BYTE PTR [BP].COLUPC
        mov BL, 02D
        mul BL
        add SI, AX                  ; sumamos columna*2 a SI ya q
                                    ; cada columna son 2 bytes

        mov AX, 0B800H
        mov ES, AX                  ; ahora ES:SI apunta a la posici¢n de
                                    ; pantalla donde empezar  la cadena

        LDS DI, [BP].CADENA         ; DS:DX apunta a la CADENA

        mov AH, byte ptr [BP].ATRIBPC ; AH contiene el atributo

       cmp_cad:

            cmp byte ptr DS:[DI], '$'
            jne escribe_cad
            jmp fin_cad

            escribe_cad:
                     mov AL, DS:[DI]
                     mov ES:SI, AL
                     mov ES:[SI+1], AH

                     inc DI
                     add SI, 2
                     jmp cmp_cad

        fin_cad:

     pop DI
     pop SI
     pop DS
     pop ES
     pop DX
     pop BX
     pop AX

     pop BP

   ret NPC

  pon_cadena endp

;------------------------------------

  tostring PROC FAR

     push BP
     mov BP, SP

     push BX

          mov AX, [BP].numero  ; AX contiene el n£mero en hexadecimal

          cmp AX, 1000d
          jge millares
          jmp no_millares

          millares:

               mov BX, 1000d    ;
               div BX           ; AL contine los millares

               mov DH, AL
               mov AL, AH
               mov AH, 00h
               jmp cmp_centenas

          no_millares:

               mov DH, 00h

          cmp_centenas:

          cmp AX, 100d
          jge centenas
          jmp no_centenas

          centenas:

               mov BL, 100d     ;
               div BL           ; AL tiene las centenas

               mov DL, AL       ;
               mov AL, AH       ;
               mov AH, 00h      ; DX tiene las 2 cifras mas significativas
               jmp cmp_decenas  ; del n£mero

          no_centenas:

               mov DL, 00h

          cmp_decenas:

          cmp AX, 10d
          jge decenas
          jmp no_decenas

          decenas:

               mov BL, 10d
               div BL           ; en AH est n las unidades y
                                ; en AL las decenas

               mov BL, AL
               mov AL, AH
               mov AH, BL
               jmp fin_tostring

          no_decenas:

               mov AH, 00h

          fin_tostring:

          add DL, 30h   ; DX tiene las 2 cifras mas significativas
          add DH, 30h   ; del n£mero  (en ASCII)

          add AL, 30H   ; en AL estan las unidades en ascii
          add AH, 30H   ; en AH la decenas

     pop BX

     pop BP

   ret 2

 tostring ENDP

;-------------------------------------------------

 ESCRIBE PROC FAR

        push BP              ; guarda bp en pila
        mov BP, SP

        push AX             ;
        push SI             ;> guarda registros q vamos a usar
        push BX             ;
        push ES             ;
        push DX             ;

        mov BX, word ptr [BP].PAGINA0     ;
        mov AX, 1000h                     ;
        mul BX                            ;
        mov SI, AX                        ; guarda en SI el primer despl
                                          ; de la p gina indicada en PAGINA0

        mov AL, BYTE PTR [BP].FILA0
        mov BL, 00A0H
        mul BL
        add SI, AX                  ; sumamos fila*160 a SI ya q
                                    ; cada fila son 160 bytes (A0H)

        mov AL, BYTE PTR [BP].COLUMNA0
        mov BL, 02D
        mul BL
        add SI, AX                  ; sumamos columna*2 a SI ya q
                                    ; cada columna son 2 bytes

        mov AX, 0B800H
        mov ES, AX

        mov AH, BYTE PTR [BP].CARACTER0
        mov AL, BYTE PTR [BP].ATRIBUTO0

        mov ES:SI, AH             ; escribe en memoria el caracter...
        mov ES:[SI+1], AL         ; ... y el atributo

        pop DX       ;
        pop ES       ;
        pop BX       ;
        pop SI       ;> restaura registros
        pop AX       ;

        pop BP        ; restaura BP

   ret NESCR             ; retorna y libera el espacio de los par metros

 ESCRIBE ENDP

;-------------------------------------------------------------------

 LEE PROC FAR

     push BP              ; guarda bp en pila
     mov BP, SP

     push SI             ;> guarda registros q vamos a usar
     push BX             ;
     push ES             ;
     push DX             ;

        mov BX, word ptr [BP].PAG1        ;
        mov AX, 1000h                     ;
        mul BX                            ;
        mov SI, AX                        ; guarda en SI el primer despl
                                          ; de la p gina indicada en PAGINA

        mov AL, BYTE PTR [BP].FILA1
        mov BL, 00A0H
        mul BL
        add SI, AX                  ; sumamos fila*160 a SI ya q
                                    ; cada fila son 160 bytes (A0H)

        mov AL, BYTE PTR [BP].COLUM1
        mov BL, 02D
        mul BL
        add SI, AX                  ; sumamos columna*2 a SI ya q
                                    ; cada columna son 2 bytes

        mov AX, 0B800H
        mov ES, AX

        mov AH, 00h
        mov AL, byte ptr [ES:SI]        ; obtiene el car cter
        cmp [BP].CARAC, AX
        jne noiguales

        mov AL, byte ptr ES:[SI+1]      ; obtiene el atributo
        cmp [BP].ATRIB, AX
        jne noiguales

        iguales:   mov AX, 0001h
                   jmp finlee

        noiguales: mov AX, 0000h

        finlee:

     pop DX
     pop ES
     pop BX
     pop SI

     pop BP

   ret NLEE

 LEE ENDP

;-------------------------------------------------------------------

 LIMPIA PROC FAR

     push BP
     mov BP, SP

     push AX
     push BX
     push SI
     push ES

          mov AX, 0B800H
          mov ES, AX

          mov AX, 1000H
          mov BX, BP.[PAG2]
          mul BX

          mov SI, AX
          mov BX, 0000H

          blimpia: cmp BX, 2000d
                   jg fblimpia

                   mov [ES:SI], BYTE PTR 00H
                   inc SI
                   mov [ES:SI], BYTE PTR 07D
                   inc SI

                   inc BX
                   jmp blimpia
        fblimpia:

     pop ES
     pop SI
     pop BX
     pop AX

     pop BP

   ret NLIM

 LIMPIA ENDP

;-------------------------------------------------------

 CUENTA_CARAC PROC FAR

    push BP
    mov BP, SP

    push BX
    push CX
    push DX

         mov AX, 1000h
         mov BX, [BP].PAGINAC
         mul BX

         mov SI, AX          ;
         mov AX, 0B800h      ;> ES:SI apunta a la primera posici¢n de la
         mov ES, AX          ;  pagina indicada

         mov BL, byte ptr [BP].CARACTERC
         mov BH, byte ptr [BP].ATRIBUTOC

         mov AX, 0000h               ; inic. contador del caracter (salida)
         mov CX, 0000h               ; inic. contador del bucle
         bu_cuenta: cmp CX, 2000d
                    jge fin_bu_cuenta

                    cmp ES:[SI], BL        ; si es el mismo caracter
                    jne siguint_casilla    ;
                    cmp ES:[SI+1], BH      ; y el mismo atributo
                    jne siguint_casilla    ;
                                           ;
                        inc AX             ; incrementamos el contador

            siguint_casilla: inc CX        ; y pasamos a comprobar la
                             add SI, 2     ; siguiente casilla
                             jmp bu_cuenta

         fin_bu_cuenta:

    pop DX
    pop CX
    pop BX

    pop BP

  ret NCC

 CUENTA_CARAC ENDP

;-------------------------------------------------------

 AUTOPINTA PROC FAR

   push BP
   mov BP, SP

   push AX
   push BX
   push CX
   push DX
   push SI
   push DS

        mov AX, seg DATAMAZ  ; actualizamos DS para q apunte al
        mov DS, AX           ;   segmento de datos DATAMAZ

        mov SI, offset MAZMORRA   ; DS:SI apunta a la matriz MAZMORRA

        mov BX, 0002h                    ; indice de fila
        bfilamaz: cmp BX, 20d
                  jge fbfilamaz

                  mov CX, 0005h          ; indice de columna
                  bcolmaz: cmp CX, 73d
                           jge fbcolmaz

                           mov DX, DS:SI  ;
                           mov AL, DH     ;> AX contiene el car cter y
                           mov DH, 00h    ;  DX el atributo
                           mov AH, 00h    ;

                           push DX           ;
                           push AX           ;
                           mov AX, 2         ;> escribe el caracter
                           push AX           ;
                           push BX           ;
                           push CX           ;
                           call escribe      ;

                           add SI, 2      ; actualiza el ¡ndice de la matriz

                           inc CX        ; act. contador de fila
                           jmp bcolmaz
                  fbcolmaz:

                  inc BX                 ; act. contador de columna
                  jmp bfilamaz

        fbfilamaz:

   pop DS
   pop SI
   pop DX
   pop CX
   pop BX
   pop AX

   pop BP

  ret

 AUTOPINTA ENDP

;-------------------------------------------------------------

 PINTAMANO PROC FAR

   push BP
   mov BP, SP

   push AX
   push BX
   push CX
   push DX
   push ES

        mov AX, 00h ; para q los contadores del raton se pongan a cero
        int 33h     ;

        mov AX, 04h     ;
        mov CX, 320d    ;> sit£a el cursor del rat¢n para asegurarse de q no se
        mov DX, 100d    ;  sale de los bordes exteriores de la mazmorra
        int 33h         ;

        mov AX, 07h    ;
        mov CX, 40d    ;
        mov DX, 576d   ;
        int 33h        ;> limita el movimiento del cursor a los
        mov AX, 08h    ;     bordes exteriores de la mazmorra
        mov CX, 16d    ;
        mov DX, 152d   ;
        int 33h        ;

        mov AX, 01h    ;
        int 33h        ; muestra el cursor

        bucleobs: mov AX, 0005h   ;
                  mov BX, 0001h   ;
                  int 33h         ;> mientras no se pulse el boton derecho
                  cmp BX, 0000h   ;
                  je sigbuclobs   ;
                  jmp fbucleobs   ;

       sigbuclobs:
                  mov AX, 05h     ;
                  mov BX, 0000h   ;> si se pulsa el boton izquierdo
                  int 33h         ;
                  cmp BX, 0000h   ;
                  je bucleobs     ;

                  mov AX, 02h   ;
                  int 33h       ; oculta el raton

                  mov AX, 03h   ;
                  int 33h       ; obtiene la posici¢n del raton
                  shr CX, 3     ;   CL = columna
                  shr DX, 3     ;   DL = fila

                  mov BH, 00h     ;  fila antigua
                  mov BL, 00h     ;  columna antigua
                                  ; las inicializamos con valores distintos
                                  ; para q la primera vez entre y escriba

                 pintaobs: cmp BH, CL      ;
                           jne sigpintaobs ;  compara las pos antiguas
                           cmp BL, DL      ; con las nuevas, si son distintas
                           jne sigpintaobs ; el rat¢n se ha movido y escribimos
                           jmp comp_libera

                sigpintaobs:
                            ; miramos si ya hab¡a un obst culo
                            ; con la funci¢n booleana lee
                            mov AX, 12d
                            push AX
                            mov AX, 0B1h
                            push AX
                            mov AX, [pagina]
                            push AX
                            push DX
                            push CX
                            call lee

                            cmp AX, 1
                            je borraobs

                            ; nos aseguramos de q tampoco sea la casilla de
                            ; meta

                            cmp DX, 19d
                            jne no_es_meta
                            cmp CX, 72d
                            jne no_es_meta
                            jmp comp_libera

                            no_es_meta:

                            ; si no hab¡a un obst culo lo escribimos

                            ESCRIBELO 12D, 0B1H, [pagina], DX, CX

                            jmp comp_libera

                           ; si lo hab¡a lo borramos

                  borraobs: BORRA DX, CX, [pagina]

               comp_libera: push CX
                            push DX
                            push BX
                            mov AX, 06h      ;
                            mov BX, 0000h    ;
                            int 33h          ;  mientras no se libere
                            test AX, 0001h   ;  el boton izq del rat¢n
                            jne actpos       ;

                            ; si el bot¢n se libera
                            pop BX
                            pop DX
                            pop CX
                            mov AX, 01h    ;
                            int 33h        ; muestra el cursor
                            jmp bucleobs   ; y vuelve a esperar
                                           ; q se pulse denuevo

                    actpos: pop BX
                            pop DX
                            pop CX
                            mov BH, CL    ; columna antigua
                            mov BL, DL    ; fila antigua

                            push BX
                            mov AX, 03h   ;
                            int 33h       ; actualiza la posici¢n del raton
                            shr CX, 3     ;   CL = columna
                            shr DX, 3     ;   DL = fila
                            pop BX
                            jmp pintaobs  ;

        fbucleobs:

        buclemon: mov AX, 0005h    ;
                  mov BX, 0001h    ;> mientras no se pulse el boton derecho
                  int 33h          ;
                  cmp BX, 0000h    ;
                  je  siguebm      ;
                  jmp fbuclemon    ;

         siguebm: mov AX, 0005h    ;
                  mov BX, 0000h    ;> si se pulsa el boton izquierdo
                  int 33h          ;
                  cmp BX, 0000h    ;
                  je buclemon      ;

                  pintamon: shr CX, 3         ; columna del raton
                            shr DX, 3         ; fila del raton

                            mov AX, 02h   ;
                            int 33h       ; oculta el raton

                            ; comprobamos si intenta escribir una
                            ; moneda donde hay un obst culo

                            mov AX, 12d
                            push AX
                            mov AX, 0B1h
                            push AX
                            mov AX, [pagina]
                            push AX
                            push DX
                            push CX
                            call lee

                            cmp AX, 1
                            jne mira_meta

                            mov AX, 01h   ; si habia un obst culo
                            int 33h       ; muestra el raton
                            jmp buclemon  ; y vuelve a bucle principal

                            ; nos aseguramos de q tampoco sea la casilla de
                            ; meta

                            mira_meta:
                                      cmp DX, 19d
                                      jne noesobs
                                      cmp CX, 72d
                                      jne noesobs

                                      mov AX, 01h   ;
                                      int 33h       ; muestra el raton
                                      jmp buclemon

                            ; si no hab¡a un obst culo
                            ; comprobamos si ya habia una moneda

                   noesobs:
                            mov AX, 14d
                            push AX
                            mov AX, 07h
                            push AX
                            mov AX, [pagina]
                            push AX
                            push DX
                            push CX
                            call lee

                            cmp AX, 1
                            je borramon   ;si ya habia una moneda la borramos

                            ; sino la escribimos

                            ESCRIBELO 14D, 07H, [pagina], DX, CX

                            mov AX, 01h   ; una vez escrito
                            int 33h       ; muestra el raton
                            jmp buclemon

                  borramon:  BORRA  DX, CX, [pagina]

                            mov AX, 01h  ; una vez escrito
                            int 33h      ; muestra el raton
                            jmp buclemon

        fbuclemon: mov AX, 02h  ;
                   int 33h      ;oculta el cursor del rat¢n

        mov AX, 07h    ;
        mov CX, 00d    ;
        mov DX, 641d   ;
        int 33h        ;> limita el movimiento del cursor
        mov AX, 08h    ;  a la pantalla
        mov CX, 00d    ;
        mov DX, 201d   ;
        int 33h        ;


   pop ES
   pop DX
   pop CX
   pop BX
   pop AX

   pop BP

  ret

 PINTAMANO ENDP

;----------------------------------------------

 RELOJ PROC FAR

      push BP
      mov BP, SP

      sub sp, 2

      push AX
      push BX
      push DX

           mov AX, [BP].minutos
           push AX
           call tostring

           mov [BP-2], AX
           mov BL, AH
           mov BH, 00h
           ESCRIBELO 11d, BX, [pagina], 24d, 66d
           mov BX, [BP-2]
           mov BH, 00h
           ESCRIBELO 11d, BX, [pagina], 24d, 67d

           ESCRIBELO 11D, ':', [pagina], 24d, 68d

           mov AX, [BP].segundos
           push AX
           call tostring

           mov [BP-2], AX
           mov BL, AH
           mov BH, 00h
           ESCRIBELO 11d, BX, [pagina], 24d, 69d
           mov BX, [BP-2]
           mov BH, 00h
           ESCRIBELO 11d, BX, [pagina], 24d, 70d

      pop DX
      pop BX
      pop AX

      add sp, 2

      pop BP

   ret 4

 RELOJ ENDP

;---------------------------------


;******************************************************************

 PUBLIC MENU

; pone el menu en pantalla en la  pagina 0
; y espera q se pulse una de las opciones (1, 2, 3, ESC)

;-------------------imprime el menu en pantalla

 MENU PROC FAR

     push BP
     mov BP, SP

     push AX
     push BX

      mov BX, [pagina]  ; pagina en q vamos a escribir las cadenas

      mov AX, 9d
      push AX
      mov AX, 08d
      push AX
      mov AX, 14d
      push AX
      push BX
      mov AX, seg menu0
      push AX
      mov AX, offset menu0
      push AX
      call pon_cadena

      mov AX, 3d
      push AX
      mov AX, 09d
      push AX
      mov AX, 14d
      push AX
      push BX
      mov AX, seg menu1
      push AX
      mov AX, offset menu1
      push AX
      call pon_cadena

      mov AX, 3d
      push AX
      mov AX, 10d
      push AX
      mov AX, 14d
      push AX
      push BX
      mov AX, seg menu2
      push AX
      mov AX, offset menu2
      push AX
      call pon_cadena

      mov AX, 3d
      push AX
      mov AX, 11d
      push AX
      mov AX, 14d
      push AX
      push BX
      mov AX, seg menu3
      push AX
      mov AX, offset menu3
      push AX
      call pon_cadena

      mov AX, 3d
      push AX
      mov AX, 12d
      push AX
      mov AX, 14d
      push AX
      push BX
      mov AX, seg menu4
      push AX
      mov AX, offset menu4
      push AX
      call pon_cadena

      mov AX, 3d
      push AX
      mov AX, 13d
      push AX
      mov AX, 14d
      push AX
      push BX
      mov AX, seg menu5
      push AX
      mov AX, offset menu5
      push AX
      call pon_cadena

      mov AX, 3d
      push AX
      mov AX, 14d
      push AX
      mov AX, 14d
      push AX
      push BX
      mov AX, seg menu6
      push AX
      mov AX, offset menu6
      push AX
      call pon_cadena

      mov AX, 15d
      push AX
      mov AX, 15d
      push AX
      mov AX, 14d
      push AX
      push BX
      mov AX, seg menu7
      push AX
      mov AX, offset menu7
      push AX
      call pon_cadena

      mov AX, 3d
      push AX
      mov AX, 22d
      push AX
      mov AX, 35d
      push AX
      push BX
      mov AX, seg nombre
      push AX
      mov AX, offset nombre
      push AX
      call pon_cadena

;---------------------por defecto el modo es 1 jugador

     mov [jugadores], 1

      mov AX, 3d
      push AX
      mov AX, 17d
      push AX
      mov AX, 17d
      push AX
      push BX
      mov AX, seg modo1
      push AX
      mov AX, offset modo1
      push AX
      call pon_cadena

      pop BX
      pop AX

      pop BP

    ret

 MENU ENDP

CODIGO1 ENDS
        END
