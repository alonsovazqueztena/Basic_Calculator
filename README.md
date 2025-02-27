# Basic Calculator

The **Basic Calculator** is a project created for use on the **Terasic DE-10 Standard board**. It utilizes an ALU circuit to perform common mathematical operations (addition, subtraction, multiplication, and division) based on user inputs. The result is displayed in both binary and integer formats.

## Overview

This project demonstrates the implementation of digital arithmetic operations using an ALU and the display of results through 7-segment displays and LED lights.

## Components and Implementation

- **ALU Circuit**
  - Implements logic for an adder, subtractor, multiplier, or divider.
  - The operation is selected using a two-bit operator.
  - Accepts two 4-bit inputs for the calculation.
  - Uses behavioral modeling.
  - Represents a multiplexer.

- **BCD-to-7-Segment Display Decoder**
  - Converts a BCD digit into signals for a 7-segment display.
  - Determines which segments to activate based on the input digit.
  - Displays signs for unique numbers like fractions and negative numbers.
  - Uses hybrid modeling (both behavioral and dataflow).
 
- **Top Calculator Entity**
  - Establishes ports that will be assigned pins for circuit functionality.
  - Creates 1 ALU and 5 BCD-to-7-Segment Display Decoders (for display of each digit or sign).
  - Holds logic necessary for the circuits to work together (converting inputs and ouputs).
  - Uses structural modeling.

## Board Interfaces

- **Inputs**
  - **10 Switches:**  
    - 4 switches (6-9) for the first 4-bit operand.
    - 4 switches (2-5) for the second 4-bit operand.
    - 2 switches (0-1) for selecting the two-bit operator.
  - **1 Clock:**  
    - Provides the clock signal for the synchronous ALU process.
  - **1 Key Button:**  
    - Used to confirm and latch the calculation result.

- **Outputs**
  - **5 7-Segment Displays:**  
    - Display calculation results in the range of -15 to 1500 (integer form).
    - Displays special signs (negative, fraction).
  - **10 LED Lights:**  
    - Show the calculation results and error codes in binary form.
    - Handles values from 0 to 1023.
