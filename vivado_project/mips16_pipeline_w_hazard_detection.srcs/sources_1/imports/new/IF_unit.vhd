----------------------------------------------------------------------------------
-- Company: TUCN
-- Engineer: Radu-Augustin Vele
-- 
-- Create Date: 03/18/2022 02:15:21 PM
-- Design Name: 
-- Module Name: IF_unit - Behavioral
-- Project Name: MIPS 16 Single Cycle
-- Target Devices: Basys 3
-- Tool Versions: 2020.1
-- Description: Instruction fetch unit - takes the instruction pointed to by the program counter and
--              computes the next address.
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
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity IF_unit is
    Port (
        clk100MHz: in std_logic;
        branch_addr: in std_logic_vector(15 downto 0);
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
        
end IF_unit;

architecture Behavioral of IF_unit is

    component branch_history_table is
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
    end component;

    signal nxt_pc: std_logic_vector(15 downto 0);
    signal curr_pc_content: std_logic_vector(15 downto 0);
    signal adder_out: std_logic_vector(15 downto 0);
    signal mux1_out: std_logic_vector(15 downto 0);
    signal mux0_out: std_logic_vector(15 downto 0);
    signal predicted_target: std_logic_vector(15 downto 0);
    signal tmp_instruction: std_logic_vector(15 downto 0);
    signal MSB_Pred: std_logic;
    signal ID_Pred_ID_Br_Taken: std_logic_vector(1 downto 0);
    signal jump_if: std_logic;
    signal jump_addr_if: std_logic_vector(15 downto 0);
    
    type rom_content is array(0 to 255) of std_logic_vector(15 downto 0);
    
    -- Instructions Format: --------------------
    --
    -- R Type
    --  ---------------------------------------
    -- | opcode | rs | rt | rd | sa | function |
    --  ---------------------------------------
    -- 15      12    9    6    3    2         0
    --    
    -- I Type
    --  ---------------------------------------
    -- | opcode | rs | rt | immediate/address  |
    --  ---------------------------------------
    --
    -- J Type
    --  ---------------------------------------
    -- | opcode |     target address           |
    --  ---------------------------------------
    --------------------------------------------
    
    signal curr_rom: rom_content := ( 
-- Dynamic branch prediction
    -- 5 fibonnaci numbers to be computed 2 -> 5 -> 7 -> 12 -> 19
    B"010_000_011_0000000", -- load $3 = MEM[0]
    B"100_011_100_0000010", -- beq $3 $4 
    B"000_101_110_111_0_001", -- add $5 $6 $7
    others => x"0000"
    );
    
begin   
    pc: process(clk100MHz, reset_pc) is
    begin
        if(reset_pc = '1') then
            curr_pc_content <= x"0000";
        elsif rising_edge(clk100MHz) then
            if(enable_pc = '1') then
                curr_pc_content <= nxt_pc;
            end if;
        end if;
    end process;
    
    bht_connect: branch_history_table port map (
        clk => clk100MHz,
        address => curr_pc_content(3 downto 0),
        update_data => branch_addr,
        write_address => ID_prv_pc,
        inc_predictor => ID_Branch_Taken, 
        pc_enable => enable_pc,
        branch_instruction => ID_Branch_Instruction,
        flush => ID_Flush,
        MSB_Pred => MSB_Pred,
        predicted_target => predicted_target
    );
    
    tmp_instruction <= curr_rom(to_integer(unsigned(curr_pc_content(7 downto 0))));
    
    instruction <= tmp_instruction;
   
    -- next address computation
    adder: adder_out <= curr_pc_content + "1";
    
    pc_plus_one <= adder_out; -- needed for ID (branch)
    
    mux_bht: mux0_out <= predicted_target when MSB_Pred = '1' else adder_out;
        
    ID_Pred_ID_Br_Taken <= ID_pred & ID_Branch_Taken;
    
    mux1: process (branch_addr, ID_Flush, ID_Pred_ID_Br_Taken, mux0_out, ID_pc_plus_one) is
    begin
        case ID_Pred_ID_Br_Taken is 
            when "00" => mux1_out <= mux0_out;
            when "01" => mux1_out <= branch_addr;
            when "10" => mux1_out <= ID_pc_plus_one;
            when "11" => mux1_out <= mux0_out;
            when others => mux1_out <= adder_out;
        end case;
    end process;
    
    jump_if <= '1' when (tmp_instruction(15 downto 13) = "111") else '0'; -- jump
    jump_addr_if <= "000" & tmp_instruction(12 downto 0);
    
    mux2: nxt_pc <= jump_addr_if when (jump_if = '1') else mux1_out;  
    
    prediction <= MSB_Pred;
    curr_pc <= curr_pc_content(3 downto 0);
end Behavioral;
