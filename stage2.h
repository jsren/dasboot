/* stage2.h - (c) 2016 James S Renwick
   -----------------------------------
*/
#pragma once

typedef _Bool bool;
#define true (bool)1
#define false 0

#define _packed_ __attribute__((packed))
#define _noreturn_ __attribute__((noreturn))

typedef unsigned char uint8_t;
typedef unsigned short int uint16_t;
typedef unsigned long int uint32_t;


typedef struct
{
    uint8_t  driveNo;
    uint16_t maxCylinder;
    uint8_t  maxHead;
    uint8_t  maxSector;
    uint8_t  driveCount;   
    unsigned : 16;
} _packed_ drive_info;


typedef struct
{
    uint8_t  mode;
    uint8_t  columns;
    uint8_t  page;
    unsigned : 8;
} _packed_ video_mode;



inline void _noreturn_ halt()
{
    __asm volatile("cli");
    __asm volatile("hlt");
}
