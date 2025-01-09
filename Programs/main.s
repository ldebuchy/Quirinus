		AREA    |.text|, CODE, READONLY

;	Import des controles de p�riph�rique
;	Controle moteur
		IMPORT	MOTEUR_INIT					; initialise les moteurs (configure les pwms + GPIO)
		IMPORT	MOTEUR_DROIT_ON				; activer le moteur droit
		IMPORT  MOTEUR_DROIT_OFF			; d�activer le moteur droit
		IMPORT  MOTEUR_DROIT_AVANT			; moteur droit tourne vers l'avant
		IMPORT  MOTEUR_DROIT_ARRIERE		; moteur droit tourne vers l'arri�re
		IMPORT	MOTEUR_GAUCHE_ON			; activer le moteur gauche
		IMPORT  MOTEUR_GAUCHE_OFF			; d�activer le moteur gauche
		IMPORT  MOTEUR_GAUCHE_AVANT			; moteur gauche tourne vers l'avant
		IMPORT  MOTEUR_GAUCHE_ARRIERE		; moteur gauche tourne vers l'arri�re

;	Controle led
		IMPORT	LED_INIT
		IMPORT	LED_DROITE_ON
		IMPORT	LED_DROITE_OFF
		IMPORT	LED_GAUCHE_ON
		IMPORT	LED_GAUCHE_OFF

;	Controle Switch

	  	ENTRY
		EXPORT	__main
__main	
		
		BL	MOTEUR_INIT
		BL	LED_INIT

;loop	

		BL	LED_DROITE_ON
		BL	LED_GAUCHE_OFF
		
		BL	LED_GAUCHE_ON
		BL	LED_DROITE_OFF
		
		;b	loop

		nop		
		END    