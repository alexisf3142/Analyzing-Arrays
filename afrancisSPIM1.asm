#----------------------------------------------------------------------------#
# afrancisSPIM1.a
# Alexis Francis 
# Description: This program reads in user input of an array and calculates
# the size, maximum value, integer mean, and the remainder, the mode, and outputs
# a bar graph indicating the frequency of each value.
# Input: The input for this program is up to 25 integer values in the range 1 to 21.
# Output: The output for this program is strings to clairfy the number being output,
# the number of values input, the maximum value, the integer mean, the remained found when
# computing the mean, the mode(s), and a bar graph that shows the frequency of each number
# that was entered. For each value that is output an appropriate string indicates what the
# number is, I also make use of the proper spacing and new lines. 
#----------------------------------------------------------------------------#
	.data
endl:	.asciiz "\n"
list:	.word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
freqlist: .word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
modelist: .word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
outval: .asciiz "The number of values input: "
maxval: .asciiz "The maximum value is: "
meanval: .asciiz "The mean is: "
meanrem: .asciiz "The integer remainder while calculating mean is: "
modeval: .asciiz "The mode(s) are: "
complete: .asciiz "Program completed :)"
plus: .asciiz "+"
space: .asciiz " "
#----------------------------------------------------------------------------#
	.text
	.globl main
#initializing variables	
main:
	li $t0, 0					#set "offset" to 0 at first 
	li $t1, 4					#set number of bytes to 4 (for int)
	li $t2, 1					#constant 1
	li $t3, 0					#set "counter" to 0
	li $t4, 25					#end of array
	li $t6, 21					#higher range of array (its 21 because we arent counting 0)
	li $t7, 0					#to keep track of the size
	
	li $s0, 0					#to keep track of the maximum value
	li $s1, 0					#the integer mean
	li $s2, 0					#the integer remainder found when computing the mean
	li $s3, 0					#mode offset to 0

	li $s5, 0					#saves the mode
	li $s7, 0					#current mode frequency
#start of input loop
inputloop:
	beq $t3, $t4, output
	li $v0, 5					#v0 stores user's input initially
	syscall		
	move $t5, $v0				#move user input to $t5
	
	j checkinput				#jump to negative

#the input loop continues, we wouldn't want to loop all the way
#back up otherwise we disregard the value we just checked.
inputloopcont:	
	sw $t5, list($t0)			#store $t5 into list[offset]
	add $t7, $t7, $t2			#increase the size of the list
	add $s1, $s1, $t5			#add to the mean which we will calculate later
	add $t3, $t3, $t2			#increment "counter"
	mul $t0, $t3, $t1			#find new offset
	
	j mode
	
#this is the end of the input loop
back:
	bgt $t5, $s0, max   		#compare the int $t5 with the current maximum $s0
	
	j inputloop					#loop back up to inputloop
	
#this checks the value of the input, and whether its in range or negative
checkinput:						#checks if integer is in range {1..20} and if negative
	blez $t5, output			#is $t5 (input) negative?
	bgt $t5, $t6, output		#is $t5 (input) in range?
	
	j inputloopcont				#loop back to inputloopcont because if you went to inputloop
								#it would take another variable and we dont want that
							
#this stores the new maximum and goes back to the start of the loop	
max:
	add $s0, $t5, $zero			#adds the new maximum with zero and stores it in $s0
	
	j inputloop					#jumps back up to inputloop
	
#the mean is computed after all values have been added	
mean:
	divu $s1, $t7				#divide all the values that have been added up with the size
	mflo $s1					#move the quotient into $s1
	mfhi $s2					#move the remainder into $s2
	
	j outputcont				#go back to outputting

#start of finding the mode
mode:
	mul $s3, $t5, $t1			#finds the offset for freqlist by multiplying the value and number of bytes
	
	lw $s4, freqlist($s3)		#load the number at the offset
	add $s4, $s4, $t2			#add 1 to the number
	sw $s4, freqlist($s3)		#put the new frequency number back
	
	j calcmode					#jump to calcmode
	j back						#jump back to user unput

#looking for bigger mode	
calcmode:
	bgt $s4, $s7, newmode		#frequency at "current mode"
	
	j back						#jump back to user input

#a bigger mode was found
newmode:
	move $s5, $t5				#user input is now mode
	move $s7, $s4				#copies frequency of new mode
	
	j back						#jump back to user input

#checking if there are multiple modes
modeduplicates:
	lw $s6, freqlist($s3)		#the frequency at the offset of $s3	
	beq $s1, $t4, aftermodeprint#till counter is array size
	beq $s7, $s6, multimodeprint#comparing desired frequency with frequncy at offset
	j modeincrement				#increment the counter and offset

#prints the modes
multimodeprint:
	li $v0, 1			
	div $a0, $s3, $t1
	syscall						#printing the mode
	
	li $v0, 4					
	la $a0, space
	syscall						#printing a space
	
	j modeincrement				#increment the counter and offset
	
#increments the offset and counter for finding modes in list
modeincrement:
	add $s3, $s3, $t1			#increment the offset by 4
	add $s1, $s1, $t2			#increment the counter by 1
	
	j modeduplicates			#loop to find more

#start of graph
graph: 
	
	li $t3, 1					#set "counter" to 1
	li $t0, 4					#set offset to 4
	add $s0, $s0, $t2			#add one to the max
	
	j graphloop
	
#prints from 1 to the maximum value that was entered to have a nice
#looking graph
graphloop:
	beq $t3, $s0, done			#loops from counter to max
	
	add $a0, $t3, $zero			#add counter and zero and store it in $a0
	li $v0, 1
	syscall						#prints out counter (1-max)
	
	li $v0, 4					
	la $a0, space
	syscall						#prints out a space for nice graph spacing
	
	lw $t9, freqlist($t0)		#load the number in freqlist[offset] and stores in $t9
	li $t8, 0 	 				#set internal counter to 0 for printplus
	bgt $t9, $zero, printplus
	
	j graphincrement
		
#loops from another 0 to $t9 which is how many times a number appeared
printplus:
	beq $t8, $t9, graphincrement

	li $v0, 4
	la $a0, plus
	syscall						#print a plus
	
	add $t8, $t8, $t2			#increment the inside counter
	
	j printplus					#loop printing
	
#increment to the next value for printing the graph out
graphincrement:
	add $t3, $t3, $t2
	mul $t0, $t3, $t1
	
	li $v0, 4
	la $a0, endl	
	syscall						#printing to a new line
	
	j graphloop					#loop back up to graphloop

#start outputting the strings with their corresponding 
#calculation (size, max, etc.)
output:
#print out the number of values input
	li $v0, 4
	la $a0, outval
	syscall						#printing outval string
	
	li $v0, 1
	move $a0, $t7
	syscall						#printing the size
	
	li $v0, 4
	la $a0, endl
	syscall						#printing to a new line
	
	li $v0, 4
	la $a0, maxval
	syscall						#printing maxval string
	
	li $v0, 1
	move $a0, $s0
	syscall						#printing the maximum value
	
	li $v0, 4
	la $a0, endl
	syscall						#printing to a new line
	
	j mean						#jump to mean, to calculate and find remainder

#continuing output
outputcont:
	li $v0, 4
	la $a0, meanval
	syscall						#printing meanval string
	
	li $v0, 1
	move $a0, $s1
	syscall						#printing the mean
	
	li $v0, 4
	la $a0, endl
	syscall						#printing to a new line
	
	li $v0, 4
	la $a0, meanrem	
	syscall						#printing meanrem string
	
	li $v0, 1
	move $a0, $s2
	syscall						#printing the mean remainder
	
	li $v0, 4
	la $a0, endl
	syscall						#printing to a new line
	
	li $v0, 4
	la $a0, modeval
	syscall

	li $s3, 0
	li $s1, 0
	j modeduplicates			#jump to find and print out all the modes
	
#continue printing after finding modes
aftermodeprint:

	li $v0, 4
	la $a0, endl
	syscall					#printing to a new line

	j graph					#start printing the graph

#program has finished :)
done:
	li $v0, 4
	la $a0, endl
	syscall					#printing to a new line
	
	li $v0, 4
	la $a0, complete
	syscall					#printing complete string
	
	li	$v0, 10		
	syscall	
	
#----------------------------------------------------------------------------#
