----------------------------------------------------------------------------------
-- Company: TUCN
-- Engineer: Radu-Augustin Vele
-- 
-- Create Date: 02/22/2022 05:21:03 PM
-- Design Name: test_env
-- Module Name: test_env
-- Project Name: MIPS 16 Pipeline with Hazard Detection and Avoidance
-- Target Devices: Basys 3
-- Tool Versions: 2020.1
-- Description: MIPS 16 implemented using pipelining with integrated logic
--              that detects and solves hazard situations.
--
-- Dependencies: -
-- 
-- Revision: A
-- Revision A.1 - Instruction Fetch Unit + Decode + CTRL signals
-- Revision B - Added the source files from Mips16 project to the Mips16 Hazard Detection and Avoidance project
-- Additional   Comments:
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.std_logic_unsigned.ALL;
use IEEE.numeric_std.ALL;

entity test_env is
    Port ( 
        clk100MHz : in std_logic; 
        btn_en: in std_logic; -- PC enable
        btn_reset: in std_logic; -- PC sync reset
        btn_MemWrite: in std_logic; -- validate writing in memory
        btn_RegWrite: in std_logic; -- validate writing in register (avoid infinite writing)
        an : out std_logic_vector (3 downto 0); 
        cat : out std_logic_vector (6 downto 0);   
        sw : in std_logic_vector (7 downto 0); -- util switches
        led_out : out std_logic_vector (7 downto 0)); -- LEDS for control Outputs 
end test_env;

architecture Behavioral of test_env is
    signal in_btn: std_logic_vector(4 downto 0);
    signal mpg_outp: std_logic_vector(4 downto 0);
    
    -- 16-bit signals
    signal ins_outp: std_logic_vector(15 downto 0);
    signal addr_outp: std_logic_vector(15 downto 0);
    signal tmp_output: std_logic_vector(15 downto 0);
    signal adder_outp: std_logic_vector (15 downto 0);
    signal read_data_1: std_logic_vector(15 downto 0);
    signal read_data_2: std_logic_vector(15 downto 0);
    signal ext_imm: std_logic_vector(15 downto 0);
    signal branch_address: std_logic_vector(15 downto 0);
    signal ALU_result: std_logic_vector(15 downto 0);
    signal wb_mem: std_logic_vector (15 downto 0);
    signal wb_ALU: std_logic_vector (15 downto 0);
    signal write_data: std_logic_vector (15 downto 0);
    
    --Control Signals
    signal RegWrite: std_logic;
    signal RegWriteValid: std_logic; -- validated with an MPG output
    signal RegDst: std_logic;
    signal ExtOp: std_logic;
    signal ALUSrc: std_logic;
    signal Branch: std_logic;
    signal Jump: std_logic;
    signal MemWrite: std_logic;
    signal MemWriteEnable: std_logic;
    signal MemtoReg: std_logic;
    signal ALUOp: std_logic_vector(1 downto 0);
    signal zero: std_logic;
    signal PCSrc_ctrl: std_logic;
    signal ltzero: std_logic;
    
    -- Instruction components    
    signal func: std_logic_vector(2 downto 0);
    signal sa: std_logic;
    
    -- Pipeline registers signals
    signal REG_IF_ID: std_logic_vector(31 downto 0);
    signal REG_ID_EX: std_logic_vector(65 downto 0);
    signal REG_EX_MEM: std_logic_vector(56 downto 0);
    signal REG_MEM_WB: std_logic_vector(36 downto 0);
    
    -- Other signals
    signal write_address_1: std_logic_vector(2 downto 0);
    signal write_address_2: std_logic_vector(2 downto 0);
    signal write_address_chosen: std_logic_vector(2 downto 0);

    
    component mono_pulse_gen
        Port (
            clk : in STD_LOGIC;
            btn : in std_logic_vector (4 downto 0);
            enable : out std_logic_vector (4 downto 0));
    end component;
    
    component ID_unit
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
            write_address_2: out std_logic_vector(2 downto 0));
    end component;
    
    component ctrl_unit
      Port ( 
        opcode: in std_logic_vector (2 downto 0);
        RegDst: out std_logic;
        ExtOp: out std_logic;
        ALUSrc: out std_logic;
        Branch: out std_logic;
        Jump: out std_logic;
        ALUOp: out std_logic_vector(1 downto 0);
        MemWrite: out std_logic;
        MemtoReg: out std_logic;
        RegWrite: out std_logic);
    end component;
    
    --seven segment display
    component ssd
        Port ( 
            digit0: in STD_LOGIC_VECTOR(3 downto 0);
            digit1: in STD_LOGIC_VECTOR(3 downto 0);
            digit2: in STD_LOGIC_VECTOR(3 downto 0);
            digit3: in STD_LOGIC_VECTOR(3 downto 0);
            clk: in STD_LOGIC;
            cat: out STD_LOGIC_VECTOR(6 downto 0);
            an: out STD_LOGIC_VECTOR (3 downto 0));
    end component;
    
    component IF_unit
        Port (
            clk100MHz: in std_logic;
            jump_addr: in std_logic_vector(15 downto 0);
            branch_addr: in std_logic_vector(15 downto 0);
            jump_ctrl: in std_logic;
            PCsrc_ctrl: in std_logic;
            reset_pc: in std_logic;
            enable_pc: in std_logic;
            instruction: out std_logic_vector(15 downto 0);
            nxt_pc: out std_logic_vector(15 downto 0));
    end component;
    
    component EX_unit
        Port(
            next_pc: in std_logic_vector(15 downto 0);
            rd1: in std_logic_vector(15 downto 0); 
            rd2: in std_logic_vector(15 downto 0);
            ALUSrc: in std_logic;
            ext_imm: in std_logic_vector(15 downto 0);
            sa: in std_logic;
            func: in std_logic_vector(2 downto 0);
            ALUOp: in std_logic_vector(1 downto 0);
            branch_address: out std_logic_vector(15 downto 0);
            zero: out std_logic;
            ltzero: out std_logic;
            ALURes: out std_logic_vector (15 downto 0));
    end component;
    
    component mem_unit
        Port(
            clk100MHz: in std_logic;
            MemWrite: in std_logic;
            ALURes: in std_logic_vector (15 downto 0);
            RD2: in std_logic_vector (15 downto 0);
            ALURes_out: out std_logic_vector (15 downto 0);
            MemData: out std_logic_vector (15 downto 0)
        );
    end component;
    
begin    

    in_btn <= "0" & btn_MemWrite & btn_RegWrite & btn_en & btn_reset;

    mpg_connection: mono_pulse_gen port map(
        clk => clk100MHz,
        btn => in_btn,
        enable => mpg_outp);
        
    pcsrc_computation: PCSrc_ctrl <= (REG_EX_MEM(53) and REG_EX_MEM(36)) or (REG_EX_MEM(53) and REG_EX_MEM(35));
    
    if_connection: IF_unit port map(
            clk100MHz => clk100MHz,
            jump_addr => ext_imm,
            branch_addr => REG_EX_MEM(52 downto 37),
            jump_ctrl => Jump,
            PCsrc_ctrl => PCSrc_ctrl, 
            reset_pc => mpg_outp(0),
            enable_pc => mpg_outp(1),
            instruction => ins_outp,
            nxt_pc => addr_outp
    );
        
    register_write_enable: RegWriteValid <= REG_MEM_WB(35) and mpg_outp(2);
    
    -- Pipeline register ID_IF
    IF_ID: process (clk100MHz, mpg_outp(1)) is
    begin
        if rising_edge(clk100MHz) then
            if(mpg_outp(1) = '1') then
                REG_IF_ID(31 downto 16) <= addr_outp;
                REG_IF_ID(15 downto 0) <= ins_outp;
            end if;
        end if;
    end process;
    
    id_connection: ID_unit port map(
            clk100MHz => clk100MHz,
            instruction => REG_IF_ID(15 downto 0),
            wd => write_data,
            RegWrite => RegWriteValid,
            RegDstAddress => REG_MEM_WB(2 downto 0),
            ExtOp => ExtOp,
            rd1 => read_data_1,
            rd2 => read_data_2,
            ext_imm => ext_imm,
            func => func,
            sa => sa,
            write_address_1 => write_address_1,
            write_address_2 => write_address_2);
    
    ctrl_unit_connection: ctrl_unit port map(
        opcode => ins_outp(15 downto 13),
        RegDst => RegDst,
        ExtOp => ExtOp,
        ALUSrc => ALUSrc,
        Branch => Branch,
        Jump => Jump,
        ALUOp => ALUOp,
        MemWrite => MemWrite,
        MemtoReg => MemtoReg,
        RegWrite => RegWrite);
        
    -- Pipeline register ID_EX
    ID_EX: process(clk100MHz, mpg_outp(1)) is
    begin
        if (rising_edge(clk100MHz)) then
            if (mpg_outp(1) = '1') then
                REG_ID_EX(65) <= MemToReg;
                REG_ID_EX(64) <= RegWrite;
                REG_ID_EX(63) <= MemWrite;
                REG_ID_EX(62) <= Branch;
                REG_ID_EX(61 downto 60) <= ALUOp;
                REG_ID_EX(59) <= ALUSrc;
                REG_ID_EX(58) <= RegDst;
                REG_ID_EX(57 downto 42) <= REG_IF_ID(31 downto 16);
                REG_ID_EX(41 downto 26) <= read_data_1;
                REG_ID_EX(41 downto 26) <= read_data_2;
                REG_ID_EX(25 downto 10) <= ext_imm;
                REG_ID_EX(9 downto 7) <= func;
                REG_ID_EX(6) <= sa;
                REG_ID_EX(5 downto 3) <= write_address_1;
                REG_ID_EX(2 downto 0) <= write_address_2;
            end if;
        end if; 
    end process;
        
    exe_unit_connection: EX_unit port map(
            next_pc => REG_ID_EX(57 downto 42),
            rd1 => REG_ID_EX(41 downto 26), 
            rd2 => REG_ID_EX(41 downto 26),
            ALUSrc => REG_ID_EX(59),
            ext_imm => REG_ID_EX(25 downto 10),
            sa => REG_ID_EX(6),
            func => REG_ID_EX(9 downto 7),
            ALUOp => REG_ID_EX(61 downto 60),
            branch_address => branch_address, 
            zero => zero,
            ltzero => ltzero,
            ALURes => ALU_result);
    
    mux_wd_address: write_address_chosen <= REG_ID_EX(5 downto 3) when REG_ID_EX(58) = '0' else REG_ID_EX(2 downto 0);
    
    -- Pipeline register EX_MEM
    EX_MEM: process(clk100MHz, mpg_outp(1)) is
    begin
        if rising_edge(clk100MHz) then
            if (mpg_outp(1) = '1') then
                REG_EX_MEM(56) <= REG_ID_EX(65);
                REG_EX_MEM(55) <= REG_ID_EX(64);
                REG_EX_MEM(54) <= REG_ID_EX(63);
                REG_EX_MEM(53) <= REG_ID_EX(62);
                REG_EX_MEM(52 downto 37) <= branch_address;
                REG_EX_MEM(36) <= zero;
                REG_EX_MEM(35) <= ltzero;
                REG_EX_MEM(34 downto 19) <= ALU_result;
                REG_EX_MEM(18 downto 3) <= REG_ID_EX(41 downto 26);
                REG_EX_MEM(2 downto 0) <= write_address_chosen;
            end if;
        end if;        
    end process;
    
    
    
    mem_write_enable: MemWriteEnable <= REG_EX_MEM(54) and mpg_outp(3); --additional button for writing in memory
    
    mem_unit_connection: mem_unit port map (
        clk100MHz => clk100MHz,
        MemWrite => MemWriteEnable,
        ALURes => REG_EX_MEM(34 downto 19),
        RD2 => REG_EX_MEM(18 downto 3),
        ALURes_out => wb_ALU,
        MemData => wb_mem
    );
    
    -- Pipeline register MEM_WB
    MEM_WB: process(clk100MHz, mpg_outp(1)) is
    begin
        if rising_edge(clk100MHz) then
            if (mpg_outp(1) = '1') then
                REG_MEM_WB(36) <= REG_EX_MEM(56);
                REG_MEM_WB(35) <= REG_EX_MEM(55);
                REG_MEM_WB(34 downto 19) <= wb_mem;
                REG_MEM_WB(18 downto 3) <= wb_ALU;
                REG_MEM_WB(2 downto 0) <= REG_ID_EX(2 downto 0);
            end if;
        end if;        
    end process;
    
    write_back: write_data <= REG_MEM_WB(34 downto 19) when REG_MEM_WB(36) = '1' else REG_MEM_WB(18 downto 3);
        
    output_generation: process(sw, ins_outp, addr_outp, read_data_1, read_data_2, ALU_result) 
    begin
        case sw(7 downto 5) is
        when "000" => tmp_output <= ins_outp; 
        when "001" => tmp_output <= addr_outp;
        when "010" => tmp_output <= read_data_1;
        when "011" => tmp_output <= read_data_2;
        when "100" => tmp_output <= ext_imm;
        when "101" => tmp_output <= ALU_result;
        when "110" => tmp_output <= wb_mem;
        when "111" => tmp_output <= write_data;
        when others => tmp_output <= x"0000";
        end case;   
    end process;

    display: ssd port map(
        digit0 => tmp_output(3 downto 0),
        digit1 => tmp_output(7 downto 4),
        digit2 => tmp_output(11 downto 8),
        digit3 => tmp_output(15 downto 12),
        clk => clk100MHz,
        cat => cat,
        an => an);  
    
    led_out <= RegDst & ExtOp & ALUSrc & Branch & Jump & MemWrite & MemtoReg & RegWrite when sw(4) = '1' else
            "000000" & ALUOp;
              
     
end Behavioral;
