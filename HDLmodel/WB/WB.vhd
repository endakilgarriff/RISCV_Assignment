-- Company: National University of Ireland Galway
-- Engineer: Fearghal Morgan, Arthur Beretta (AB), Joseph Clancy (JC)
-- Created June 2018
--
-- TEMPLATE: complete processes
--

-- Module Name: RISCV_WB
-- Description: Writeback component
--
-- Includes 
--  1. 3-to-1 WBDAT selection multiplexer
--  2. selLdSlice for memory read slice selection

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity WB is
   Port (selWBD   : in  std_logic_vector( 1 downto 0);
		 ALUOut   : in  std_logic_vector(31 downto 0);
		 DFrM     : in  std_logic_vector(31 downto 0);
         selDFrM  : in  std_logic_vector(2 downto 0);
		 PCPlus4  : in  std_logic_vector(31 downto 0);
         WBDat    : out std_logic_vector(31 downto 0)
         );
end WB;

architecture combinational of WB is
signal MToWB  : std_logic_vector(31 downto 0);

begin


selLdSlice_i: process(DFrM,selDFrM)
begin
   MToWB <= DFrM;
   case selDFrM is
        when "000" => MToWB <= DFrM;
        when "001" => MToWB <= (x"ffff"&DFrM(15 downto 0 ));
        when "010" => MToWB <= (x"ffffff"& DFrM(7 downto 0));
        when "011" => MToWB <= (x"0000"&DFrM(15 downto 0 ));
        when "100" => MToWB <= (x"000000"& DFrM(7 downto 0));
        when others => MToWB <= DFrM;
    end case;
end process;

WBDat_i: process(ALUOut,PCPlus4,MToWB,selWBD)
begin
    WBDat <= ALUOut;
    case selWBD is
        when "01" => WBDat <= MToWB;
        when "10" => WBDat <= PCPlus4;
        when others => WBDat <= ALUOut;
    end case;
end process;

end combinational;