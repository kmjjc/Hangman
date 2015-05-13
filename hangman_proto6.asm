#
# This code is to test loading of a string, preparing an answer string for
# guesswork, and uncovering the mystery string with user input.
#
# hangman_proto2: Additions to the first prototype include holding number of
# guesses left, keeping track of which letters have been guessed, routine for
# repeating game
#
# hangman_proto3: Accomodates for spaces/nonlowercase letter characters in the
# word to guess
#
# hangman_proto4: Added in word bank and procedure to choose a word from this
# word bank to load into answerString; commented out the parts used for the
# old input process
#
# hangman_proto5: Draws the graphics for the game. Hangman, gallows, guesses,
# and the mystery word are all displayed on the KGAS screen
#
# hangman_proto6: Clears the graphics after each game to allow replayability
#
# Saved variables:
# s4 - size of current guesses made
# s5 - number of guesses left
# s6 - current letter guess
# s7 - variable for checking
#

			.data

announce2:		.asciiz "Mystery word is: "			# Prompt of status of mystery word
guessPrompt:		.asciiz "Type a lowercase letter guess: "	# Ask for a character to guess
invalidGuess:		.asciiz "Answer not in range, try again.\n"	# Notify when guess is not in range
newLine:		.asciiz "\n"					# Simple newline output
alreadyPrompt:		.asciiz "Letter has been guessed before.\n"	# Notify user letter has been guessed before
wrongGuess:		.asciiz "Wrong guess. Guesses left: "		# Notify when wrong letter guessed
noGuesses:		.asciiz "You're out of guesses. The word is: "	# Prompt for no guesses left
playAgainPrompt:	.asciiz "Press 'y' to play again: "		# Prompt asking if player wants to play again
answerString:		.space 20					# allow for a 20-character word
mysteryString:		.space 20					# reserve space for a 20-character mystery word
prevGuessArray:		.space 28					# reserve space for tracking guesses
resetString: 		.asciiz  "                    "			# 20 character long space for reset

x: 			.byte 3						#save x pos on screen					
y: 			.byte 25					#save y pos on screen
three: 			.byte 3						#holds constant 3
twentyseven:		.byte 27					#holds constant 27
input:			.word 0						#current input to screen

wordStorage:		.asciiz "archery"				# start of word bank
			.space 12					# bytes taken up by word and space equals 20
			.asciiz "aerial"
			.space 13
			.asciiz "bagel"
			.space 14
			.asciiz "brandish"
			.space 11
			.asciiz "chocolate"
			.space 10
			.asciiz "caramel"
			.space 12
			.asciiz "dramatic"
			.space 11
			.asciiz "deus ex machina"
			.space 4
			.asciiz "eternity"
			.space 11
			.asciiz "egotistical"
			.space 8
			.asciiz "fire in the hole"
			.space 3
			.asciiz "frolic"
			.space 13
			.asciiz "gargantuan"
			.space 9
			.asciiz "grandmaster"
			.space 8
			.asciiz "hole in one"
			.space 8
			.asciiz "hula hoop"
			.space 10
			.asciiz "indigo"
			.space 13
			.asciiz "impossible"
			.space 9
			.asciiz "jocularity"
			.space 9
			.asciiz "jaguar"
			.space 13
			.asciiz "king of the hill"
			.space 3
			.asciiz "karma"
			.space 14
			.asciiz "lyrical"
			.space 12
			.asciiz "lemonade"
			.space 11
			.asciiz "memento mori"
			.space 7
			.asciiz "make up your mind"
			.space 2
			.asciiz "nightmare"
			.space 10
			.asciiz "night of the lepus"
			.space 1
			.asciiz "orange"
			.space 13
			.asciiz "osmosis"
			.space 12
			.asciiz "press your luck"
			.space 4
			.asciiz "paranormal"
			.space 9
			.asciiz "quantum"
			.space 12
			.asciiz "quark"
			.space 14
			.asciiz "right or wrong"
			.space 5
			.asciiz "realistic"
			.space 10
			.asciiz "spaghetti"
			.space 10
			.asciiz "systematic"
			.space 9
			.asciiz "trustworthy"
			.space 8
			.asciiz "trick or treat"
			.space 5
			.asciiz "utopia"
			.space 13
			.asciiz "unabridged"
			.space 9
			.asciiz "vernacular"
			.space 9
			.asciiz "vivid imagination"
			.space 2
			.asciiz "wonderful"
			.space 10
			.asciiz "wizard of oz"
			.space 7
			.asciiz "xenophobia"
			.space 9
			.asciiz "x marks the spot"
			.space 3
			.asciiz "yin and yang"
			.space 7
			.asciiz "yearly"
			.space 13
			.asciiz "zenith"
			.space 13
			.asciiz "zealot"
			.space 13


			.text
main:
			add $s4, $zero, $zero				# set size of array of guessed letters to zero
			addi $s5, $zero, 7				# set $s5 to max number of guesses					
							
			jal gallows					# draw the gallows on the KGAS screen
			
			jal answerSetup					# jump to answerSetup subroutine
			jal mysteryCreate				# jump to mysteryCreate subroutine
			jal mysteryTest					# jump to mysteryTest subroutine			
			
			la $a0, mysteryString				# load mysteryString to $a0
			jal printWordToScreen				# print mysteryString to screen
		
guessRoutine:		la $a0, guessPrompt 				# load guessPrompt address into $a0
			li $v0, 4 					# set $v0 for a string output call
			syscall						
			li $v0, 12					# create a call to read a character					
			syscall						
			move $s6, $v0					# set contents of $s6 to $v0
			la $a0, newLine 				# load guessPrompt address into $a0
			li $v0, 4 					# set $v0 for a string output call
			syscall		
		
			add $s7, $zero, $zero				# set $s7 to zero
			jal rangeCheck					# execute rangeCheck subroutine
			beq $s7, $zero, rangeCheckPass			# if range check passes, continue
			j guessRoutine					# jump back to start of guessRoutine on failure
rangeCheckPass:		add $s7, $zero, $zero				# set $s7 to zero
			jal prevGuessCheck				# execute prevGuessCheck subroutine
			beq $s7, $zero, prevGuessCheckPass		# if prevGuessCheck passes, continue			
			j guessRoutine					# jump back to start if letter was guessed before
prevGuessCheckPass:	add $s7, $zero, $zero				# set $s7 to zero			
			jal revealMystery				# jump to revealMystery subroutine
			la $a0, mysteryString				# load mysteryString to $a0
			jal printWordToScreen				# print mysteryString to screen
			ble $s5, $zero, gameOver			# if guesses have been reduced to 0, branch to game over
			jal mysteryTest					# jump to mysteryTest subroutine
			addi $s4, $s4, 1				# add number of guesses made by 1
			bne $s7, $zero, guessRoutine			# keep going if whole word hasn't been revealed			

gameOver:		bgt $s5, $zero, playAgainCheck			# skip to playAgainCheck if at least one guess left
			la $a0, noGuesses 				# load noGuesses address into $a0
			li $v0, 4 					# set $v0 for a string output call
			syscall						# inform user that they ran out of guesses
			la $a0, answerString 				# load answerString address into $a0
			li $v0, 4 					# set $v0 for a string output call
			syscall						# reveal answer to player			
			la $a0, newLine 				# load guessPrompt address into $a0
			li $v0, 4 					# set $v0 for a string output call
			syscall	
			la $a0, answerString				# load answerString to $a0
			jal printWordToScreen				# print answerString to KGAS screen
playAgainCheck:		la $a0, playAgainPrompt 			# load playAgainPrompt address into $a0
			li $v0, 4 					# set $v0 for a string output call
			syscall						# ask user if they want to play again
			li $v0, 12					# create a call to read a character
			syscall						
			move $s6, $v0					# set contents of $s6 to $v0
			la $a0, newLine 				# load guessPrompt address into $a0
			li $v0, 4 					# set $v0 for a string output call
			syscall
			li $t0, 121					# load decimal representation of 'y' to $t0			
			beq $s6, $t0, resetGame				# if 'y' is inputted, loop back to start of main
			
			li $v0, 10					# close program
			syscall
		
# answerSetup: choose word from word bank and put that into answer string
answerSetup:		la $t0, wordStorage				# load address of start of word storage
			li $v0, 42					# random number generator call
			li $a0, 0					# random seed
			li $a1, 52					# store total number of words here (max exclusive bound)
			li $t4, 20					# hold number of spaces in answerString
			syscall			
answerSetup_Loop:	ble $a0, 0, answerSetup_Loop.End		# check if $a0 <= 0
			addi $a0, $a0, -1				# if not, subtract 1 from $a0
			addi $t0, $t0, 20				# move address at $t0 up by 20 bytes
			j answerSetup_Loop								
answerSetup_Loop.End:	la $t1, answerString				# load address of answerString into $t1
			li $t2, 0					# load representation of null in $t2
			li $t7, 10					# representation of \n in $t7
answerSetup_Create:	lbu $t3, 0($t0)					# load next char of random string
			beq $t3, $t2, answerSetup_Create.End		# if null, jump to createEnd
			sb $t3, 0($t1)					# store byte in $t0 to answerString
			addi $t1, $t1, 1				# increment pointer to answerString
			addi $t0, $t0, 1				# increment pointer to chosen word
			addi $t4, $t4, -1				# decrement number of spaces in answerString by 1
			j answerSetup_Create
answerSetup_Create.End:	sb $t7, 0($t1)					# add newline at end of answerString
answerSetup_Pad:	addi $t4, $t4, -1				# decrement number of spaces in answerString by 1
			ble $t4, $zero, answerSetup_Pad.End		# check if answerString has empty spaces left
			addi $t1, $t1, 1				# if not, increment pointer to answerString
			addi $t4, $t4, -1				# decrement number of spaces in answerString by 1
			sb $t2, 0($t1)					# pad unused space in answerString with null
			j answerSetup_Pad				# jump back to check if more padding needed
answerSetup_Pad.End:	jr $ra

######################################		
		
		
#
# mysteryCreate creates a segment of '*'s that match up with the answer string
#		
		
mysteryCreate:		li $t0, 42					# load decimal representation of '*' char
			li $t1, 10					# decimal representation of \n
			la $t2, answerString				# address of answerString in $s2
			la $t3, mysteryString				# address of mysteryString in $s3
			li $t5, 97					# decimal representation of 'a'
			li $t6, 122					# decimal representation of 'z'
create.Loop:		lbu $t4, 0($t2)					# load next char of answerString
			beq $t4, $t1, create.End			# if newline, jump to createEnd
			blt $t4, $t5, create.nonLetter			# branch to nonLetter if not a lowercase letter
			bgt $t4, $t6, create.nonLetter			# branch to nonLetter if not a lowercase letter
			sb $t0, 0($t3)					# store '*' in mysteryString
			addi $t2, $t2, 1				# increment pointer to answerString
			addi $t3, $t3, 1				# increment pointer to mysteryString
			j create.Loop
create.nonLetter:	sb $t4, 0($t3)					# store non-lowercase letter in mysteryString
			addi $t2, $t2, 1				# increment pointer to answerString
			addi $t3, $t3, 1				# increment pointer to mysteryString
			j create.Loop
create.End:		sb $t1, 0($t3)					# store newline representation at end
			addi $t3, $t3, 1				# increment pointer one more time
			sb $zero, 0($t3)				# store nul at end
			jr $ra						# return from subroutine	

#
# mysteryTest display current guess progress
#

mysteryTest:		la $a0, announce2 				# load annonuce2 address into $a0
			li $v0, 4 					# set $v0 for a string output call
			syscall
			la $a0, mysteryString
			li $v0, 4
			syscall						# check if mysteryString created correctly
			jr $ra						# return from subroutine

#
# rangeCheck checks if inputted character is a lowercase letter
#		
		
rangeCheck:		li $t0, 97					# decimal representation of 'a'
			li $t1, 122					# decimal representation of 'z'
			blt $s6, $t0, rangeCheck.Fail			# branch if less than decimal 'a' to failure
			ble $s6, $t1, rangeCheck.End			# branch if less than or equal to decimal 'z' to success
rangeCheck.Fail:	la $a0, invalidGuess 				# load invalidGuess address into $a0
			li $v0, 4 					# set $v0 for a string output call
			syscall
			addi $s7, $zero, 1				# mark $s7 to indicate failed range Check
rangeCheck.End:		jr $ra

#
# prevCheck checks if letter has been guessed already
#

prevGuessCheck:		add $t0, $zero, $zero				# set $t0 to zero, start of array to check
			la $t1, prevGuessArray				# load address of prevGuessArray to $t1
prevGuessCheck.Loop:	bge $t0, $s4, prevGuessCheck.End		# jump to end if going out of array bounds
			lbu $t2, 0($t1)					# load character at current array address to $t2
			beq $t2, $s6, prevGuessCheck.Mark		# branch if letter was guessed before
			addi $t0, $t0, 1				# add 1 to $t0 if array letter doesn't match up
			addi $t1, $t1, 1				# move 1 byte down previous guess array
			j prevGuessCheck.Loop				# jump back to loop check
prevGuessCheck.Mark:	la $a0, alreadyPrompt 				# load guessPrompt address into $a0
			li $v0, 4 					# set $v0 for a string output call
			syscall						# notify user letter has been guessed before
			addi $s7, $zero, 1				# mark $s7 with 1 if match found
prevGuessCheck.End:	jr $ra						# jump back from subroutine

#
# revealMystery checks the answerString for any matching characters to the guess and replaces the
# appropriate '*'s in the mystery string with it
#		
						
revealMystery:		li $t0, 42					# decimal representation of '*'
			li $t1, 10					# decimal representation of '\n'
			la $t2, answerString				# address of answerString in $t2
			la $t3, mysteryString				# address of mysteryString in $t3
			add $t6, $zero, $zero				# $t5 will signify when an uncover occurs
reveal.Check:		lbu $t4, 0($t2)					# get next char pointed by answerString
			beq $t4, $t1, reveal.WrongCheck			# branch to WrongCheck if newline reached
			beq $t4, $s6, reveal.Uncover			# uncover letter if there's a match
			lbu $t4, 0($t3)					# get next char pointed by mysteryString
			bne $t0, $t4, reveal.Advance			# simply advance if that place is not * in mysteryString
			addi $s7, $zero, 1				# mark $s7 so that it's not equal to zero if reached
			j reveal.Advance				# jump ahead to advance
reveal.Uncover:		sb $s6, 0($t3)					# change '*' in mystery string to input letter
			addi $t6, $t6, 1				# mark $t6 to indicate a letter has been uncovered
reveal.Advance:		addi $t2, $t2, 1				# advance pointer to answerString
			addi $t3, $t3, 1				# advance pointer to mysteryString
			j reveal.Check
reveal.WrongCheck:	bne $t6, $zero, reveal.GoodSound		# if letter was guessed right, jump to end
			addi $s5, $s5, -1				# decrement total number of guesses available
			
			addi $sp, $sp, -4				# store current return address on stack
			sw $ra, 0($sp)
			
			jal imageProcessor				# jump to image processor subroutine
			sb $s6, input					# store letter guessed to input
			jal printGuessToScreen				# print letter guessed to screen	
			li $a2, 14					# load instrument 14 to $a2
			jal playSound					# jump to playSound
							
			lw $ra, 0($sp)					# retrieve return address
			addi $sp, $sp, 4	

			la $a0, wrongGuess 				# load wrongGuess address into $a0
			li $v0, 4 					# set $v0 for a string output call
			syscall						# inform user that guess is wrong
			add $a0, $zero, $s5				# load number of guesses left into $a0
			li $v0, 1					# set $v0 for an integer output call
			syscall
			la $a0, newLine 				# load guessPrompt address into $a0
			li $v0, 4 					# set $v0 for a string output call
			syscall	
			j reveal.End
reveal.GoodSound:			
			addi $sp, $sp, -4				# store return address on stack
			sw $ra, 0($sp)
			li $a2, 114					# load instrument 114 to $a2
			jal playSound					# jump to playSound
			lw $ra, 0($sp)					# retrieve return address
			addi $sp, $sp, 4
reveal.End:		
			la $t5, prevGuessArray				# load address of prevGuessArray
			add $t5, $t5, $s4				# alter address to be first empty spot of array
			sb $s6, 0($t5)					# store guessed letter in array			
			jr $ra						# return from subroutine
			
#			
# prints content of input to KGAS screen	
#
	
printGuessToScreen:
			la $a0, input					# load address of input to $a0
			lb $a1, x					# pos x = 3
			lb $a2, y					# pos y = 25
			li $a3, 0xF0 					# color = white character(F), black background (0)
			li $t2, 1					# $t2 = 1 (store x pos)
			j printString			
			
			
printWordToScreen:
			lb $a1, three					# pos x = 3
			lb $a2, twentyseven				# pos y = 27
			li $a3, 0xF0 					# color = white character(F), black background (0)
			li $t2, 0					# $t2 = 0 (don't store x pos)
			j printString
					
			
printString:
			li $t1, 0xFFFF000C				# load base command
			sb $a1, 2($t1)					# substitute in $a1 for x pos
			sb $a2, 1($t1)					# substitute in $a2 for y pos
			sb $a3, ($t1)					# substitute in $a3 for color
printString.Loop:
			lb $t0, ($a0)					# load first character to $a0
			beqz $t0, printString.Save			# exit loop if empty
			sb $t0, 3($t1)					# otherwise substitute character into base command
			addi $a0, $a0, 1				# increment $a0 1
			addi $a1, $a1, 2				# increment x by 2
			sb $a1, 2($t1)					# store x in base command
			j printString.Loop				# loop through next character in input

printString.Save:
			beqz $t2, printString.Return			# if inputting a char guess, save x pos
			sb $a1, x					# store x pos
printString.Return:
			jr $ra						# return to caller
			
#
# clear KGAS screen and reset position coordinates
#					
						
resetGame:			
			la $a0, resetString				# load empty string to $a0
			jal printWordToScreen				# clear answerString from KGAS screen
			
			la $a0, resetString				# clears guesses from screen
			lb $a1, three					# pos x = 3
			lb $a2, y					# pos y = 25
			li $a3, 0xF0 					# color = white character(F), black background (0)
			li $t2, 0					# $t2 = 0 (don't store x pos)
			jal printString
			
			li $t0, 0x00					# load color (black) for KGAS to clear screen
			jal head					# clear head
			jal body					# clear body
			jal leftArm					# clear left arm
			jal rightArm					# clear right arm
			jal leftLeg					# clear left leg
			jal rightLeg					# clear right leg
			
			lb $t0, x					# reset x to 3
			li $t0, 3			
			sb $t0, x	
			
			j main						# jump to main for new game
#			
# draws gallows
#

gallows:
			li $t0, 0x06					# color: black with brown background
			sb $t0, 0xffff000c				# store in Attribute Register
			li $t0, 0x03					# y position
			sb $t0, 0xffff000d				# store in Verticle Position Register
			li $t0, 0x15					# x position
			sb $t0, 0xffff000e				# store in Horizontal Position
			li $t0, '|'					# character to display: '|'
			sb $t0, 0xffff000f				# store character
			li $t0, 0x16
			sb $t0, 0xffff000e
			li $t0, '|'
			sb $t0, 0xffff000f
			li $t0, 0x17
			sb $t0, 0xffff000e
			li $t0, '|'
			sb $t0, 0xffff000f
			li $t0, 0x18
			sb $t0, 0xffff000e
			li $t0, '|'
			sb $t0, 0xffff000f
			li $t0, 0x19
			sb $t0, 0xffff000e
			li $t0, '|'
			sb $t0, 0xffff000f
			li $t0, 0x1a
			sb $t0, 0xffff000e
			li $t0, '|'
			sb $t0, 0xffff000f
			li $t0, 0x1b
			sb $t0, 0xffff000e
			li $t0, '|'
			sb $t0, 0xffff000f
			li $t0, 0x1c
			sb $t0, 0xffff000e
			li $t0, '|'
			sb $t0, 0xffff000f
			li $t0, 0x1d
			sb $t0, 0xffff000e
			li $t0, '|'
			sb $t0, 0xffff000f
			li $t0, 0x1e
			sb $t0, 0xffff000e
			li $t0, '|'
			sb $t0, 0xffff000f
			li $t0, 0x1f
			sb $t0, 0xffff000e
			li $t0, '|'
			sb $t0, 0xffff000f
			li $t0, 0x20
			sb $t0, 0xffff000e
			li $t0, '|'
			sb $t0, 0xffff000f
			li $t0, 0x21
			sb $t0, 0xffff000e
			li $t0, '|'
			sb $t0, 0xffff000f
			li $t0, 0x22
			sb $t0, 0xffff000e
			li $t0, '|'
			sb $t0, 0xffff000f
			li $t0, 0x23
			sb $t0, 0xffff000e
			li $t0, '|'
			sb $t0, 0xffff000f
			li $t0, 0x24
			sb $t0, 0xffff000e
			li $t0, '|'
			sb $t0, 0xffff000f
			li $t0, 0x25
			sb $t0, 0xffff000e
			li $t0, '|'
			sb $t0, 0xffff000f
			li $t0, 0x26
			sb $t0, 0xffff000e
			li $t0, '|'
			sb $t0, 0xffff000f
			li $t0, 0x04		
			sb $t0, 0xffff000d	
			li $t0, 0x26
			sb $t0, 0xffff000e	
			li $t0, '|'		
			sb $t0, 0xffff000f
			li $t0, 0x05		
			sb $t0, 0xffff000d	
			li $t0, 0x26
			sb $t0, 0xffff000e	
			li $t0, '|'		
			sb $t0, 0xffff000f
			li $t0, 0x04		
			sb $t0, 0xffff000d	
			li $t0, 0x15
			sb $t0, 0xffff000e	
			li $t0, '|'		
			sb $t0, 0xffff000f
			li $t0, 0x05		
			sb $t0, 0xffff000d	
			li $t0, 0x15
			sb $t0, 0xffff000e	
			li $t0, '|'		
			sb $t0, 0xffff000f
			li $t0, 0x06		
			sb $t0, 0xffff000d	
			li $t0, 0x15
			sb $t0, 0xffff000e	
			li $t0, '|'		
			sb $t0, 0xffff000f
			li $t0, 0x07		
			sb $t0, 0xffff000d	
			li $t0, 0x15
			sb $t0, 0xffff000e	
			li $t0, '|'		
			sb $t0, 0xffff000f
			li $t0, 0x08		
			sb $t0, 0xffff000d	
			li $t0, 0x15
			sb $t0, 0xffff000e	
			li $t0, '|'		
			sb $t0, 0xffff000f
			li $t0, 0x09		
			sb $t0, 0xffff000d	
			li $t0, 0x15
			sb $t0, 0xffff000e	
			li $t0, '|'		
			sb $t0, 0xffff000f			
			li $t0, 0x0a		
			sb $t0, 0xffff000d	
			li $t0, 0x15
			sb $t0, 0xffff000e	
			li $t0, '|'		
			sb $t0, 0xffff000f
			li $t0, 0x0b		
			sb $t0, 0xffff000d	
			li $t0, 0x15
			sb $t0, 0xffff000e	
			li $t0, '|'		
			sb $t0, 0xffff000f
			li $t0, 0x0c		
			sb $t0, 0xffff000d	
			li $t0, 0x15
			sb $t0, 0xffff000e	
			li $t0, '|'		
			sb $t0, 0xffff000f
			li $t0, 0x0d		
			sb $t0, 0xffff000d	
			li $t0, 0x15
			sb $t0, 0xffff000e	
			li $t0, '|'		
			sb $t0, 0xffff000f
			li $t0, 0x0e		
			sb $t0, 0xffff000d	
			li $t0, 0x15
			sb $t0, 0xffff000e	
			li $t0, '|'		
			sb $t0, 0xffff000f
			li $t0, 0x0f		
			sb $t0, 0xffff000d	
			li $t0, 0x15
			sb $t0, 0xffff000e	
			li $t0, '|'		
			sb $t0, 0xffff000f
			li $t0, 0x10		
			sb $t0, 0xffff000d	
			li $t0, 0x15
			sb $t0, 0xffff000e	
			li $t0, '|'		
			sb $t0, 0xffff000f			
			li $t0, 0x11		
			sb $t0, 0xffff000d	
			li $t0, 0x15
			sb $t0, 0xffff000e	
			li $t0, '|'		
			sb $t0, 0xffff000f
			li $t0, 0x12		
			sb $t0, 0xffff000d	
			li $t0, 0x15
			sb $t0, 0xffff000e	
			li $t0, '|'		
			sb $t0, 0xffff000f
			li $t0, 0x13		
			sb $t0, 0xffff000d	
			li $t0, 0x15
			sb $t0, 0xffff000e	
			li $t0, '|'		
			sb $t0, 0xffff000f
			li $t0, 0x14		
			sb $t0, 0xffff000d	
			li $t0, 0x15
			sb $t0, 0xffff000e	
			li $t0, '|'		
			sb $t0, 0xffff000f
			li $t0, 0x15		
			sb $t0, 0xffff000d	
			li $t0, 0x15
			sb $t0, 0xffff000e	
			li $t0, '|'		
			sb $t0, 0xffff000f
			li $t0, 0x15		
			sb $t0, 0xffff000d	
			li $t0, 0x14
			sb $t0, 0xffff000e	
			li $t0, '|'		
			sb $t0, 0xffff000f
			li $t0, 0x15		
			sb $t0, 0xffff000d	
			li $t0, 0x13
			sb $t0, 0xffff000e	
			li $t0, '|'		
			sb $t0, 0xffff000f
			li $t0, 0x15		
			sb $t0, 0xffff000d	
			li $t0, 0x12
			sb $t0, 0xffff000e	
			li $t0, '|'		
			sb $t0, 0xffff000f
			li $t0, 0x15		
			sb $t0, 0xffff000d	
			li $t0, 0x11
			sb $t0, 0xffff000e	
			li $t0, '|'		
			sb $t0, 0xffff000f
			li $t0, 0x15		
			sb $t0, 0xffff000d	
			li $t0, 0x10
			sb $t0, 0xffff000e	
			li $t0, '|'		
			sb $t0, 0xffff000f
			li $t0, 0x15		
			sb $t0, 0xffff000d	
			li $t0, 0x16
			sb $t0, 0xffff000e	
			li $t0, '|'		
			sb $t0, 0xffff000f
			li $t0, 0x15		
			sb $t0, 0xffff000d	
			li $t0, 0x17
			sb $t0, 0xffff000e	
			li $t0, '|'		
			sb $t0, 0xffff000f
			li $t0, 0x15		
			sb $t0, 0xffff000d	
			li $t0, 0x18
			sb $t0, 0xffff000e	
			li $t0, '|'		
			sb $t0, 0xffff000f
			li $t0, 0x15		
			sb $t0, 0xffff000d	
			li $t0, 0x19
			sb $t0, 0xffff000e	
			li $t0, '|'		
			sb $t0, 0xffff000f
			li $t0, 0x15		
			sb $t0, 0xffff000d	
			li $t0, 0x1a
			sb $t0, 0xffff000e	
			li $t0, '|'		
			sb $t0, 0xffff000f
			li $t0, 0x15		
			sb $t0, 0xffff000d	
			li $t0, 0x1b
			sb $t0, 0xffff000e	
			li $t0, '|'		
			sb $t0, 0xffff000f
			li $t0, 0x15		
			sb $t0, 0xffff000d	
			li $t0, 0x1c
			sb $t0, 0xffff000e	
			li $t0, '|'		
			sb $t0, 0xffff000f
			li $t0, 0x15		
			sb $t0, 0xffff000d	
			li $t0, 0x1d
			sb $t0, 0xffff000e	
			li $t0, '|'		
			sb $t0, 0xffff000f
			li $t0, 0x15		
			sb $t0, 0xffff000d	
			li $t0, 0x1e
			sb $t0, 0xffff000e	
			li $t0, '|'		
			sb $t0, 0xffff000f
			li $t0, 0x15		
			sb $t0, 0xffff000d	
			li $t0, 0x1f
			sb $t0, 0xffff000e	
			li $t0, '|'		
			sb $t0, 0xffff000f
			li $t0, 0x15		
			sb $t0, 0xffff000d	
			li $t0, 0x1f
			sb $t0, 0xffff000e	
			li $t0, '|'		
			sb $t0, 0xffff000f
			li $t0, 0x15		
			sb $t0, 0xffff000d	
			li $t0, 0x20
			sb $t0, 0xffff000e	
			li $t0, '|'		
			sb $t0, 0xffff000f
			li $t0, 0x15		
			sb $t0, 0xffff000d	
			li $t0, 0x21
			sb $t0, 0xffff000e	
			li $t0, '|'		
			sb $t0, 0xffff000f
			li $t0, 0x15		
			sb $t0, 0xffff000d	
			li $t0, 0x22
			sb $t0, 0xffff000e	
			li $t0, '|'		
			sb $t0, 0xffff000f			
			li $t0, 0x15		
			sb $t0, 0xffff000d	
			li $t0, 0x23
			sb $t0, 0xffff000e	
			li $t0, '|'		
			sb $t0, 0xffff000f
			li $t0, 0x15		
			sb $t0, 0xffff000d	
			li $t0, 0x24
			sb $t0, 0xffff000e	
			li $t0, '|'		
			sb $t0, 0xffff000f
			li $t0, 0x15		
			sb $t0, 0xffff000d	
			li $t0, 0x25
			sb $t0, 0xffff000e	
			li $t0, '|'		
			sb $t0, 0xffff000f
			li $t0, 0x15		
			sb $t0, 0xffff000d	
			li $t0, 0x26
			sb $t0, 0xffff000e	
			li $t0, '|'		
			sb $t0, 0xffff000f
			li $t0, 0x15		
			sb $t0, 0xffff000d	
			li $t0, 0x27
			sb $t0, 0xffff000e	
			li $t0, '|'		
			sb $t0, 0xffff000f
			li $t0, 0x15		
			sb $t0, 0xffff000d	
			li $t0, 0x28
			sb $t0, 0xffff000e	
			li $t0, '|'		
			sb $t0, 0xffff000f
			li $t0, 0x15		
			sb $t0, 0xffff000d	
			li $t0, 0x29
			sb $t0, 0xffff000e	
			li $t0, '|'		
			sb $t0, 0xffff000f
			li $t0, 0x15		
			sb $t0, 0xffff000d	
			li $t0, 0x2a
			sb $t0, 0xffff000e	
			li $t0, '|'		
			sb $t0, 0xffff000f
			li $t0, 0x15		
			sb $t0, 0xffff000d	
			li $t0, 0x2b
			sb $t0, 0xffff000e	
			li $t0, '|'		
			sb $t0, 0xffff000f
			li $t0, 0x15		
			sb $t0, 0xffff000d	
			li $t0, 0x2c
			sb $t0, 0xffff000e	
			li $t0, '|'		
			sb $t0, 0xffff000f
			li $t0, 0x15		
			sb $t0, 0xffff000d	
			li $t0, 0x2d
			sb $t0, 0xffff000e	
			li $t0, '|'		
			sb $t0, 0xffff000f
			li $t0, 0x15		
			sb $t0, 0xffff000d	
			li $t0, 0x2e
			sb $t0, 0xffff000e	
			li $t0, '|'		
			sb $t0, 0xffff000f
			li $t0, 0x15		
			sb $t0, 0xffff000d	
			li $t0, 0x2f
			sb $t0, 0xffff000e	
			li $t0, '|'		
			sb $t0, 0xffff000f
			li $t0, 0x15		
			sb $t0, 0xffff000d	
			li $t0, 0x30
			sb $t0, 0xffff000e	
			li $t0, '|'		
			sb $t0, 0xffff000f
			li $t0, 0x15		
			sb $t0, 0xffff000d	
			li $t0, 0x31
			sb $t0, 0xffff000e	
			li $t0, '|'		
			sb $t0, 0xffff000f
			li $t0, 0x15		
			sb $t0, 0xffff000d	
			li $t0, 0x32
			sb $t0, 0xffff000e	
			li $t0, '|'		
			sb $t0, 0xffff000f
			li $t0, 0x15		
			sb $t0, 0xffff000d	
			li $t0, 0x33
			sb $t0, 0xffff000e	
			li $t0, '|'		
			sb $t0, 0xffff000f
			li $t0, 0x15		
			sb $t0, 0xffff000d	
			li $t0, 0x34
			sb $t0, 0xffff000e	
			li $t0, '|'		
			sb $t0, 0xffff000f
			li $t0, 0x15		
			sb $t0, 0xffff000d	
			li $t0, 0x35
			sb $t0, 0xffff000e	
			li $t0, '|'		
			sb $t0, 0xffff000f
			li $t0, 0x03		
			sb $t0, 0xffff000d	
			li $t0, 0x14
			sb $t0, 0xffff000e	
			li $t0, '|'		
			sb $t0, 0xffff000f
			li $t0, 0x04		
			sb $t0, 0xffff000d	
			li $t0, 0x14
			sb $t0, 0xffff000e	
			li $t0, '|'		
			sb $t0, 0xffff000f
			li $t0, 0x05		
			sb $t0, 0xffff000d	
			li $t0, 0x14
			sb $t0, 0xffff000e	
			li $t0, '|'		
			sb $t0, 0xffff000f
			li $t0, 0x06		
			sb $t0, 0xffff000d	
			li $t0, 0x14
			sb $t0, 0xffff000e	
			li $t0, '|'		
			sb $t0, 0xffff000f
			li $t0, 0x07		
			sb $t0, 0xffff000d	
			li $t0, 0x14
			sb $t0, 0xffff000e	
			li $t0, '|'		
			sb $t0, 0xffff000f
			li $t0, 0x08		
			sb $t0, 0xffff000d	
			li $t0, 0x14
			sb $t0, 0xffff000e	
			li $t0, '|'		
			sb $t0, 0xffff000f
			li $t0, 0x09		
			sb $t0, 0xffff000d	
			li $t0, 0x14
			sb $t0, 0xffff000e	
			li $t0, '|'		
			sb $t0, 0xffff000f
			li $t0, 0x0a		
			sb $t0, 0xffff000d	
			li $t0, 0x14
			sb $t0, 0xffff000e	
			li $t0, '|'		
			sb $t0, 0xffff000f
			li $t0, 0x0b		
			sb $t0, 0xffff000d	
			li $t0, 0x14
			sb $t0, 0xffff000e	
			li $t0, '|'		
			sb $t0, 0xffff000f
			li $t0, 0x0c		
			sb $t0, 0xffff000d	
			li $t0, 0x14
			sb $t0, 0xffff000e	
			li $t0, '|'		
			sb $t0, 0xffff000f
			li $t0, 0x0d		
			sb $t0, 0xffff000d	
			li $t0, 0x14
			sb $t0, 0xffff000e	
			li $t0, '|'		
			sb $t0, 0xffff000f
			li $t0, 0x0e		
			sb $t0, 0xffff000d	
			li $t0, 0x14
			sb $t0, 0xffff000e	
			li $t0, '|'		
			sb $t0, 0xffff000f
			li $t0, 0x0f		
			sb $t0, 0xffff000d	
			li $t0, 0x14
			sb $t0, 0xffff000e	
			li $t0, '|'		
			sb $t0, 0xffff000f
			li $t0, 0x10		
			sb $t0, 0xffff000d	
			li $t0, 0x14
			sb $t0, 0xffff000e	
			li $t0, '|'		
			sb $t0, 0xffff000f
			li $t0, 0x11		
			sb $t0, 0xffff000d	
			li $t0, 0x14
			sb $t0, 0xffff000e	
			li $t0, '|'		
			sb $t0, 0xffff000f
			li $t0, 0x12		
			sb $t0, 0xffff000d	
			li $t0, 0x14
			sb $t0, 0xffff000e	
			li $t0, '|'		
			sb $t0, 0xffff000f
			li $t0, 0x13		
			sb $t0, 0xffff000d	
			li $t0, 0x14
			sb $t0, 0xffff000e	
			li $t0, '|'		
			sb $t0, 0xffff000f
			li $t0, 0x14		
			sb $t0, 0xffff000d	
			li $t0, 0x14
			sb $t0, 0xffff000e	
			li $t0, '|'		
			sb $t0, 0xffff000f							
			
			jr $ra
#
# branches to the proper section to draw hangman based on the number of guesses left 
#
			
imageProcessor:

			li $t0, 0x0e				#load color: black with yellow background
			beq $s5, 6, head
			beq $s5, 5, body
			beq $s5, 4, leftArm
			beq $s5, 3, rightArm
			beq $s5, 2, leftLeg
			beq $s5, 1, rightLeg
			beq $s5, 0, yourDead			
#			
# draws head	
#
		
head:			
			sb $t0, 0xffff000c				# store in Attribute Register
			li $t0, 0x05					# y position
			sb $t0, 0xffff000d				# store in Verticle Position Register
			li $t0, 0x24					# x position
			sb $t0, 0xffff000e				# store in Horizontal Position
			li $t0, ' '					# character to display: ' '
			sb $t0, 0xffff000f				# store character
			li $t0, 0x05		
			sb $t0, 0xffff000d	
			li $t0, 0x25
			sb $t0, 0xffff000e	
			li $t0, ' '		
			sb $t0, 0xffff000f
			li $t0, 0x05		
			sb $t0, 0xffff000d	
			li $t0, 0x26
			sb $t0, 0xffff000e	
			li $t0, ' '		
			sb $t0, 0xffff000f
			li $t0, 0x05		
			sb $t0, 0xffff000d	
			li $t0, 0x27
			sb $t0, 0xffff000e	
			li $t0, ' '		
			sb $t0, 0xffff000f
			li $t0, 0x05		
			sb $t0, 0xffff000d	
			li $t0, 0x28
			sb $t0, 0xffff000e	
			li $t0, ' '		
			sb $t0, 0xffff000f
			li $t0, 0x06		
			sb $t0, 0xffff000d	
			li $t0, 0x23
			sb $t0, 0xffff000e	
			li $t0, ' '		
			sb $t0, 0xffff000f
			li $t0, 0x06		
			sb $t0, 0xffff000d	
			li $t0, 0x24
			sb $t0, 0xffff000e	
			li $t0, ' '		
			sb $t0, 0xffff000f
			li $t0, 0x06		
			sb $t0, 0xffff000d	
			li $t0, 0x25
			sb $t0, 0xffff000e	
			li $t0, 'O'		
			sb $t0, 0xffff000f
			li $t0, 0x06		
			sb $t0, 0xffff000d	
			li $t0, 0x26
			sb $t0, 0xffff000e	
			li $t0, ' '		
			sb $t0, 0xffff000f
			li $t0, 0x06		
			sb $t0, 0xffff000d	
			li $t0, 0x27
			sb $t0, 0xffff000e	
			li $t0, 'O'		
			sb $t0, 0xffff000f
			li $t0, 0x06		
			sb $t0, 0xffff000d	
			li $t0, 0x28
			sb $t0, 0xffff000e	
			li $t0, ' '		
			sb $t0, 0xffff000f
			li $t0, 0x06		
			sb $t0, 0xffff000d	
			li $t0, 0x29
			sb $t0, 0xffff000e	
			li $t0, ' '		
			sb $t0, 0xffff000f
			li $t0, 0x07		
			sb $t0, 0xffff000d	
			li $t0, 0x23
			sb $t0, 0xffff000e	
			li $t0, ' '		
			sb $t0, 0xffff000f
			li $t0, 0x07		
			sb $t0, 0xffff000d	
			li $t0, 0x24
			sb $t0, 0xffff000e	
			li $t0, ' '		
			sb $t0, 0xffff000f
			li $t0, 0x07		
			sb $t0, 0xffff000d	
			li $t0, 0x25
			sb $t0, 0xffff000e	
			li $t0, ' '		
			sb $t0, 0xffff000f
			li $t0, 0x07		
			sb $t0, 0xffff000d	
			li $t0, 0x26
			sb $t0, 0xffff000e	
			li $t0, 'V'		
			sb $t0, 0xffff000f
			li $t0, 0x07		
			sb $t0, 0xffff000d	
			li $t0, 0x27
			sb $t0, 0xffff000e	
			li $t0, ' '		
			sb $t0, 0xffff000f
			li $t0, 0x07		
			sb $t0, 0xffff000d	
			li $t0, 0x28
			sb $t0, 0xffff000e	
			li $t0, ' '		
			sb $t0, 0xffff000f
			li $t0, 0x07		
			sb $t0, 0xffff000d	
			li $t0, 0x29
			sb $t0, 0xffff000e	
			li $t0, ' '		
			sb $t0, 0xffff000f
			li $t0, 0x08		
			sb $t0, 0xffff000d	
			li $t0, 0x24
			sb $t0, 0xffff000e	
			li $t0, ' '		
			sb $t0, 0xffff000f
			li $t0, 0x08		
			sb $t0, 0xffff000d	
			li $t0, 0x25
			sb $t0, 0xffff000e	
			li $t0, '-'		
			sb $t0, 0xffff000f
			li $t0, 0x08		
			sb $t0, 0xffff000d	
			li $t0, 0x26
			sb $t0, 0xffff000e	
			li $t0, '-'		
			sb $t0, 0xffff000f
			li $t0, 0x08		
			sb $t0, 0xffff000d	
			li $t0, 0x27
			sb $t0, 0xffff000e	
			li $t0, '-'		
			sb $t0, 0xffff000f
			li $t0, 0x08		
			sb $t0, 0xffff000d	
			li $t0, 0x28
			sb $t0, 0xffff000e	
			li $t0, ' '		
			sb $t0, 0xffff000f			
			
			jr $ra
			
#			
# draws body
#

body:
			#li $t0, 0x0e					# color: black with yellow background
			sb $t0, 0xffff000c				# store in Attribute Register
			li $t0, 0x09					# y position
			sb $t0, 0xffff000d				# store in Verticle Position Register
			li $t0, 0x26					# x position
			sb $t0, 0xffff000e				# store in Horizontal Position
			li $t0, ' '					# character to display: '/'
			sb $t0, 0xffff000f				# store character
			li $t0, 0x0a		
			sb $t0, 0xffff000d	
			li $t0, ' '		
			sb $t0, 0xffff000f
			li $t0, 0x0b		
			sb $t0, 0xffff000d	
			li $t0, ' '		
			sb $t0, 0xffff000f
			li $t0, 0x0b		
			sb $t0, 0xffff000d	
			li $t0, ' '		
			sb $t0, 0xffff000f
			li $t0, 0x0c		
			sb $t0, 0xffff000d			
			li $t0, ' '		
			sb $t0, 0xffff000f
			li $t0, 0x0d		
			sb $t0, 0xffff000d	
			li $t0, ' '		
			sb $t0, 0xffff000f
			li $t0, 0x0e		
			sb $t0, 0xffff000d	
			li $t0, ' '		
			sb $t0, 0xffff000f
			li $t0, 0x0f
			sb $t0, 0xffff000d
			li $t0, ' '	
			sb $t0, 0xffff000f
			li $t0, 0x10
			sb $t0, 0xffff000d
			li $t0, ' '		
			sb $t0, 0xffff000f
			
			jr $ra
			
#
# draws right arm
#
rightArm:
			#li $t0, 0x0e					# color: black with yellow background
			sb $t0, 0xffff000c				# store in Attribute Register
			li $t0, 0x0a		
			sb $t0, 0xffff000d	
			li $t0, 0x27
			sb $t0, 0xffff000e	
			li $t0, ' '		
			sb $t0, 0xffff000f
			li $t0, 0x0a		
			sb $t0, 0xffff000d	
			li $t0, 0x28
			sb $t0, 0xffff000e	
			li $t0, ' '		
			sb $t0, 0xffff000f
			li $t0, 0x0b		
			sb $t0, 0xffff000d	
			li $t0, 0x28
			sb $t0, 0xffff000e	
			li $t0, ' '		
			sb $t0, 0xffff000f
			li $t0, 0x0b		
			sb $t0, 0xffff000d	
			li $t0, 0x29
			sb $t0, 0xffff000e	
			li $t0, ' '		
			sb $t0, 0xffff000f
			li $t0, 0x0c		
			sb $t0, 0xffff000d	
			li $t0, 0x29
			sb $t0, 0xffff000e	
			li $t0, ' '		
			sb $t0, 0xffff000f
			li $t0, 0x0c		
			sb $t0, 0xffff000d	
			li $t0, 0x2a
			sb $t0, 0xffff000e	
			li $t0, ' '		
			sb $t0, 0xffff000f
			li $t0, 0x0d		
			sb $t0, 0xffff000d	
			li $t0, 0x2a
			sb $t0, 0xffff000e	
			li $t0, ' '		
			sb $t0, 0xffff000f
			li $t0, 0x0d		
			sb $t0, 0xffff000d	
			li $t0, 0x2b
			sb $t0, 0xffff000e	
			li $t0, ' '		
			sb $t0, 0xffff000f
			
			jr $ra
			
#
# draws left arm
#

leftArm:
			#li $t0, 0x0e					# color: black with yellow background
			sb $t0, 0xffff000c				# store in Attribute Register
			li $t0, 0x0a		
			sb $t0, 0xffff000d	
			li $t0, 0x25
			sb $t0, 0xffff000e	
			li $t0, ' '		
			sb $t0, 0xffff000f
			li $t0, 0x0a		
			sb $t0, 0xffff000d	
			li $t0, 0x24
			sb $t0, 0xffff000e	
			li $t0, ' '		
			sb $t0, 0xffff000f
			li $t0, 0x0b		
			sb $t0, 0xffff000d	
			li $t0, 0x24
			sb $t0, 0xffff000e	
			li $t0, ' '		
			sb $t0, 0xffff000f
			li $t0, 0x0b		
			sb $t0, 0xffff000d	
			li $t0, 0x23
			sb $t0, 0xffff000e	
			li $t0, ' '		
			sb $t0, 0xffff000f
			li $t0, 0x0c		
			sb $t0, 0xffff000d	
			li $t0, 0x23
			sb $t0, 0xffff000e	
			li $t0, ' '		
			sb $t0, 0xffff000f
			li $t0, 0x0c		
			sb $t0, 0xffff000d	
			li $t0, 0x22
			sb $t0, 0xffff000e	
			li $t0, ' '		
			sb $t0, 0xffff000f
			li $t0, 0x0d		
			sb $t0, 0xffff000d	
			li $t0, 0x22
			sb $t0, 0xffff000e	
			li $t0, ' '		
			sb $t0, 0xffff000f
			li $t0, 0x0d		
			sb $t0, 0xffff000d	
			li $t0, 0x21
			sb $t0, 0xffff000e	
			li $t0, ' '		
			sb $t0, 0xffff000f
			
			jr $ra
			
#			
# draws left leg
#

leftLeg:
			#li $t0, 0x0e					# color: black with yellow background
			sb $t0, 0xffff000c				# store in Attribute Register
			li $t0, 0x10		
			sb $t0, 0xffff000d	
			li $t0, 0x25
			sb $t0, 0xffff000e	
			li $t0, ' '		
			sb $t0, 0xffff000f
			li $t0, 0x10		
			sb $t0, 0xffff000d	
			li $t0, 0x24
			sb $t0, 0xffff000e	
			li $t0, ' '		
			sb $t0, 0xffff000f
			li $t0, 0x11		
			sb $t0, 0xffff000d	
			li $t0, 0x24
			sb $t0, 0xffff000e	
			li $t0, ' '		
			sb $t0, 0xffff000f
			li $t0, 0x11		
			sb $t0, 0xffff000d	
			li $t0, 0x23
			sb $t0, 0xffff000e	
			li $t0, ' '		
			sb $t0, 0xffff000f
			li $t0, 0x12		
			sb $t0, 0xffff000d	
			li $t0, 0x23
			sb $t0, 0xffff000e	
			li $t0, ' '		
			sb $t0, 0xffff000f
			li $t0, 0x12		
			sb $t0, 0xffff000d	
			li $t0, 0x22
			sb $t0, 0xffff000e	
			li $t0, ' '		
			sb $t0, 0xffff000f
			li $t0, 0x13		
			sb $t0, 0xffff000d	
			li $t0, 0x22
			sb $t0, 0xffff000e	
			li $t0, ' '		
			sb $t0, 0xffff000f
			li $t0, 0x13		
			sb $t0, 0xffff000d	
			li $t0, 0x21
			sb $t0, 0xffff000e	
			li $t0, ' '		
			sb $t0, 0xffff000f
			li $t0, 0x13		
			sb $t0, 0xffff000d	
			li $t0, 0x20
			sb $t0, 0xffff000e	
			li $t0, ' '		
			sb $t0, 0xffff000f
			
			jr $ra
			
#
# draws right leg
#

rightLeg:
			#li $t0, 0x0e					# color: black with yellow background
			sb $t0, 0xffff000c				# store in Attribute Register
			li $t0, 0x10		
			sb $t0, 0xffff000d	
			li $t0, 0x27
			sb $t0, 0xffff000e	
			li $t0, ' '		
			sb $t0, 0xffff000f
			li $t0, 0x10		
			sb $t0, 0xffff000d	
			li $t0, 0x28
			sb $t0, 0xffff000e	
			li $t0, ' '		
			sb $t0, 0xffff000f
			li $t0, 0x11		
			sb $t0, 0xffff000d	
			li $t0, 0x28
			sb $t0, 0xffff000e	
			li $t0, ' '		
			sb $t0, 0xffff000f
			li $t0, 0x11		
			sb $t0, 0xffff000d	
			li $t0, 0x29
			sb $t0, 0xffff000e	
			li $t0, ' '		
			sb $t0, 0xffff000f
			li $t0, 0x12		
			sb $t0, 0xffff000d	
			li $t0, 0x29
			sb $t0, 0xffff000e	
			li $t0, ' '		
			sb $t0, 0xffff000f
			li $t0, 0x12		
			sb $t0, 0xffff000d	
			li $t0, 0x2a
			sb $t0, 0xffff000e	
			li $t0, ' '		
			sb $t0, 0xffff000f
			li $t0, 0x13		
			sb $t0, 0xffff000d	
			li $t0, 0x2a
			sb $t0, 0xffff000e	
			li $t0, ' '		
			sb $t0, 0xffff000f
			li $t0, 0x13		
			sb $t0, 0xffff000d	
			li $t0, 0x2b
			sb $t0, 0xffff000e	
			li $t0, ' '		
			sb $t0, 0xffff000f
			li $t0, 0x13		
			sb $t0, 0xffff000d	
			li $t0, 0x2c
			sb $t0, 0xffff000e	
			li $t0, ' '		
			sb $t0, 0xffff000f
			
			jr $ra
			
#			
# makes eyes X		
#
		
yourDead:
			#li $t0, 0x0e					# color: black with yellow background
			sb $t0, 0xffff000c				# store in Attribute Register
			li $t0, 0x06		
			sb $t0, 0xffff000d	
			li $t0, 0x25
			sb $t0, 0xffff000e	
			li $t0, 'X'		
			sb $t0, 0xffff000f
			li $t0, 0x27
			sb $t0, 0xffff000e	
			li $t0, 'X'		
			sb $t0, 0xffff000f
			
			jr $ra
			
#
# takes instrument input and plays "good" or "bad" sound
#			
			
playSound:
			li $a0, 62			# pitch 
  			li $a1, 500  			# half second, duration in ms
  			#move $a2, $t2			# instrument. 114 is good, 14 is bad
  			li $a3, 120			# volume
 			la $v0, 33			
  			syscall
  
  			jr $ra
