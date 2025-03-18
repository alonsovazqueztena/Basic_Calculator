-- Alonso Vazquez Tena
-- March 18, 2025
-- Milestone 4: Embedded Application Release 3
-- This is my own work.

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY ten_bit_register IS
	PORT
	(
		clk : IN STD_LOGIC;
		load : IN STD_LOGIC;
		d : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
		q : OUT STD_LOGIC_VECTOR(9 DOWNTO 0)
	);
END ten_bit_register;

ARCHITECTURE Behavioral OF ten_bit_register IS
	SIGNAL register_value : STD_LOGIC_VECTOR(9 DOWNTO 0) := (OTHERS => '0');
BEGIN
	PROCESS(clk)
	BEGIN
		IF (RISING_EDGE (clk)) THEN
			IF (load = '1') THEN
				register_value <= d;
			END IF;
		END IF;
	END PROCESS;
	q <= register_value;
END Behavioral;