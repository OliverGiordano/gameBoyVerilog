module ControlUnit (
        input logic [7:0] OpCode,
        input logic Clock,
        input logic Reset,
        input logic [7:0] IFin, IEin,
        output logic IncrementPc, We, UseConditional, NoCarry, AluInputControl, RamWe, WideWrite,
                     WideRead, ForceZero, SpEnable, HighMemSelect, SpOpp, WideInCrtl,
                     WideAluControl, WideAluInCrtl1, WideAluInCrtl2, ClearIF,
        output logic [2:0] WriteSelect, ShiftMode,
        output logic [2:0] Reg1, Reg2, Reg3,
        output logic [3:0] AluOp,
        output logic [7:0] WriteData,
        output logic [1:0] ConditionSelect, HighMem, RamInSelect,
        output logic [2:0] Jump, LoadSp,
        output logic [15:0] WideCuOut
    );
    // Interesting: the stack pointer points to two bytes, (16 bits) this
    // means we /
    typedef enum logic [3:0]{
        FETCH_OPCODE, FETCH_BYTE2, FETCH_BYTE3, EXECUTE, HALT, POPBYTE1, PUSHBYTE1,
        DEINCREMENTSP
    } control_state_t;
    logic [7:0] opCode1, opCode2, opCode3;

    logic Ime;
    logic ImeReEnable;

    control_state_t currentState;

    always_ff @(posedge Clock, posedge Reset) begin
        if(Reset) begin
            currentState <= FETCH_OPCODE;
            IncrementPc <= 1;
            ImeReEnable <= 0;
            Ime <= 0;
            ClearIF <= 0;
        end else begin
            ClearIF <= 0;
            if(currentState == POPBYTE1 || currentState == PUSHBYTE1) begin
                IncrementPc <= 0;
                currentState <= EXECUTE;
            end else if (currentState == DEINCREMENTSP) begin
                IncrementPc <= 0;
                currentState <= PUSHBYTE1;
            end else if(currentState == FETCH_OPCODE) begin
                casez (OpCode)
                    8'h00: begin
                        opCode1 <= OpCode;
                        IncrementPc <= 0;
                        currentState <= EXECUTE; end
                    8'hF3: begin
                        opCode1 <= OpCode;
                        IncrementPc <= 0;
                        Ime <= 0;
                        currentState <= EXECUTE; end
                    8'hFB: begin
                        opCode1 <= OpCode;
                        IncrementPc <= 0;
                        currentState <= EXECUTE; end
                    /*8'hCB: begin
                        opCode1 <= OpCode;
                        IncrementPc <= 1;
                        currentState <= FETCH_BYTE2; end*/
                    8'h07: begin
                        opCode1 <= OpCode;
                        IncrementPc <= 0;
                        currentState <= EXECUTE; end
                    8'hC9, 8'hD9: begin
                        opCode1 <= OpCode;
                        IncrementPc <= 0;
                        currentState <= POPBYTE1; end
                    8'hF9: begin
                        opCode1 <= OpCode;
                        IncrementPc <= 0;
                        currentState <= EXECUTE; end
                    8'hE8: begin
                        opCode1 <= OpCode;
                        IncrementPc <= 1;
                        currentState <= FETCH_BYTE2; end
                    /*8'h31: begin
                        opCode1 <= OpCode;
                        IncrementPc <= 1;
                        currentState <= FETCH_BYTE2; end*/
                    8'b00??1001, 8'b00??1011, 8'b00??0011: begin
                        opCode1 <= OpCode;
                        IncrementPc <= 0;
                        currentState <= EXECUTE; end
                    8'b110??000: begin
                        opCode1 <= OpCode;
                        IncrementPc <= 0;
                        currentState <= POPBYTE1; end
                    8'b001??111: begin
                        opCode1 <= OpCode;
                        IncrementPc <= 0;
                        currentState <= EXECUTE; end
                    8'h0F: begin
                        opCode1 <= OpCode;
                        IncrementPc <= 0;
                        currentState <= EXECUTE; end
                    8'h17: begin
                        opCode1 <= OpCode;
                        IncrementPc <= 0;
                        currentState <= EXECUTE; end
                    8'h1F: begin
                        opCode1 <= OpCode;
                        IncrementPc <= 0;
                        currentState <= EXECUTE; end
                    8'hE9: begin
                        opCode1 <= OpCode;
                        IncrementPc <= 0;
                        currentState <= EXECUTE; end
                    8'hF8: begin
                        opCode1 <= OpCode;
                        IncrementPc <= 1;
                        currentState <= FETCH_BYTE2; end
                    8'b11100010: begin //  quick loads to ram
                        opCode1 <= OpCode;
                        IncrementPc <= 0;
                        currentState <= EXECUTE; end
                    8'b11100000: begin
                        opCode1 <= OpCode;
                        IncrementPc <= 1;
                        currentState <= FETCH_BYTE2; end
                    8'b11101010: begin
                        opCode1 <= OpCode;
                        IncrementPc <= 1;
                        currentState <= FETCH_BYTE2; end
                    8'b11110010: begin
                        opCode1 <= OpCode;
                        IncrementPc <= 0;
                        currentState <= EXECUTE; end
                    8'b11110000: begin
                        opCode1 <= OpCode;
                        IncrementPc <= 1;
                        currentState <= FETCH_BYTE2; end
                    8'b11111010: begin
                        opCode1 <= OpCode;
                        IncrementPc <= 1;
                        currentState <= FETCH_BYTE2; end
                    8'b11000011: begin
                        opCode1 <= OpCode;
                        IncrementPc <= 1;
                        currentState <= FETCH_BYTE2; end
                    8'b11101011: begin
                        opCode1 <= OpCode;
                        IncrementPc <= 0;
                        currentState <= EXECUTE; end
                    8'b11001011: begin
                        opCode1 <= OpCode;
                        currentState <= FETCH_BYTE2;
                        IncrementPc <= 1; end
                    8'hCD: begin // call imm16
                        opCode1 <= OpCode;
                        currentState <= FETCH_BYTE2;
                        IncrementPc <= 1; end
                    8'b110??100: begin
                        opCode1 <= OpCode;
                        currentState <= FETCH_BYTE2;
                        IncrementPc <= 1; end
                    8'b00??0010, 8'b00??1010: begin
                        opCode1 <= OpCode;
                        IncrementPc <= 0;
                        currentState <= EXECUTE; end
                    8'hC7, 8'hCF, 8'hD7, 8'hDF, 8'hE7, 8'hEF, 8'hF7, 8'hFF: begin
                        opCode1 <= OpCode;
                        currentState <= DEINCREMENTSP;
                        IncrementPc <= 0; end
                    8'b11??0?01: begin // stack ops
                        opCode1 <= OpCode;
                        if(OpCode[2] == 0)currentState <= POPBYTE1;
                        else currentState <= DEINCREMENTSP;
                        IncrementPc <= 0; end
                    8'b00???10?: begin // increment/deincrement
                        opCode1 <= OpCode;
                        currentState <= EXECUTE;
                        IncrementPc <= 0; end
                    8'b01??????: begin // register to register
                        if(OpCode == 8'h76) currentState <= HALT;
                        else currentState <= EXECUTE;
                        opCode1 <= OpCode;
                        //currentState <= EXECUTE;
                        IncrementPc <= 0; end
                    8'b00???110: begin // load immediate
                        opCode1 <= OpCode;
                        currentState <= FETCH_BYTE2;
                        IncrementPc <= 1; end
                    8'b110??010: begin // jump cond imm16
                        opCode1 <= OpCode;
                        currentState <= FETCH_BYTE2;
                        IncrementPc <= 1; end
                    8'b00??0001: begin
                        opCode1 <= OpCode;
                        currentState <= FETCH_BYTE2;
                        IncrementPc <= 1; end
                    8'b10??????: begin // alu opp
                        opCode1 <= OpCode;
                        currentState <= EXECUTE;
                        IncrementPc <= 0; end
                    8'b00011000: begin // Jumps!
                        opCode1 <= OpCode;
                        currentState <= FETCH_BYTE2;
                        IncrementPc <= 1; end
                    8'b001??000: begin // Jumps with conditions
                        opCode1 <= OpCode;
                        currentState <= FETCH_BYTE2;
                        IncrementPc <= 1; end
                    8'b11???110: begin // math with immediates
                        opCode1 <= OpCode;
                        currentState <= FETCH_BYTE2;
                        IncrementPc <= 1; end
                    default: begin
                        $display("unimplemented %h", OpCode);
                        IncrementPc <= 1;
                        currentState <= FETCH_BYTE3; end
                endcase
            end else if(currentState == FETCH_BYTE2) begin
                casez(opCode1)
                    8'b00??0001: begin
                        opCode2 <= OpCode;
                        IncrementPc <= 1;
                        currentState <= FETCH_BYTE3; end
                    8'b11000011: begin
                        opCode2 <= OpCode;
                        IncrementPc <= 1;
                        currentState <= FETCH_BYTE3; end
                    8'b110??010: begin
                        opCode2 <= OpCode;
                        IncrementPc <= 1;
                        currentState <= FETCH_BYTE3; end
                    /*8'h31: begin
                        opCode2 <= OpCode;
                        IncrementPc <= 1;
                        currentState <= FETCH_BYTE3; end*/
                    8'b11101010: begin
                        opCode2 <= OpCode;
                        IncrementPc <= 1;
                        currentState <= FETCH_BYTE3; end
                    8'b11111010: begin
                        opCode2 <= OpCode;
                        IncrementPc <= 1;
                        currentState <= FETCH_BYTE3; end
                    8'hCD: begin // call imm16
                        opCode2 <= OpCode;
                        currentState <= FETCH_BYTE3;
                        IncrementPc <= 1; end
                    8'b110??100: begin // call imm16
                        opCode2 <= OpCode;
                        currentState <= FETCH_BYTE3;
                        IncrementPc <= 1; end
                    default: begin
                        opCode2 <= OpCode;
                        IncrementPc <= 0;
                        currentState <= EXECUTE; end
                endcase
            end else if(currentState == FETCH_BYTE3) begin
                casez(opCode1)
                    8'hCD: begin
                        opCode3 <= OpCode;
                        IncrementPc <= 0;
                        currentState <= DEINCREMENTSP; end
                    8'b110??100: begin
                        opCode3 <= OpCode;
                        IncrementPc <= 0;
                        currentState <= DEINCREMENTSP; end
                    default: begin
                        opCode3 <= OpCode;
                        IncrementPc <= 0;
                        currentState <= EXECUTE; end
                endcase
            end else if(currentState == HALT) begin
                IncrementPc <= 0;
                if(ImeReEnable == 1) begin
                    Ime <= 1;
                    ImeReEnable <= 0;
                end
                if((IEin & IFin) != 8'h00) currentState <= FETCH_OPCODE;
                else currentState <= HALT;
            end else begin // Execute
                if (ImeReEnable == 1) begin
                    Ime <= 1;
                    ImeReEnable <= 0;
                end
                if (opCode1 == 8'hFB) ImeReEnable <= 1;

                if (opCode1 == 8'h2A || opCode1 == 8'h3A) begin
                    opCode1 <= (opCode1 == 8'h2A) ? 8'h23 : 8'h2B;   // INC HL / DEC HL
                    IncrementPc <= 0;
                    currentState <= EXECUTE;                          // run EXECUTE once more
                end else if ((Ime || ImeReEnable) && (IEin & IFin) != 8'h00) begin
                    opCode1 <= 8'hCD;
                    opCode3 <= 8'h00;
                    IncrementPc <= 0;
                    currentState <= DEINCREMENTSP;
                    Ime <= 0;
                    ClearIF <= 1;
                    if      (IFin[0]) opCode2 <= 8'h40;
                    else if (IFin[1]) opCode2 <= 8'h48;
                    else if (IFin[2]) opCode2 <= 8'h50;
                    else if (IFin[3]) opCode2 <= 8'h58;
                    else if (IFin[4]) opCode2 <= 8'h60;
                end else begin
                    if (opCode1 == 8'hD9) Ime <= 1;
                    IncrementPc <= 1;
                    currentState <= FETCH_OPCODE;
                end
            end
        end
    end


    // IncrementInstr is poorly named, what it really means is are we loading
    // an immediate straight into the alu
    always_comb begin
        WideInCrtl = 0;
        WideAluControl = 0;
        WideAluInCrtl1 = 0;
        HighMem = 0;
        WideAluInCrtl2 = 0;
        WriteSelect = 0;
        Reg1 = 0;
        Reg2 = 0;
        Reg3 = 0;
        SpOpp = 0;
        SpEnable = 0;
        Jump = 0;
        We = 0;
        RamWe = 0;
        WideRead = 0;
        WideWrite = 0;
        RamInSelect = 0;
        ConditionSelect = 0;
        UseConditional = 0;
        LoadSp = 0;
        WideCuOut = 0;
        NoCarry = 0;
        ForceZero = 0;
        WriteData = 0;
        AluInputControl = 0;
        AluOp = 0;
        HighMemSelect = 0;
        ShiftMode = 0;
        if(currentState == POPBYTE1) begin
            RamWe = 0;
            WriteSelect = 3'b011;
            //Reg3 = 2*opCode1[5:4]+1;
            Reg3 = 2*opCode1[5:4];
            //WideCuOut = 16'b1;
            SpOpp = 0;
            SpEnable = 1;
            We = (opCode1[3:0] == 4'b0001);
            //We = 1;
            WideRead = 0;
            WideWrite = 0;
            RamInSelect = 0;
            ConditionSelect = opCode1[4:3];
            if(opCode1 == 8'hC9 || opCode1 == 8'hD9) begin
                Jump = 3'b100;
                UseConditional = 0; end
            else if(opCode1[7:5] == 3'b110 && opCode1[2:0] == 3'b000) begin
                Jump = 3'b100;
                UseConditional = 1; end
            else begin
                Jump = 3'b000;
                UseConditional = 0; end
            LoadSp = 3'b001;
            RamInSelect = 2'b00;
        end else if(currentState == PUSHBYTE1) begin
            RamWe = 1;
            Reg2 = 2*opCode1[5:4]+1;
            casez(opCode1)
                8'b11???111, 8'hCD, 8'b110??100 : begin
                    RamInSelect = 2'b01; end
                default: begin
                    RamInSelect = 2'b00; end
            endcase
            //WideCuOut = 16'b1111111111111111;
            SpOpp = 1;
            We = 0;
            WideRead = 0;
            WideWrite = 0;
            ConditionSelect = opCode1[4:3];
            if(opCode1[7:5] == 3'b110 && opCode1[2:0] == 3'b100) begin
                UseConditional = 1;
                SpEnable = 1; end
            else begin
                UseConditional = 0;
                SpEnable = 1; end
            Jump = 3'b000;
            LoadSp = 3'b001;
        end else if (currentState == DEINCREMENTSP) begin
            RamWe = 0;
            if(opCode1[7:5] == 3'b110 && opCode1[2:0] == 3'b100) begin
                UseConditional = 1;
                ConditionSelect = opCode1[4:3];
                SpEnable = 1;
            end else begin
                UseConditional = 0;
                SpEnable = 1;
            end
            We = 0;
            SpOpp = 1; //subtract
            LoadSp = 3'b001;
        end else if(currentState == EXECUTE) begin
            casez (opCode1)
                8'hF3, 8'hFB: begin
                    We = 0;
                    RamWe = 0;
                    Jump = 3'b000;
                    UseConditional = 0; end
                /*8'hCB: begin
                    We = 1;
                    RamWe = 0;
                    Jump = '0;
                    WideRead = 0;
                    ForceZero = 0;
                    SpEnable = 0;
                    UseConditional = 0;
                    Reg1 = opCode2[2:0];
                    Reg3 = opCode2[2:0];
                    WriteSelect = 3'b110;
                    WriteData = opCode2; end*/
                8'b001??111: begin
                    AluInputControl = 0;
                    WriteSelect = 0;
                    We = 1;
                    Reg1 = 3'b111;
                    Reg3 = 3'b111;
                    AluOp = {2'b10, opCode1[4:3]};
                    RamWe = 0;
                    Jump = 3'b000;
                    WideRead = 0;
                    ForceZero = 0;
                    SpEnable = 0;
                    WideWrite = 0;
                    LoadSp = 3'b001;
                    RamInSelect = 0;
                    UseConditional = 0; end
                8'b110??000: begin
                    AluInputControl = 0;
                    WriteSelect = 0;
                    We = 0;
                    RamWe = 0;
                    WideRead = 0;
                    ForceZero = 0;
                    SpEnable = 1;
                    WideWrite = 0;
                    LoadSp = 3'b001;
                    Jump = 3'b101;
                    ConditionSelect = opCode1[4:3];
                    UseConditional = 1; end
                8'b00??0011: begin
                    WideAluInCrtl1 = 1;
                    WriteData = 8'h01;
                    WideWrite = 1;
                    WideRead = 1;
                    WideInCrtl = 1;
                    Reg1 = {1'b0, opCode1[5:4]};
                    Reg3 = {1'b0, opCode1[5:4]};
                    We = 1;
                    WriteSelect = 3'b001;
                    Jump = 0;
                    UseConditional = 0;
                    RamWe = 0;
                    WideAluControl = 0;
                end
                8'b00??0010: begin // LD (rr),A
                    RamWe = 1;
                    Reg1 = (opCode1[5]) ? 3'b010 : {2'b00, opCode1[4]}; // BC, DE, or HL
                    Reg2 = 3'b111;                                       // A
                    WideRead = 1;
                    HighMem = 2'b00;                                     // ram addr = wideRegOut
                    WriteSelect = 3'b001;
                    if (opCode1[5]) begin                                // HL+ / HL-
                        WideWrite = 1; We = 1;
                        Reg3 = 3'b010;
                        WideInCrtl = 1; WideAluInCrtl1 = 1; WideAluInCrtl2 = 0;
                        WideAluControl = 0;
                        WriteSelect = 3'b001;
                        WriteData = opCode1[4] ? 8'hFF : 8'h01;          // 0x32 = HL-, 0x22 = HL+
                    end else begin
                        WideWrite = 0; We = 0;
                    end
                    SpEnable = 0; LoadSp = 3'b010; Jump = 3'b000;
                    UseConditional = 0; RamInSelect = 2'b00;
                end
                8'b00??1010: begin // LD A,(rr)
                    RamWe = 0;
                    Reg1 = (opCode1[5]) ? 3'b010 : {2'b00, opCode1[4]};  // BC, DE, or HL
                    WideRead = 1;
                    HighMem = 2'b00;
                    Reg3 = 3'b111;          // A
                    WriteSelect = 3'b011;   // data from ramOut
                    We = 1;
                    WideWrite = 0;          // see note: HL+/HL- not handled yet
                    SpEnable = 0; LoadSp = 3'b010; Jump = 3'b000;
                    UseConditional = 0; RamInSelect = 2'b00;
                end
                8'b00??1011: begin
                    WideAluInCrtl1 = 1;
                    WriteData = 8'hFF;
                    WideWrite = 1;
                    WideRead = 1;
                    WideInCrtl = 1;
                    Reg1 = {1'b0, opCode1[5:4]};
                    Reg3 = {1'b0, opCode1[5:4]};
                    We = 1;
                    WriteSelect = 3'b001;
                    Jump = 0;
                    UseConditional = 0;
                    RamWe = 0;
                    WideAluControl = 0;
                end
                8'b00??1001: begin
                    WideAluInCrtl1 = 1;
                    WideAluInCrtl2 = 1;
                    WriteData = 8'hFF;
                    WideWrite = 1;
                    WideRead = 1;
                    WideInCrtl = 1;
                    if(opCode1[5:4] == 2'b11) WideAluInCrtl1 = 0;
                    else Reg1 = {1'b0, opCode1[5:4]};
                    Reg3 = 3'b010;
                    We = 1;
                    WriteSelect = 3'b111;
                    Jump = 0;
                    UseConditional = 0;
                    RamWe = 0;
                    WideAluControl = 1;
                end
                8'hC9, 8'hD9: begin
                    AluInputControl = 0;
                    WriteSelect = 0;
                    We = 0;
                    RamWe = 0;
                    WideRead = 0;
                    ForceZero = 0;
                    SpEnable = 1;
                    WideWrite = 0;
                    LoadSp = 3'b001;
                    Jump = 3'b101;
                    UseConditional = 0; end
                8'h00: begin //No op
                    AluInputControl = 1'b0;
                    WriteSelect = 0;
                    We = 0;
                    RamWe = 0;
                    Jump = 3'b000;
                    WideWrite = 0;
                    WideRead = 0;
                    ForceZero = 0;
             //       SpEnable = 0;
                    LoadSp = 3'b010;
                    RamInSelect = 0;
                    UseConditional = 0; end
                8'b11101001: begin // Jump hl
                    RamWe = 0;
                    WideWrite = 0;
                    WideRead = 1;
                    Jump = 3'b010;
                    Reg1 = 3'b010;
                    We = 0;
                    LoadSp = 3'b010;
                    SpEnable = 0;
                    RamInSelect = 0;
                    UseConditional = 0; end
                8'b11000011: begin
                    RamWe = 0;
                    WideWrite = 0;
                    WideRead = 0;
                    Jump = 3'b011;
                    We = 0;
                    LoadSp = 3'b010;
                    SpEnable = 0;
                    UseConditional = 0;
                    RamInSelect = 0;
                    WideCuOut = {opCode3, opCode2}; end
                8'h07: begin // rlca
                    RamWe = 0;
                    Reg1 = 3'b111;
                    Reg3 = 3'b111;
                    ShiftMode = 3'b000;
                    WideWrite = 0;
                    We = 1;
                    ForceZero = 0;
                    LoadSp = 3'b010;
                    UseConditional = 0;
                    Jump = 3'b000;
                    SpEnable = 0;
                    RamInSelect = 0;
                    WriteSelect = 3'b100; end
                8'h0F: begin //rrca
                    RamWe = 0;
                    Reg1 = 3'b111;
                    Reg3 = 3'b111;
                    ShiftMode = 3'b001;
                    WideWrite = 0;
                    We = 1;
                    ForceZero = 0;
                    LoadSp = 3'b010;
                    UseConditional = 0;
                    Jump = 3'b000;
                    SpEnable = 0;
                    RamInSelect = 0;
                    WriteSelect = 3'b100; end
                8'h17: begin //rla
                    RamWe = 0;
                    Reg1 = 3'b111;
                    Reg3 = 3'b111;
                    ShiftMode = 3'b010;
                    WideWrite = 0;
                    We = 1;
                    ForceZero = 0;
                    UseConditional = 0;
                    Jump = 3'b000;
                    SpEnable = 0;
                    LoadSp = 3'b010;
                    RamInSelect = 0;
                    WriteSelect = 3'b100; end
                8'h1F: begin //rra
                    RamWe = 0;
                    Reg1 = 3'b111;
                    Reg3 = 3'b111;
                    ShiftMode = 3'b011;
                    WideWrite = 0;
                    We = 1;
                    ForceZero = 0;
                    LoadSp = 3'b010;
                    UseConditional = 0;
                    Jump = 3'b000;
                    SpEnable = 0;
                    RamInSelect = 0;
                    WriteSelect = 3'b100; end
                8'hF9: begin
                    RamWe = 0;
                    LoadSp = 3'b011;
                    Reg1 = 3'b010;
                    SpEnable = 1;
                    WideRead = 1;
                    UseConditional = 0;
                    Jump = 3'b000;
                    RamInSelect = 0;
                    WriteSelect = 3'b000; end
                8'hE8: begin
                    RamWe = 0;
                    Reg1 = 3'b111;
                    Reg3 = 3'b111;
                    WriteSelect = 3'b111;
                    AluInputControl = 1;
                    We = 1;
                    Jump = 3'b000;
                    UseConditional = 0;
                    LoadSp = 3'b100;
                    WriteData = opCode2;
                    SpEnable = 1; end
                8'hF8: begin
                    RamWe = 0;
                    Reg3 = 3'b010;
                    WriteSelect = 3'b111;
                    We = 1;
                    Jump = 3'b000;
                    UseConditional = 0;
                    SpEnable = 0;
                    WideWrite = 1;
                    WriteData = opCode2;
                    WideInCrtl = 1; end
                8'b11001011: begin // shifts
                    if(opCode1 == 8'hCB) begin
                        We = 1;
                        RamWe = 0;
                        Jump = '0;
                        WideRead = 0;
                        ForceZero = 0;
                        SpEnable = 0;
                        UseConditional = 0;
                        Reg1 = opCode2[2:0];
                        Reg3 = opCode2[2:0];
                        WriteSelect = 3'b110;
                        WriteData = opCode2; end
                    else begin
                        RamWe = 0;
                        Reg1 = opCode2[2:0];
                        Reg3 = opCode2[2:0];
                        ShiftMode = opCode2[5:3];
                        WideWrite = 0;
                        We = 1;
                        ForceZero = 0;
                        LoadSp = 3'b010;
                        UseConditional = 0;
                        Jump = 3'b000;
                        SpEnable = 0;
                        RamInSelect = 0;
                        WriteSelect = 3'b100; end
                    end
                8'b11100010: begin // loading to special ram
                    Reg1 = 3'b001; // C  // 1 byte
                    Reg2 = 3'b111; // accumulator
                    RamWe = 1;
                    We = 0;
                    UseConditional = 0;
                    Jump = 3'b000;
                    SpEnable = 0;
                    //WriteSelect = 3'b011;
                    LoadSp = 3'b010;
                    HighMemSelect = 0;
                    RamInSelect = 0;
                    HighMem = 2'b01; end
                8'b11100000: begin
                    HighMemSelect = 1;
                    Reg2 = 3'b111;
                    WriteData = opCode2;
                    HighMemSelect = 1;
                    HighMem = 2'b01;
                    RamWe = 1;
                    Jump = 3'b000;
                    UseConditional = 0;
                    SpEnable = 0;
                    LoadSp = 3'b010;
                    RamInSelect = 0;
                    We = 0; end
                8'b11101010: begin
                    HighMem = 2'b10;
                    Reg2 = 3'b111;
                    RamWe = 1;
                    Jump = 3'b000;
                    UseConditional = 0;
                    SpEnable = 0;
                    LoadSp = 3'b010;
                    We = 0;
                    RamInSelect = 0;
                    WideCuOut = {opCode3, opCode2}; end
                8'b11110010: begin
                    HighMem = 2'b01;
                    HighMemSelect = 0;
                    Reg1 = 3'b001;
                    Reg3 = 3'b111;
                    RamWe = 0;
                    We = 1;
                    UseConditional = 0;
                    Jump = 3'b000;
                    WriteSelect = 3'b011;
                    RamInSelect = 0;
                    LoadSp = 3'b010;
                    SpEnable = 0; end
                8'b11110000: begin
                    HighMemSelect = 1;
                    HighMem = 2'b01;
                    Reg3 = 3'b111;
                    RamWe = 0;
                    Jump = 3'b000;
                    UseConditional = 0;
                    LoadSp = 3'b010;
                    SpEnable = 0;
                    We = 1;
                    WriteData = opCode2;
                    RamInSelect = 0;
                    WriteSelect = 3'b011; end
                8'b11111010: begin
                    HighMem = 2'b10;
                    Reg3 = 3'b111;
                    RamWe = 0;
                    Jump = 3'b000;
                    UseConditional = 0;
                    SpEnable = 0;
                    We = 1;
                    WideCuOut = {opCode3, opCode2};
                    RamInSelect = 0;
                    WriteSelect = 3'b011; end
                8'b11??0?01: begin // push / pop from stack
                    SpEnable = 1;
                    UseConditional = 0;
                    if(opCode1[2] == 0) begin // pop
                        RamWe = 0;
                        //Reg3 = 2*opCode1[5:4];
                        Reg3 = 2*opCode1[5:4]+1;
                        WriteSelect = 3'b011;
                        SpOpp = 0;
                        //WideCuOut = 16'b1;
                        //SpEnable = 1;
                        LoadSp = 3'b001;
                        We = 1; end
                    else begin // push
                        RamWe = 1;
                        Reg2 = 2*opCode1[5:4];
                        //WideCuOut = 16'b0;
                        LoadSp = 3'b010;
                        //SpEnable = 0;
                        We = 0; end
                    RamInSelect = 0;
                    WideRead = 0;
                    WideWrite = 0;
                    Jump = 3'b000; end
                8'hCD: begin //load sp
                    RamWe = 1;
                    //WriteData = opCode3;
                    RamInSelect = 2'b10;
                    LoadSp = 3'b010;
                    //WideCuOut = 16'b1111111111111111;
                    SpOpp = 1;
                    SpEnable = 1;
                    We = 0;
                    WideRead = 0;
                    WideWrite = 0;
                    WideCuOut = {opCode3, opCode2};
                    UseConditional = 0;
                    Jump = 3'b011; end
                8'b110??100: begin // jump cond
                    RamWe = 1;
                    RamInSelect = 2'b10;
                    //WideCuOut = 16'b1111111111111111;
                    LoadSp = 3'b001;
                    SpOpp = 1;
                    SpEnable = 1;
                    We = 0;
                    WideRead = 0;
                    WideWrite = 0;
                    WideCuOut = {opCode3, opCode2};
                    UseConditional = 1;
                    ConditionSelect = opCode1[4:3];
                    Jump = 3'b011; end
                8'b11???111: begin
                    RamWe = 1;
                    RamInSelect = 2'b10;
                    //WideCuOut = 16'b1111111111111111;
                    SpOpp = 1;
                    LoadSp = 3'b010;
                    SpEnable = 1;
                    We = 0;
                    WideRead = 0;
                    WideWrite = 0;
                    WideCuOut = {10'b0, {opCode1[5:3], 3'b000}};
                    //WriteData = {2'b00, {opCode1[5:3], 3'b000}};
                    UseConditional = 0;
                    ConditionSelect = opCode1[4:3];
                    Jump = 3'b011; end
                8'b110??010: begin // jp cond imm16
                    RamWe = 0;
                    We = 0;
                    WideWrite = 1;
                    ForceZero = 0;
                    Jump = 3'b011; // -> this is a jump but I keep it shut off so we let the
                                  // conditional jump
                    UseConditional = 1;
                    SpEnable = 0;
                    LoadSp = 3'b000;
                    ConditionSelect = opCode1[4:3];
                    RamInSelect = 0;
                    WideCuOut = {opCode3, opCode2}; end
                8'b01??????: begin // register to register Loads
                    SpEnable = 0;
                    LoadSp = 0;
                    RamInSelect = 0;
                    if(opCode1 == 8'h76) begin // halt
                        We = 1;
                        ForceZero = 0;
                        LoadSp = 3'b010;
                        RamInSelect = 0;
                        RamWe = 0;
                        SpEnable = 0;
                    end else if (opCode1[5:3] == 3'b110) begin //Write to ram
                        RamWe = 1;
                        Reg1 = 3'b010; // HL // location to write too
                        Reg2 = opCode1[2:0]; // what we are writing
                        WideRead = 1;
                        WideWrite = 0;
                        We = 0;
                        ForceZero = 0;
                        UseConditional = 0;
                        Jump = 3'b000;
                    end else if (opCode1[2:0] == 3'b110) begin
                        RamWe = 0;
                        Reg1 = 3'b010;
                        Reg3 = opCode1[5:3];
                        WideWrite = 0;
                        WideRead = 1;
                        We = 1;
                        ForceZero = 0;
                        UseConditional = 0;
                        Jump = 3'b000;
                        WriteSelect = 3'b011;
                    end else begin
                        RamWe = 0;
                        WideWrite = 0;
                        WideRead = 0;
                        Reg3 = opCode1[5:3];
                        Reg2 = 3'b0;
                        Reg1 = opCode1[2:0];
                        We = 1;
                        RamWe = 0;
                        ForceZero = 0;
                        AluInputControl = 0;
                        UseConditional = 0;
                        Jump = 3'b000;
                        NoCarry = 0;
                        WriteSelect = 3'b010;
                    end
                end
                8'b00???110: begin // imediate loads
                    Reg3 = opCode1[5:3];
                    WriteData = opCode2;
                    AluInputControl = 0;
                    We = 1;
                    SpEnable = 0;
                    RamWe = 0;
                    LoadSp = 0;
                    Jump = 3'b000;
                    NoCarry = 0;
                    WideWrite = 0;
                    WideRead = 0;
                    ForceZero = 0;
                    UseConditional = 0;
                    RamInSelect = 0;
                    WriteSelect = 3'b001;
                end
                8'b00??0001: begin  // write imm16
                    if(opCode1 == 8'h31) begin
                        RamWe = 0;
                        We = 0;
                        LoadSp = 3'b000;
                        SpEnable = 1;
                        Jump = 3'b000;
                        UseConditional = 0;
                        RamInSelect = 0;
                        WideCuOut = {opCode3, opCode2};
                    end else begin
                        WideWrite = 1;
                        WriteSelect = 3'b000;
                        WideRead = 0;
                        RamWe = 0;
                        Jump = 3'b000;
                        We = 1;
                        SpEnable = 0;
                        LoadSp = 0;
                        ForceZero = 0;
                        UseConditional = 0;
                        Reg3 = {1'b0, opCode1[5:4]};
                        RamInSelect = 0;
                        WideCuOut = {opCode3, opCode2};
                    end
                end
                8'b10??????: begin // alu math
                    WriteSelect = 3'b000; ///
                    We = 1;
                    RamWe = 0;
                    NoCarry = 0;
                    Jump = 3'b000;
                    WideWrite = 0;
                    WideRead = 0;
                    ForceZero = 0;
                    SpEnable = 0;
                    LoadSp = 0;
                    AluInputControl = 0;
                    UseConditional = 0;
                    AluOp = {1'b0, opCode1[5:3]};
                    Reg1 = opCode1[2:0];
                    Reg2 = 3'b111;
                    Reg3 = 3'b111; // 110 is the accumulator
                    RamInSelect = 0;
                end
                8'b00???10?: begin
                    WriteSelect = 3'b000;
                    We = 1;
                    RamWe = 0;
                    Jump = 3'b000;
                    NoCarry = 1;
                    WideWrite = 0;
                    WideRead = 0;
                    ForceZero = 0;
                    SpEnable = 0;
                    LoadSp = 0;
                    AluInputControl = 1;
                    UseConditional = 0;
                    AluOp = (opCode1[0]) ? 4'b0010 : 4'b0000;
                    WriteData = 8'b00000001;
                    RamInSelect = 0;
                    Reg1 = opCode1[5:3];
                    Reg3 = opCode1[5:3]; end
                8'b00011000: begin // Unconditional Jump
                    //WriteSelect = 2'bxx // I dont care bc Im not writing
                    We = 0;
                    RamWe = 0;
                    Jump = 3'b001;
                    AluInputControl = 0;
                    WideWrite = 0;
                    WideRead = 0;
                    ForceZero = 0;
                    LoadSp = 0;
                    //AluOp = 3'bxxx
                    //WriteData = 8'b1;
                    SpEnable = 0;
                    NoCarry = 0;
                    RamInSelect = 0;
                    UseConditional = 0;
                    WriteData = opCode2; end
                8'b001??000: begin // Conditional Jump
                    We = 0;
                    RamWe = 0;
                    Jump = 3'b001; // we tie jump
                    NoCarry = 0;
                    WideWrite = 0;
                    WideRead = 0;
                    ForceZero = 0;
                    SpEnable = 0;
                    LoadSp = 0;
                    ConditionSelect = opCode1[4:3];
                    UseConditional = 1;
                    AluInputControl = 0;
                    WriteData = opCode2; end
                8'b11???110: begin // alu math with immediates
                    NoCarry = 0;
                    We = 1;
                    RamWe = 0;
                    Jump = 3'b000;
                    WideWrite = 0;
                    WideRead = 0;
                    ForceZero = 0;
                    SpEnable = 0;
                    LoadSp = 0;
                    WriteData = opCode2;
                    WriteSelect = 3'b000;
                    AluInputControl = 1;
                    UseConditional = 0;
                    AluOp = {1'b0, opCode1[5:3]};
                    RamInSelect = 0;
                    Reg1 = 3'b111;
                    Reg3 = 3'b111; end
                default: begin
                    RamWe = 0;
                    WriteSelect = 0;
                end
            endcase
        end else begin
            AluInputControl = 1'b0;
            WriteSelect = 0;
            We = 0;
            RamWe = 0;
            LoadSp = 0;
            SpEnable = 0;
            Jump = 3'b000;
            WideWrite = 0;
            WideRead = 0;
            UseConditional = 0;
            ForceZero = 0;
            RamInSelect = 0;
        end
    end
endmodule
