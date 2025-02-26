The basic calculator is a project created for use on the Terasic DE-10 Standard board.

This is meant to make use of an ALU circuit to perform common mathematical operations (addition, subtraction, multiplication, and division) utilizing user inputs. The result is displayed to the user in both binary and integer forms.

Here are the circuits, inputs, and outputs that this board implements:
  - ALU circuit that contains logic for either an adder, subtractor, multiplier, or divider (chosen using a two-bit selector) taking in two 4-bit inputs for calculation
  - BCD to 7-segment display decoder circuit that contains logic regarding what segments to turn on depending on the digit
  - 10 input switches (4 switches each for two 4-bit inputs, 2 switches for the two-bit operator)
  - 1 input clock for the ALU to be a synchronous process
  - 1 input key button for confirming calculations
  - 2 output 7-segment displays for displaying calculation results from 0-99
  - 10 output LED lights for displaying calculation results and error codes in binary
