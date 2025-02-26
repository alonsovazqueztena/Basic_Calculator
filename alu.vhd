-- Alonso Vazquez Tena
-- February 26, 2025
-- Milestone 3: Embedded Application Release 2
-- This is my own work.

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.all;

-- The entity is defined to have a clock, a confirmation,
-- user inputs, and binary outputs.
ENTITY alu IS
    PORT
	 (
        clock           : 
		      IN  STD_LOGIC;
        confirm         : 
			   IN  STD_LOGIC;
        user_inputs     : 
			   IN  STD_LOGIC_VECTOR(
				    9 DOWNTO 0
				    );
        binary_outputs  : 
		      OUT STD_LOGIC_VECTOR(
				    9 DOWNTO 0
				    ) 
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
    SIGNAL input_A: 
	     UNSIGNED(
		      3 DOWNTO 0
		  );
    SIGNAL input_B: 
	     UNSIGNED(
		      3 DOWNTO 0
		  );
    SIGNAL operator : 
	     STD_LOGIC_VECTOR(
		      1 DOWNTO 0
		  );
    
    -- The computed result has signals here that
	 -- handled it.
    SIGNAL result_int   : 
	     INTEGER RANGE 0 TO 1023;
    SIGNAL alu_register : 
	     INTEGER RANGE 0 TO 1023;
BEGIN

    -- The user inputs are mapped here to the
	 -- operands and the operator.
    input_A <= 
	     UNSIGNED(
		      user_inputs(
				    3 DOWNTO 0
				)
		  );
    input_B <= 
	     UNSIGNED(
		      user_inputs(
				    7 DOWNTO 4
				)
		  );
    operator  <= 
		  user_inputs(
		      9 DOWNTO 8
			);

    -- A combinational process is used here to calculate the
	 -- ALU result (multiplexer).
    PROCESS(
	     input_A, 
		  input_B, 
		  operator
		  )
    BEGIN
        CASE operator IS
		  
				-- This is the case for addition: A + B.
            WHEN "00" =>
                result_int <= 
				        TO_INTEGER(input_A) + TO_INTEGER(input_B);
					 
				-- This is the case for subtraction: A - B.
            WHEN "01" =>
				
					 -- In the case that the math expression results in
					 -- a negative number, output an error code.
                IF TO_INTEGER(input_A) < TO_INTEGER(input_B) THEN
                    result_int <= 249;
						  
					 -- This is the valid subtraction case.
                ELSE
                    result_int <= TO_INTEGER(input_A) - TO_INTEGER(input_B);
                END IF;
					 
				-- This is the case for multiplication: A * B.
            WHEN "10" =>
                result_int <= TO_INTEGER(input_A) * TO_INTEGER(input_B);
				
				-- This is the case for division: A / B (rounded 
				-- down to the nearest integer if a decimal 
				-- result is given).
            WHEN "11" =>
				
					 -- In the case that the math expression results in
					 -- a division by zero, output an error code.
                IF input_B = 0 THEN
                    result_int <= DIVISION_ERROR;
						  
					 -- This is the valid division case.
                ELSE
                    result_int <= TO_INTEGER(input_A) / TO_INTEGER(input_B);
                END IF;
					 
				-- For any other unexpected case, output an error code.
            WHEN OTHERS =>
                result_int <= DEFAULT_ERROR;
        END CASE;
    END PROCESS;

	 -- This allows for a synchronous process for the ALU.
	 -- The result is latches on the rising edge of the clock.
    PROCESS(clock)
    BEGIN
		  -- If the rising edge of the clock is high, then
		  -- there already is an ALU result stored.
        IF RISING_EDGE(clock) THEN
		  
			   -- Pressing the confirmation button allows for the 
				-- result to be reset back to 0.
            IF confirm = '1' THEN
                alu_register <= 0;
					 
				-- Otherwise, the result remains in the system.
            ELSE
                alu_register <= result_int;
            END IF;
        END IF;
    END PROCESS;

    -- The ALU result is output as a 10-bit binary number.
    binary_outputs <= 
	     STD_LOGIC_VECTOR(
	         to_unsigned(
		          alu_register, 10
				)
		  );

END Behavioral;