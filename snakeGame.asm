##### SANDY SOlAQA
##### 825945946
##### SNAKE GAME
##### KEN ARNOLD

.data
	mainMenu:      .asciiz "\n=========================\nPlease select an option\n=========================\n0 - play\n1 - rules\n2 - quit\n=========================\nyour option: "
	mainOption:    .space 2
	rules:         .asciiz "\n=========================\nEat apples (*) to increase your score.\nPress 'a' to turn counter-clockwise, and press 'd' to turn clockwise.\nYou can circulate through boundaries.\n"
	scoreLabel:    .asciiz "Score: "
	separator:     .asciiz "\n=========================\n"
	playOption:    .asciiz "0"
	rulesOption:   .asciiz "1"
	exitOption:    .asciiz "2"
	emptyField:    .asciiz " "
	snakeField:    .asciiz "o"
	appleField:    .asciiz "*"
	boundaryField: .asciiz "#"
	newLine:       .asciiz "\n"
	H:             .word 20 
	W:             .word 20
	field:         .space 400  # array
	snake:         .space 1600 # array
	tail:          .space 4
	snakeSize:     .word 1
	
	score:         .word 0
	direction:     .word 0
	apple:         .word 0
	oldApple:      .word 0
	
	pitch: 	       .byte 51 
    	duration:      .byte 100
    	piano: 	       .byte 58
    	volume:        .byte 100


.text
.globl main

main:					# main function
	jal	printMain		# print main menu
	jal	getMain			# get main menu option from user

	la	$t1,mainOption		# load option entered by user
	la	$t2,rulesOption		# load rules option
	lbu	$t1,0($t1)      	# read the first character of mainOption
	lbu	$t2,0($t2)      	# read the first character of mainOption
	beq	$t1,$t2,printRules	# check if user option is the same as rules option
	la	$t2,exitOption		# load exit option
	lbu	$t2,0($t2)		# read the first character of mainOption
	beq	$t1,$t2,exit		# exit if the user input equals the exit option
	la	$t2,playOption		# load play option
	lbu	$t2,0($t2)		# read the first character
	beq	$t1,$t2,initializeField	# start game if user imput equals the play option
	j	main			# jump to main if the user input doesn't match any of the available options

printMain:
	li $v0, 31 
   	la $t0, pitch			# tone
   	la $t1, duration                # time
    	la $t2, piano			# musical type
    	la $t3, volume 			# controls volume 
    	move $a0, $t0 
    	move $a1, $t1 
    	move $a2, $t2
    	move $a3, $t3 
    	syscall
    	
	li      $v0,4       		# code to print string
	la      $a0,mainMenu    	# load main menu string
	syscall             		# print 
	jr	$ra			# return to the calling location

getMain:
	lw 	$t0,0xFFFF0004		# read input from the simulated keyboard
	beq	$t0,$zero,getMain	# retake the input if the input is empty
	sw	$zero,0xFFFF0004	# else reset the simulated keyboard
	sb	$t0,mainOption		# write the input to mainOption label
	jr	$ra			# return to the calling location

printRules:
	li      $v0,4       		# code to print string
	la      $a0,rules   		# load the rules string
	syscall				# print 
	j	main	    		# jump to the main function

exit:
	li	$v0, 10  		# termination code
	syscall				# terminate

snakeSession:				# print field
	li	$t4, 22			# width including the boundaries
	li	$t0, 484		# total size of field including the boundaries, upper boundary of loop
	li	$t1, 0			# loop counter
	la	$t5, field		# load the field array
	li	$t7,-1			# position of the current empty field
	li      $v0,4			# code to print string
	la      $a0,separator		# load the separator string
	syscall				# print separator
	la      $a0,scoreLabel  	# load the score label
	syscall				# print score label
	lw 	$a0, score		# load score
	li 	$v0,1			# code to print integer
	syscall				# print score
	li      $v0,4			# code to print string
	la      $a0,separator		# load separator string
	lw	$t6,apple		# load apple character
	syscall				# print separator
loop:
	beq	$t1, $t0, end 		# if t1 == t0 end loop
	remu	$t3,$t1,$t4		# current field index % field width
	beq	$t3,0,printBoundary	# if index is at the first index of row, print boundary
	beq	$t3,21,printBoundary	# if index is at the last index of row, print boundary
	ble	$t1,21,printBoundary	# if index is at the first row, print boundary
	bge	$t1,463,printBoundary	# if index is at the last row, print boundary
	lb	$a0,($t5)		# get the current field character, as input register
	addi	$t5,$t5,1		# increment field pointer
	addi	$t7,$t7,1		# increment the position of empty field array, excluding the boundaries
	beq	$t6,$t7,printApple	# if the current index of empty field equals to apple index, print apple
	li      $v0,11       		# code to print character
	syscall				# print the current field character
	j	continueField		# jump to second half of loop
	
continueField:				# second half of loop
	addi	$t1, $t1, 1 		# increment t1 by 1
	beq	$t3,21,printNewLine	# print newline the beginning of new row
	j	loop 			# jump back loop
	end:
	jr	$ra			# jump to the calling function

printBoundary:				# print boundary character
	li      $v0,4			# code to print string
	la      $a0,boundaryField  	# load boundary string
	syscall				# print boundary
	j	continueField		# jump to second half of printing field loop

printApple:				# print apple character
	li      $v0,4			# code to print string
	la      $a0,appleField		# load apple string
	syscall				# print apple
	j	continueField		# jump to second half of printing field loop

printNewLine:				# print new line character
	li      $v0,4			# code to print string
	la      $a0,newLine		# load new line string
	syscall				# print new line
	j	loop			# jump to first half of printing field loop

initializeField:			# set initial values for game field
	la      $t2,emptyField  	# load empty field string
	lbu	$t2,0($t2)  		# read first character of empty field
	li	$t0, 400 		# loop boundary, field size
	li	$t1, 0 			# loop counter
loop1:
	beq	$t1, $t0, end1		# if t1 == 10 end loop1
	sb	$t2, field($t1)		# store empty field in field[t1]
	addi	$t1, $t1, 1		# add 1 to t1
	j	loop1			# jump back to loop1
end1:
	j	initializeSession	# jump to initializeSession function

initializeSession:			# initialize variables needed for game
	sw	$zero,score		# store 0 in score
	sw	$zero,direction		# store 0 in direction
	li	$t0,1			# load 1 in t0
	sw	$t0,snakeSize		# store 1 in snakeSize
	lw 	$t2,H			# load field heigh
	divu 	$t2,$t2,2		# get center of height
	subiu 	$t2,$t2,1		# get index of row above center
	lw	$t3,W			# load field width
	mul	$t2,$t2,$t3		# multiply width by row number to get the index in field
	divu 	$t3,$t3,2		# divide width by two, to get center column
	add	$t2,$t2,$t3		# add center column to field index
	sw	$t2,snake($zero)	# store field center as the first index of snake
	la	$t3,snakeField		# load snake string
	lbu	$t3,0($t3)		# get snake character
	sb	$t3,field($t2)		# write snake character at the center of field
	j	replaceApple		# place apple randomly

replaceApple:				# place apple randomly on the field
	li 	$a1,400			# upper bound, not inclusive, of the random number range
	li 	$v0,42			# random generator seed
	syscall				# get random number in %a0
	sw	$a0,apple		# write random number to apple
	sw	$a0,oldApple		# store random apple index to be used later in making sure it's in empty field
	la	$t0,field		# load field array
	add	$t0,$t0,$a0		# point to the field index corresponding to apple
	lw	$a1,oldApple		# set apple position as argument
	la	$a3,snakeField		# load snake string
	lbu	$a3,0($a3)      	# read snake character as argument
	la      $a2,emptyField  	# load empty field string
	lbu	$a2,0($a2)		# read empty field character as argument
	beq	$t0,$a3,placeAppleEmpty	# if the current apple index equals to a snake index, change apple index to an empty field
j	gameLoop			# else jump to game loop

placeAppleEmpty:			# make sure that apple is placed on empty field
	addi	$a0,$a0,1		# add 1 to apple index
	remu	$a0,$a0,400		# make sure new index is on field
	beq	$a0,$a1,main		# if returned to the original random apple index, return to main because there is no empty place
	la	$t0,field		# load field array
	add	$t0,$t0,$a0		# point to the field array at new apple index
	beq	$t0,$a2,gameLoop	# if the field is empty, continue game
	j	placeAppleEmpty		# else retry to place the apple at empty field

turn:					
	lw 	$t0,direction		# turn snake clock wise or counter-clockwise
	add	$t0,$t0,$a0		# add argument (1 or -1) to direction
	addi	$t0,$t0,4		# add 4 to direction to make sure it's positive
	remu	$t0,$t0,4		# direction = direction % 4 to make sure it's in range [0,3]
	sw	$t0,direction		# store direction
	j	forward			# move forward in the new direction

forward:				# move snake forward in current direction
	lw 	$a0,W			# load width as argument
	lw 	$a1,H			# load height as argument
	lw 	$a2,snakeSize		# load snake size as argument
	subi	$a2,$a2,1		# subtract one from snake size argument, to get head index in snake
	mul	$a2,$a2,4		# multiply snake index by 4 to read and write integers in snake array
	lw	$a3,snake($a2)		# get head position as argument
	lw 	$t0,direction		# load current direction
					# move in proper direction based on t0
	beq	$t0,0,moveUp
	beq	$t0,1,moveRight
	beq	$t0,2,moveDown
	beq	$t0,3,moveLeft

moveUp:
	sub	$a3,$a3,$a0		# subtract width from head index, to go to the upper row
	add	$a3,$a3,400		# add 400 to new head index, to make sure it's positive
	remu	$a3,$a3,400		# index % 400 to make sure it's inside field
	sw	$a3,snake($a2)		# write current index at sneak array at the top
	j	ateApple		# check if head lies on the apple index

moveRight:
	addi	$a3,$a3,1		# add 1 to head index, to go to the next column
	remu	$t0,$a3,$a0		# index % 400 to make sure it's inside field
	beq	$t0,0,moveUp		# if we moved to next row, move up
	sw	$a3,snake($a2)		# write current index at sneak array at the top
	j	ateApple		# check if head lies on the apple index

moveDown:
	add	$a3,$a3,$a0		# add width from head index, to go to the lower row
	remu	$a3,$a3,400		# index % 400 to make sure it's inside field
	sw	$a3,snake($a2)		# write current index at sneak array at the top
	j	ateApple		# check if head lies on the apple index

moveLeft:
	subi	$a3,$a3,1		# subtract 1 from head index, to go to the previous column
	remu	$t0,$a3,$a0		# index % 400 to make sure it's inside field
	beq	$t0,19,moveDown 	# if we moved to previous row, move down
	sw	$a3,snake($a2)		# write current index at sneak array at the top
	j	ateApple		# check if head lies on the apple index

ateApple:				# check if head lies on the apple index
	lw	$t0,apple		# load apple index
	beq	$a3,$t0,increaseLength	# if head index matches apple index, increase snake size
	j	ateItself		# else check if head lies on snake position

ateItself:				# check if head lies on snake position
	lb	$t0,field($a3)		# load field character corresponding to snake head
	la	$t1,snakeField		# load snake string
	lbu	$t1,0($t1)		# read snake character
	beq	$t0,$t1,main		# if the new snake head field contains snake character, jump to main
	sb	$t1,field($a3) 		# else, draw snake character at snake head position
	j	gameLoop		# jump to game loop

increaseLength:
	divu	$a2,$a2,4		# transfrom index into snake size
	addi	$a2,$a2,2		# add 2 to snake head index to get new snake size
	sw	$a2,snakeSize		# store snake size
	

	lw   $t2,score			# read score which is 0
	addi $sp, $sp, -4		# allocating stack memory
	sw   $t2, 0($sp)		# storing score value in first stack pointer.
	addi $t2,$t2,10			# increase score by 10
	sw   $t2,score			# store score
	
	li	$t0, 0			# loop boubdary
	subi	$t1,$a2,1		# loop counter starting from snake size - 1
loop3:					# move each snake part one step forward
	beq	$t1,$t0,end3		# if t1 == t0 end loop3
	mul	$t2,$t1,4		# get array index that store integers, using loop counter
	subi 	$t2,$t2,4		# get i-1
	lw	$t3,snake($t2)  	# get snake[i-1]
	addi	$t2,$t2,4		# get i, for array storing integers
	sw	$t3,snake($t2)		# store snake[i-1] in snake[i]
	subi	$t1, $t1, 1		# subtract 1 from t1
	j	loop3 			# jump back to the top
end3:
	lw	$t1,tail		# load tail position
	sw	$t1,snake($zero)	# store tail at zero index of snake array
	la	$t0,snakeField		# load snake string
	lbu	$t0,0($t0)		# read snake character
	sb	$t0,field($t1)		# draw snake character on field at tail position
	sb	$t0,field($a3)		# draw snake character on field at head position
j	replaceApple			# change apple position

getArrow:				# get user pressed key
	lw 	$t0,0xFFFF0004		# read input from simulated keyboard
	li	$a0,400			# set waiting time as 400 melli second
	li	$v0,32			# code to wait
	syscall				# wait
	sw	$zero,0xFFFF0004	# reset simulated keyboard
	li	$a0,-1			# load -1 as argument for counter-clockwise turn
	beq 	$t0, 0x00000061,turn	# turn left if input key is 'a'
	li	$a0,1			# load 1 as argument for clockwise turn
	beq 	$t0, 0x00000064,turn	# turn right if input key is 'd'
	j	forward			# else move forward in current direction if input key is neither a/d

gameLoop:				# main loop
	jal	snakeSession		# print field
	lw	$t0,snake($zero)	# load current snake tail field positoin at 0 index
	sw	$t0,tail		# store tail field positoin
	la	$t1,emptyField		# load empty field string
	lbu	$t1,0($t1)		# read empty field character
	sb	$t1,field($t0)		# deaw empty character at tail position, erase tail
	lw	$t0,snakeSize		# t0 is loop boundary = snake size
	subi	$t0,$t0,1		# make loop boundary = snake size -1
	li	$t1, 0			# t1 is loop counter starting from 0
	
loop2:					# move each snake part one step backward
	beq	$t1,$t0,end2		# if t1 == 10 end loop2
	add	$t2,$t1,1		# get i+1
	mul	$t2,$t2,4		# make index suitable for array storing integer
	lw	$t3,snake($t2)		# load snake[i+1]
	subi	$t2,$t2,4		# get i, suitable for array storing integer
	sw	$t3,snake($t2)		# store snake[i+1] in snake[i]
	addi	$t1, $t1, 1 		# add 1 to t1
	j	loop2			# jump back to loop2
	
end2:
	j	getArrow		# get user input key and move snake

