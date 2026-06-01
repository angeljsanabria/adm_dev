/* ################## Guía de Ejercicios 2 ##################
Archivo: AdM_e2622_e2619_e2605_GE2
| e2622 | Sanabria, Angel Javier| 05/2026| Semana 05 |
| e2619 | Urian Florez, Brajhan Andres| 05/2026 | Semana 05 |
| e2605 | Guirula, Lucia Agostina| 05/2026 | Semana 05 |
*/
.text
.syntax unified
.thumb

/* Exportar funciones*/
.global asm_invertir


/* Ejercicio 4 */
// Prototipo en archivo .h:
// void asm_invertir(uint16_t *buffer, uint16_t longitud);
// Parámetros recibidos:
//	r0: arreglo a procesar
//	r1: longitud
.thumb_func
	asm_invertir:

		push {r4 - r7} // Se resguardan los valores de los registros en el stack
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
		pop {r4 - r7}
		bx lr


// Prototipo en archivo .h:
// void asm_GPS_unpack(int32_t *GPS_data, int16_t *GPS_Lat, int16_t *GPS_Long, uint16_t longitud);
.thumb_func
	asm_GPS_unpack:

// void asm_downSample(int32_t *Signal_HF, int32_t *Signal_LF, uint16_t longitud, uint16_t N);
.thumb_func
	asm_downSample:

// uint32_t asm_max(int32_t *vectorIn, uint32_t longitud);
.thumb_func
	asm_max:
