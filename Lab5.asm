#####################################################################
# Created by:  Gadhiraju, Sathya
#              sgadhira
#              07 March 2019
#
# Assignment:  Lab 5: Subroutines
#              CMPE 012, Computer Systems and Assembly Language
#              UC Santa Cruz, Winter 2019
#
# Description: This program takes user input and works with subroutines to generate an output depending on encryption or decryption.
#
# Notes:       This program is intended to be run from the MARS IDE.
#####################################################################		
#--------------------------------------------------------------------

# Register Usage:
# a0, a1, a2 are used as varying inputs to the subroutines and syscalls
# v0 is used as return values from the subroutines and for syscalls
# s0 contains address of E,D or X
# t0 contains character of E,D or X
# s1 contains address of key string
# s2 contains address of user input string for Enc/Dec
# s3 contains address of resulting string after cipher applied


# give_prompt
#
# This function should print the string in $a0 to the user, store the user’s input in
# an array, and return the address of that array in $v0. Use the prompt number in $a1
# to determine which array to store the user’s input in. 

# the first prompt to see if user input E, D, or X if not print error message and ask
# again.
#
# arguments:  $a0 - address of string prompt to be printed to user
#             $a1 - prompt number (0, 1, or 2)
#
# note:
# prompt 0: Do you want to (E)ncrypt, (D)ecrypt, or e(X)it?
#
# prompt 1: What is the key?
#
#  prompt 2: What is the string?
#
# return:     $v0 - address of the corresponding user input data
#--------------------------------------------------------------------

.data
 key: .space 100
 indata: .byte 1
 data: .space 100
 WrongKeyword: .asciiz "Invalid input: Please input E, D, or X.\n"
 endl:         .asciiz "\n"

# text
.text
give_prompt:
subi $sp $sp 12
sw $ra ($sp)
sw $a0 4($sp)
sw $a1 8($sp)


beqz $a1 zero
beq $a1 1 one
beq $a1 2 two

zero:
 # Encryption or Decryption
 lw $a0 4($sp)
 li $v0,4
 syscall
 # read the input
 la $a0,indata
 la $a1,2
 li $v0,8
 syscall 
  
 move $t0 $a0
 lb $t2,0($a0)
 li $v0 11
  la $a0 0x0A
  syscall
 beq $t2,69,endzero
 beq $t2,68,endzero
 beq $t2,88,endzero
 # Wrong Key word Enetred
 la $a0,WrongKeyword
 li $v0,4
 syscall
 
 j zero
 
 endzero:
 move $v0 $t0
 j end
 
 one:
 lw $a0 4($sp)
 li $v0,4
 syscall
# Read Key
 la $a0,key
 li $a1 100
 li $v0,8
 syscall
 
 move $v0 $a0
 j end
 
 two:
 # Read Plain text value
 lw $a0 4($sp)
 li $v0,4
 syscall
 la $a0,data
 la $a1,100  		# Maximum 40 characters can be read (This value can be changed as preferred)
 li $v0,8
 syscall
 move $v0 $a0 		# Entered string is stored in the t0 register
 j end 		        # string length
 
  end:
  lw $ra ($sp)
  addi $sp $sp 12
  jr $ra
  

#--------------------------------------------------------------------
# cipher
#
# Calls compute_checksum and encrypt or decrypt depending on if the user input E or
# D. The numerical key from compute_checksum is passed into either encrypt or decrypt
#
# note: this should call compute_checksum and then either encrypt or decrypt
#
# arguments:  $a0 - address of E or D character
#             $a1 - address of key string
#             $a2 - address of user input string
#
# return:     $v0 - address of resulting encrypted/decrypted string
#--------------------------------------------------------------------


.data
convert_str: .space 100

.text
cipher:
subi $sp $sp 28
sw $ra ($sp)
sw $a0 4($sp)
sw $a1 8($sp)
sw $a2 12($sp)
sw $s0 16($sp)
sw $s1 20($sp)
sw $s2 24($sp)
lw $a0 8($sp)
jal compute_checksum
move $t0 $v0
la $t1 convert_str
lw $t2 12($sp)
lw $t3 4($sp)
lb $t3 ($t3)
beq $t3 'E' cipherenc
beq $t3 'D' cipherdec
cipherenc:
lb $t4 ($t2)
beqz $t4 end1
move $a0 $t4
move $a1 $t0
jal encrypt
sb $v0 ($t1)
addi $t1 $t1 1
addi $t2 $t2 1
b cipherenc
cipherdec:
lb $t4 ($t2)
beqz $t4 end1
move $a0 $t4
move $a1 $t0
jal decrypt
sb $v0 ($t1)
addi $t1 $t1 1
addi $t2 $t2 1
b cipherdec
end1:
la $v0 convert_str
lw $ra ($sp)
lw $s0 16($sp)
lw $s1 20($sp)
lw $s2 24($sp)
addi $sp $sp 28
jr $ra

#--------------------------------------------------------------------
# compute_checksum
#
# Computes the checksum by xor’ing each character in the key together. Then,
# use mod 26 in order to return a value between 0 and 25.
#
# arguments:  $a0 - address of key string
#
# return:     $v0 - numerical checksum result (value should be between 0 - 25)
#--------------------------------------------------------------------

 .text
 compute_checksum:
 subi $sp $sp 8
 sw $ra ($sp)
 sw $a0 4($sp)

 li $t0 0
 lw $t1 4($sp)
 ccsloop:
 lb $t2 ($t1)
 beq $t2 10 endccsloop
 xor $t0 $t0 $t2
 addi $t1 $t1 1
 b ccsloop
 endccsloop:
 rem $t0 $t0 26
 move $v0 $t0
 lw $ra ($sp)
 addi $sp $sp 8
 jr $ra
 
#--------------------------------------------------------------------
# encrypt
#
# Uses a Caesar cipher to encrypt a character using the key returned from
# compute_checksum. This function should call check_ascii.
#
# arguments:  $a0 - character to encrypt
#             $a1 - checksum result
#
# return:     $v0 - encrypted character
#--------------------------------------------------------------------

.text
encrypt:
subi $sp $sp 12
sw $ra ($sp)
sw $a0 4($sp)
sw $a1 8($sp)
jal check_ascii
move $t5 $v0
lw $t4 4($sp)
beqz $t5 EncryptUpper
beq $t5 1 EncryptLower
b end2
EncryptLower:
lw $t5 8($sp)
add $t4, $t4, $t5
ble $t4 122 end2
rem $t4 $t4 122
li $t5 96
add $t4,$t5,$t4
j end2
EncryptUpper:
lw $t5 8($sp)
add $t4, $t4, $t5
ble $t4 90 end2
rem $t4 $t4 90
li $t5 64
add $t4,$t5,$t4
j end2
end2:
move $v0 $t4
lw $ra ($sp)
lw $a0 4($sp)
lw $a1 8($sp)
addi $sp $sp 12
jr $ra

#--------------------------------------------------------------------
# decrypt
#
# Uses a Caesar cipher to decrypt a character using the key returned from
# compute_checksum. This function should call check_ascii.
#
# arguments:  $a0 - character to decrypt
#             $a1 - checksum result
#
# return:     $v0 - decrypted character
#--------------------------------------------------------------------
.text
decrypt:
subi $sp $sp 12
sw $ra ($sp)
sw $a0 4($sp)
sw $a1 8($sp)
jal check_ascii
move $t5 $v0
lw $t4 4($sp)
beqz $t5 DecryptUpper
beq $t5 1 DecryptLower
b end3
DecryptLower:
lw $t5 8($sp)
sub $t4, $t4, $t5
bge $t4 97 end3
li $t5 97
li $t6 123
rem $t4 $t5 $t4
sub $t4,$t6,$t4
j end3
DecryptUpper:
lw $t5 8($sp)
sub $t4, $t4, $t5
bge $t4 65 end3
li $t5 65
li $t6 91
rem $t4 $t5 $t4
sub $t4,$t6,$t4
j end3
end3:
move $v0 $t4
lw $ra ($sp)
lw $a0 4($sp)
lw $a1 8($sp)
addi $sp $sp 12
jr $ra

#--------------------------------------------------------------------
# check_ascii
#
# This checks if a character is an uppercase letter, lowercase letter, or
# not a letter at all. Returns 0, 1, or -1 for each case, respectively.
#
# arguments:  $a0 - character to check
#
# return:     $v0 - 0 if uppercase, 1 if lowercase, -1 if not letter
#--------------------------------------------------------------------
.text
check_ascii:
subi $sp $sp 8
sw $ra ($sp)
sw $a0 4($sp)
islower:
bgt $t4,122,Notchar	 	# if the character is not lower case or upper case
blt $t4,97,checkupper		# if the character is not lower case 
li $v0,1   				# store value 1 in register V0 if the character is a lower case character
lw $ra ($sp)
addi $sp $sp 8
jr $ra    
checkupper:
blt $t4,65,Notchar		# if the character is not upper or lower
bgt $t4,91,Notchar		# if character is not upper or lower
li $v0,0   
lw $ra ($sp)
addi $sp $sp 8
jr $ra    				# store value 0 in register V0 if the character is upper case
Notchar:
li $v0 -1
lw $ra ($sp)
addi $sp $sp 8
jr $ra   

#--------------------------------------------------------------------
# print_strings
#
# Determines if user input is the encrypted or decrypted string in order
# to print accordingly. Prints encrypted string and decrypted string. See
# example output for more detail.
#
# arguments:  $a0 - address of user input string to be printed
#             $a1 - address of resulting encrypted/decrypted string to be printed
#             $a2 - address of E or D character
#
# return:     prints to console
#--------------------------------------------------------------------
.data
resprompt:    .asciiz "\nHere is the encrypted and decrypted string:\n"
eprompt: .asciiz "<encrypted> "
dprompt: .asciiz "<decrypted> "
  
.text
print_strings:
subi $sp $sp 16
sw $ra ($sp)
sw $a0 4($sp)
sw $a1 8($sp)
sw $a2 12($sp)
move $t0 $a0
move $t1 $a1
lw $t2 12($sp)
lb $t2 ($t2)
beq $t2 'E' eprint
beq $t2 'D' dprint
eprint:
li $v0 4
la $a0 resprompt
syscall
li $v0 4
la $a0 eprompt
syscall
lp:
lb $t2 ($t1)
beq $t2 10 elp
move $a0 $t2
li $v0 11
syscall
addi $t1 $t1 1
b lp
elp:
li $v0 11
la $a0 0x0A
syscall
li $v0 4
la $a0 dprompt
syscall
lp2:
lb $t2 ($t0)
beq $t2 10 end4
move $a0 $t2
li $v0 11
syscall
addi $t0 $t0 1
b lp2
dprint:
li $v0 4
la $a0 resprompt
syscall
li $v0 4
la $a0 eprompt
syscall
lp3:
lb $t2 ($t0)
beq $t2 10 elp3
move $a0 $t2
li $v0 11
syscall
addi $t0 $t0 1
b lp3
elp3:
li $v0 11
la $a0 0x0A
syscall
li $v0 4
la $a0 dprompt
syscall
lp4:
lb $t2 ($t1)
beq $t2 10 end4
move $a0 $t2
li $v0 11
syscall
addi $t1 $t1 1
b lp4
end4:
li $v0 11
la $a0 0x0A
syscall
lw $ra ($sp)
addi $sp $sp 16
jr $ra
