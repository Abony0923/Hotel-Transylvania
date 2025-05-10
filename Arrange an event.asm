                                       .model small.MODEL SMALL
.STACK 100H
.DATA


event db 0Dh,0Ah, "Our available events:", 0Dh,0Ah, "$"
select_event db 0Dh,0Ah, "Select an event (1-6): $"
venue db 0Dh,0Ah, "Available Venues:", 0Dh,0Ah, "$"
select_venue db 0Dh,0Ah, "Select a venue (1-4): $"
theme db 0Dh,0Ah, "Available Themes:", 0Dh,0Ah, "$"
select_theme db 0Dh,0Ah, "Select a theme (1-4): $"
guest db 0Dh,0Ah, "Enter number of guests (10-99): $"
addon db 0Dh,0Ah, "Add-On Services:", 0Dh,0Ah, "$"
addon_menu db "1. Live Music/DJ (10000)", 0Dh,0Ah
           db "2. Photographer/Videographer (17000)", 0Dh,0Ah
           db "3. Catering Package", 0Dh,0Ah, "$"
catering db 0Dh,0Ah, "Select Catering Package: 1. Standard (1500), 2. Premium (2500): $"
another_addon db 0Dh,0Ah, "Do you want another add-on? (Y/N): $"
book_another db 0Dh,0Ah, "Do you want to book another event? (Y/N): $"
total_cost_msg db 0Dh,0Ah, "Final Total Cost: $", "$"

day db 0Dh,0Ah, "Enter event day (DD): $"
month db 0Dh,0Ah, "Enter event month (MM): $"
year db 0Dh,0Ah, "Enter event year (YYYY): $"

events db "1. Wedding Ceremony",0Dh,0Ah
       db "2. Birthday Party",0Dh,0Ah
       db "3. Corporate Seminar",0Dh,0Ah
       db "4. Cultural Night",0Dh,0Ah
       db "5. Met Gala",0Dh,0Ah
       db "6. Family Get Together",0Dh,0Ah,'$'
event_prices dw 20000, 10000, 12000, 15000, 14000, 8000

venues db "1. Banquet Hall",0Dh,0Ah
       db "2. Rooftop",0Dh,0Ah
       db "3. Poolside",0Dh,0Ah
       db "4. Garden",0Dh,0Ah,'$'
venue_prices dw 5000, 7000, 8000, 6000

themes db "1. Royal",0Dh,0Ah
       db "2. Garden",0Dh,0Ah
       db "3. Minimalist",0Dh,0Ah
       db "4. Futuristic",0Dh,0Ah,'$'
theme_prices dw 1000, 1500, 1200, 2000

selected_event dw 0
selected_venue dw 0
selected_theme dw 0
guest_count dw 0
total_cost dw 0
grand_total dw 0

event_day dw 0
event_month dw 0
event_year dw 0

; ----- CODE -----
.CODE
MAIN:
    mov AX, @DATA
    mov DS, AX

BookingLoop:
    mov word ptr [total_cost], 0

    ; Show Events
    mov ah, 09h
    lea dx, event
    int 21h
    lea dx, events
    int 21h

    ; Select Event
    mov ah, 09h
    lea dx, select_event
    int 21h
    call ReadDigit
    dec al
    mov bl, al
    lea si, event_prices
    mov ax, [si + bx*2]
    mov [selected_event], ax

    ; Show Venues
    mov ah, 09h
    lea dx, venue
    int 21h
    lea dx, venues
    int 21h

    ; Select Venue
    mov ah, 09h
    lea dx, select_venue
    int 21h
    call ReadDigit
    dec al
    mov bl, al
    lea si, venue_prices
    mov ax, [si + bx*2]
    mov [selected_venue], ax

    ; Show Themes
    mov ah, 09h
    lea dx, theme
    int 21h
    lea dx, themes
    int 21h

    ; Select Theme
    mov ah, 09h
    lea dx, select_theme
    int 21h
    call ReadDigit
    dec al
    mov bl, al
    lea si, theme_prices
    mov ax, [si + bx*2]
    mov [selected_theme], ax

    ; Enter Date
    mov ah, 09h
    lea dx, day
    int 21h
    call Read2Digit
    mov [event_day], ax

    mov ah, 09h
    lea dx, month
    int 21h
    call Read2Digit
    mov [event_month], ax

    mov ah, 09h
    lea dx, year
    int 21h
    call Read4Digit
    mov [event_year], ax

GetGuest:
    mov ah, 09h
    lea dx, guest
    int 21h
    call Read2Digit
    cmp ax, 10
    jl GetGuest
    cmp ax, 99
    jg GetGuest
    mov [guest_count], ax

    ; Base cost
    mov ax, [selected_event]
    add ax, [selected_venue]
    add ax, [selected_theme]
    mov [total_cost], ax

; ----- ADD-ONS -----
AddonLoop:
    mov ah, 09h
    lea dx, addon
    int 21h
    lea dx, addon_menu
    int 21h

    call ReadDigit
    cmp al, '1'
    je AddLiveMusic
    cmp al, '2'
    je AddPhoto
    cmp al, '3'
    je AddCatering
    jmp CheckAnother

AddLiveMusic:
    add [total_cost], 10000
    jmp CheckAnother

AddPhoto:
    add [total_cost], 17000
    jmp CheckAnother

AddCatering:
    mov ah, 09h
    lea dx, catering
    int 21h
    call ReadDigit
    cmp al, '1'
    je StandardCatering
    cmp al, '2'
    je PremiumCatering
    jmp CheckAnother

StandardCatering:
    mov ax, [guest_count]
    mov bx, 1500
    mul bx
    add [total_cost], ax
    jmp CheckAnother

PremiumCatering:
    mov ax, [guest_count]
    mov bx, 2500
    mul bx
    add [total_cost], ax

CheckAnother:
    mov ah, 09h
    lea dx, another_addon
    int 21h
    mov ah, 01h
    int 21h
    cmp al, 'Y'
    je AddonLoop
    cmp al, 'y'
    je AddonLoop

    ; Add to grand total
    mov ax, [total_cost]
    add [grand_total], ax

    ; Book another event?
    mov ah, 09h
    lea dx, book_another
    int 21h
    mov ah, 01h
    int 21h
    cmp al, 'Y'
    je BookingLoop
    cmp al, 'y'
    je BookingLoop

    ; Final Output
    mov ah, 09h
    lea dx, total_cost_msg
    int 21h
    mov ax, [grand_total]
    call PrintNumber

    ; Exit
    mov ah, 4ch
    int 21h



ReadDigit PROC
    mov ah, 01h
    int 21h
    ret
ReadDigit ENDP

Read2Digit PROC
    mov ah, 01h
    int 21h
    sub al, '0'
    mov ah, 0
    mov bx, 10
    mul bx
    mov cx, ax
    mov ah, 01h
    int 21h
    sub al, '0'
    mov ah, 0
    add ax, cx
    ret
Read2Digit ENDP

Read4Digit PROC
    mov ax, 0
    mov cx, 0

    ; Thousands
    mov ah, 01h
    int 21h
    sub al, '0'
    mov ah, 0
    mov bx, 1000
    mul bx
    mov cx, ax

    ; Hundreds
    mov ah, 01h
    int 21h
    sub al, '0'
    mov ah, 0
    mov bx, 100
    mul bx
    add cx, ax

    ; Tens
    mov ah, 01h
    int 21h
    sub al, '0'
    mov ah, 0
    mov bx, 10
    mul bx
    add cx, ax

    ; Units
    mov ah, 01h
    int 21h
    sub al, '0'
    mov ah, 0
    add cx, ax

    mov ax, cx
    ret
Read4Digit ENDP

PrintNumber PROC
    push ax
    push bx
    push cx
    push dx
    mov cx, 0
    mov bx, 10

ConvLoop:
    xor dx, dx
    div bx
    push dx
    inc cx
    test ax, ax
    jnz ConvLoop

PrintLoop:
    pop dx
    add dl, '0'
    mov ah, 02h
    int 21h
    loop PrintLoop

    pop dx
    pop cx
    pop bx
    pop ax
    ret
PrintNumber ENDP

END MAIN
