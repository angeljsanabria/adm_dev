/* ################## Guía de Ejercicios 2 ##################
Archivo: _TODO RENOMBRAR AdM_e2622_e2619_e2605_GE2
| e2622 | Sanabria, Angel Javier| 05/2026| Semana 05 |
| e2619 | Urian Florez, Brajhan Andres| 05/2026 | Semana 05 |
| e2605 | Guirula, Lucia Agostina| 05/2026 | Semana 05 |
*/
.text
.syntax unified
.thumb

/* Exportar funciones*/
.global asm_invertir
.global asm_max
.global asm_downSample



/* Ejercicio 4 */
// Prototipo en archivo .h:
// void asm_invertir(uint16_t *buffer, uint16_t longitud);
// Parámetros recibidos:
//	r0: vector a procesar
//	r1: longitud
.thumb_func
	asm_invertir:

		push {r4 - r5} // Se resguardan los valores de los registros en el stack
		cbz r0, _exit_invertir

		cmp r1, #1			// Comparo con 1, para checkear menor igual.
		bls _exit_invertir	// Hay 1 o 0 elementos, (long menor igual a 1) escapo

		mov r2, #0
		sub r1, #1	// longitud = longitud - 1

		_loop_invertir:

			cmp r2, r1
			bhs _exit_invertir		// Si es mayor igual, termina (funciona caso longitud par)
										// Inicio de Swap
			ldrh r4, [r0, r2, LSL #1]		// Cargo,
			ldrh r5, [r0, r1, LSL #1]

			strh r5, [r0, r2, LSL #1]		// Guardo
			strh r4, [r0, r1, LSL #1]
										// Fin de Swap
			add r2, #1				// suma y resta de los offsets
			sub r1, #1

			b _loop_invertir		// itero de nuevo


	_exit_invertir:
		pop {r4 - r5}
		bx lr



/* Ejercicio 3 */
// uint32_t asm_max(int32_t *vectorIn, uint32_t longitud)
// Parámetros recibidos:
//	r0: vector a procesar
//	r1: longitud
// 120, -45, 310, 89, 542, -12, 410, 201, 678, 912, 430, -90, 912, 150, 300	// Valores ejemplo
//   0 ,  1,   2,  3,   4,   5,   6,   7,   8,   9,  10,   11, 12,  13,  14 // Indice
.thumb_func
	asm_max:

	    push {r4,r5} // r4 = valor máximo; r5 = valor actual

	    cbz r0, _max_fin
	    cbz r1, _max_fin

	    mov r3, #0

	    ldr r4, [r0]

	    mov r2, #1

		_loop_max:

		    cmp r2, r1
		    bhs _fin_loop  //i >= longitud

		    ldr r5, [r0, r2, LSL #2]

		    cmp r5, r4
		    ble _siguiente //ble xq son enteros signados

		    mov r4, r5
		    mov r3, r2

		_siguiente:

		    add r2, #1
		    b _loop_max

		_fin_loop:

		    mov r0, r3

	_max_fin:

	    pop {r4,r5}
	    bx lr


/* Ejercicio 3 */
// uint32_t asm_max(int32_t *vectorIn, uint32_t longitud)
// Parámetros recibidos:
// r0 = Signal_HF (vector de entrada)
// r1 = Signal_LF (vector de salida)
// r2 = longitud
// r3 = N
// r4 = i (índice del vector de entrada)
// r5 = j (índice del vector de salida)
// r6 = muestra temporal
.thumb_func
	asm_downSample:

	    push {r4-r6}

	    cbz r0,_exit_ds   // Si Signal_HF es NULL, salir
	    cbz r1,_exit_ds   // Si Signal_LF es NULL, salir
	    cbz r3,_exit_ds   // Evita N = 0

	    mov r4,#0         // i = 0
	    mov r5,#0         // j = 0

		_loop_ds:

		    cmp r4,r2         // i >= longitud
		    bhs _exit_ds

		    ldr r6,[r0,r4,LSL #2]
		    str r6,[r1,r5,LSL #2]

		    add r4,r3         // i += N
		    add r5,#1         // j++

		    b _loop_ds

	_exit_ds:

	    pop {r4-r6}
	    bx lr

