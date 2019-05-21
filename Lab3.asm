####################################################################
# Created by:  Gadhiraju, Sathya
#              sgadhira 
#              15 Feb 2019 
# 
# Assignment:  Lab 3: MIPS Looping ASCII Art   
#              CMPE 012, Computer Systems and Assembly Language 
#              UC Santa Cruz, Winter 2019 
#  
# Description: This program draws triangles based on user input regarding length of the legs and amount of triangles.
#  
# Notes:       This program is intended to be run from the MARS IDE. 
#####################################################################

.data
    qstn1: .asciiz "Enter the length of one of the triangle legs: "
    qstn2: .asciiz "Enter the number of triangles to print: "
    nLine: .asciiz "\n"

.text
    main:
        # REGISTER USAGE 
        # $t0: user input- length of leg
        # $t1: user input- amount of triangles
        # $t2: loop counter- first triangle line
        # $t3: loop counter- second triangle line
        # $t4: loop counter- first triangle line spaces
        # $t5: loop counter- second triangle line spaces
        # $t6: loop counter- total number triangles
        # $t7: loop-counter- total number spaces
        
     
        #FIRST INPUT
        li $v0, 4	#Print prompt for first user input regarding length of leg
        la $a0, qstn1
        syscall
        
        li $v0, 5	#Read integer input for length of leg
        syscall
        
        move $t0, $v0	#Move input regarding length of leg to register t0
        
        
        #SECOND INPUT
        li $v0, 4	#Print prompt for second user input regarding amount of triangles
        la $a0, qstn2
        syscall

        li $v0, 5 	#Read integer input for amount of triangles
        syscall

        move $t1, $v0	#Move input regarding amount of triangles to register t0

       while:
       beq $t2, $t1, exit
       
       
        for:		#For loop which initializes the variable in the loop to 0
        add $t6, $zero, $zero
        beq $t6, $t1, exit                  
        
        	for1:		#For loop for printing first triangle line
		add $t4, $zero, $zero    
		beq $t6, $t0, exit1           
                
        		for2:		#For loop for printing spaces for first triangle line
        		beq $t4, $t6, exitfor1
        		li $a0, 32	#ASCII Code 32 indicates space
        		li $v0, 11      #Syscall number prints space          
        		syscall
        		
        		addi $t4, $t4, 1
        		j for2
        		exitfor1:
        		
             		addi $t6, $t6, 1
                	li $a0, 92	#ASCII Code 92 indicates '\'
                	li $v0, 11      #Syscall number prints '\'                
                	syscall   
                	
 			la $a0, nLine 
                	li $v0, 4	#Syscall number prints new line
                	syscall
           		j for1
            	exit1:           
            	add $t3, $zero, $zero 
           	move $t5, $t0 		#Moves value from t5 to t0
           	
            	for3:			#For loop for printing second triangle line
            	add $t7, $zero, $zero 
                beq $t3, $t0, exit6
                sub $t5, $t5, 1                  
 
                	for4:		#For loop for printing spaces for first triangle line
                	beq $t7, $t5, exitfor2
                	li $a0, 32	#ASCII Code 32 indicates space
                	li $v0, 11      #Syscall number prints space 
                	syscall
                	
                	addi $t7, $t7, 1
                	j for4
                	exitfor2:
                
                	li $a0, 47	#ASCII Code 47 indicates '/'
                	li $v0, 11      #Syscall number prints '/'                  
                	syscall    
               
                	la $a0, nLine #Syscall number prints new line
                 	li $v0, 4
                	syscall       
                	addi $t3, $t3, 1
	             	j for3
            	exit6:  
            	       
            	addi $t2, $t2, 1
            	
            	j while
            	                                        
        	exit:

        li $v0, 10
                             
        syscall              #Syscall number to exit program
