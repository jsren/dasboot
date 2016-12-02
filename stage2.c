/* stage2.c - (c) 2016 James S Renwick
   -----------------------------------
*/
#include "stage2.h"
#define BOOT_MAGIC 0xDA5B007

typedef struct 
{
    uint8_t character;
    unsigned foreColor : 4;
    unsigned backColor : 4;
} _packed_ tmchar;


video_mode currentVideoMode;


void print(const char* string)
{
    static volatile tmchar* textBuffer = (tmchar*)0xB8000;

    for (uint32_t i = 0; i < 255 && string[i] != '\0'; i++) {
        textBuffer[i] = (tmchar){ string[i], 0xF, 0x0 };
    }
}


void boot_main(uint32_t magic, const drive_info* driveInfo, 
    const video_mode* videoMode)
{
    // Sanity-check
    if (magic != BOOT_MAGIC) halt();

    currentVideoMode = *videoMode;

    print("Hello, World!");

    // TODO: Configure IDT
    // TODO: Set up keyboard interaction
    halt();
}


// Address of entry point
const volatile void* __attribute__((section (".entryAddr"))) 
    entryPointAddress = &boot_main;
