#ifndef INC_FUNCTIONS_H_
#define INC_FUNCTIONS_H_

#include "inttypes.h"

/* Funciones en implementadas en C */

/* Funciones implementadas en Assembly*/
void asm_invertir (uint16_t *buffer, uint16_t longitud);
uint32_t asm_max(int32_t *vectorIn, uint32_t longitud);
void asm_downSample(int32_t *Signal_HF, int32_t *Signal_LF, uint16_t longitud, uint16_t N);
#endif /* INC_FUNCTIONS_H_ */
