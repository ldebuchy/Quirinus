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
LONG_ADR			EQU	0x20000001
ROT_TIME_45			EQU	0x17C000
ROT_TIME_90			EQU	0x2F8000
ROT_TIME_180		EQU	0x5F0000
ROT_TIME_360		EQU	0xBC0000

DWT_CYCCNT			EQU	0xE0001004
	  	ENTRY
		EXPORT	__main
__main	
		
		BL	MOTEUR_INIT
		BL	LED_INIT
		BL	SWITCH_INIT
		BL	BUMPER_INIT
		
	;	Initalisation du compteur de cycle de l'horloge
	LDR R0, =0xE000EDFC        ; Adresse du registre DEMCR (Debug Exception and Monitor Control)
    LDR R1, [R0]               ; Charger sa valeur actuelle
    ORR R1, R1, #(1 << 24)     ; Activer TRCENA (bit 24)
    STR R1, [R0]               ; Écrire la nouvelle valeur dans DEMCR

    LDR R0, =0xE0001000        ; Adresse de DWT_CYCCNT
    LDR R1, [R0]               ; Charger sa valeur actuelle
    ORR R1, R1, #1             ; Activer le compteur de cycles (bit 0)
    STR R1, [R0]               ; Écrire la nouvelle valeur

mode_passif_loop	; boucle principale ne fait rien tant qu'aucun bouton est pressé
		BL	LED_DROITE_OFF
		BL	LED_GAUCHE_OFF
		BL	MOTEUR_GAUCHE_OFF
		BL	MOTEUR_DROIT_OFF

		BL SWITCH_1
		CMP r0, #0x0
		BLEQ	mode_reperage_phase_1
		
		BL SWITCH_2
		CMP r0, #0x0
		BLEQ	mode_surveillance
		
		BL	mode_passif_loop
	
mode_reperage_phase_1 ; mode repérage
		BL	LED_GAUCHE_ON
		BL	LED_DROITE_ON
		
		;	Attend que l'utilisateur est éloigné son doigt
		BL	wait_switch_1_free
		
		ldr r1, =0x100000
		BL	wait
		
		ldr r2, =0x1	;	Définition du nombre de cligottement
		BL	Clignottement
		
		BL	animation_1

		ldr r2, =0x2	;	Définition du nombre de cligottement
		BL	Clignottement
		
		BL	MOTEUR_DROIT_ON
		BL	MOTEUR_GAUCHE_ON
        BL	MOTEUR_DROIT_AVANT
		BL	MOTEUR_GAUCHE_ARRIERE                                        
		ldr r1, =ROT_TIME_90
		BL	wait
		
		
		BL	MOTEUR_DROIT_AVANT
		BL	MOTEUR_GAUCHE_AVANT
mode_reperage_phase_1_loop	; avance jusqu'a ce qu'un bumper soit touché
		BL	BUMPER_DROIT
		CMP	r0,	#0x0
		BEQ	mode_reperage_phase_2	;	Si rien est touché, continue sa détection
		
		BL	BUMPER_GAUCHE
		CMP	r0,	#0x0
		BEQ	mode_reperage_phase_2	;	Si rien est touché, continue sa détection
		
		B	mode_reperage_phase_1_loop
		
		; recule et demi toure
mode_reperage_phase_2

		BL	MOTEUR_DROIT_ARRIERE
		BL	MOTEUR_GAUCHE_ARRIERE
		
		ldr r1, =0x4A0000
		BL	wait
		
		BL	MOTEUR_DROIT_OFF
		BL	MOTEUR_GAUCHE_OFF

		; Lire le compteur avant l'opération
		LDR R7, =DWT_CYCCNT        ; Adresse du registre DWT_CYCCNT
		LDR R8, [R7]               ; Charger la valeur initiale dans R8 (start)
		
		ldr r2, =0x1	;	Définition du nombre de cligottement
		BL	Clignottement
		
		BL	MOTEUR_DROIT_ON
		BL	MOTEUR_GAUCHE_ON
		BL	MOTEUR_DROIT_ARRIERE
		BL	MOTEUR_GAUCHE_AVANT
		
		ldr r1, =ROT_TIME_180
		BL	wait
		
		BL	MOTEUR_DROIT_AVANT
		BL	MOTEUR_GAUCHE_AVANT
		
mode_reperage_phase_2_loop	; avance jusqu'a ce qu'un bumper soit touché

		BL	BUMPER_DROIT
		CMP	r0,	#0x0
		BEQ	mode_reperage_phase_3	;	Si rien est touché, continue sa détection
		
		BL	BUMPER_GAUCHE
		CMP	r0,	#0x0
		BEQ	mode_reperage_phase_3	;	Si rien est touché, continue sa détection
		
		B	mode_reperage_phase_2_loop
				
mode_reperage_phase_3

		BL	MOTEUR_DROIT_ARRIERE
		BL	MOTEUR_GAUCHE_ARRIERE
		
		ldr r1, = 0x4A0000
		BL	wait
		
		BL	MOTEUR_DROIT_OFF
		BL	MOTEUR_GAUCHE_OFF
		
		; Lire le compteur après l'opération
		LDR R9, [R7]               ; Charger la valeur finale dans R9 (end)

		; Calculer le nombre de cycles écoulés
		SUB R3, R9, R8             ; R3 = end - start
	
		LSR	r3,	r3,	#2
		
		ldr r0,	=LONG_ADR	;	Enregistrement de la longeur
		str	r3,	[r0]
		
		ldr r2, =0x1	;	Définition du nombre de cligottement
		BL	Clignottement
		
		BL	MOTEUR_DROIT_ON
		BL	MOTEUR_GAUCHE_ON
		BL	MOTEUR_DROIT_AVANT
		BL	MOTEUR_GAUCHE_ARRIERE
		
		ldr r1, = ROT_TIME_180
		BL	wait
		
		BL	MOTEUR_DROIT_AVANT
		BL	MOTEUR_GAUCHE_AVANT
		
		ldr	r0,	=LONG_ADR
		ldr	r3,	[r0]
		LSR	r3,	r3,	#1	;	on divise la longeur enregistré pour revenir au millieux lors de la 3ème phase
mode_reperage_phase_3_loop	; avance jusqu'a ce qu'un bumper soit touché
		subs	r3,	r3, #1
		bne	mode_reperage_phase_3_loop
		
		BL	MOTEUR_DROIT_ARRIERE
		BL	MOTEUR_GAUCHE_AVANT
		
		ldr r1, = ROT_TIME_90
		BL	wait
		
		BL	MOTEUR_GAUCHE_OFF
		BL	MOTEUR_DROIT_OFF
		
		BL	LED_DROITE_ON
		BL	LED_GAUCHE_ON
		ldr r1, =0x100000      
		BL	wait
		BL	LED_DROITE_OFF
		BL	LED_GAUCHE_OFF
		
		ldr r2, =0x2	;	Définition du nombre de cligottement
		BL	Clignottement
		B	mode_passif_loop
		
mode_surveillance
		BL	LED_GAUCHE_ON
		BL	LED_DROITE_ON
		BL	wait_switch_2_free	;	Attend que l'utilisateur est éloigné son doigt
		ldr r1, =0x100000
		BL	wait
		ldr r2, =0x3	;	Définition du nombre de cligottement
		BL	Clignottement
		
		ldr	r0,	=LONG_ADR
		ldr	r3, [r0]
		sub	r3,	#0xB00000
		
		BL	MOTEUR_DROIT_ON
		BL	MOTEUR_GAUCHE_ON
        BL	MOTEUR_DROIT_AVANT
		BL	MOTEUR_GAUCHE_ARRIERE                                        
		ldr r1, =ROT_TIME_90
		BL	wait
		
		BL	MOTEUR_DROIT_AVANT
		BL	MOTEUR_GAUCHE_AVANT
		
		LSR	r4,	r3,	#4
mode_surveillance_loop_1
		BL	BUMPER_DROIT
		CMP	r0,	#0x0
		BEQ	interruption_surveillance
		
		BL	BUMPER_GAUCHE
		CMP	r0,	#0x0
		BEQ	interruption_surveillance

		subs	r4,	#1
		BNE	mode_surveillance_loop_1
		
		BL	MOTEUR_DROIT_ARRIERE
		BL	MOTEUR_GAUCHE_AVANT
		ldr r1, =ROT_TIME_180
		BL	wait
		BL	MOTEUR_DROIT_AVANT
		BL	MOTEUR_GAUCHE_AVANT
		
		LSR	r4,	r3,	#3
		BL	mode_surveillance_loop_2

mode_surveillance_loop_2
		BL	BUMPER_DROIT
		CMP	r0,	#0x0
		BEQ	interruption_surveillance
		
		BL	BUMPER_GAUCHE
		CMP	r0,	#0x0
		BEQ	interruption_surveillance

		subs	r4,	#1
		BNE	mode_surveillance_loop_2
		
		BL	MOTEUR_DROIT_ARRIERE
		BL	MOTEUR_GAUCHE_AVANT
		ldr r1, =ROT_TIME_180
		BL	wait
		BL	MOTEUR_DROIT_AVANT
		BL	MOTEUR_GAUCHE_AVANT
		
		LSR	r4,	r3,	#3
		BL	mode_surveillance_loop_1	
		
wait	subs r1, #1
		bne wait
		BX	LR
		
wait_switch_1_free	PUSH	{LR}
wait_switch_1_free2
		BL SWITCH_1
		CMP r0, #0x0
		BEQ	wait_switch_1_free2
		POP		{PC}
		
wait_switch_2_free	PUSH	{LR}
wait_switch_2_free2
		BL SWITCH_2
		CMP r0, #0x0
		BEQ	wait_switch_2_free2
		POP		{PC}
		
Clignottement
		PUSH	{LR}
		BL	LED_GAUCHE_ON
		BL	LED_DROITE_ON
		
		ldr r1, =0x0A0000
		BL	wait		
		
		BL	LED_GAUCHE_OFF
		BL	LED_DROITE_OFF
		
		ldr r1, =0x0A0000
		BL	wait	
		
		subs r2, #1
		BLNE	Clignottement
		POP		{PC}
		
		
interruption_reperage
		BL	MOTEUR_DROIT_ARRIERE
		BL	MOTEUR_GAUCHE_ARRIERE
		
		ldr r1, =0x100000
		BL	wait
		
		BL	MOTEUR_GAUCHE_OFF
		BL	MOTEUR_DROIT_OFF
		
		ldr r2, =0x10	;	Définition du nombre de cligottement
		BL	Clignottement
		B	mode_passif_loop

interruption_surveillance
		BL	MOTEUR_DROIT_ARRIERE
		BL	MOTEUR_GAUCHE_ARRIERE
		
		ldr r1, =0x0A0000
		BL	wait
		
		BL	MOTEUR_DROIT_AVANT
		BL	MOTEUR_GAUCHE_AVANT
		
		ldr r1, =0x0A0000
		BL	wait

		BL	MOTEUR_DROIT_ARRIERE
		BL	MOTEUR_GAUCHE_ARRIERE
		
		ldr r1, =0x0A0000
		BL	wait
		
		BL	MOTEUR_DROIT_AVANT
		BL	MOTEUR_GAUCHE_AVANT
		
		ldr r1, =0x0A0000
		BL	wait
		
				BL	MOTEUR_DROIT_ARRIERE
		BL	MOTEUR_GAUCHE_ARRIERE
		
		ldr r1, =0x0A0000
		BL	wait
		
		BL	MOTEUR_DROIT_AVANT
		BL	MOTEUR_GAUCHE_AVANT
		
		B	mode_passif_loop

animation_1
		PUSH	{LR}
		BL	MOTEUR_DROIT_ON
		BL	MOTEUR_GAUCHE_ON
		BL	MOTEUR_DROIT_AVANT
		BL	MOTEUR_GAUCHE_ARRIERE
		
		ldr r1, =ROT_TIME_45
		BL	wait
		
		BL	MOTEUR_DROIT_OFF
		BL	MOTEUR_GAUCHE_OFF
		
		ldr r1, =	0x200000
		BL	wait
		
		BL	MOTEUR_DROIT_ON
		BL	MOTEUR_GAUCHE_ON
		BL	MOTEUR_DROIT_ARRIERE
		BL	MOTEUR_GAUCHE_AVANT
		
		ldr r1, =ROT_TIME_90
		BL	wait
		
		BL	MOTEUR_DROIT_OFF
		BL	MOTEUR_GAUCHE_OFF
		
		ldr r1, =	0x200000
		BL	wait
		
		BL	MOTEUR_DROIT_ON
		BL	MOTEUR_GAUCHE_ON
		BL	MOTEUR_DROIT_AVANT
		BL	MOTEUR_GAUCHE_ARRIERE
		
		ldr r1, =ROT_TIME_45
		BL	wait
		
		BL	MOTEUR_DROIT_OFF
		BL	MOTEUR_GAUCHE_OFF
		ldr r1, =	0x500000
		BL	wait
		POP		{PC}


		nop		
		END    