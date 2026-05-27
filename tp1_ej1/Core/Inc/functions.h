#ifndef INC_FUNCTIONS_H_
#define INC_FUNCTIONS_H_

#include "inttypes.h"

/* Funciones en implementadas en C */
void productoEscalar32(uint32_t *vectorIn, uint32_t *vectorOut, uint32_t longitud, uint16_t escalar);
uint32_t bitfield_clear(uint32_t dato, uint32_t ancho, uint32_t inicio);

/* Funciones implementadas en Assembly*/
void asm_productoEscalar32(uint32_t *vectorIn, uint32_t *vectorOut, uint32_t longitud, uint16_t escalar);
void asm_productoEscalar16(uint16_t *vectorIn, uint16_t *vectorOut, uint16_t longitud, uint16_t escalar);
uint32_t asm_bitfield_clear(uint32_t dato, uint32_t ancho, uint32_t inicio);
uint32_t asm_bitfield_toggle(uint32_t dato, uint32_t ancho, uint32_t inicio);

#endif /* INC_FUNCTIONS_H_ */
