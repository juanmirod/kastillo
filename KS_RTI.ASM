;*****************************************************************
;  Nombre:    Juan Miguel
;  Apellidos: Rodr¡guez Cer¢n
;  D.N.I.:    74879016
;
;  I.T.I.S. 2§ A
;******************************************************************

;******************************************************************
; RTI DEL PULSADOR DEL PUERTO PARALELO
;------------------------------------------------------------------
;
;******************************************************************

;--------- MACROS Y SUBRUTINAS EXTERNAS ------------------

 include ks_mac.asm

 EXTRN escribe:far
 EXTRN lee:far
 EXTRN pon_cadena:far

 EXTRN modo1:BYTE
 EXTRN modo2:BYTE
 EXTRN dir_fila_koko:BYTE
 EXTRN dir_colu_koko:BYTE
 EXTRN dir_fila_fantasma:BYTE
 EXTRN dir_colu_fantasma:BYTE
 EXTRN pagina:WORD
 EXTRN retraso_koko:WORD
 EXTRN retraso_fantasma:WORD
 EXTRN reloj_minutos:WORD
 EXTRN reloj_segundos:WORD
 EXTRN enmenu:BYTE
 EXTRN opcion:BYTE
 EXTRN jugadores: BYTE
 EXTRN FinDeJuego:BYTE

;---------------------------------------------------------

 PUBLIC RTIRQ7

;***********************************
; RTI DEL PULSADOR DE LA IMPRESORA
;***********************************

 CODIGORTI SEGMENT

    ASSUME CS:CODIGORTI

  RTIRQ7 PROC FAR

     push AX
     push BX
     push CX
     push DX
     push ES
     push SI

          sti ; permite q las interrupciones se aniden

          cli
          in AL, 21h           ;> enmascaramos la IRQ0 para q no var¡e el
          or AL, 00000001b     ;    contador de ticks
          out 21h, AL          ;
          sti

;------------------------enciende el led y muestra el rat¢n

          mov SI, 0008h  ; en ES:SI est  el puerto base de imp.

          mov DX, ES:SI  ;
          mov AL, 01h    ;> enciende el led
          out DX, AL     ;

          mov AX, 01h   ; muestra el rat¢n
          int 33h       ;

;-----------------------Controla el rat¢n para modificar las opciones

         bucle_rti:
                   mov AX, 0005h   ;
                   mov BX, 0001h   ;
                   int 33h         ;> mientras no se pulse el boton derecho
                   cmp BX, 0000h   ;
                   je sig_brti     ;
                   jmp fbrti       ;

          sig_brti:
                   mov AX, 05h     ;
                   mov BX, 0000h   ;> si se pulsa el boton izquierdo
                   int 33h         ;
                   cmp BX, 0000h   ;
                   jne si_opcion
                   jmp bucle_rti

                   si_opcion:
                             shr CX, 3
                             shr DX, 3

                             mov AX, 02h  ; oculta el rat¢n
                             int 33h      ;

                             mov AX, 9d
                             push AX
                             mov AX, '+'
                             push AX
                             mov AX, [pagina]
                             push AX
                             push DX
                             push CX
                             call lee

                             cmp AX, 1
                             je inc_vel_koko
                             jmp sig_opcion

                             inc_vel_koko:
                                       add [retraso_koko], 10d
                                       mov AX, 01h ; muestra el cursor
                                       int 33h     ;
                                       jmp bucle_rti

                   sig_opcion:
                             mov AX, 9d
                             push AX
                             mov AX, '-'
                             push AX
                             mov AX, [pagina]
                             push AX
                             push DX
                             push CX
                             call lee

                             cmp AX, 1
                             je dec_vel_koko
                             jmp sig_opcion2

                             dec_vel_koko:
                                          cmp [retraso_koko], 66d
                                          jg decrementa
                                          mov AX, 01h ; muestra el cursor
                                          int 33h     ;
                                          jmp bucle_rti

                                          decrementa:
                                          sub [retraso_koko], 10d
                                          mov AX, 01h ; muestra el cursor
                                          int 33h     ;
                                          jmp bucle_rti

                   sig_opcion2:
                             mov AX, 15d
                             push AX
                             mov AX, '+'
                             push AX
                             mov AX, [pagina]
                             push AX
                             push DX
                             push CX
                             call lee

                             cmp AX, 1
                             je inc_vel_fan
                             jmp sig_opcion3

                             inc_vel_fan:
                                         add [retraso_fantasma], 10d
                                         mov AX, 01h ; muestra el cursor
                                         int 33h     ;
                                         jmp bucle_rti

                   sig_opcion3:
                             mov AX, 15d
                             push AX
                             mov AX, '-'
                             push AX
                             mov AX, [pagina]
                             push AX
                             push DX
                             push CX
                             call lee

                             cmp AX, 1
                             je dec_vel_fan
                             jmp sig_opcion4

                             dec_vel_fan:
                                          cmp [retraso_fantasma], 66d
                                          jg decrementa2
                                          mov AX, 01h ; muestra el cursor
                                          int 33h     ;
                                          jmp bucle_rti

                                          decrementa2:
                                          sub [retraso_fantasma], 10d
                                          mov AX, 01h ; muestra el cursor
                                          int 33h     ;
                                          jmp bucle_rti

                   sig_opcion4:
                               cmp DX, 24d
                               je fila_reloj
                               jmp fin_op4

                     fila_reloj:
                                cmp CX, 66d
                                jge col_reloj
                                jmp fin_op4

                      col_reloj:
                                cmp CX, 70
                                jle en_reloj
                                jmp fin_op4

                      en_reloj:

;-----------------------si clickea sobre el reloj lo actualizamos

                    mov [reloj_minutos], 0000h
                    mov [reloj_segundos], 0000h

                               cli               ;
                               in AL, 21h        ;> inhibe la int de teclado
                               or Al, 00000010b  ;
                               out 21h, AL       ;
                               sti               ;

                     mov CX, 66d   ;empieza en la col. 66
                     bucle_for4:
                                  cmp CX, 71d
                                  jl esp_numero
                                  jmp fin_bucle_for4

                      esp_numero:
                                  ESCRIBELO 10001000b, 0b1h, [pagina], DX, CX

                                  in AL, 64h
                                  test AL, 1
                                  jne si_pulsa
                                  jmp esp_numero

                        si_pulsa:
                                  in AL, 60h
                                  test AL, 128
                                  je y_es_make
                                  jmp esp_numero

                        y_es_make:
                                  cmp AL, 2d
                                  jl esp_numero
                                  cmp AL, 11
                                  jg esp_numero

                                  cmp AL, 11d
                                  jne dec_al

                                  mov AL, 00h
                                  mov BH, AL
                                  jmp act_reloj

                                 dec_al:
                                  dec AL
                                  mov BH, AL

                           act_reloj:
                                      cmp CX, 66
                                      je suma_min_d
                                      cmp CX, 67
                                      je suma_min_u
                                      cmp CX, 69
                                      je suma_seg_d
                                      jmp suma_seg_u

                                      suma_seg_u: mov AH, 00h
                                                  add [reloj_segundos], AX
                                                  jmp escr_reloj
                                      suma_seg_d: mov BL, 10d
                                                  mul BL
                                                  add [reloj_segundos], AX
                                                  jmp escr_reloj
                                      suma_min_u: mov AH, 00h
                                                  add [reloj_minutos], AX
                                                  jmp escr_reloj
                                      suma_min_d: mov BL, 10d
                                                  mul BL
                                                  add [reloj_minutos], AX

                           escr_reloj:
                                      add BH, 30h
                                      mov BL, BH
                                      mov BH, 00h
                                      ESCRIBELO 11d, BX, [pagina], DX, CX

                           inc CX
                           cmp CX, 68d
                           jne vuelve_for4

                              inc CX

                      vuelve_for4: jmp bucle_for4

                   fin_bucle_for4:

                               cli               ;
                               in AL, 21h        ;> permite la int de teclado
                               and Al, 11111101b ;
                               out 21h, AL       ;
                               sti               ;

                   fin_op4:

                   mov AX, 01h ; muestra el cursor
                   int 33h     ;

                   jmp bucle_rti

          fbrti:

;-----------------------oculta el rat¢n, apaga el led y
;-----------------------recupera el contador de ticks

          mov AX, 0040h
          mov ES, AX
          mov SI, 0008h  ; en ES:SI est  el puerto base de imp.

          mov DX, ES:SI  ;
          mov AL, 00h    ;> apaga el led
          out DX, AL     ;

          mov AX, 02h  ; Oculta el rat¢n
          int 33h      ;

          cli
          in AL, 21h         ;> desenmascara la IRQ0 para volver a permitir
          and AL, 11111110b  ;    la actualizaci¢n del contador de ticks
          out 21h, AL        ;
          sti

          mov AL, 00100000b ;> EOI (fin de instrucci¢n no espec¡fico)
          out 20h, AL       ;

     pop SI
     pop ES
     pop DX
     pop CX
     pop BX
     pop AX

    iret

  RTIRQ7 ENDP

;-----------------------------------

 PUBLIC RTIRQ1

;***********************************
; RTI DEL TECLADO
;***********************************

 RTIRQ1 PROC FAR

     push AX

       sti  ;permite q las interrupciones se aniden

       in AL, 60h     ;> si es un break
       test AL, 128   ;  salimos, no hace nada
       je es_make     ;
       jmp fin_rtit   ;

;-------------------------- si no: tratamos el make

    es_make:

       cmp [enmenu], byte ptr 1
       je rtit_menu
       jmp rtit_no_menu

;----------------esta en el men£

       rtit_menu:

             op1: cmp AL, 2                 ; comprueba si era el "1"
                  jne op2
                  mov [opcion], byte ptr 'd'  ; si lo era, guarda la opcion y
                  mov CL, 1                 ; pone CL a 1 para salir del menu
                  jmp fin_rtit              ; termina la selecci¢n

             op2: cmp AL, 3               ; igual q el 1 ...
                  jne op3
                  mov [opcion], byte ptr 'f'
                  mov CL, 1
                  jmp fin_rtit

             op3: cmp AL, 4               ; . . .
                  jne opesc
                  mov [opcion], byte ptr 'v'
                  mov CL, 1
                  jmp fin_rtit

             opesc: cmp AL, 1               ; . . .
                    jne op4
                    mov [opcion], byte ptr 'e'
                    mov CL, 1
                    mov [FinDeJuego], byte ptr 4
                    jmp fin_rtit

             op4: cmp AL, 5
                  jne op5

                  mov [jugadores], byte ptr 1

                  mov AX, 3d
                  push AX
                  mov AX, 17d
                  push AX
                  mov AX, 17d
                  push AX
                  mov AX, [pagina]
                  push AX
                  mov AX, seg modo1
                  push AX
                  mov AX, offset modo1
                  push AX
                  call pon_cadena

                  jmp fin_rtit

             op5: cmp AL, 6
                  je opcion5_rti
                  jmp fin_rtit

                opcion5_rti:

                  mov [jugadores], byte ptr 2

                  mov AX, 3d
                  push AX
                  mov AX, 17d
                  push AX
                  mov AX, 17d
                  push AX
                  mov AX, [pagina]
                  push AX
                  mov AX, seg modo2
                  push AX
                  mov AX, offset modo2
                  push AX
                  call pon_cadena

                  jmp fin_rtit

;---------------------------est  fuera del men£

       rtit_no_menu:
                     cmp AL, 72d    ;
                     je mov_arriba  ;> comprueba q la tecla
                     cmp AL, 80d    ;  pulsada sea uno de
                     je mov_abajo   ;  los cursores.
                     cmp AL, 75d    ;
                     je mov_izq     ;  Si lo es, la trata, sino
                     cmp AL, 77d    ;  mueve normalmente
                     je mov_der     ;
                     cmp AL, 1d
                     je salir_jug
                     jmp no_koko

                     mov_arriba: mov [dir_fila_koko], -1
                                 mov [dir_colu_koko], 0
                                 jmp fin_rtit

                     mov_abajo:  mov [dir_fila_koko], 1
                                 mov [dir_colu_koko], 0
                                 jmp fin_rtit

                     mov_izq:  mov [dir_fila_koko], 0
                               mov [dir_colu_koko], -1
                               jmp fin_rtit

                     mov_der:  mov [dir_fila_koko], 0
                               mov [dir_colu_koko], 1
                               jmp fin_rtit

                     salir_jug: mov [FinDeJuego], 4
                                jmp fin_rtit
              no_koko:
                     cmp [jugadores],byte ptr 2
                     je trata_fan
                     jmp fin_rtit

                  trata_fan:

                     cmp AL, 17d     ;
                     je mov_arribaf  ;> comprueba q la tecla
                     cmp AL, 31d     ;  pulsada sea
                     je mov_abajof   ;  'w', 'a', 's' o 'd'
                     cmp AL, 30d     ;
                     je mov_izqf     ;  Si lo es, la trata, sino
                     cmp AL, 32d     ;  mueve normalmente
                     je mov_derf     ;
                     jmp fin_rtit

                     mov_arribaf: mov [dir_fila_fantasma], -1
                                  mov [dir_colu_fantasma], 0
                                  jmp fin_rtit

                     mov_abajof:  mov [dir_fila_fantasma], 1
                                  mov [dir_colu_fantasma], 0
                                  jmp fin_rtit

                     mov_izqf:  mov [dir_fila_fantasma], 0
                                mov [dir_colu_fantasma], -1
                                jmp fin_rtit

                     mov_derf:  mov [dir_fila_fantasma], 0
                                mov [dir_colu_fantasma], 1

       fin_rtit:

          mov AL, 00100000b ;> EOI (fin de instrucci¢n no espec¡fico)
          out 20h, AL       ;

     pop AX

   iret

 RTIRQ1 ENDP

 CODIGORTI ENDS
           END