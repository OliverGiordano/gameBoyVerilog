module RegisterFile_TB;
    logic Clock;
    logic [2:0] Addr1, Addr2, Addr3;
    logic [7:0] RegIn;
    logic [15:0] WideRegIn;
    logic We, Wide, Reset;
    logic [7:0] Out1, Out2, FlagsOut;
    logic [15:0] WideOut;
    
    RegisterFile dut(.Clock, .Addr1, .Addr2, .Addr3, .RegIn, .WideRegIn, .We, .Wide, 
        .Out1, .Out2, .WideOut, .FlagsOut, .Reset);
    
    initial begin
        $dumpfile("RegisterFile.vcd");
        $dumpvars(0, RegisterFile_TB);
        Clock = 0; Addr1 = '0; Addr2 = '0; Addr3 = '0; 
        RegIn = '0; WideRegIn = '0; We = 0; Wide = 0;
        Reset = 1;
        #10; Clock = 1; #10; Clock = 0; // write to reg
        Reset = 0;
        #10; Clock = 1; #10; Clock = 0; // write to reg
        
        Addr1 = 3'b010; Addr2 = 3'b100; Addr3 = 3'b111;
        We = 1;
        RegIn = 8'b10101010;
        #10; Clock = 1; #10; Clock = 0; // read reg out
        
        Addr1 = 3'b111; Addr2 = 3'b100; Addr3 = 3'b000;
        We = 0;
        #10; Clock = 1; #10; Clock = 0; // write to wide reg
        
        Addr1 = 3'b000; Addr2 = 3'b100; Addr3 = 3'b000;
        WideRegIn = 16'b1010101010101010;
        We = 1; Wide = 1;
        #10; Clock = 1; #10; Clock = 0;
        
        Addr1 = 3'b000; Addr2 = 3'b111; Addr3 = 3'b000;
        We = 0; Wide = 1;
        #10; Clock = 1; #10; Clock = 0;
        #10;
        $finish;
    end
endmodule
