*****************************************************************
  Nombre:    Juan Miguel
  Apellidos: Rodríguez Cerón

  I.T.I.S. 2º A
******************************************************************

 Descripción de los módulos:

 * kastillo.asm .- módulo principal del juego (segmento de datos y de código principales)

 * ks_mov.asm .- contiene las rutinas para el movimiento del koko y del fantasma

 * ks_pan.asm .- en él están todas las rutinas que escriben en pantalla 

 * ks_rti.asm .- las rutinas de tratamiento de las interrupciones del teclado y de la impresora
 
 * ks_mac.asm .- macros de ámbito global

 * ks_mlo.asm .- macros de ámbito local al programa principal (el contenido en kastillo.asm)
 
 * ks_maz.asm .- segmento de datos con la mazmorra por defecto (para el modo f)

 * ks_son.asm .- módulo "son.asm" utilizado en el laboratorio, con algunas modificaciones (ver MEJORAS.TXT)

 * ks_ret.asm .- módulo "retardo.asm" utilizado en el laboratorio


----------------------------------------------------------------------------------------

 NOTAS: 
 -------

 * Para activar el menu del pulsador de la impresora debe ejecutarse el juego en MS-DOS (con el ratón instalado, sino el propio juego nos indicará la imposibilidad de accceder a este menú) ya q ue la temporización del juego está hecha con el contador de ticks, y en windows no se puede detener ni modificar, con lo que si se activa el menu en windows durante algunos segundos al volver al juego dará un error de división por cero.
 

                 
