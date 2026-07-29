// Code your design here
module ALUdp(clk,mode,A,B,LDA,LDRA,LDB,LDRB,LDP,Innit,redB,comp0,comp,P);
  input clk,LDA,LDB,LDP,Innit,redB,LDRA,LDRB;
  input [3:0] A,B;
  output [7:0] P;
  input [1:0] mode;
  output reg comp0;
  output [1:0]comp;
  reg [3:0] regA,regB;
  reg [7:0] regP;
  parameter ADD=2'b00,SUB=2'b01,MUL=2'b10,GCD=2'b11;
  always @(posedge clk)
    begin
      if(Innit)
              begin
                regP  <= 0;
                comp0 <= 0;
              end
      else
        begin
          case(mode)
            ADD:
              begin
                if(LDA)
                  regA<=A;
                if(LDB)
                  regB<=B;
                if(LDP)
                  regP<=regA+regB;
              end
            SUB:
              begin
                if(LDA)
                  regA<=A;
                if(LDB)
                  regB<=B;
                if(LDP)
                  begin
                    if(regA<regB)
                    regP<=regB-regA;
                    else
                      regP<=regA-regB;
                  end
              end
            MUL:
              begin
                if(LDA)
                  regA<=A;
                if(LDB)
                  regB<=B;
                if (LDP && regB != 0)
  					regP <= regP + regA;
                if(redB)
                  regB<=regB-1;
                comp0<=(regB==0);
              end
            GCD:
              begin
                if(LDA)
                  regA<=A;
                if(LDB)
                  regB<=B;
                if(LDRA)
                  regA<=regA-regB;
                if(LDRB)
                  regB<=regB-regA;
            	if(regA==regB)
                  regP<=regA;
              end
          endcase
        end
    end
  assign P=regP;
  assign comp = (regA < regB) ? 2'b00 :
              (regA > regB) ? 2'b01 :
                              2'b10;
endmodule

module ALUfsm(clk,mode,LDA,LDRA,LDB,LDRB,LDP,Innit,redB,comp0,comp,Start,Done);
  input clk,comp0,Start;
  input [1:0]comp;
  input [1:0]mode;
  output reg LDA,LDRA,LDB,LDRB,LDP,Innit,redB,Done;
  reg [4:0]state=S0;
  parameter S0=0,S1=1,S2=2,S3=3,S4=4,S5=5,S6=6,S7=7,S8=8,S9=9,S10=10,S11=11,S12=12,S13=13,S14=14,S15=15,S16=16,S17=17,S18=18,S19=19,S20=20;
  always@(posedge clk)
    begin
      case(state)
        S0:
          begin
            if(Start==1)
              state<=S1;
            else
              state<=S0;
          end
        S1:
          begin
            if(mode==2'b00)
              state<=S2;
            else if(mode==2'b01)
              state<=S5;
            else if(mode==2'b10)
              state<=S8;
            else if(mode==2'b11)
              state<=S13;
          end
        S2:
          begin
            state<=S3;
          end
        S3:
          begin 
            state<=S4;
          end 
        S4:
          begin
            state<=S19;
          end
        S5:
          begin
            state<=S6;
          end
        S6:
          begin 
            state<=S7;
          end 
        S7:
          begin            
            state<=S19;
          end
        S8:
          begin            
            state<=S9;
          end
        S9:
          begin            
            state<=S10;
          end
        S10:
          begin
            if(comp0==1)
              state<=S19;
            else
              state<=S11;
          end
        S11:
          begin            
            state<=S12;
          end
        S12:
          begin            
            state<=S10;
          end
        S13:
          begin            
            state<=S14;
          end
        S14:
          begin            
            state<=S15;
          end
        S15:
          begin
            if(comp==2'b00)
              state<=S18;
            else if(comp==2'b01)
              state<=S16;
            else if(comp==2'b10)
              state<=S17;
          end
        S16:
          begin            
            state<=S15;
          end
        S17:
          begin            
            state<=S19;
          end
        S18:
          begin          	
            state<=S15;
          end
        S19:
          begin
            if(!Start)
              state<=S0;
          end
        default:
          begin
            state<=S0;
          end
      endcase
    end
      always@(*)
    begin
      LDA   = 0;
      LDB   = 0;
      LDP   = 0;
      LDRA  = 0;
      LDRB  = 0;
      Innit = 0;
      redB  = 0;
      Done  = 0;
      case(state)
        S2:
          begin
            Innit=1;
          end
        S3:
          begin 
            LDA=1;
            LDB=1;            
          end 
        S4:
          begin
            LDP=1;            
          end
        S5:
          begin
            Innit=1;            
          end
        S6:
          begin 
            LDA=1;
            LDB=1;            
          end 
        S7:
          begin
            LDP=1;            
          end
        S8:
          begin
            Innit=1;            
          end
        S9:
          begin 
            LDA=1;
            LDB=1;            
          end
        S11:
          begin
            LDP=1;            
          end
        S12:
          begin
            redB=1;            
          end
        S13:
          begin
            Innit=1;            
          end
        S14:
          begin 
            LDA=1;
            LDB=1;            
          end        
        S16:
          begin
            LDRA=1;            
          end
        S17:
          begin
            LDP=1;            
          end
        S18:
          begin
          	LDRB=1;            
          end
        S19:
          Done=1;
      endcase
    end
endmodule
module ALU(clk,mode,A,B,P,Start,Done);
  input clk,Start;
  input [3:0]A,B;
  input [1:0] mode;
  output Done;
  output [7:0]P;
  wire LDA, LDRA, LDB, LDRB, LDP, Innit, redB;
  wire comp0;
  wire [1:0] comp;
  
  ALUfsm FSM (
    .clk   (clk),
    .mode  (mode),
    .LDA   (LDA),
    .LDRA  (LDRA),
    .LDB   (LDB),
    .LDRB  (LDRB),
    .LDP   (LDP),
    .Innit (Innit),
    .redB  (redB),
    .comp0 (comp0),
    .comp  (comp),
    .Start (Start),
    .Done  (Done));
  
  ALUdp datapath (
    .clk   (clk),
    .mode  (mode),
    .A     (A),
    .B     (B),
    .LDA   (LDA),
    .LDRA  (LDRA),
    .LDB   (LDB),
    .LDRB  (LDRB),
    .LDP   (LDP),
    .Innit (Innit),
    .redB  (redB),
    .comp0 (comp0),
    .comp  (comp),
    .P     (P));
endmodule

  
  