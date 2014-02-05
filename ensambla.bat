echo off           
echo -----------------------------------------------
echo Nombre, Apellidos: Juan Miguel Rodr¡guez Cer¢n
echo DNI: 74879016
echo Titulaci¢n: I.T.I.S.
echo Grupo: 2§ A
echo -----------------------------------------------
echo Ensamblando: KASTILLO.ASM
tasm /zi /la kastillo.asm
pause
echo ---------------------------
echo Ensamblando: ks_pan.asm
echo ---------------------------
tasm /zi /la ks_pan.asm
pause
echo ---------------------------
echo Ensamblando: ks_mov.asm
echo ---------------------------
tasm /zi /la ks_mov.asm
pause
echo ---------------------------
echo Ensamblando: ks_son.asm
echo ---------------------------
tasm /zi /la ks_son.asm
pause
echo ---------------------------
echo Ensamblando: ks_rti.asm
echo ---------------------------
tasm /zi /la ks_rti.asm
pause
echo ---------------------------
echo Enlazando: KASTILLO.EXE
echo ---------------------------
tlink /v /m kastillo+ks_pan+ks_rti+ks_mov+ks_son

