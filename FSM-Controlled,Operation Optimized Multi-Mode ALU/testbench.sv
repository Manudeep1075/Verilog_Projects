module tb_ALU;
  reg clk;
  reg Start;
  reg [1:0] mode;
  reg [3:0] A, B;
  wire [7:0] P;
  wire Done;
  ALU dut (
    .clk   (clk),
    .mode  (mode),
    .A     (A),
    .B     (B),
    .P     (P),
    .Start (Start),
    .Done  (Done)
  );
  always #5 clk = ~clk;
  task start_and_wait;
    begin
      Start = 1;
      @(posedge Done);   
      #5;
      Start = 0;         
      @(negedge Done);   
    end
  endtask

  initial begin
    clk   = 0;
    Start = 0;
    mode  = 0;
    A     = 0;
    B     = 0;    
    #20;    
    $display("\n--- ADD TEST ---");
    mode = 2'b00;  
    A = 4'd5;
    B = 4'd3;
    start_and_wait;
    $display("ADD: %0d + %0d = %0d", A, B, P);    
    $display("\n--- SUB TEST ---");
    mode = 2'b01;   
    A = 4'd3;
    B = 4'd9;
    start_and_wait;
    $display("SUB: |%0d - %0d| = %0d", A, B, P);    
    $display("\n--- MUL TEST ---");
    mode = 2'b10;   
    A = 4'd4;
    B = 4'd6;
    start_and_wait;
    $display("MUL: %0d * %0d = %0d", A, B, P);
    $display("\n--- GCD TEST ---");
    mode = 2'b11;   // GCD
    A = 4'd12;
    B = 4'd8;
    start_and_wait;
    $display("GCD(%0d, %0d) = %0d", A, B, P);    
    $display("\n--- EDGE CASES ---");    
    mode = 2'b10;
    A = 4'd7;
    B = 4'd0;
    start_and_wait;
    $display("MUL: %0d * %0d = %0d", A, B, P);    
    mode = 2'b11;
    A = 9;
    B = 2;
    start_and_wait;
    $display("GCD(%0d, %0d) = %0d", A, B, P);    
    $display("\nALL TESTS COMPLETED");
    #20;
    $finish;
  end
endmodule
