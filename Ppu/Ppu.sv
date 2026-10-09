module Ppu(
        input logic Clock, Reset,
        input logic [7:0] LcdcIn,
        input logic [7:0] VramIn,
        input logic [7:0] BgpIn,
        input logic [7:0] Scx, Scy,
        output logic [7:0] LyOut,
        output logic [1:0] CurrentState,
        output logic VBlankInterruptPulse,
        output logic [15:0] VramAddress,
        output logic [1:0] PixelOut,

        output logic [7:0] ScreenX,
        output logic PixelValid
    );

    logic [8:0] dotCounter;
    logic [7:0] lyRegister;
    logic xDone;
    logic [7:0] screenXReg;
    logic [2:0] discardCount;

    logic [7:0] trueY;
    logic [4:0] trueX;
    assign ScreenX = screenXReg;

    assign LyOut = lyRegister;

    typedef enum logic [1:0]{
        HBLANK, VBLANK, OAM, PIXELTRANSFER
    } control_mode_t;

    control_mode_t ControlMode;

    logic [15:0] pPipelineHigh, pPipelineLow;
    logic [4:0] pInQueue;
    logic [7:0] pOutput;

    logic [1:0] nextPixelToScreen;

    logic [2:0] fetcher;
    logic [4:0] xTileCounter;
    logic [7:0] currentTileId;
    logic [7:0] currentTileLow, currentTileHigh;

    assign nextPixelToScreen = {pPipelineHigh[15], pPipelineLow[15]};

    assign CurrentState = ControlMode;
    assign PixelValid = (ControlMode == PIXELTRANSFER) && (pInQueue > 8)
                    && (discardCount == 0) && (screenXReg < 160);

    always_ff @(posedge Clock, posedge Reset) begin
        if(Reset) begin
            dotCounter <= '0;
            lyRegister <= '0;
            fetcher <= '0;
            pInQueue <= '0;
            pOutput <= '0;
            xDone <= 0;
        end else begin
            if(ControlMode == PIXELTRANSFER) begin
                if (screenXReg == 160) xDone <= 1;
                if (xTileCounter == 20) xDone <= 1;
                if(pInQueue > 8) begin
                    pPipelineHigh <= pPipelineHigh << 1;
                    pPipelineLow <= pPipelineLow << 1;
                    pInQueue <= pInQueue-1;
                    pOutput <= pOutput+1;

                    if(discardCount > 0) begin
                        discardCount <= discardCount -1'b1;
                    end else if (screenXReg < 160) begin
                        screenXReg <= screenXReg + 1;
                    end
                end
                fetcher <= fetcher+1;
                case (fetcher)
                    3'd1: currentTileId <= VramIn;
                    3'd3: currentTileLow <= VramIn;
                    3'd5: currentTileHigh <= VramIn;
                    3'd7: begin
                    if (pInQueue > 8) begin
                        fetcher <= 3'd7;                 // no room yet, retry next cycle
                    end else begin
                        if (pInQueue == 0) begin
                            pPipelineHigh[15:8] <= currentTileHigh;
                            pPipelineLow[15:8]  <= currentTileLow;
                            pInQueue <= 8;
                        end else begin                   // pInQueue == 8
                            pPipelineHigh[7:0] <= currentTileHigh;
                            pPipelineLow[7:0]  <= currentTileLow;
                            pInQueue <= pInQueue + 8;
                        end
                        xTileCounter <= xTileCounter + 1'b1;
                    end
                end
                default: ;
                endcase
            end else begin
                fetcher <= '0;
                xTileCounter <= 0;
                pInQueue <= '0;
                pOutput <= '0;
                screenXReg <= '0;
                discardCount <= Scx[2:0];
            end
            VBlankInterruptPulse <= 0;
            if(dotCounter == 455) begin
                dotCounter <= '0;
                xDone <= 0;
                if(lyRegister == 153) lyRegister <= '0;
                else lyRegister <= lyRegister +1;

                if(lyRegister == 143) begin
                    VBlankInterruptPulse <= 1;
                end
            end else dotCounter <= dotCounter + 1;
        end
    end

    logic [15:0] mapAddress, tileAddress;
    logic [15:0] signedTileId;

    always_comb begin
        trueY = lyRegister + Scy;
        trueX = (xTileCounter + Scx[7:3]) & 5'h1F;
        if(LcdcIn[3]) mapAddress = 16'h9C00 + ({8'b0, trueY[7:3]}*32)
                                   +{11'b0, trueX};
        else mapAddress = 16'h9800 + ({8'b0, trueY[7:3]}*32)
                                   +{11'b0, trueX};
                    // we get the y by deciding by 8 (each tile is 8p tall)
        signedTileId = {{8{currentTileId[7]}}, currentTileId};

        if(LcdcIn[4]) tileAddress = 16'h8000 + ({8'b0, currentTileId} * 16)
                                   +({13'b0, trueY[2:0]}*2);

        else tileAddress = 16'h9000 +(signedTileId * 16)
                          +({13'b0, trueY[2:0]}*2)      ;
        case (fetcher)
            3'd0, 3'd1: VramAddress = mapAddress;
            3'd2, 3'd3: VramAddress = tileAddress;
            3'd4, 3'd5: VramAddress = tileAddress+1;
            default: VramAddress = mapAddress;
        endcase
    end
    /*always_ff @(posedge Clock)
    if (ControlMode == PIXELTRANSFER && lyRegister == 10 && xTileCounter == 0
        && (fetcher == 3'd1 || fetcher == 3'd3 || fetcher == 3'd5))
        $display("FETCH f=%0d addr=%h data=%h", fetcher, VramAddress, VramIn);*/

    always_comb begin
        if (lyRegister >= 8'd144) begin
            ControlMode = VBLANK; // Mode 1: V-Blank (Lines 144-153)
        end else begin
            if (dotCounter < 9'd80) begin
                ControlMode = OAM; // Mode 2: OAM Search (80 clocks)
            end else if (!xDone) begin
                ControlMode = PIXELTRANSFER;
            end else begin
                ControlMode = HBLANK;
            end
        end

        case(nextPixelToScreen)
            2'b00: PixelOut = BgpIn[1:0];
            2'b01: PixelOut = BgpIn[3:2];
            2'b10: PixelOut = BgpIn[5:4];
            2'b11: PixelOut = BgpIn[7:6];
            default: PixelOut = BgpIn[1:0];
        endcase
    end
endmodule
