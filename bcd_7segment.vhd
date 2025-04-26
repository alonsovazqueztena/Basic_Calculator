-- Alonso Vazquez Tena
-- April 26, 2025
-- Milestone 5: Embedded Application Release 4
-- This was provided by an in-class activity (Activity 2).

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

-- BCD to 7-segment decoder has BCD input
-- & 7-segment display output.
ENTITY bcd_7segment IS
  PORT
  (
    -- 4-bit BCD input.
    bcd_in : IN STD_LOGIC_VECTOR (3 DOWNTO 0);

    -- 7-segment display output.
    seven_seg_out : OUT STD_LOGIC_VECTOR (6 DOWNTO 0)
  );
END bcd_7segment;

-- Hybrid architecture has Boolean expressions
-- & codes to light up segments.
ARCHITECTURE Hybrid OF bcd_7segment IS
BEGIN

  -- 1 bit per variable.
  PROCESS(bcd_in)
    VARIABLE a : STD_LOGIC;
    VARIABLE b : STD_LOGIC;
    VARIABLE c : STD_LOGIC;
    VARIABLE d : STD_LOGIC;
  BEGIN

    -- Negative sign display.
    IF bcd_in = "1010" THEN
      seven_seg_out <= "0111111";

    -- Underbar sign display.
    ELSIF bcd_in = "1011" THEN
      seven_seg_out <= "1110111";

    -- "E" display.
    ELSIF bcd_in = "1100" THEN
      seven_seg_out <= "0000110";

    -- "r" display.
    ELSIF bcd_in = "1101" THEN
      seven_seg_out <= "0101111";

    -- "o" display.
    ELSIF bcd_in = "1110" THEN
      seven_seg_out <= "0100011";

    -- Off display.
    ELSIF bcd_in = "1111" THEN
      seven_seg_out <= "1111111";

    ELSE

      -- Assign 1 input bit per variable.
      a := bcd_in(3);
      b := bcd_in(2);
      c := bcd_in(1);
      d := bcd_in(0);

      -- Boolean expressions for each 7-segment display.
      seven_seg_out(0) <= NOT ((NOT b AND NOT d) OR c OR (b AND d) OR a);
      seven_seg_out(1) <= NOT (NOT b OR (NOT c AND NOT d) OR (c AND d));
      seven_seg_out(2) <= NOT (NOT c OR d OR b);
      seven_seg_out(3) <= NOT ((NOT b AND NOT d) OR (NOT b AND c) OR (b AND NOT c AND d) OR (c AND NOT d) OR a);
      seven_seg_out(4) <= NOT ((NOT b AND NOT d) OR (c AND NOT d));
      seven_seg_out(5) <= NOT ((NOT c AND NOT d) OR (b AND NOT c) OR (b AND NOT d) OR a);
      seven_seg_out(6) <= NOT ((NOT b AND c) OR (b AND NOT c) OR a OR (b AND NOT d));
    END IF;
  END PROCESS;
END Hybrid;