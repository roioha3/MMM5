.data
#alocates memeroy space for input
Name_Buffer: .space 100


# data base variables:
CUSTOMERS: .space 1080
Customer_Count: .word 0
CUSTOMER_SIZE: .word 108
MAX_CUSTOMERS: .word 10
# messages:
MAIN_MENU: .asciiz "\nMain Menu:\n1. add_customer\n2. display_customer\n3. update_balance\n4. delete_customer\n5. exit_program\nEnter your choice (1-5): "
INVALID_CHOICE: .asciiz "Invalid choice. Please enter a number between 1 and 5\n"
ENTER_ID: .asciiz "Enter ID: "
ENTER_NAME: .asciiz "Enter Name: "
ENTER_BALANCE: .asciiz "Enter Balance: "
ENTER_NEW_BALANCE: .asciiz "Enter New Balance: "
SUCCESS: .asciiz "Success: "
COMMA: .asciiz ", "
DOWN_LINE: .asciiz "\n"
SUCCESS_CUSTOMER_MSG: .asciiz "Success: Cutomer "
WAS_ADDED_SUCCESSFULLY: .asciiz " was added successfully\n"

# Errors:
ERROR_CUSTOMER_NOT_EXIST: .asciiz "Error: Customer "
ERROR_DOESNOT_EXIST: .asciiz " doesn't exist\n"
ERROR_CUSTOMER: .asciiz "Error: Customer "
ALREADY_EXISTS_MSG: .asciiz " already exists\n"
.text

main_menu:
	li $v0, 4
	la $a0, MAIN_MENU 
	syscall	# shows main menu.
	
	li $v0, 5
	syscall # gets an integer from the user.
	move $t0, $v0
	# checks if the input is legal and throws and exsaption.
	
	beq $t0, 1, add_customer_input
	beq $t0, 2, display_customer_input
	beq $t0, 3, update_balance_input
	beq $t0, 4, delete_record_input
	beq $t0, 5, exit_program
	# prints an error message.
	li $v0, 4
	la $a0, INVALID_CHOICE
	syscall
	
	j main_menu
	add_customer_input:
		li $v0, 4 # prints "Enter ID: "
		la $a0, ENTER_ID
		syscall
		
		li $v0, 5
		syscall # gets an integer from the user.
		
		move $s0, $v0 #stores the Id on $s0
		
		li $v0, 4 # prints "Enter Name: "
		la $a0, ENTER_NAME
		syscall
		
		li $v0, 8 #gets a string 
		la $a0, Name_Buffer
		li $a1, 100 # 99 chars and a null
		syscall
		
		la $t0, Name_Buffer
		start_delete_enter_loop:
			lb $t1, ($t0)
			beq $t1, '\n', end_delete_enter_loop
			addi $t0, $t0, 1
			j start_delete_enter_loop
		end_delete_enter_loop:
			sb $zero, ($t0)
		
		li $v0, 4 #prints "Enter Balance: "
		la $a0, ENTER_BALANCE
		syscall
		
		li $v0, 5
		syscall # gets an integer from the user.
		
		move $s1, $v0 #stores the balance on $s1
		
		move $a0, $s0
		la $a1, Name_Buffer
		move $a2, $s1
		
		jal add_customer 
		j main_menu
		
		
	display_customer_input:
		li $v0, 4 # prints "Enter ID: "
		la $a0, ENTER_ID
		syscall
		
		li $v0, 5
		syscall # gets an integer from the user.
		move $a0, $v0
		jal display_customer
		
		j main_menu
		
	update_balance_input:
		li $v0, 4 # prints "Enter ID: "
		la $a0, ENTER_ID
		syscall
				
		li $v0, 5
		syscall # gets an integer from the user.
		move $s0, $v0
		
		li $v0, 4 # prints "Enter New Balance: "
		la $a0, ENTER_NEW_BALANCE
		syscall
		
		li $v0, 5
		syscall # gets an integer from the user.
		move $s1, $v0
		move $a0, $s0
		move $a1, $s1
		jal update_balance
		
		j main_menu
	delete_record_input:
		j main_menu
		# dont know if we will do it
		li $v0, 4 # prints "Enter ID: "
		la $a0, ENTER_ID
		syscall
				
		li $v0, 5
		syscall # gets an integer from the user.
		move $a0, $v0
		jal delete_record
		
		j main_menu
# a0 = id, $a1 = address of name, $a2 = balance
add_customer:
	subi $sp, $sp, 4
	sw $fp, ($sp)
	move $fp, $sp
	
	
	la $t0, CUSTOMERS # address of the array
	lw $t1, Customer_Count
	lw $t2, CUSTOMER_SIZE
	
	unique_id_check_loop:
		beq $t1, $zero, end_unique_id_loop
		lw $t3, ($t0)
		beq $t3, $a0, user_already_exists
		add $t0, $t0, $t2 # t0 += CUSTOMER_SIZE
		subi $t1, $t1, 1 # customersToCheck -= 1
		j unique_id_check_loop
		
	end_unique_id_loop:
	
	sw $a0, ($t0) # storing id
	addi $t0, $t0, 4
	move $t1, $t0 # iterator for the name memory in array
	move $t2, $a1 # iterator for the name in the buffer
	
	store_name_loop:
		lb $t3, ($t2)
		beq $t3, $zero, end_name_loop
		sb $t3, ($t1)
		
		addi $t1, $t1, 1
		addi $t2, $t2, 1
		j store_name_loop
		
	end_name_loop:
	
	add $t0, $t0, 100
	sw $a2, ($t0) # storing balance
	add $t0, $t0, 4
	
	lw $t1, CUSTOMER_SIZE
	sub $t0, $t0, $t1 # setting t0 to the address for id of added customer
	
	lw $t2, ($t0) # id of added customer
	
	la $a0, SUCCESS_CUSTOMER_MSG
	li $v0, 4
	syscall
	
	move $a0, $t2
	li $v0, 1
	syscall
	
	la $a0, WAS_ADDED_SUCCESSFULLY
	li $v0, 4
	syscall
	j end_add_customer
	
	user_already_exists:
	move $t0, $a0
	la $a0, ERROR_CUSTOMER
	li $v0, 4
	syscall
	
	move $a0, $t0
	li $v0, 1
	syscall
	
	la $a0, ALREADY_EXISTS_MSG
	li $v0, 4
	syscall
	
	end_add_customer: 
	move $sp, $fp
	lw $fp, ($sp)
	add $sp, $sp, 4
	
	jr $ra
	
display_customer:
    subi $sp, $sp, 4 
    sw $s0, ($sp) # stores the value of $s0 on the stack
    subi $sp, $sp, 4
    sw $fp, ($sp)
    move $fp, $sp
    
    move $t0, $a0
    la $t1, CUSTOMERS
    lw $t2, Customer_Count # how many customers exists
    lw $t3, CUSTOMER_SIZE # how many bytes a customer costs
    
    mul $s0, $t2, $t3 
    add $s0, $s0, $t1 #last adress to check
    
    #starts a loop
    start_display_loop:
    	lw $t4, ($t1)
        beq $t1, $s0, start_error_Id_display
    	beq $t4, $t0, end_display_loop
    	add $t1, $t1, $t3
    	j start_display_loop	
    end_display_loop:
    				  # $t0 holds customer's ID
    	addi $t1, $t1, 4
    	la $t2, ($t1) # $t2 holds the adress for customer's name
    	addi $t1, $t1, 100
		lw $t3, ($t1) # $t3 holds the balance of the customer
		
		li $v0, 4 
   		la $a0, SUCCESS
   		syscall # prints "Success: "
   		li $v0, 1 
   		move $a0, $t0
   		syscall # prints the ID
   		
   		li $v0, 4
   		la $a0, COMMA
   		syscall # ", "
   		 
   		move $a0, $t2
   		syscall # prints the Name
   		
   		li $v0, 4
   		la $a0, COMMA
   		syscall # ", "
   		
   		li $v0, 1
   		move $a0, $t3
   		syscall # prints the balance
   		
   		li $v0, 4
   		la $a0, DOWN_LINE
   		syscall # enters line
   		
    	j end_error_Id_display
    	
    start_error_Id_display:
    	li $v0, 4
    	la $a0, ERROR_CUSTOMER_NOT_EXIST
    	syscall
    	li $v0, 1
    	move $a0, $t0
    	syscall
    	li $v0, 4
    	la $a0, ERROR_DOESNOT_EXIST
    	syscall # prints the error message
    end_error_Id_display:
    
    move $sp, $fp
    lw $fp, ($sp)
    addi $sp, $sp, 4
    lw $s0, ($sp)
    addi $sp, $sp, 4
    jr $ra
    
update_balance:
	subi $sp, $sp, 4 
    sw $s0, ($sp) # stores the value of $s0 on the stack
    subi $sp, $sp, 4
    sw $fp, ($sp)
    move $fp, $sp
    
   	move $t0, $a0
    la $t1, CUSTOMERS
    lw $t2, Customer_Count # how many customers exists
    add $t2, $t2, $t1 # holds the location of the next customer
    lw $t3, CUSTOMER_SIZE # how many bytes a customer costs
    
    mul $s0, $t2, $t3 #last adress to check
    
    	#starts a loop
    start_update_loop:
    	lw $t4, ($t1)
        beq $t4, $s0, start_error_Id_update
    	beq $t4, $t0, end_update_loop
    	add $t1, $t1, $t3
    	j start_update_loop	
    end_update_loop:
    addi $t1, $t1, 4
    la $t2, ($t1)
    addi $t1, $t1, 100
    sw $a1, ($t1)

	li $v0, 4 
   	la $a0, SUCCESS
   	syscall # prints "Success: "
   	li $v0, 1 
   	move $a0, $t0
   	syscall # prints the ID
   	
   	li $v0, 4
   	la $a0, COMMA
   	syscall # ", "
   		 
   	move $a0, $t2
   	syscall # prints the Name
   		
   	li $v0, 4
   	la $a0, COMMA
   	syscall # ", "
   		
   	li $v0, 1
   	move $a0, $t3
   	syscall # prints the balance
   		
   	li $v0, 4
   	la $a0, DOWN_LINE
   	syscall # enters line
   		
    j end_error_Id_display
    
    
    start_error_Id_update:
    end_error_Id_update:
    
    
    move $sp, $fp
    lw $fp, ($sp)
    addi $sp, $sp, 4
    lw $s0, ($sp)
    addi $sp, $sp, 4
    jr $ra
delete_record:
exit_program:
	li $v0, 10
	syscall





	
	
	
	
