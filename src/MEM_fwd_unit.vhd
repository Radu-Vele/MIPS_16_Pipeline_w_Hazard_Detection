----------------------------------------------------------------------------------
-- Company: TUCN
-- Engineer: Radu-Augustin Vele
-- 
-- Create Date: 12/06/2022 09:50:42 AM
-- Design Name: 
-- Module Name: MEM_fwd_unit - Behavioral
-- Project Name: MIPS 16 Pipeline with Hazard detection and Avoidance
-- Target Devices: 
-- Tool Versions: 
-- Description: Forwarding unit to be placed in MEM stage
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity MEM_fwd_unit is
    Port (
        MEM_WB_RegWrite: in std_logic;
        WB_BUF_RegWrite: in std_logic;
        EX_MEM_MemWrite: in std_logic;
        EX_MEM_Rt: in std_logic_vector(2 downto 0);
        WB_BUF_RegDst: in std_logic_vector(2 downto 0);
        MEM_WB_RegDst: in std_logic_vector(2 downto 0);
        ForwardC: out std_logic_vector(1 downto 0)
    );
end MEM_fwd_unit;

architecture Behavioral of MEM_fwd_unit is

begin
    hazard_detect: process (WB_BUF_RegWrite, EX_MEM_Rt, WB_BUF_RegDst, EX_MEM_MemWrite, MEM_WB_RegWrite, MEM_WB_RegDst) is
    begin
        ForwardC <= "00";
        
        -- less priority
        if WB_BUF_RegWrite = '1' then 
            if EX_MEM_Rt = WB_BUF_RegDst and EX_MEM_MemWrite = '1' then
                ForwardC <= "10";
            end if;
        end if;
        
        -- more priority
        if MEM_WB_RegWrite = '1' then 
            if EX_MEM_Rt = MEM_WB_RegDst and EX_MEM_MemWrite = '1' then
                ForwardC <= "01";
            end if;
        end if;
        
    end process;

end Behavioral;
