SYSCTL_PERIPH_GPIO EQU		0x400FE108	; Adresse du registre des ports ABCDEF

GPIO_PORTF_BASE		EQU		0x40025000	; GPIO Port F (APB) base: 0x4002.5000 (p416 datasheet de lm3s9B92.pdf)

; configure the corresponding pin to be an output
; all GPIO pins are inputs by default
GPIO_O_DIR   		EQU 	0x00000400  ; GPIO Direction (p417 datasheet de lm3s9B92.pdf)

; The GPIODR2R register is the 2-mA drive control register
; By default, all GPIO pins have 2-mA drive.
GPIO_O_DR2R   		EQU 	0x00000500  ; GPIO 2-mA Drive Select (p428 datasheet de lm3s9B92.pdf)

; Digital enable register
; To use the pin as a digital input or output, the corresponding GPIODEN bit must be set.
GPIO_O_DEN  		EQU 	0x0000051C  ; GPIO Digital Enable (p437 datasheet de lm3s9B92.pdf)

BROCHE4		EQU	0x10	; led1 sur broche 4
BROCHE5		EQU	0x20	; led2 sur broche 5


		AREA    |.text|, CODE, READONLY
		ENTRY
			
		;; The EXPORT command specifies that a symbol can be accessed by other shared objects or executables.
		EXPORT	LED_INIT
		EXPORT	LED_DROITE_ON
		EXPORT	LED_DROITE_OFF
		EXPORT	LED_GAUCHE_ON
		EXPORT	LED_GAUCHE_OFF

LED_INIT			
;	Alimentation du port F
		ldr r6, = SYSCTL_PERIPH_GPIO	; RCGC2
		ldr	r0, [R6] 		
		ORR	r0, r0, #0x20	; Active au port F dans le registre
		str r0, [r6]
		
		nop ; Attend les 3 ticks avant de pouvoir utiliser le port
		nop	   
		nop

;	Configuration des broches sur sortie
		ldr r6, = GPIO_PORTF_BASE+GPIO_O_DIR	; 1 Pin du portF en sortie (broche 4 : 00010000)
		ldr r0, [r6]
		ORR r0, r0, #BROCHE4
		str	r0, [r6]
		
		ldr r6, = GPIO_PORTF_BASE+GPIO_O_DIR	; 1 Pin du portF en sortie (broche 5 : 00100000)
		ldr r0, [r6]
		ORR r0, r0, #BROCHE5
		str	r0, [r6]
	
;	Activation des fonctions numérique
		ldr r6, = GPIO_PORTF_BASE+GPIO_O_DEN
		ldr r0, [r6]
		ORR r0, r0, #BROCHE4
		str	r0, [r6]
		
		ldr r6, = GPIO_PORTF_BASE+GPIO_O_DEN
		ldr r0, [r6]
		ORR r0, r0, #BROCHE5
		str	r0, [r6]
	
;	Choix de l'intensité de sortie (2mA)
		ldr r6, = GPIO_PORTF_BASE+GPIO_O_DR2R
		ldr r0, [r6]
		ORR r0, r0, #BROCHE4
		str	r0, [r6]
		
		ldr r6, = GPIO_PORTF_BASE+GPIO_O_DR2R
		ldr r0, [r6]
		ORR r0, r0, #BROCHE5
		str	r0, [r6]
		
		BX LR

LED_DROITE_ON
		ldr r6, = GPIO_PORTF_BASE + (BROCHE4<<2)	; @data Register = @base + (mask<<2)
		ldr r0, [r6]
		ORR r0, r0, #BROCHE4
		str	r0, [r6]
		BX LR
	
LED_DROITE_OFF
		ldr r6, = GPIO_PORTF_BASE + (BROCHE4<<2)  ; @data Register = @base + (mask<<2)
		ldr r0, [r6]
		bic r0, r0, #BROCHE4
		str r0, [r6]
		BX LR
	
LED_GAUCHE_ON
		ldr r6, = GPIO_PORTF_BASE + (BROCHE5<<2)	; @data Register = @base + (mask<<2)
		ldr r0, [r6]
		ORR r0, r0, #BROCHE5
		STR	r0, [r6]
		BX LR
	
LED_GAUCHE_OFF
		ldr r6, = GPIO_PORTF_BASE + (BROCHE5<<2)  ; @data Register = @base + (mask<<2)
		ldr r0, [r6]
		bic r0, r0, #BROCHE5
		str r0, [r6]
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        		BX LR
		
		END