/* screen.c - (c) 2016 James S Renwick
   -----------------------------------
   Authors: James S Renwick
*/ 
#include "screen.h"


static volatile tmchar* const textBuffer = (tmchar*)0xB8000;
static volatile tmchar* cursor = (tmchar*)0xB8000;

static tmpoint cursorPos = { 0, 0 };

static uint8_t screen_rows = 25;
static uint8_t screen_cols = 0;
static tmcolor textColor = { TMCOLOR_WHITE, TMCOLOR_BLACK };



void screen_setmode(uint8_t columns, uint8_t rows)
{
    screen_rows = rows;
    screen_cols = columns;
}


void screen_newline()
{
    cursor += (screen_cols - cursorPos.column);
    cursorPos.column = 0;
    cursorPos.row += 1;
}


void screen_clear()
{
    // To clear the screen, we have to draw blanks :/
    for (uint32_t i = 0; i < screen_cols * screen_rows; i++) {
        cursor[i] = (tmchar){ ' ', { 0x0 } };
    }
}


void screen_forecolor(tmcolors color) {
    textColor = (tmcolor){ color , textColor.back };
}
void screen_backcolor(tmcolors color) {
    textColor = (tmcolor){ textColor.fore, color };
}
void screen_color(tmcolors foreColor, tmcolors backColor) {
    textColor = (tmcolor){ foreColor, backColor };
}


void screen_print(const char* string)
{
    for (uint32_t i = 0; i < 1024 && string[i] != '\0'; i++)
    {
        if (string[i] == '\n') { screen_newline(); continue; }

        *(cursor++) = (tmchar){ string[i], textColor };

        if (++cursorPos.column == screen_cols) {
            cursorPos.column = 0; cursorPos.row++;
        }
    }
}


void screen_set(const tmchar* chars, uint32_t length)
{
    for (uint32_t i = 0; i < length; i++) {
        *(cursor++) = chars[i];
    }
}


tmpoint screen_getpos()
{
    return (tmpoint) { cursorPos.column, cursorPos.row };
}


void screen_setpos(tmpoint point)
{
    cursorPos = point;
    cursor = textBuffer + (point.row * screen_cols + point.column);
}


void screen_setposxy(uint8_t column, uint8_t row)
{
    cursorPos = (tmpoint) { column, row };
    cursor = textBuffer + (row * screen_cols + column);
}
