-- Engineer: Fearghal Morgan, Arthur Beretta, Joseph Clancy
-- National University of Ireland Galway
-- 
-- TEMPLATE: complete processes / concurrent statement 

-- Module Name: EX
-- Description: Execution module of RISC-V processor
-- 

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.RISCV_vicilogic_Package.ALL;
use ieee.std_logic_unsigned.all;

entity EX is
  Port (extImm     : in  std_logic_vector(31 downto 0); 
		rs1D       : in  std_logic_vector(31 downto 0);
        rs2D       : in  std_logic_vector(31 downto 0);
        jalr       : in  std_logic;                    
        PC         : in  std_logic_vector(31 downto 0);
        auipc      : in  std_logic;                    
        selALUBSrc : in  std_logic;  
        selALUOp   : in  std_logic_vector( 3 downto 0);  
        selDToM    : in  std_logic_vector( 1 downto 0); 
        ALUOut     : out std_logic_vector(31 downto 0);
        DToM       : out std_logic_vector(31 downto 0);
        brAdd      : out std_logic_vector(31 downto 0);
        branch     : out std_logic
        );        
end EX;

architecture comb of EX is
component ALU is
  Port (A        : in  std_logic_vector(31 downto 0); -- ALU input A
        B        : in  std_logic_vector(31 downto 0); -- ALU input B
        selALUOp : in  std_logic_vector( 3 downto 0); -- ALU operation select 
		ALUOut   : out std_logic_vector(31 downto 0); -- ALU output
        branch   : out std_logic;                     -- assert on branch instruction                   
        zero     : out std_logic                      -- assert when ALUOut = 0 
        );        
end component;

signal A 	  	   : std_logic_vector(31 downto 0); -- ALU input A
signal B 	  	   : std_logic_vector(31 downto 0); -- ALU input B
signal brBaseAdd   : std_logic_vector(31 downto 0); -- branch base address 
signal zero        : std_logic;                     -- signal is generate but is not on RISCV_EX component port

begin

selA_i: process (PC, rs1D, auipc)
begin
    if auipc = '1' then
        A <= PC;
   else 
        A <= rs1D;
   end if;
end process;        

selB_i: process (extImm, rs2D, selALUBsrc)
begin 
    if selALUBsrc = '1' then
        B <= rs2D;
   else 
        B <= extImm;
   end if;
end process;

ALU_i: ALU Port map 
         (A        => A, 
          B        => B, 
          selALUOp => selALUOp, 
		  ALUOut   => ALUOut,   
		  branch   => branch,
          zero     => zero
        );        

DToM_i: process(rs2D, selDToM)
begin
    if selDToM = "10" then
        DToM <= x"000000" & rs2D(7 downto 0);
    elsif selDToM = "01" then 
        DToM <= x"0000" & rs2D(15 downto 0);
    else  
        DToM <= rs2D;
    end if;
end process;

brBaseAdd_i: process(PC, rs1D, jalr)
begin
    if jalr = '0' then
        brBaseAdd <= PC;
    else
        brBaseAdd <= rs1D;
    end if;
end process;

genbrAdd_i: process(brBaseAdd, extImm)
begin
    brAdd <= brBaseAdd + extImm;
end process;
end comb;