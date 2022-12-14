----------------------------------------------------------------------------------
-- Company: TUCN
-- Engineer: Radu-Augustin Vele
-- 
-- Create Date: 11/25/2022 07:25:33 PM
-- Design Name: 
-- Module Name: mips16_top_sim - Behavioral
-- Project Name: MIPS 16 Pipeline with Hazard Detection and Avoidance
-- Target Devices: Basys3
-- Tool Versions: 
-- Description: Top level module for simulation purposes
-- 
-- Dependencies: -
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.ALL;
use IEEE.numeric_std.ALL;

entity mips16_top_sim is
    Port ( 
        clk: in std_logic;
        reset: in std_logic;
        --signals used when tested on the board
        en_pc: in std_logic;
        en_mem_wr: in std_logic; 
        en_rf_wr: in std_logic
    );
end mips16_top_sim;

architecture Behavioral of mips16_top_sim is
-- Components declaration

    component IF_unit is
        Port (
            clk100MHz: in std_logic;
            jump_addr: in std_logic_vector(15 downto 0);
            branch_addr: in std_logic_vector(15 downto 0);
            jump_ctrl: in std_logic;
            PCsrc_ctrl: in std_logic;
            reset_pc: in std_logic;
            enable_pc: in std_logic; 
            instruction: out std_logic_vector(15 downto 0);
            pc_plus_one: out std_logic_vector(15 downto 0);
            -- *** BHT Add-on
            ID_prv_pc: in std_logic_vector(3 downto 0);
            ID_pc_plus_one: in std_logic_vector(15 downto 0);
            ID_Flush: in std_logic;
            ID_Branch_Taken: in std_logic;
            ID_Pred: in std_logic;
            ID_Branch_Instruction: in std_logic;
            prediction: out std_logic;
            curr_pc: out std_logic_vector(3 downto 0)    
        );
    end component;
    
    component ID_unit is
        Port ( 
            clk100MHz: in std_logic;
            instruction: in std_logic_vector(15 downto 0);
            wd: in std_logic_vector(15 downto 0);
            RegWrite: in std_logic;
            RegDstAddress: in std_logic_vector(2 downto 0);
            ExtOp: in std_logic;
            rd1: out std_logic_vector(15 downto 0);
            rd2: out std_logic_vector(15 downto 0);
            ext_imm: out std_logic_vector(15 downto 0);
            func: out std_logic_vector(2 downto 0);
            sa: out std_logic;
            write_address_1: out std_logic_vector(2 downto 0);
            write_address_2: out std_logic_vector(2 downto 0);
            -- *** HDU Add-on
            ID_EX_MemRead: in std_logic;
            ID_EX_Rt: in std_logic_vector(2 downto 0);
            IF_ID_WriteEn: out std_logic;
            Ctrl_Sel: out std_logic;
            PC_Enable: out std_logic;
            --*** BranchDet Add-on
            pc_nxt: in std_logic_vector(15 downto 0);
            Branch_instruction: in std_logic;
            Branch_Taken: out std_logic;
            Branch_Address: out std_logic_vector(15 downto 0)
        );
    end component;
    
    component ctrl_unit is
      Port ( 
        opcode: in std_logic_vector (2 downto 0);
        func: in std_logic_vector (2 downto 0);
        RegDst: out std_logic;
        ExtOp: out std_logic;
        ALUSrc: out std_logic;
        Branch: out std_logic;
        Jump: out std_logic;
        ALUOp: out std_logic_vector(1 downto 0);
        MemRead: out std_logic;
        MemWrite: out std_logic;
        MemtoReg: out std_logic;
        RegWrite: out std_logic);
    end component;
    
    component EX_unit is
        Port ( 
            next_pc: in std_logic_vector(15 downto 0);
            rd1: in std_logic_vector(15 downto 0); 
            rd2: in std_logic_vector(15 downto 0);
            ALUSrc: in std_logic;
            ext_imm: in std_logic_vector(15 downto 0);
            sa: in std_logic;
            func: in std_logic_vector(2 downto 0);
            ALUOp: in std_logic_vector(1 downto 0);
            ALURes: out std_logic_vector (15 downto 0);
            -- *** FWD Unit Add-on
            EX_MEM_ALUOut: in std_logic_vector(15 downto 0);
            MEM_WB_ALUOut: in std_logic_vector(15 downto 0);
            EX_MEM_RegWrite: in std_logic;
            MEM_WB_RegWrite: in std_logic;
            EX_MEM_RegDst: in std_logic_vector(2 downto 0);
            MEM_WB_RegDst: in std_logic_vector(2 downto 0);
            ID_EX_Rs: in std_logic_vector(2 downto 0);
            ID_EX_Rt: in std_logic_vector(2 downto 0)
        );
    end component;
    
    component mem_unit is
        Port ( 
            clk100MHz: in std_logic;
            MemWrite: in std_logic;
            MemRead: in std_logic;
            ALURes: in std_logic_vector (15 downto 0);
            RD2: in std_logic_vector (15 downto 0);
            ALURes_out: out std_logic_vector (15 downto 0);
            MemData: out std_logic_vector (15 downto 0);
            -- MEM FWD Add-on
            MEM_WB_RegWrite: in std_logic;
            WB_BUF_RegWrite: in std_logic;
            EX_MEM_Rt: in std_logic_vector(2 downto 0);
            WB_BUF_RegDst: in std_logic_vector(2 downto 0);
            MEM_WB_RegDst: in std_logic_vector(2 downto 0);
            MEM_WB_RegData: in std_logic_vector(15 downto 0);
            WB_BUF_RegData: in std_logic_vector(15 downto 0)
        );
    end component;
    
--Signals
    
    --generated by control unit
    signal C_RegWrite: std_logic;
    signal C_RegWriteValid: std_logic; -- validated with an MPG output
    signal C_RegDst: std_logic;
    signal C_ExtOp: std_logic;
    signal C_ALUSrc: std_logic;
    signal C_Branch: std_logic;
    signal C_Jump: std_logic;
    signal C_MemRead: std_logic;
    signal C_MemWrite: std_logic;
    signal C_MemWriteEnable: std_logic;
    signal C_MemToReg: std_logic;
    signal C_ALUOp: std_logic_vector(1 downto 0);    

    --control unit signal after flush MUX
    signal MUXOut_C_RegWrite: std_logic;
    signal MUXOut_C_RegWriteValid: std_logic; -- validated with an MPG output
    signal MUXOut_C_RegDst: std_logic;
    signal MUXOut_C_ExtOp: std_logic;
    signal MUXOut_C_ALUSrc: std_logic;
    signal MUXOut_C_Branch: std_logic;
    signal MUXOut_C_Jump: std_logic;
    signal MUXOut_C_MemRead: std_logic;
    signal MUXOut_C_MemWrite: std_logic;
    signal MUXOut_C_MemWriteEnable: std_logic;
    signal MUXOut_C_MemToReg: std_logic;
    signal MUXOut_C_ALUOp: std_logic_vector(1 downto 0);    
    
    --outputs of IF
    signal IF_instruction: std_logic_vector(15 downto 0);
    signal IF_pc_plus_one: std_logic_vector(15 downto 0);
    signal IF_curr_pc: std_logic_vector(3 downto 0);
    signal IF_prediction: std_logic;
    
    --outputs of ID
    signal ID_rd1: std_logic_vector(15 downto 0); 
    signal ID_rd2: std_logic_vector(15 downto 0);
    signal ID_ext_imm: std_logic_vector(15 downto 0);
    signal ID_Branch_Taken: std_logic;
    signal ID_Branch_Address: std_logic_vector(15 downto 0);
    signal ID_sa: std_logic;
    signal ID_func: std_logic_vector(2 downto 0); 
    signal ID_wr_addr1: std_logic_vector(2 downto 0);
    signal ID_wr_addr2: std_logic_vector(2 downto 0);
    signal IF_ID_WriteEn: std_logic;
    signal Ctrl_Sel: std_logic;
    signal PC_Enable: std_logic;
    
    --outputs of EX
    signal EX_ALU_out: std_logic_vector(15 downto 0);
    signal EX_wr_addr: std_logic_vector(2 downto 0);
    
    --outputs of MEM
    signal MEM_ALU_out: std_logic_vector(15 downto 0);
    signal MEM_data_out: std_logic_vector(15 downto 0);    
    
    --outputs of WB
    signal WB_w_data: std_logic_vector(15 downto 0);
    
    --misc
    signal Flush: std_logic;
    
-- Pipeline registers
    signal IF_ID: std_logic_vector(36 downto 0);
    
    -- MSB                  LSB
    --  ----------------------
    -- | Instruction | PC + 1 | 
    --  ----------------------
    -- 31           15       0
    
    -- *** Dynamic Branch Prediction add-ons
    --  -----------------------
    -- | MSB_Pred | Current_PC |
    --  -----------------------
    
    signal ID_EX: std_logic_vector(88 downto 0);
    
    -- MSB                                                                                                 LSB
    --  -------------------------------------------------------------------------------------------------------
    -- | WB CTRL |  MEM CTRL | EX CTRL | PC + 1 |   RD1   |   RD2   | EXT_IMM | Wr_Add1 | Wr_addr2 | sa | func |
    --  -------------------------------------------------------------------------------------------------------
    -- 82       80           77       73       57        41         25        9         6          3    2      0
    
    -- *** FWD Unit Add-on   
    --  --------------------------
    -- | RS Address | RT Address | WB CTRL ...
    --  --------------------------
    -- 88          85            82
   
    --  WB CTRL:
    --      82 : MemToReg
    --      81 : RegWrite
  
    --  MEM CTRL:
    --      80 : MemRead
    --      79 : MemWrite
    --      78 : Branch
    
    --  EX CTRL:
    --      77 downto 76 : ALUOp
    --      75 : ALUSrc
    --      74 : RegDst
    
    signal EX_MEM: std_logic_vector(59 downto 0);
    
    -- MSB                                                                             LSB
    --  --------------------------------------------------------------------------------------
    --  | WB CTRL | MEM CTRL |  Branch_addr  |  Zero  | ALU_out |   RD2   |   Wr_Add_chosen   |    
    --  --------------------------------------------------------------------------------------
    --  56       54          51              35        34        18        2                   0
    
    -- *** MEM FWD Unit Add-on   
    --  --------------------------
    -- | RT Address | WB CTRL ...
    --  --------------------------
    -- 59          56
    
    signal MEM_WB: std_logic_vector(36 downto 0);
    
    -- MSB                                              LSB
    --  ---------------------------------------------------
    -- | WB CTRL | Wr_Add_chosen | MEM Data Out |  ALU Out | 
    --  ---------------------------------------------------
    -- 36        34             31             15         0
    
    signal WB_BUF: std_logic_vector(19 downto 0); -- save the WB data for MEM FWD unit
    
    -- *** MEM FWD Unit Add-on
    -- MSB
    --  -----------------------------------------------
    -- | RegWrite | Wr_Add_chosen | Write_Back_MUX_Out | 
    --  -----------------------------------------------
    -- 19         18             15                    0
       
begin

    IF_connect: IF_unit port map (
        clk100MHz => clk,
        jump_addr => ID_ext_imm,
        branch_addr => ID_Branch_Address,
        jump_ctrl => MUXOut_C_Jump,
        PCsrc_ctrl => ID_Branch_Taken,
        reset_pc => reset,
        enable_pc => PC_Enable, -- TODO: If you want to test on the board replace with an and between board button and PC_Enable
        instruction => IF_instruction,
        pc_plus_one  => IF_pc_plus_one,
        ID_pc_plus_one => IF_ID(15 downto 0),
        ID_prv_pc => IF_ID(35 downto 32),
        ID_Flush => Flush,
        ID_Branch_Taken => ID_Branch_Taken,
        ID_Pred => IF_ID(36),
        ID_Branch_Instruction => MUXOut_C_Branch, 
        prediction => IF_prediction,
        curr_pc => IF_curr_pc    
    );
    
    if_id_flush_detection: Flush <= ID_Branch_Taken xor IF_ID(36); -- TODO: add xor with the branch prediction bit
    
    pl_IF_ID: process(reset, clk) is 
    begin
        if reset = '1' then
            IF_ID(36 downto 0) <= (others => '0');
        elsif rising_edge(clk) then
            if Flush = '1' then
                IF_ID(36 downto 0) <= (others => '0');    
            elsif IF_ID_WriteEn = '1' then
                IF_ID(36) <= IF_prediction;
                IF_ID(35 downto 32) <= IF_curr_pc;
                IF_ID(31 downto 16) <= IF_instruction;
                IF_ID(15 downto 0) <= IF_pc_plus_one;
            end if;
        end if;
    end process;    
    
    ID_connect: ID_unit port map (
        clk100MHz => clk,
        instruction => IF_ID(31 downto 16),
        wd => WB_w_data,
        RegWrite => MEM_WB(35),
        RegDstAddress => MEM_WB(34 downto 32), 
        ExtOp => MUXOut_C_ExtOp,
        rd1 => ID_rd1,
        rd2 => ID_rd2,
        ext_imm => ID_ext_imm,
        func => ID_func,
        sa => ID_sa,
        write_address_1 => ID_wr_addr1,
        write_address_2 => ID_wr_addr2,
        ID_EX_MemRead => ID_EX(80),
        ID_EX_Rt => ID_EX(85 downto 83),
        IF_ID_WriteEn => IF_ID_WriteEn,
        Ctrl_Sel => Ctrl_Sel,
        PC_Enable => PC_Enable,
        pc_nxt => IF_ID(15 downto 0),
        Branch_instruction => MUXOut_C_Branch,
        Branch_Taken => ID_Branch_Taken,
        Branch_Address => ID_Branch_Address
    );
    
    CU_connect: ctrl_unit port map(
        opcode => IF_ID(31 downto 29),
        func => IF_ID(18 downto 16),
        RegDst => C_RegDst,
        ExtOp => C_ExtOp,
        ALUSrc => C_ALUSrc,
        Branch => C_Branch,
        Jump => C_Jump,
        ALUOp => C_ALUOp,
        MemRead => C_MemRead,
        MemWrite => C_MemWrite,
        MemtoReg => C_MemToReg,
        RegWrite => C_RegWrite
    );
    
    CU_flush_MUX: process (Ctrl_Sel, C_RegDst, C_ExtOp, C_ALUSrc, C_Branch, C_Jump, C_ALUOp, C_MemRead, C_MemWrite, C_MemToReg, C_RegWrite) is
    begin
        if Ctrl_Sel = '0' then
            MUXOut_C_RegWrite <= '0';
            MUXOut_C_RegWriteValid <= '0';
            MUXOut_C_RegDst <= '0';
            MUXOut_C_ExtOp <= '0';
            MUXOut_C_ALUSrc <= '0';
            MUXOut_C_Branch <= '0';
            MUXOut_C_Jump <= '0';
            MUXOut_C_MemRead <= '0';
            MUXOut_C_MemWrite <= '0';
            MUXOut_C_MemWriteEnable <= '0';
            MUXOut_C_MemToReg <= '0';
            MUXOut_C_ALUOp <= "11"; -- no operation
        else
            MUXOut_C_RegWrite <= C_RegWrite;
            MUXOut_C_RegWriteValid <= C_RegWriteValid;
            MUXOut_C_RegDst <= C_RegDst;
            MUXOut_C_ExtOp <= C_ExtOp;
            MUXOut_C_ALUSrc <= C_ALUSrc;
            MUXOut_C_Branch <= C_Branch;
            MUXOut_C_Jump <= C_Jump;
            MUXOut_C_MemRead <= C_MemRead;
            MUXOut_C_MemWrite <= C_MemWrite;
            MUXOut_C_MemWriteEnable <= C_MemWriteEnable;
            MUXOut_C_MemToReg <= C_MemToReg;
            MUXOut_C_ALUOp <= C_ALUOp;
        end if;
    end process;
    
    pl_ID_EX: process(reset, clk) is
    begin
        if reset = '1' then
            ID_EX(88 downto 0) <= (others => '0');
        elsif rising_edge(clk) then
            ID_EX(88 downto 86)<= IF_ID(28 downto 26); -- RS
            ID_EX(85 downto 83) <= IF_ID(25 downto 23); -- RT
            ID_EX(82) <= MUXOut_C_MemToReg;
            ID_EX(81) <= MUXOut_C_RegWrite;
            ID_EX(80) <= MUXOut_C_MemRead;
            ID_EX(79) <= MUXOut_C_MemWrite;
            ID_EX(78) <= MUXOut_C_Branch;
            ID_EX(77 downto 76) <= MUXOut_C_ALUOp;
            ID_EX(75) <= MUXOut_C_ALUSrc;
            ID_EX(74) <= MUXOut_C_RegDst;
            ID_EX(73 downto 58) <= IF_ID(15 downto 0);
            ID_EX(57 downto 42) <= ID_rd1;
            ID_EX(41 downto 26) <= ID_rd2;
            ID_EX(25 downto 10) <= ID_ext_imm;
            ID_EX(9 downto 7) <= ID_wr_addr1;
            ID_EX(6 downto 4) <= ID_wr_addr2;
            ID_EX(3) <= ID_sa;
            ID_EX(2 downto 0) <= ID_func;
        end if;
    end process;
    
    EX_connect: EX_unit port map (
        next_pc => ID_EX(73 downto 58),
        rd1 => ID_EX(57 downto 42),
        rd2 => ID_EX(41 downto 26),
        ALUSrc => ID_EX(75),
        ext_imm => ID_EX(25 downto 10),
        sa => ID_EX(3),
        func => ID_EX(2 downto 0),
        ALUOp => ID_EX(77 downto 76),
        ALURes => EX_ALU_out,
        EX_MEM_ALUOut => EX_MEM(34 downto 19),
        MEM_WB_ALUOut => WB_w_data, -- modified to work for load dependency as well
        EX_MEM_RegWrite => EX_MEM(55),
        MEM_WB_RegWrite => MEM_WB(35),
        EX_MEM_RegDst => EX_MEM(2 downto 0),
        MEM_WB_RegDst => MEM_WB(34 downto 32),
        ID_EX_Rs => ID_EX(88 downto 86),
        ID_EX_Rt => ID_EX(85 downto 83)
    );
    
    mux_wr_addr_choice: EX_wr_addr <= 
        ID_EX(9 downto 7) when ID_EX(74) = '0' 
        else ID_EX(6 downto 4);
    
    pl_EX_MEM: process(reset, clk) is
    begin
        if reset = '1' then
            EX_MEM(59 downto 0) <= (others => '0');
        elsif rising_edge(clk) then
            EX_MEM(59 downto 57) <= ID_EX(85 downto 83); -- RT address
            EX_MEM(56 downto 55) <= ID_EX(82 downto 81);
            EX_MEM(54 downto 52) <= ID_EX(80 downto 78);
            EX_MEM(51 downto 36) <= x"0000"; -- TODO: remove later
            EX_MEM(35) <= '0'; -- TODO: remove later
            EX_MEM(34 downto 19) <= EX_ALU_out;
            EX_MEM(18 downto 3) <= ID_EX(41 downto 26);
            EX_MEM(2 downto 0) <= EX_wr_addr;
        end if;    
    end process;
    
    MEM_connect: MEM_unit port map(
        clk100MHz => clk,
        MemWrite => EX_MEM(53),
        MemRead => EX_MEM(54), 
        ALURes => EX_MEM(34 downto 19), 
        RD2 => EX_MEM(18 downto 3),
        ALURes_out => MEM_ALU_out,
        MemData => MEM_data_out,
        MEM_WB_RegWrite => MEM_WB(35),
        WB_BUF_RegWrite => WB_BUF(19),
        EX_MEM_Rt => EX_MEM(59 downto 57),
        WB_BUF_RegDst => WB_BUF(18 downto 16),
        MEM_WB_RegDst => MEM_WB(34 downto 32),
        MEM_WB_RegData => WB_w_data,
        WB_BUF_RegData => WB_BUF(15 downto 0)
    );
    
    pl_MEM_WB: process(reset, clk) is
    begin
        if reset = '1' then
            MEM_WB(36 downto 0) <= (others => '0');
        elsif rising_edge(clk) then
            MEM_WB(36 downto 35) <= EX_MEM(56 downto 55);
            MEM_WB(34 downto 32) <= EX_MEM(2 downto 0);
            MEM_WB(31 downto 16) <= MEM_data_out;
            MEM_WB(15 downto 0) <= MEM_ALU_out;
        end if;
    end process;
    
    WB_unit: WB_w_data <= 
        MEM_WB(31 downto 16) when MEM_WB(36) = '1'
        else MEM_WB(15 downto 0);
        
    pl_WB_BUF: process(reset, clk) is
    begin
        if reset = '1' then
            WB_BUF(19 downto 0) <= (others => '0');
        elsif rising_edge(clk) then
            WB_BUF(19) <= MEM_WB(35);
            WB_BUF(18 downto 16) <= MEM_WB(34 downto 32);
            WB_BUF(15 downto 0) <= WB_w_data;
        end if;
    end process;
    
end Behavioral;
 