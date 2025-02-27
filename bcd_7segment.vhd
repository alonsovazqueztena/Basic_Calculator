-- Alonso Vazquez Tena
-- February 26, 2025
-- Milestone 3: Embedded Application Release 2
-- This was provided by an in-class activity (Activity 2).

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

-- In this entity, we create an input for a 4-bit 
-- number (goes up to 9 from 0) and an output for a 7-segment display.
ENTITY bcd_7segment IS
	PORT
	(
		-- This is the input for the 4-bit number.
		bcd_in : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
	
		-- This is the output for a 7-segment display.
		seven_segment_out : OUT STD_LOGIC_VECTOR (6 DOWNTO 0)
	);
END bcd_7segment;

-- Here, we create a hybrid architecture that utilizes
-- Boolean expressions as the determination of the segments
-- and hardcodes segments due to codes.
ARCHITECTURE Hybrid OF bcd_7segment IS
BEGIN
	
	-- A process is started to where every variable is one bit.
	PROCESS(bcd_in)
	
		VARIABLE A : STD_LOGIC;
		VARIABLE B : STD_LOGIC;
		VARIABLE C : STD_LOGIC;
		VARIABLE D : STD_LOGIC;
	BEGIN
	
		-- If the input is a negative sign, display it.
		IF bcd_in = "1010" THEN
			seven_segment_out <= "0111111";
			
		-- If the input is a decimal, display an underbar.
		ELSIF bcd_in = "1011" THEN
			seven_segment_out <= "1110111";
		ELSE
			
			-- Assign each variable to carry 1 bit of the input.
			A := bcd_in(3);
			B := bcd_in(2);
			C := bcd_in(1);
			D := bcd_in(0);
			
			-- Every boolean expression for each of the seven segments
			-- are handled here.
			seven_segment_out(0) <= NOT ((NOT B AND NOT D) OR C OR (B AND D) OR A);
			seven_segment_out(1) <= NOT (NOT B OR (NOT C AND NOT D) OR (C AND D));
			seven_segment_out(2) <= NOT (NOT C OR D OR B);
			seven_segment_out(3) <= NOT ((NOT B AND NOT D) OR (NOT B AND C) OR (B AND NOT C AND D) OR (C AND NOT D) OR A);
			seven_segment_out(4) <= NOT ((NOT B AND NOT D) OR (C AND NOT D));
			seven_segment_out(5) <= NOT ((NOT C AND NOT D) OR (B AND NOT C) OR (B AND NOT D) OR A);
			seven_segment_out(6) <= NOT ((NOT B AND C) OR (B AND NOT C) OR A OR (B AND NOT D));
		END IF;
	END PROCESS;
END Hybrid;