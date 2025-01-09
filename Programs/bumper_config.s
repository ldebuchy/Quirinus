; Définition des constantes
SYSCTL_PERIPH_GPIO EQU		0x400FE108	; Adresse du registre des ports ABCDEF

GPIO_PORTE_BASE		EQU		0x40024000	; GPIO Port E (APB) base: 0x4002.5000 (p416 datasheet de lm3s9B92.pdf)

GPIO_O_DEN  		EQU 	0x0000051C  ; GPIO Digital Enable (p437 datasheet de lm3s9B92.pdf)

; Pul_up
GPIO_I_PUR   		EQU 	0x00000510  ; GPIO Pull-Up (p432 datasheet de lm3s9B92.pdf)

BROCHE0				EQU 	0x01		; bumper 1 sur broche 0
BROCHE1				EQU		0x02		; bumper 2 sur broche 1


		AREA    |.text|, CODE, READONLY
		ENTRY
		
		EXPORT 	BUMPER_INIT
		EXPORT	BUMPER_DROIT
		EXPORT	BUMPER_GAUCHE

BUMPER_INIT
; Alimentation du port E
	ldr R6, = SYSCTL_PERIPH_GPIO  			;; RCGC2
	ldr	R0, [R6] 		
	ORR	R0, R0, #0x10  ; Active le port E dans le registre
	str R0, [R6]
	
	nop ; Attend les 3 ticks avant de pouvoir utiliser le port
	nop	   
	nop

;	Activation des fonctions numérique
	ldr R6, = GPIO_PORTE_BASE+GPIO_O_DEN
	ldr	R0, [R6] 		
	ORR	R0, R0, #BROCHE0
	str R0, [R6]
	
	ldr R6, = GPIO_PORTE_BASE+GPIO_O_DEN
	ldr	R0, [R6] 		
	ORR	R0, R0, #BROCHE1
	str R0, [R6]
	
;	Pul_up 
	ldr R6, = GPIO_PORTE_BASE+GPIO_I_PUR 			
	ldr	R0, [R6] 		
	ORR	R0, R0, #BROCHE0
	str R0, [R6]
	
	ldr R6, = GPIO_PORTE_BASE+GPIO_I_PUR 			
	ldr	R0, [R6] 		
	ORR	R0, R0, #BROCHE1
	str R0, [R6]
	
	BX LR
	
BUMPER_DROIT
	ldr r0, = GPIO_PORTE_BASE + (BROCHE0<<2)
	ldr r0, [r0]
	BX	LR
	
BUMPER_GAUCHE
	ldr r0, = GPIO_PORTE_BASE + (BROCHE1<<2)
	ldr r0, [r0]
	BX	LR
	
	END