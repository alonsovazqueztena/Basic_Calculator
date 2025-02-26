-- Alonso Vazquez Tena
-- February 26, 2025
-- Milestone 3: Embedded Application Release 2
-- This is my own work.

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

-- An entity for the top-level module is to include
-- the following: a clock, a confirm, user
-- inputs, binary outputs, and
-- digit displays.
ENTITY calculator_top IS
    PORT 
	 (
        clock             : 
		      IN  STD_LOGIC;
        confirm           : 
		      IN  STD_LOGIC;
        user_inputs       : 
		      IN  STD_LOGIC_VECTOR(
				    9 DOWNTO 0
					 );
		  binary_outputs 	  : 
		      OUT STD_LOGIC_VECTOR(
				    9 DOWNTO 0
					 );
        ones_display      : 
		      OUT STD_LOGIC_VECTOR(
				    6 DOWNTO 0
					 );
        tens_display      : 
		      OUT STD_LOGIC_VECTOR(
				    6 DOWNTO 0
					 );
		  hundreds_display  :
				OUT STD_LOGIC_VECTOR(
					 6 DOWNTO 0
					 )
    );
END calculator_top;

-- A structural architecture is defined here 
-- with signals that will carry the ALU result,
-- the binary version of the ALU result, and the digits
-- of the ALU result. The logic of the top-level
-- module is handled here.
ARCHITECTURE Structural OF calculator_top IS
    SIGNAL alu_output_bin : 
	     STD_LOGIC_VECTOR(
		      9 DOWNTO 0
				);
    SIGNAL alu_output_int : 
	     INTEGER RANGE -15 TO 999;
    SIGNAL hundreds_digit, tens_digit, ones_digit : 
	     STD_LOGIC_VECTOR(
		      3 DOWNTO 0
				);
BEGIN
    -- An ALU is instantiated here. The inputs and outputs
	 -- of the ALU are taken in by top-level module's inputs
	 -- and the signal output.
    U_ALU: ENTITY WORK.alu
        PORT MAP 
		  (
            clock              => clock,
            confirm            => confirm,
            user_inputs        => user_inputs,
            binary_outputs		 => alu_output_bin
        );

    -- The ALU result is converted to an integer for the
	 -- binary result signal to take in.
    alu_output_int <= 
	     TO_INTEGER(
		      SIGNED(
				    alu_output_bin
				)
		  );
	 
	 -- The ALU result is driven through the LED output.
	 binary_outputs <= 
	     STD_LOGIC_VECTOR(
		      TO_SIGNED(
				    alu_output_int, 10
					 )
				);

    -- A process to convert the ALU result to
	 -- BCD is performed here.
    PROCESS(alu_output_int)
	 
		  -- Three integer variables is defined here to handle
		  -- all digits of the ALU result (hundreds, tens, and ones).
        VARIABLE A     : INTEGER;
        VARIABLE B     : INTEGER;
		  VARIABLE C     : INTEGER;
		  VARIABLE ABS_D : INTEGER;
    BEGIN
	 
	     -- If the ALU result is positive 0-999, divide the
		  -- result to take in the hundreds digit, divide again
		  -- and do a modulus operation to take in the tens digit, 
		  -- and do a modulus operation to take in the ones digit.
		  -- Each of these digits is to undergo BCD conversion
		  -- when input into the digit signals.
        IF (alu_output_int >= 0) AND (alu_output_int <= 999) THEN
            A := alu_output_int / 100;
            B := (alu_output_int / 10) MOD 10;
				C := alu_output_int MOD 10;
				
				hundreds_digit <= 
				    STD_LOGIC_VECTOR(
					     TO_UNSIGNED(
						      A, 4
								)
						  );
						  
            tens_digit 		<= 
				    STD_LOGIC_VECTOR(
					     TO_UNSIGNED(
						      B, 4
								)
						  );
						  
            ones_digit 		<= 
				    STD_LOGIC_VECTOR(
					     TO_UNSIGNED(
						      C, 4
								)
						  );
						  
		  -- If the input is negative (-15 to 0), take an absolute value of
		  -- the input and separate each of the two digits by
		  -- dividing and doing a modulus operation. Send in the code
		  -- for a negative sign to the hundreds digit.
		  ELSIF (alu_output_int < 0) AND (alu_output_int >= -15) THEN
				ABS_D := ABS(alu_output_int);
				hundreds_digit <= "1010";
				B := ABS_D / 10;
				C := ABS_D MOD 10;
				tens_digit 		<= 
				    STD_LOGIC_VECTOR(
					     TO_UNSIGNED(
						      B, 4
								)
						  );
						  
            ones_digit 		<= 
				    STD_LOGIC_VECTOR(
					     TO_UNSIGNED(
						      C, 4
								)
						  );
				
		  -- In the case that the ALU result is out of
		  -- range (over 999 or under -15), input the error code 999.
        ELSE
				hundreds_digit <= "1111";
            tens_digit 		<= "1111";
            ones_digit 		<= "1111";
        END IF;
    END PROCESS;
	 
	 -- A BCD to 7-segment display decoder is instantiated
	 -- to take in the hundreds digit and display it.
    U_BCD_Hundreds: ENTITY WORK.bcd_7segment
        PORT MAP 
		  (
            bcd_in => hundreds_digit,
            seven_segment_out => hundreds_display
        );

    -- A BCD to 7-segment display decoder is instantiated
	 -- to take in the tens digit and display it.
    U_BCD_Tens: ENTITY WORK.bcd_7segment
        PORT MAP 
		  (
            bcd_in => tens_digit,
            seven_segment_out => tens_display
        );

    -- A BCD to 7-segment display decoder is instantiated
	 -- to take in the ones digit and display it.
    U_BCD_Ones: ENTITY WORK.bcd_7segment
        PORT MAP
		  (
            bcd_in => ones_digit,
            seven_segment_out => ones_display
        );
		  
END Structural;