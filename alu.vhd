-- Alonso Vazquez Tena
-- April 26, 2025
-- Milestone 5: Embedded Application Release 4
-- This is my own work.

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

-- ALU has 1 clock, 1 reset,
-- 1 confirm, user inputs (operands A & B,
-- and operation code) & binary outputs (calculation result).
ENTITY alu IS
  PORT
  (
    clock : IN STD_LOGIC;
    reset : IN STD_LOGIC;
    confirm : IN STD_LOGIC;
    op_a : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
    op_b : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
    op_code : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
    result_out : OUT STD_LOGIC_VECTOR(20 DOWNTO 0)
  );
END alu;

-- Behavioral architecture defined with
-- several signals serving as numeric representations
-- of inputs & outputs. Logic for ALU handled.
ARCHITECTURE Behavioral OF alu IS

  -- Error codes for division by zero
  -- & unexpected results.
  CONSTANT DIVISION_ERROR : INTEGER := -1024;
  CONSTANT DEFAULT_ERROR : INTEGER := -1025;

  -- Operands & operator defined as
  -- signals for working logic.
  SIGNAL in_a : UNSIGNED(9 DOWNTO 0);
  SIGNAL in_b : UNSIGNED(9 DOWNTO 0);
  SIGNAL in_op_code : STD_LOGIC_VECTOR(9 DOWNTO 0);

  -- Calculated result has signals for handling.
  SIGNAL result : INTEGER RANGE -999999 TO 999999;
  SIGNAL alu_reg : INTEGER RANGE -999999 TO 999999;
BEGIN

  -- User inputs mapped to operands & operator.
  in_a <= UNSIGNED(op_a);
  in_b <= UNSIGNED(op_b);
  in_op_code <= op_code;

  -- Multiplexer to calculate ALU result.
  PROCESS(in_a, in_b, in_op_code)
  BEGIN
    CASE in_op_code IS

      -- Addition: A + B.
      WHEN "0000000000" =>
        result <= TO_INTEGER(in_a) + TO_INTEGER(in_b);

      -- Subtraction: A - B.
      WHEN "0000000001" =>
        result <= TO_INTEGER(in_a) - TO_INTEGER(in_b);

      -- Multiplication: A * B.
      WHEN "0000000010" =>
        result <= TO_INTEGER(in_a) * TO_INTEGER(in_b);

      -- Division: A / B.
      WHEN "0000000011" =>

        -- Division by zero handling.
        IF in_b = 0 THEN
          result <= DIVISION_ERROR;

        -- Valid division.
        ELSE
          result <= (TO_INTEGER(in_a) * 100) / TO_INTEGER(in_b);
        END IF;

      -- Unexpected error handling.
      WHEN OTHERS =>
        result <= DEFAULT_ERROR;
    END CASE;
  END PROCESS;

  -- Synchronous process for ALU.
  -- Result latches on rising edge of clock
  -- when confirmation high.
  PROCESS(clock, reset)
  BEGIN

    -- If reset high, reset output.
    IF reset = '1' THEN
      alu_reg <= 0;
    ELSIF RISING_EDGE(clock) THEN

      -- If confirmation high, update result.
      IF confirm = '1' THEN
        alu_reg <= result;
      END IF;
    END IF;
  END PROCESS;

  -- ALU result output as 21-bit binary (also as integer).
  result_out <= STD_LOGIC_VECTOR(TO_SIGNED(alu_reg, 21));
END Behavioral;