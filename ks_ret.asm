;*****************************************************************
;  Nombre:    Juan Miguel
;  Apellidos: Rodr¡guez Cer¢n
;  D.N.I.:    74879016
;
;  I.T.I.S. 2§ A
;******************************************************************

;
; Macro : RETARAT
;
; Descripcion
;    Espera durante un determinado numero de centesimas de segundo
;
; Parametro
;    centesimas: numero de centesimas de segundo a esperar

;  LIMITACION!!: ticks < 256  (lo que cabe
;                en 1 byte, debido a la restriccion del
;                producto y la division)

retarat     macro centesimas
            local bucle
;
;Salva registros
;
            push    ax
            push    dx
            push    cx
            push    si

;Retardo
            mov     ax, centesimas  ;carga en ax el parametro
                                    
           
            mov     cx,10
            mul     cx              ;multiplicamos por 10
            mov     cl,55
            div     cl              ;dividimos por 55


            ; al=centesimas*10/55 -> numero de ticks equivalentes

            mov cx,40h
            mov es,cx
            mov si,6Ch  
            
            mov cx,es:[si]    ;valor inicial del contador de ticks
            mov ah,0
            add cx,ax         ;valor final futuro cuando pase el tiempo 
                              ;de retardo

bucle:      mov dx,es:[si]    ;valor actual del contador de ticks 
            cmp dx,cx 
            jle  bucle
            
;Recupera registros
            pop     si                                            
            pop     cx
            pop     dx
            pop     ax

endm
