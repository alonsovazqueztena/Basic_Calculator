-- Alonso Vazquez Tena
-- April 26, 2025
-- Milestone 5: Embedded Application Release 4
-- This is my own work.

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

-- Top-level calculator entity has a clock, a confirm, a load, a reset, user
-- inputs (operands & operator code), binary & digit displays.
ENTITY calculator_top IS
  PORT
  (
    clock : IN STD_LOGIC;
    confirm : IN STD_LOGIC;
    load : IN STD_LOGIC;
    reset : IN STD_LOGIC;
    user_inputs : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
    binary_outputs : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
    ones_display : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
    tens_display : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
    hundreds_display : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
    thousands_display : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
    ten_thousands_display : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
    hundred_thousands_display : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
  );
END calculator_top;

-- Structural architecture has signals inverting for active-low logic,
-- carrying operands & operator code, carrying ALU binary & integer result,
-- & have result digits. Logic of top-level module handled.
ARCHITECTURE Structural OF calculator_top IS

  -- Division by zero & unexpected errors.
  CONSTANT DIVISION_ERROR: INTEGER := -1024;
  CONSTANT DEFAULT_ERROR : INTEGER := -1025;

  -- Divison operation code.
  CONSTANT DIV_OP : STD_LOGIC_VECTOR(9 DOWNTO 0) := "0000000011";

  SIGNAL load_invert : STD_LOGIC;
  SIGNAL reset_invert : STD_LOGIC;
  SIGNAL confirm_invert : STD_LOGIC;
  SIGNAL op_a : STD_LOGIC_VECTOR(9 DOWNTO 0);
  SIGNAL op_b : STD_LOGIC_VECTOR(9 DOWNTO 0);
  SIGNAL op_code : STD_LOGIC_VECTOR(9 DOWNTO 0);
  SIGNAL alu_output_bin : STD_LOGIC_VECTOR(20 DOWNTO 0);
  SIGNAL alu_output_int : INTEGER RANGE -999999 TO 999999;
  SIGNAL hundred_thousands_digit, ten_thousands_digit, thousands_digit, hundreds_digit, tens_digit, ones_digit : STD_LOGIC_VECTOR(3 DOWNTO 0);

  -- Signal to display seven segments.
  SIGNAL display_enable : STD_LOGIC := '0';
BEGIN

  -- Invert input control signals to work active-low logic.
  load_invert <= NOT load;
  reset_invert <= NOT reset;
  confirm_invert <= NOT confirm;

  -- Instantiate input controller (split user inputs).
  U_Input_Controller: ENTITY WORK.input_controller
    PORT MAP
    (
      clock => clock,
      load => load_invert,
      reset => reset_invert,
      user_data => user_inputs,
      op_a => op_a,
      op_b => op_b,
      op_code => op_code
    );

  -- Instantiate ALU with module inputs & signal output.
  U_ALU: ENTITY WORK.alu
    PORT MAP
    (
      clock => clock,
      reset => reset_invert,
      confirm => confirm_invert,
      op_a => op_a,
      op_b => op_b,
      op_code => op_code,
      result_out => alu_output_bin
    );

  -- ALU result converted to signed integer for binary result signal.
  alu_output_int <= TO_INTEGER(SIGNED(alu_output_bin));

  -- Drive LEDs when result is 0‒1023 and not division.
  binary_outputs <= STD_LOGIC_VECTOR(TO_UNSIGNED(alu_output_int, 10))
    WHEN (display_enable = '1' AND op_code /= DIV_OP AND alu_output_int >= 0 AND alu_output_int <= 1023)
    ELSE (OTHERS => '0');

  -- Clear all displays but ones digit display at start (also when reset & confirm).
  PROCESS(clock, reset_invert)
  BEGIN
    IF reset_invert = '1' THEN
      display_enable <= '1';
    ELSIF RISING_EDGE(clock) THEN
      IF confirm_invert = '0' THEN
        display_enable <= '1';
      END IF;
    END IF;
  END PROCESS;

  -- Convert ALU result to BCD.
  PROCESS(alu_output_int, op_code, display_enable)

    -- Variables to handle digits of ALU result.
    VARIABLE a, b, c, d, e, f, whole, fraction : INTEGER;
  BEGIN

    -- Start by having all digits be turned off.
    hundred_thousands_digit <= "1111";
    ten_thousands_digit <= "1111";
    thousands_digit <= "1111";
    hundreds_digit <= "1111";
    tens_digit <= "1111";
    ones_digit <= "1111";

	 -- Only keep ones digit on.
    IF display_enable = '0' THEN
      ones_digit <= "0000";

    -- Show error when errors are caught.
    ELSIF (alu_output_int = DIVISION_ERROR) OR (alu_output_int = DEFAULT_ERROR)
	   OR (alu_output_int > 999999) OR (alu_output_int >= 100000 AND op_code = "0000000011") THEN
      hundred_thousands_digit <= "1010";
      ten_thousands_digit <= "1100";
      thousands_digit <= "1101";
      hundreds_digit <= "1101";
      tens_digit <= "1110";
      ones_digit <= "1101";

    -- Division case (extract whole & fraction).
    ELSIF (display_enable = '1') AND (op_code = "0000000011") THEN
      whole := alu_output_int / 100;
      fraction := alu_output_int MOD 100;

      -- Whole < 10: mark tens as 0, display ones.
      IF whole < 10 THEN
        thousands_digit <= STD_LOGIC_VECTOR(TO_UNSIGNED(whole, 4));

      -- Whole < 100: mark hundreds as 0, seperate tens & ones digit.
      ELSIF whole < 100 THEN
        a := whole / 10;
        b := whole MOD 10;
        ten_thousands_digit <= STD_LOGIC_VECTOR(TO_UNSIGNED(a, 4));
        thousands_digit <= STD_LOGIC_VECTOR(TO_UNSIGNED(b, 4));

      -- Whole >= 100: extract hundreds, extract tens & ones digit.
      ELSE
        a := whole / 100;
        b := (whole MOD 100) / 10;
        c := whole MOD 10;

        hundred_thousands_digit <= STD_LOGIC_VECTOR(TO_UNSIGNED(a, 4));
        ten_thousands_digit <= STD_LOGIC_VECTOR(TO_UNSIGNED(b, 4));
        thousands_digit <= STD_LOGIC_VECTOR(TO_UNSIGNED(c, 4));
      END IF;

      -- Pass code for underbar (decimal point).
      hundreds_digit <= "1011";

      -- Use fraction to extract tenths & hundredths.
      d := fraction / 10;
      e := fraction MOD 10;

      tens_digit <= STD_LOGIC_VECTOR(TO_UNSIGNED(d, 4));
      ones_digit <= STD_LOGIC_VECTOR(TO_UNSIGNED(e, 4));

    -- For ALU result positive 0-999999: extract all digits
    -- & convert them to BCD to input into digit signals.
    ELSIF (alu_output_int >= 0) AND (alu_output_int <= 999999) THEN

      -- Case for integers 1 to 9.
      IF (alu_output_int < 10) THEN
        ones_digit <= STD_LOGIC_VECTOR(TO_UNSIGNED(alu_output_int, 4));

      -- Case for integers 10 to 99.
      ELSIF (alu_output_int < 100) THEN
        a := alu_output_int / 10;
        b := alu_output_int MOD 10;
        tens_digit <= STD_LOGIC_VECTOR(TO_UNSIGNED(a, 4));
        ones_digit <= STD_LOGIC_VECTOR(TO_UNSIGNED(b, 4));

      -- Case for integers 100 to 999.
      ELSIF (alu_output_int < 1000) THEN
        a := alu_output_int / 100;
        b := (alu_output_int / 10) MOD 10;
        c := alu_output_int MOD 10;
        hundreds_digit <= STD_LOGIC_VECTOR(TO_UNSIGNED(a, 4));
        tens_digit <= STD_LOGIC_VECTOR(TO_UNSIGNED(b, 4));
        ones_digit <= STD_LOGIC_VECTOR(TO_UNSIGNED(c, 4));

      -- Case for integers 1000 to 9999.
      ELSIF (alu_output_int < 10000) THEN
        a := alu_output_int / 1000;
        b := (alu_output_int / 100) MOD 10;
        c := (alu_output_int / 10) MOD 10;
        d := alu_output_int MOD 10;
        thousands_digit <= STD_LOGIC_VECTOR(TO_UNSIGNED(a, 4));
        hundreds_digit <= STD_LOGIC_VECTOR(TO_UNSIGNED(b, 4));
        tens_digit <= STD_LOGIC_VECTOR(TO_UNSIGNED(c, 4));
        ones_digit <= STD_LOGIC_VECTOR(TO_UNSIGNED(d, 4));

      -- Case for integers 10000 to 99999.
      ELSIF (alu_output_int < 100000) THEN
        a := alu_output_int / 10000;
        b := (alu_output_int / 1000) MOD 10;
        c := (alu_output_int / 100) MOD 10;
        d := (alu_output_int / 10) MOD 10;
        e := alu_output_int MOD 10;
        ten_thousands_digit <= STD_LOGIC_VECTOR(TO_UNSIGNED(a, 4));
        thousands_digit <= STD_LOGIC_VECTOR(TO_UNSIGNED(b, 4));
        hundreds_digit <= STD_LOGIC_VECTOR(TO_UNSIGNED(c, 4));
        tens_digit <= STD_LOGIC_VECTOR(TO_UNSIGNED(d, 4));
        ones_digit <= STD_LOGIC_VECTOR(TO_UNSIGNED(e, 4));

      -- Case for integers 100000 to 999999.
      ELSE
        a := alu_output_int / 100000;
        b := (alu_output_int / 10000) MOD 10;
        c := (alu_output_int / 1000) MOD 10;
        d := (alu_output_int / 100) MOD 10;
        e := (alu_output_int / 10) MOD 10;
        f := alu_output_int MOD 10;
        hundred_thousands_digit <= STD_LOGIC_VECTOR(TO_UNSIGNED(a, 4));
        ten_thousands_digit <= STD_LOGIC_VECTOR(TO_UNSIGNED(b, 4));
        thousands_digit <= STD_LOGIC_VECTOR(TO_UNSIGNED(c, 4));
        hundreds_digit <= STD_LOGIC_VECTOR(TO_UNSIGNED(d, 4));
        tens_digit <= STD_LOGIC_VECTOR(TO_UNSIGNED(e, 4));
        ones_digit <= STD_LOGIC_VECTOR(TO_UNSIGNED(f, 4));
      END IF;

    -- For ALU result negative -999999 to 0: take absolute value, separate digits & turn off displays.
    ELSE
      d := ABS(alu_output_int);

      -- Case for integers -10000 & less.
      IF d >= 10000 THEN
        hundred_thousands_digit <= "1010";
        a := d / 10000;
        b := (d / 1000) MOD 10;
        c := (d / 100) MOD 10;
        e := (d / 10) MOD 10;
        f := d MOD 10;
        ten_thousands_digit <= STD_LOGIC_VECTOR(TO_UNSIGNED(a, 4));
        thousands_digit <= STD_LOGIC_VECTOR(TO_UNSIGNED(b, 4));
        hundreds_digit <= STD_LOGIC_VECTOR(TO_UNSIGNED(c, 4));
        tens_digit <= STD_LOGIC_VECTOR(TO_UNSIGNED(e, 4));
        ones_digit <= STD_LOGIC_VECTOR(TO_UNSIGNED(f, 4));

      -- Case for integers -1000 to -9999.
      ELSIF d >= 1000 THEN
        ten_thousands_digit <= "1010";
        a := d / 1000;
        b := (d / 100) MOD 10;
        c := (d / 10) MOD 10;
        e := d MOD 10;
        thousands_digit <= STD_LOGIC_VECTOR(TO_UNSIGNED(a, 4));
        hundreds_digit <= STD_LOGIC_VECTOR(TO_UNSIGNED(b, 4));
        tens_digit <= STD_LOGIC_VECTOR(TO_UNSIGNED(c, 4));
        ones_digit <= STD_LOGIC_VECTOR(TO_UNSIGNED(e, 4));

      -- Case for integers -100 to -999.
      ELSIF D >= 100 THEN
        thousands_digit <= "1010";
        a := d / 100;
        b := (d / 10) MOD 10;
        c := d MOD 10;
        hundreds_digit <= STD_LOGIC_VECTOR(TO_UNSIGNED(a, 4));
        tens_digit <= STD_LOGIC_VECTOR(TO_UNSIGNED(b, 4));
        ones_digit <= STD_LOGIC_VECTOR(TO_UNSIGNED(c, 4));

      -- Case for integers -10 to -99.
      ELSIF d >= 10 THEN
        hundreds_digit <= "1010";
        a := d / 10;
        b := d MOD 10;
        tens_digit <= STD_LOGIC_VECTOR(TO_UNSIGNED(a, 4));
        ones_digit <= STD_LOGIC_VECTOR(TO_UNSIGNED(b, 4));

      -- Case for integers -1 to -9.
      ELSE
        tens_digit <= "1010";
        ones_digit <= STD_LOGIC_VECTOR(TO_UNSIGNED(D, 4));
      END IF;
    END IF;
  END PROCESS;

  -- Instantiate BCD to 7-segment decoder for hundred thousands digit.
  U_BCD_Hundred_Thousands: ENTITY WORK.bcd_7segment
    PORT MAP
    (
      bcd_in => hundred_thousands_digit,
      seven_seg_out => hundred_thousands_display
    );

  -- Instantiate BCD to 7-segment decoder for ten thousands digit.
  U_BCD_Ten_Thousands: ENTITY WORK.bcd_7segment
    PORT MAP
    (
      bcd_in => ten_thousands_digit,
      seven_seg_out => ten_thousands_display
    );

  -- Instantiate BCD to 7-segment decoder for thousands digit.
  U_BCD_Thousands: ENTITY WORK.bcd_7segment
    PORT MAP
    (
      bcd_in => thousands_digit,
      seven_seg_out => thousands_display
    );

  -- Instantiate BCD to 7-segment decoder for hundreds digit.
  U_BCD_Hundreds: ENTITY WORK.bcd_7segment
    PORT MAP
    (
      bcd_in => hundreds_digit,
      seven_seg_out => hundreds_display
    );

  -- Instantiate BCD to 7-segment decoder for tens digit.
  U_BCD_Tens: ENTITY WORK.bcd_7segment
    PORT MAP
    (
      bcd_in => tens_digit,
      seven_seg_out => tens_display
    );

  -- Instantiate BCD to 7-segment decoder for ones digit.
  U_BCD_Ones: ENTITY WORK.bcd_7segment
    PORT MAP
    (
      bcd_in => ones_digit,
      seven_seg_out => ones_display
    );
END Structural;