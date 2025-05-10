.model small
.stack 100h
.data

menu db 'Room Service Menu:',13,10
     db '1. Housekeeping Service - 1000 Taka',13,10
     db '2. In-Room Dining        - Varies',13,10
     db '   A. Light Meal Combo    - 500 Taka',13,10
     db '   B. Full Meal Combo     - 1000 Taka',13,10
     db '   C. Premium Dinner      - 1500 Taka',13,10
     db '3. Wellness Services     - 2000 Taka/day',13,10
     db '4. Spa Treatments        - 3000 Taka/hour',13,10,'$'

time_slots db 'Time Slots:',13,10
           db '1. 06:00 AM - 08:00 AM',13,10
           db '2. 09:00 AM - 11:00 AM',13,10
           db '3. 12:00 PM - 02:00 PM',13,10
           db '4. 03:00 PM - 05:00 PM',13,10
           db '5. 06:00 PM - 08:00 PM',13,10,'$'

summary_msg db 13,10,'Booking Cost:',13,10,'$'

input_msg db 'Enter your choice: $'
ask_days db 'How many days for Wellness service? $'
ask_hours db 'How many hours for Spa service? $'
ask_food db 'Select food package [A/B/C]: $'
ask_time db 'Choose time slot (1-5): $'
ask_continue db 13,10,'Need another service? (Y/N): $'

ask_hk_type db 'Choose Housekeeping Type - (N)normal or (D)designated: $'
hk_info db 13,10,'Assigned Housekeeper: Samantha D. | ID: HK302 | Contact: 1234',13,10,'$'

service_counts dw 10,10,10,10

total_cost dw 0
temp_cost dw 0

.code

main:
    mov ax, @data
    mov ds, ax

start_booking:
    mov ah, 0
    mov al, 3
    int 10h

    ; print services
    mov ah, 09h
    lea dx, menu
    int 21h

    ; input choice
    mov ah, 09h
    lea dx, input_msg
    int 21h

    mov ah, 01h
    int 21h
    sub al, '0'
    mov bl, al

    cmp bl, 1
    je do_housekeeping
    cmp bl, 2
    je do_dining
    cmp bl, 3
    je do_wellness
    cmp bl, 4
    je do_spa
    jmp after_service

do_housekeeping:
ask_hk:
    mov ah, 09h
    lea dx, ask_hk_type   ; Ask housekeeping type
    int 21h

    mov ah, 01h           ; Get input
    int 21h
    cmp al, 'D'
    je do_designated
    cmp al, 'N'
    je do_normal
    jmp ask_hk            ; invalid input, ask again

do_designated:
    mov ah, 09h
    lea dx, hk_info       ; Show assigned housekeeper info
    int 21h

do_normal:
    mov ax, 1000
    mov temp_cost, ax
    jmp after_service

do_dining:
    mov ah, 09h
    lea dx, ask_food
    int 21h
    mov ah, 01h
    int 21h
    cmp al, 'A'
    je food_A
    cmp al, 'B'
    je food_B
    cmp al, 'C'
    je food_C
    jmp after_service

food_A:
    mov ax, 500
    mov temp_cost, ax
    jmp after_service
food_B:
    mov ax, 1000
    mov temp_cost, ax
    jmp after_service
food_C:
    mov ax, 1500
    mov temp_cost, ax
    jmp after_service

do_wellness:
    mov ah, 09h
    lea dx, ask_days
    int 21h
    mov ah, 01h
    int 21h
    sub al, '0'
    mov ah, 0
    mov bx, ax
    mov ax, 2000
    mul bx
    mov temp_cost, ax
    jmp after_service

do_spa:
    mov ah, 09h
    lea dx, ask_hours
    int 21h
    mov ah, 01h
    int 21h
    sub al, '0'
    mov ah, 0
    mov bx, ax
    mov ax, 3000
    mul bx
    mov temp_cost, ax
    jmp after_service

after_service:
    ; show time slots
    mov ah, 09h
    lea dx, time_slots
    int 21h
    lea dx, ask_time
    int 21h

    ; input time
    mov ah, 01h
    int 21h

    ; update total cost
    mov ax, total_cost
    add ax, temp_cost
    mov total_cost, ax

    ; print summary
    mov ah, 09h
    lea dx, summary_msg
    int 21h

    mov ax, total_cost
    jmp print_number

after_print_number:
    ; ask for another
    mov ah, 09h
    lea dx, ask_continue
    int 21h

    mov ah, 01h
    int 21h
    cmp al, 'Y'
    je start_booking

    ; exit
    mov ah, 4ch
    int 21h

; Print AX 
print_number:
    push ax
    push bx
    push cx
    push dx
    mov cx, 0
    mov bx, 10

pn_next:
    xor dx, dx
    div bx
    push dx
    inc cx
    test ax, ax
    jnz pn_next

pn_print:
    pop dx
    add dl, '0'
    mov ah, 02h
    int 21h
    loop pn_print

    pop dx
    pop cx
    pop bx
    pop ax
    jmp after_print_number

end main
