Diya Saha 
dsaha4
Fall 2020
Lab 5: Functions and Graphics

-----------
DESCRIPTION

This program uses a text file to run the code that has been written. 
This code is printing a pattern according to the instructions provided by the professor
in the lab document. This pattern is draw into the bitmap display using pixels 
and colours provided by the test document. 

----------------------------------------------------
 getCoordinates PSEUDOCODE
 multiply how many spaces u moved * 4
 0x00XX00YY -> move 4 steps 0x000000XX -> %x
 0x00XX00YY <- move 4 steps 0x00YY0000 -> %input
 0x00YY0000 -> move 4 steps 0x000000YY -> %y 
----------------------------------------------------
 formatCoordinates PSEUDOCODE
 multiply how many spaces u moved * 4
 0x000000XX <- move 4 steps 0x00XX0000 -> %input
 0x000000YY + 0x00XX0000 -> %input
----------------------------------------------------
 clear_bitmap PSEUDOCODE
 start from start address
 for loop from start to last address
 startaddress += 4 to keep moving
 sw colour as we go 
------------------------------------------------------
 draw_pixel PSEUDOCODE
 break into x and Y 
 use math formula 
 (4X + 4Y*128 ) add starting address to this
 simplify math formula 4(x+128y) +  0xFFFF0000
 sw colour as we go 
-------------------------------------------------------
 get_pixel PSEUDOCODE
 break into x and Y 
 use same math formula 
 (4X + 4Y*128 ) add starting address to this
 simplify math formula 4(x+128y) +  0xFFFF0000
-------------------------------------------------------
 draw_rect PSEUDOCODE
 break into x and Y 
 break into WW and HH
 forloop Y from Y to y+HH: 
 forloop X from X to X+WW
 	use same math formula 
 	use math formula 4(x+128y) +  0xFFFF0000
 	sw colour as we go
	increment X and Y by 1 
-------------------------------------------------------
 draw_diamond PSEUDOCODE
 Draw_diamond(height, base_point_x, base_point_y)
			for (dy = 0; dy <= h; dy++)
				y = base_point_y + dy

				if dy <= h/2
					x_min = base_point_x - dy
					x_max = base_point_x + dy
				else
					x_min = base_point_x - h + dy
					x_max = base_point_x + h - dy
				use math formula 4(x+128y) +  0xFFFF0000 <-- address
	 			for (x=x_min; x<=x_max; x++) 
				 address += 4 (moving down the row)
					
---------------------------------------------------------------
FILES
-
Lab5.asm
This file contains all the MIPS code used for the program described above.
- 
lab5_f20_test.asm
This file contains the tests for lab 5. 

-------------
INSTRUCTIONS

This program is intended to be run from the MARS IDE.