// Code your design here
module risc_ppl(clk1, clk2);
  input clk1;
  input clk2;
  reg [31:0] reg_file [0:31];
  reg [31:0] mem_file [0:1023];
  parameter ADD   = 6'b000000,
            SUB   = 6'b000001,
            AND   = 6'b000010,
            OR    = 6'b000011,
            SLT   = 6'b000100,
            MUL   = 6'b000101,
            HLT   = 6'b111111,
            LDR   = 6'b001000,
            STR   = 6'b001001,
            ADDI  = 6'b001010,
            SUBI  = 6'b001011,
            SLTI  = 6'b001100,
            BNEQZ = 6'b001101,
            BEQZ  = 6'b001110;
  parameter R_R    = 3'b000,
            R_I    = 3'b001,
            LOAD   = 3'b010,
            STORE  = 3'b011,
            BRANCH = 3'b100,
            HALT   = 3'b101;
  reg [31:0] IF_ID_IR;
  reg [31:0] IF_ID_NPC;
  reg [31:0] ID_IE_IR;
  reg [31:0] ID_IE_NPC;
  reg [31:0] ID_IE_A;
  reg [31:0] ID_IE_B;
  reg [31:0] ID_IE_IMM;
  reg [2:0]  ID_IE_type;
  reg [31:0] IE_MEM_IR;
  reg [31:0] IE_MEM_ALU_OUT;
  reg [31:0] IE_MEM_B;
  reg [31:0] IE_MEM_cond;
  reg [2:0]  IE_MEM_type;
  reg [31:0] MEM_WB_IR;
  reg [31:0] MEM_WB_ALU_OUT;
  reg [31:0] MEM_WB_LMD;
  reg [2:0]  MEM_WB_type;
  reg HALTED;
  reg BRANCH_TAKEN;
  reg STALL;
  // PROGRAM COUNTER
  reg [31:0] PC;
  // FORWARDING OPERANDS
  reg [31:0] EX_A;
  reg [31:0] EX_B;
  // DIRECT-MAPPED INSTRUCTION CACHE
  // 16 lines
  // 1 word per line
  reg [31:0] ICache_data  [0:15];
  reg [27:0] ICache_tag   [0:15];
  reg        ICache_valid [0:15];
  reg [31:0] DCache_data  [0:15];
  reg [27:0] DCache_tag   [0:15];
  reg        DCache_valid [0:15];

  integer ICache_hits;
  integer ICache_misses;
  integer DCache_hits;
  integer DCache_misses;
  wire [3:0]  IF_index;
  wire [27:0] IF_tag;
  assign IF_index = PC[3:0];
  assign IF_tag   = PC[31:4];
  always @(*)
    begin
      EX_A = ID_IE_A;
      EX_B = ID_IE_B;
      // EX/MEM R-type
      if ((IE_MEM_type == R_R) &&
          (IE_MEM_IR[15:11] != 0) &&
          (IE_MEM_IR[15:11] == ID_IE_IR[25:21]))
        begin
          EX_A = IE_MEM_ALU_OUT;
        end
      else if ((IE_MEM_type == R_I) &&
               (IE_MEM_IR[20:16] != 0) &&
               (IE_MEM_IR[20:16] == ID_IE_IR[25:21]))
        begin
          EX_A = IE_MEM_ALU_OUT;
        end
      // MEM/WB R-type
      else if ((MEM_WB_type == R_R) &&
               (MEM_WB_IR[15:11] != 0) &&
               (MEM_WB_IR[15:11] == ID_IE_IR[25:21]))
        begin
          EX_A = MEM_WB_ALU_OUT;
        end
      // MEM/WB I-type
      else if ((MEM_WB_type == R_I) &&
               (MEM_WB_IR[20:16] != 0) &&
               (MEM_WB_IR[20:16] == ID_IE_IR[25:21]))
        begin
          EX_A = MEM_WB_ALU_OUT;
        end
      // MEM/WB LOAD
      else if ((MEM_WB_type == LOAD) &&
               (MEM_WB_IR[20:16] != 0) &&
               (MEM_WB_IR[20:16] == ID_IE_IR[25:21]))
        begin
          EX_A = MEM_WB_LMD;
        end
      // OPERAND B
      // EX/MEM R-type
      if ((IE_MEM_type == R_R) &&
          (IE_MEM_IR[15:11] != 0) &&
          (IE_MEM_IR[15:11] == ID_IE_IR[20:16]))
        begin
          EX_B = IE_MEM_ALU_OUT;
        end
      // EX/MEM I-type
      else if ((IE_MEM_type == R_I) &&
               (IE_MEM_IR[20:16] != 0) &&
               (IE_MEM_IR[20:16] == ID_IE_IR[20:16]))
        begin
          EX_B = IE_MEM_ALU_OUT;
        end
      // MEM/WB R-type
      else if ((MEM_WB_type == R_R) &&
               (MEM_WB_IR[15:11] != 0) &&
               (MEM_WB_IR[15:11] == ID_IE_IR[20:16]))
        begin
          EX_B = MEM_WB_ALU_OUT;
        end
      // MEM/WB I-type
      else if ((MEM_WB_type == R_I) &&
               (MEM_WB_IR[20:16] != 0) &&
               (MEM_WB_IR[20:16] == ID_IE_IR[20:16]))
        begin
          EX_B = MEM_WB_ALU_OUT;
        end
      // MEM/WB LOAD
      else if ((MEM_WB_type == LOAD) &&
               (MEM_WB_IR[20:16] != 0) &&
               (MEM_WB_IR[20:16] == ID_IE_IR[20:16]))
        begin
          EX_B = MEM_WB_LMD;
        end
    end
  always @(*)
    begin
      STALL = 0;
      if(ID_IE_type == LOAD)
        begin
          if((IF_ID_IR[25:21] == ID_IE_IR[20:16]) ||
             (IF_ID_IR[20:16] == ID_IE_IR[20:16]))
            begin
              if(ID_IE_IR[20:16] != 0)
                STALL = 1;
            end
        end
    end
  always @(posedge clk1)
    if(HALTED == 0)
      begin
        if(STALL == 1)
          begin
            PC <= #2 PC;
            IF_ID_IR  <= #2 IF_ID_IR;
            IF_ID_NPC <= #2 IF_ID_NPC;
          end
        else
          begin
            if(ICache_valid[IF_index] &&
               ICache_tag[IF_index] == IF_tag)
              begin
                IF_ID_IR <= #2 ICache_data[IF_index];
                ICache_hits = ICache_hits + 1;
              end
            else
              begin
                ICache_misses = ICache_misses + 1;
                ICache_data[IF_index] <= #2 mem_file[PC];
                ICache_tag[IF_index] <= #2 IF_tag;
                ICache_valid[IF_index] <= #2 1;
                IF_ID_IR <= #2 mem_file[PC];
              end
            IF_ID_NPC <= #2 PC + 1;
            PC <= #2 PC + 1;
          end
      end
  always @(posedge clk2)
    if(HALTED == 0)
      begin
        if(STALL == 1)
          begin
            ID_IE_IR   <= #2 0;
            ID_IE_type <= #2 R_I;
            ID_IE_NPC  <= #2 0;
            ID_IE_A    <= #2 0;
            ID_IE_B    <= #2 0;
            ID_IE_IMM  <= #2 0;
          end
        else
          begin
            ID_IE_IR  <= #2 IF_ID_IR;
            ID_IE_NPC <= #2 IF_ID_NPC;
            ID_IE_A <= #2 reg_file[IF_ID_IR[25:21]];
            ID_IE_B <= #2 reg_file[IF_ID_IR[20:16]];
            ID_IE_IMM <= #2
              {{16{IF_ID_IR[15]}},IF_ID_IR[15:0]};
            case(IF_ID_IR[31:26])
              ADD,SUB,AND,OR,SLT,MUL:
                ID_IE_type <= #2 R_R;
              LDR:
                ID_IE_type <= #2 LOAD;
              STR:
                ID_IE_type <= #2 STORE;
              ADDI,SUBI,SLTI:
                ID_IE_type <= #2 R_I;
              BNEQZ,BEQZ:
                ID_IE_type <= #2 BRANCH;
              HLT:
                ID_IE_type <= #2 HALT;
              default:
                ID_IE_type <= #2 HALT;
            endcase
          end
      end
  always @(posedge clk1)
    if(HALTED == 0)
      begin
        IE_MEM_IR   <= #2 ID_IE_IR;
        IE_MEM_type <= #2 ID_IE_type;
        BRANCH_TAKEN <= #2 0;
        case(ID_IE_type)
          R_R:
            begin
              case(ID_IE_IR[31:26])
                ADD:
                  IE_MEM_ALU_OUT <= #2 EX_A + EX_B;
                SUB:
                  IE_MEM_ALU_OUT <= #2 EX_A - EX_B;
                AND:
                  IE_MEM_ALU_OUT <= #2 EX_A & EX_B;
                OR:
                  IE_MEM_ALU_OUT <= #2 EX_A | EX_B;
                SLT:
                  begin
                    if(EX_A < EX_B)
                      IE_MEM_ALU_OUT <= #2 1;
                    else
                      IE_MEM_ALU_OUT <= #2 0;
                  end
                MUL:
                  IE_MEM_ALU_OUT <= #2 EX_A * EX_B;
                default:
                  IE_MEM_ALU_OUT <= #2 32'hxxxxxxxx;
              endcase
            end
          R_I:
            begin
              case(ID_IE_IR[31:26])
                ADDI:
                  IE_MEM_ALU_OUT <= #2 EX_A + ID_IE_IMM;
                SUBI:
                  IE_MEM_ALU_OUT <= #2 EX_A - ID_IE_IMM;
                SLTI:
                  begin
                    if(EX_A < ID_IE_IMM)
                      IE_MEM_ALU_OUT <= #2 1;
                    else
                      IE_MEM_ALU_OUT <= #2 0;
                  end
                default:
                  IE_MEM_ALU_OUT <= #2 32'hxxxxxxxx;
              endcase
            end
          LOAD,STORE:
            begin
              IE_MEM_ALU_OUT <= #2 EX_A + ID_IE_IMM;
              IE_MEM_B <= #2 EX_B;
            end
          BRANCH:
            begin
              IE_MEM_ALU_OUT <= #2 ID_IE_NPC + ID_IE_IMM;
              IE_MEM_cond <= #2 (EX_A == 0);
            end
        endcase
      end
  always @(posedge clk2)
    if(HALTED == 0)
      begin
        MEM_WB_IR   <= #2 IE_MEM_IR;
        MEM_WB_type <= #2 IE_MEM_type;
        case(IE_MEM_type)
          R_R,R_I:
            begin
              MEM_WB_ALU_OUT <= #2 IE_MEM_ALU_OUT;
            end
          LOAD:
            begin
              if(DCache_valid[IE_MEM_ALU_OUT[3:0]] &&
                 DCache_tag[IE_MEM_ALU_OUT[3:0]]
                   == IE_MEM_ALU_OUT[31:4])
                begin
                  // CACHE HIT
                  DCache_hits = DCache_hits + 1;

                  MEM_WB_LMD <= #2
                    DCache_data[IE_MEM_ALU_OUT[3:0]];
                end
              else
                begin
                  // CACHE MISS
                  DCache_misses = DCache_misses + 1;
                  // Refill cache
                  DCache_data[IE_MEM_ALU_OUT[3:0]]
                    <= #2 mem_file[IE_MEM_ALU_OUT];
                  DCache_tag[IE_MEM_ALU_OUT[3:0]]
                    <= #2 IE_MEM_ALU_OUT[31:4];
                  DCache_valid[IE_MEM_ALU_OUT[3:0]]
                    <= #2 1;
                  MEM_WB_LMD <= #2
                    mem_file[IE_MEM_ALU_OUT];
                end
            end
          STORE:
            begin
              mem_file[IE_MEM_ALU_OUT] <= #2 IE_MEM_B;
              if(DCache_valid[IE_MEM_ALU_OUT[3:0]] &&
                 DCache_tag[IE_MEM_ALU_OUT[3:0]]
                   == IE_MEM_ALU_OUT[31:4])
                begin
                  DCache_hits = DCache_hits + 1;
                  DCache_data[IE_MEM_ALU_OUT[3:0]]
                    <= #2 IE_MEM_B;
                end
              else
                begin
                  DCache_misses = DCache_misses + 1;
                  DCache_data[IE_MEM_ALU_OUT[3:0]]
                    <= #2 IE_MEM_B;
                  DCache_tag[IE_MEM_ALU_OUT[3:0]]
                    <= #2 IE_MEM_ALU_OUT[31:4];
                  DCache_valid[IE_MEM_ALU_OUT[3:0]]
                    <= #2 1;
                end
            end
        endcase
      end
  always @(posedge clk1)
    if(BRANCH_TAKEN == 0)
      begin
        case(MEM_WB_type)
          R_R:
            begin
              if(MEM_WB_IR[15:11] != 0)
                reg_file[MEM_WB_IR[15:11]]
                  <= #2 MEM_WB_ALU_OUT;
            end
          R_I:
            begin
              if(MEM_WB_IR[20:16] != 0)
                reg_file[MEM_WB_IR[20:16]]
                  <= #2 MEM_WB_ALU_OUT;
            end
          LOAD:
            begin
              if(MEM_WB_IR[20:16] != 0)
                reg_file[MEM_WB_IR[20:16]]
                  <= #2 MEM_WB_LMD;
            end
          HALT:
            begin
              HALTED <= #2 1;
            end
        endcase
      end
endmodule