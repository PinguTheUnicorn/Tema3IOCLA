section .data
	;; Variable containing the delimiters of the expression's elements
    delim 	db " ", 10, 0

section .text

extern check_atoi
extern print_tree_inorder
extern print_tree_preorder
extern evaluate_tree
extern printf
extern malloc
extern strtok
extern strdup

global create_tree
global iocla_atoi

;; Function that simulates the atoi function from C
iocla_atoi: 
    push 	ebp
    mov 	ebp, esp
    sub 	esp, 4				; Create variable
    pushad 						; Save registers

    ;; Store sign in variable
    mov 	dword [esp], 1

    ;; Take argument
    xor 	ecx, ecx
    mov 	ecx, dword [ebp + 8]

    xor 	eax, eax			; Initialize the return value with 0

verify_sign:
	cmp 	byte [ecx], 45		; Verify if it's a negative number
	jne create_number 			; If not, proceed to creating the number

negative_sign:
	;; If number is negative, store the sign as -1 and go to next element
	mov 	dword [esp], -1
	inc 	ecx
	
create_number:
	xor 	ebx, ebx			; Clear the ebx register for any residual data
	mov 	bl, byte [ecx]		; Copy the current element
	sub 	ebx, 48				; Convert the character to integer digit

	;; Multiply the return value by 10 in order to add the new value at the end
	xor 	edx, edx
	mov 	edx, 10
	mul 	edx

	add 	eax, ebx			; Add the new digit at the end of the number

	inc 	ecx					; Go to next element
	cmp 	byte [ecx], 0		; Check if it reached end of array
	jne create_number 			; If not, repeat the process

	;; Multiply the number with the sign
	xor 	ebx, ebx
	mov 	ebx, dword [esp]
	mul 	ebx

exit_atoi:
	;; Save the return value in first argument of current stackframe
	mov 	dword [ebp - 4], eax
	popad 						; Restore the values of the registers

	;; Store in eax the return value
	mov 	eax, dword [ebp - 4]

	;; Restore the stackframe
	leave
    ret





;; Auxiliary function that creates the kid nodes for every node of the tree
make_nodes:
	enter 0, 0
	sub 	esp, 8				; Create variables for children nodes
	pushad 						; Save registers

memory_left:
	xor 	eax, eax			; Clear the register for any residual data
	xor 	ebx, ebx			; Clear the register for any residual data
	mov 	ebx, 12				; Store node size

	;; Call malloc function in order to allocate memory for the left node
	push 	ebx
	call 	malloc
	add 	esp, 4

	;; Store the allocated memory in variable
	mov 	dword [ebp - 8], eax 

memory_right:
	xor 	eax, eax			; Clear the register for any residual data

	;; Call malloc function in order to allocate memory for the right node
	push 	ebx
	call 	malloc
	add 	esp, 4

	;; Store the allocated memory in variable
	mov 	dword [ebp - 4], eax 

token_left:
	;; Get data for the left node from the second argument
	mov 	ebx, dword [ebp + 12]

	;; Call strdup function in order to allocate memory and copy the data
	push 	ebx
	call 	strdup
	add 	esp, 4

	;; Get the left node and copy in its data section the element
	mov 	ebx, dword [ebp - 8]
	mov 	dword [ebx], eax

	xor 	eax, eax			; Make eax 0

	;; Make the bonds of the node null
	mov 	dword [ebx + 4], eax
	mov 	dword [ebx + 8], eax

check_operator_left:
	;; Check if first character of the data is digit
	mov 	ebx, dword [ebp + 12]
	cmp 	byte [ebx], 48
	jae token_right 			; If true, continue to right node

	;; If the first character is not a digit, check the second one
	;; In order to be sure it's not a negative number
	cmp 	byte [ebx + 1], 48
	jae token_right 			; If it's a digit, continue to right node

left_operator:
	xor 	ebx, ebx

	;; If it's an operator, get the next token with strtok
	push 	delim
	push 	ebx
	call 	strtok
	add 	esp, 8

	;; Create the children nodes of the left node
	mov 	ebx, dword [ebp - 8]
	push 	eax
	push 	ebx
	call 	make_nodes
	add 	esp, 8

token_right:
	xor 	ebx, ebx

	;; Get the next token for the right node
	push 	delim
	push 	ebx
	call 	strtok
	add 	esp, 8

	;; Allocate memory and copy the data using strdup
	push 	eax
	call 	strdup
	add 	esp, 4

	;; Get the right node and store in it's data section the element
	mov 	ebx, dword [ebp - 4]
	mov 	dword [ebx], eax

	;; Make the bonds of the node null
	mov 	dword [ebx + 4], 0
	mov 	dword [ebx + 8], 0

check_operator_right:
	;; Check if first character of the data is digit
	cmp 	byte [eax], 48
	jae make_bonds 				; If true, continue to exit

	;; If the first character is not a digit, check the second one
	;; In order to be sure it's not a negative number
	cmp 	byte [eax + 1], 48
	jae make_bonds 				; If it's a digit, continue to exit

right_operator:
	xor 	eax, eax
	
	;; If it's an operator, get the next token with strtok
	push 	delim
	push 	eax
	call 	strtok
	add 	esp, 8

	;; Create the children nodes of the left node
	push 	eax
	push 	ebx
	call 	make_nodes
	add 	esp, 8

make_bonds:
	xor 	ebx, ebx 			; Clear the register for any residual data
	xor 	eax, eax			; Clear the register for any residual data

	;; Get the root node from first argument
	mov 	eax, dword [ebp + 8]

	;; Get left node from arguments
	mov 	ebx, dword [ebp - 4]

	;; Make bonds between root and left node
	mov 	dword [eax + 8], ebx

	;; Get right node from arguments
	mov 	ebx, dword [ebp - 8]

	;; Make bonds between root and right node
	mov 	dword [eax + 4], ebx

exit_make_nodes:
	popad 						; Restore the values of the registers
	
	;; Restore the stackframe
	add 	esp, 8
	leave
	ret





;; FUnction that creates an AST from a prefix expression given as argument
create_tree:
    ; TODO
    enter 0, 0
    xor 	eax, eax
    sub 	esp, 4				; Creates variable for root node

    pushad 						; Save registers

memory_alloc:
    xor 	edx, edx 			; Clear the register for any residual data
    mov 	edx, 12				; Stores the size of the node

    ;; Call malloc in order to allocate memory for the root node
    push 	edx
    call 	malloc
    add 	esp, 4

    ;; Stores root in local variable
    mov 	dword [ebp - 4], eax

get_token:
	;; Get argument
	mov 	eax, dword [ebp + 8]

	;; Get the first element using strtok
	push 	delim
	push 	eax
	call 	strtok
	add 	esp, 8

token_memory:
	;; Allocate memory and copy the content for the data using strdup
	push 	eax
	call 	strdup
	add 	esp, 4

	;; Stores element in the data section of the node
	xor 	ebx, ebx
	mov 	ebx, dword [ebp - 4]
	mov 	dword [ebx], eax

next_token:
	;; Get next element using strtok
	xor 	eax, eax

	push 	delim
	push 	eax
	call 	strtok
	add 	esp, 8

get_children:
	;; Creates the kid nodes using the auxiliary function make_nodes
	push 	eax

	xor 	eax, eax
	mov 	eax, dword [ebp - 4]

	push 	eax
	call 	make_nodes
	add 	esp, 8

exit_function:
	popad 						; Restore the values of the registers

	;; Get the root node from the variable and store it in the return register
    pop 	eax

    ;; Restore the stackframe
    leave
    ret
