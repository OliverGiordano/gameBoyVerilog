module Mmu(
        input logic We, Clock, Reset, ClearIF, vBlankInterrupt,
        input logic [1:0] CurrentMode,
        input logic [15:0] Addr, VramAddr,
        input logic [7:0] Din, LyIn,
        input logic [7:0] RomData,
        input logic [7:0] Buttons,
        output logic [7:0] Dout, IFout, IEout, VramDout, LcdcRegisterOut, BgpMap, Scx, Scy,
        output logic [15:0] RomAddr
    );
    logic ramWe;
    logic vramWe;
    logic [7:0] ifData, ieData, tempDataOut, lyRegister, vramDataOut, bgpRegister, ScyReg, ScxReg;
    logic [7:0] lcdcRegister;
    logic [6:3] statInterupts;
    logic [5:4] joypSel;

    Ram ram(.We(ramWe), .Clock, .Addr, .Dout(tempDataOut), .Din);
    Vram vram(.We(vramWe), .Clock, .Addr1(Addr), .Addr2(VramAddr-16'h8000),
              .Dout1(vramDataOut), .Dout2(VramDout), .Din(Din));

    assign IFout = ifData;
    assign IEout = ieData;
    assign LcdcRegisterOut = lcdcRegister;
    assign BgpMap = bgpRegister;
    //assign VramDout = vramDataOut;
    //assign lyRegister = LyIn;
    always_ff @(posedge Reset, posedge Clock) begin
        if(Reset) begin
            ifData <= '0;
            ieData <= '0;
            lcdcRegister <= 8'h91;
            statInterupts <= '0;
            bgpRegister <= 8'hFC;
            Scy <= '0;
            Scx <= '0;
            lyRegister <= '0;
        end else begin
            if(vBlankInterrupt) ifData[0] <= 1;
            if(ClearIF) ifData <= '0;
            if(We) begin
                if (Addr == 16'hFF01) begin
                    // Print the raw ASCII character to the terminal!
                    $write("%c", Din);
                    $fflush();
                end
                if(Addr == 16'hFF41) statInterupts <= Din[6:3];
                else if (Addr == 16'hFF45) lyRegister <= Din;
                else if (Addr == 16'hFF40) begin
                    //$display("CPU wrote to LCDC: %h\n", Din);
                    lcdcRegister <= Din;
                end
                else if (Addr == 16'hFF00) joypSel <= Din[5:4];
                else if (Addr == 16'hFF0F) ifData <= Din;
                else if (Addr == 16'hFFFF) ieData <= Din;
                else if (Addr == 16'hFF47) bgpRegister <= Din;
                else if (Addr == 16'hFF42) Scy <= Din;
                else if (Addr == 16'hFF43) Scx <= Din;
            end
        end
    end
    //always_ff @(posedge Clock)
    //    if (vramWe) $display("VRAM[%h] <= %h", Addr, Din);
    //
    logic [3:0] joypNibble;
    always_comb begin
        joypNibble = 4'hF;
        if (!joypSel[4]) joypNibble = joypNibble & ~Buttons[3:0];   // d-pad selected
        if (!joypSel[5]) joypNibble = joypNibble & ~Buttons[7:4];   // A/B/Select/Start selected
    end
    always_comb begin
        Dout = tempDataOut;
        RomAddr = Addr;
        if(Addr == 16'hFFFF) begin
            ramWe = 0;
            vramWe = 0;
            Dout = ieData;
        end else if(Addr == 16'hFF0F) begin
            ramWe = 0;
            vramWe = 0;
            Dout = ifData;
        end else if(Addr == 16'hFF45) begin
            ramWe = 0;
            vramWe = 0;
            Dout = lyRegister;
        end else if(Addr == 16'hFF44) begin
            ramWe = 0;
            vramWe = 0;
            Dout = LyIn;
        end else if(Addr == 16'hFF43) begin
            ramWe = 0;
            vramWe =0;
            Dout = Scx;
        end else if(Addr == 16'hFF42) begin
            ramWe = 0;
            vramWe =0;
            Dout = Scy;
        end else if(Addr == 16'hFF00) begin
            ramWe = 0;
            vramWe =0;
            Dout = {2'b11, joypSel, joypNibble};
        end else if(Addr == 16'hFF41) begin
            ramWe = 0;
            vramWe = 0;
            Dout = {1'b1, statInterupts, (LyIn == lyRegister), CurrentMode};
        end else if(Addr == 16'hFF40) begin
            ramWe = 0;
            vramWe = 0;
            Dout = lcdcRegister;
        end else if(Addr == 16'hFF47) begin
            ramWe = 0;
            vramWe = 0;
            Dout = bgpRegister;
        end else if(16'h9FFF >= Addr && Addr >= 16'h8000) begin
            ramWe = 0;
            vramWe = We;
            Dout = vramDataOut;
        end else if(Addr <= 16'h7FFF) begin
            ramWe = 0;
            vramWe = 0;
            Dout = RomData;
        end else begin
            ramWe = We;
            vramWe = 0;
        end
    end
endmodule
