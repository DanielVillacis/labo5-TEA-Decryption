.include "macros.s"
.global  main

main:                           // main()
    // Lire mots w0 et w1       // {
    //             à déchiffrer //
    adr     x0, fmtEntree       //
    adr     x1, temp            //
    bl      scanf               //   scanf("%X", &temp)
    ldr     w19, temp           //   w0 = temp
                                //
    adr     x0, fmtEntree       //
    adr     x1, temp            //
    bl      scanf               //   scanf("%X", &temp)
    ldr     w20, temp           //   w1 = temp
                                //
    // Déchiffrer w0 et w1      //
    mov     w0, w19             //
    mov     w1, w20             //
    ldr     w2, k0              //
    ldr     w3, k1              //
    ldr     w4, k2              //
    ldr     w5, k3              //
    bl      dechiffrer          //   w0, w1 = dechiffrer(w0, w1, w2, w3, w4, w5)
                                //
    // Afficher message secret  //
    mov     w19, w0             //
    mov     w20, w1             //
                                //
    adr     x0, fmtSortie       //
    mov     w1, w19             //
    mov     w2, w20             //
    bl      printf              //   printf("%c %c\n", w0, w1)
                                //
    // Quitter programme        //
    mov     x0, 0               //
    bl      exit                //   return 0
                                // }
/*******************************************************************************
  Procédure de déchiffrement de l'algorithme TEA
  Entrées: - mots w0 et w1 à déchiffrer (32 bits chacun)
           - clés w2, w3, w4 et w5      (32 bits chacune)
  Sortie: mots w0 et w1 déchiffrés
  Usage des registres :
  w19 -- w0
  w20 -- w1
  w21 -- delta
  w22 -- i
  w23 -- temp
  w24 -- temp
  w25 -- temp
  w26 -- temp
  w28 -- 33
*******************************************************************************/
dechiffrer:						//
	SAVE 						//
	mov 	w19, w0				// w19 = w0
	mov		w20, w1				// w20 = w1
	ldr		w21, delta			// w21 = 0x9E3779B9 (delta)
	mov 	w22, 1				// int i = 1;
	mov 	w23, 0				// int sum = 0
	mov 	w28, 33				// 33

								//
dechiffrer_boucle:				//
	cmp 	w22, 32				// for (i = 1; i<32 ; i++) {
	b.hi 	dechiffrer_ret		//
								//
								//
	// Calcul du w1'			//
	lsl		w24, w19, 4			//		(w0 << 4)
	add		w24, w24, w4		//		((w0 << 4) + w4)
								//
	// Calcul de sum			//
	sub 	w23, w28, w22		// 		sum = (33 - i);
	mul 	w23, w23, w21		// 		sum = (33 - i) * delta;
	add 	w23, w23, w19		// 		w23 = (w0 + sum);
								//
	lsr		w25, w19, 5			//		(w0 >> 5)
	add		w25, w25, w5		//		((w0 >> 5) + w5)
								//
	eor		w26, w24, w23		//		w26 = w24 ⊕ w23
	eor		w24, w26, w25		//		w24 = w26 ⊕ w25
	sub		w20, w20, w24		//		w1' = w1 - w24;
								//
								//
								//
	// Calcul du w0'			//
	lsl		w24, w20, 4			//		(w1 << 4)
	add 	w24, w24, w2		//		((w1 << 4) + w2)
								//
	// Calcul de sum 			//
	sub		w23, w28, w22		//		sum = (33 - i)
	mul 	w23, w23, w21		//		sum = (33 - i) * delta
	add 	w23, w23, w20		//		w23 = (sum + w1);
								//
	lsr		w25, w20, 5			//		(w1 >> 5)
	add		w25, w25, w3		//		((w1 >> 5) + w3)
								//
	eor		w26, w24, w23		// 		w26 = w24 ⊕ w27
	eor		w24, w26, w25		//		w24 = w26 ⊕ w25
								//
	sub		w19, w19, w24		//		w0' = w0 - w24;
	add		w22, w22, 1			//
	b		dechiffrer_boucle	// }
								//
								//
dechiffrer_ret:					// return w0', w1';
	mov w0, w19					//
	mov w1, w20					//
	RESTORE						//
	ret							//
								//
.section ".rodata"
k0:         .word   0xABCDEF01
k1:         .word   0x11111111
k2:         .word   0x12345678
k3:         .word   0x90000000
delta:      .word   0x9E3779B9

fmtEntree:  .asciz  "%X"
fmtSortie:  .asciz  "%c %c\n"

.section ".data"
            .align  4
temp:       .skip   4


// Implementation de l'algorithme de décryption TEA en C++ :
//	for (int i = 1; i < 32; i++) {
//		v1 -= ((v0 << 4) + w4)⊕(v0 + sum)⊕((v0 >> 5) + w5);
//		v0 -= ((v1 << 4) + w2)⊕(v1 + sum)⊕((v1 >> 5) + w3);
//		sum -= delta;
// 	}
//	return v1, v0;
