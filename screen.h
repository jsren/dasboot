/* screen.h - (c) 2016 James S Renwick
   -----------------------------------
   Authors: James S Renwick
*/ 
#pragma once

#define _packed_ __attribute__((packed))
#define _noreturn_ __attribute__((noreturn))

typedef unsigned char uint8_t;
typedef unsigned short int uint16_t;
typedef unsigned long int uint32_t;


typedef struct 
{
    uint8_t column;
    uint8_t row;
} tmpoint;


typedef struct
{
    unsigned fore : 4;
    unsigned back : 4;
} _packed_ tmcolor;


typedef struct 
{
    uint8_t character;
    tmcolor color;
} _packed_ tmchar;


typedef enum
{
    TMCOLOR_BLACK   = 0x0,
    TMCOLOR_BLUE    = 0x1,
    TMCOLOR_GREEN   = 0x2,
    TMCOLOR_CYAN    = 0x3,
    TMCOLOR_RED     = 0x4,
    TMCOLOR_MAGENTA = 0x5,
    TMCOLOR_BROWN   = 0x6,
    TMCOLOR_GRAY    = 0x7,

    TMCOLOR_DARKGRAY     = 0x8,
    TMCOLOR_LIGHTBLUE    = 0x9,
    TMCOLOR_LIGHTGREEN   = 0xA,
    TMCOLOR_LIGHTCYAN    = 0xB,
    TMCOLOR_LIGHTRED     = 0xC,
    TMCOLOR_LIGHTMAGENTA = 0xD,
    TMCOLOR_YELLOW       = 0xE,
    TMCOLOR_WHITE        = 0xF

} tmcolors;


void screen_setmode(uint8_t columns, uint8_t rows);
void screen_color(tmcolors foreColor, tmcolors backColor);
void screen_forecolor(tmcolors color);
void screen_backcolor(tmcolors color);
void screen_print(const char* string);
void screen_newline();
void screen_clear();
tmpoint screen_getpos();
void screen_setpos(tmpoint point);
void screen_setposxy(uint8_t column, uint8_t row);
void screen_set(const tmchar* chars, uint32_t length);
