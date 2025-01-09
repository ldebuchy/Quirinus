; Définition des constantes
SYSCTL_PERIPH_GPIO EQU		0x400FE108	; Adresse du registre des ports ABCDEF

GPIO_PORTD_BASE		EQU		0x40007000		; GPIO Port D (APB) base: 0x4000.7000 (p416 datasheet de lm3s9B92.pdf)

GPIO_O_DEN  		EQU 	0x0000051C  ; GPIO Digital Enable (p437 datasheet de lm3s9B92.pdf)

; Pul_up
GPIO_I_PUR   		EQU 	0x00000510  ; GPIO Pull-Up (p432 datasheet de lm3s9B92.pdf)

BROCHE6				EQU 	0x40		; bouton poussoir 1

		AREA    |.text|, CODE, READONLY
		ENTRY
		
		EXPORT 	SWITCH_INIT
		EXPORT	SWITCH_1

SWITCH_INIT
; Alimentation du port D
	ldr R6, = SYSCTL_PERIPH_GPIO  			;; RCGC2
	ldr	R0, [R6] 		
	ORR	R0, R0, #0x08  ; Active le port D dans le registre
	str R0, [R6]
	
	nop ; Attend les 3 ticks avant de pouvoir utiliser le port
	nop	   
	nop

;	Activation des fonctions numérique
	ldr R6, = GPIO_PORTD_BASE+GPIO_O_DEN
	ldr	R0, [R6] 		
	ORR	R0, R0, #BROCHE6
	str R0, [R6]

	ldr R6, = GPIO_PORTD_BASE+GPIO_I_PUR 			;; Pul_up 
	ldr	R0, [R6] 		
	ORR	R0, R0, #BROCHE6
	str R0, [R6]
	
	BX LR
	
SWITCH_1
	ldr r0, = GPIO_PORTD_BASE + (BROCHE6<<2)			;; Pul_up 
	ldr r0, [r0]
	BX	LR
	
	END