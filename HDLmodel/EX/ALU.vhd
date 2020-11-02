-- Engineer: Fearghal Morgan, Arthur Beretta, Joseph Clancy
-- National University of Ireland Galway

-- TEMPLATE: complete >A, >B, >C, >D, >E, >F, >G, >H

-- 
-- Module Name: RISCV_ALU
-- Description: Execution arithmetic and logic unit module of RISC-V processor
--
-- Generates ALUOut from ALU data inputs A, B and control input selALUOP(3:0)
-- Operations include   arithmetic,   logical,   shift (immediate or registered),   set less than  
--
-- Generates branch: asserted when branch instruction 
-- Generates zero: asserted when ALUOut = 0  
--
-- Arithmetic operations on std_logic_vector (slv) types
-- Requires 
--   1. Selection of arithmetic library, "use IEEE.NUMERIC_STD.ALL;" used in VHDL library section. 
--   IEEE.NUMERIC_STD.vhd https://www.csee.umbc.edu/portal/help/VHDL/packages/cieee/numeric_std.vhd supports -/+ functions 
--     Id: A.2
--      function "-" (ARG: SIGNED) return SIGNED;
--      Result subtype: SIGNED(ARG'LENGTH-1 downto 0). Result: Returns the value of the unary minus operation on a SIGNED vector ARG.
--     Id: A.4
--      function "+" (L, R: SIGNED) return SIGNED;
--      Result subtype: SIGNED(MAX(L'LENGTH, R'LENGTH)-1 downto 0). Result: Adds two SIGNED vectors that may be of different lengths.
--   2. type conversion of slv, i.e, signed or unsigned
--   3. arithmetic operation, using arithmetic operator, e.g, +, -
--   4. type conversion of arithmetic result to slv 
--  Examples:
--      signed addition:    std_logic_vector(signed(A) + signed(B));
--      signed subtraction: std_logic_vector(signed(A) + signed(B));
--
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ALU is
  Port (A        : in  std_logic_vector(31 downto 0); -- ALU input A
        B        : in  std_logic_vector(31 downto 0); -- ALU input B
        selALUOp : in  std_logic_vector( 3 downto 0); -- ALU operation select 
		ALUOut   : out std_logic_vector(31 downto 0); -- ALU output
        branch   : out std_logic;                     -- assert on branch instruction                   
        zero     : out std_logic                      -- assert when ALUOut = 0 
        );        
end ALU;

architecture comb of ALU is
signal intALUOut : std_logic_vector(31 downto 0); -- 32 bit vector

begin

asgnALUOut_i: ALUOut <= intALUOut;

-- ALU function
ALUOut_i: process(A, B, selALUOp)  
begin
    intALUOut   <= (others => '0'); -- Default assignment
    case selALUOp is 
    
      -- arithmetic operation 
      when "0000" => -- ADD
		intALUOut <= std_logic_vector(signed(A) + signed(B)); 
      when "0001" => -- SUB
		intALUOut <= std_logic_vector(signed(A) - signed(B)); 

      -- logical operation
      when "0010" => intALUOut <= A and B; -- AND
      when "0011" => intALUOut <= A or  B; -- OR
      when "0100" => intALUOut <= A xor B; -- XOR

      --  shift (immediate or registered) operation
      -->A when "0101" => intALUOut <= -- Shift left logical Immediate (SLLI)
	  when "0101" => intALUOut <= std_logic_vector( shift_left(signed(A),to_integer(signed(B(4 downto 0)))));
      -->B when "0110" => intALUOut <= -- Shift right logical Immediate (SRLI)
	  when "0110" =>intALUOut <= std_logic_vector( shift_right(signed(A),to_integer(signed(B(4 downto 0)))));
      when "0111" => intALUOut <= std_logic_vector( shift_right(signed  (A), to_integer( unsigned(B(4 downto 0))) ) ); -- Shift right arithmetic Immediate (SRAI)

      -- set less than operations
	  when "1000" => -- Set less than immediate (SLTI | SLT) 
        if signed(A)    < signed(B)   then intALUOut(0) <= '1'; end if; 
	  -->C when "1001" => -- Set less than unsigned (SLTIU | SLTU)
		when "1001" => 
		if unsigned(A) < unsigned(B) then intALUOut(0) <= '1'; end if; 
      when others => null;
    end case;
end process;

genALUZero_i: process(intALUOut) 
-- Assert signal zero when ALUOut = 0
begin
    zero <= '0'; -- Default assignment
    if unsigned(intALUOut) = X"00000000" then -- convery to unsigned first
       zero <= '1'; 
    end if;
end process;

genBranch_i: process(A, B, selALUOp) 
-- Assert signal branch for branch instructions (selALUOP = 0b1010-0b1111)  
-- Equality check requires type conversion of std_logic_vector (slv) signal to signed or unsigned
-- Equal =    or  not equal /=  check does not required slv type conversion   
begin
    branch <= '0'; -- Default assignment
    case selALUOp is 
	  -- Branch check and generate signal zero
	  when "1010" => if A = B             		   then branch <= '1'; end if; -- BEQ						
      -- >D when "1011" => -- BNE	
	  when "1011" => if A /= B  then branch <= '1'; end if;
      -- >E when "1100" => -- BLT
	  when "1100" => if A < B then branch <= '1'; end if;
      -- >F when "1101" => -- BGE
	  when "1101" => if A >= B then branch <= '1'; end if;
      -- >G when "1110" => -- BLTU 		
	 when "1110" => if unsigned(A) < unsigned(B) then branch <= '1'; end if; 
      -- >H when "1111" => -- BGEU
	  when "1111" => if unsigned(A) >= unsigned(B) then branch <= '1'; end if;
	  when others  => null;                                     
    end case;
end process;

end comb;