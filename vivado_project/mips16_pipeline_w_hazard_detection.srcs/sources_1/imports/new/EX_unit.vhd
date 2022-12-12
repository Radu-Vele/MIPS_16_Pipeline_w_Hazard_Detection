----------------------------------------------------------------------------------
-- Company: TUCN
-- Engineer: Radu-Augustin Vele
-- 
-- Create Date: 04/01/2022 11:34:52 AM
-- Design Name: 
-- Module Name: EX_unit - Behavioral
-- Project Name: MIPS 16
-- Target Devices: Basys 3
-- Tool Versions: 2020.1
-- Description: Execution unit for the mips - takes the data resulting from the Instruction decode, makes the necessary
-- computations and gives back some results
-- 
-- Dependencies: no dependencies
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity EX_unit is
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
end EX_unit;

architecture Behavioral of EX_unit is

    component EX_fwd_unit is
        Port (
            EX_MEM_RegWrite: in std_logic;
            MEM_WB_RegWrite: in std_logic;
            EX_MEM_RegDst: in std_logic_vector(2 downto 0);
            MEM_WB_RegDst: in std_logic_vector(2 downto 0);
            ID_EX_Rs: in std_logic_vector(2 downto 0);
            ID_EX_Rt: in std_logic_vector(2 downto 0);
            ForwardA: out std_logic_vector (1 downto 0);
            ForwardB: out std_logic_vector (1 downto 0)
        );
    end component;
    signal ALUCtrl: std_logic_vector (2 downto 0);
    signal tmp_res: std_logic_vector (15 downto 0);
    
    signal ForwardA: std_logic_vector (1 downto 0);
    signal ForwardB: std_logic_vector (1 downto 0);
    signal FWD_B_Out: std_logic_vector (15 downto 0);

    signal ALU_input_A: std_logic_vector (15 downto 0);
    signal ALU_input_B: std_logic_vector (15 downto 0);
begin
    
    hazard_detection: EX_fwd_unit port map (
        EX_MEM_RegWrite => EX_MEM_RegWrite,
        MEM_WB_RegWrite => MEM_WB_RegWrite,
        EX_MEM_RegDst => EX_MEM_RegDst,
        MEM_WB_RegDst => MEM_WB_RegDst,
        ID_EX_Rs => ID_EX_Rs,
        ID_EX_Rt => ID_EX_Rt,
        ForwardA => ForwardA,
        ForwardB => ForwardB
    ); 
     
    MUX_FWD_A: process (ForwardA, EX_MEM_ALUOut, MEM_WB_ALUOut, rd1)
        begin
           case ForwardA is
              when "00" => ALU_input_A <= rd1;
              when "01" => ALU_input_A <= EX_MEM_ALUOut;
              when "10" => ALU_input_A <= MEM_WB_ALUOut;
              when others => ALU_input_A <= rd1;
           end case;
    end process;
                              
    MUX_FWD_B: process (ForwardB, EX_MEM_ALUOut, MEM_WB_ALUOut, rd1, rd2)
        begin
           case ForwardB is
              when "00" => FWD_B_Out <= rd2;
              when "01" => FWD_B_Out <= EX_MEM_ALUOut;
              when "10" => FWD_B_Out <= MEM_WB_ALUOut;
              when others => FWD_B_Out <= rd2;
           end case;
    end process;
        
    input1_MUX: ALU_input_B <= ext_imm when ALUSrc = '1' else FWD_B_Out;   
        
    ALU_control: process(func, ALUOp)
    begin
        if ALUOp = "10" then -- we deal with R-type
            case (func) is
                when "001" => ALUCtrl <= "001"; --addition 
                when "010" => ALUCtrl <= "010"; --subtraction
                when "011" => ALUCtrl <= "011"; --sll 
                when "100" => ALUCtrl <= "100"; --srl 
                when "101" => ALUCtrl <= "101"; --and 
                when "110" => ALUCtrl <= "110"; --or
                when "111" => ALUCtrl <= "111"; --xor
                when others => ALUCtrl <= "000"; --default
            end case;         
        else
            case(ALUOp) is 
                when "00" => ALUCtrl <= "001"; -- addition
                when "10" => ALUCtrl <= "010"; -- subtraction for subi
                when others => ALUCtrl <= "000";
            end case;
        end if;
    end process;
    
    ALU_component: process(ALUCtrl, ALU_input_A, ALU_input_B, sa, ext_imm)
    begin
        case(ALUCtrl) is 
            when "001" => tmp_res <= ALU_input_A + ALU_input_B; --addition
            when "010" => tmp_res <= ALU_input_A - ALU_input_B; --subtraction
            when "011" => -- sll
                if(sa = '1') then
                    tmp_res <= ALU_input_A(14 downto 0) & '0';
                else
                    tmp_res <= ALU_input_A;
                end if;
            when "100" => --srl
                if(sa = '1') then
                    tmp_res <= '0' & ALU_input_A(15 downto 1);
                else
                    tmp_res <= ALU_input_A;
                end if;
            when "101" => tmp_res <= ALU_input_A and ALU_input_B;
            when "110" => tmp_res <= ALU_input_A or ALU_input_B;
            when "111" => tmp_res <= ALU_input_A xor ALU_input_B;
            when others => tmp_res <= x"0000";
        end case;
    end process;

    --outputs assignment
    ALURes <= tmp_res;    
end Behavioral;
