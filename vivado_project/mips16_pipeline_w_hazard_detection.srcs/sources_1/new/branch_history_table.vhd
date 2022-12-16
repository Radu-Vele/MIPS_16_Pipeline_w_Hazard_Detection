----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/12/2022 07:45:26 PM
-- Design Name: 
-- Module Name: branch_history_table - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
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

entity branch_history_table is
    Port ( 
        clk: in std_logic; 
        address: in std_logic_vector(3 downto 0); -- current pc address
        update_data: in std_logic_vector(15 downto 0); -- new target address
        write_address: in std_logic_vector(3 downto 0); -- the pc address that corresponds to the new target
        inc_predictor: in std_logic;
        pc_enable: in std_logic; -- so the bht is not modified throughout stalls
        branch_instruction: in std_logic;
        flush: in std_logic;
        MSB_Pred: out std_logic;
        predicted_target: out std_logic_vector(15 downto 0)
    );
end branch_history_table;

architecture Behavioral of branch_history_table is
    type bht is array (0 to 15) of std_logic_vector(17 downto 0);
    
    --  ----------------------------
    -- | Predictor | Target Address |
    --  ----------------------------
    -- 17         15               0 
    
    signal curr_bht: bht := (
        B"00_0000000000000000",
        B"00_0000000000000000",
        B"00_0000000000000000",
        others => B"00_0000000000000000"
    );
    
begin
    --get predicted address
    predicted_target <= curr_bht(to_integer(unsigned(address)))(15 downto 0);
    MSB_pred <= curr_bht(to_integer(unsigned(address)))(17);
    
    --update table
    read_write_process: process (clk, write_address, inc_predictor, branch_instruction, update_data) is 
        variable curr_predictor: std_logic_vector(1 downto 0);
    begin
        curr_predictor := curr_bht(to_integer(unsigned(write_address)))(17 downto 16);
        
        if rising_edge(clk) and pc_enable = '1' then
            if branch_instruction = '1' then -- previous branch
                if inc_predictor = '1' then -- branch taken
                     if curr_predictor < "11" then
                        curr_predictor := curr_predictor + 1;
                     end if;
                else -- branch not taken
                    if curr_predictor > "00" then
                        curr_predictor := curr_predictor - 1;
                    end if;
                end if;
            end if;
            
            if flush = '1' and inc_predictor = '1' then -- the previous prediction was different from the outcome=branch taken
                curr_bht(to_integer(unsigned(write_address)))(15 downto 0) <= update_data;
            end if; 
        
            curr_bht(to_integer(unsigned(write_address)))(17 downto 16) <= curr_predictor;
        
        end if;
       
    end process;

end Behavioral;
