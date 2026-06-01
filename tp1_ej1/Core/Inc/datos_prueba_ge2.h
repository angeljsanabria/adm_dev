#ifndef DATOS_PRUEBA_GE2_H
#define DATOS_PRUEBA_GE2_H


// ============================================================================
// EJERCICIO 1: Módulo GPS
// ============================================================================
// Cada dígito hexadecimal representa 4 bits.

#define LONGITUD_EJ1 10

static const int32_t GPS_data[LONGITUD_EJ1] = {
    0x00000000, // Lat = 0    | Long = 0
    0x0000A00A, // Lat = 10   | Long = 10
    0x00064064, // Lat = 100  | Long = 100
    0x003E80C8, // Lat = 200  | Long = 1000
    0x007D07D0, // Lat = 2000 | Long = 2000
    0x00800800, // Lat = -2048| Long = -2048
    0x00FFF001, // Lat = 1    | Long = -1
    0x00001FFF, // Lat = -1   | Long = 1
    0x00FC0040, // Lat = 64   | Long = -64
    0x00123C98  // Lat = -872 | Long = 291
};


// ============================================================================
// EJERCICIO 2: Downsampling
// ============================================================================

#define LONGITUD_EJ2_IN  36

static const int32_t Signal_HF[LONGITUD_EJ2_IN] = {
    0,   17,  34, 50,  64,  77, 87,  94,  98, 100, 98,  94,
    87,  77,  64, 50,  34,  17, 0,  -17, -34, -50, -64, -77,
   -87, -94, -98, -100,-98, -94, -87, -77, -64, -50, -34, -17
};


// ============================================================================
// EJERCICIO 3: Pico máximo de presión en banco de pruebas de motores
// ============================================================================

#define LONGITUD_EJ3 15

static const int32_t vectorIn_ej3[LONGITUD_EJ3] = {
    120, -45, 310, 89, 542, -12, 410, 201, 678, 912, 430, -90, 912, 150, 300
};


// ============================================================================
// EJERCICIO 4: Inversión de buffer en driver LCD
// ============================================================================

#define LONGITUD_EJ4_PAR 12

static const uint16_t buffer_ej4_in[LONGITUD_EJ4_PAR] = {
    100, 200, 300, 400, 500, 600, 700, 800, 900, 1000, 1100, 1200
};

#define LONGITUD_EJ4_IMPAR 13

static const uint16_t buffer_ej4_in_b[LONGITUD_EJ4_IMPAR] = {
    10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 110, 120, 130
};


// ============================================================================
// PROTOTIPOS DE LAS FUNCIONES EN C
// ============================================================================
void GPS_unpack(int32_t *GPS_data, int16_t *GPS_Lat, int16_t *GPS_Long, uint16_t longitud);
void downSample(int32_t *Signal_HF, int32_t *Signal_LF, uint16_t longitud, uint16_t N);
uint32_t max(int32_t *vectorIn, uint32_t longitud);
void invertir(uint16_t *buffer, uint16_t longitud);

// ============================================================================
// PROTOTIPOS DE LAS FUNCIONES EN ASSEMBLY
// ============================================================================
void asm_GPS_unpack(int32_t *GPS_data, int16_t *GPS_Lat, int16_t *GPS_Long, uint16_t longitud);
void asm_downSample(int32_t *Signal_HF, int32_t *Signal_LF, uint16_t longitud, uint16_t N);
uint32_t asm_max(int32_t *vectorIn, uint32_t longitud);
void asm_invertir(uint16_t *buffer, uint16_t longitud);

#endif // DATOS_PRUEBA_GE2_H
