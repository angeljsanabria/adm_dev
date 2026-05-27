# Tutorial: ARMv7 Thumb-2 y Guía de Ejercicios 1

Documento de referencia para programar en Assembly sobre **Cortex-M4** (STM32G4 y similares), basado en la presentación *Clase 3 - ARMv7 ISA*, el repositorio de ejemplos *Clase 4* y la *Guía de Ejercicios 1*.

---

## 1. Objetivo de este documento

Este archivo reúne:

1. **Todos los temas** vistos en la presentación de la Clase 3.
2. **Ejemplos concretos** del código de referencia (Clase 3 y Clase 4).
3. **La relación directa** entre cada tema y lo que pide la guía de ejercicios.
4. **Un recorrido tutorial** para que puedas resolver la guía por tu cuenta: primero en C, luego en Assembly.

**Metodología recomendada por la guía:** implementar en C, verificar el algoritmo, y recién después pasarlo a Assembly en un único archivo `.S`.

---

## 2. Contexto: Cortex-M4 y ARMv7

| Concepto | Detalle |
|----------|---------|
| Arquitectura | ARMv7-M (perfil Microcontroller) |
| ISA usada | **Thumb-2** (mezcla de instrucciones de 16 y 32 bits) |
| Modo de ejecución | Solo **Thumb** (bit 0 de direcciones de función en 1) |
| Registros generales | `r0`–`r12` |
| Registros especiales | `sp` (r13), `lr` (r14), `pc` (r15) |
| Convención de llamadas | **AAPCS** (ARM Architecture Procedure Call Standard) |

El Cortex-M4 implementa Thumb-2 completo, incluyendo instrucciones DSP como `usat` y `ssat`, relevantes para el Ejercicio 2.

---

## 3. Temas de la Clase 3 (presentación)

### 3.1 Características generales de Thumb-2

**Qué es:** Thumb-2 es el conjunto de instrucciones de ARMv7-M. Combina instrucciones compactas de 16 bits con instrucciones de 32 bits más expresivas. Es compatible con **UAL** (*Unified Assembly Language*).

**Por qué importa en la práctica:**

- El compilador/ensamblador elige 16 bits cuando puede (menor tamaño de código).
- En Assembly manual podés forzar el tamaño con sufijos `.N` (16 bits) o `.W` (32 bits).

**Formato general de una instrucción:**

```
INST{S}<c>.<q> <Rd>, <Rn>, <Rm>
```

| Parte | Significado | Ejemplo |
|-------|-------------|---------|
| `{S}` | Actualiza flags del APSR | `ADDS r0, r1` |
| `<c>` | Condición (bloques IT) | `ADDEQ r0, r1` |
| `<q>` | Tamaño de instrucción | `SUB.W` (32b), `SUB.N` (16b) |
| `<Rd>` | Registro destino | `r0` |
| `<Rn>, <Rm>` | Operandos | `r1`, r2` |

**Immediate:** valor embebido en la propia instrucción (no pasa por memoria). Ejemplo: `mov r3, #1`.

**Directivas obligatorias en un archivo `.S` para Cortex-M4:**

```asm
.text          /* Seccion de codigo ejecutable */
.syntax unified /* UAL */
.thumb          /* ISA Thumb-2 */
.global mi_funcion  /* Exportar simbolo a C */
.thumb_func     /* Marcar entrada de funcion Thumb */
mi_funcion:
    /* ... */
    bx lr
```

Referencia en el repo: `refProj/.../Clase3/Core/Src/asm_functions.S` (líneas 7-11, 32-40).

---

### 3.2 Tipos de instrucciones

La presentación agrupa el ISA en cinco familias. Todas aplican al trabajo de la guía.

#### A) Movimiento de datos

Copian valores entre registros o cargan constantes.

| Instrucción | Efecto | Ejemplo |
|-------------|--------|---------|
| `mov` | Copia valor | `mov r3, #1` |
| `mvn` | Copia complemento a uno | `mvn r3, r3` (niega bits) |

**Ejemplo Clase 4 — inicio de `asm_bitfield_clear`:**

```asm
mov r3, #1      /* r3 = 0x00000001 */
lsl r3, r1      /* desplaza segun ancho del campo */
```

#### B) Acceso a memoria (load/store)

Permiten leer y escribir en RAM usando direcciones base + offset.

**Modos de direccionamiento vistos en la presentación:**

```asm
ldr r0, [r1]              /* r0 = *r1 */
ldr r0, [r1, #64]         /* r0 = *(r1 + 64) */
ldr r0, [r1, #4]!         /* r0 = *(r1+4); r1 += 4 (pre-indexado) */
ldr r5, [r1, r2, LSL #2]  /* r5 = *(r1 + r2*4)  --> indice de vector uint32_t */
str r0, [r1], #-4         /* *r1 = r0; r1 -= 4 (post-indexado) */
str r4, [r1, r2, LSL #2]  /* *(r1 + r2*4) = r4 */
```

**Variantes por tamaño:**

| Instrucción | Tamaño | Uso |
|-------------|--------|-----|
| `LDRB` / `STRB` | 8 bits | bytes unsigned |
| `LDRSB` | 8 bits | byte con signo |
| `LDRH` / `STRH` | 16 bits | halfword |
| `LDRSH` | 16 bits | halfword con signo |
| `LDR` / `STR` | 32 bits | word |

**Regla importante (presentación, pág. 9):** si usás `r4`–`r12` dentro de una función, guardalos en el stack con `push` al inicio y recuperalos con `pop` antes de retornar.

**Ejemplo Clase 4 — recorrido de vector en `asm_productoEscalar32`:**

```asm
push {r4-r7}                    /* guardar registros callee-saved usados */
cbz r0, _exit1                  /* guarda: puntero nulo */
cbz r1, _exit1
_loop1:
    sub r2, #1
    ldr r4, [r0, r2, LSL #2]    /* LSL #2 = multiplicar indice por 4 bytes */
    mul r4, r4, r3
    str r4, [r1, r2, LSL #2]
    cbz r2, _exit1
    b _loop1
_exit1:
    pop {r4-r7}
    bx lr
```

**Por qué `LSL #2`:** cada elemento del vector es `uint32_t` (4 bytes). El offset en memoria es `indice * 4`.

**Recorrido descendente:** la guía y el repo iteran desde el último elemento hacia el primero (`i = longitud; i > 0; i--` en C). En Assembly: decrementar `r2` antes del acceso y salir cuando `r2 == 0`.

#### C) Operaciones aritméticas

Suman, restan, multiplican. Con sufijo `S` actualizan flags (N, Z, C, V) en el APSR.

```asm
add  r0, r1        /* r0 = r0 + r1 */
sub  r2, #1         /* r2 = r2 - 1 */
mul  r4, r4, r3     /* r4 = r4 * r3 (32x32 -> 32 bits) */
adds r0, r4         /* suma y actualiza flags */
subs r3, #2
```

**Uso en la guía:**

- Ejercicio 1: `mul` para producto escalar.
- Ejercicio 2: producto de `uint16_t` (podés usar `mul` y luego saturar).

#### D) Operaciones lógicas (bitwise)

Fundamentales para Ejercicios 3 y 4.

| Instrucción | Operación | Uso típico |
|-------------|-----------|------------|
| `and` | AND bit a bit | enmascarar / **clear** de bitfield |
| `orr` | OR bit a bit | set de bits |
| `eor` | XOR bit a bit | **toggle** de bitfield |
| `bic` | AND con complemento | clear alternativo |
| `lsl` | shift lógico izquierda | armar máscaras, indexar |
| `lsr` | shift lógico derecha | datos unsigned |
| `asr` | shift aritmético derecha | datos signed |
| `ror` | rotación derecha | no hay `rol`; rotar izq = rotar der (N-i) veces |

**Shift lógico vs aritmético (resumen de la presentación):**

| Operación | Unsigned | Signed |
|-----------|----------|--------|
| Shift izquierda | `LSL` | `LSL` |
| Shift derecha | `LSR` | `ASR` |

**Ejemplo Clase 4 — algoritmo de máscara en C (`C_functions.c`):**

```c
uint32_t bitfield_clear(uint32_t dato, uint32_t ancho, uint32_t inicio){
    uint32_t auxiliar = 1 << ancho;   /* ej: ancho=5 -> 0b100000 */
    auxiliar -= 1;                    /* 0b011111 */
    auxiliar = auxiliar << inicio;    /* desplazar al bit de inicio */
    auxiliar = ~auxiliar;             /* invertir: 1 donde NO se borra */
    return dato & auxiliar;           /* poner a 0 el campo */
}
```

**Equivalente en Assembly (`ASM_functions.S`):**

```asm
mov r3, #1
lsl r3, r1          /* (1 << ancho) */
sub r3, #1          /* mascara de 'ancho' unos consecutivos */
lsl r3, r2          /* shift a posicion 'inicio' */
mvn r3, r3          /* NOT de la mascara */
and r0, r3          /* resultado en r0 (valor de retorno) */
bx lr
```

**Ejemplo numérico (del `main.c` de Clase 4):**

- `a = 1023` → binario `0b001111111111` (bits 0–9 en 1)
- `bitfield_clear(a, 5, 3)` → borra 5 bits desde posición 3
- Resultado: bits 3–7 pasan a 0; el resto se mantiene.

#### E) Control de flujo

**Comparaciones y saltos:** `cmp`, `tst`, saltos condicionales (`beq`, `bne`, `bgt`, etc.).

**Tabla de sufijos (presentación):**

| Unsigned | Signed | Significado |
|----------|--------|-------------|
| HI | GT | mayor |
| HS | GE | mayor o igual |
| LS | LE | menor o igual |
| LO | LT | menor |
| PL | — | >= 0 |
| MI | — | < 0 |

**Saltos especializados para comparar con cero:**

```asm
cbz  r0, _exit   /* salta si r0 == 0 */
cbnz r0, _loop   /* salta si r0 != 0; la etiqueta debe estar adelante */
```

**Ejemplo de bucle (presentación y Clase 4):**

```asm
_loop1:
    sub r0, #1
    /* cuerpo */
    cbz r0, _exit1
    b _loop1
_exit1:
```

**Instrucción IT (*If-Then*):** ejecuta 1–4 instrucciones condicionalmente sin salto.

- Usar IT para condicionales **cortos** (≤ 4 instrucciones).
- Usar saltos (`b`, `cbz`) para bloques **largos** (como un bucle completo).

---

### 3.3 Aritmética saturada

En procesamiento de señales, el overflow no deseado se evita **limitando** el resultado al rango representable.

| Instrucción | Tipo | Efecto |
|-------------|------|--------|
| `ssat Rd, #n, Rm` | signed | satura a n bits con signo |
| `usat Rd, #n, Rm` | unsigned | satura a n bits sin signo |

**Ejemplos de la presentación:**

```asm
ssat r1, #16, r0    /* signed, 16 bits */
usat r4, #8, r2     /* unsigned, 8 bits */
```

**Relación con Ejercicio 2:** el producto escalar de `uint16_t` debe saturarse a **12 bits** (rango 0–4095). En Assembly:

```asm
mul  r4, r4, r3       /* producto 32 bits */
usat r4, #12, r4      /* limitar a 12 bits unsigned */
strh r4, [r1, r2, LSL #1]  /* guardar halfword; LSL #1 = *2 bytes */
```

En C podés implementar saturación manualmente o confiar en lógica equivalente antes de pasar a `usat`.

---

### 3.4 Interfaz C ↔ Assembly (AAPCS)

Reglas esenciales para Cortex-M:

| Regla | Detalle |
|-------|---------|
| Parámetros 1–4 | `r0`, `r1`, `r2`, `r3` |
| Valor de retorno | `r0` (escalares de 32 bits o menos) |
| Retorno de función | `bx lr` (`lr` = dirección de retorno) |
| Llamada desde C | `bl nombre_funcion` |
| Registros preservados | `r4`–`r11`, `sp` (la función llamada no debe destruirlos) |
| Registros temporales | `r0`–`r3`, `r12` (caller-saved) |

**Ejemplo mínimo — Clase 3, `asm_sum`:**

```c
/* functions.h */
uint32_t asm_sum(uint32_t primerOperando, uint32_t segundoOperando);
```

```asm
.thumb_func
asm_sum:
    add r0, r1    /* r0 = r0 + r1; resultado en r0 */
    bx lr
```

**Más de 4 parámetros — Clase 3, `asm_stack`:**

Los parámetros 5, 6, … se apilan **antes** del `bl`. Tras el `push` interno, se acceden con `ldr rn, [sp, #offset]`.

```asm
/* Parametros: r0-r5; el 5° y 6° quedaron en stack antes del bl */
push {r4-r8}
ldr  r4, [sp, #20]   /* 5° parametro */
ldr  r5, [sp, #24]   /* 6° parametro */
pop  {r4-r8}
bx lr
```

**Estructura de un proyecto (Clase 4):**

```
Core/Inc/functions.h     /* prototipos C y asm */
Core/Src/C_functions.c   /* implementacion C */
Core/Src/ASM_functions.S /* implementacion Assembly */
Core/Src/main.c          /* pruebas / llamadas */
```

---

## 4. Análisis del repositorio Clase 4

### 4.1 Qué contiene

| Archivo | Rol |
|---------|-----|
| `functions.h` | Declara 4 funciones: 2 en C y 2 en Assembly |
| `C_functions.c` | Solución de referencia en C (Ejercicios 1 y 3) |
| `ASM_functions.S` | Solución de referencia en Assembly (Ejercicios 1 y 3) |
| `main.c` | Prueba ambas versiones con los mismos datos |

### 4.2 Funciones implementadas

#### `productoEscalar32` / `asm_productoEscalar32`

- **Algoritmo:** `vectorOut[i] = vectorIn[i] * escalar` para todo `i`.
- **Técnicas Assembly:** punteros en `r0`/`r1`, longitud en `r2`, escalar en `r3`, `ldr`/`str` indexados, `mul`, bucle con `cbz`/`b`, `push`/`pop`.

**Nota sobre el prototipo:** la guía declara `longitud` como `uint16_t`; el repo usa `uint32_t`. Ambos funcionan si la longitud es pequeña; respetá el prototipo de la guía en tu entrega.

#### `bitfield_clear` / `asm_bitfield_clear`

- **Parámetros:** `dato`, `ancho` (cantidad de bits), `inicio` (LSB del campo).
- **Algoritmo:** construir máscara de `ancho` unos en posición `inicio`, invertirla, AND con `dato`.
- **Técnicas Assembly:** `mov`, `lsl`, `sub`, `mvn`, `and`, guardas con `cbz`.

### 4.3 Qué NO está en Clase 4 (lo completás vos)

| Ejercicio | Estado en repo |
|-----------|----------------|
| 1 — producto escalar 32 bits | Implementado (C + ASM) |
| 2 — producto escalar 16 bits + saturación 12 bits | **No implementado** |
| 3 — bitfield clear | Implementado (C + ASM) |
| 4 — bitfield toggle | **No implementado** |

---

## 5. Guía de Ejercicios 1 — requisitos

### Ejercicio 1 — Producto escalar 32 bits

```c
void productoEscalar32(uint32_t *vectorIn, uint32_t *vectorOut,
                       uint16_t longitud, uint16_t escalar);
```

**Qué practicás:** bucles, punteros, acceso a memoria con offset, multiplicación.

**Trampa común (comentada en el repo):** no usar `for (uint8_t i = longitud; i >= 0; i--)` con tipo unsigned; al llegar a 0 y restar, hace underflow infinito.

### Ejercicio 2 — Producto escalar 16 bits con saturación

```c
void productoEscalar12(uint16_t *vectorIn, uint16_t *vectorOut,
                       uint16_t longitud, uint16_t escalar);
```

**Qué practicás:** `LDRH`/`STRH`, `LSL #1` para indexar (2 bytes por elemento), **`usat #12`**.

**Saturación a 12 bits:** valores válidos 0 … 4095 (`2^12 - 1`). Si `vectorIn[i] * escalar > 4095`, el resultado debe ser 4095.

### Ejercicio 3 — Limpiar campo de bits

```c
uint32_t bitfield_clear(uint32_t dato, uint32_t ancho, uint32_t inicio);
```

**Qué practicás:** operaciones lógicas, construcción de máscaras, shifts.

**Interpretación de parámetros:**

- `inicio`: posición del bit menos significativo del campo (LSB).
- `ancho`: cantidad de bits consecutivos a poner en **0**.

### Ejercicio 4 — Invertir campo de bits (toggle)

```c
uint32_t bitfield_toggle(uint32_t dato, uint32_t ancho, uint32_t inicio);
```

**Qué practicás:** misma máscara que Ejercicio 3, pero operación **`eor`** (XOR) en lugar de `and` con máscara invertida.

**Diferencia clave respecto al Ejercicio 3:**

```c
/* Clear: poner campo a 0 */
return dato & ~mascara;

/* Toggle: invertir bits del campo */
return dato ^ mascara;
```

En Assembly: `eor r0, r3` en lugar de `and r0, r3` (con la misma `mascara` sin invertir).

---

## 6. Mapa integrado: tema → ejercicio → código de ejemplo

| Tema (Clase 3) | Ejercicio guía | Dónde verlo en el repo |
|----------------|----------------|------------------------|
| Directivas `.text`, `.thumb`, `.global` | Todos (ASM) | Clase3 `asm_functions.S` |
| AAPCS: params en r0–r3, retorno en r0 | Todos (ASM) | Clase3 `asm_sum`; Clase4 todas |
| `push`/`pop` de r4–r7 | 1, 2 | Clase4 `asm_productoEscalar32` |
| `ldr`/`str` + `LSL #2` (32 bits) | 1 | Clase4 `ASM_functions.S` |
| `ldr`/`str` + `LSL #1` (16 bits) | 2 | *(a implementar)* |
| `mul` | 1, 2 | Clase4 `asm_productoEscalar32` |
| `usat #12` | 2 | Presentación Clase 3 |
| Máscaras: `lsl`, `sub`, `mvn`, `and` | 3 | Clase4 `asm_bitfield_clear` |
| Máscaras + `eor` | 4 | *(derivar del ejercicio 3)* |
| `cbz`, bucles, `b` | 1, 2 | Clase4 `_loop1` |
| Guardas puntero nulo | 1, 3 | Clase4 `cbz r0, _exit` |
| Función simple sin memoria | — | Clase3 `asm_sum` |
| Parámetros > 4 vía stack | — | Clase3 `asm_stack` |
| `ssat` / contexto DSP | 2 (concepto) | Presentación Clase 3 |

---

## 7. Tutorial paso a paso para resolver la guía

### Paso 0 — Preparar el proyecto

1. Crear proyecto STM32 (CubeIDE) o usar plantilla del curso.
2. Agregar `functions.h`, `C_functions.c`, `ASM_functions.S`.
3. En propiedades del proyecto, verificar que el ensamblador procese `.S` (GCC ARM lo hace por defecto).

### Paso 1 — Ejercicio 1 en C

```c
void productoEscalar32(uint32_t *vectorIn, uint32_t *vectorOut,
                       uint16_t longitud, uint16_t escalar) {
    for (uint16_t i = longitud; i > 0; i--) {
        vectorOut[i - 1] = vectorIn[i - 1] * escalar;
    }
}
```

Probar en `main.c` con un vector pequeño y comparar a mano.

### Paso 2 — Ejercicio 1 en Assembly

Traducir línea a línea:

1. Documentar mapa de registros (como en Clase 4).
2. `push {r4-r7}` **antes** de cualquier guarda que use esos registros.
3. Validar punteros con `cbz`.
4. Bucle descendente con `sub r2, #1` antes de cada acceso.
5. `pop {r4-r7}` y `bx lr`.

Verificar con el mismo `main` que la versión C (`vecOut1` vs `vecOut2` en Clase 4).

### Paso 3 — Ejercicio 2 en C

```c
void productoEscalar12(uint16_t *vectorIn, uint16_t *vectorOut,
                       uint16_t longitud, uint16_t escalar) {
    const uint32_t max12 = 4095u;
    for (uint16_t i = longitud; i > 0; i--) {
        uint32_t prod = (uint32_t)vectorIn[i - 1] * escalar;
        if (prod > max12) prod = max12;
        vectorOut[i - 1] = (uint16_t)prod;
    }
}
```

### Paso 4 — Ejercicio 2 en Assembly

Copiar la estructura del Ejercicio 1 y cambiar:

- `LDRH` / `STRH` en lugar de `LDR` / `STR`.
- Offset: `LSL #1` (2 bytes).
- Tras `mul`, agregar `usat r4, #12, r4`.

### Paso 5 — Ejercicio 3 en C

Usar la implementación de `C_functions.c` del repo. Probar con `a = 1023`, `ancho = 5`, `inicio = 3` y dibujar el binario en papel.

### Paso 6 — Ejercicio 3 en Assembly

Seguir `asm_bitfield_clear` del repo. Entender cada instrucción anotando el valor de `r3` en cada paso.

### Paso 7 — Ejercicio 4 en C

```c
uint32_t bitfield_toggle(uint32_t dato, uint32_t ancho, uint32_t inicio) {
    uint32_t mascara = ((1u << ancho) - 1u) << inicio;
    return dato ^ mascara;
}
```

Comprobar: aplicar toggle **dos veces** debe devolver el dato original.

### Paso 8 — Ejercicio 4 en Assembly

Reutilizar la construcción de máscara del Ejercicio 3 (sin `mvn`) y cerrar con `eor r0, r3`.

### Paso 9 — Verificación sistemática

| Prueba | Qué validar |
|--------|-------------|
| Vector vacío / puntero NULL | salida segura (guards) |
| Escalar 0 y 1 | identidad / ceros |
| Producto > 4095 (Ej. 2) | saturación correcta |
| `ancho = 0` o `ancho + inicio > 32` | comportamiento definido (guards opcionales) |
| Toggle dos veces | vuelve al valor original |

Depuración recomendada: breakpoints en CubeIDE, inspeccionar `vectorOut` y registros `r0`–`r4` en vista Disassembly.

---

## 8. Plantilla base para nuevas funciones Assembly

```asm
.text
.syntax unified
.thumb

.global asm_mi_funcion

/* Prototipo C:
 * uint32_t asm_mi_funcion(uint32_t arg0, uint32_t arg1);
 * r0 = arg0, r1 = arg1
 * retorno en r0
 */
.thumb_func
asm_mi_funcion:
    push {r4-r7}        /* solo si usas esos registros */
    /* cuerpo */
    pop {r4-r7}
    bx lr
```

```c
/* functions.h */
uint32_t asm_mi_funcion(uint32_t arg0, uint32_t arg1);
```

---

## 9. Errores frecuentes y cómo evitarlos

| Error | Consecuencia | Solución |
|-------|--------------|----------|
| Olvidar `.thumb_func` | HardFault al llamar desde C | Siempre en entradas de función |
| No hacer `push`/`pop` simétrico | Corrupción de registros | Mismo conjunto en ambos |
| Usar `LSL #2` con `uint16_t` | Lee memoria incorrecta | Usar `LSL #1` |
| Confundir máscara clara/invertida en clear | No borra o borra de más | Seguir secuencia del repo |
| Usar `and` en toggle | No invierte bits | Usar `eor` |
| Bucle unsigned `i >= 0` | Bucle infinito | `i > 0` o contador en Assembly con `cbz` |
| `cbnz` a etiqueta anterior | Restricción del ISA | Usar `cbz` o saltos condicionales clásicos |

---

## 10. Referencias

| Recurso | Uso |
|---------|-----|
| Presentación `actividades/Clase 3 - ARMv7 ISA.pdf` | Teoría ISA |
| `actividades/Guía de Ejercicios 1.pdf` | Enunciados |
| `refProj/.../Clase3/` | Primeros pasos ASM + stack |
| `refProj/.../Clase4/` | Soluciones referencia Ej. 1 y 3 |
| ARM DDI 0403 (ARMv7-M ARM) | Codificación y detalle de instrucciones |
| ARM IHI 0042 (AAPCS) | Convención de llamadas |
| Joseph Yiu, *The Definitive Guide to ARM Cortex-M3 and Cortex-M4* | Shifts, rotaciones, IT |

---

## 11. Próximo paso sugerido

Con este documento podés:

1. Leer un tema de la sección 3.
2. Mirar el ejemplo del repo (sección 4 o 6).
3. Resolver el ejercicio correspondiente (sección 7).
4. Repetir hasta completar los cuatro ejercicios en C y Assembly.

Si querés, en un siguiente mensaje podemos armar el **tutorial interactivo** ejercicio por ejercicio (con ejercicios guiados, preguntas de comprensión y espacio para tu código) a partir de este `.md`.
