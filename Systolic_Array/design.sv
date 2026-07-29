// Code your design here
module systolic_array(clk,rst,C_A,C_B,C_C,R_A,R_B,R_C,A11,A12,A13,A21,A22,A23,A31,A32,A33);
  reg [3:0] C11,C12,C13,R11,R21,R31;
  input [3:0] C_A,C_B,C_C,R_A,R_B,R_C;
  input clk,rst;
  integer i;
  output reg [9:0] A11,A12,A13,A21,A22,A23,A31,A32,A33;
  reg [3:0] reg_AB,reg_BC,reg_DE,reg_EF,reg_GH,reg_HI,reg_AD,reg_DG,reg_BE,reg_EH,reg_CF,reg_FI;
  reg [3:0]C1[0:4];
  reg [3:0]C2[0:4];
  reg [3:0]C3[0:4];
  reg [3:0]R1[0:4];
  reg [3:0]R2[0:4];
  reg [3:0]R3[0:4];
  //data orchestration
  always@(posedge clk)
    begin
      if(rst==1)
        begin
          for(i=0;i<=4;i=i+1)
            begin
              C1[i]<=0;
              C2[i]<=0;
              C3[i]<=0;
              R1[i]<=0;
              R2[i]<=0;
              R3[i]<=0;
            end
          C11<=0;
          C12<=0;
          C13<=0;
          R11<=0;
          R21<=0;
          R31<=0;
        end
      else
        begin
          //C11
          C11<=C1[0];
          C1[0]<=C1[1];
          C1[1]<=C1[2];
          C1[2]<=C1[3];
          C1[3]<=C1[4];
          C1[4]<=C_A;

          //C12
          C12<=C2[0];
          C2[0]<=C2[1];
          C2[1]<=C2[2];
          C2[2]<=C2[3];
          C2[3]<=C2[4];
          C2[4]<=C_B;
          //C13
          C13<=C3[0];
          C3[0]<=C3[1];
          C3[1]<=C3[2];
          C3[2]<=C3[3];
          C3[3]<=C3[4];
          C3[4]<=C_C;
          //R11
          R11<=R1[0];
          R1[0]<=R1[1];
          R1[1]<=R1[2];
          R1[2]<=R1[3];
          R1[3]<=R1[4];
          R1[4]<=R_A;
          //R21
          R21<=R2[0];
          R2[0]<=R2[1];
          R2[1]<=R2[2];
          R2[2]<=R2[3];
          R2[3]<=R2[4];
          R2[4]<=R_B;
          //R31
          R31<=R3[0];
          R3[0]<=R3[1];
          R3[1]<=R3[2];
          R3[2]<=R3[3];
          R3[3]<=R3[4];
          R3[4]<=R_C;
        end
    end
      
  //A11
  always@(posedge clk)
    begin
      if(rst==1)
        begin
          A11<=0;
          reg_AB<=0;
          reg_AD<=0;
        end
      else
        begin
          reg_AB<=R11;
          reg_AD<=C11;
          A11<=A11+R11*C11;
        end
    end
  //A12
  always@(posedge clk)
    begin
      if(rst==1)
        begin
          A12<=0;
          reg_BC<=0;
          reg_BE<=0;
        end
      else
        begin
          reg_BC<=reg_AB;
          reg_BE<=C12;
          A12<=A12+reg_AB*C12;
        end
    end
  //A13
  always@(posedge clk)
    begin
      if(rst==1)
        begin
          A13<=0;
          reg_CF<=0;
        end
      else
        begin
          reg_CF<=C13;
          A13<=A13+reg_BC*C13;
        end
    end
  //A21
  always@(posedge clk)
    begin
      if(rst==1)
        begin
          A21<=0;
          reg_DG<=0;
          reg_DE<=0;
        end
      else
        begin
          reg_DG<=reg_AD;
          reg_DE<=R21;
          A21<=A21+reg_AD*R21;
        end
    end
  //A22
  always@(posedge clk)
    begin
      if(rst==1)
        begin
          A22<=0;
          reg_EF<=0;
          reg_EH<=0;
        end
      else
        begin
          reg_EF<=reg_DE;
          reg_EH<=reg_BE;
          A22<=A22+reg_DE*reg_BE;
        end
    end
  //A23
  always@(posedge clk)
    begin
      if(rst==1)
        begin
          A23<=0;
          reg_FI<=0;
        end
      else
        begin
          reg_FI<=reg_CF;
          A23<=A23+reg_EF*reg_CF;
        end
    end
  //A31
  always@(posedge clk)
    begin
      if(rst==1)
        begin
          A31<=0;
          reg_GH<=0;
        end
      else
        begin
          reg_GH<=R31;
          A31<=A31+R31*reg_DG;
        end
    end
  //A32
  always@(posedge clk)
    begin
      if(rst==1)
        begin
          A32<=0;
          reg_HI<=0;
        end
      else
        begin
          reg_HI<=reg_GH;
          A32<=A32+reg_EH*reg_GH;
        end
    end
  //A33
  always@(posedge clk)
    begin
      if(rst==1)
        begin
          A33<=0;
        end
      else
        begin
      		A33<=A33+reg_HI*reg_FI;
        end
    end
endmodule
  
      
      
      
      