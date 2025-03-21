-- Alonso Vazquez Tena
-- March 19, 2025
-- Milestone 4: Embedded Application Release 3
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
		clock : IN STD_LOGIC;
		confirm : IN STD_LOGIC;
		load : IN STD_LOGIC;
		reset : IN STD_LOGIC;
      user_inputs : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
		-- binary_outputs : OUT STD_LOGIC_VECTOR(19 DOWNTO 0);
      ones_display : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
      tens_display : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
		hundreds_display : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
		thousands_display : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
		ten_thousands_display : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
		hundred_thousands_display : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
	);
END calculator_top;

-- A structural architecture is defined here 
-- with signals that will carry the ALU result,
-- the binary version of the ALU result, and the digits
-- of the ALU result. The logic of the top-level
-- module is handled here.
ARCHITECTURE Structural OF calculator_top IS
	SIGNAL op_a : STD_LOGIC_VECTOR(9 DOWNTO 0);
	SIGNAL op_b : STD_LOGIC_VECTOR(9 DOWNTO 0);
	SIGNAL op_code : STD_LOGIC_VECTOR(9 DOWNTO 0);
	SIGNAL alu_output_bin : STD_LOGIC_VECTOR(19 DOWNTO 0);
	SIGNAL alu_output_int : INTEGER RANGE -999999 TO 999999;
	SIGNAL hundred_thousands_digit, ten_thousands_digit, thousands_digit, hundreds_digit, tens_digit, ones_digit : STD_LOGIC_VECTOR(3 DOWNTO 0);
BEGIN

	U_Input_Controller: ENTITY WORK.input_controller
		PORT MAP
		(
			clock => clock,
			load => load,
			reset => reset,
			user_data => user_inputs,
			operand_a => op_a,
			operand_b => op_b,
			op_code => op_code
		);
    -- An ALU is instantiated here. The inputs and outputs
	 -- of the ALU are taken in by top-level module's inputs
	 -- and the signal output.
	U_ALU: ENTITY WORK.alu
		PORT MAP 
		(
			clock => clock,
         confirm => confirm,
         operand_a => op_a,
			operand_b => op_b,
			op_code => op_code,
         result_out => alu_output_bin
      );

    -- The ALU result is converted to a signed integer for the
	 -- binary result signal to take in.
	alu_output_int <= TO_INTEGER(SIGNED(alu_output_bin));
	 
	 -- The ALU result is driven through the LED output.
	 -- Only integer values 0-1023 are correctly displayed.
	-- binary_outputs <= STD_LOGIC_VECTOR(TO_SIGNED(alu_output_int, 20));

    -- A process to convert the ALU result to
	 -- BCD is performed here.
	PROCESS(alu_output_int, op_code)
	 
		  -- Variables are defined here to handle
		  -- digits of the ALU result.
		VARIABLE A, B, C, D, E, F, WHOLE, FRACTION : INTEGER;
	BEGIN
	
		hundred_thousands_digit <= "0000";
		ten_thousands_digit <= "0000";
		thousands_digit <= "0000";
		hundreds_digit <= "0000";
		tens_digit <= "0000";
		ones_digit <= "0000";
	 
	     -- In the case that division was performed, undo
		  -- the multiplication to take in the whole component
		  -- of the result and do a modulus operation to
		  -- get the fraction component.
		IF op_code = "0000000011" THEN
			WHOLE := alu_output_int / 100;
			FRACTION := alu_output_int MOD 100;
			
			IF WHOLE < 100 THEN
				hundred_thousands_digit <= "0000";
				A := WHOLE / 10;
				B := WHOLE MOD 10;
				ten_thousands_digit <= STD_LOGIC_VECTOR(TO_UNSIGNED(A, 4));
				thousands_digit <= STD_LOGIC_VECTOR(TO_UNSIGNED(B, 4));
				
				-- If the whole component of the result is less than 10,
				-- mark the tens digit as 0, and only display the ones digit.
			ELSIF WHOLE < 10 THEN
				hundred_thousands_digit <= "0000";
				ten_thousands_digit <= "0000";		
				A := WHOLE;
				thousands_digit <= STD_LOGIC_VECTOR(TO_UNSIGNED(A, 4));
						  
			   -- If the whole component of the result is over 10,
				-- divide by 10 to extract the tens digit and perform a
				-- modulus operation to extract the ones digit.
			ELSE
				A := WHOLE / 100; 
				B := (WHOLE MOD 100) / 10;
				C := WHOLE MOD 10;
			
				hundred_thousands_digit <= STD_LOGIC_VECTOR(TO_UNSIGNED(A, 4));
				ten_thousands_digit <= STD_LOGIC_VECTOR(TO_UNSIGNED(B, 4));
				thousands_digit <= STD_LOGIC_VECTOR(TO_UNSIGNED(C, 4));
			END IF;
				
				-- In place of the position in between the
				-- whole and fraction components of the result,
				-- pass in a code that will display an underbar
				-- in substitution of a decimal point.
			hundreds_digit <= "1011";
				
				-- Using the fraction component of the result,
				-- divide by 10 to get the tenths digit and perform
				-- a modulus operation to get the hundredths digit.
			D := FRACTION / 10;
			E := FRACTION MOD 10;
				
			tens_digit <= STD_LOGIC_VECTOR(TO_UNSIGNED(D, 4));
			ones_digit <= STD_LOGIC_VECTOR(TO_UNSIGNED(E, 4));
	 
	     -- Only occurs if the operation is not division.
		  -- If the ALU result is positive 0-999, divide the
		  -- result to take in the hundreds digit, divide again
		  -- and do a modulus operation to take in the tens digit, 
		  -- and do a modulus operation to take in the ones digit.
		  -- Each of these digits is to undergo BCD conversion
		  -- when input into the digit signals.
		ELSIF (alu_output_int >= 0) AND (alu_output_int <= 999999) THEN
			A := alu_output_int / 100000;
			B := (alu_output_int / 10000) MOD 10;
			C := (alu_output_int / 1000) MOD 10;
			D := (alu_output_int / 100) MOD 10;
			E := (alu_output_int / 10) MOD 10;
			F := alu_output_int MOD 10;
			
			hundred_thousands_digit <= STD_LOGIC_VECTOR(TO_UNSIGNED(A, 4));
			ten_thousands_digit <= STD_LOGIC_VECTOR(TO_UNSIGNED(B, 4));
			thousands_digit <= STD_LOGIC_VECTOR(TO_UNSIGNED(C, 4));
			hundreds_digit <= STD_LOGIC_VECTOR(TO_UNSIGNED(D, 4));
			tens_digit <= STD_LOGIC_VECTOR(TO_UNSIGNED(E, 4));
			ones_digit <= STD_LOGIC_VECTOR(TO_UNSIGNED(F, 4));
						  
		  -- If the input is negative (-15 to 0), take an absolute value of
		  -- the input and separate each of the two digits by
		  -- dividing and doing a modulus operation.
		ELSIF (alu_output_int < 0) AND (alu_output_int >= -99999) THEN
		  
			D := ABS(alu_output_int);
			
			IF D >= 10000 THEN
				hundred_thousands_digit <= "1010";
				A := D / 10000;
				B := (D / 1000) MOD 10;
				C := (D / 100) MOD 10;
				E := (D / 10) MOD 10;
				F := D MOD 10;
				
				ten_thousands_digit <= STD_LOGIC_VECTOR(TO_UNSIGNED(A, 4));
				thousands_digit <= STD_LOGIC_VECTOR(TO_UNSIGNED(B, 4));
				hundreds_digit <= STD_LOGIC_VECTOR(TO_UNSIGNED(C, 4));
				tens_digit <= STD_LOGIC_VECTOR(TO_UNSIGNED(E, 4));
				ones_digit <= STD_LOGIC_VECTOR(TO_UNSIGNED(F, 4));
				
			ELSIF D >= 1000 THEN
				ten_thousands_digit <= "1010";
				A := D / 1000;
				B := (D / 100) MOD 10;
				C := (D / 10) MOD 10;
				E := D MOD 10;
				
				thousands_digit <= STD_LOGIC_VECTOR(TO_UNSIGNED(A, 4));
				hundreds_digit <= STD_LOGIC_VECTOR(TO_UNSIGNED(B, 4));
				tens_digit <= STD_LOGIC_VECTOR(TO_UNSIGNED(C, 4));
				ones_digit <= STD_LOGIC_VECTOR(TO_UNSIGNED(E, 4));
				
			ELSIF D >= 100 THEN
				thousands_digit <= "1010";
				A := D / 100;
				B := (D / 10) MOD 10;
				C := D MOD 10;
				
				hundreds_digit <= STD_LOGIC_VECTOR(TO_UNSIGNED(A, 4));
				tens_digit <= STD_LOGIC_VECTOR(TO_UNSIGNED(B, 4));
				ones_digit <= STD_LOGIC_VECTOR(TO_UNSIGNED(C, 4));
				
			ELSIF D >= 10 THEN
				hundreds_digit <= "1010";
				A := D / 10;
				B := D MOD 10;
				
				tens_digit <= STD_LOGIC_VECTOR(TO_UNSIGNED(A, 4));
				ones_digit <= STD_LOGIC_VECTOR(TO_UNSIGNED(B, 4));
				
			ELSE
				tens_digit <= "1010";
				
				ones_digit <= STD_LOGIC_VECTOR(TO_UNSIGNED(D, 4));
			END IF;
							
		  -- Input the error code 99999 as an out-of-range error.
		ELSE
			hundred_thousands_digit <= "1111";
			ten_thousands_digit <= "1111";
			thousands_digit <= "1111";
			hundreds_digit <= "1111";
			tens_digit <= "1111";
         ones_digit <= "1111";
		END IF;
	END PROCESS;
	
	U_BCD_Hundred_Thousands: ENTITY WORK.bcd_7segment
		PORT MAP 
		(
			bcd_in => hundred_thousands_digit,
         seven_segment_out => hundred_thousands_display
      );
	 
	 -- A BCD to 7-segment display decoder is instantiated
	 -- to take in the tens digit for a fractional division result 
	 -- and display it.
	U_BCD_Ten_Thousands: ENTITY WORK.bcd_7segment
		PORT MAP 
		(
			bcd_in => ten_thousands_digit,
         seven_segment_out => ten_thousands_display
      );
	 
	 -- A BCD to 7-segment display decoder is instantiated
	 -- to take in the ones digit for a fractional division result
	 -- and display it.
	U_BCD_Thousands: ENTITY WORK.bcd_7segment
		PORT MAP 
		(
			bcd_in => thousands_digit,
			seven_segment_out => thousands_display
       );
	 
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