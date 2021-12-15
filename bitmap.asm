##########################################################################
# Created by: Saha, Diya
# 	      dsaha4
#             1 December 2020
#
# Assignment: Lab 5: Functions and Graphics
# 	     CSE 12, Computer Systems and Assembly Language
# 	     UC Santa Cruz, Fall 2020
#
# Description:  
#	     This program uses a text file to run the code that has been written. 
#	     This code is printing a pattern according to the instructions provided by the professor
#	     in the lab document. This pattern is draw into the bitmap display using pixels 
#	     in the colours provided by the test document.
#
# Notes: This program is intended to be run from the MARS IDE.
##########################################################################
# REGISTER USAGE
# clear bitmap :-----------------------------------
# $a0: 	colour 		(given by testfile)
# $t1: 	endpoint 	(used to store the last bitmap address)
# $t2: 	originAddress	(used to store start address)
# draw pixel :------------------------------------
# $a0: 	coords 		(given by testfile)		
# $a1:	colour 		(given by testfile)
# $t2:	originAddress	(used to store start address)
# $t3: 	x-coord		(getcoord from a0)
# $t4: 	y-coord		(getcoord from a0)
# $t5: 	coords		(calculating process)
# $t6:	coords 		(calculate final address)
# get pixel :--------------------------------------
# $a0: 	coords 		(given by testfile)		
# $v0:	colour 		(store colour in)
# $t2:	originAddress	(used to store start address)
# $t3: 	x-coord		(getcoord from a0)
# $t4: 	y-coord		(getcoord from a0)
# $t5: 	coords		(calculating process)
# $t6:	coords 		(calculate final address)
# draw rect :--------------------------------------
# $a0: 	coords 		(given by testfile)		
# $a1:	dimensions 	(given by testfile)
# $a2:	colour		(given by testfile)
# $t0: 	width		(getcoord from a1)
# $t1: 	height		(getcoord from a1)
# $t3: 	x-coord		(getcoord from a0)
# $t4: 	y-coord		(getcoord from a0)
# $t5: 	x-coord		(copy of t3)
# $t6:	coords 		(calculate final address)
# $t7: 	finalX		(ending the row)
# $t8: 	finalY		(ending the coloumn)
# draw diamond :--------------------------------------
# $a0: 	coords 		(given by testfile)		
# $a1:	height 		(given by testfile)
# $t0: 	heightcounter	(copy of a1)
# $t1: 	height/2		(a1/2)
# $t3: 	base x-coord	(getcoord from a0)
# $t4: 	base y-coord	(getcoord from a0)
# $t5: 	coords		(calculate final address)
# $t6:	x-min 		(start x loop)
# $t7: 	x-max		(ending x loop)
# $t8: 	finalcoord	(final address to print)
##########################################################################
#Fall 2020 CSE12 Lab5
## Macro that stores the value in %reg on the stack 
##  and moves the stack pointer.
.macro push(%reg)
	subi $sp $sp 4
	sw %reg 0($sp)
.end_macro 
# Macro takes the value on the top of the stack and 
#  loads it into %reg then moves the stack pointer.
.macro pop(%reg)
	lw %reg 0($sp)
	addi $sp $sp 4	
.end_macro
# Macro that takes as input coordinates in the format
# (0x00XX00YY) and returns 0x000000XX in %x and 
# returns 0x000000YY in %y
#*****************************************************
# PSEUDOCODE
# multiply how many spaces u moved * 4
# 0x00XX00YY -> move 4 steps 0x000000XX -> %x
# 0x00XX00YY <- move 4 steps 0x00YY0000 -> %input
# 0x00YY0000 -> move 4 steps 0x000000YY -> %y 
#*****************************************************
.macro getCoordinates(%input %x %y)
	srl %x %input 16 				
	sll %input %input 16
	srl %y %input 16
	
.end_macro
# Macro that takes Coordinates in (%x,%y) where
# %x = 0x000000XX and %y= 0x000000YY and
# returns %output = (0x00XX00YY)
#*****************************************************
# PSEUDOCODE
# multiply how many spaces u moved * 4
# 0x000000XX <- move 4 steps 0x00XX0000 -> %input
# 0x000000YY + 0x00XX0000 -> %input
#*****************************************************
.macro formatCoordinates(%output %x %y)
	sll %output %x 16
	add %output %x %y
	
.end_macro 
.data
originAddress: .word 0xFFFF0000
.text
j done
    
done: nop
	li $v0 10 
	syscall
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#  Subroutines defined below
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#Clear_bitmap: Given a color, will fill the bitmap display with that color.
#   Inputs:
#    $a0 = Color in format (0x00RRGGBB) 
#   Outputs:
#    No register outputs
#    Side-Effects: 
#    Colors the Bitmap display all the same color
#*****************************************************
# PSEUDOCODE
# start from start address
# for loop from start to last address
# startaddress += 4 to keep moving
# sw colour as we go 
#*****************************************************
clear_bitmap: nop
	li $t1 0xfffffffc				# 0xfffffffc where to end
	lw $t2 originAddress			# 0xFFFF0000 where to start 	
	colorloop: 				# for (0xFFFF0000-0xfffffffc)
	bgt $t2 $t1 exit				# if i < 0xfffffffc
	sw  $a0 ($t2) 				# colour address
	addi $t2 $t2 4				# i += 4
	b colorloop				# continue loop 
	exit:					# jumping label 
 	jr $ra
 	
#*****************************************************
# draw_pixel:
#  Given a coordinate in $a0, sets corresponding value
#  in memory to the color given by $a1	
#-----------------------------------------------------
#   Inputs:
#    $a0 = coordinates of pixel in format (0x00XX00YY)
#    $a1 = color of pixel in format (0x00RRGGBB)
#   Outputs:
#    No register outputs
#*****************************************************
# PSEUDOCODE
# break into x and Y 
# use math formula 
# (4X + 4Y*128 ) add starting address to this
# simplify math formula 4(x+128y) +  0xFFFF0000
# sw colour as we go 
#*****************************************************

draw_pixel: nop	
	li $t3 0					# x-coord = 0
	li $t4 0 				# y-coord = 0	
	getCoordinates($a0 $t3 $t4)		# fills x-coord & y-coord 
	lw $t2 originAddress			# start_point = 0xFFFF0000
	mul $t5 $t4 128 				# (y-coord * row size(128)) 
	add $t6 $t5 $t3 				# (^) + x-coord
	mul $t6 $t6 4				# (^) * 4
	add $t6 $t6 $t2 				# (^) +0xffff0000
	sw  $a1 ($t6) 				# colour address
	li $t5 0					# calc = 0
	li $t6 0					# finalcoord = 0
	jr $ra
	
#*****************************************************
# get_pixel:
#  Given a coordinate, returns the color of that pixel	
#-----------------------------------------------------
#   Inputs:
#    $a0 = coordinates of pixel in format (0x00XX00YY)
#   Outputs:
#    Returns pixel color in $v0 in format (0x00RRGGBB)
#*****************************************************
# PSEUDOCODE
# break into x and Y 
# use same math formula 
# (4X + 4Y*128 ) add starting address to this
# simplify math formula 4(x+128y) +  0xFFFF0000
#*****************************************************

get_pixel: nop
	li $t3 0					# x-coord = 0
	li $t4 0 				# y-coord = 0
	getCoordinates($a0 $t3 $t4)		# fills x-coord & y-coord 
	lw $t2 originAddress			# start_point = 0xFFFF0000
	mul $t5 $t4 128 				# (y-coord * row size(128)) 
	add $t6 $t5 $t3 				# (^) + x-coord
	mul $t6 $t6 4				# (^) * 4
	add $t6 $t6 $t2 				# (^) +0xffff0000
	lw  $v0 ($t6) 				# colour address
	li $t5 0					# calc = 0
	li $t6 0					# finalcoord = 0
	jr $ra

#*****************************************************
#draw_rect: Draws a rectangle on the bitmap display.
#	Inputs:
#		$a0 = coordinates of top left pixel in format (0x00XX00YY)
#		$a1 = width and height of rectangle in format (0x00WW00HH)
#		$a2 = color in format (0x00RRGGBB) 
#	Outputs:
#		No register outputs
#*****************************************************
# PSEUDOCODE
# break into x and Y 
# break into WW and HH
# forloop Y from Y to y+HH: 
# forloop X from X to X+WW
# 	use same math formula 
# 	use math formula 4(x+128y) +  0xFFFF0000
# 	sw colour as we go
#	increment X and Y by 1 
#***************************************************
draw_rect: nop
	li $t0 0 				# WW = 0
	li $t1 0  				# HH = 0
	li $t3 0 				# x-coord = 0
	li $t4 0					# y-coord = 0
	getCoordinates($a1,$t0,$t1)     		# break up WW and HH
	getCoordinates($a0 $t3 $t4)		# t3 is og x-coord and t4 is og y-coord
	add $t5 $t3 0				# copyx 
	add $t7 $t0 $t3				# x-coord + WW = finalX
	add $t8 $t1 $t4				# y-coord +HH = finalY
	colloop: 				# for (y-coord - finalY)
	beq $t4 $t8 exit3                   	# if y = final y
	add $t3 $t5 0 				# restart the x to the begining 
	rowloop: 				# for (x-coord - finalX)
	lw $t2 originAddress			# start_point = 0xFFFF0000
	beq $t3 $t7 exit2				# if x-coord < finalX
	li $t6 0					# final coord = 0 
	mul $t6 $t4 128 				# (y-coord * row size(128)) 
	add $t6 $t6 $t3 				# (^) + x-coord
	mul $t6 $t6 4				# (^) * 4
	add $t2 $t2 $t6 				# (^) +0xffff0000
	sw  $a2 ($t2) 				# colour address
	addi $t3 $t3 1				# x-coord += 1
	b  rowloop				# continue loop 
	exit2: 					# jumping label
	addi $t4 $t4 1				# y-coord += 1
	b colloop				# continue loop 
	exit3: 					# jumping label 
 	jr $ra
 	
#***********************************************
# draw_diamond:
#  Draw diamond of given height peaking at given point.
#  Note: Assume given height is odd.
#-----------------------------------------------------
#Draw_diamond(height, base_point_x, base_point_y)
#			for (dy = 0; dy <= h; dy++)
#				y = base_point_y + dy
#
#				if dy <= h/2
#					x_min = base_point_x - dy
#					x_max = base_point_x + dy
#				else
#					x_min = base_point_x - h + dy
#					x_max = base_point_x + h - dy
#				use math formula 4(x+128y) +  0xFFFF0000 <-- address
#	 			for (x=x_min; x<=x_max; x++) 
#				 address += 4 (moving down the row)
#					
#-----------------------------------------------------
#   Inputs:
#    $a0 = coordinates of top point of diamond in format (0x00XX00YY)
#    $a1 = height of the diamond (must be odd integer)
#    $a2 = color in format (0x00RRGGBB)
#   Outputs:
#    No register outputs
#***************************************************
draw_diamond: nop
	li $t1 0					# half-height = 0
	div $t1 $a1 2				# half-height = h/2
	li $t3 0  				# base_point_x = 0
	li $t4 0  				# base_point_y = 0
	li $t0 0  				# dy = 0 
	getCoordinates($a0 $t3 $t4)		# t3 is base_point_x and t4 is base_point_y	
	forloop: 				# for loop (dy - height)
	bgt $t0 $a1 exit4 			# dy  = h
	li $t6 0 				# x-min = 0
	li $t7 0 				# x_max = 0
	li $t5 0 				# y = 0	
	add $t5 $t4 $t0				# y = base_point_y + dy
	ble $t0 $t1 if				# check if dy <= h/2
	sub $t6 $t3 $a1				# x_min = base_point_x - h
	add $t6 $t6 $t0				# (^) + dy
	add $t7 $t3 $a1				# x_max = base_point_x + h 
	sub $t7 $t7 $t0				# (^) - dy  
	move $t2 $t6 				# x = xmin
	b else					# continue loop 
	if: 					# if dy <= h/2
	sub $t6 $t3 $t0				# x_min = base_point_x - dy					
	add $t7 $t3 $t0				# x_max = base_point_x + dy
	li $t2 0					# copyx = 0
	add $t2 $t6 0 				# x = xmin
	li $t8 0					# clearing t8 to store final coord 
	else: 					# jumping label for else
	lw $t8 originAddress			# start_point = 0xFFFF0000
	mul $t5 $t5 128 				# (y-coord * row size(128)) 
	add $t5 $t5 $t2 				# (^) + x-coord
	mul $t5 $t5 4				# (^) * 4
	add $t8 $t8 $t5 				# t1 contains final address (128y + x) * 4
	forloop2: 				# for (x-min - x-max)
	bgt $t2 $t7 here				# from x min to x-max ERRORIS HERE
	sw  $a2 ($t8) 				# colour address
	addi $t8 $t8 4				# finaladdress+= 4
	addi $t2 $t2 1				# x-min += 1
	b forloop2				# continue loop 
	here: 					# jumping label 
	addi $t0 $t0 1				# dy += 1
	b forloop				# continue loop 
	exit4:					# jumping label 
	li $t8 0 				# finalcoord = 0
	jr $ra

