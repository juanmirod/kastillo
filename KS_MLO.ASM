;******************************************************************
;  Nombre:    Juan Miguel
;  Apellidos: Rodr¡guez Cer¢n
;  D.N.I.:    74879016
;
;  I.T.I.S. 2§ A
;******************************************************************

;******************************************************************
;  MACROS LOCALES AL PROGRAMA PRINCIPAL (KASTILLO.ASM)
;------------------------------------------------------------------
;  Macros implementadas:
;
;  * INICIA  .- inicializa las variables, koko y fantasma, el rat¢n, y
;               oculta el cursor
; 
;  * PON_MAZ .- imprime en pantalla los bordes de la mazmorra y el menu
;               del pulsador
;
; Para m s informaci¢n ver comentarios en las cabeceras y en el interior de
; cada macro
;------------------------------------------------------------------
;
;******************************************************************


;------------------------------

 INICIA MACRO

; Inicializa las variables globales, limpia la memoria de video,
; establece el modo de video y la p gina activa,
; tambien comprueba si el rat¢n est  instalado para
; enviar un aviso si no lo est 
; Tambi‚n oculta el cursor

;------------------inicializa variables

       mov [FinDeJuego], 0000h
       mov [monedas],    0000h
       mov [aux_fantasma], 0000h
       mov [aux_koko],   0000h
       mov [reloj_minutos],  2d
       mov [reloj_segundos], 30d
       mov [reloj_aux], 0000h


       mov AX, 0040h     ;
       mov ES, AX        ;> AX contiene el valor del contador de ticks
       mov SI, 006Ch     ;       (la palabra menos significativa)
       mov AX, ES:SI     ;
       mov [semilla], AX

;------------------inicializa el koko:

       mov [retraso_koko],  200d   ; retardo de 200 ms de segundo
       mov [atrib_koko],    09d   ; atributo del koko (color azul intenso)
       mov [caracter_koko], 02h   ; caracter de koko

       lea si, koko
       mov [si].X, 2
       mov [si].Y, 5          ; posicion inicial del koko

       mov [si].oldX, 2
       mov [si].oldY, 5

       mov [si].Aprev, 10d
       mov [si].Cprev, 0B2h

;---------------------genera la direcci¢n de inicio (pseudo)aleatoriamente

       mov DI, 006Ch
       mov AX, 0040h
       mov ES, AX
       mov AX, ES:[DI]
       and AL, 00000011b

       cmp AL, 0
       je ini_arriba
       cmp AL, 1
       je ini_abajo
       cmp AL, 2
       je ini_der
       jmp ini_izq

       ini_arriba:
                mov [dir_fila_koko],-1   ; dir. y sentido del mov. de fila
                mov [dir_colu_koko],0    ; dir. y sentido del mov. de columna
                jmp fin_ini_koko

       ini_abajo:
                mov [dir_fila_koko],1   ; dir. y sentido del mov. de fila
                mov [dir_colu_koko],0    ; dir. y sentido del mov. de columna
                jmp fin_ini_koko

       ini_der:
                mov [dir_fila_koko],0   ; dir. y sentido del mov. de fila
                mov [dir_colu_koko],1    ; dir. y sentido del mov. de columna
                jmp fin_ini_koko

       ini_izq:
                mov [dir_fila_koko],0   ; dir. y sentido del mov. de fila
                mov [dir_colu_koko],-1    ; dir. y sentido del mov. de columna

       fin_ini_koko:

;------------- inicializa el fantasma:

       mov [retraso_fantasma],  150d  ; retardo de 150 ms de segundo
       mov [atrib_fantasma],    15d  ; atributo del fantasma
       mov [caracter_fantasma], 01h  ; caracter del fantasma

       lea si, fantasma
       mov [si].X, 00h         ; fila inicial del fantasma
       mov [si].Y, 00h         ; columna inicial del fantasma
                               ; (una vez dibujada la mazmorra se buscara la
                               ;    verdadera posicion inicial del fantasma)
       mov [si].oldX, 0
       mov [si].oldY, 0

       mov [si].Aprev, 0
       mov [si].Cprev, 0

;-------------------------genera la posici¢n de inicio (pseudo)aleatoriamente

       mov DI, 006Ch
       mov AX, 0040h
       mov ES, AX
       mov AX, ES:[DI]
       and AL, 00000011b

       cmp AL, 0
       je ini_arribaf
       cmp AL, 1
       je ini_abajof
       cmp AL, 2
       je ini_derf
       jmp ini_izqf

       ini_arribaf:
                mov [dir_fila_fantasma],-1   ; dir. y sentido del mov. de fila
                mov [dir_colu_fantasma],0    ; dir. y sentido del mov. de columna
                jmp fin_ini_fan

       ini_abajof:
                mov [dir_fila_fantasma],1   ; dir. y sentido del mov. de fila
                mov [dir_colu_fantasma],0    ; dir. y sentido del mov. de columna
                jmp fin_ini_fan

       ini_derf:
                mov [dir_fila_fantasma],0   ; dir. y sentido del mov. de fila
                mov [dir_colu_fantasma],1    ; dir. y sentido del mov. de columna
                jmp fin_ini_fan

       ini_izqf:
                mov [dir_fila_fantasma],0   ; dir. y sentido del mov. de fila
                mov [dir_colu_fantasma],-1    ; dir. y sentido del mov. de columna

       fin_ini_fan:


;--------------------limpia las p ginas

       mov ax, 0001h
       buclepag:  cmp ax, 0003h
                  jg fbuclepag

                  push ax
                  call limpia

                  inc ax
                  jmp buclepag

       fbuclepag:

;------------------establece modo de video  (sin borrar la pantalla)

       mov ah, 00h
       mov al, 83h    ; modo 3 y BMS de AL a 1 para q no borre la pantalla
       int 10h

;------------------establece la pagina activa

       mov ah, 05h
       mov al, 00h
       int 10h

;------------------comprueba que el raton esta instalado

       mov ax, 00h
       int 33h
       mov raton, ax

;-----------------esconde el cursor de texto

       mov AH, 01h
       mov CH, 01h
       mov CL, 00h
       int 10h

 ENDM


;----------------------------------

 PON_MAZ MACRO

; Pone en pantalla los bordes de la mazmorra
; el mensaje de salida, la peque¤a leyenda y las opciones del pulsador
;----------------------------------------------------------------------

      mov DX, [pagina]  ; p gina en la q imprimiremos la mazmorra

;-------------- obstaculos del borde de la mazmorra

      mov CX, 0001h  ;filas, contador del bucle1m

;-----------borde superior

      mov BX, 0004h
      bucle0m: cmp BX, 73d
               jg finbucle0m

               mov AX, 12d
               push AX
               mov AX, 0B1h
               push AX
               push DX
               push CX
               push BX
               call ESCRIBE   ; escribe un obst culo

               inc BX
               jmp bucle0m

      finbucle0m:

;---------bordes izquierdo y derecho

      inc CX
      bucle1m: cmp CX, 20d       ; condici¢n de salida
               jl  entrab2m       ;   de las filas
               jmp finbucle1m

    entrab2m:  mov BX, 0004d  ;columnas, contador del bucle2m
               bucle2m: cmp BX, 04d    ;   comprueba si es el borde izq
                        je pintaborde  ;
                        cmp BX, 73d    ;          o el derecho
                        je pintaborde  ;

                        cmp BX, 74d    ; condici¢n de salida de
                        je finbucle2m  ;   las columnas

                        jmp incbucle2

                        pintaborde: mov AX, 12d
                                    push AX
                                    mov AX, 0B1h
                                    push AX
                                    push DX
                                    push CX
                                    push BX
                                    call ESCRIBE   ; escribe un obst culo

                        incbucle2: inc BX
                                   jmp bucle2m
               finbucle2m:

                 inc CX
                 jmp bucle1m
      finbucle1m:

;-----------borde inferior

      mov BX, 0004h
      bucle3m: cmp BX, 73d
               jg finbucle3m

               mov AX, 12d
               push AX
               mov AX, 0B1h
               push AX
               push DX
               push CX
               push BX
               call ESCRIBE   ; escribe un obst culo

               inc BX
               jmp bucle3m

      finbucle3m:

;----------------------casilla de meta

      ESCRIBELO 14d, 0b1h, [pagina], 19d, 72d

;----------------------opciones del pulsador

      mov BX, 0000h  ; columna en la q estar n las opciones
      mov CX, 0003h  ; fila en la q empezamos

      mov AX, 9d
      push AX
      mov AX, 'k'
      push AX
      push DX
      push CX
      push BX
      call escribe

      inc CX
      mov AX, 9d
      push AX
      mov AX, '+'
      push AX
      push DX
      push CX
      push BX
      call escribe

      inc CX
      mov AX, 9d
      push AX
      mov AX, '-'
      push AX
      push DX
      push CX
      push BX
      call escribe

      ADD CX, 4
      mov AX, 15d
      push AX
      mov AX, 'F'
      push AX
      push DX
      push CX
      push BX
      call escribe

      inc CX
      mov AX, 15d
      push AX
      mov AX, '+'
      push AX
      push DX
      push CX
      push BX
      call escribe

      inc CX
      mov AX, 15d
      push AX
      mov AX, '-'
      push AX
      push DX
      push CX
      push BX
      call escribe

;--------------------mensaje q muestra la salida

      mov AX, 15d
      push AX
      mov AX, 00d
      push AX
      mov AX, 49d
      push AX
      push DX
      mov AX, seg fin
      push AX
      mov AX, offset fin
      push AX
      call pon_cadena

;----------------Mensajes de la leyenda

      mov AX, 14d
      push AX
      mov AX, 21d
      push AX
      mov AX, 10d
      push AX
      push DX
      mov AX, seg leyen1
      push AX
      mov AX, offset leyen1
      push AX
      call pon_cadena

      mov AX, 14d
      push AX
      mov AX, 21d
      push AX
      mov AX, 52d
      push AX
      push DX
      mov AX, seg leyen2
      push AX
      mov AX, offset leyen2
      push AX
      call pon_cadena

      mov AX, 11d
      push AX
      mov AX, 23d
      push AX
      mov AX, 5d
      push AX
      push DX
      mov AX, seg leyen3
      push AX
      mov AX, offset leyen3
      push AX
      call pon_cadena

      mov AX, 11d
      push AX
      mov AX, 23d
      push AX
      mov AX, 50d
      push AX
      push DX
      mov AX, seg leyen4
      push AX
      mov AX, offset leyen4
      push AX
      call pon_cadena


 ENDM       