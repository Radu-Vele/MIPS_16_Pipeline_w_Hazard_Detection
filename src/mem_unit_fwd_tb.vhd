----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/06/2022 10:13:58 AM
-- Design Name: 
-- Module Name: mem_unit_fwd_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
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


entity mem_unit_fwd_tb is

end mem_unit_fwd_tb;

architecture Behavioral of mem_unit_fwd_tb is

    component mem_unit is
        Port ( 
            clk100MHz: in std_logic;
            MemWrite: in std_logic;
            MemRead: in std_logic;
            ALURes: in std_logic_vector (15 downto 0);
            RD2: in std_logic_vector (15 downto 0);
            zero_detected: in std_logic; 
            branch_ins: in std_logic;
            ALURes_out: out std_logic_vector (15 downto 0);
            MemData: out std_logic_vector (15 downto 0);
            branch_taken: out std_logic;
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
    
    signal gen_clk: std_logic := '0';
    signal MemWrite: std_logic;
    signal br_taken: std_logic;
    signal MemData: std_logic_vector(15 downto 0);
    signal ALURes_out: std_logic_vector(15 downto 0);
    
    signal MEM_WB_RegWrite: std_logic;
    signal WB_BUF_RegWrite: std_logic;
    signal EX_MEM_MemWrite: std_logic;
    signal EX_MEM_Rt: std_logic_vector(2 downto 0);
    signal WB_BUF_RegDst: std_logic_vector(2 downto 0);
    signal MEM_WB_RegDst: std_logic_vector(2 downto 0);
    signal MEM_WB_RegData: std_logic_vector(15 downto 0);
    signal WB_BUF_RegData: std_logic_vector(15 downto 0);
    
begin
    gen_clk <= not gen_clk after 3ns; --- clock
    MEM_WB_RegData <= x"EE01"; -- data to store from MEM_WB
    WB_BUF_RegData <= x"BAC0"; -- data to store from WB_BUF
    
    -- scenario:
    --   -> no forwarding as the instruction is not a store
    --   -> forward from MEM
    --   -> forward from WB
    --   -> forwarding from MEM with WB also there
    --   -> no forwarding
    
    MemWrite <= '0', '1' after 20 ns; -- curr ins is a load
    MEM_WB_RegWrite <= '1', '1' after 20 ns, '0' after 40 ns, '1' after 60ns; 
    WB_BUF_RegWrite <= '1', '0' after 20 ns, '1' after 40 ns;
    EX_MEM_Rt <= "001";
    WB_BUF_RegDst <= "001", "000" after 20 ns, "001" after 40 ns, "001" after 60 ns, "000" after 80ns;
    MEM_WB_RegDst <= "000", "001" after 20 ns, "000" after 80 ns;
    
    -- expected content in memory at address 2:
    -- x0003 -> xEEEE -> xEE01 -> xBAC0 -> xEE01 -> xEEEE
    
    uut: mem_unit port map (
        clk100MHz => gen_clk,
        MemWrite => MemWrite,
        MemRead => '0',
        ALURes => x"0002", 
        RD2 => x"EEEE",
        zero_detected => '0', 
        branch_ins => '0',
        ALURes_out => ALURes_out,
        MemData => MemData,
        branch_taken => br_taken,
        MEM_WB_RegWrite => MEM_WB_RegWrite,
        WB_BUF_RegWrite => WB_BUF_RegWrite,
        EX_MEM_Rt => EX_MEM_Rt,
        WB_BUF_RegDst => WB_BUF_RegDst,
        MEM_WB_RegDst => MEM_WB_RegDst,
        MEM_WB_RegData => MEM_WB_RegData,
        WB_BUF_RegData => WB_BUF_RegData
    );

end Behavioral;
