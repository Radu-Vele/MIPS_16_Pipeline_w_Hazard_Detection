----------------------------------------------------------------------------------
-- Company: TUCN
-- Engineer: Radu-Augustin Vele
-- 
-- Create Date: 12/12/2022 09:13:06 AM
-- Design Name: 
-- Module Name: hazard_det_unit - Behavioral
-- Project Name: MIPS 16 Pipeline with Hazard Detection and Avoidance
-- Target Devices: Basys3
-- Tool Versions: 
-- Description: Detects the Load Data Hazard and inserts a stall. Additionally adds stalls related
--    to the branch condition checking in the ID stage
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity hazard_det_unit is
    Port (
        ID_Rs: in std_logic_vector(2 downto 0); 
        ID_Rt: in std_logic_vector(2 downto 0); 
        ID_EX_Rt: in std_logic_vector(2 downto 0);
        ID_EX_MemRead: in std_logic; 
        Branch_instruction: in std_logic;
        ID_EX_RegWrite: in std_logic;
        EX_MEM_RegWrite: in std_logic;
        EX_WrAddrChosen: in std_logic_vector(2 downto 0); -- from EX unit
        EX_MEM_WrAddrChosen: in std_logic_vector(2 downto 0); -- from MEM unit
        IF_ID_WriteEn: out std_logic;
        Ctrl_Sel: out std_logic;
        PC_Enable: out std_logic
    );
end hazard_det_unit;

architecture Behavioral of hazard_det_unit is

begin
    hazard_det: process(ID_Rs, ID_Rt, ID_EX_Rt, ID_EX_MemRead, ID_EX_RegWrite, Branch_instruction, EX_WrAddrChosen, EX_MEM_RegWrite, EX_MEM_WrAddrChosen) is
    begin
        IF_ID_WriteEn <= '1';
        Ctrl_Sel <= '1';
        PC_Enable <= '1';
        
        -- load data hazard
        if ID_EX_MemRead = '1' and (ID_Rs = ID_EX_Rt or ID_Rt = ID_EX_Rt) then
            IF_ID_WriteEn <= '0';
            Ctrl_Sel <= '0';
            PC_Enable <= '0';                    
        end if;
        
        -- branch dependencies
        if (ID_EX_RegWrite = '1' and Branch_instruction = '1') and (ID_Rs = EX_WrAddrChosen or ID_Rt = EX_WrAddrChosen) then
            IF_ID_WriteEn <= '0';
            Ctrl_Sel <= '0';
            PC_Enable <= '0'; 
        end if;   
        
        if(EX_MEM_RegWrite = '1' and Branch_instruction = '1') and (ID_Rs = EX_MEM_WrAddrChosen or ID_Rt = EX_MEM_WrAddrChosen) then
            IF_ID_WriteEn <= '0';
            Ctrl_Sel <= '0';
            PC_Enable <= '0'; 
        end if;        
    end process;
end Behavioral;
