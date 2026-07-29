module tst_bch;

reg clk1, clk2;
integer K;
risc_ppl DUT(clk1, clk2);
initial
begin
    clk1 = 0;
    clk2 = 0;

    repeat (60)
    begin
        #5 clk1 = 1;
        #5 clk1 = 0;
        #5 clk2 = 1;
        #5 clk2 = 0;
    end
end
initial
begin
    for(K = 0; K < 32; K = K + 1)
        DUT.reg_file[K] = K;

    DUT.PC = 0;
    DUT.HALTED = 0;
    DUT.BRANCH_TAKEN = 0;

    DUT.mem_file[100] = 32'd999;
  
    // ADDI R1,R0,10
    DUT.mem_file[0]  = 32'h2801000A;

    // ADDI R2,R0,20
    DUT.mem_file[1]  = 32'h28020014;

    // ADDI R3,R0,5
    DUT.mem_file[2]  = 32'h28030005;

    DUT.mem_file[3]  = 32'h0CE77800;
    DUT.mem_file[4]  = 32'h0CE77800;

    // ADD R4,R1,R2
    DUT.mem_file[5]  = 32'h00222000;

    // SUB R5,R2,R3
    DUT.mem_file[6]  = 32'h04432800;

    // AND R6,R1,R2
    DUT.mem_file[7]  = 32'h08223000;

    // OR R8,R1,R2
    DUT.mem_file[8]  = 32'h0C224000;

    // SLT R9,R3,R2
    DUT.mem_file[9]  = 32'h10624800;

    // MUL R10,R1,R3
    DUT.mem_file[10] = 32'h14235000;

    DUT.mem_file[11] = 32'h0CE77800;
    DUT.mem_file[12] = 32'h0CE77800;

    // SUBI R11,R2,5
    DUT.mem_file[13] = 32'h2C4B0005;

    // SLTI R12,R3,10
    DUT.mem_file[14] = 32'h306C000A;

    // STR R4,100(R0)
    DUT.mem_file[15] = 32'h24040064;

    // LDR R13,100(R0)
    DUT.mem_file[16] = 32'h200D0064;

    // NOPs
    DUT.mem_file[17] = 32'h0CE77800;
    DUT.mem_file[18] = 32'h0CE77800;

    // BEQZ R0,+2
    DUT.mem_file[19] = 32'h38000002;

    DUT.mem_file[20] = 32'h280E006F;

    // Executed
    DUT.mem_file[21] = 32'h280E00DE;

    // BNEQZ R1,+2
    DUT.mem_file[22] = 32'h34200002;

    // Skipped
    DUT.mem_file[23] = 32'h280F014D;

    // Executed
    DUT.mem_file[24] = 32'h280F01BC;

    // HALT
    DUT.mem_file[25] = 32'hFC000000;

    #800;
    for(K = 0; K < 16; K = K + 1)
        $display("R%0d = %0d", K, DUT.reg_file[K]);

    $display("\nMemory[100] = %0d", DUT.mem_file[100]);
    $display("HALTED      = %0d", DUT.HALTED);

    #100 $finish;

end

endmodule