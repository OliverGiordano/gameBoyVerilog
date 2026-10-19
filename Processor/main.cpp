/*#include "VProcessor.h" 
#include "VProcessor___024root.h" 
#include "verilated.h"
#include <iostream>
#include <fstream>
#include <sstream>
#include <iomanip> // Needed for padding zeros in the filename

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);
    VProcessor* top = new VProcessor;

    top->Reset = 1;
    top->Clock = 0;
    top->Clock25 = 0;
    top->eval();
    top->Reset = 0;

    int time_step = 0;
    int frames_rendered = 0;
    bool last_vsync = true;

    std::cout << "Starting simulation..." << std::endl;

    // Run until 60 frames are rendered
    while (!Verilated::gotFinish() && frames_rendered < 900) {
        
        top->Clock25 = !top->Clock25;
        top->eval();

        if (time_step % 6 == 0) {
            top->Clock = !top->Clock;
            top->eval();
        }

        // Detect the end of a full monitor frame (Vsync falling edge)
        if (last_vsync == 1 && top->Vsync == 0) {
            frames_rendered++;
            std::cout << "Rendering frame " << frames_rendered << "..." << std::endl;

            // Dynamically generate the filename: frame_0001.ppm, frame_0002.ppm, etc.
            std::ostringstream filename;
            filename << "frame_" << std::setfill('0') << std::setw(4) << frames_rendered << ".ppm";

            std::ofstream img(filename.str());
            img << "P3\n160 144\n255\n"; // PPM Header

            for (int y = 0; y < 144; y++) {
                for (int x = 0; x < 160; x++) {
                    int pixel_color = top->rootp->Processor__DOT__frameBuffer[y*160+x];

                    int r = 0, g = 0, b = 0;
                    switch(pixel_color) {
                        case 0: r=255; g=255; b=255; break; // White
                        //case 0: r=170; g=170; b=170; break; // White
                        case 1: r=170; g=170; b=170; break; // Light Gray
                        case 2: r=85;  g=85;  b=85;  break; // Dark Gray
                        case 3: r=0;   g=0;   b=0;   break; // Black
                    }

                    //std::cout << "PixelColor" << pixel_color << std::endl;
                    img << r << " " << g << " " << b << " ";
                }
                img << "\n";
            }
            int nonzero = 0;
            for (int y = 0; y < 144; y++)
                for (int x = 0; x < 160; x++)
                    if (top->rootp->Processor__DOT__frameBuffer[y*160+x] != 0) nonzero++;
            std::cout << "  nonzero pixels: " << nonzero << std::endl;
            img.close();
        }
        last_vsync = top->Vsync;
        time_step++;
    }

    std::cout << "Simulation complete!" << std::endl;
    delete top;
    return 0;
}*/
#include "VProcessor.h"
#include "VProcessor___024root.h"
#include "verilated.h"
#include <SDL.h>
#include <cstdio>

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);
    VProcessor* top = new VProcessor;

    // hold reset across several clock edges
    top->Reset = 1; top->Clock = 0; top->Clock25 = 0; top->Buttons = 0;
    top->eval();
    for (int i = 0; i < 4; i++) { top->Clock = 1; top->eval(); top->Clock = 0; top->eval(); }
    top->Reset = 0; top->eval();

    SDL_Init(SDL_INIT_VIDEO);
    const int SCALE = 5;
    SDL_Window*   win = SDL_CreateWindow("GB", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED,
                                         160 * SCALE, 144 * SCALE, 0);
    SDL_Renderer* ren = SDL_CreateRenderer(win, -1, SDL_RENDERER_ACCELERATED);
    SDL_Texture*  tex = SDL_CreateTexture(ren, SDL_PIXELFORMAT_ARGB8888,
                                          SDL_TEXTUREACCESS_STREAMING, 160, 144);

    static uint32_t px[160 * 144];
    const uint32_t pal[4] = {0xFFFFFFFF, 0xFFAAAAAA, 0xFF555555, 0xFF000000};
    const Uint64 freq = SDL_GetPerformanceFrequency();
    const Uint64 frameTicks = (Uint64)(freq * (70224.0 / 4194304.0));
    Uint64 next = SDL_GetPerformanceCounter();
    Uint64 fpsStart = next; int frames = 0;
    bool running = true;

    while (running && !Verilated::gotFinish()) {
        SDL_Event e;
        while (SDL_PollEvent(&e)) if (e.type == SDL_QUIT) running = false;
        const Uint8* k = SDL_GetKeyboardState(nullptr);
        if (k[SDL_SCANCODE_ESCAPE]) running = false;

        uint8_t b = 0;
        if (k[SDL_SCANCODE_RIGHT])  b |= 1 << 0;
        if (k[SDL_SCANCODE_LEFT])   b |= 1 << 1;
        if (k[SDL_SCANCODE_UP])     b |= 1 << 2;
        if (k[SDL_SCANCODE_DOWN])   b |= 1 << 3;
        if (k[SDL_SCANCODE_Z])      b |= 1 << 4;   // A
        if (k[SDL_SCANCODE_X])      b |= 1 << 5;   // B
        if (k[SDL_SCANCODE_RSHIFT]) b |= 1 << 6;   // Select
        if (k[SDL_SCANCODE_RETURN]) b |= 1 << 7;   // Start
        top->Buttons = b;

        for (int i = 0; i < 4; i++) {
            top->Clock = 1; top->Clock25 = 1; top->eval();
            top->Clock = 0; top->Clock25 = 0; top->eval();
        }

        for (int i = 0; i < 70224; i++) {
            top->Clock = 1; top->eval();
            top->Clock = 0; top->eval();
        }

        for (int i = 0; i < 160 * 144; i++)
            px[i] = pal[top->rootp->Processor__DOT__frameBuffer[i] & 3];
        SDL_UpdateTexture(tex, nullptr, px, 160 * 4);
        SDL_RenderClear(ren);
        SDL_RenderCopy(ren, tex, nullptr, nullptr);
        SDL_RenderPresent(ren);

        frames++;
        Uint64 now = SDL_GetPerformanceCounter();
        if (now - fpsStart > freq) {
            //printf("%d fps\n", frames);
            //printf("%s keypress", k);
            frames = 0; fpsStart = now;
        }
        next += frameTicks;
        if (now < next) SDL_Delay((Uint32)((next - now) * 1000 / freq));
        else next = now;   // running slow: don't try to catch up
    }
    SDL_Quit();
    delete top;
    return 0;
}
