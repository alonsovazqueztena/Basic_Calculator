-- Alonso Vazquez Tena
-- April 20, 2025
-- Milestone 4: Embedded Application Release 3
-- This is my own work.

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.all;

-- The entity is defined to have a clock, a reset,
-- a confirm, user inputs (operands A and B,
-- and operation code), and binary outputs (calculation result).
ENTITY alu IS
    PORT
	 (
		clock : IN STD_LOGIC;
		reset : IN STD_LOGIC;
	   confirm : IN STD_LOGIC;
      operand_a : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
		operand_b : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
		op_code : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
      result_out : OUT STD_LOGIC_VECTOR(20 DOWNTO 0) 
    );
END alu;

-- A behavioral architecture is defined here with
-- several signals serving as numeric representations
-- of the inputs and outputs. The logic for the ALU is
-- handled here.
ARCHITECTURE Behavioral OF alu IS

	 -- These are error codes for division by zero 
	 -- and unexpected results.
	 CONSTANT DIVISION_ERROR: INTEGER := 250;
	 CONSTANT DEFAULT_ERROR : INTEGER := 251;
		
    -- The operands and the operator are defined here to
	 -- be signals for the logic to work with.
    SIGNAL input_A : UNSIGNED(9 DOWNTO 0);
    SIGNAL input_B : UNSIGNED(9 DOWNTO 0);
    SIGNAL operator : STD_LOGIC_VECTOR(9 DOWNTO 0);
    
    -- The computed result has signals here that
	 -- handle it. Results vary from -999999 to 999999.
    SIGNAL result_int : INTEGER RANGE -999999 TO 999999;
    SIGNAL alu_register : INTEGER RANGE -999999 TO 999999;
	 
BEGIN
    -- The user inputs are mapped here to the
	 -- operands and the operator.
    input_A <= UNSIGNED(operand_A);
    input_B <= UNSIGNED(operand_B);
    operator <= op_code;

    -- A combinational process is used here to calculate the
	 -- ALU result (multiplexer).
    PROCESS(input_A, input_B, operator)
    BEGIN
        CASE operator IS
		  
				-- This is the case for addition: A + B.
            WHEN "0000000000" =>
                result_int <= TO_INTEGER(input_A) + TO_INTEGER(input_B);
					 
				-- This is the case for subtraction: A - B.
            WHEN "0000000001" =>       
                result_int <= TO_INTEGER(input_A) - TO_INTEGER(input_B);
                
				-- This is the case for multiplication: A * B.
            WHEN "0000000010" =>
                result_int <= TO_INTEGER(input_A) * TO_INTEGER(input_B);
				
				-- This is the case for division: A / B (rounded 
				-- down to the nearest integer if a decimal 
				-- result is given).
            WHEN "0000000011" =>
				
					 -- In the case that the math expression results in
					 -- a division by zero, output an error code.
                IF input_B = 0 THEN
                    result_int <= DIVISION_ERROR;
						  
					 -- This is the valid division case.
                ELSE
                    result_int <= (TO_INTEGER(input_A) * 100) / TO_INTEGER(input_B);
                END IF;
					 
				-- For any other unexpected case, output an error code.
            WHEN OTHERS =>
                result_int <= DEFAULT_ERROR;
        END CASE;
    END PROCESS;

	 -- This allows for a synchronous process for the ALU.
	 -- The result is latches on the rising edge of the clock
	 -- when the confirmation is high (1).
    PROCESS(clock, reset)
    BEGIN
		  -- If the reset is high (1), the output is reset.
        IF reset = '1' THEN
				alu_register <= 0;
		  ELSIF RISING_EDGE(clock) THEN
				-- If the confirmation is high (1), the
				-- result is updated.
			   IF confirm = '1' THEN
					alu_register <= result_int;
				ELSE
					alu_register <= alu_register;
				END IF;
		  END IF;
    END PROCESS;

    -- The ALU result is output as a 21-bit binary number.
	 -- This number is prioritized to be output as an integer.
    result_out <= STD_LOGIC_VECTOR(TO_SIGNED(alu_register, 21));

END Behavioral;