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
DELETED_MSG: .asciiz " deleted\n"

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
	sw $ra, ($sp)
	subi $sp, $sp, 4
	sw $fp, ($sp)
	move $fp, $sp
	
	
	
	la $t0, CUSTOMERS # address of the array
	lw $t1, Customer_Count
	lw $t2, CUSTOMER_SIZE
	
	subi $sp, $sp, 4
	sw, $a0, ($sp)
	
	jal find_customer #checking if id exists
	
	
	bne $v0, $zero, user_already_exists
	
	
	
	move $a3, $t0
	jal insert_customer
	
	lw $t0, Customer_Count
	add $t0, $t0, 1
	sw $t0, Customer_Count
	
	
	lw $t2, ($sp) # id of added customer
	
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
	
	j end_add_customer
	
	
	
	end_add_customer: 
	move $sp, $fp
	lw $fp, ($sp)
	addi $sp, $sp, 4
	lw $ra ($sp)
	addi $sp, $sp, 4
	
	jr $ra

# a0 = id 
display_customer:
	subi $sp, $sp, 4
	sw $ra, ($sp)
    subi $sp, $sp, 4 
    sw $s0, ($sp) # stores the value of $s0 on the stack
    subi $sp, $sp, 4
    sw $fp, ($sp)
    move $fp, $sp
    
    
    move $s0, $a0
    #starts a loop
    jal find_customer
    move $t0, $s0
    beq $v0, $zero, start_error_Id_display
    move $t1, $v1
    
					# $t0 holds customer's ID		
    	addi $t1, $t1, 4
    	la $t2, ($t1) # $t2 holds the address for customer's name
    	addi $t1, $t1, 100
	lw $t3, ($t1) # $t3 holds the balance of the customer
		
	li $v0, 4 
   	la $a0, SUCCESS
   	syscall # prints "Success: "
   		
   	move $a0, $t0
   	move $a1, $t2
   	move $a2, $t3
   	jal print_customer
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
    lw $ra, ($sp)
    addi $sp, $sp, 4
    jr $ra

    
update_balance:
	subi $sp, $sp, 4
	sw $ra, ($sp)
	subi $sp, $sp, 4 
    sw $s0, ($sp) # stores the value of $s0 on the stack
    subi $sp, $sp, 4
    sw $fp, ($sp)
    move $fp, $sp
    
    move $s0, $a0
    	#starts a loop
    	jal find_customer
    	move $t0, $s0
    	beq $v0, $zero, start_error_Id_update
    	move $t1, $v1
    lw $t0, ($t1)
    addi $t1, $t1, 4
    move $t2, $t1
    addi $t1, $t1, 100
    sw $a1, ($t1)
    move $t3, $a1
    
	li $v0, 4 
   	la $a0, SUCCESS
   	syscall # prints "Success: "
   	
   	move $a0, $t0
   	move $a1, $t2
   	move $a2, $t3
   	jal print_customer
   	
    j end_error_Id_update
    
    
    start_error_Id_update:
        li $v0, 4
    	la $a0, ERROR_CUSTOMER_NOT_EXIST
    	syscall
    	li $v0, 1
    	move $a0, $t0
    	syscall
    	li $v0, 4
    	la $a0, ERROR_DOESNOT_EXIST
    	syscall # prints the error message
    end_error_Id_update:
    
    
    move $sp, $fp
    lw $fp, ($sp)
    addi $sp, $sp, 4
    lw $s0, ($sp)
    addi $sp, $sp, 4
    lw $ra, ($sp)
    addi $sp, $sp, 4
    jr $ra
    
# a0 = id
delete_record:
	subi $sp, $sp, 4
	sw $ra, ($sp)
	subi $sp, $sp, 4
	sw $fp, ($sp)
	move $fp, $sp
	subi $sp, $sp, 4
	
	sw $a0, ($sp)
	jal find_customer
	beq $v0, $zero, set_up_error_customer_doesnt_exist
	
	# checking if customer of id is last
	la $t0, CUSTOMERS
	lw $t1, Customer_Count
	subi $t1, $t1, 1
	lw $t2, CUSTOMER_SIZE
	mul $t1, $t1, $t2
	add $t0, $t0, $t1 # has the address of the last customer
	beq $v1, $t0, decrease_customer_count
	
	# copying last customer:
	lw $a0, ($t0) # a0 = id
	add $t0, $t0, 4
	move $a1, $t0 #a1 = address of name
	add $t0, $t0, 100
	lw $a2, ($t0) #a2 = balance
	move $a3, $v1 # a3 = address of deleted customer
	jal insert_customer # inserting last customer in deleted customer place
	
	decrease_customer_count:
		lw $t0, Customer_Count
		subi $t0, $t0, 1
		sw, $t0, Customer_Count
	
	la $a0, SUCCESS_CUSTOMER_MSG
	li $v0, 4
	syscall
	
	lw $a0, ($sp)
	li $v0, 1
	syscall
	
	la $a0, DELETED_MSG
	li $v0, 4
	syscall
	
	j end_delete_record
	
	set_up_error_customer_doesnt_exist:
	lw $a0, ($sp) 
	jal error_customer_doesnt_exist
	
	end_delete_record:
	move $sp, $fp
	lw $fp ($sp)
	addi $sp, $sp, 4
	lw $ra, ($sp)
	addi $sp, $sp, 4
	jr $ra
	
# a0 = id
# a1 = address name
# a2 = balance
print_customer:
	subi $sp, $sp, 4
	sw $fp, ($sp)
	move $fp, $sp
	
   	li $v0, 1 
   	syscall # prints the ID
   	
   	li $v0, 4
   	la $a0, COMMA
   	syscall # ", "
   		 
   	move $a0, $a1
   	syscall # prints the Name
   		
   	li $v0, 4
   	la $a0, COMMA
   	syscall # ", "
   		
   	li $v0, 1
   	move $a0, $a2
   	syscall # prints the balance
   		
   	li $v0, 4
   	la $a0, DOWN_LINE
   	syscall # enters line
   	
   	move $sp, $fp
   	lw $fp, ($sp)
   	addi $sp, $sp, 4
   	jr $ra

# a0 = id
# v0 = 0 - not found, 1 - found
# v1 = address of customer in array
find_customer:
	la $t0, CUSTOMERS
	lw $t1, Customer_Count
	lw $t2, CUSTOMER_SIZE
	
	find_customer_loop:
		beq $t1, $zero, not_found
		lw $t3, ($t0)
		beq $t3, $a0, found
		add $t0, $t0, $t2 # t0 += CUSTOMER_SIZE
		subi $t1, $t1, 1 # customersToCheck -= 1
		j find_customer_loop
		
	not_found:
		move $v0, $zero
		j end_find_customer

	found:
		li $v0, 1
		move $v1, $t0
		j end_find_customer
	
	end_find_customer:
		jr $ra
		
# a0 = id
error_customer_doesnt_exist:
	move $t0, $a0
	li $v0, 4
    	la $a0, ERROR_CUSTOMER_NOT_EXIST
    	syscall
    	
    	li $v0, 1
    	move $a0, $t0
    	syscall
    	
    	li $v0, 4
    	la $a0, ERROR_DOESNOT_EXIST
    	syscall # prints the error message

# a0 = id, a1 = address of name, a2 = balance, a3 = address to store
insert_customer:	
	subi $sp, $sp, 4
	sw $fp, ($sp)
	move $fp, $sp
	
	move $t0, $a3
	sw $a0, ($t0) # storing id
	addi $t0, $t0, 4
	move $t1, $t0 # iterator for the name memory in array
	move $t2, $a1 # iterator for the name 
	
	store_name_loop:
		lb $t3, ($t2)
		beq $t3, $zero, end_name_loop
		sb $t3, ($t1)
		
		addi $t1, $t1, 1
		addi $t2, $t2, 1
		j store_name_loop
	end_name_loop:
		
	
	add $t0, $t0, 100
	
	clean_name:
		beq $t1, $t0, end_clean_name
		sb $zero, ($t1)
		addi $t1, $t1, 1
	end_clean_name:
	
	sw $a2, ($t0) # storing balance
	
	move $sp, $fp
	lw $fp ($sp)
	addi $sp, $sp, 4
	
	jr $ra
	
exit_program:
	li $v0, 10
	syscall





	
	
	
	
