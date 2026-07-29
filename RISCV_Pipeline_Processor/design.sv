// Code your design here


// The code is not synthasizable as there are time delays added. removing them makes the code synthasizable.


module risc_ppl(clk1,clk2);
  input clk1,clk2;
  reg [31:0]reg_file[0:31];
  reg [31:0]mem_file[0:1023];
  //pipeline stages
  // IF,ID,IE,MEM,WB
  //pipeline registers
  // A,B,IR,NPC,IMM,ALU_OUT,cond
  reg[31:0] IF_ID_IR,PC,IF_ID_NPC;
  reg[31:0] ID_IE_IR,ID_IE_NPC,ID_IE_A,ID_IE_B,ID_IE_IMM;
  reg[31:0] IE_MEM_IR,IE_MEM_ALU_OUT,IE_MEM_B,IE_MEM_cond;
  reg[31:0] MEM_WB_IR,MEM_WB_ALU_OUT,MEM_WB_LMD;
  reg[2:0] ID_IE_type,IE_MEM_type,MEM_WB_type;
  parameter ADD=6'b000000,SUB=6'b000001,AND=6'b000010,OR=6'b000011,SLT=6'b000100,MUL=6'b000101,HLT=6'b111111,LDR=6'b001000,STR=6'b001001,ADDI=6'b001010,SUBI=6'b001011,SLTI=6'b001100,BNEQZ=6'b001101,BEQZ=6'b001110;
  parameter R_R=3'b000,R_I=3'b001,LOAD=3'b010,STORE=3'b011,BRANCH=3'b100,HALT=3'b101;
  reg HALTED,BRANCH_TAKEN;
  //FETCH STAGE
  always @(posedge clk1)
    if(HALTED==0)
      begin
        IF_ID_IR<=#2 mem_file[PC];
        if(IF_ID_IR[31:26]==BEQZ && IE_MEM_cond==1 || IF_ID_IR[31:26]==BNEQZ && IE_MEM_cond==0)
          begin
            BRANCH_TAKEN<=#2 1;
            PC<=#2 IE_MEM_ALU_OUT;
            IF_ID_NPC<=#2 IE_MEM_ALU_OUT;
          end
        else
          begin
            PC<=#2 PC+1;
            IF_ID_NPC<=#2 PC+1;
          end
      end
  //DECODE STAGE
  always @(posedge clk2)
    if(HALTED==0)
      begin
        ID_IE_IR<=#2 IF_ID_IR;
        ID_IE_NPC<=#2 IF_ID_NPC;
        ID_IE_A<=#2 reg_file[IF_ID_IR[25:21]];
        ID_IE_B<=#2 reg_file[IF_ID_IR[20:16]];
        ID_IE_IMM<=#2 {{16{IF_ID_IR[15]}},{IF_ID_IR[15:0]}};
        case(IF_ID_IR[31:26])
          ADD,SUB,AND,OR,SLT,MUL:
            begin
              ID_IE_type<=#2 R_R;
            end
          LDR:
            begin
              ID_IE_type<=#2 LOAD;
            end
          STR:
            begin
              ID_IE_type<=#2 STORE;
            end
          ADDI,SUBI,SLTI:
            begin
              ID_IE_type<=#2 R_I;
            end
          BNEQZ,BEQZ:
            begin
              ID_IE_type<=#2 BRANCH;
            end
          HLT:
            begin
              ID_IE_type<=#2 HALT;
            end
          default:
            ID_IE_type<=#2 HALT;
        endcase
      end
  //EXICUTE STAGE
  always @(posedge clk1)
    if(HALTED==0)
      begin
        IE_MEM_IR<=#2 ID_IE_IR;
        IE_MEM_type<=#2 ID_IE_type;
        BRANCH_TAKEN<=#2 0;
        case(ID_IE_type)
          R_R:
            begin
              case(ID_IE_IR[31:26])
                ADD:
                  begin
                    IE_MEM_ALU_OUT<=#2 ID_IE_A+ID_IE_B;
                  end
                SUB:
                  begin
                    IE_MEM_ALU_OUT<=#2 ID_IE_A-ID_IE_B;
                  end
                AND:
                  begin
                    IE_MEM_ALU_OUT<=#2 ID_IE_A&ID_IE_B;
                  end
                OR:
                  begin
                    IE_MEM_ALU_OUT<=#2 ID_IE_A|ID_IE_B;
                  end
                SLT:
                  begin
                    if(ID_IE_A<ID_IE_B)
                      begin
                        IE_MEM_ALU_OUT<=#2 1;
                      end
                    else
                      IE_MEM_ALU_OUT<=#2 0;
                  end
                MUL:
                  begin 
                    IE_MEM_ALU_OUT<=#2 ID_IE_A*ID_IE_B;
                  end
                default:
                  IE_MEM_ALU_OUT<=#2 32'hxxxxxxxx;
              endcase
            end
          R_I:
            begin
              case(ID_IE_IR[31:26])
                ADDI:
                  IE_MEM_ALU_OUT<=#2 ID_IE_A+ID_IE_IMM;
                SUBI:
                  IE_MEM_ALU_OUT<=#2 ID_IE_A-ID_IE_IMM;
                SLTI:
                  begin
                    if(ID_IE_A<ID_IE_IMM)
                      IE_MEM_ALU_OUT<=#2 1;
                    else
                      IE_MEM_ALU_OUT<=#2 0;
                  end
                default:
                  IE_MEM_ALU_OUT<=#2 32'hxxxxxxxx;
              endcase
            end
          LOAD,STORE:
            begin
              IE_MEM_ALU_OUT<=#2 ID_IE_A+ID_IE_IMM;
              IE_MEM_B<=#2 ID_IE_B;             
            end
          BRANCH:
            begin
              IE_MEM_ALU_OUT<=#2 ID_IE_NPC+ID_IE_IMM;
              IE_MEM_cond<=#2 (ID_IE_A==0);
            end
        endcase
      end
  //MEM STAGE
  always @(posedge clk2)
    if(HALTED==0)
      begin
        MEM_WB_IR<=#2 IE_MEM_IR;
        MEM_WB_type<=#2 IE_MEM_type;
        case(IE_MEM_type)
          R_R,R_I:
            MEM_WB_ALU_OUT<=#2 IE_MEM_ALU_OUT;
          LOAD:
            MEM_WB_LMD<=#2 mem_file[IE_MEM_ALU_OUT];
          STORE:
            mem_file[IE_MEM_ALU_OUT]<=#2 IE_MEM_B;
        endcase
      end
  //WB STAGE
  always @(posedge clk1)
    if(BRANCH_TAKEN==0)
      begin
        case(MEM_WB_type)
          R_R:
            reg_file[MEM_WB_IR[15:11]]<=#2 MEM_WB_ALU_OUT;
          R_I:
            reg_file[MEM_WB_IR[20:16]]<=#2 MEM_WB_ALU_OUT;
          LOAD:
            reg_file[MEM_WB_IR[20:16]]<=#2 MEM_WB_LMD;
          HALT:
            HALTED<=#2 1;
        endcase
      end
endmodule
  
              