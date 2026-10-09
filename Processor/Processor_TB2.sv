`timescale 1ns/1ps

module tb_GameBoyTop();

    logic Clock;
    logic Reset;
    logic We;
    logic [15:0] Addr;
    logic [15:0] VramAddr;
    logic [7:0] Din;
    logic [7:0] LyIn;
    logic [1:0] CurrentMode;
    logic vBlankInterrupt;
    logic ClearIF;

    logic [7:0] Dout;
    logic [7:0] IFout;
    logic [7:0] IEout;
    logic [7:0] VramDout;
    logic [7:0] LcdcRegisterOut;
    logic [7:0] BgpMap;
    logic [7:0] Scx;
    logic [7:0] Scy;
    logic [15:0] RomAddr;
    logic [7:0] RomData;

    // Instantiate MMU
    Mmu uut (
        .*
    );

    // Instantiate simplified ROM module
    Rom rom_inst (
        .Addr(RomAddr),
        .DataOut(RomData)
    );

    // Clock generation (4.194304 MHz Game Boy clock)
    initial begin
        Clock = 0;
        forever #119.2 Clock = ~Clock;
    end

    // Test sequence
    initial begin
        Reset = 1;
        We = 0;
        Addr = '0;
        VramAddr = '0;
        Din = '0;
        LyIn = '0;
        CurrentMode = '0;
        vBlankInterrupt = 0;
        ClearIF = 0;

        #500;
        Reset = 0;
        
        #500000;
        $finish;
    end

    // Monitor VRAM writes
    initial begin
        @(negedge Reset);
        forever begin
            @(posedge Clock);
            if (We && (Addr >= 16'h8000 && Addr <= 16'h9FFF)) begin
                $display("[VRAM] Addr: %h | Data: %h", Addr, Din);
            end
        end
    end

endmodule
