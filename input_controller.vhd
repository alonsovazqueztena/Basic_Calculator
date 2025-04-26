-- Alonso Vazquez Tena
-- April 26, 2025
-- Milestone 5: Embedded Application Release 4
-- This is my own work.

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

-- Input controller has clock, load & reset signals,
-- user data & outputs (operands & operator code).
ENTITY input_controller IS
  PORT
  (
    clock : IN STD_LOGIC;
    load : IN STD_LOGIC;
    reset : IN STD_LOGIC;
    user_data : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
    op_a : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
    op_code : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
    op_b : OUT STD_LOGIC_VECTOR(9 DOWNTO 0)
  );
END input_controller;

-- Behavioral architecture has three-step state machine logic.
ARCHITECTURE Behavioral OF input_controller IS

  -- States for state machine.
  TYPE state IS (IDLE, LOAD_OPCODE, LOAD_OP_B);
  SIGNAL current_state : state := IDLE;

  -- Signals to detect rising edge of load.
  SIGNAL load_prev, load_event : STD_LOGIC := '0';

  -- Registers for storing inputs.
  SIGNAL op_a_reg : STD_LOGIC_VECTOR(9 DOWNTO 0) := (OTHERS => '0');
  SIGNAL op_code_reg : STD_LOGIC_VECTOR(1 DOWNTO 0) := (OTHERS => '0');
  SIGNAL op_b_reg : STD_LOGIC_VECTOR(9 DOWNTO 0) := (OTHERS => '0');
BEGIN

  -- Samples load pulses & advances state.
  PROCESS(clock, reset)
  BEGIN

    -- When reset high, reset all registers & state.
    IF reset = '1' THEN
      load_prev <= '0';
      load_event <= '0';
      current_state <= IDLE;
      op_a_reg <= (OTHERS => '0');
      op_code_reg <= (OTHERS => '0');
      op_b_reg <= (OTHERS => '0');

    -- Detect rising edge on load high.
    ELSIF RISING_EDGE(clock) THEN
      load_event <= load AND (NOT load_prev);
      load_prev <= load;

      CASE current_state IS

        -- First load: operand A taken in.
        WHEN IDLE =>
          IF load_event = '1' THEN
            op_a_reg <= user_data;
            current_state <= LOAD_OPCODE;
          END IF;

        -- Second load: operator code taken in.
        WHEN LOAD_OPCODE =>
          IF load_event = '1' THEN
            op_code_reg <= user_data(1 DOWNTO 0);
            current_state <= LOAD_OP_B;
          END IF;

        -- Third load: operand B taken in.
        WHEN LOAD_OP_B =>
          IF load_event = '1' THEN
            op_b_reg <= user_data;
            current_state <= IDLE;
          END IF;
      END CASE;
    END IF;
  END PROCESS;

  -- Drive outputs from user input registers.
  op_a <= op_a_reg;
  op_code <= "00000000" & op_code_reg;
  op_b <= op_b_reg;
END Behavioral;