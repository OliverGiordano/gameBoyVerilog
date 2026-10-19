module Rom
    (
        input logic [15:0] Addr,
        input logic [15:0] AddrMmu,
        output logic [7:0] DataMmu,
        output logic [7:0] DataOut
    );
    logic [7:0] rom [262143];
    //logic [7:0] rom [65535];

    initial begin
        //$readmemh("../Rom/ld_tests.hex", rom); //write the program to rom
        //$readmemh("../Rom/cb_test_rom.hex", rom); //write the program to rom
        //$readmemh("../Rom/tetris.hex", rom); //write the program to rom
        $readmemh("../Rom/rom.hex", rom); //write the program to rom
       // $display("Code at 0159: %h %h %h %h", rom[16'h0159], rom[16'h015A],
        //                                    rom[16'h015B], rom[16'h015C]);
    end
    //initial $readmemh("../Rom/tetris.hex", rom); //write the program to rom
    assign DataOut = rom[Addr];
    assign DataMmu = rom[AddrMmu];
endmodule
