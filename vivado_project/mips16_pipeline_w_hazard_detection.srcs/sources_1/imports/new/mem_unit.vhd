----------------------------------------------------------------------------------
-- Company: TUCN
-- Engineer: Radu-Augustin Vele
-- 
-- Create Date: 04/07/2022 03:57:48 PM
-- Design Name: Memory Unit
-- Module Name: mem_unit - Behavioral
-- Project Name: MIPS 16 Pipeline with Hazard detection and Avoidance
-- Target Devices: Basys 3
-- Tool Versions: 2020.1
-- Description: A RAM memory with synchronous write and synchronous read
-- 
-- Dependencies: no dependencies
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

entity mem_unit is
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
end mem_unit;

architecture Behavioral of mem_unit is
    component MEM_fwd_unit is
        Port (
            MEM_WB_RegWrite: in std_logic;
            WB_BUF_RegWrite: in std_logic;
            EX_MEM_MemWrite: in std_logic;
            EX_MEM_Rt: in std_logic_vector(2 downto 0);
            WB_BUF_RegDst: in std_logic_vector(2 downto 0);
            MEM_WB_RegDst: in std_logic_vector(2 downto 0);
            ForwardC: out std_logic_vector(1 downto 0)
        );
    end component;   

    type ram_content is array (0 to 255) of std_logic_vector(15 downto 0); --use the LS byte of the address
    signal curr_content: ram_content := (
        x"0003",
        x"0005", 
        x"0003",
        x"1111",
        x"ABC8",
        x"0004",
        x"0006",
        x"0008", 
        others => x"0000");
    
    signal ForwardC: std_logic_vector(1 downto 0); -- forwarding unit output
    signal MemWriteData: std_logic_vector(15 downto 0);
begin

    hazard_detection: MEM_fwd_unit port map (
        MEM_WB_RegWrite => MEM_WB_RegWrite,
        WB_BUF_RegWrite => WB_BUF_RegWrite,
        EX_MEM_MemWrite => MemWrite,
        EX_MEM_Rt => EX_MEM_Rt,
        WB_BUF_RegDst => WB_BUF_RegDst,
        MEM_WB_RegDst => MEM_WB_RegDst,
        ForwardC => ForwardC
    );

    MUX_MemData: process(ForwardC, RD2, MEM_WB_RegData, WB_BUF_RegData) is
    begin
        case ForwardC is 
            when "00" => MemWriteData <= RD2;
            when "01" => MemWriteData <= MEM_WB_RegData;
            when "10" => MemWriteData <= WB_BUF_RegData;
            when others => MemWriteData <= x"0000";
        end case;
    end process;
    
    writing: process(clk100MHz, MemWrite) is
    begin
        if rising_edge(clk100MHz) then
            if(MemWrite = '1') then
                curr_content(to_integer(unsigned(ALURes))) <= MemWriteData;
            end if;
        end if;
    end process;
    
    reading: process(clk100MHz, MemRead) is 
    begin    
        if MemRead = '1' then
            MemData <= curr_content(to_integer(unsigned(ALURes)));
        end if;
    end process;
    
    ALURes_out <= ALURes;

end Behavioral;
