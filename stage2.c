/* stage2.c - (c) 2016 James S Renwick
   -----------------------------------
*/
#include "stage2.h"
#include "screen.h"
#include "title.h"

#define BOOT_MAGIC 0xDA5B007



void drawMenuItem(const char* string, uint32_t length, bool selected)
{
    tmcolors bg = selected ? TMCOLOR_WHITE : TMCOLOR_BLACK;

    // Generate background strip
    tmchar strip[80];
    for (int i = 0; i < 80; i++) {
        strip[i] = (tmchar) {' ', { 0, bg }};
    }

    // Print background strip
    tmpoint linestart = screen_getpos();
    linestart.column = 0;

    screen_set(strip, 80);
    screen_setpos(linestart);

    // Print label 
    int textstart = 80 / 2 - length / 2;
    screen_setposxy(textstart, linestart.row);

    if (selected) {
        screen_color(TMCOLOR_BLACK, TMCOLOR_WHITE);
    } else {
        screen_color(TMCOLOR_GRAY, TMCOLOR_BLACK);
    } 

    screen_print(string);
    screen_newline();
}


void boot_main(uint32_t magic, const drive_info* driveInfo, 
    const video_mode* videoMode)
{
    // Sanity-check
    if (magic != BOOT_MAGIC) halt();

    // TODO: Configure IDT
    // TODO: Set up keyboard interaction

    // Clear screen
    screen_setmode(videoMode->columns, 25);
    screen_clear();

    // Print title
    screen_setposxy(0, 4);
    screen_color(TMCOLOR_WHITE, TMCOLOR_BLACK);
    screen_print(titleText);

    // Print menu options
    const char item1Text[] = "DAS IST BOOT!";
    const char item2Text[] = "NICHT SO BOOT";
    
    screen_setposxy(0, 16);
    drawMenuItem(item1Text, sizeof(item1Text) - 1, /*selected=*/true);
    drawMenuItem(item2Text, sizeof(item2Text) - 1, /*selected=*/false);

    halt();
}


// Address of entry point
const volatile void* __attribute__((section (".entryAddr"))) 
    entryPointAddress = &boot_main;
