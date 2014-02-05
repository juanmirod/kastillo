;*****************************************************************
;  Nombre:    Juan Miguel
;  Apellidos: Rodr¡guez Cer¢n
;  D.N.I.:    74879016
;
;  I.T.I.S. 2§ A
;******************************************************************

;-----------------------------------------------------------
;      Programa Principal (Kastillo.asm)
;-----------------------------------------------------------

;---------------------------------------------------------------------
; VARIABLES GLOBALES
;---------------------------------------------------------------------

 PUBLIC koko, fantasma, atrib_koko, caracter_koko, atrib_fantasma
 PUBLIC caracter_fantasma, atrib_moneda, caracter_moneda, atrib_obst
 PUBLIC caracter_obst, dir_fila_koko, dir_colu_koko, dir_fila_fantasma
 PUBLIC dir_colu_fantasma, modo, pagina, monedas, jugadores, FinDeJuego
 PUBLIC retraso_koko, retraso_fantasma, reloj_minutos, reloj_segundos, enmenu
 PUBLIC menu0, menu1, menu2, menu3, menu4, menu5, menu6, menu7, modo1, modo2
 PUBLIC nombre, opcion

;-----------------------------------------------------------
; MACROS Y SUBRUTINAS EXTERNAS:
;-----------------------------------------------------------

   include ks_ret.asm     ; retardo basado en TICKS de reloj
   include KS_mac.asm      ; macros globales
   include ks_mlo.asm      ; macros locales (inicia, menu y pon_maz)

   extrn rtirq7:far
   extrn rtirq1:far

   extrn limpia:far
   extrn escribe:far
   extrn lee:far
   extrn pintamano:far
   extrn autopinta:far
   extrn cuenta_carac:far
   extrn reloj:far
   extrn tostring:far
   extrn pon_cadena:far
   extrn menu:far

   extrn mov_koko:far
   extrn mov_fan:far
   extrn random:far

;------------------------------------------------------------------
;                   DATOS CONSTANTES Y ESTRUCTURAS
;------------------------------------------------------------------

;Definiciones

  ESCcode EQU 011Bh          ;codigos de rastreo/ascii de la tecla ESC

      ;Algunas definiciones que facilitan el acceso a la
      ;estructura de datos que representa al koko/fantasma

  ente struc

       X db ?               ; - coordenada X
       Y db ?               ; - coordenada Y
       oldX db ?            ;
       oldY db ?            ;
       Cprev db ?           ; - caracter anterior
       Aprev db ?           ; - atributo anterior

  ente ends

;Tama¤o a reservar para la estructura del koko y del fantasma

  sizeente EQU OFFSET Aprev - OFFSET X + 1

;/////////////////////////////////////////////////////////////////
;El segmento de datos contiene las VARIABLES GLOBALES del programa
;  SEGMENTO DE DATOS
;/////////////////////////////////////////////////////////////////

 DATOS SEGMENT

   koko db sizeente  dup('K')      ;memoria reservada para la estructura del koko
   fantasma db sizeente  dup('F')  ; memoria reservada para el fantasma

   ;cadenas de caracteres de mensages de pantalla:
   no_raton db 'TU RATON NO ESTA INSTALADO O NO FUNCIONA CORRECTAMENTE $' 
   no_raton2 db 'NO PODRµS ENTRAR EN EL MENU DEL PULSADOR DE LA IMPRESORA $'

   menu0   db ' $'
   menu1   db ' PARA EMPEZAR A JUGAR EN EL MODO D PULSE 1    $'
   menu2   db ' PARA EMPEZAR A JUGAR EN EL MODO F PULSE 2    $'
   menu3   db ' PARA CONTINUAR EL JUEGO           PULSE 3    $'
   menu4   db ' PARA PASAR A MODO  1 JUGADOR      PULSE 4    $'
   menu5   db ' PARA PASAR A MODO  2 JUGADORES    PULSE 5    $'
   menu6   db ' PARA SALIR                        PULSE ESC  $'
   menu7   db ' $'

   modo1   db '( ACTUALMENTE JUEGA EN MODO   1 JUGADOR ) $'
   modo2   db '( ACTUALMENTE JUEGA EN MODO 2 JUGADORES ) $'

   nombre  db ' Juan Miguel Rodr¡guez Cer¢n I.T.I.S. 2§A $'

   fin     db 'PULSA ESC PARA IR AL MENU','$' ;mensaje de finalizacion
   lose0   db ' $'
   lose1   db ' ­HAS PERDIDO! ', '$'
   win0    db ' $'
   win1    db ' ­­HAS GANADO!! ','$'
   volver  db 'NO SE PUDO VOLVER AL JUEGO $'
   gracias db '­­­ GRACIAS POR JUGAR !!! $'

   leyen1 db 'Para ganar recoge todas las monedas y ve a la $'
   leyen2 db ' META ', 0B1h, '$'
   leyen3 db 'Monedas restantes: $'
   leyen4 db 'Tiempo restante: $'

   ;atributos del car cter con que se pinta el koko
   atrib_koko    db 09d
   caracter_koko db 02h

   ;atributos del car cter con que se pinta el fantasma
   atrib_fantasma    db 01h
   caracter_fantasma db 15d

   ;atributos del car cter con que se pinta una moneda
   atrib_moneda db 14d
   caracter_moneda db 07h

   ;atributos del car cter con que se pinta un obst culo
   atrib_obst    db 12d
   caracter_obst db 0B1h

   ;vector direccion del movimiento del koko
   dir_fila_koko db 0  ; indica la direccion de movimiento del koko
                       ; en la fila donde esta situada
   dir_colu_koko db 0  ; indica la direccion en la columna
                       ; donde esta situada

   ;vector direccion del movimiento del fantasma
   dir_fila_fantasma db 0 ; indica la direcci¢n de movimiento del koko
                          ; en la fila donde esta situada
   dir_colu_fantasma db 0 ; indica la direccion en la columna
                          ; donde esta situada

   ; velocidad del movimiento del koko
   retraso_koko  dw ?  ; indica el retraso del koko (centesimas de seg.)
   aux_koko      dw ?

   ; velocidad de movimiento del fantasma
   retraso_fantasma dw ? ;indica el retraso del fantasma
   aux_fantasma     dw ?

   ; variables para el reloj de tiempo restante
    reloj_minutos  dw ?
    reloj_segundos dw ?
    reloj_aux      dw ?

   ; modo y pagina de video a utilizar

         modo           db 1 dup(?)
         pagina         dw ?

   ; antigua posici¢n del rat¢n
     xratonant dw ?
     yratonant dw ?

     semilla dw ?    ; variable para la funci¢n aleatoria

     monedas dw ?    ; variable contador de monedas en pantalla

     raton dw ?      ; variable booleana q indica si el rat¢n est  instalado:
                     ; si vale 00h el rat¢n est  instalado
                     ; si vale FFh el rat¢n NO est  instalado

     opcion db ?     ; opci¢n de juego elegida:
                     ; 'd'--> opcion de juego D
                     ; 'f'--> opcion de juego F
                     ; 'v'--> volver al juego
                     ; 'e'--> salir del juego

    jugadores db ?  ; numero de jugadores (1 ¢ 2)

     enmenu db ?    ; variable booleana q indica si nos encontramos
                  ; en el men£ (1) o fuera de ‚l (0)

     FinDeJuego db ?  ; variable auxiliar para guardar
                      ; la forma en q se debe salir:
                      ; 1 - ha ganado
                      ; 2 - ha perdido
                      ; 3 - no se pudo volver

DATOS ENDS

;------------------------------------------------------------------
;                   SEGMENTO DE PILA
;------------------------------------------------------------------

PILA SEGMENT STACK
     db 128 dup ('Kastillo')
PILA ENDS

;------------------------------------------------------------------
;               SEGMENTO DE CODIGO
;------------------------------------------------------------------

CODIGO SEGMENT

      ASSUME CS:CODIGO, DS:DATOS, SS:PILA

      inicio: mov AX ,datos
              mov ds, AX     ; ds contiene el segmento de datos

;---------------------- recoge los par metros de la l¡nea de comandos

              mov SI, 0080h
              cmp ES:[SI], byte ptr 00h
              jne hay_params
              jmp no_hay_params

              hay_params: mov BL, ES:[SI]
                          mov BH, 00h

                 b_busca: cmp BH, BL
                          jle busca_params
                          jmp no_hay_params

                          busca_params: inc SI
                                        inc BH
                                        cmp ES:[SI],byte ptr 20h
                                        je b_busca
                                        cmp ES:[SI],byte ptr 09h
                                        je b_busca
                                        cmp ES:[SI],byte ptr 'd'
                                        je opcion_d
                                        cmp ES:[SI], byte ptr 'D'
                                        je opcion_d
                                        cmp ES:[SI], byte ptr 'f'
                                        je opcion_f
                                        cmp ES:[SI], byte ptr 'F'
                                        je opcion_f
                                        jmp no_hay_params

                                        opcion_d: mov [opcion], byte ptr 'd'
                                                  jmp fin_busqda

                                        opcion_f: mov [opcion], byte ptr 'f'
                                                  jmp fin_busqda

              no_hay_params: mov [opcion], byte ptr 00h

              fin_busqda:

;----------------guarda la posici¢n del cursor en la pila

            mov BH, 00h
            mov AH, 03h
            int 10h

            push DX


;-------------------- Inicializa las variables y la pantalla

              INICIA   ; macro q inicializa variables y memoria de video


;----------------------

            ; si el raton est  instalado y correcto habilita el men£
            ; del pulsador (cambia el vector de la RTI de la IRQ )

              cmp [raton], 00h
              je no_raton_msn
              jmp cambia_vector

              no_raton_msn:
                           mov AX, 3d
                           push AX
                           mov AX, 2d
                           push AX
                           mov AX, 10d
                           push AX
                           mov AX, 1d
                           push AX
                           mov AX, seg no_raton
                           push AX
                           mov AX, offset no_raton
                           push AX
                           call pon_cadena

                           mov AX, 3d
                           push AX
                           mov AX, 3d
                           push AX
                           mov AX, 10d
                           push AX
                           mov AX, 1d
                           push AX
                           mov AX, seg no_raton2
                           push AX
                           mov AX, offset no_raton2
                           push AX
                           call pon_cadena

                           jmp fin_raton

              cambia_vector:

;------------------------ cambia la interrupci¢n de la impresora

              push DS       ; en la pila

              mov DI, 003Ch      ;
              mov AX, 0000h      ;> ES:DI apunta al vector de int de la
              mov ES, AX         ;  impresora

              mov BX, ES:[DI]    ;> guarda el antiguo valor del vector de
              mov CX, ES:[DI+2]  ;  interrupci¢n en CX:BX

              mov SI, offset rtirq7
              mov AX, seg rtirq7
              mov DS, AX

              cli                    ;
              mov ES:[DI], SI        ;> sustituye la rutina de interrupci¢n
              mov ES:[DI+2], DS      ;
              sti                    ;

              pop DS   ; recupera DS

              push CX  ; guarda en pila CX:BX
              push BX  ;


;--------------------habilita la interrupci¢n del pulsador

              mov AX, 0040h
              mov ES, AX
              mov SI, 0008h

              mov DX, ES:SI  ;> DX contiene el puerto de control
              add DX, 2      ;

              in AL, DX
              or AL, 00010000b
              out DX, AL

              cli               ;
              in AL, 21h        ;
              and AL, 01111111b ;> desenmascara la int de la impresora
              out 21h, AL       ;
              sti               ;


;-----------------------------------------

              fin_raton:


;-------------------cambia el vector de interrupci¢n del teclado

              push DS       ; en la pila

              mov DI, 36d      ;
              mov AX, 0000h    ;> ES:DI apunta al vector de int del teclado
              mov ES, AX       ;

              mov BX, ES:[DI]    ;> guarda el antiguo valor del vector de
              mov CX, ES:[DI+2]  ;  interrupci¢n en CX:BX

              mov SI, offset rtirq1
              mov AX, seg rtirq1
              mov DS, AX

              cli                    ;
              mov ES:[DI], SI        ;> sustituye la rutina de interrupci¢n
              mov ES:[DI+2], DS      ;
              sti                    ;

              pop DS   ; recupera DS

              push CX  ; guarda en pila CX:BX
              push BX  ;

              cli               ;
              in AL, 21h        ;
              and AL, 11111101b ;> desenmascara la int del teclado
              out 21h, AL       ;
              sti               ;


;-------------------- pone el menu

           mov [jugadores], 1

           cmp [opcion], byte ptr 00h
           je pon_menu
           jmp salta_menu

           pon_menu:
                    PON_PAG 1
                    mov [pagina], word ptr 1d
                    call menu  ; macro q pone el menu en pantalla y espera que
                               ; el usuario escoja una opci¢n

                    mov [enmenu], 1
                    mov CL, 00h
                    bucle_menu: cmp CL, 01h
                                jne bucle_menu

                    mov [enmenu], 0

           salta_menu:


;-----------------pinta la mazmorra en la p gina 2

    opciones:
              mov [pagina], word ptr 2d  ; todo el juego transcurre en la p gina 2

              cmp opcion, 'd'
              jne sigue_opc
              mov AX, pagina
              push AX
              call limpia

    sigue_opc:
              PON_MAZ
              PON_PAG 2

              cmp opcion, 'd'
              je opcionD
              cmp opcion, 'f'
              je opcionF
              cmp opcion, 'v'
              je opcionV
              jmp fin_main

                opcionD:
                       mov [FinDeJuego], 0
                       call pintamano
                       jmp finsipinta

                opcionF:
                      mov [FinDeJuego], 0
                      call autopinta
                      jmp finsipinta

                opcionV:
                      cmp [FinDeJuego], byte ptr 4
                      jne no_pued_volver

                      mov [FinDeJuego], 0
                      jmp fan_en_pos

                      no_pued_volver: mov [FinDeJuego], byte ptr 3d
                                      jmp fin_prin
              finsipinta:

         lea si, koko           ;
         mov [si].X, 2          ;> posicion inicial del koko
         mov [si].Y, 5          ;


;----------------------cuenta las monedas de la mazmorra

          mov AH, 00h
          mov AL, [atrib_moneda]
          push AX
          mov AL, [caracter_moneda]
          push AX
          mov AX, [pagina]
          push AX
          call cuenta_carac

          mov [monedas], AX

;----------------------calcula la posici¢n incial del fantasma

    pos_ini_fan:

              lea si, fantasma

              mov AX, 18
              push AX
              mov DX, seg semilla
              push DX
              mov AX, offset semilla
              push AX
              call RANDOM

              inc AL
              mov [si].X, AL          ; fila inicial del fantasma
              mov BH, 00h
              mov BL, AL              ; la guardamos en BX

              mov AX, 69
              push AX
              mov DX, seg semilla
              push DX
              mov AX, offset semilla
              push AX
              call RANDOM

              add AL, 4
              mov [si].Y, AL          ; columna inicial del fantasma
              mov AH, 00h

              ; mira si hay un obst culo en esa posici¢n

              mov CH, 00h
              mov CL, [atrib_obst]
              push CX
              mov CL, [caracter_obst]
              push CX
              mov CX, pagina
              push CX
              push BX
              push AX
              call lee

              cmp AX, 1
              jne cmp_meta
              jmp pos_ini_fan

              cmp_meta:

              mov CH, 00h
              mov CL, 14d
              push CX
              mov CL, 0b2h
              push CX
              mov CX, pagina
              push CX
              push BX
              push AX
              call lee

              cmp AX, 1
              jne fan_en_pos
              jmp pos_ini_fan

   fan_en_pos:


;----------------------muestra el contador de monedas y el reloj

              mov AX, [monedas]
              push AX
              call tostring

        mov BH, 00h                             ;
        mov BL, DH                              ;> muestra el contador de
        ESCRIBELO 11d, BX, [pagina], 24d, 23d   ;  monedas en la esquina
        mov BL, DL                              ;  inferior izquierda de
        ESCRIBELO 11d, BX, [pagina], 24d, 24d   ;  pantalla
        mov BL, AH                              ;
        ESCRIBELO 11d, BX, [pagina], 24d, 25d   ;
        mov BL, AL                              ;
        ESCRIBELO 11d, BX, [pagina], 24d, 26d   ;

              mov AX, [reloj_minutos]      ;> muestra el reloj en la esquina
              push AX                      ;   inferior derecha de pantalla
              mov AX, [reloj_segundos]     ;
              push AX                      ;
              call reloj                   ;


;------------------Hace el primer movimiento del koko y el fantasma
;------------------para inicialzar los temporizadores

                            call mov_koko
                            mov AX, [retraso_koko]
                            mov BL, 55d
                            div BL
                            mov BH, 00h
                            mov BL, AL

                            mov AX, 0040h ;
                            mov ES, AX    ;>ES:SI apunta al contador de ticks
                            mov SI, 006Ch ;

                            mov AX, ES:SI ; valor inicial del contador de ticks
                            add BX, AX    ; valor final del contador de ticks
                            mov [aux_koko], BX

                            call mov_fan
                            mov AX, [retraso_fantasma]
                            mov BL, 55d
                            div BL
                            mov BH, 00h
                            mov BL, AL

                            mov AX, ES:SI ; valor inicial del contador de ticks
                            add BX, AX    ; valor final del contador de ticks
                            mov [aux_fantasma], BX

                            mov BH, 00h
                            mov BL, 20d

                            mov AX, ES:SI ; valor inicial del contador de ticks
                            add BX, AX    ; valor final del contador de ticks
                            mov [reloj_aux], BX


;----------------------bucle principal del juego

              bucleprin:
                         cmp FinDeJuego, 0 ;> si la variable FinDeJuego se
                         je si_sigue_main  ;  actualiza se acaba el juego
                         jmp fin_prin

             si_sigue_main:
                        mov AX, 0040h ;
                        mov ES, AX    ;>ES:SI apunta al contador de ticks
                        mov SI, 006Ch ;

                        mov AX, ES:SI ; valor del contador de ticks en AX
                        cmp AX, [aux_koko]
                        jge mueve_koko
                        jmp no_mu_koko

                        mueve_koko:

                            call mov_koko
                            sub AX, [aux_koko]
                            mov BX, AX
                            mov AX, [retraso_koko]
                            sub AX, BX
                            mov BL, 55d
                            div BL
                            mov BH, 00h
                            mov BL, AL

                            mov AX, 0040h ;
                            mov ES, AX    ;>ES:SI apunta al contador de ticks
                            mov SI, 006Ch ;

                            mov AX, ES:SI ; valor inicial del contador de ticks
                            add BX, AX    ; valor final del contador de ticks
                            mov [aux_koko], BX

                     no_mu_koko:

                        mov AX, 0040h ;
                        mov ES, AX    ;>ES:SI apunta al contador de ticks
                        mov SI, 006Ch ;

                        mov AX, ES:SI ; valor del contador de ticks en AX
                        cmp AX, [aux_fantasma]
                        jge mueve_fan
                        jmp no_mu_fan

                        mueve_fan:

                            call mov_fan
                            sub AX, [aux_fantasma]
                            mov BX, AX
                            mov AX, [retraso_fantasma]
                            sub AX, BX
                            mov BL, 55d
                            div BL
                            mov BH, 00h
                            mov BL, AL

                            mov AX, 0040h ;
                            mov ES, AX    ;>ES:SI apunta al contador de ticks
                            mov SI, 006Ch ;

                            mov AX, ES:SI ; valor inicial del contador de ticks
                            add BX, AX    ; valor final del contador de ticks
                            mov [aux_fantasma], BX

                     no_mu_fan:


;--------------------actualiza el reloj y pone en pantalla el reloj y las
;--------------------monedas restantes

              mov AX, [monedas]
              push AX
              call tostring

        mov BH, 00h                             ;
        mov BL, DH                              ;> muestra el contador de
        ESCRIBELO 11d, BX, [pagina], 24d, 23d   ;  monedas en la esquina
        mov BL, DL                              ;  inferior izquierda de
        ESCRIBELO 11d, BX, [pagina], 24d, 24d   ;  pantalla
        mov BL, AH                              ;
        ESCRIBELO 11d, BX, [pagina], 24d, 25d   ;
        mov BL, AL                              ;
        ESCRIBELO 11d, BX, [pagina], 24d, 26d   ;

                        mov AX, 0040h ;
                        mov ES, AX    ;>ES:SI apunta al contador de ticks
                        mov SI, 006Ch ;

                        mov AX, ES:SI ; valor del contador de ticks en AX
                        cmp AX, [reloj_aux]
                        jge dec_reloj
                        jmp fin_dec_reloj

              dec_reloj: 
                         cmp [reloj_segundos], 00d
                         je dec_minutos
                         jmp dec_normal

                         dec_minutos:cmp [reloj_minutos], 00d
                                     je fin_tiempo
                                     jmp sigue_dec_min

                                     fin_tiempo:

                                       mov FinDeJuego, 2
                                       jmp fin_dec_reloj

                                     sigue_dec_min:

                                       mov [reloj_segundos], 59d
                                       dec [reloj_minutos]
                                       jmp actualiza_aux

                     dec_normal:
                                       dec [reloj_segundos]

                     actualiza_aux:

                            sub AX, [reloj_aux]
                            mov BX, 18d
                            sub BX, AX

                            mov AX, 0040h ;
                            mov ES, AX    ;>ES:SI apunta al contador de ticks
                            mov SI, 006Ch ;

                            mov AX, ES:SI ; valor inicial del contador de ticks
                            add BX, AX    ; valor final del contador de ticks
                            mov [reloj_aux], BX

                 fin_dec_reloj:

                    mov AX, [reloj_minutos]      ;> muestra el reloj en la
                    push AX                      ;  esquina inferior derecha
                    mov AX, [reloj_segundos]     ;  de pantalla
                    push AX                      ;
                    call reloj                   ;

                    jmp bucleprin

      fin_prin:
                PON_PAG 3
                mov [pagina], 3d

                mov AX, [pagina]   ;
                push AX            ;> limpia la p gina 3
                call limpia        ;

                cmp [FinDeJuego], 1
                jne sig_fin
                jmp gana

                sig_fin:
                cmp [FinDeJuego], 2
                jne sig_fin1
                jmp pierde

                sig_fin1:
                cmp [FinDeJuego], 3
                jne sig_fin2
                jmp no_vuelve

                sig_fin2:
                jmp fin_msn_final

                gana:
                     mov AX, 9d
                     push AX
                     mov AX, 10d
                     push AX
                     mov AX, 30d
                     push AX
                     mov AX, pagina
                     push AX
                     mov AX, seg win0
                     push AX
                     mov AX, offset win0
                     push AX
                     call pon_cadena

                     mov AX, 9d
                     push AX
                     mov AX, 11d
                     push AX
                     mov AX, 30d
                     push AX
                     mov AX, pagina
                     push AX
                     mov AX, seg win1
                     push AX
                     mov AX, offset win1
                     push AX
                     call pon_cadena

                     mov AX, 9d
                     push AX
                     mov AX, 12d
                     push AX
                     mov AX, 30d
                     push AX
                     mov AX, pagina
                     push AX
                     mov AX, seg win0
                     push AX
                     mov AX, offset win0
                     push AX
                     call pon_cadena

                     RETARAT 250
                     jmp fin_msn_final

                pierde:
                     mov AX, 15d
                     push AX
                     mov AX, 10d
                     push AX
                     mov AX, 30d
                     push AX
                     mov AX, pagina
                     push AX
                     mov AX, seg lose0
                     push AX
                     mov AX, offset lose0
                     push AX
                     call pon_cadena

                     mov AX, 15d
                     push AX
                     mov AX, 11d
                     push AX
                     mov AX, 30d
                     push AX
                     mov AX, pagina
                     push AX
                     mov AX, seg lose1
                     push AX
                     mov AX, offset lose1
                     push AX
                     call pon_cadena

                     mov AX, 15d
                     push AX
                     mov AX, 12d
                     push AX
                     mov AX, 30d
                     push AX
                     mov AX, pagina
                     push AX
                     mov AX, seg lose0
                     push AX
                     mov AX, offset lose0
                     push AX
                     call pon_cadena

                     RETARAT 250
                     jmp fin_msn_final

                no_vuelve:

                     mov AX, 3d
                     push AX
                     mov AX, 10d
                     push AX
                     mov AX, 28d
                     push AX
                     mov AX, pagina
                     push AX
                     mov AX, seg volver
                     push AX
                     mov AX, offset volver
                     push AX
                     call pon_cadena

                     RETARAT 250

       fin_msn_final:
                     mov [pagina], 2d

                     cmp [FinDeJuego], byte ptr 4d   ;> si se salio del juego
                     jne limpia_pan                  ;  por pulsar esc se
                     jmp no_limpia                   ;  puede volver

                     limpia_pan:                     ;> si no, se limpia
                                 mov AX, pagina      ;  la mazmorra xq no
                                 push AX             ;  se seguir  usando
                                 call limpia         ;
                      no_limpia:
                                 PON_PAG 1                ;
                                 mov [pagina], 1d         ;> vuelve al menu
                                 call menu                ;
                                 mov CL, 00h              ;  y espera
                                 mov [enmenu], 1          ;  una opci¢n
                                 bu_enmenu: cmp CL, 00h   ;
                                            je bu_enmenu  ;

                                 mov [enmenu], 0
                                 jmp opciones    ; va a ejecutar la opcion
                                                 ; (opciones en linea 390)
        fin_main:
                     mov [pagina], 3
                     mov AX, 3
                     push AX
                     call limpia

                     PON_PAG 3

                     mov AX, 14d
                     push AX
                     mov AX, 10d
                     push AX
                     mov AX, 28d
                     push AX
                     mov AX, pagina
                     push AX
                     mov AX, seg gracias
                     push AX
                     mov AX, offset gracias
                     push AX
                     call pon_cadena

                     RETARAT 250


;-------------------------- vuelve a la p gina 0

              PON_PAG 0

;--------------------------vuelve a mostrar el cursor

              mov AH, 01h
              mov CH, 06h
              mov CL, 07h
              int 10h

;----------------------recupera la antigua int del teclado

              pop BX
              pop CX

              mov DI, 36d        ;
              mov AX, 0000h      ;> ES:DI apunta al vector de int del
              mov ES, AX         ;  teclado

              cli                    ;
              mov ES:[DI], BX        ;> sustituye la rutina de interrupci¢n
              mov ES:[DI+2], CX      ;
              sti                    ;

;----------------------y la de la impresora

              pop BX
              pop CX

              mov DI, 003Ch          ;> ES:DI apunta al vector de la int de
                                     ; la imresora

              cli                    ;
              mov ES:[DI], BX        ;> sustituye la rutina de interrupci¢n
              mov ES:[DI+2], CX      ;
              sti                    ;

;----------------recupera la posici¢n original del cursor

             pop DX

             mov BH, 00h
             mov AH, 02h
             int 10h

;----------devuelve el control al DOS

       MOV AX, 4C00H
       INT 21H

CODIGO ENDS
       END inicio