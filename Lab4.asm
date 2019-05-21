#####################################################################
# Created by:  Gadhiraju, Sathya
#              sgadhira
#              20 February 2019
#
# Assignment:  Lab 4: ASCII Conversion
#              CMPE 012, Computer Systems and Assembly Language
#              UC Santa Cruz, Winter 2019
#
# Description: This program takes user input in either binary or hex and prints out the sum of both numbers in base 4.
#
# Notes:       This program is intended to be run from the MARS IDE.
#####################################################################

# USER INPUT:
# User will enter in values

# PRINTING:
# Read in values 
# Print "You entered the numbers:"
# Print the user inputted values 

# IDENTIFICATION:
# 	if the number is binary
#		store first value in the first register
#
# 	else if the number is hex
#		convert value from hex to binary
#		store first value in the first register
#
# 	else if the number is decimal
#		convert value from decimal to binary
#		store first value in the first register
#
#
# 	if the number is binary
#		store second value in the second register
#
# 	else if the number is hex
#		convert value from hex to binary
#		store second value in the second register
#
# 	else if the number is decimal
#		convert value from decimal to binary
#		store second value in the second register
#
# ADDING:
# Take value from first register and second register
# Store sum in third register $s0
#
# PRINTING SUM:
# Convert binary to base 4 
# 	if number is negative
#		print magnitude and negative sign
#
# 	else if number is positive
# 		print magnitude 
# 

.data
 spacer: .asciiz "\n"
 hexInput: .asciiz "You entered the numbers:\n"
 binInput: .asciiz " "
 theSum: .asciiz "\nThe sum in base 4 is:\n" 

.text
.globl main
main:
    lw $t3, 0($a1)			#Get first program input.
    lw $t4,4($a1)			#Get Second program input.
    la $a0, hexInput			#Print String.
    li $v0, 4				
    syscall

    move $a0,$t3
    li $v0, 4             		#print first Input.
    syscall  

    la $a0, binInput			# print string for second Binary input argument.
    li $v0, 4
    syscall

    move $a0, $t4
    li $v0, 4             		 # print second program argument
    syscall 

    la $a0, spacer
    li $v0, 4				 # Print newline 
    syscall
    
    lb $t0 ($t3)
    beq $t0 '0' HexaorBinary
    b Decimal
    
    HexaorBinary:
    lb $t0 1($t3)
    beq $t0 'x' fromHexaStringToDecimal
    b fromBinaryStringToDecimal

  # Hex to Decimal                  
 fromHexaStringToDecimal:
  # start counter
    addi $t3 $t3 2       		# load inputNumber address to t2
    li   $t8, 0                      	# start our counter
    li   $t1 16
    li   $t5 1
    li   $s1 0
 
hexaStringToDecimalLoop:
    beq  $t8 2 endLoop
    lb   $t0, ($t3)
    ble  $t0, '9', inputSub48       	# if t7 less than or equal to char '9' inputSub48
    addi $t0, $t0, -55              	# convert from string (ABCDEF) to int
    inputHexaNormalized:
    mult $t0 $t1
    mflo $t0
    div $t1 $t1 $t1
    add $s1 $s1 $t0
    addi $t8 $t8 1
    addi $t3 $t3 1
    b hexaStringToDecimalLoop

inputSub48:
    addi $t0, $t0, -48              	# convert from string (ABCDEF) to int
    j   inputHexaNormalized

endLoop:
b secondInputCheck

fromBinaryStringToDecimal:
#binary to Integer 
startConvert:           		 # initialize counter to 16
  addi $t1 $t1 16
  addi $t5 $t5 128
  li $s1 0
  li $t6 2
  addi $t3 $t3 2
firstByte:
  lb $t2, ($t3)      			# load the first byte
  beq $t1, 8, endLoop1  		 # branch if less than 48
  addi $t3, $t3, 1         		 # increment offset
  subi $t2, $t2, 48        		 # subtract 48 to convert to int value
  subi $t1, $t1, 1          		# decrement counter
  mult $t2 $t5
  mflo $t2
  div $t5 $t5 $t6
  add $s1 $s1 $t2
  j firstByte     
   endLoop1:
   j secondInputCheck
   
   Decimal:
   li $s1 0
   li $t5 10
   lb $t0 ($t3)
   seq $t1 $t0 45
   beqz $t1 decLoop
   addi $t3 $t3 1
   decLoop:
   lb $t0 ($t3)
   beqz $t0 enddecloop
   subi $t0 $t0 48
   mult $s1 $t5
   mflo $s1
   add $s1 $s1 $t0
   addi $t3 $t3 1
   j decLoop
   enddecloop:
   beqz $t1 secondInputCheck
   li $t1 -1
   mult $s1 $t1
   mflo $s1
   j secondInputCheck
secondInputCheck:
    lb $t0 ($t4)
    beq $t0 '0' HexaorBinary2
    b Decimal2
    
    HexaorBinary2:
    lb $t0 1($t4)
    beq $t0 'x' fromHexaStringToDecimal2
    b fromBinaryStringToDecimal2

  # Hex to Decimal                  
 fromHexaStringToDecimal2:
  # start counter
    addi $t4 $t4 2       		# load inputNumber address to t2
    li   $t8, 0                      	# start our counter
    li   $t1 16
    li   $t5 1
    li   $s2 0
 
hexaStringToDecimalLoop2:
    beq  $t8 2 endLoop2
    lb   $t0, ($t4)
    ble  $t0, '9', inputSub482       	# if t7 less than or equal to char '9' inputSub48
    addi $t0, $t0, -55              	# convert from string (ABCDEF) to int
    inputHexaNormalized2:
    mult $t0 $t1
    mflo $t0
    div $t1 $t1 $t1
    add $s2 $s2 $t0
    addi $t8 $t8 1
    addi $t4 $t4 1
    b hexaStringToDecimalLoop2

inputSub482:
    addi $t0, $t0, -48              	# convert from string (ABCDEF) to int
    j   inputHexaNormalized2

endLoop2:
b converted

fromBinaryStringToDecimal2:
#binary to Integer 
startConvert2:           		 # initialize counter to 16
  addi $t1 $t1 16
  addi $t5 $zero 128
  li $s2 0
  li $t6 2
  addi $t4 $t4 2
firstByte2:
  lb $t2, ($t4)      			# load the first byte
  beq $t1, 8, endLoop3  		 # branch if less than 48
  addi $t4, $t4, 1         		 # increment offset
  subi $t2, $t2, 48        		 # subtract 48 to convert to int value
  subi $t1, $t1, 1          		# decrement counter
  mult $t2 $t5
  mflo $t2
  div $t5 $t5 $t6
  add $s2 $s2 $t2
  j firstByte2     
   endLoop3:
   j converted
   
   Decimal2:
   li $s2 0
   li $t5 10
   lb $t0 ($t4)
   seq $t1 $t0 45
   beqz $t1 decLoop2
   addi $t4 $t4 1
   decLoop2:
   lb $t0 ($t4)
   beqz $t0 enddecloop2
   subi $t0 $t0 48
   mult $s2 $t5
   mflo $s2
   add $s2 $s2 $t0
   addi $t4 $t4 1
   j decLoop2
   enddecloop2:
   beqz $t1 converted
   li $t1 -1
   mult $s2 $t1
   mflo $s2
   j converted

converted:
sgt $t0 $s1 127
sgt $t1 $s2 127
beqz $t0 signExtend0
j signExtend1
signExtend0:
ori $s1 $s1 0x00000000
j convert2
signExtend1:
ori $s1 $s1 0xFFFFFF00
convert2:
beqz $t1 secsignExtend0
j secsignExtend1
secsignExtend0:
ori $s2 $s2 0x00000000
j printSum
secsignExtend1:
ori $s2 $s2 0xFFFFFF00

printSum:
la $a0, theSum
li $v0, 4
syscall

add $s0, $s1, $s2 

add $t0 $zero $s0
li $t1 4
subi $sp $sp 8
li $t2 0

slti $t3 $t0 0
beqz $t3 factorLoop
li $t4 -1
mult $t0 $t4
mflo $t0
li $v0 11
la $a0 0x2D
syscall
factorLoop:
beqz $t0 print
div $t0 $t1
mflo $t0
mfhi $t3
sb $t3 ($sp)
addi $sp $sp 1
addi $t2 $t2 1
j factorLoop
print:
beqz $t2 exit
addi $sp $sp -1
lb $t0 ($sp)
addi $t0 $t0 48
li $v0 11
move $a0 $t0
syscall
addi $t2 $t2 -1
j print
exit:
addi $sp $sp 8


    li $v0, 10              		# exit code
    syscall                		# terminate cleanly