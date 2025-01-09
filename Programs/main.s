		AREA    |.text|, CODE, READONLY

;	Import des controles de périphérique
;	Controle moteur
		IMPORT	MOTEUR_INIT					; initialise les moteurs (configure les pwms + GPIO)
		IMPORT	MOTEUR_DROIT_ON				; activer le moteur droit
		IMPORT  MOTEUR_DROIT_OFF			; déactiver le moteur droit
		IMPORT  MOTEUR_DROIT_AVANT			; moteur droit tourne vers l'avant
		IMPORT  MOTEUR_DROIT_ARRIERE		; moteur droit tourne vers l'arrière
		IMPORT	MOTEUR_GAUCHE_ON			; activer le moteur gauche
		IMPORT  MOTEUR_GAUCHE_OFF			; déactiver le moteur gauche
		IMPORT  MOTEUR_GAUCHE_AVANT			; moteur gauche tourne vers l'avant
		IMPORT  MOTEUR_GAUCHE_ARRIERE		; moteur gauche tourne vers l'arrière

;	Controle led
		IMPORT	LED_INIT
		IMPORT	LED_DROITE_ON
		IMPORT	LED_DROITE_OFF
		IMPORT	LED_GAUCHE_ON
		IMPORT	LED_GAUCHE_OFF

;	État switchs
		IMPORT	SWITCH_INIT
		IMPORT	SWITCH_1
		IMPORT	SWITCH_2
			
;	États bumper
		IMPORT	BUMPER_INIT
		IMPORT	BUMPER_DROIT
		IMPORT	BUMPER_GAUCHE

;	Initialisation des variables et constante
mode	EQU		0

	  	ENTRY
		EXPORT	__main
__main	
		
		BL	MOTEUR_INIT
		BL	LED_INIT
		BL	SWITCH_INIT
		BL	BUMPER_INIT

loop	
		BL	BUMPER_DROIT
		CMP	r0, #0
		BEQ mode_one
		
		BL	BUMPER_GAUCHE
		CMP	r0, #0
		BEQ mode_one
		
		BL	LED_DROITE_OFF
		BL	LED_GAUCHE_ON
		B	loop
		
mode_one
		BL	LED_GAUCHE_OFF
		BL	LED_DROITE_ON
		
		B	loop
		
		nop		
		END    