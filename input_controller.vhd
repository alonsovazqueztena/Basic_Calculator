-- Alonso Vazquez Tena
-- March 19, 2025
-- Milestone 4: Embedded Application Release 3
-- This is my own work.

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY input_controller IS
	PORT
	(
		clock : IN STD_LOGIC;
		load : IN STD_LOGIC;
		reset : IN STD_LOGIC;
		user_data : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
		operand_a : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
		operand_b : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
		opcode : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
	);
END input_controller;

ARCHITECTURE Behavioral OF input_controller IS
	TYPE state IS (IDLE, LOAD_OPERAND_A, LOAD_OPERAND_B, LOAD_OPCODE);
	SIGNAL current_state, next_state : state;
	
	SIGNAL operand_a_reg, operand_b_reg, opcode_reg : STD_LOGIC_VECTOR(9 DOWNTO 0);
BEGIN
	PROCESS(clock, reset)
	BEGIN
		IF reset = '1' THEN
			current_state <= IDLE;
		ELSIF RISING_EDGE(clk) THEN
			current_state <= next_state;
		END IF;
	END PROCESS;
	
	PROCESS(current_state, load)
	BEGIN
		next_state <= current_state;
		
		CASE current_state IS
			WHEN IDLE =>
				next_state <= LOAD_OPERAND_A;
				
			WHEN LOAD_OPERAND_A =>
				IF load = '1' THEN
					operand_a_reg <= user_data;
					next_state <= LOAD_OPERAND_B;
				END IF;
				
			WHEN LOAD_OPERAND_B =>
				IF load = '1' THEN
					operand_b_reg <= user_data;
					next_state <= LOAD_OPCODE;
				END IF;
				
			WHEN LOAD_OPCODE =>
				IF load = '1' THEN
					opcode_reg <= user_data;
					next_state <= IDLE;
				END IF;
		END CASE;
	END PROCESS;
	
	operand_a <= operand_a_reg;
	operand_b <= operand_b_reg;
	opcode <= opcode_reg;
	
END Behavioral;