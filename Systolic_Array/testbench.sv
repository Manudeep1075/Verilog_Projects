module tstbch;
  wire [9:0] A11,A12,A13,A21,A22,A23,A31,A32,A33;
  reg clk, rst;
  reg [3:0] C_A,C_B,C_C,R_A,R_B,R_C;

  systolic_array DUT (
    .clk(clk), .rst(rst),
    .C_A(C_A),.C_B(C_B),.C_C(C_C),.R_A(R_A),.R_B(R_B),.R_C(R_C),
    .A11(A11), .A12(A12), .A13(A13),
    .A21(A21), .A22(A22), .A23(A23),
    .A31(A31), .A32(A32), .A33(A33)
  );

  initial clk = 0;
  always #1 clk = ~clk;
  integer i;
  initial
    begin
      //@(posedge clk);
      rst=1;
      @(posedge clk);
      @(posedge clk);
      rst=0;
    end
  initial
    begin
      @(posedge clk);
      @(posedge clk)#1;
      C_A=5;
      C_B=0;
      C_C=0;
      R_A=1;
      R_B=0;
      R_C=0;
      @(posedge clk)#1;
      C_A=3;
      C_B=2;
      C_C=0;
      R_A=2;
      R_B=4;
      R_C=0;
      @(posedge clk)#1;
      C_A=9;
      C_B=2;
      C_C=6;
      R_A=3;
      R_B=5;
      R_C=7;
      @(posedge clk)#1;
      C_A=0;
      C_B=5;
      C_C=8;
      R_A=0;
      R_B=6;
      R_C=8;
      @(posedge clk)#1;
      C_A=0;
      C_B=0;
      C_C=6;
      R_A=0;
      R_B=0;
      R_C=9;
      @(posedge clk)#1;
      C_A=0;
      C_B=0;
      C_C=0;
      R_A=0;
      R_B=0;
      R_C=0;
      @(posedge clk)#1;
      C_A=0;
      C_B=0;
      C_C=0;
      R_A=0;
      R_B=0;
      R_C=0;
      @(posedge clk)#1;
      C_A=0;
      C_B=0;
      C_C=0;
      R_A=0;
      R_B=0;
      R_C=0;
      repeat(8) @(posedge clk);
    #1;

    $display("%d  %d  %d", A11, A12, A13);
    $display("%d  %d  %d", A21, A22, A23);
    $display("%d  %d  %d", A31, A32, A33);
    $finish;
  end
endmodule
