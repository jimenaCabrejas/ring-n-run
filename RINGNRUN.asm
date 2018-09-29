;********************************************************************************************************************************************************************
; Proyecto Ring&Run
; By Lucia Conde & Jimena Cabrejas
; Si quieres crowdfundear este proyecto, manda tus donativos a S1B49, Mesa 4

	ORG	003;
	GOTO	PROGPAL		; 

;************************************************************************************************************************************************************************

; REGISTROS

;************************************************************************************************************************************************************************
;********************************************************************************************************************************************************************
	LIST	P=16F887		; Microcontrolador
;********************************************************************************************************************************************************************
; Registros y ctes propias del micro
	INCLUDE 	"P16F887.INC"

;********************************************************************************************************************************************************************
; Registros particulares del sistema

HORDEC		EQU	20 	; Decenas de hora del reloj
HORUNI		EQU	21 	; Unidades de hora del reloj
MINDEC		EQU	22 	; Decenas de minuto del reloj
MINUNI		EQU	23 	; Unidades de minuto del reloj
SEGDEC		EQU	24
SEGUNI		EQU	25
TICK		EQU	2E	; Marca de paso de 1 segundo
CONT		EQU	37	; Contador de llamadas en 1 segundo
TICK2		EQU	38

DESP_HORDEC	EQU	26 	; Decenas de hora del despertador
DESP_HORUNI	EQU	27 	; Unidades de hora del despertador
DESP_MINDEC	EQU	28 	; Decenas de minuto del despertador
DESP_MINUNI	EQU	29 	; Unidades de minuto del despertador
DESP		EQU	36	; 1: despertador programado, 0: no despertador

HOR1		EQU	3A	; Variable auxiliar para guardar las decenas de hora
HOR2		EQU	3B	; Variable auxiliar para guardar las unidadas de hora
MIN1		EQU	3C	; Variable auxiliar para guardar las decenas de minuto


EventoT		EQU	2A 	; Variable para el tipo de evento
EventoD		EQU	2B 	; Variable para el dato del evento
Tecla_aux	EQU	2C 	; Variable auxiliar

estado		EQU	2D 	; Variable de estado

NumRan		EQU	d'200'	; 200 ranuras a 100us cada una 20ms
ranura		EQU	39	; Variable de ranura de la máquina de tiempos

TEC_numv	EQU	33	; Teclado: número de veces estable
TEC_ant		EQU	34	; Teclado: tecla anterior
TEC_flg		EQU	35	; Teclado: flags de control
F_rep		EQU	0	; Teclado: flag de tecla reportada (bit 0)

	

TMP1		EQU	2F	; Variable temporal 
TMP2		EQU	30	; Variable temporal
				; Variables para salvado durante interrupción
SAVEPCL		EQU	7C	; Salvado de PCLATH
SAVEFSR		EQU	7D	; Salvado de FSR		
SAVEST		EQU	7E	; Salvado de Status
SAVEW		EQU	7F	; Salvado de W (7F, FF, 17F, 1FF)

;************************************************************************************************************************************************************************
; Configuración de tiempo de timer 2

prescal2	EQU	d'4'	; Valor del prescaler (1,4,16)
rperiod		EQU	d'5'	; Valor en el registro de período (0-256)
postscal	EQU	d'5'	; Valor calculado para el postscaler (1-16)


;**********************************************************************************
; Configuración de tiempo de timer 0

prescal0	EQU	d'5'	; Valor del prescaler según tabla
				; (0=>2, 1=>4, 2=>8,... 7=>256, 8=>1)
cnttmr0		EQU	d'125'	; Valor en contador(0-255)

;************************************************************************************************************************************************************************
; Registros del motor

P_SERVO		EQU	PORTA	; Puerto en el que l oenganchas
b_SERVO		EQU	2
servo_val	EQU	40
servo_cnt	EQU	41	;

;************************************************************************************************************************************************************************
; Registros del piezoeléctrico

P_SOUND		EQU	PORTC	;
b_SOUND		EQU	1	; En que punto del puerto A lo enganchas, atención todo menos el 6 y 7
sound_val	EQU	42	;
sound_cnt0	EQU	43	;
sound_cnt1	EQU	44	;


;************************************************************************************************************************************************************************
; Puertos LCD

P_LCDen	EQU	PORTD		; Puerto de bit de enable(strobe) LCD
b_LCDen	EQU	 4		;  bit de enable(strobe) LCD
P_LCDrw	EQU	PORTD		; Puerto de bit de read/write LCD
b_LCDrw	EQU	 5		;  bit de read/write LCD
P_LCDdi	EQU	PORTD		; Puerto de bit de dato/instruccion LCD
b_LCDdi	EQU	 6		;  bit de dato/instruccion LCD
P_LCDDA	EQU	PORTD		; Puerto de dato de LCD (4 bits menos significat.)


;************************************************************************************************************************************************************************
; Instrucciones LCD

lcd_clr	EQU	b'00000001'	; LCD clear
cur_hm	EQU	b'00000010'	; Cursor to home
cur_sa	EQU	b'10000000'	; Cursor to indicated position 
cur_on	EQU	b'00001010'	; Cursor on
cur_off	EQU	b'00001000'	; Cursor off
cur_rm	EQU	b'00010100'	; Cursor right move
cur_lm	EQU	b'00010000'	; Cursor left move
cur_l2	EQU	b'11000000'	; Cursor en segunda línea
cur_rma	EQU	b'00000110'	; Cursor auto right move
cur_lma	EQU	b'00000100'	; Cursor auto left move
cur_nor	EQU	b'00000110'	; Cursor auto-move normal (izq a dch)
cur_cal	EQU	b'00000111'	; Cursor auto-move calculadora (dch a izq)

;************************************************************************************************************************************************************************
; Constantes de tiempo (pueden variar segun frecuencia
;                       de operacion del microcontrolador)

klcdw	EQU	0FFh		; Constante para pausa 


;************************************************************************************************************************************************************************
; Configuración LCD

lcd_set	EQU	b'00101000'	; LCD: 4 bits, 2 líneas, 5x7 puntos
lcd_mod	EQU	b'00000110'	; Movimiento del cursor hacia la derecha
lcd_on	EQU	b'00001100'	; Display on, cursor off, blink off
lcd_off	EQU	b'00001000'	; Display off
lcd_to	EQU	d'200'		; Time-out para display ocupado


;************************************************************************************************************************************************************************
; Puerto de teclado

PKYBD	EQU	PORTB		; El teclado ocupa el puerto B de 8 bits


;************************************************************************************************************************************************************************
; Constantes de teclado

selc1	EQU	B'00000111'	; Selección de columna 1
selc2	EQU	B'00001011'	; Selección de columna 2
selc3	EQU	B'00001101'	; Selección de columna 3
selc4	EQU	B'00001110'	; Selección de columna 4
selca	EQU	B'00000000'	; Selección de todas las columnas
nminv	EQU	10		; Numero mínimo de veces para detectar estabilidad



;************************************************************************************************************************************************************************
;***************************************
;*** INTERRUPCIONES ***
	ORG	004 	; Dirección de Interrupcion
;***************************************
;************************************************************************************************************************************************************************

;************************************************************************************************************************************************************************
; INTERR
; Atención a interrupciones
; Crea cada un tick cada segundo 

INTERR:				; Salvado general de registros
	MOVWF	SAVEW		;  el registro W
	MOVF	STATUS,W	;  el Status
	CLRF	STATUS		;   
	MOVWF	SAVEST		;
	MOVF	FSR,W		;  el registro indirecto FSR
	MOVWF	SAVEFSR		;		
	MOVF	PCLATH,W	;  el registro PCLATH
	MOVWF	SAVEPCL		;
	CLRF	PCLATH		; Se trabajarán interrupciones en primera pagina
		
  ;******************* Interrupción por timer2
INTTMR2:				
	BTFSS	PIR1,TMR2IF	; Comprueba si es interrupción por TMR2
	GOTO	SIGINT		;  si no lo es, busca otra posible interrupción
				; Caso que hay interrupción por TMR2
	BCF	PIR1,TMR2IF	; Se resetea interrupcion para prox. vez
	
	CALL	MAQTIE		; Se inicia la rutina de atención
	CALL	GENSONIDO	; Suena

	GOTO	RETINT		;

SIGINT:
  ;******************* Fin interrupción por timer2

RETINT:				; Recuperación general de registros y retorno
	MOVF	SAVEPCL,W	;  el registro PCLATH
	MOVWF	PCLATH		;
	MOVF	SAVEFSR,W	;  el registro indirecto FSR
	MOVWF	FSR		;
	MOVF	SAVEST,W	;  el Status
	MOVWF	STATUS		;
	SWAPF	SAVEW,F		;  el registro W
	SWAPF	SAVEW,W		;
	RETFIE			;

;************************************************************************************************************************************************************************
;***************************************
;*** PROGRAMA PRINCIPAL ***
;***************************************
;************************************************************************************************************************************************************************

;************************************************************************************************************************************************************************
; PROGPAL
; Programa principal 

PROGPAL: 
	CALL	INITPORTS	; Inicializamos los puertos de la PICTOR
	CALL	INITTEC		; Inicializamos el teclado
	CALL	INITLCD		; Inicializamos la pantalla
	CALL	INITTMR2	; Inicializamos la interrupción
	CALL	INITRELOJ	; Inicializamos el cronómetro
	CALL	SERVO_INIT	; Inicializamos el motor
	CALL	INITESTADO	; Inicializamos el estado (estado 0)	
	BSF	INTCON,7	; Pone el GIE a 1
	CALL	VISRELOJ	; Se visualiza el reloj (empieza en 00:00:00)
	CLRF	CONT		; Se inicializan las variables de Gentick
	CLRF	TICK		; Se limpia la variable lógica TICK

LAZO:
	CALL	LEETECLA	; Se lee una tecla, se guarda en w
	CALL	ELIMREB		; Se elimina el rebote, y se vuelve a guardar en w
	CALL	REPORTT		; Te quedas solo con la tecla pulsada
	CALL	ENVEVENTO	; Se aplica la función (evento) pulsada
	CALL	MAQUEST		; Vamos a la máquina de estados
	GOTO	LAZO


;************************************************************************************************************************************************************************
;** MAQTIE
;** Máquina de tiempos
;** Para optimizar tiempos, debe ser puesta en la subpágina 0 (000h-0FFh)
;** Debe llamarse desde una interrupción de tiempo

	ORG	030			; Debe estar subpágina 0 para optimización en tiempo

MAQTIE:
	INCF	ranura,F		; Se actualiza la ranura del tiempo
	MOVLW 	-NumRan			; Se verifica que no se haya
	ADDWF	ranura,W		; superado el valor maximo
	BTFSC	STATUS,C		; de ranuras en caso contrario
	CLRF 	ranura			; se inicialza

	MOVF	ranura,W		;Se toma el numero de la ranura
	ADDWF	PCL,F			;Se salta a la ranura correspondiente

	GOTO	SERVO_CYC0		; Ranura 000 -> Inicio de ciclo del servo
	RETURN				; Ranura 001 ->
	RETURN				; Ranura 002 ->
	RETURN				; Ranura 003 ->
	RETURN				; Ranura 004 ->
	GOTO	SERVO_CYC1		; Ranura 005 -> Ciclo del servo
	GOTO	SERVO_CYC1		; Ranura 006 -> Ciclo del servo
	GOTO	SERVO_CYC1		; Ranura 007 -> Ciclo del servo
	GOTO	SERVO_CYC1		; Ranura 008 -> Ciclo del servo
	GOTO	SERVO_CYC1		; Ranura 009 -> Ciclo del servo

	GOTO	SERVO_CYC1		; Ranura 010 -> Ciclo del servo
	GOTO	SERVO_CYC1		; Ranura 011 -> Ciclo del servo
	GOTO	SERVO_CYC1		; Ranura 012 -> Ciclo del servo
	GOTO	SERVO_CYC1		; Ranura 013 -> Ciclo del servo
	GOTO	SERVO_CYC1		; Ranura 014 -> Ciclo del servo
	GOTO	SERVO_CYC1		; Ranura 015 -> Ciclo del servo
	GOTO	SERVO_CYC1		; Ranura 016 -> Ciclo del servo
	GOTO	SERVO_CYC1		; Ranura 017 -> Ciclo del servo
	GOTO	SERVO_CYC1		; Ranura 018 -> Ciclo del servo
	GOTO	SERVO_CYC1		; Ranura 019 -> Ciclo del servo

	GOTO	SERVO_CYC1		; Ranura 020 -> Ciclo del servo
	GOTO	SERVO_CYC1		; Ranura 021 -> Ciclo del servo
	GOTO	SERVO_CYC1		; Ranura 022 -> Ciclo del servo
	GOTO	SERVO_CYC1		; Ranura 023 -> Ciclo del servo
	GOTO	SERVO_CYC1		; Ranura 024 -> ...
	GOTO	SERVO_CYC1		; Ranura 025 ->
	GOTO	SERVO_CYC1		; Ranura 026 ->
	GOTO	SERVO_CYC1		; Ranura 027 ->
	GOTO	SERVO_CYC1		; Ranura 028 ->
	GOTO	SERVO_CYC1		; Ranura 029 ->

	GOTO	SERVO_CYC1		; Ranura 030 ->
	GOTO	SERVO_CYC1		; Ranura 031 ->
	GOTO	SERVO_CYC1		; Ranura 032 ->
	GOTO	SERVO_CYC1		; Ranura 033 ->
	GOTO	SERVO_CYC1		; Ranura 034 ->
	GOTO	SERVO_CYC1		; Ranura 035 ->
	GOTO	SERVO_CYC1		; Ranura 036 ->
	GOTO	SERVO_CYC1		; Ranura 037 ->
	GOTO	SERVO_CYC1		; Ranura 038 ->
	GOTO	SERVO_CYC1		; Ranura 039 ->

	GOTO	SERVO_CYC1		; Ranura 040 ->
	GOTO	SERVO_CYC1		; Ranura 041 ->
	GOTO	SERVO_CYC1		; Ranura 042 ->
	GOTO	SERVO_CYC1		; Ranura 043 ->
	GOTO	SERVO_CYC1		; Ranura 044 ->
	GOTO	SERVO_CYC1		; Ranura 045 ->
	GOTO	SERVO_CYC1		; Ranura 046 ->
	GOTO	SERVO_CYC1		; Ranura 047 ->
	GOTO	SERVO_CYC1		; Ranura 048 ->
	GOTO	SERVO_CYC1		; Ranura 049 ->

	GOTO	SERVO_CYC1		; Ranura 050 ->
	GOTO	SERVO_CYC1		; Ranura 051 ->
	GOTO	SERVO_CYC1		; Ranura 052 ->
	GOTO	SERVO_CYC1		; Ranura 053 ->
	GOTO	SERVO_CYC1		; Ranura 054 ->
	GOTO	SERVO_CYC1		; Ranura 055 ->
	GOTO	SERVO_CYC1		; Ranura 056 ->
	GOTO	SERVO_CYC1		; Ranura 057 ->
	GOTO	SERVO_CYC1		; Ranura 058 ->
	GOTO	SERVO_CYC1		; Ranura 059 ->

	GOTO	SERVO_CYC1		; Ranura 060 ->
	GOTO	SERVO_CYC1		; Ranura 061 ->
	GOTO	SERVO_CYC1		; Ranura 062 ->
	GOTO	SERVO_CYC1		; Ranura 063 ->
	GOTO	SERVO_CYC1		; Ranura 064 ->
	GOTO	SERVO_CYC1		; Ranura 065 ->
	GOTO	SERVO_CYC1		; Ranura 066 ->
	GOTO	SERVO_CYC1		; Ranura 067 ->
	GOTO	SERVO_CYC1		; Ranura 068 ->
	GOTO	SERVO_CYC1		; Ranura 069 ->

	GOTO	SERVO_CYC1		; Ranura 070 ->
	GOTO	SERVO_CYC1		; Ranura 071 ->
	GOTO	SERVO_CYC1		; Ranura 072 ->
	GOTO	SERVO_CYC1		; Ranura 073 ->
	GOTO	SERVO_CYC1		; Ranura 074 ->
	GOTO	SERVO_CYC1		; Ranura 075 ->
	GOTO	SERVO_CYC1		; Ranura 076 ->
	GOTO	SERVO_CYC1		; Ranura 077 ->
	GOTO	SERVO_CYC1		; Ranura 078 ->
	GOTO	SERVO_CYC1		; Ranura 079 ->

	GOTO	SERVO_CYC1		; Ranura 080 ->
	GOTO	SERVO_CYC1		; Ranura 081 ->
	GOTO	SERVO_CYC1		; Ranura 082 ->
	GOTO	SERVO_CYC1		; Ranura 083 ->
	GOTO	SERVO_CYC1		; Ranura 084 ->
	GOTO	SERVO_CYC1		; Ranura 085 ->
	GOTO	SERVO_CYC1		; Ranura 086 ->
	GOTO	SERVO_CYC1		; Ranura 087 ->
	GOTO	SERVO_CYC1		; Ranura 088 ->
	GOTO	SERVO_CYC1		; Ranura 089 ->

	GOTO	SERVO_CYC1		; Ranura 090 ->
	GOTO	SERVO_CYC1		; Ranura 091 ->
	GOTO	SERVO_CYC1		; Ranura 092 ->
	GOTO	SERVO_CYC1		; Ranura 093 ->
	GOTO	SERVO_CYC1		; Ranura 094 ->
	GOTO	SERVO_CYC1		; Ranura 095 ->
	GOTO	SERVO_CYC1		; Ranura 096 -> ...
	GOTO	SERVO_CYC1		; Ranura 097 -> Ciclo del servo
	GOTO	SERVO_CYC1		; Ranura 098 -> Ciclo del servo
	GOTO	SERVO_CYC1		; Ranura 099 -> Ciclo del servo

	GOTO	SERVO_CYC2		; Ranura 100 -> Fin de ciclo de servo (obligado)
	RETURN				; Ranura 101 ->
	RETURN				; Ranura 102 ->
	RETURN				; Ranura 103 ->
	RETURN				; Ranura 104 ->
	RETURN				; Ranura 105 ->
	RETURN				; Ranura 106 ->
	RETURN				; Ranura 107 ->
	RETURN				; Ranura 108 ->
	RETURN				; Ranura 109 ->

	RETURN				; Ranura 110 ->
	RETURN				; Ranura 111 ->
	RETURN				; Ranura 112 ->
	RETURN				; Ranura 113 ->
	RETURN				; Ranura 114 ->
	RETURN				; Ranura 115 ->
	RETURN				; Ranura 116 ->
	RETURN				; Ranura 117 ->
	RETURN				; Ranura 118 ->
	RETURN				; Ranura 119 ->

	RETURN				; Ranura 120 ->
	RETURN				; Ranura 121 ->
	RETURN				; Ranura 122 ->
	RETURN				; Ranura 123 ->
	RETURN				; Ranura 124 ->
	RETURN				; Ranura 125 ->
	RETURN				; Ranura 126 ->
	RETURN				; Ranura 127 ->
	RETURN				; Ranura 128 ->
	RETURN				; Ranura 129 ->

	RETURN				; Ranura 130 ->
	RETURN				; Ranura 131 ->
	RETURN				; Ranura 132 ->
	RETURN				; Ranura 133 ->
	RETURN				; Ranura 134 ->
	RETURN				; Ranura 135 ->
	RETURN				; Ranura 136 ->
	RETURN				; Ranura 137 ->
	RETURN				; Ranura 138 ->
	RETURN				; Ranura 139 ->

	RETURN				; Ranura 140 ->
	RETURN				; Ranura 141 ->
	RETURN				; Ranura 142 ->
	RETURN				; Ranura 143 ->
	RETURN				; Ranura 144 ->
	RETURN				; Ranura 145 ->
	RETURN				; Ranura 146 ->
	RETURN				; Ranura 147 ->
	RETURN				; Ranura 148 ->
	RETURN				; Ranura 149 ->

	RETURN				; Ranura 150 ->
	RETURN				; Ranura 151 ->
	RETURN				; Ranura 152 ->
	RETURN				; Ranura 153 ->
	RETURN				; Ranura 154 ->
	RETURN				; Ranura 155 ->
	RETURN				; Ranura 156 ->
	RETURN				; Ranura 157 ->
	RETURN				; Ranura 158 ->
	RETURN				; Ranura 159 ->

	RETURN				; Ranura 160 ->
	RETURN				; Ranura 161 ->
	RETURN				; Ranura 162 ->
	RETURN				; Ranura 163 ->
	RETURN				; Ranura 164 ->
	RETURN				; Ranura 165 ->
	RETURN				; Ranura 166 ->
	RETURN				; Ranura 167 ->
	RETURN				; Ranura 168 ->
	RETURN				; Ranura 169 ->

	RETURN				; Ranura 170 ->
	RETURN				; Ranura 171 ->
	RETURN				; Ranura 172 ->
	RETURN				; Ranura 173 ->
	RETURN				; Ranura 174 ->
	RETURN				; Ranura 175 ->
	RETURN				; Ranura 176 ->
	RETURN				; Ranura 177 ->
	RETURN				; Ranura 178 ->
	RETURN				; Ranura 179 ->

	RETURN				; Ranura 180 ->
	RETURN				; Ranura 181 ->
	RETURN				; Ranura 182 ->
	RETURN				; Ranura 183 ->
	RETURN				; Ranura 184 ->
	RETURN				; Ranura 185 ->
	RETURN				; Ranura 186 ->
	RETURN				; Ranura 187 ->
	RETURN				; Ranura 188 ->
	RETURN				; Ranura 189 ->

	RETURN				; Ranura 190 -> Generación de 1 seg
	RETURN				; Ranura 191 ->
	RETURN				; Ranura 192 ->
	RETURN				; Ranura 193 ->
	RETURN				; Ranura 194 ->
	RETURN				; Ranura 195 ->
	RETURN				; Ranura 196 ->
	RETURN				; Ranura 197 ->
	RETURN				; Ranura 198 ->
	GOTO	GENTICK			; Ranura 199 -> Tick de 20ms para tiempo
;************************************************************************************************************************************************************************
;***************************************
;*** TABLAS Y MÁQUINAS ***
	ORG	100
;***************************************
;************************************************************************************************************************************************************************

;************************************************************************************************************************************************************************

; TABLAS DE TRADUCCIÓN

;************************************************************************************************************************************************************************
;************************************************************************************************************************************************************************
; TRATECLA
; Traduce código de tecla al carácter correspondiente
; Recibe:  W: código de tecla (0-16)
; Retorna: W: código de tecla traducido
; Nota: está preparado para trabajar en la página 100-1FF


TRATECLA:

	CLRF	PCLATH		; Funciona en direcciones 100-1FF
	BSF	PCLATH,0	; 
	BCF	PCLATH,1	;

	ADDWF	PCL,F		;
	RETLW	0		; No tecla
	RETLW	'A'		; 	
	RETLW	'B'		; 
	RETLW	'C'
	RETLW	'D'
	RETLW	d'3'
	RETLW	d'6'		 
	RETLW	d'9'			
	RETLW	'#'
	RETLW	d'2'			 
	RETLW	d'5'			 
	RETLW	d'8'			 
	RETLW	d'0'
	RETLW	d'1'			 
	RETLW	d'4'
	RETLW	d'7'
	RETLW	'*'

;************************************************************************************************************************************************************************
; TRATECLA1
; Indica el tipo de tecla pulsada (número, letra o función)
; Recibe:  W: código de tecla (0-16)
; Retorna: W: código de tecla traducido
; Nota: está preparado para trabajar en la página 100-1FF


TRATECLA1:

	CLRF	PCLATH		; Funciona en direcciones 100-1FF
	BSF	PCLATH,0	; 
	BCF	PCLATH,1	;

	ADDWF	PCL,F		;
	RETLW	0		; No tecla
	RETLW	d'2'		; Tipos:
	RETLW	d'3'		; 0: Nada
	RETLW	d'4'		; 1: Números
	RETLW	d'5'		; 2: A (ajustar hora)
	RETLW	d'1'		; 3: B (apagar despertador)
	RETLW	d'1'		; 4: C (cancelar despertador)
	RETLW	d'1'		; 5: D (programar despertador)
	RETLW	0		; 6: * (cancelar operación)
	RETLW	d'1'		;
	RETLW	d'1'
	RETLW	d'1'
	RETLW	d'1'
	RETLW	d'1'
	RETLW	d'1'
	RETLW	d'1'
	RETLW	d'6'


;************************************************************************************************************************************************************************

; MÁQUINAS

;************************************************************************************************************************************************************************

;************************************************************************************************************************************************************************
; MAQUEST
; Maquina de estados

MAQUEST:
	CLRF	PCLATH			; Funciona en direcciones 100-1FF
	BSF	PCLATH,0		; 
	BCF	PCLATH,1		;

	MOVF	estado,W		; Miramos en qué estado estamos
	ADDWF	PCL,F			; Saltamos a la rutina precisa
	GOTO	HORA			; Estado 0, está dando la hora
	GOTO	ESP_HORDEC		; Estado 1, cambiar hora: decena hora
	GOTO	ESP_HORUNI1		; Estado 2, cambiar hora: unidad hora (si HORDEC=0 ó 1)
	GOTO	ESP_HORUNI2		; Estado 3, cambiar hora: unidad hora (si HORDEC=2)
	GOTO	ESP_MINDEC		; Estado 4, cambiar hora: decena minuto
	GOTO	ESP_MINUNI		; Estado 5, cambiar hora: unidad minuto
	GOTO	ESP_DESPHORDEC		; Estado 6, configurar despertador: decena hora
	GOTO	ESP_DESPHORUNI1		; Estado 7, configurar despertador: unidad hora (si HORDEC=0 ó 1)
	GOTO	ESP_DESPHORUNI2		; Estado 8, configurar despertador: unidad hora (si HORDEC=2)
	GOTO	ESP_DESPMINDEC		; Estado 9, configurar despertador: decena minuto
	GOTO	ESP_DESPMINUNI		; Estado 10, configurar despertador: unidad minuto
	GOTO	DESPERTADOR		; Estado 11, ringing amphersand running

;************************************************************************************************************************************************************************
; MÁQUINAS DE EVENTOS
;************************************************************************************************************************************************************************
; Estado 0

HORA:		
	CLRF	PCLATH		; Funciona en direcciones 100-1FF
	BSF	PCLATH,0	; 
	BCF	PCLATH,1	;

	CALL	LEEVENTO	; Se comprueba el tipo de la tecla introducida
	ADDWF	PCL,F		;
	RETURN			; No evento
	RETURN			; Número
	GOTO	AC_CAMBIAHORA	; A
	RETURN			; B
	GOTO	AC_CANCELDESP	; C
	GOTO	AC_PROGDESP	; D
	RETURN			; *
	GOTO	AC_INCRELOJ	; Tick	


;************************************************************************************************************************************************************************
; Estado 1

ESP_HORDEC:
	CLRF	PCLATH		; Funciona en direcciones 100-1FF
	BSF	PCLATH,0	; 
	BCF	PCLATH,1	;

	CALL	LEEVENTO	; Se comprueba el tipo de la tecla introducida
	ADDWF	PCL,F		;
	RETURN			; No evento
	GOTO	AC_VERHORDEC	; Número
	RETURN			; A
	RETURN			; B
	RETURN			; C
	RETURN			; D
	GOTO	AC_CANCELOP	; *
	RETURN			; Tick	

;************************************************************************************************************************************************************************
; Estado 2

ESP_HORUNI1:
	CLRF	PCLATH		; Funciona en direcciones 100-1FF
	BSF	PCLATH,0	; 
	BCF	PCLATH,1	;

	CALL	LEEVENTO	; Se comprueba el tipo de la tecla introducida
	ADDWF	PCL,F		;
	RETURN			; No evento
	GOTO	AC_VERHORUNI1	; Número
	RETURN			; A
	RETURN			; B
	RETURN			; C
	RETURN			; D
	GOTO	AC_CANCELOP	; *
	RETURN			; Tick	

;************************************************************************************************************************************************************************
; Estado 3

ESP_HORUNI2:
	CLRF	PCLATH		; Funciona en direcciones 100-1FF
	BSF	PCLATH,0	; 
	BCF	PCLATH,1	;

	CALL	LEEVENTO	; Se comprueba el tipo de la tecla introducida
	ADDWF	PCL,F		;
	RETURN			; No evento
	GOTO	AC_VERHORUNI2	; Número
	RETURN			; A
	RETURN			; B
	RETURN			; C
	RETURN			; D
	GOTO	AC_CANCELOP	; *
	RETURN			; Tick	

;************************************************************************************************************************************************************************
; Estado 4

ESP_MINDEC:
	CLRF	PCLATH		; Funciona en direcciones 100-1FF
	BSF	PCLATH,0	; 
	BCF	PCLATH,1	;

	CALL	LEEVENTO	; Se comprueba el tipo de la tecla introducida
	ADDWF	PCL,F		;
	RETURN			; No evento
	GOTO	AC_VERMINDEC	; Número
	RETURN			; A
	RETURN			; B
	RETURN			; C
	RETURN			; D
	GOTO	AC_CANCELOP	; *
	RETURN			; Tick	

;************************************************************************************************************************************************************************
; Estado 5

ESP_MINUNI:
	CLRF	PCLATH		; Funciona en direcciones 100-1FF
	BSF	PCLATH,0	; 
	BCF	PCLATH,1	;

	CALL	LEEVENTO	; Se comprueba el tipo de la tecla introducida
	ADDWF	PCL,F		;
	RETURN			; No evento
	GOTO	AC_GUARDAHORA	; Número
	RETURN			; A
	RETURN			; B
	RETURN			; C
	RETURN			; D
	GOTO	AC_CANCELOP	; *
	RETURN			; Tick	

;************************************************************************************************************************************************************************
; Estado 6

ESP_DESPHORDEC:
	CLRF	PCLATH		; Funciona en direcciones 100-1FF
	BSF	PCLATH,0	; 
	BCF	PCLATH,1	;

	CALL	LEEVENTO	; Se comprueba el tipo de la tecla introducida
	ADDWF	PCL,F		;
	RETURN			; No evento
	GOTO	AC_VERHORDEC	; Número
	RETURN			; A
	RETURN			; B
	RETURN			; C
	RETURN			; D
	GOTO	AC_CANCELOP	; *
	GOTO	INCRELOJ	; Tick	

;************************************************************************************************************************************************************************
; Estado 7

ESP_DESPHORUNI1:
	CLRF	PCLATH		; Funciona en direcciones 100-1FF
	BSF	PCLATH,0	; 
	BCF	PCLATH,1	;

	CALL	LEEVENTO	; Se comprueba el tipo de la tecla introducida
	ADDWF	PCL,F		;
	RETURN			; No evento
	GOTO	AC_VERHORUNI1	; Número
	RETURN			; A
	RETURN			; B
	RETURN			; C
	RETURN			; D
	GOTO	AC_CANCELOP	; *
	GOTO	INCRELOJ	; Tick	

;************************************************************************************************************************************************************************
; Estado 8

ESP_DESPHORUNI2:
	CLRF	PCLATH		; Funciona en direcciones 100-1FF
	BSF	PCLATH,0	; 
	BCF	PCLATH,1	;

	CALL	LEEVENTO	; Se comprueba el tipo de la tecla introducida
	ADDWF	PCL,F		;
	RETURN			; No evento
	GOTO	AC_VERHORUNI2	; Número
	RETURN			; A
	RETURN			; B
	RETURN			; C
	RETURN			; D
	GOTO	AC_CANCELOP	; *
	GOTO	INCRELOJ	; Tick	

;************************************************************************************************************************************************************************
; Estado 9

ESP_DESPMINDEC:
	CLRF	PCLATH		; Funciona en direcciones 100-1FF
	BSF	PCLATH,0	; 
	BCF	PCLATH,1	;

	CALL	LEEVENTO	; Se comprueba el tipo de la tecla introducida
	ADDWF	PCL,F		;
	RETURN			; No evento
	GOTO	AC_VERMINDEC	; Número
	RETURN			; A
	RETURN			; B
	RETURN			; C
	RETURN			; D
	GOTO	AC_CANCELOP	; *
	GOTO	INCRELOJ	; Tick	

;************************************************************************************************************************************************************************
; Estado 10

ESP_DESPMINUNI:
	CLRF	PCLATH		; Funciona en direcciones 100-1FF
	BSF	PCLATH,0	; 
	BCF	PCLATH,1	;

	CALL	LEEVENTO	; Se comprueba el tipo de la tecla introducida
	ADDWF	PCL,F		;
	RETURN			; No evento
	GOTO	AC_GUARDADESP	; Número
	RETURN			; A
	RETURN			; B
	RETURN			; C
	RETURN			; D
	GOTO	AC_CANCELOP	; *
	GOTO	INCRELOJ	; Tick	

;************************************************************************************************************************************************************************
; Estado 11

DESPERTADOR:
	CLRF	PCLATH		; Funciona en direcciones 100-1FF
	BSF	PCLATH,0	; 
	BCF	PCLATH,1	;

	CALL	LEEVENTO	; Se comprueba el tipo de la tecla introducida
	ADDWF	PCL,F		;
	RETURN			; No evento
	RETURN			; Número
	RETURN			; A
	GOTO	AC_APAGAR	; B
	RETURN			; C
	RETURN			; D
	RETURN			; *
	GOTO	INCRELOJ	; Tick	
;	GOTO	AC_RINGRUN	; Tick de sonido



;************************************************************************************************************************************************************************
;***************************************
;*** ACCIONES E INICIALIZACIONES ***
	ORG	200
;***************************************
;************************************************************************************************************************************************************************

; ACCIONES

;************************************************************************************************************************************************************************
; AC_INCRELOJ
; Acción que incrementa un segundo el reloj y lo visualiza

AC_INCRELOJ:
	CALL	INCRELOJ
	CALL	VISRELOJ
	RETURN

;************************************************************************************************************************************************************************
; AC_CAMBIAHORA
; Pasamos al estado de configurar la hora

AC_CAMBIAHORA:
	MOVLW	d'1'		; Pasamos al estado 1 
	MOVWF	estado
	MOVLW	lcd_clr		; Se limpia la pantalla
	CALL	LCDIWR		;
	RETURN

;************************************************************************************************************************************************************************
; AC_PROGDESP
; Pasamos al estado de configurar el despertador

AC_PROGDESP:
	MOVLW	d'6'		; Pasamos al estado 6 
	MOVWF	estado
	MOVLW	lcd_clr		; Se limpia la pantalla
	CALL	LCDIWR		;
	CALL	VISDESP		;
	RETURN
;************************************************************************************************************************************************************************
; AC_CANCELOP
; Volvemos al estado 0 (visualizar la hora)

AC_CANCELOP:
	MOVLW	lcd_clr		; Se limpia la pantalla
	CALL	LCDIWR		;
	CALL	INITESTADO	;
	RETURN			;

;************************************************************************************************************************************************************************
; AC_CANCELDESP
; Cancelamos el despertador programado

AC_CANCELDESP:
	MOVLW	lcd_clr		; Se limpia la pantalla
	CALL	LCDIWR		;
	RETURN

;************************************************************************************************************************************************************************
; AC_VERHORDEC
; Verificamos que el dígito introducido para las decenas de hora es correcto

AC_VERHORDEC:
	CALL	LEE_DATO	;
	ADDLW	-d'3'		; Miramos si es menor que dos
	BTFSC	STATUS,C	;
	RETURN

	CALL	LEE_DATO	; Si no es igual a 2 
	XORLW	d'2'		; vamos al lazo HORA1
	BTFSS	STATUS,Z	;
	GOTO	HORA1
				; Si es igual a 2
	CALL	LEE_DATO	; Guardamos la cifra en HORDEC
	MOVWF	HOR1
	ADDLW	'0'		; Se pasa a ASCII
	CALL	LCDDWR		; Escribimos el número introducido en pantalla
	INCF	estado,F
	INCF	estado,F	; Aumentamos el estado dos veces
	RETURN
HORA1:
	CALL	LEE_DATO	; Guardamos la cifra en HORDEC
	MOVWF	HOR1		; 
	ADDLW	'0'		; Se pasa a ASCII
	CALL	LCDDWR		; Escribimos el número introducido en pantalla
	INCF	estado,F	; Aumentamos el estado
	
	RETURN


;************************************************************************************************************************************************************************
; AC_GUARDAHORUNI
; Guardamos las unidades de hora (puede ser cualquier valor de 0 a 9)

AC_VERHORUNI1:
	CALL	LEE_DATO
	MOVWF	HOR2
	ADDLW	'0'		; Se pasa a ASCII
	CALL	LCDDWR
	INCF	estado,F	; Pasamos a verificar las decenas de minuto
	INCF	estado,F
	RETURN
	
;************************************************************************************************************************************************************************
; AC_VERHORUNI
; Verificamos las unidades de hora (tiene que ser menor que 4) y la guardamos si el valor es correcto

AC_VERHORUNI2:
	CALL	LEE_DATO	;
	ADDLW	-d'4'		; Miramos si es menor que cuatro
	BTFSC	STATUS,C	;
	RETURN
	
	DECF	estado,F
	GOTO	AC_VERHORUNI1	;

;************************************************************************************************************************************************************************
; AC_VERMINDEC
; Verificamos las decenas de minuto (tiene que ser menor que 6) y la guardamos si el valor es correcto

AC_VERMINDEC:
	CALL	LEE_DATO	;
	ADDLW	-d'6'		; Miramos si es menor que seis
	BTFSC	STATUS,C	;
	RETURN

	MOVLW	':'		; Se escriben dos puntos
	CALL	LCDDWR		; 

	CALL	LEE_DATO
	MOVWF	MIN1
	ADDLW	'0'		; Se pasa a ASCII
	CALL	LCDDWR

	MOVF	estado,W	;	; Si no es igual a 2 
	XORLW	d'4'		; vamos al lazo HORA1
	BTFSS	STATUS,Z	;
	INCF	estado,F

	MOVLW	d'10'		;
	MOVWF	estado		; Miramos si es menor que seis
	RETURN			;

;************************************************************************************************************************************************************************
; AC_GUARDAHORA
; Verificamos las unidades de minuto (tiene que ser menor que cualquier valor, solo guardamos) y la guardamos si el valor es correcto

AC_GUARDAHORA:
	CALL	LEE_DATO	;Guardamos las unidades de minuto
	MOVWF	MINUNI
	ADDLW	'0'		; Se pasa a ASCII
	CALL	LCDDWR
	MOVF	HOR1,W
	MOVWF	HORDEC		;Guardamos las decenas de hora
	MOVF	HOR2,W		
	MOVWF	HORUNI		;Guardamos las unidades de hora
	MOVF	MIN1,W		
	MOVWF	MINDEC		;Guardamos las decenas de minuto
	CALL	INITESTADO	;
	MOVLW	lcd_clr		; Se limpia la pantalla
	CALL	LCDIWR		;
	RETURN	

;************************************************************************************************************************************************************************
; AC_GUARDADESP
; Guardamos la hora de despertador programada

AC_GUARDADESP:
	CALL	LEE_DATO
	MOVWF	DESP_MINUNI	;Guardamos las unidades de minuto
	ADDLW	'0'		; Se pasa a ASCII
	CALL	LCDDWR
	MOVF	HOR1,W
	MOVWF	DESP_HORDEC	;Guardamos las decenas de hora
	MOVF	HOR2,W		
	MOVWF	DESP_HORUNI	;Guardamos las unidades de hora
	MOVF	MIN1,W		
	MOVWF	DESP_MINDEC	;Guardamos las decenas de minuto
	CALL	INITESTADO	; Volvemos al estado 0
	RETURN	




;************************************************************************************************************************************************************************
; AC_APAGAR
; Apagamos el despertador

AC_APAGAR:
	CALL	INITESTADO
	MOVLW	lcd_clr		; Se limpia la pantalla
	CALL	LCDIWR		;
	RETURN	

;************************************************************************************************************************************************************************

; RUTINAS

;************************************************************************************************************************************************************************
;************************************************************************************************************************************************************************
; VISTEXTO
; Visualiza en pantalla "Despierta!"

VISTEXTO:
	MOVLW	lcd_clr		; Se limpia la pantalla
	CALL	LCDIWR		;

	MOVLW	'D'		; Se toma cada letra en ASCII y
	CALL	LCDDWR		; se envia a la pantalla
	MOVLW	'e'		; 
	CALL	LCDDWR		;
	MOVLW	's'		; 
	CALL	LCDDWR		;
	MOVLW	'p'		;
	CALL	LCDDWR		; 
	MOVLW	'i'		; 
	CALL	LCDDWR		;
	MOVLW	'e'		; 
	CALL	LCDDWR		;
	MOVLW	'r'		; 
	CALL	LCDDWR		;
	MOVLW	't'		;
	CALL	LCDDWR		; 
	MOVLW	'a'		; 
	CALL	LCDDWR		;
	MOVLW	'!'		; 
	CALL	LCDDWR		;


	RETURN
;************************************************************************************************************************************************************************
; VISDESP
; Visualiza en pantalla Desp

VISDESP:
	MOVLW	'D'		; Se toma cada letra en ASCII y
	CALL	LCDDWR		; se envia a la pantalla
	MOVLW	'e'		; 
	CALL	LCDDWR		;
	MOVLW	's'		; 
	CALL	LCDDWR		;
	MOVLW	'p'		;
	CALL	LCDDWR		; 
	MOVLW	' '		; 
	CALL	LCDDWR		;

	RETURN

;************************************************************************************************************************************************************************
; INCRELOJ
; Rutina que incrementa un segundo el reloj

INCRELOJ:	
	INCF	SEGUNI,F	; Se incrementan las unidades de segundos
	MOVF	SEGUNI,W	;	
	XORLW	d'10'		;
	BTFSS	STATUS,Z	;
	RETURN			;

	CLRF	SEGUNI		;
	INCF	SEGDEC,F	; Se incrementan las decenas de segundos
	MOVF	SEGDEC,W	;	
	XORLW	d'6'		;
	BTFSS	STATUS,Z	;
	RETURN			;

	CLRF	SEGDEC		;
	INCF	MINUNI,F	; Se incrementan las unidades de minutos
	CALL	COMPROBAR_DESP	; Al incrementar los minutos, se comprueba si la hora coincide
	MOVF	MINUNI,W	;	con la del despertador programado (si lo hay)
	XORLW	d'10'		;
	BTFSS	STATUS,Z	;
	RETURN			;

	CLRF	MINUNI		;
	INCF	MINDEC,F	; Se incrementan las decenas de minutos
	CALL	COMPROBAR_DESP	
	MOVF	MINDEC,W	;	
	XORLW	d'6'		;
	BTFSS	STATUS,Z	;
	RETURN			;

	CLRF	MINDEC		; 
	INCF	HORUNI,F	; Se incrementan las unidades de hora
	CALL	COMPROBAR_DESP
	MOVF	HORDEC,W	;
	XORLW	d'2'		;
	BTFSC	STATUS,Z
	GOTO	NOCHE
	MOVF	HORUNI,W	;	
	XORLW	d'10'		;
	BTFSS	STATUS,Z	;
	RETURN
	GOTO	DIA

NOCHE:
	MOVF	HORUNI,W	;
	XORLW	d'4'		;
	BTFSS	STATUS,Z
	RETURN
	GOTO	DIA

DIA:
	CLRF	HORUNI		; 
	INCF	HORDEC,F	; Se incrementan las decenas de hora
	CALL	COMPROBAR_DESP
	MOVF	HORDEC,W	;
	XORLW	d'3'		;
	BTFSS	STATUS,Z	;
	RETURN

	CLRF	HORDEC		;
	CALL	COMPROBAR_DESP
	RETURN			;

;************************************************************************************************************************************************************************
; GENSONIDO
; Genera el sonido

GENSONIDO:
	MOVF	estado,W	;
	XORLW	d'11'		; Se comprueba que estamos en el estado 11
	BTFSS	STATUS,Z	;	(está sonando el despertador)
	RETURN

	MOVLW	d'150' 		; poner la frecuencia que queremos
	CALL	SOUND		; 
	CALL	GEN_SOUND	; Generamos el sonido
	RETURN

;************************************************************************************************************************************************************************
; COMPROBAR_DESP
; Rutina que compara la hora con la del despertador programado

COMPROBAR_DESP:
	MOVF	DESP,W		;
	XORLW	d'1'		; Se comprueba que el flag desp está a 1
	BTFSS	STATUS,Z	;	(hay un despertador programado)
	RETURN

	MOVF	HORDEC,W	;
	XORWF	DESP_HORDEC,W	; Se comparan las decenas de hora 
	BTFSS	STATUS,Z	;
	RETURN			;

	MOVF	HORUNI,W	;
	XORWF	DESP_HORUNI,W	; Se comparan las unidades de hora 
	BTFSS	STATUS,Z	;
	RETURN			;

	MOVF	MINDEC,W	;
	XORWF	DESP_MINDEC,W	; Se comparan las decenas de minuto
	BTFSS	STATUS,Z	;
	RETURN			;

	MOVF	MINUNI,W	;
	XORWF	DESP_MINUNI,W	; Se comparan las unidades de minuto
	BTFSS	STATUS,Z	;
	RETURN			;
				; Si la hora y el despertador programado coinciden, 
	CLRF	DESP		; 	se elimina el despertador
	MOVLW	d'11'		; 
	MOVWF	estado		;	se pasa al estado "Despertador" (despertador sonando y moviéndose)
	CALL	VISTEXTO	;	se escribe en la pantalla "despierta!"

	RETURN			;

;************************************************************************************************************************************************************************
; LEEVENTO
; Rutina para especificar el tipo de evento ocurrido
; Devuelve W: tipo de evento

LEEVENTO:
	MOVF	EventoT,W	; Comprobamos si el eventoT es 0
	XORLW	0		; 
	BTFSS	STATUS,Z	;
	GOTO	EVENTOT		; Si no lo es, devolvemos su valor

	MOVF	TICK,W		; Si lo es verificamos el TICK
	XORLW	0		; 
	BTFSC	STATUS,Z	; 
	GOTO	EVENTOT		; Devolvemos 0 si el TICK está a cero

	MOVLW	0		;
	MOVWF	TICK		;
	RETLW	7		; Devolvemos 7 si el TICK está a cuatro

EVENTOT:
	MOVF	EventoT,W	; Devolvemos EventoT
	RETURN

;************************************************************************************************************************************************************************
; ENVEVENTO
; Traduce el codigo recibido de teclado
; Recibe: W:tecla

ENVEVENTO:
	MOVWF	Tecla_aux	; Guarda el valor de la tecla pulsada
	CALL	TRATECLA1	; Guarda en EventoT el tipo de evento que se ha pulsado
	MOVWF	EventoT		; 
	MOVF	Tecla_aux,W	; Mueve el valor de la tecla a w
	CALL	TRATECLA	; Guarda en EventoD el evento que se ha pulsado
	MOVWF	EventoD		;
	RETURN	

;************************************************************************************************************************************************************************
; VISRELOJ
; Visualiza el reloj

VISRELOJ:
	MOVLW	cur_l2		; Se manda el cursor a la segunda linea
	CALL	LCDIWR		;

	MOVF	HORDEC, W	; Se cogen las decenas de hora
	ADDLW	'0'		; Se pasa a ASCII
	CALL	LCDDWR		; Se manda a la pantalla
	
	MOVF	HORUNI, W	; Se cogen las unidades de hora
	ADDLW	'0'		; Se pasa a ASCII
	CALL	LCDDWR		; Se manda a la pantalla

	MOVLW	':'		; Se escriben dos puntos
	CALL	LCDDWR		; 
	
	MOVF	MINDEC, W	; Se cogen las decenas de minuto
	ADDLW	'0'		; Se pasa a ASCII
	CALL	LCDDWR		; Se manda a la pantalla
	
	MOVF	MINUNI, W	; Se cogen las unidades de minuto
	ADDLW	'0'		; Se pasa a ASCII
	CALL	LCDDWR		; Se manda a la pantalla
	
	MOVLW	':'		; Se escriben dos puntos
	CALL	LCDDWR		; 

	MOVF	SEGDEC, W	; Se cogen las decenas de segundo
	ADDLW	'0'		; Se pasa a ASCII
	CALL	LCDDWR		; Se manda a la pantalla

	MOVF	SEGUNI, W	; Se cogen las unidades de segundo
	ADDLW	'0'		; Se pasa a ASCII
	CALL	LCDDWR		; Se manda a la pantalla

	RETURN			;

;************************************************************************************************************************************************************************
; LEE_DATO
; Rutina para leer la cifra introducida
; Devuelve W: la cifra introducida

LEE_DATO:
	MOVF	EventoD, W	; Se devuelve la cifra
	RETURN			;

;************************************************************************************************************************************************************************
; GENTICK
; Genera una marca/tick cada segundo
GENTICK:
	DECFSZ	CONT,F		; Se decrementa el contador y se salta la siguiente instrucción
	RETURN			; si está a 0 (se sale de Gentick si no lo es)

	MOVLW	d'50'		; Se pone 50 en el registro
	MOVWF	CONT		; y se guarda ese valor en el contador (se reinicia el contador)
	BSF	TICK,0		; Pone a 1 el tick
	RETURN


;************************************************************************************************************************************************************************
; SERVO_CYC0:
; Inicializa ciclo de servo (inicio de pulso)
; Debe llamarse en la ranura 0 de la máquina de tiempo

SERVO_CYC0:
	BSF	P_SERVO,b_SERVO		; Se activa ciclo del servo
	MOVF	servo_val,W		; Se inicializa contador de pulso para
	MOVWF	servo_cnt		; contar el tiempo que estará a uno
	RETURN				;


;************************************************************************************************************************************************************************
; SERVO_CYC1:
; Ciclo de servo a uno '1'
; Debe llamarse en todas las ranuras desde la ranura correspondiente al
; ciclo mínimo (0.5ms: ranura 5 en caso de ranuras a 0.1ms) hasta la ranura
; anterior al ciclo máximo (2.4ms: ranura 23 en caso de ranuras a 0.1ms)

SERVO_CYC1:
	MOVF	servo_cnt,F		; Se averigua si llegó a cero
	BTFSC	STATUS,Z		;
	GOTO	SERVO_CYC1_1		;
	DECF	servo_cnt,F		; si no es cero, se decrementa el contador
	RETURN				;
SERVO_CYC1_1:				; si ya en cero, se obliga a poner
	BCF	P_SERVO,b_SERVO		; pulso a cero
	RETURN				;


;************************************************************************************************************************************************************************
; SERVO_CYC2:
; Ciclo de servo apagado por exigencia independiente del valor solicitado
; Debe llamarse en la ranura correspondiente al ciclo máximo
; (2.4ms: ranura 24 en caso de ranuras a 0.1ms)

SERVO_CYC2:
	BCF	P_SERVO,b_SERVO		; pulso a cero se acabo el tiempo
	RETURN				;

;************************************************************************************************************************************************************************
; SOUND()
; Fija el valor de frecuencia
; Recibe: W: valor de frecuencia (0-255) f= W /((256*4)*0.0001)

SOUND:
 	MOVWF	sound_val	; Se transfiere valor a la variable correspondiente
	RETURN			;

;************************************************************************************************************************************************************************
; GEN_SOUND
; Genera el sonido. Debe ser llamada desde la interrupción de tiempo cada
; 100us (0.0001s).
; El parámetro debe ser almacenado en sound_val, un valor entre 0 y 255, la
; frecuencia obtenida será   f=sound_val/((256*4)*0.0001)

GEN_SOUND:
	MOVF	sound_val,W	;
	BTFSC	STATUS,Z	; Si el valor es cero,
	GOTO	GEN_SOUND1	; se apaga

	ADDWF	sound_cnt0,F	; Se acumula la fase
	BTFSC	STATUS,C	; en un word
	INCF	sound_cnt1,F	;

	MOVLW	b'00000011'	; Se limita el conteo a 1024, es decir un máximo
	ANDWF	sound_cnt1,F	; de 1024 muestras para completar un período

	BTFSC	sound_cnt1,1	; Para salida binaria se toma el bit más significativo
	BSF	P_SOUND,b_SOUND	;
	BTFSS	sound_cnt1,1	;
GEN_SOUND1:
	BCF	P_SOUND,b_SOUND	;
	RETURN			;

;************************************************************************************************************************************************************************

; RUTINAS DE TECLADO

;************************************************************************************************************************************************************************
; LEETECLA
; Lee teclado
; Retorna: W: 0 si no hay tecla presionada, de lo contrario código de tecla

LEETECLA:
				; Se hace una verificación rápida de si
				; hay tecla presionada
	CLRF	TMP2		; Se inicializa registro de código COD=0
	MOVLW	selca		; Selecciona todas las columnas simultáneamente
	MOVWF	PKYBD		;
	MOVLW	0F0h
	XORWF	PKYBD,W		; Se leen las columnas y si alguna tecla esta
				; presionada el resultado será distinto de 0
	BTFSC	STATUS,Z		;
	GOTO	LEETECRET	; Retorna, no hay teclas presionadas

	CLRF	TMP1		; Se inicializa registro de barrido BAR=1
	INCF	TMP1,F		; 

	MOVLW	selc1		; Se selecciona columna 1
	CALL	LEETEC1		;
	MOVLW	selc2		; Se selecciona columna 2
	CALL	LEETEC1		;
	MOVLW	selc3		; Se selecciona columna 3
	CALL	LEETEC1		;
	MOVLW	selc4		; Se selecciona columna 4
	CALL	LEETEC1		;
LEETECRET:
	MOVLW	selca		; Se dejan seleccionadas todas las columnas
	MOVWF	PKYBD		;
	MOVF	TMP2,W		; Se retorna código en W
	RETURN			;
LEETEC1:
	MOVWF	PKYBD		; Se pone seleccionador de fila en el puerto
	MOVF	TMP2,F		; Se verifica que no ha sido recibida tecla
	BTFSS	STATUS,Z		;
	RETURN			; Tecla recibida previamente
	BTFSS	PKYBD,4		; Se verifica fila 1
	GOTO	LEETEC2		;
	INCF	TMP1,F		;
	BTFSS	PKYBD,5		; Se verifica fila 2
	GOTO	LEETEC2		;
	INCF	TMP1,F		;
	BTFSS	PKYBD,6		; Se verifica fila 3 
	GOTO	LEETEC2		;
	INCF	TMP1,F		;
	BTFSS	PKYBD,7		; Se verifica fila 4
	GOTO	LEETEC2		;
	INCF	TMP1,F		;
	RETURN			; No se encuentra ninguna fila presionada

LEETEC2:
	MOVF	TMP1,W		; Se ha descubierto una fila presionada y
	MOVWF	TMP2		; se guarda su código
	RETURN			; Se retorna con el código de fila en TMP2



;************************************************************************************************************************************************************************
; ELIMREB
; Elimina rebote de teclado
; Recibe:  W: código leido de tecla, 0 no hay tecla
; Retorna: W: código de tecla ya estable, 0 no hay tecla

;	ORG	200
ELIMREB:
	MOVWF	TMP1		; Se almacena temporalmente la tecla recibida
	XORWF	TEC_ant,W	; Se verifica si es igual a la tecla anterior
	BTFSC	STATUS,Z		;
	GOTO	ELIM_IG		;
				; Caso de tecla distinta
	MOVF	TMP1,W		; Se actualiza tecla anterior
	MOVWF	TEC_ant		;
	CLRF	TEC_numv		; Se inicializa contador de número de veces
	RETLW	0		; Se indica 'no tecla'
ELIM_IG:				; Caso de tecla igual
	MOVLW	nminv		; Se verifica si es estable durante un 
	SUBWF	TEC_numv,W	; número mínimo de veces
	BTFSC	STATUS,Z		;
	GOTO	ELIM_EST		;
				; Caso aún no estable
	INCF	TEC_numv,F	;
	RETLW	0		;
ELIM_EST:			; Caso estable
	MOVF	TMP1,W		;
	RETURN			;
	
	
;************************************************************************************************************************************************************************
; REPORTT
; Reporta una vez una tecla cuando se presiona
; Recibe:  W: código leido y filtrado de tecla, 0 no hay tecla
; Retorna: W: código de tecla, 0 no hay tecla
;          STATUS: flag Zero debidamente ajustado

;	ORG	200
REPORTT:
	IORLW	0		; Se verifica si hay tecla
	BTFSC	STATUS,Z	;
	GOTO	RE_NTEC		;
RE_TEC:
	BSF	STATUS,Z	; Se activa flag Zero, para indicar "no hay tecla"  
	BTFSC	TEC_flg,F_rep	; Tecla presionada, se verifica si fue reportada
	RETLW	0		; (RETLW 0 no ajusta el flag de Zero)

	BSF	TEC_flg,F_rep	; Se reporta tecla, marcando tecla reportada
	BCF	STATUS,Z		; Se limpia el flag de Zero indicando "hay tecla"
	RETURN			; Se retorna código de tecla
RE_NTEC:
	BCF	TEC_flg,F_rep	; No hay tecla, se marca no reportado
	ANDLW	0		; Se retorna 0: tecla ya reportada (ajusta flag Z)
	RETURN			;


;************************************************************************************************************************************************************************

; RUTINAS DE PANTALLA

;************************************************************************************************************************************************************************
; LCDDWR
; LCD Data write
; Recibe: W=Dato a escribir

;	ORG	200
LCDDWR:
	BSF	P_LCDdi,b_LCDdi	; Dato/instrucción = Dato
	GOTO	LCDWRAUX	;

;************************************************************************************************************************************************************************
; LCDIWR
; LCD Instruction write
; Recibe: W=Dato a escribir

;	ORG	200
LCDIWR:
	BCF	P_LCDdi,b_LCDdi	; Dato/instrucción = instrucción
	GOTO	LCDWRAUX	;

LCDWRAUX:
	BCF	P_LCDrw,b_LCDrw	; Read/Write = Write
	MOVWF	TMP1		; Se guarda dato para posterior uso

	MOVLW	0F0h		; Se borran bits lsb del puerto
	ANDWF	P_LCDDA,F	;
	SWAPF	TMP1,W		; Se escribe el nible superior
	ANDLW	00Fh		;
	IORWF	P_LCDDA,F	;
	BSF	P_LCDen,b_LCDen	;  activa el strobe
	BCF	P_LCDen,b_LCDen	;  desactiva el strobe

	MOVLW	0F0h		; Se borran bits lsb del puerto
	ANDWF	P_LCDDA,F	;
	MOVF	TMP1,W		; Se escribe nible inferior	
	ANDLW	00Fh		;
	IORWF	P_LCDDA,F	;
	BSF	P_LCDen,b_LCDen	;  activa el strobe
	BCF	P_LCDen,b_LCDen	;  desactiva el strobe

	CALL	LCDBSY		;
	
	RETURN

;************************************************************************************************************************************************************************
; CURADD
; Lee dirección del cursor
; Retorna: W=dirección del cursor (0-79d)

;	ORG	200
CURADD:
	CALL	LCDDIN		; Se reconfigura puerto de datos LCD como entrada

	BCF	P_LCDdi,b_LCDdi	; Dato/instrucción = Instruccion
	BSF	P_LCDrw,b_LCDrw	; Read/Write = Write

	BSF	P_LCDen,b_LCDen	;  activar strobe / desactivar strobe
	BCF	P_LCDen,b_LCDen	;
	MOVF	P_LCDDA,W	; Se lee nibble MSN
	ANDLW	07h		;
	MOVWF	TMP1		;
	SWAPF	TMP1,F		;
	BSF	P_LCDen,b_LCDen	;  activar strobe / desactivar strobe
	BCF	P_LCDen,b_LCDen	;
	MOVF	P_LCDDA,W	; Se lee nibble LSN
	ANDLW	0Fh		;
	IORWF	TMP1,W		;
	CALL	LCDDOUT		;
	RETURN		

;************************************************************************************************************************************************************************
; LCDWAIT
; Recibe:  W=Número de milisegundos a esperar

;	ORG	200
LCDWAIT:
	MOVWF	TMP1		; Se almacena el número de milisegundos en CONT1
LCDW1:	MOVLW	klcdw		; Se almacena contador básico
	MOVWF	TMP2		;
LCDW2:	NOP			; Ajustando al milisegundo
	NOP			;
	DECFSZ	TMP2,F		; Se decrementa contador básico
	GOTO	LCDW2		; hasta llegar a cero
	DECFSZ	TMP1,F		; Se repite el contador básico tantas
	GOTO	LCDW1		; veces como número de milisegundos
	RETURN			;

;****************************************************************************************************************************************************************************
; LCDBSY
; LCD Busy: espera desocupación de LCD (con time-out)
; Retorna: W=0 desocupado / W=1 error time-out superado

;	ORG	200
LCDBSY:
	MOVLW	lcd_to		; Se prepara contador de time-out
	MOVWF	TMP1		;
	CALL	LCDDIN		; Se pone el bus como entrada
	BCF	P_LCDdi,b_LCDdi	; Dato/instrucción = Instruccion
	BSF	P_LCDrw,b_LCDrw	; Read/Write = Read

LCDBS1:
	BSF	P_LCDen,b_LCDen	;  activar strobe / desactivar strobe
	BCF	P_LCDen,b_LCDen	;
	MOVF	P_LCDDA,W	; Se lee nibble MSN con busy flag BF
	BSF	P_LCDen,b_LCDen	;  activar strobe / desactivar strobe
	BCF	P_LCDen,b_LCDen	;
	ANDLW	08h		;
	BTFSC	STATUS,Z	; Si BF=0 el LCD esta desocupado
	GOTO	LCDBS2		;

	DECFSZ	TMP1,F		; Se verifica si hay time out
	GOTO	LCDBS1		;
	
	CLRF	TMP1		; Hay time-out
	CALL	LCDDOUT		;
	RETLW	01		; Retorna error por time-out

LCDBS2:				; Desocupado
	CALL	LCDDOUT		;
	RETLW	00		; Retorna desocupado sin errores

;************************************************************************************************************************************************************************
; LCDIN
; Rutina de uso particular. Pone el bus de datos LCD como entrada

;	ORG	200
LCDDIN:				; 
	BSF	STATUS, RP0	; Se reconfigura puerto de datos LCD
	MOVLW   00Fh		; como entrada
	IORWF	P_LCDDA,W	;
	MOVWF	P_LCDDA		;
	BCF	STATUS, RP0	;
	RETURN			;

;************************************************************************************************************************************************************************
; LCDOUT
; Rutina de uso particular. Pone el bus de datos LCD como salida

;	ORG	200
LCDDOUT:				;
	BSF	STATUS, RP0	; Se reconfigura puerto de datos LCD
	MOVLW   0F0h		; como salida
	ANDWF	P_LCDDA,W	;
	MOVWF	P_LCDDA		;
	BCF	STATUS, RP0	;
	MOVF	TMP1,W		;
	RETURN	

				
;************************************************************************************************************************************************************************

; INICIALIZACIONES

;************************************************************************************************************************************************************************
;************************************************************************************************************************************************************************
; INITTMR2
; Inicialización del timer 2 

INITTMR2:			; Inicialización timer 2
				; Se escribe constante de configuración
	MOVLW	((prescal2/4)&3) | (prescal2/8) | (postscal-1)*8 | 4
	MOVWF	T2CON		;

	BSF	STATUS,RP0	; Banco 1
	MOVLW	rperiod-1	; Se escribe valor de comparación de timer 2
	MOVWF	PR2&7F		;
	BSF	PIE1&7F,TMR2IE	; Se habilita interrupción por timer 2
	BSF	INTCON,PEIE	;
	BCF	STATUS,RP0	; Banco 0

	BCF	PIR1,TMR2IF	; Se borra posible flag de interrupción
	BSF	T2CON,TMR2ON	; Se enciende el temporizador
	RETURN			;

;********************************************************************************************************************************************************************
; INITRELOJ
; Inicializa el reloj a 00:00:00

INITRELOJ
	CLRF	HORDEC		; Ponemos a cero todas las variables
	CLRF	HORUNI
	CLRF	MINDEC
	CLRF	MINUNI
	CLRF	SEGDEC
	CLRF	SEGUNI
	RETURN

;********************************************************************************************************************************************************************
; INITESTADO
; Inicializa el estado a 0 (ESTADO de dar la hora)

INITESTADO:
	CLRF	estado
	RETURN	

;********************************************************************************************************************************************************************
; INITPORTS (PIC16F88X)
; Inicializa puertos en procesadores de la serie 88X


INITPORTS:
	BSF	STATUS,RP0 	; Cambio de banco
	BSF 	STATUS,RP1 	;
	CLRF	ANSEL&7F 	; Puerto A digital para PIC16F88x
	CLRF 	ANSELH&7F 	; Puerto B digital para PIC16F88x
	BCF 	STATUS,RP0 	; Cambio de banco
	BCF 	STATUS,RP1 	;
	RETURN			;

;********************************************************************************************************************************************************************
; INITTEC
; Inicializa puerto de teclado

INITTEC:
	BSF	STATUS,RP0		; Banco 1
	MOVLW	B'11110000'		; Configuración de puerto B:
	MOVWF	PKYBD			;  RB7-RB4 entrada, RB3-RB0 salida
	BCF	OPTION_REG&7F,NOT_RBPU	;  Pull ups activados
	BCF	STATUS,RP0		; Banco 0
	MOVLW	selca			; Selecciona todas columnas
	MOVWF	PKYBD			;
	CLRF	TEC_ant			; Se inicializan variables
	CLRF	TEC_flg			;
	CLRF	TEC_numv			;
	RETURN	

;********************************************************************************************************************************************************************
; INITLCD
; Inicializa pantalla y puerto de pantalla

INITLCD:
	BSF	STATUS, RP0	; Se reconfigura puerto de datos LCD
	MOVLW	0F0h		; 4 bits de datos = Salida
	ANDWF	P_LCDDA,F	;
	BCF	P_LCDdi,b_LCDdi	; Dato/instrucción = Salida
	BCF	P_LCDrw,b_LCDrw	; Read/Write = Salida
	BCF	P_LCDen,b_LCDen	; Strobe = Salida
	BCF	STATUS, RP0	;
	BCF	P_LCDdi,b_LCDdi	; Dato/instrucción = Instrucción
	BCF	P_LCDrw,b_LCDrw	; Read/Write = Write
	BCF	P_LCDen,b_LCDen	; desactiva el strobe
	MOVLW	0F0h		; Se prepara primer dato de inicialización
	ANDWF	P_LCDDA,F	; (que hay que enviar 3 veces)
	MOVLW	B'0011'		; 
	IORWF	P_LCDDA,F	;

	MOVLW	D'20'		; Se esperan 20ms
	CALL	LCDWAIT		;
	BSF	P_LCDen,b_LCDen	; Primer envio
	BCF	P_LCDen,b_LCDen	;  activar strobe / desactivar strobe

	MOVLW	D'5'		; Se esperan 5ms
	CALL	LCDWAIT		;
	BSF	P_LCDen,b_LCDen	; Segundo envio
	BCF	P_LCDen,b_LCDen	;  activar strobe / desactivar strobe

	MOVLW	D'1'		; Se espera 1ms
	CALL	LCDWAIT		;
	BSF	P_LCDen,b_LCDen	; Tercer envio
	BCF	P_LCDen,b_LCDen	;  activar strobe / desactivar strobe

	MOVLW	D'5'		; Se esperan 5ms
	CALL	LCDWAIT		;
	MOVLW	0F0h		; Se prepara segundo dato de inicialización	ANDWF	P_LCDDA,F	;
	ANDWF	P_LCDDA,F	;	
	MOVLW	B'0010'		;
	IORWF	P_LCDDA,F	;
	BSF	P_LCDen,b_LCDen	; Envio
	BCF	P_LCDen,b_LCDen	;  activar strobe / desactivar strobe

	MOVLW	D'5'		; Se esperan 5ms
	CALL	LCDWAIT		;
	MOVLW	lcd_set		; Se envia instrucción para fijar tipo de pantalla
	CALL	LCDIWR		;

	MOVLW	D'5'		; Se esperan 5ms
	CALL	LCDWAIT		;
	MOVLW	lcd_off		; Se envia instrucción para apagar pantalla
	CALL	LCDIWR		;
	MOVLW	lcd_on		; Se envia instrucción para encender pantalla
	CALL	LCDIWR		;
	MOVLW	lcd_mod		; Se envia instrucción para modo de operación
	CALL	LCDIWR		;
	MOVLW	lcd_clr		; Se envia instrucción para limpiar pantalla
	CALL	LCDIWR		;

	MOVLW	D'100'		; Se esperan 100 ms
	CALL	LCDWAIT		;

	RETURN

;********************************************************************************************************************************************************************
; SERVO_INIT:
; Inicializa puerto del servo

SERVO_INIT:
	BSF	STATUS, RP0		; Cambio a página de configuración de puertos
	BCF	P_SERVO,b_SERVO		; se programa como salida
	BCF	STATUS, RP0		; Vuelta a página principal 0
	BCF	P_SERVO,b_SERVO		; se pone servo a cero
	CLRF	servo_val		; Valor inicial de servo a 0 (Izq)
	CLRF	servo_cnt		;
	RETURN

;********************************************************************************************************************************************************************
; SOUND_INIT:
; Inicializa puerto del sonido

SOUND_INIT:
	BSF	STATUS, RP0		; Cambio a página de configuración de puertos
	BCF	P_SOUND,b_SOUND		; se programa como salida
	BCF	STATUS, RP0		; Vuelta a página principal 0
	BCF	P_SOUND,b_SOUND		; Se apaga de salida de sonido a 0
	CLRF	sound_val		; Valor inicial de sonido a 0
	CLRF	sound_cnt0		;
	CLRF	sound_cnt1		;
	RETURN

;********************************************************************************************************************************************************************
;********************************************************************************************************************************************************************
;********************************************************************************************************************************************************************
	;ELEMENTOS ADICIONALES PARA SERVO
;********************************************************************************************************************************************************************
	



;**********************************************************************************
; SERVO()
; Posiciona el servo
; Recibe: W: valor de posición del servo (0-19) 0=>0º  19=>190º

SERVO:
 	MOVWF	servo_val	; Se transfiere valor a la variable correspondiente
	RETURN			;



;********************************************************************************************************************************************************************
	;FIN DEL PROGRAMA
;********************************************************************************************************************************************************************

	END
