module Processor(
        input logic Clock, Reset, Clock25,
        output logic [7:0] VgaRed, VgaGreen, VgaBlue,
        input logic [7:0] Buttons,
                    // [0]=Right [1]=Left [2]=Up [3]=Down [4]=A [5]=B [6]=Select [7]=Start, active high
        output logic Hsync, Vsync
    );
    logic [15:0] Pc, PcNext;
    logic [2:0] cuJump; // if on allow for pc modifications
    logic [2:0] jump;
    logic [15:0] extendedCuOut;

    logic IncrementPc;
    logic aluInputControl;
    logic noCarry;

    //assign PcNext = Pc+IncrementPc;//this is our Pc Incrementer

    logic [7:0] cuDataOut;
    SignExtender signExtender(.Number(cuDataOut), .ExtendedNumber(extendedCuOut));


    ProgramCounter pc(.Clock, .Reset, .Pc, .PcNext);

    logic [7:0] OpCode;
    logic [15:0] memRomAddr;
    logic [7:0] memRomData;
    Rom rom(.Addr(Pc), .DataOut(OpCode), .DataMmu(memRomData), .AddrMmu(memRomAddr));

    logic [2:0] RegIn1, RegIn2, RegIn3;
    logic [3:0] AluOp;

    logic WriteEnable, wideRead, wideWrite, ramWriteEnable;
    logic [2:0] WriteDataSelect;

    logic [15:0] wideCuOut, wideRegOut;

    logic useConditional;
    logic [1:0] conditionalSelect;
    logic forceZero;
    logic [2:0] shiftMode;
    logic enableSp;
    logic [2:0] loadSp;
    logic [7:0] highMemWriteIn;
    //logic [7:0] AluInput;
    logic [1:0] highMem;
    logic highMemInputSelect;
    logic [15:0] summedWriteHigh;
    logic [15:0] muxedRamAddr;
    assign summedWriteHigh = {8'b0, highMemWriteIn} + 16'hFF00;
    logic [1:0] ramInSelect;
    logic spOpp;
    logic wideInCrtl;
    logic [15:0] tempSpOpp;
    logic wideAluInCtrl1, wideAluInCtrl2, wideAluControl;
    logic [7:0] iF, iE;
    logic clearIF;

    logic [7:0] cuOpcode;
    assign cuOpcode = (Pc >= 16'hFF80) ? 8'hC9 : OpCode;


    ControlUnit cu(.Clock,.Reset,.OpCode(cuOpcode),.IncrementPc,.Reg1(RegIn1),.Reg2(RegIn2),
                   .Reg3(RegIn3),.AluOp,.WriteData(cuDataOut),.We(WriteEnable),.WriteSelect(WriteDataSelect),
                   .AluInputControl(aluInputControl),.Jump(cuJump),
                   .ConditionSelect(conditionalSelect),.UseConditional(useConditional),
                   .NoCarry(noCarry),.WideRead(wideRead),.WideWrite(wideWrite),
                   .RamWe(ramWriteEnable),.WideCuOut(wideCuOut),.ShiftMode(shiftMode),
                   .ForceZero(forceZero),.SpEnable(enableSp),.LoadSp(loadSp),.HighMem(highMem),
                   .HighMemSelect(highMemInputSelect),.RamInSelect(ramInSelect),.SpOpp(spOpp),
                   .WideInCrtl(wideInCrtl), .WideAluInCrtl1(wideAluInCtrl1),
                   .WideAluInCrtl2(wideAluInCtrl2), .WideAluControl(wideAluControl),
                   .IFin(iF), .IEin(iE), .ClearIF(clearIF));

    logic [7:0] AluIn1, AluIn2,  AluOut;
    logic [7:0] regFlagsIn;
    logic [7:0] aluRegFlagsOut;
    logic [7:0] regFlagsOut;

    logic [7:0] rfWriteIn;
    logic [7:0] rfOut2;


    logic [7:0] shiftOut;
    logic [7:0] shiftFlagsOut;
    //assign rfWriteIn = (WriteDataSelect) ? AluOut : cuDataOut;

    logic [15:0] spNext, sp, spPostCond;
    StackPointer stackPointer(.Clock, .Reset, .SpNext(spNext), .Sp(sp), .LoadEnable(enableSp));

    logic [15:0] wideRegLoad;
    logic [15:0] wideRegOut2;

    RegisterFile rf(.Clock, .Reset, .Addr1(RegIn1), .Addr2(RegIn2), .Addr3(RegIn3),
                    .RegIn(rfWriteIn), .Out1(AluIn1), .Out2(rfOut2), .FlagsOut(regFlagsOut),
                    .FlagsIn(regFlagsIn), .WideRead(wideRead), .WideWrite(wideWrite),
                    .We(WriteEnable), .WideRegIn(wideRegLoad), .WideRegOut(wideRegOut),
                    .WideRegOut2(wideRegOut2));

    Alu alu(.Op(AluOp), .In1(AluIn1), .In2(AluIn2), .FlagsIn(regFlagsOut),
            .FlagsOut(aluRegFlagsOut), .Out(AluOut), .NoCarry(noCarry));

    Shifter shifter(.Din(AluIn1), .FlagsIn(regFlagsOut), .Dout(shiftOut), .FlagsOut(shiftFlagsOut),
                    .ShiftMode(shiftMode), .ForceZero(forceZero));

    logic condJump;
    ConditionChecker condChecker(.ConditionSelect(conditionalSelect), .RegFlags(regFlagsOut),
                                 .Jump(condJump), .Enable(useConditional));
    //logic jump;
    assign jump = cuJump & {3{condJump|~useConditional}};
    logic enableRam;
    assign enableRam = ramWriteEnable & (~useConditional | condJump);

    logic [7:0] ramOut;
    logic [15:0] ramAddr;
    logic [7:0] ramIn;
    //Ram ram(.We(enableRam), .Clock, .Din(ramIn), .Addr(ramAddr), .Dout(ramOut));
    //
    logic [7:0] lcdY;
    logic [1:0] ppuState;
    logic vBlankPulse;

    logic [15:0] vramAddr;
    logic [7:0] bgpReg, scxReg, scyReg, lcdcReg, vramDout;
    logic pValid;
    logic [1:0] pOut;
    logic [7:0] screenX;
    Mmu mmu(.We(enableRam), .Clock, .Din(ramIn), .Addr(ramAddr), .Dout(ramOut), .IFout(iF),
            .IEout(iE), .Reset, .ClearIF(clearIF), .LyIn(lcdY), .CurrentMode(ppuState),
            .vBlankInterrupt(vBlankPulse), .VramAddr(vramAddr), .VramDout(vramDout),
            .LcdcRegisterOut(lcdcReg), .BgpMap(bgpReg), .Scx(scxReg),.Scy(scyReg),
            .RomData(memRomData), .RomAddr(memRomAddr), .Buttons(Buttons));

    Ppu ppu(.Clock, .Reset, .VBlankInterruptPulse(vBlankPulse), .CurrentState(ppuState),
            .LyOut(lcdY), .VramIn(vramDout), .BgpIn(bgpReg), .Scx(scxReg), .Scy(scyReg),
            .VramAddress(vramAddr), .PixelOut(pOut), .PixelValid(pValid), .ScreenX(screenX),
            .LcdcIn(lcdcReg));

    logic [15:0] spAdded;
    logic [7:0] spAddedFlags;
    logic [15:0] wideAluIn1;
    logic [15:0] wideAluIn2;
    Alu16Bit Alu16Bit(.Num1(wideAluIn1), .Num2(wideAluIn2), .Out(spAdded),
                      .FlagsOut(spAddedFlags), .Control(wideAluControl), .FlagsIn(regFlagsOut));

    logic [7:0] bitManipulatorDataOut;
    logic [7:0] bitManipulatorFlagsOut;
    BitManipulator bitManipulator(.Opperation(cuDataOut), .Din(AluIn1), .RegFlagsIn(regFlagsOut),
                                  .Dout(bitManipulatorDataOut),
                                  .RegFlagsOut(bitManipulatorFlagsOut));

    logic [1:0] frameBuffer[23040];
    always_ff @(posedge Clock) begin
        if (pValid && screenX < 160 && lcdY < 144) begin
            frameBuffer[lcdY*160+screenX] <= pOut;
        end
    end

    int ok2a = 0, bad2a = 0;
    logic [31:0] cyc = 0;
    int tileW = 0, tileNZ = 0, mapNZ = 0, lowReads = 0, pix = 0;
    always_ff @(posedge Clock) begin
        cyc <= cyc + 1;
        if (enableRam && ramAddr >= 16'h8000 && ramAddr < 16'h9800) begin
            tileW <= tileW + 1;
            if (ramIn != 0) tileNZ <= tileNZ + 1;
        end
        if (enableRam && ramAddr >= 16'h9800 && ramAddr < 16'hA000 && ramIn != 0)
            mapNZ <= mapNZ + 1;
        if (WriteEnable && WriteDataSelect == 3'b011 && ramAddr < 16'h8000)
            lowReads <= lowReads + 1;           // CPU loads from the ROM address range
        if (pValid && lcdY < 144) pix <= pix + 1;
        if (vBlankPulse) begin
            //$display("cyc=%0d PC=%h LCDC=%h BGP=%h tileW=%0d tileNZ=%0d mapNZ=%0d lowReads=%0d pix=%0d ok2a=%0d bad2a=%0d",
             //   cyc, Pc, lcdcReg, bgpReg, tileW, tileNZ, mapNZ, lowReads, pix, ok2a, bad2a);
            pix <= 0;
        end
    end

/*  logic [15:0] hp [64]; logic [7:0] ho [64]; logic [15:0] hs [64];
logic [5:0] hi = 0; int dumps = 0;
always_ff @(posedge Clock)
    if (cu.currentState == 4'd0) begin
        hp[hi] <= Pc; ho[hi] <= OpCode; hs[hi] <= sp; hi <= hi + 1;
        if (cyc > 200000 && dumps < 3 &&
            (Pc == 16'h021B || Pc == 16'h0000 || Pc == 16'h020C)) begin
            dumps <= dumps + 1;
            $display("RESTART PC=%h cyc=%0d FF80=%h FF81=%h", Pc, cyc,
                     mmu.ram.mem[16'hFF80], mmu.ram.mem[16'hFF81]);
            for (int i = 0; i < 64; i++)
                $display("  H %h %h %h", hp[6'(hi+i)], ho[6'(hi+i)], hs[6'(hi+i)]);
        end
    end
*/
/*    logic [15:0] histPc [32];
logic [7:0]  histOp [32];
logic [4:0]  histIdx = 0;
int initCount = 0;
always_ff @(posedge Clock)
    if (cu.currentState == 4'd0) begin
        histPc[histIdx] <= Pc; histOp[histIdx] <= OpCode; histIdx <= histIdx + 1;
        if (Pc == 16'h020C) begin
            initCount <= initCount + 1;
            if (initCount == 1)
                for (int i = 0; i < 32; i++)
                    $display("H PC=%h op=%h", histPc[5'(histIdx + i)], histOp[5'(histIdx + i)]);
        end
    end*/
/*logic [15:0] hp [32];
logic [7:0]  ho [32];
logic [4:0]  hi = 0;
bit dumped = 0;
always_ff @(posedge Clock) begin
    if (cu.currentState == 4'd0) begin
        hp[hi] <= Pc; ho[hi] <= OpCode; hi <= hi + 1;
    end
    if (!dumped && enableRam && ramAddr == 16'hFF40 && ramIn == 8'h1e) begin
        dumped <= 1;
        $display("LCDC<=1e at cyc=%0d PC=%h, last 32 fetches:", cyc, Pc);
        for (int i = 0; i < 32; i++)
            $display("  H %h %h", hp[5'(hi + i)], ho[5'(hi + i)]);
    end
end

logic armed = 0, chkDec;
logic [15:0] chkHl;
logic [7:0] chkF, chkA;
always_ff @(posedge Clock) begin
    if (!armed && cu.currentState == 4'd3 && (cu.opCode1 == 8'h2A || cu.opCode1 == 8'h3A)) begin
        armed  <= 1;
        chkHl  <= {rf.registers[4], rf.registers[5]};
        chkF   <= rf.registers[6];
        chkA   <= ramOut;                      // the byte about to go into A
        chkDec <= (cu.opCode1 == 8'h3A);
    end else if (armed && cu.currentState == 4'd0) begin
        armed <= 0;
        if (rf.registers[7] == chkA &&
            {rf.registers[4], rf.registers[5]} == (chkDec ? chkHl - 16'd1 : chkHl + 16'd1) &&
            rf.registers[6] == chkF)
            ok2a <= ok2a + 1;
        else begin
            bad2a <= bad2a + 1;
            if (bad2a < 10)
                $display("BAD 2A/3A after PC=%h: HL0=%h F0=%h wantA=%h  gotA=%h HL=%h F=%h",
                         Pc, chkHl, chkF, chkA, rf.registers[7],
                         {rf.registers[4], rf.registers[5]}, rf.registers[6]);
        end
    end
end*/
    // --- 2. VGA TIMING CONSTANTS (640x480 @ 60Hz) ---
    localparam H_DISPLAY = 640, H_FRONT = 16, H_SYNC = 96, H_BACK = 48, H_MAX = 800;
    localparam V_DISPLAY = 480, V_FRONT = 10, V_SYNC = 2,  V_BACK = 33, V_MAX = 525;

    logic [9:0] h_count = 0;
    logic [9:0] v_count = 0;
    // --- 3. VGA COUNTERS AND SYNC PULSES ---
    always_ff @(posedge Clock25) begin
        if (Reset) begin
            h_count <= 0;
            v_count <= 0;
        end else begin
            if (h_count == H_MAX - 1) begin
                h_count <= 0;
                if (v_count == V_MAX - 1) v_count <= 0;
                else v_count <= v_count + 1;
            end else begin
                h_count <= h_count + 1;
            end
        end
    end

    // Hsync and Vsync are active-low for 640x480
    assign Hsync = ~(h_count >= (H_DISPLAY + H_FRONT) && h_count < (H_DISPLAY + H_FRONT + H_SYNC));
    assign Vsync = ~(v_count >= (V_DISPLAY + V_FRONT) && v_count < (V_DISPLAY + V_FRONT + V_SYNC));

    // --- 4. SCREEN CENTERING & COLOR MAPPING ---
    logic display_active;
    logic gb_active;
    logic [7:0] vga_x, vga_y;

    // Active when the VGA beam is in the visible monitor area
    assign display_active = (h_count < H_DISPLAY) && (v_count < V_DISPLAY);

    // Active when the VGA beam is inside our centered 160x144 Game Boy box
    assign gb_active = (h_count >= 240 && h_count < 400) &&
                       (v_count >= 168 && v_count < 312);

    // Map the absolute monitor coordinates to the relative 0-159 / 0-143 Framebuffer coordinates
    assign vga_x = h_count[7:0] - 8'd240;
    assign vga_y = v_count[7:0] - 8'd168;

    always_comb begin
        if (!display_active) begin
            // Outside physical display (Blanking interval) - MUST be pure black
            {VgaRed, VgaGreen, VgaBlue} = 24'h000000;
        end
        else if (gb_active) begin
            // Inside the centered Game Boy screen - Read the Framebuffer
            case (frameBuffer[vga_y*160+vga_x])
                2'b00: {VgaRed, VgaGreen, VgaBlue} = 24'hFFFFFF; // White
                2'b01: {VgaRed, VgaGreen, VgaBlue} = 24'hAAAAAA; // Light Gray
                2'b10: {VgaRed, VgaGreen, VgaBlue} = 24'h555555; // Dark Gray
                2'b11: {VgaRed, VgaGreen, VgaBlue} = 24'h000000; // Black
                default: {VgaRed, VgaGreen, VgaBlue} = 24'h000000; // Black
            endcase
            //$display("buffer %d", frameBuffer[vga_y][vga_x]);
        end
        else begin
            // The border surrounding the Game Boy screen
            {VgaRed, VgaGreen, VgaBlue} = 24'h222222; // Dark Charcoal Border
        end
    end

    always_comb begin
        case(WriteDataSelect)
            3'b000: rfWriteIn = AluOut;      // arithmetic/logic
            3'b001: rfWriteIn = cuDataOut;   // immediate load
            3'b010: rfWriteIn = AluIn1;      // register-to-register load
            3'b011: rfWriteIn = ramOut;      // loading from ram
            3'b100: rfWriteIn = shiftOut;
            3'b101: rfWriteIn = rfOut2;
            3'b110: rfWriteIn = bitManipulatorDataOut;
            3'b111: rfWriteIn = AluIn1;
            default: rfWriteIn= 8'h00;
        endcase

        case(WriteDataSelect)
            3'b000: regFlagsIn = aluRegFlagsOut;
            3'b001: regFlagsIn = regFlagsOut;
            3'b100: regFlagsIn = shiftFlagsOut;
            3'b110: regFlagsIn = bitManipulatorFlagsOut;
            3'b111: regFlagsIn = spAddedFlags;
            default: regFlagsIn = regFlagsOut;
        endcase

        case(jump)
            3'b000: PcNext = Pc+IncrementPc;
            3'b001: PcNext = Pc+extendedCuOut;
            3'b010: PcNext = wideRegOut;
            3'b011: PcNext = wideCuOut;
            3'b100: PcNext = {ramOut, 8'h00};
            3'b101: PcNext = {Pc[15:8], ramOut};
            default: PcNext = Pc;
        endcase

        case(aluInputControl)
            1'b0: AluIn2 = rfOut2;
            1'b1: AluIn2 = cuDataOut;
            default: AluIn2 = cuDataOut;
        endcase

        case(ramInSelect)
            2'b00: ramIn = rfOut2;
            2'b01: ramIn = Pc[7:0];
            2'b10: ramIn = Pc[15:8];
            default: ramIn = 8'h00;
        endcase

        if(highMemInputSelect) highMemWriteIn = cuDataOut;
        else highMemWriteIn = AluIn1;

        if(spOpp) tempSpOpp = 16'hFFFF;
        else tempSpOpp = 16'b1;

        if(~useConditional||condJump) spPostCond = sp + tempSpOpp;
        else spPostCond = sp;

        //if(AluIn1Crtl) AluInput = sp;
        //else AluInput = AluIn1;

        case(loadSp)
            3'b000: spNext = wideCuOut;
            3'b001: spNext = spPostCond;
            3'b010: spNext = sp;
            3'b011: spNext = wideRegOut;
            3'b100: spNext = spAdded;
            default: spNext = sp;
        endcase
        case(highMem)
            2'b00: muxedRamAddr = wideRegOut;
            2'b01: muxedRamAddr = summedWriteHigh;
            2'b10: muxedRamAddr = wideCuOut;
            default: muxedRamAddr = wideCuOut;
        endcase

        if(enableSp) ramAddr = sp;
        else ramAddr = muxedRamAddr;

        if(wideInCrtl) wideRegLoad = spAdded;
        else wideRegLoad = wideCuOut;

        if(wideAluInCtrl1) wideAluIn1 = wideRegOut;
        else wideAluIn1 = sp;

        if(wideAluInCtrl2) wideAluIn2 = wideRegOut2;
        else wideAluIn2 = {{8{cuDataOut[7]}}, cuDataOut};

    end
endmodule

