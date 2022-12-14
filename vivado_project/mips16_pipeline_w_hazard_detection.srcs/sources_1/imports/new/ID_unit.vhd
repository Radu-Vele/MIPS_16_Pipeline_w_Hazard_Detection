----------------------------------------------------------------------------------
-- Company: TUCN
-- Engineer: Radu-Augustin Vele
-- 
-- Create Date: 03/25/2022 02:16:35 PM
-- Design Name: 
-- Module Name: ID_unit - Behavioral
-- Project Name: MIPS 16 Pipeline with Hazard Detection and Avoidance
-- Target Devices: Basys 3
-- Tool Versions: 
-- Description: Instruction Decode unit
-- 
-- Dependencies: Register file module
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Revision 1 - Adapted for MIPS 16 Pipeline with Hazard detection and Avoidance
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ID_unit is
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
        --*** HDU Add-on
        ID_EX_MemRead: in std_logic;
        ID_EX_Rt: in std_logic_vector(2 downto 0);
        IF_ID_WriteEn: out std_logic;
        Ctrl_Sel: out std_logic;
        PC_Enable: out std_logic;
        --*** BranchDet Add-on
        pc_nxt: in std_logic_vector(15 downto 0);
        Branch_instruction: in std_logic;
        Branch_Taken: out std_logic;
        Branch_Address: out std_logic_vector(15 downto 0);
        EX_WrAddrChosen: in std_logic_vector(2 downto 0);
        ID_EX_RegWrite: in std_logic; 
        -- *** FWD Add-on
        EX_MEM_RegWrite: in std_logic;
        EX_MEM_RegDst: in std_logic_vector(2 downto 0);
        EX_MEM_ALUOut: in std_logic_vector(15 downto 0)
        
    );
end ID_unit;

architecture Behavioral of ID_unit is
    component reg_file is
        port (
            read_address2: in STD_LOGIC_VECTOR(2 downto 0);
            read_address1: in STD_LOGIC_VECTOR(2 downto 0);
            write_address: in STD_LOGIC_VECTOR(2 downto 0); --Addresses coming from the counter
            write_data: in STD_LOGIC_VECTOR(15 downto 0);
            reg_write: in STD_LOGIC;
            clk100MHz: in STD_LOGIC;
            read_data1: out STD_LOGIC_VECTOR(15 downto 0);
            read_data2: out STD_LOGIC_VECTOR(15 downto 0));
    end component;
    
    component hazard_det_unit is
        Port (
            ID_Rs: in std_logic_vector(2 downto 0); 
            ID_Rt: in std_logic_vector(2 downto 0); 
            ID_EX_Rt: in std_logic_vector(2 downto 0);
            ID_EX_MemRead: in std_logic; 
            Branch_instruction: in std_logic;
            ID_EX_RegWrite: in std_logic;
            EX_MEM_RegWrite: in std_logic;
            EX_WrAddrChosen: in std_logic_vector(2 downto 0);
            EX_MEM_WrAddrChosen: in std_logic_vector(2 downto 0);
            IF_ID_WriteEn: out std_logic;
            Ctrl_Sel: out std_logic;
            PC_Enable: out std_logic
        );
    end component;    
    
    component id_fwd_unit is
        Port(
            EX_MEM_RegWrite: in std_logic;
            EX_MEM_RegDst: in std_logic_vector(2 downto 0);
            ID_Branch: in std_logic;
            ID_Rs: in std_logic_vector(2 downto 0);
            ID_Rt: in std_logic_vector(2 downto 0);
            ForwardA: out std_logic;
            ForwardB: out std_logic
        );
    end component;
    
    signal mux_outp: std_logic_vector(2 downto 0);  
    signal temp_rd1: std_logic_vector(15 downto 0);  
    signal temp_rd2: std_logic_vector(15 downto 0);  
    signal eq_det_inA: std_logic_vector(15 downto 0);  
    signal eq_det_inB: std_logic_vector(15 downto 0);  
    signal temp_ext_imm: std_logic_vector(15 downto 0); 
    signal ForwardA: std_logic; 
    signal ForwardB: std_logic;
begin
    
    write_address_1 <= instruction(9 downto 7);
    write_address_2 <= instruction (6 downto 4);
    
    reg_file_connection: reg_file port map(
        read_address2 => instruction(9 downto 7),
		read_address1 => instruction(12 downto 10),
		write_address => RegDstAddress,
		write_data => wd,
		reg_write => RegWrite,
		clk100MHz => clk100MHz,
		read_data1 => temp_rd1,
		read_data2 => temp_rd2);
    
    rd1 <= temp_rd1;
    rd2 <= temp_rd2;
    
    muxEqDetA: eq_det_inA <= EX_MEM_ALUOut when ForwardA = '1' else temp_rd1;
    muxEqDetB: eq_det_inB <= EX_MEM_ALUOut when ForwardB = '1' else temp_rd2;
    
    branch_taken_generation: process(eq_det_inA, eq_det_inB, instruction, Branch_instruction) is 
    begin        
        if Branch_instruction = '1' then
            if (eq_det_inA = eq_det_inB) and instruction(15 downto 13) = "100" then --beq
                Branch_Taken <= '1';
            elsif (not (eq_det_inA = eq_det_inB)) and instruction(15 downto 13) = "110" then --bneq
                Branch_Taken <= '1';
            else
                Branch_Taken <= '0';
            end if;
        else 
            Branch_Taken <= '0';
        end if;
    end process;
    
    branch_addr_adder: Branch_Address <= temp_ext_imm + pc_nxt;
    
    extender_unit: temp_ext_imm <= x"00" & '0' & instruction(6 downto 0) when ExtOp = '0' else
               x"FF" & '1' & instruction(6 downto 0) when instruction(6) = '1' else
               x"00" & '0'& instruction(6 downto 0);
    
    ext_imm <= temp_ext_imm; 
    func <= instruction(2 downto 0);
    sa <= instruction(3);
    
    stall_hazard_detection: hazard_det_unit port map (
        ID_Rs => instruction(12 downto 10), 
        ID_Rt => instruction(9 downto 7),
        ID_EX_Rt => ID_EX_Rt,
        ID_EX_MemRead => ID_EX_MemRead,
        Branch_instruction => Branch_instruction,
        ID_EX_RegWrite => ID_EX_RegWrite,
        EX_MEM_RegWrite => EX_MEM_RegWrite,
        EX_WrAddrChosen => EX_WrAddrChosen,
        EX_MEM_WrAddrChosen => EX_MEM_RegDst,
        IF_ID_WriteEn => IF_ID_WriteEn,
        Ctrl_Sel => Ctrl_Sel,
        PC_Enable => PC_Enable
    );
    
    hazard_detection_fwd: id_fwd_unit port map (
        EX_MEM_RegWrite => EX_MEM_RegWrite,
        EX_MEM_RegDst => EX_MEM_RegDst,
        ID_Branch => Branch_Instruction,
        ID_Rs => instruction(12 downto 10),
        ID_Rt => instruction(9 downto 7),
        ForwardA => ForwardA,
        ForwardB => ForwardB
    );
    
end Behavioral;
