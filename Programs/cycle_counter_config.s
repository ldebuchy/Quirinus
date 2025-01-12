		AREA    |.text|, CODE, READONLY
		ENTRY
		
		EXPORT	CYCLE_COUNTER_INIT
		EXPORT	CYCLE_COUNTER_READ
			
DWT_CYCCNT	EQU	0xE0001004 
DEMCR	EQU	0xE000EDFC
	
CYCLE_COUNTER_INIT
		LDR R0, =DEMCR        ; Adresse du registre DEMCR (Debug Exception and Monitor Control)
		LDR R1, [R0]
		ORR R1, R1, #(1 << 24)     ; Activer TRCENA (bit 24)
		STR R1, [R0]

		LDR R0, =DWT_CYCCNT        ; Adresse de DWT_CYCCNT
		LDR R1, [R0]
		ORR R1, R1, #1             ; Activer le compteur de cycles (bit 0)
		STR R1, [R0]
		
		BX	LR
		
CYCLE_COUNTER_READ
		ldr R0, = DWT_CYCCNT       ; Adresse du registre 
		ldr R0, [R0]               ; Charger la valeur actuelle de l'horloge
		BX	LR

		END