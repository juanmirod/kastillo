*****************************************************************
  Nombre:    Juan Miguel
  Apellidos: Rodr�guez Cer�n

  I.T.I.S. 2� A
******************************************************************

 Descripci�n de los m�dulos:

 * kastillo.asm .- m�dulo principal del juego (segmento de datos y de c�digo principales)

 * ks_mov.asm .- contiene las rutinas para el movimiento del koko y del fantasma

 * ks_pan.asm .- en �l est�n todas las rutinas que escriben en pantalla 

 * ks_rti.asm .- las rutinas de tratamiento de las interrupciones del teclado y de la impresora
 
 * ks_mac.asm .- macros de �mbito global

 * ks_mlo.asm .- macros de �mbito local al programa principal (el contenido en kastillo.asm)
 
 * ks_maz.asm .- segmento de datos con la mazmorra por defecto (para el modo f)

 * ks_son.asm .- m�dulo "son.asm" utilizado en el laboratorio, con algunas modificaciones (ver MEJORAS.TXT)

 * ks_ret.asm .- m�dulo "retardo.asm" utilizado en el laboratorio


----------------------------------------------------------------------------------------

 NOTAS: 
 -------

 * Para activar el menu del pulsador de la impresora debe ejecutarse el juego en MS-DOS (con el rat�n instalado, sino el propio juego nos indicar� la imposibilidad de accceder a este men�) ya q ue la temporizaci�n del juego est� hecha con el contador de ticks, y en windows no se puede detener ni modificar, con lo que si se activa el menu en windows durante algunos segundos al volver al juego dar� un error de divisi�n por cero.
 

                 
