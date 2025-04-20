-- Alonso Vazquez Tena
-- April 20, 2025
-- Milestone 4: Embedded Application Release 3
-- This is my own work.

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

-- The input controller controls the clock, load/reset signals,
-- user data, and outputs from the user data (operands and operator
-- code).
ENTITY input_controller IS
	PORT
	(
		clock : IN STD_LOGIC;
		load : IN STD_LOGIC;
		reset : IN STD_LOGIC;
		user_data : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
		operand_a : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
		operand_b : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
		op_code : OUT STD_LOGIC_VECTOR(9 DOWNTO 0)
	);
END input_controller;

-- A three-step load state machine is implemented to 
-- allow each operand and operator code to be input orderly.
ARCHITECTURE Behavioral OF input_controller IS
	-- A state machine with differing states depending on
	-- what input is being put in.
	TYPE state IS (IDLE, LOAD_OPERAND_B, LOAD_OPCODE);
	SIGNAL current_state : state := IDLE;
	
	-- These are signals to detect the rising edge of the load.
	SIGNAL load_prev, load_event : STD_LOGIC := '0';
	
	-- These are registers for storing inputs.
	SIGNAL operand_a_reg : STD_LOGIC_VECTOR(9 DOWNTO 0) := (OTHERS => '0');
	SIGNAL operand_b_reg : STD_LOGIC_VECTOR(9 DOWNTO 0) := (OTHERS => '0');
	SIGNAL op_code_reg : STD_LOGIC_VECTOR(1 DOWNTO 0) := (OTHERS => '0');
BEGIN
	-- This samples the load pulses and advances the state.
	PROCESS(clock, reset)
	BEGIN
		-- When a reset signal is sent in, reset all
		-- registers and the state.
		IF reset = '1' THEN
			load_prev <= '0';
			load_event <= '0';
			current_state <= IDLE;
			operand_a_reg <= (OTHERS => '0');
			operand_b_reg <= (OTHERS => '0');
			op_code_reg <= (OTHERS => '0');
			
		-- We detect the rising edge on the load signal.
		ELSIF RISING_EDGE(clock) THEN
			load_event <= load AND (NOT load_prev);
			load_prev <= load;
			
			CASE current_state IS
				-- On the first load, operand A is taken in.
				WHEN IDLE =>
					if load_event = '1' THEN
						operand_a_reg <= user_data;
						current_state <= LOAD_OPERAND_B;
					end if;
					
				-- On the second load, operand B is taken in.
				WHEN LOAD_OPERAND_B =>
					IF load_event = '1' THEN
						operand_b_reg <= user_data;
						current_state <= LOAD_OPCODE;
					END IF;
					
				-- On the third load, the operator code is taken in.
				WHEN LOAD_OPCODE =>
					IF load_event = '1' THEN
						op_code_reg <= user_data(1 DOWNTO 0);
						current_state <= IDLE;
					END IF;
			END CASE;
		END IF;
	END PROCESS;
	
	-- We drive the outputs from the registers that captured
	-- the user inputs.
	operand_a <= operand_a_reg;
	operand_b <= operand_b_reg;
	op_code <= "00000000" & op_code_reg;
	
END Behavioral;