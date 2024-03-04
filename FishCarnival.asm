;________________________________________________________________________
;Concept: Egypt                                                          |
;M. Hasnain Fatmi             Roll No. 21l-1773                          |
;________________________________________________________________________|

bits 16
[org 0x0100]

jmp start

 seconds:    dw 0    
 ticks:      dw 195
 ticks2:      dw 76
 oldisr: dd 0											; space for saving old isr
 oldtimer: dd 0											; space for saving old isr
 flag: db 0
 Aflag: db 0
 Bflag: db 0
 Gflag: db 0
 Rflag: db 0
 Hflag: db 0
 fish: dw 3280
 score: dw 0
 RandomNum: dw 2900  
 RandomNum2: dw 2900  
 maxlength: dw 0
 HP: dw 50
 ; PCB layout:
; ax,bx,cx,dx,si,di,bp,sp,ip,cs,ds,ss,es,flags,next,dummy
; 0, 2, 4, 6, 8,10,12,14,16,18,20,22,24, 26 , 28 , 30
pcb: times 2*16 dw 0 ; space for 2 PCBs
stack: times 2*256 dw 0 ; space for 2 512 byte stacks
nextpcb: dw 1 ; index of next free pcb
current: dw 0 ; index of current pcb

spisr: dw 0



msg: db 10, 13, 'Please enter your name: $'
msg1: db 'Hello Mr.', 0
msg2: db 'Welcome to Jumanji!!!', 0
msg3: db 'In this version we will take you to egypt.', 0 
msg4: db 'The Credits:- ', 0 
msg5: db '   Hasnain & Mudassir', 0
msg7: db 'Press any key to proceed.....', 0
msg8: db 'Instructions:-', 0
msg9: db '1. Use arrow keys to move the fish in any direction', 0
msg10: db '2. Use ESC key to exit the Animation (Game)', 0
msg11: db '3. You cannot enter the area in which boats are moving',0
msg12: db '4. The bottom area of the sea is off-limits due to dangerous creatures',0
msg27: db '5. There will be red and green baits randomly placed in the sea',0
msg28: db '6. Each Red and Green bait is assigned value 50 and 10 respectively',0
msg29: db '7. Try to get yourself a higher score each time and enjoy',0
msg13: db '________________________________________________________________________________',0
msg14: db '_______________________________________________',0
msg15: db '|     I hope you liked this little game       |',0
msg16: db '|  I hope to Improve based on your feedback   |',0
msg17: db '|      Thank you and May we meet again        |',0
msg18: db '|  Regards:-                                  |',0 
msg19: db '|         Hasnain Fatmi & Mudassir            |',0
msg26: db '_______________________________________________',0
msg20: db '|            Your Score is                     |',0
msg21: db '|_____________________________________________|',0
msg22: db '|            The game has ended               |',0
 buffer: times 4000 db 0 ; space for 4000 bytes
msg23: db '|   Are you sure that you want to exit the game?      |',0
msg24: db '|               Y           or           N            |',0
msg25: db 'Score: ',0
msg30: db '           __     __                    _____    _              _ ',0
msg31: db '           \ \   / /                   |  __ \  (_)            | |',0
msg32: db '            \ \_/ /    ___    _   _    | |  | |  _    ___    __| |',0
msg33: db '             \   /    / _ \  | | | |   | |  | | | |  / _ \  / _` |',0
msg34: db '              | |    | (_) | | |_| |   | |__| | | | |  __/ | (_| |',0
msg35: db '              |_|     \___/   \__,_|   |_____/  |_|  \___|  \__,_|',0
msg36: db '      o                  o             o                  o                ',0
msg37: db '        o ___/|__          o            o   o              o               ',0
msg38: db '      o _/       \  /| o              o     ___/|__      o                 ',0
msg39: db '       /  @ \\    \/ |    o            o  _/       \  /|   o  ___/|__      ',0
msg40: db '       \_   //    /\ |  o  ___/|__       /  @ \\    \/ | o  _/       \  /| ',0
msg41: db '         \_______/  \| o _/       \  /|  \_   //    /\ |  o/  @ \\    \/ | ',0
msg42: db '                        /  @ \\    \/ |    \_______/  \|   \_   //    /\ | ',0
msg43: db '                        \_   //    /\ |                      \_______/  \| ',0
msg44: db '                          \_______/  \|                                    ',0
msg45: db 'HP: ',0
msg46: db '           ______________ __  ________   ___  _  _______   _____   __',0 
msg47: db '          / __/  _/ __/ // / / ___/ _ | / _ \/ |/ /  _/ | / / _ | / / ',0
msg48: db '         / _/_/ /_\ \/ _  / / /__/ __ |/ , _/    // / | |/ / __ |/ /__',0
msg49: db '        /_/ /___/___/_//_/  \___/_/ |_/_/|_/_/|_/___/ |___/_/ |_/____/',0
Ibuffer:
db 80 								; Byte # 0: Max length of buffer
db 0 											; Byte # 1: number of characters on return
times 80 db 0 									; 80 Bytes for actual buffer space
;Input buffer ends



;------------------------------------------------
strlen:
		push bp
		mov bp,sp
		push es
		push cx
		push di
		les di, [bp+4] ; point es:di to string
		mov cx, 0xffff ; load maximum number in cx
		xor al, al ; load a zero in al
		repne scasb ; find zero in the string
		mov ax, 0xffff ; load maximum number in ax
		sub ax, cx ; find change in cx
		dec ax ; exclude null from length
		pop di
		pop cx
		pop es
		pop bp
		ret 4 
;------------------------------------------------
clrscr: push es
		push ax
		push cx
		push di
		mov ax, 0xb800
		mov es, ax ; point es to video base
		xor di, di ; point di to top left column
		mov ax, 0x0720 ; space char in normal attribute
		mov cx, 2000 ; number of screen locations
		cld ; auto increment mode
		rep stosw ; clear the whole screen
		pop di 
		pop cx
		pop ax
		pop es
		ret 

;------------------------------------------------
printstr:

			push bp
			mov bp, sp
			push es
			push ax
			push cx
			push si
			push di
			push ds ; push segment of string
			mov ax, [bp+4]
			push ax ; push offset of string
			call strlen ; calculate string length 
			cmp ax, 0 ; is the string empty
			jz leaveprint ; no printing if string is empty
			mov cx, ax ; save length in cx
			mov ax, 0xb800
			mov es, ax ; point es to video base
			mov al, 80 ; load al with columns per row
			mul byte [bp+8] ; multiply with y position
			add ax, [bp+10] ; add x position
			shl ax, 1 ; turn into byte offset
			mov di,ax ; point di to required location
			mov si, [bp+4] ; point si to string
			mov ah, [bp+6] ; load attribute in ah
			cld ; auto increment mode
			nextchar: lodsb ; load next char in al
			stosw ; print char/attribute pair
			loop nextchar ; repeat for the whole string
			leaveprint: pop di
			pop si
			pop cx
			pop ax
			pop es
			pop bp
			ret 8 
;------------------------------------------------------

Pixels:
	push bp
	mov bp,SP
	push ax
	push bx
	push cx
	push dx
	
		; Setting Video Mode 0x0D (320 x 200 graphics mode)
		
			mov		al, 0x0D
			mov		ah, 0x00
			int		0x10
	
		call	printface
		call	Eye1
		call	Eye2
		call    Mouth
		
		mov		ah, 0x0C
			mov		al, 0x01
			
			mov		BH, 0x00
			
			mov	 cx, 300
			mov		dx, 50
			
		int 0x10
		
		; BIOS int 16h SRV 00h (get keystroke)
		
			mov		ah, 0x00
			int		0x16
		
		; Returning to Video Mode 0x02 (80 x 25 text mode)

			mov		al, 0x02
			mov		ah, 0x00
			int		0x10



pop dx
pop cx
pop bx
pop ax
pop bp
ret



;------------------------------------------------------

	
	
	printface:
		push bp
		mov bp,SP
		push	ax
		push	bx
		push	cx
		push	dx
			
			; BIOS int 10h SRV 0Ch			(write graphics pixel)
			
			mov		AH, 0x0C
			mov		AL, 0x07
			
			mov		BH, 0x00
			
			mov		cx, 50
			mov		dx, 20
			
			upperright:
			
				call	delayforload
				int		0x10
				
				inc		cx
				
			cmp		cx, 260
			jne		upperright
			
			
		upperrightside:
			
				call	delayforload
				int		0x10
				
				inc		cx
				inc		dx
				
			    cmp		cx, 270
			    jne		upperrightside
				
			lowerright:
			
				call	delayforload
				int		0x10
				
				inc		dx

				
			cmp		dx, 160
			jne		lowerright
			
		lowerrightside:
			
				call	delayforload
				int		0x10
				
				dec		cx
				inc		dx
				
			cmp		cx, 260
			jne		lowerrightside

			
			lowerleft:
			
				call	delayforload
				int		0x10
				
				dec		cx
				
			cmp		cx, 50
			jne		lowerleft
			
			lowerleftside:
			
				call	delayforload
				int		0x10
				
				dec		cx
				dec		dx
				
			    cmp	    cx, 40
			jne		lowerleftside
			
			
				
			upperleft:
			
				call	delayforload
				int		0x10
				
				dec		dx
				
			    cmp		dx, 30
			jne		upperleft
			
			upperleftside:
			
				call	delayforload
				int		0x10
				
				inc		cx
				dec		dx
				
			    cmp		cx, 50
			    jne		upperleftside

			
			
			
		
		pop		dx
		pop		cx
		pop		bx
		pop		ax
		pop bp
	
	ret
	
	Eye1:
		push  bp
		mov bp, SP
		push	ax
		push	bx
		push	cx
		push	dx
			
			; BIOS int 10h SRV 0Ch			(write graphics pixel)
			
			mov		AH, 0x0C
			mov		AL, 0x07
			
			mov		BH, 0x00
			
			mov		cx, 190
			mov		dx, 70
			
			upperright1:
			
				call	delayforload
				int		0x10
				
				inc		cx
				inc		dx
				
			cmp		cx, 205
			jne		upperright1
				
			lowerright1:
			
				call	delayforload
				int		0x10
				
				dec		cx
				inc		dx
				
			cmp		cx, 190
			jne		lowerright1
			
			lowerleft1:
			
				call	delayforload
				int		0x10
				
				dec		cx
				dec		dx
				
			cmp		cx, 175
			jne		lowerleft1
				
			upperleft1:
			
				call	delayforload
				int		0x10
				
				inc		cx
				dec		dx
				
			cmp		cx, 190
			jne		upperleft1
		
		pop		dx
		pop		cx
		pop		bx
		pop		ax
		pop 	bp
	
		ret

Eye2:
		push bp
		mov bp, SP
		push	ax
		push	bx
		push	cx
		push	dx
			
			; BIOS int 10h SRV 0Ch			(write graphics pixel)
			
			mov		AH, 0x0C
			mov		AL, 0x07
			
			mov		BH, 0x00
			
			mov		cx, 120
			mov		dx, 70
			
			upperright2:
			
				call	delayforload
				int		0x10
				
				inc		cx
				inc		dx
				
			cmp		cx, 135
			jne		upperright2
				
			lowerright2:
			
				call	delayforload
				int		0x10
				
				dec		cx
				inc		dx
				
			cmp		cx, 120
			jne		lowerright2
			
			lowerleft2:
			
				call	delayforload
				int		0x10
				
				dec		cx
				dec		dx
				
			cmp		cx, 105
			jne		lowerleft2
				
			upperleft2:
			
				call	delayforload
				int		0x10
				
				inc		cx
				dec		dx
				
			cmp		cx, 120
			jne		upperleft2
		
		pop		dx
		pop		cx
		pop		bx
		pop		ax
		pop     bp
	
	    ret
	
	
	Mouth:
	
		push bp
		mov bp, SP
		push	ax
		push	bx
		push	cx
		push	dx
			
			; BIOS int 10h SRV 0Ch			(write graphics pixel)
			
			mov		AH, 0x0C
			mov		AL, 0x07
			
			mov		BH, 0x00
			
			mov		cx, 110
			mov		dx, 120
			
			upperlip:
			
				call	delayforload
				int		0x10
				
				inc		cx
				
			cmp		cx, 200
			jne		upperlip
				
			rightside:
			
			  call	delayforload
				int		0x10
				
				dec		cx
				inc		dx
				
			cmp		cx, 180
			jne		rightside
			
			lowerlip:
			
				call	delayforload
				int		0x10
				
				dec		cx
				
			cmp		cx, 130
			jne		lowerlip
				
			leftside:
			
				call	delayforload
				int		0x10
				
				dec		cx
				dec		dx
				
			cmp		cx, 110
			jne		leftside
		
		pop		dx
		pop		cx
		pop		bx
		pop		ax
		pop     bp
	
	    ret
;---------------------------------------------------------------

Pixels1:
	push bp
	mov bp,SP
	push ax
	push bx
	push cx
	push dx
	
		; Setting Video Mode 0x0D (320 x 200 graphics mode)
		
			mov		al, 0x0D
			mov		ah, 0x00
			int		0x10
	
		
		    call    Base
			call Pole
			call Tarp
			call Filling
			call loadingboundary
			call loadinginside
			

		    mov		ah, 0x0C
			mov		al, 0x01
			
			mov		BH, 0x00
			
			mov	 cx, 300
			mov		dx, 50
			
			int 0x10
		
		; Returning to Video Mode 0x02 (80 x 25 text mode)
				
			mov		al, 0x02
			mov		ah, 0x00
			int		0x10



pop dx
pop cx
pop bx
pop ax
pop bp
ret



;------------------------------------------------------
	Base:
	
		push bp
		mov bp, SP
		push	ax
		push	bx
		push	cx
		push	dx
			
			; BIOS int 10h SRV 0Ch			(write graphics pixel)
			
			mov		AH, 0x0C
			mov		AL, 0x06
			
			mov		BH, 0x00
			
			mov		cx, 70
			mov		dx, 120
			
			top:
			
				call	delayforload
				int		0x10
				
				inc		cx
				
			cmp		cx, 270
			  call	delayforload
			  call	delayforload
			  call	delayforload
			  call	delayforload
			  call	delayforload
			  call	delayforload
			  call	delayforload
			  call	delayforload
			 call	delayforload
			jne		top
				
			side1:
			  call	delayforload
			  
			  
				int		0x10
				
				dec		cx
				inc		dx
				
				
			cmp		dx, 160
			  call	delayforload
			  call	delayforload
			 call	delayforload
			  call	delayforload
			  call	delayforload
			  call	delayforload
			  call	delayforload
			  call	delayforload
			  call	delayforload
			  
			jne		side1
			
			side2:
			
				call	delayforload
				int		0x10
				
				dec		cx
				
			cmp		cx, 110
			  call	delayforload
			  call	delayforload
			  call	delayforload
			  call	delayforload
			  call	delayforload
			  call	delayforload
			  call	delayforload
			  call	delayforload
			  call	delayforload
			jne		side2
				
			bottom:
			
				call	delayforload
				int		0x10
				
				dec		cx
				dec		dx
				
			cmp		cx, 70
			
			  call	delayforload
			  call	delayforload
			  call	delayforload
			  call	delayforload
			  call	delayforload
			  call	delayforload
			  call	delayforload
			  call	delayforload
			  call	delayforload
		  
			jne		bottom
					pop		dx
		pop		cx
		pop		bx
		pop		ax
		pop     bp
	
	    ret


	Tarp:
	
		push bp
		mov bp, SP
		push	ax
		push	bx
		push	cx
		push	dx
			
			; BIOS int 10h SRV 0Ch			(write graphics pixel)
			
			mov		AH, 0x0C
			mov		AL, 0x08
			
			mov		BH, 0x00


			mov dx, 119
			mov cx, 140
			
			
			flagup:
			call	delayforload
				int		0x10
				
				;dec		cx
				dec		dx
				
			cmp		dx, 10	
			  call	delayforload
			  call	delayforload
			  call	delayforload
			  call	delayforload
			  call	delayforload
			  call	delayforload
			  call	delayforload
			  call	delayforload
			  call	delayforload			
			jne		flagup
			  
			  
			  
			  
			  flagupleft:
			  
			  call	delayforload
				int		0x10
				
				dec		cx
				inc		dx
				
			cmp		dx,90 	
			  call	delayforload
			  call	delayforload
			  call	delayforload
			  call	delayforload
			  call	delayforload
			  call	delayforload
			  call	delayforload
			  call	delayforload
			  call	delayforload			
			  jne		flagupleft
			  
			  
			  
			  flagupright:
			  
			   call	delayforload
				int		0x10
				
				inc		cx
				;inc		dx
			  call	delayforload
			  call	delayforload
			  call	delayforload
			  call	delayforload
			  call	delayforload
			  call	delayforload
			  call	delayforload
			  call	delayforload
			  call	delayforload				
			cmp		cx,140 
			
			jne		flagupright
			  
			  
			  
			  



			  mov cx,170
			  mov dx,119
			  
			  
			  
			  flagup2:
			    call	delayforload
				int		0x10
				
				dec		dx
				
			cmp		dx, 30
			  call	delayforload
			  call	delayforload
			  call	delayforload
			  call	delayforload
			  call	delayforload
			  call	delayforload
			  call	delayforload
			  call	delayforload
			  call	delayforload			
	     	  jne		flagup2
			  
			  
			  
			   flagup2right:
			  
			   call	delayforload
				int		0x10
				
				inc		cx
				inc		dx
			 call	delayforload
			  call	delayforload
			  call	delayforload
			  call	delayforload
			  call	delayforload
			  call	delayforload
			  call	delayforload
			  call	delayforload
			  call	delayforload
				
			cmp		dx,100 
			jne		flagup2right
			  
			  flagup2left:
			  
			   call	delayforload
				int		0x10
				
				dec		cx
				;dec		dx
			  call	delayforload
			  call	delayforload
			  call	delayforload
			  call	delayforload
			  call	delayforload
			  call	delayforload
			  call	delayforload
			  call	delayforload
			  call	delayforload				
			cmp		cx,170 
			jne		flagup2left
			  			  		
		pop		dx
		pop		cx
		pop		bx
		pop		ax
		pop     bp
	
	    ret

			  
	Filling:
	
		push bp
		mov bp, SP
		push	ax
		push	bx
		push	cx
		push	dx
			
			; BIOS int 10h SRV 0Ch			(write graphics pixel)
			
			mov		AH, 0x0C
			mov		AL, 0x06
			
			mov		BH, 0x00
		  
		  
				mov dx,120
				mov cx,90
			
			line38:
			  
				call	delayforload
				int		0x10
				inc		cx			
				cmp		cx,250
				jne		line38

				mov dx,121
				mov cx,71
			
			line39:
			  
				call	delayforload
				int		0x10
				inc		cx			
				cmp		cx,269
				jne		line39

				mov dx,122
				mov cx,72
			
			line40:
			  
				call	delayforload
				int		0x10
				inc		cx			
				cmp		cx,268
				jne		line40

				mov dx,123
				mov cx,73
			
			line41:
			  
				call	delayforload
				int		0x10
				inc		cx			
				cmp		cx,267
				jne		line41
		  
		  			  mov dx,124
			  mov cx,74

		  
			  line1:
			  
			  call	delayforload
			   
				int		0x10
				
				inc		cx
				
			  cmp		cx,266 	  
			  jne		line1
			  
			  mov dx,125
			  mov cx,75
			  
			  
			  line2:
			  
			  call	delayforload
			   
				int		0x10
				
				inc		cx
				
			cmp		cx,265
		    jne		line2
			  
			  
			  mov dx,126
			  mov cx,76
			  
			  
			  line3:
			  
			  call	delayforload
			   
				int		0x10
				
				inc		cx
	
				cmp		cx,264 
				jne		line3
			  
			   mov dx,127
			  mov cx,77
			  
			  
			  line4:
			  
			  call	delayforload
			   
				int		0x10
				
			  inc		cx
			  cmp		cx,263	  
			  jne		line4
			  
			  
			   mov dx,128
			  mov cx,78
			  
			  
			  line5:
			  
			  call	delayforload
			   
				int		0x10
				
				inc		cx
			  cmp		cx,262
			  jne		line5
			  
			  
			   mov dx,129
			  mov cx,79
			  
			  
			  line6:
			  
			  call	delayforload
			   
				int		0x10
				
				inc		cx		
			  cmp		cx,261		  
			  jne		line6
			  
			   mov dx,130
			  mov cx,80
			  
			  
			  line7:
			  
			  call	delayforload
			   
				int		0x10
				
				inc		cx
				;dec		dx
				
			  cmp		cx,260
			  jne		line7
			  
			  mov dx,131
			  mov cx,81
			  
			  
			  line8:
			  
			  call	delayforload
			   
				int		0x10
				
				inc		cx
				;dec		dx
				
			  cmp		cx,259
			  jne		line8
			  
			  mov dx,132
			  mov cx,82
			  
			  
			  line9:
			
			  call	delayforload 
			  int		0x10
			  inc		cx
			  cmp		cx,258
			  jne		line9


				mov dx,133
				mov cx,103
			
			line10:
			  
				call	delayforload
				int		0x10
				inc		cx			
				cmp		cx,237
				jne		line10

				mov dx,134
				mov cx,104
			
			line11:
			  
				call	delayforload
				int		0x10
				inc		cx			
				cmp		cx,236
				jne		line11


				mov dx,135
				mov cx,105
			
			line12:
			  
				call	delayforload
				int		0x10
				inc		cx			
				cmp		cx,235
				jne		line12

				mov dx,136
				mov cx,106
			
			line13:
			  
				call	delayforload
				int		0x10
				inc		cx			
				cmp		cx,234
				jne		line13


				mov dx,137
				mov cx,107
			
			line14:
			  
				call	delayforload
				int		0x10
				inc		cx			
				cmp		cx,233
				jne		line14


				mov dx,138
				mov cx,108
			
			line15:
			  
				call	delayforload
				int		0x10
				inc		cx			
				cmp		cx,232
				jne		line15


				mov dx,139
				mov cx,109
			
			line16:
			  
				call	delayforload
				int		0x10
				inc		cx			
				cmp		cx,231
				jne		line16


				mov dx,140
				mov cx,110
			
			line17:
			  
				call	delayforload
				int		0x10
				inc		cx			
				cmp		cx,230
				jne		line17

				mov dx,141
				mov cx,111
			
			line18:
			  
				call	delayforload
				int		0x10
				inc		cx			
				cmp		cx,229
				jne		line18

				mov dx,142
				mov cx,112
			
			line19:
			  
				call	delayforload
				int		0x10
				inc		cx			
				cmp		cx,228
				jne		line19

				mov dx,143
				mov cx,113
			
			line20:
			  
				call	delayforload
				int		0x10
				inc		cx			
				cmp		cx,227
				jne		line20

				mov dx,144
				mov cx,114
			
			line21:
			  
				call	delayforload
				int		0x10
				inc		cx			
				cmp		cx,226
				jne		line21

				mov dx,145
				mov cx,115
			
			line22:
			  
				call	delayforload
				int		0x10
				inc		cx			
				cmp		cx,225
				jne		line22

				mov dx,146
				mov cx,116
			
			line23:
			  
				call	delayforload
				int		0x10
				inc		cx			
				cmp		cx,224
				jne		line23

				mov dx,147
				mov cx,117
			
			line24:
			  
				call	delayforload
				int		0x10
				inc		cx			
				cmp		cx,223
				jne		line24

				mov dx,148
				mov cx,118
			
			line25:
			  
				call	delayforload
				int		0x10
				inc		cx			
				cmp		cx,222
				jne		line25

				mov dx,149
				mov cx,119
			
			line26:
			  
				call	delayforload
				int		0x10
				inc		cx			
				cmp		cx,221
				jne		line26

				mov dx,150
				mov cx,120
			
			line27:
			  
				call	delayforload
				int		0x10
				inc		cx			
				cmp		cx,220
				jne		line27

				mov dx,151
				mov cx,121
			
			line28:
			  
				call	delayforload
				int		0x10
				inc		cx			
				cmp		cx,219
				jne		line28

				mov dx,152
				mov cx,122
			
			line29:
			  
				call	delayforload
				int		0x10
				inc		cx			
				cmp		cx,218
				jne		line29

				mov dx,153
				mov cx,123
			
			line30:
			  
				call	delayforload
				int		0x10
				inc		cx			
				cmp		cx,217
				jne		line30
			  

				mov dx,154
				mov cx,124
			
			line31:
			  
				call	delayforload
				int		0x10
				inc		cx			
				cmp		cx,216
				jne		line31
			  

				mov dx,155
				mov cx,125
			
			line32:
			  
				call	delayforload
				int		0x10
				inc		cx			
				cmp		cx,215
				jne		line32
			 
				mov dx,156
				mov cx,126
			
			line33:
			  
				call	delayforload
				int		0x10
				inc		cx			
				cmp		cx,214
				jne		line33
			 
				mov dx,157
				mov cx,127
			
			line34:
			  
				call	delayforload
				int		0x10
				inc		cx			
				cmp		cx,213
				jne		line34
			 
				mov dx,158
				mov cx,128
			
			line35:
			  
				call	delayforload
				int		0x10
				inc		cx			
				cmp		cx,212
				jne		line35
			 
				mov dx,159
				mov cx,129
			
			line36:
			  
				call	delayforload
				int		0x10
				inc		cx			
				cmp		cx,211
				jne		line36
			 
				mov dx,160
				mov cx,130
			
			line37:
			  
				call	delayforload
				int		0x10
				inc		cx			
				cmp		cx,210
				jne		line37
		
		pop		dx
		pop		cx
		pop		bx
		pop		ax
		pop     bp
	
	    ret

Pole:
		push bp
		mov bp, SP
		push	ax
		push	bx
		push	cx
		push	dx
			
			; BIOS int 10h SRV 0Ch			(write graphics pixel)
			
			mov		AH, 0x0C
			mov		AL, 0x07
			
			mov		BH, 0x00

				  mov dx,119
			  mov cx, 150
			  
			  pol:
			  
				call	delayforload
				int		0x10
				dec		dx
				
				cmp		dx,10 
			  call	delayforload
			  call	delayforload
			  call	delayforload
			  call	delayforload
			  call	delayforload
			  call	delayforload
			  call	delayforload
			  call	delayforload				
				jne		pol
				
				add dx, 1
				add cx, 1
				
			pol1:
				  call	delayforload
				  int	0x10
			      inc	dx
				
				cmp		dx,120	
			call	delayforload
			  call	delayforload
			  call	delayforload
			  call	delayforload
			  call	delayforload
			  call	delayforload
			  call	delayforload
			  call	delayforload
			  call	delayforload				
			    jne		pol1

				sub dx, 1
				add cx, 1
				
			pol2:
				call	delayforload
				int		0x10
				dec		dx
				
				cmp		dx,10 
			call	delayforload
			  call	delayforload
			  call	delayforload
			  call	delayforload
			  call	delayforload
			  call	delayforload
			  call	delayforload
			  call	delayforload
			  call	delayforload				
				jne		pol2

				add dx, 1				
				add cx, 1
			
			pol3:
				  call	delayforload
				  int	0x10
			      inc	dx
				
				cmp		dx,120
				call	delayforload
			  call	delayforload
			  call	delayforload
			  call	delayforload
			  call	delayforload
			  call	delayforload
			  call	delayforload
			  call	delayforload
			  call	delayforload				
			    jne		pol3

				sub dx, 1
			    add cx, 1
				
			pol4:
				call	delayforload
				int		0x10
				dec		dx
				
				cmp		dx,10
				call	delayforload
			  call	delayforload
			  call	delayforload
			  call	delayforload
			  call	delayforload
			  call	delayforload
			  call	delayforload
			  call	delayforload
			  call	delayforload				
				jne		pol4

				add dx, 1	
				add cx, 1
			
			pol5:
				  call	delayforload
				  int	0x10
			      inc	dx
				
				cmp		dx,120
				call	delayforload
			  call	delayforload
			  call	delayforload
			  call	delayforload
			  call	delayforload
			  call	delayforload
			  call	delayforload
			  call	delayforload
			    jne		pol5

				 		pop		dx
		pop		cx
		pop		bx
		pop		ax
		pop     bp
	
	    ret
		
loadingboundary:
push bp
	mov bp,SP
	push ax
	push bx
	push cx
	push dx
	
			mov		AH, 0x0c
			mov		AL, 0x07
			
			mov		BH, 0x00
		  
		  
				mov dx,176
				mov cx,112
	
			
			boundarya:
			
				call	delayforload
				int		0x10
				
				inc		cx	
				
				cmp		cx,228
				
				call delayforload
				call delayforload
				call delayforload
				
				jne		boundarya
				
			boundaryb:
				call	delayforload
				int		0x10
				
				inc		dx	
				
				cmp		dx,180
				call delayforload
				call delayforload
				call delayforload				
				jne		boundaryb
				
			boundaryc:
				call	delayforload
				int		0x10
				
				dec		cx	
				call delayforload
				call delayforload
				call delayforload				
				cmp		cx,112
				jne		boundaryc
				
			boundaryd:
				call	delayforload
				int		0x10
				
				dec		dx	
				call delayforload
				call delayforload
				call delayforload				
				cmp		dx,176
				jne		boundaryd				
				
				
			
		  
		  			  
			
			
	
		


pop dx
pop cx
pop bx
pop ax
pop bp
ret


loadinginside:
push bp
	mov bp,SP
	push ax
	push bx
	push cx
	push dx
	
			mov		AH, 0x0c
			mov		AL, 0x0a
			
			mov		BH, 0x00
		  
		  
				mov dx,178
				mov cx,114
				
	
			
			loadingina:
			
			
			
				call	delayforload
				int		0x10
				
				inc		cx	
				
				
				

				
				cmp		cx,227
				
				call delayforload
				call delayforload
				call delayforload
				call delayforload
				call delayforload
				call delayforload
				call delayforload
				call delayforload
				call delayforload
				call delayforload
				call delayforload
				call delayforload
				call delayforload
				call delayforload
				call delayforload
				call delayforload
				call delayforload
				call delayforload
				call delayforload
				call delayforload
				call delayforload
				call delayforload
				call delayforload
				call delayforload
				call delayforload
				call delayforload
				call delayforload
				call delayforload
				call delayforload
				call delayforload
				call delayforload				
				
				
				jne loadingina
				
				
				
			
				
							
							
	
		


pop dx
pop cx
pop bx
pop ax
pop bp
ret
	delayforload:

		push	cx

			mov		cx, 0xfff
			dlp:	loop	dlp
			
		pop		cx
	
	ret
	;------------------------------------------------------
initpcb:

push bp
mov bp, sp

push ax
push bx
push cx
push si

mov bx,1 ; read next available pcb index
mov cl, 5
shl bx, cl ; multiply by 2 for pcb start
mov ax, [bp+6] ; read segment parameter
mov [pcb+bx+18], ax ; save in pcb space for cs
mov ax, [bp+4] ; read offset parameter
mov [pcb+bx+16], ax ; save in pcb space for ip
mov [pcb+bx+22], ds ; set stack to our segment
mov si, 1 ; read this pcb index
mov cl, 9
shl si, cl ; multiply by 512
add si, 256*2+stack ; end of stack for this thread
sub si, 2 ; decrement thread stack pointer
mov [pcb+bx+14], si ; save si in pcb space for sp
mov word [pcb+bx+26], 0x0200 ; initialize thread flags
mov word[pcb+bx+28], 0
mov word [pcb+28], 1 ;setting next of zero thread to thread 1

pop si
pop cx
pop bx
pop ax

pop bp

ret 4
;----------------------------------------------------------------


FishDisplay:

		push bp
		mov bp,sp
		push ax
		call clrscr ; clear the screen

		
		
		mov ax, 0
		push ax ; push x position
		mov ax, 5
		push ax ; push y position
		mov ax, 1 ; blue on black
		push ax ; push attribute
		mov ax, msg46
		push ax ; push offset of string
		call printstr ; print the string
	

		mov ax, 0
		push ax ; push x position
		mov ax, 6
		push ax ; push y position
		mov ax, 1 ; blue on black 
		push ax ; push attribute
		mov ax, msg47
		push ax ; push offset of string
		call printstr ; print the string


		mov ax, 0
		push ax ; push x position
		mov ax, 7
		push ax ; push y position
		mov ax, 1 
		push ax ; push attribute
		mov ax, msg48 ; Red on black
		push ax ; push offset of string
		call printstr ; print the string


		mov ax, 0
		push ax ; push x position
		mov ax, 8
		push ax ; push y position
		mov ax, 1 ;Cyan on black 
		push ax ; push attribute
		mov ax, msg49
		push ax ; push offset of string
		call printstr ; print the string
		
		mov ax, 0
		push ax ; push x position
		mov ax, 11
		push ax ; push y position
		mov ax, 1 ; blue on black
		push ax ; push attribute
		mov ax, msg36
		push ax ; push offset of string
		call printstr ; print the string
	

		mov ax, 0
		push ax ; push x position
		mov ax, 12
		push ax ; push y position
		mov ax, 1 ; blue on black 
		push ax ; push attribute
		mov ax, msg37
		push ax ; push offset of string
		call printstr ; print the string


		mov ax, 0
		push ax ; push x position
		mov ax, 13
		push ax ; push y position
		mov ax, 1 
		push ax ; push attribute
		mov ax, msg38 ; Red on black
		push ax ; push offset of string
		call printstr ; print the string


		mov ax, 0
		push ax ; push x position
		mov ax, 14
		push ax ; push y position
		mov ax, 1 ;Cyan on black 
		push ax ; push attribute
		mov ax, msg39
		push ax ; push offset of string
		call printstr ; print the string


		mov ax, 0
		push ax ; push x position
		mov ax, 15
		push ax ; push y position
		mov ax, 1 ;Cyan on black
		push ax ; push attribute
		mov ax, msg40
		push ax ; push offset of string
		call printstr ; print the string

		mov ax, 0
		push ax ; push x position
		mov ax, 16
		push ax ; push y position
		mov ax, 1 ;white on black
		push ax ; push attribute
		mov ax, msg41
		push ax ; push offset of string
		call printstr ; print the string

		mov ax, 0
		push ax ; push x position
		mov ax, 17
		push ax ; push y position
		mov ax, 1;white on black
		push ax ; push attribute
		mov ax, msg42
		push ax ; push offset of string
		call printstr ; print the string

		mov ax, 0
		push ax ; push x position
		mov ax, 18
		push ax ; push y position
		mov ax, 1 ;white on black
		push ax ; push attribute
		mov ax, msg43
		push ax ; push offset of string
		call printstr ; print the string

		mov ax, 0
		push ax ; push x position
		mov ax, 19
		push ax ; push y position
		mov ax, 1 ;white on black
		push ax ; push attribute
		mov ax, msg44
		push ax ; push offset of string
		call printstr ; print the string


	
		pop ax
		pop bp
		ret		

;------------------------------------------------------





Welcome: 
		push bp
		mov bp,sp
		push ax
		push dx
		push es
		push bx
		push cx
	
		call FishDisplay
		mov dx, msg 								; greetings message
		mov ah, 9 										; service 9 – write string
		int 0x21 		
	    
		mov dx, Ibuffer 							; input buffer (ds:dx pointing to input buffer)
		mov ah, 0x0A 							; DOS' service A – buffered input
		int 0x21 								; dos services call

		mov bh, 0
		mov bl, [Ibuffer+1] 						; read actual size in bx i.e. no of characters user entered

		mov word[maxlength], bx		; length of users input
		
		
		;Using following Dos service to print user's name on screen
		
		mov  ah, 0x13
		mov al, 0x00
		mov bh, 0x00
		mov bl, 1			; Attribute
		
		mov cx, word[maxlength]
		mov dl, 40			; cols
		push cs
		pop es

	    call clrscr ; clear the screen
		
		mov dh, 0			;row
		mov bp, Ibuffer+2	;user's input
		int 0x10
		
		
		mov ax, 30
		push ax ; push x position
		mov ax, 0
		push ax ; push y position
		mov ax, 1 ; blue on black
		push ax ; push attribute
		mov ax, msg1
		push ax ; push offset of string
		call printstr ; print the string


		mov ax, 28
		push ax ; push x position
		mov ax, 2
		push ax ; push y position
		mov ax, 1 ; blue on black
		push ax ; push attribute
		mov ax, msg2
		push ax ; push offset of string
		call printstr ; print the string
	

		mov ax, 18
		push ax ; push x position
		mov ax, 4
		push ax ; push y position
		mov ax, 1 ; blue on black 
		push ax ; push attribute
		mov ax, msg3
		push ax ; push offset of string
		call printstr ; print the string


		mov ax, 2
		push ax ; push x position
		mov ax, 22
		push ax ; push y position
		mov ax, 4 
		push ax ; push attribute
		mov ax, msg4 ; Red on black
		push ax ; push offset of string
		call printstr ; print the string


		mov ax, 25
		push ax ; push x position
		mov ax, 23
		push ax ; push y position
		mov ax, 3 ;Cyan on black 
		push ax ; push attribute
		mov ax, msg5
		push ax ; push offset of string
		call printstr ; print the string

		mov ax, 25
		push ax ; push x position
		mov ax, 24
		push ax ; push y position
		mov ax, 0x81 ;Blinking blue on black
		push ax ; push attribute
		mov ax, msg7
		push ax ; push offset of string
		call printstr ; print the string

		mov ax, 2
		push ax ; push x position
		mov ax, 6
		push ax ; push y position
		mov ax, 4 ;Red on black
		push ax ; push attribute
		mov ax, msg8
		push ax ; push offset of string
		call printstr ; print the string
		
		mov ax, 00
		push ax ; push x position
		mov ax, 8
		push ax ; push y position
		mov ax, 2 ;Green on black
		push ax ; push attribute
		mov ax, msg9
		push ax ; push offset of string
		call printstr ; print the string
		
		mov ax, 00
		push ax ; push x position
		mov ax, 10
		push ax ; push y position
		mov ax, 2 ;Green on black
		push ax ; push attribute
		mov ax, msg10
		push ax ; push offset of string
		call printstr ; print the string

		mov ax, 00
		push ax ; push x position
		mov ax, 12
		push ax ; push y position
		mov ax, 2 ;Green on black
		push ax ; push attribute
		mov ax, msg11
		push ax ; push offset of string
		call printstr ; print the string

		mov ax, 0
		push ax ; push x position
		mov ax, 14
		push ax ; push y position
		mov ax, 2 ;Green on black
		push ax ; push attribute
		mov ax, msg12
		push ax ; push offset of string
		call printstr ; print the string
		
		mov ax, 0
		push ax ; push x position
		mov ax, 16
		push ax ; push y position
		mov ax, 2 ;Green on black
		push ax ; push attribute
		mov ax, msg27
		push ax ; push offset of string
		call printstr ; print the string

		mov ax, 0
		push ax ; push x position
		mov ax, 18
		push ax ; push y position
		mov ax, 2 ;Green on black
		push ax ; push attribute
		mov ax, msg28
		push ax ; push offset of string
		call printstr ; print the string

		mov ax, 0
		push ax ; push x position
		mov ax, 20
		push ax ; push y position
		mov ax, 2 ;Green on black
		push ax ; push attribute
		mov ax, msg29
		push ax ; push offset of string
		call printstr ; print the string

		mov ah, 0 ; service 0 – get keystroke
		int 0x16 ; call BIOS keyboard service
		
		pop cx
		pop bx
		pop es
		pop dx
		pop ax		
		pop bp
		ret
		
	Goodbye:

		push bp
		mov bp,sp
		push ax
		call clrscr ; clear the screen


		mov ax, 18
		push ax ; push x position
		mov ax, 2
		push ax ; push y position
		mov ax, 7 ; white on black
		push ax ; push attribute
		mov ax, msg14
	
		push ax ; push offset of string
		call printstr ; print the string

		mov ax, 18
		push ax ; push x position
		mov ax, 4
		push ax ; push y position
		mov ax, 7 ; white on black
		push ax ; push attribute
		mov ax, msg22
		push ax ; push offset of string
		call printstr ; print the string


		mov ax, 18
		push ax ; push x position
		mov ax, 6
		push ax ; push y position
		mov ax, 1 ; blue on black
		push ax ; push attribute
		mov ax, msg15
		push ax ; push offset of string
		call printstr ; print the string
	

		mov ax, 18
		push ax ; push x position
		mov ax, 8
		push ax ; push y position
		mov ax, 1 ; blue on black 
		push ax ; push attribute
		mov ax, msg16
		push ax ; push offset of string
		call printstr ; print the string


		mov ax, 18
		push ax ; push x position
		mov ax, 10
		push ax ; push y position
		mov ax, 4 
		push ax ; push attribute
		mov ax, msg17 ; Red on black
		push ax ; push offset of string
		call printstr ; print the string


		mov ax, 18
		push ax ; push x position
		mov ax, 12
		push ax ; push y position
		mov ax, 3 ;Cyan on black 
		push ax ; push attribute
		mov ax, msg18
		push ax ; push offset of string
		call printstr ; print the string


		mov ax, 18
		push ax ; push x position
		mov ax, 14
		push ax ; push y position
		mov ax, 3 ;Cyan on black
		push ax ; push attribute
		mov ax, msg19
		push ax ; push offset of string
		call printstr ; print the string

		mov ax, 18
		push ax ; push x position
		mov ax, 16
		push ax ; push y position
		mov ax, 7 ;white on black
		push ax ; push attribute
		mov ax, msg26
		push ax ; push offset of string
		call printstr ; print the string

		mov ax, 18
		push ax ; push x position
		mov ax, 18
		push ax ; push y position
		mov ax, 7 ;white on black
		push ax ; push attribute
		mov ax, msg20
		push ax ; push offset of string
		call printstr ; print the string		
		mov ax, 18
		push ax ; push x position
		mov ax, 20
		push ax ; push y position
		mov ax, 7 ;white on black
		push ax ; push attribute
		mov ax, msg21
		push ax ; push offset of string
		call printstr ; print the string

		
		pop ax
		pop bp
		ret	

GameOver:

		push bp
		mov bp,sp
		push ax
		call clrscr ; clear the screen

		mov ax, 20
		push ax ; push x position
		mov ax, 5
		push ax ; push y position
		mov ax, 1 ; blue on black
		push ax ; push attribute
		mov ax, msg36
		push ax ; push offset of string
		call printstr ; print the string

		mov ax, 14
		push ax ; push x position
		mov ax, 9
		push ax ; push y position
		mov ax, 1 ; blue on black
		push ax ; push attribute
		mov ax, msg36
		push ax ; push offset of string
		call printstr ; print the string

		mov ax, 30
		push ax ; push x position
		mov ax, 3
		push ax ; push y position
		mov ax, 1 ; blue on black
		push ax ; push attribute
		mov ax, msg36
		push ax ; push offset of string
		call printstr ; print the string

		mov ax, 30
		push ax ; push x position
		mov ax, 16
		push ax ; push y position
		mov ax, 1 ; blue on black
		push ax ; push attribute
		mov ax, msg36
		push ax ; push offset of string
		call printstr ; print the string

		mov ax, 24
		push ax ; push x position
		mov ax, 19
		push ax ; push y position
		mov ax, 1 ; blue on black
		push ax ; push attribute
		mov ax, msg36
		push ax ; push offset of string
		call printstr ; print the string

		mov ax, 0
		push ax ; push x position
		mov ax, 10
		push ax ; push y position
		mov ax, 1 ; blue on black
		push ax ; push attribute
		mov ax, msg30
		push ax ; push offset of string
		call printstr ; print the string
	

		mov ax, 0
		push ax ; push x position
		mov ax, 11
		push ax ; push y position
		mov ax, 1 ; blue on black 
		push ax ; push attribute
		mov ax, msg31
		push ax ; push offset of string
		call printstr ; print the string


		mov ax, 0
		push ax ; push x position
		mov ax, 12
		push ax ; push y position
		mov ax, 1 
		push ax ; push attribute
		mov ax, msg32 ; Red on black
		push ax ; push offset of string
		call printstr ; print the string


		mov ax, 0
		push ax ; push x position
		mov ax, 13
		push ax ; push y position
		mov ax, 1 ;Cyan on black 
		push ax ; push attribute
		mov ax, msg33
		push ax ; push offset of string
		call printstr ; print the string


		mov ax, 0
		push ax ; push x position
		mov ax, 14
		push ax ; push y position
		mov ax, 1 ;Cyan on black
		push ax ; push attribute
		mov ax, msg34
		push ax ; push offset of string
		call printstr ; print the string

		mov ax, 0
		push ax ; push x position
		mov ax, 15
		push ax ; push y position
		mov ax, 1 ;white on black
		push ax ; push attribute
		mov ax, msg35
		push ax ; push offset of string
		call printstr ; print the string
		
		mov ax, 25
		push ax ; push x position
		mov ax, 24
		push ax ; push y position
		mov ax, 0x81 ;Blinking blue on black
		push ax ; push attribute
		mov ax, msg7
		push ax ; push offset of string
		call printstr ; print the string


		mov ah, 0 ; service 0 – get keystroke
		int 0x16 ; call BIOS keyboard service
			
		pop ax
		pop bp
		ret				

Ask:

		push bp
		mov bp,sp
		push ax
		call clrscr ; clear the screen


		mov ax, 14
		push ax ; push x position
		mov ax, 12
		push ax ; push y position
		mov ax, 7 ; white on black
		push ax ; push attribute
		mov ax, msg23	
		push ax ; push offset of string
		call printstr ; print the string

		mov ax, 14
		push ax ; push x position
		mov ax, 13
		push ax ; push y position
		mov ax, 7 ; white on black
		push ax ; push attribute
		mov ax, msg24
	
		push ax ; push offset of string
		call printstr ; print the string

		pop ax
		pop bp
		ret		









;-----------------------------------------------------------------
; subroutine to save the screen
;-----------------------------------------------------------------
saveScreen:

	push bp
	mov bp, sp
	push cx 
	push ax
	push ds
	push es
	push si
	push di
	


			mov cx, 4000 ; number of screen locations

					

			mov ax, 0xb800
			mov ds, ax ; ds = 0xb800

			push cs
			pop es
		
			mov si, 0
			mov di, buffer

			cld ; set auto increment mode
			rep movsb ; save screen

			;[es:di] = [ds:si]
			

pop di
pop si
pop es
pop ds
pop ax
pop cx
pop bp
			ret
;-----------------------------------------------------------------
;-----------------------------------------------------------------
; subroutine to restore the screen
;-----------------------------------------------------------------
restoreScreen:

	push bp
	mov bp, sp
	push cx 
	push ax
	push ds
	push es
	push si
	push di


			mov cx, 4000 ; number of screen locations

					

			mov ax, 0xb800
			mov es, ax ; ds = 0xb800

			push cs
			pop ds
		
			mov si, buffer
			mov di, 0

			cld ; set auto increment mode
			rep movsb ;  screen

			;[es:di] = [ds:si]
			

pop di
pop si
pop es
pop ds
pop ax
pop cx
pop bp
ret	


;-----------------------------------------------------------------
;-----------------------------------------------------------------
; subroutine for adding delay
;-----------------------------------------------------------------

delay:
			push bp
			mov bp,sp
			push cx
			
			mov cx, 0xFFFF
loop1:
		loop loop1
			
			mov cx, 0xFFFF
loop2:
		loop loop2
	
			pop cx
			pop bp
			ret

;-----------------------------------------------------------------
;-----------------------------------------------------------------
; subroutine to generate random number
;-----------------------------------------------------------------

RANDGEN:

push bp
mov bp,sp
pusha

RANDSTART1:

   MOV AH, 00h    
   INT 1AH            

   mov  ax, dx
   xor  dx, dx
   mov  bx, 900   
   div  bx       
	
					; Now check if generated number is even OR odd  
    mov bx,dx
    mov ax,dx
	mov dx,1
    mov cx,2
	div cx
	cmp dx,1
    jne Erand
   
Orand:							; If odd
   add bx, 2961
   jmp Further   
Erand: 						    ; If even
   add bx, 2960

Further:						; to make it appear more random adding score
		mov ax,bx
		add ax, word[cs:score]
		cmp ax, 3900
		ja minus

adding:
		add bx, word[cs:score]
		jmp Gotrand
minus:
		add bx, word[cs:score]
		sub bx, 900
  
Gotrand:   
	   mov [bp+4], bx			; put the acquired number on the stack which would be taken in ax in the timer
	   
popa
pop bp
ret


;------------------------------------------------------
; subroutine to print a score on screen
;------------------------------------------------------
PrintScore:


push bp
mov bp, sp
push es
push ax
push bx
push cx
push dx
push di

	mov ax, 0xb800
	mov es, ax ; point es to video base
	mov ax, word[cs:score] ; load number in ax
	mov bx, 10 ; use base 10 for division
	mov cx, 0 ; initialize count of digits
 
 nextdigit:
	
	mov dx, 0 ; zero upper half of dividend
	div bx ; divide by 10
	add dl, 0x30 ; convert digit into ascii value
	push dx ; save ascii value on stack
	inc cx ; increment count of values
	cmp ax, 0 ; is the quotient zero
	jnz nextdigit ; if no divide it again
	cmp byte[cs:Aflag], 0
	jne InGoodBye

InGame:	
	mov di, 20 ; point di to 10th column
nextpos1:	
	pop dx ; remove a digit from the stack
	mov dh, 0x38 ; use normal attribute
	mov [es:di], dx ; print char on screen
	add di, 2 ; move to next screen location
	loop nextpos1 ; repeat for all digits on stack	
	jmp leavescore


InGoodBye:
		mov di, 2970 ; point di to column
nextpos2:
	
	pop dx ; remove a digit from the stack
	mov dh, 0x8 ; use normal attribute
	mov [es:di], dx ; print char on screen
	add di, 2 ; move to next screen location
	loop nextpos2 ; repeat for all digits on stack	


leavescore:

pop di
pop dx
pop cx
pop bx
pop ax 
pop es
pop bp
ret 

;------------------------------------------------------
; subroutine to print a HP on screen
;------------------------------------------------------
PrintHP:


push bp
mov bp, sp
push es
push ax
push bx
push cx
push dx
push di

	mov ax, 0xb800
	mov es, ax ; point es to video base
	mov ax, word[cs:HP] ; load number in ax
	mov bx, 10 ; use base 10 for division
	mov cx, 0 ; initialize count of digits
 
 nextdigit1:
	
	mov dx, 0 ; zero upper half of dividend
	div bx ; divide by 10
	add dl, 0x30 ; convert digit into ascii value
	push dx ; save ascii value on stack
	inc cx ; increment count of values
	cmp ax, 0 ; is the quotient zero
	jnz nextdigit1 ; if no divide it again
	mov di, 150 ; point di to 10th column
nextpos3:	
	pop dx ; remove a digit from the stack
	mov dh, 0x38 ; use normal attribute
	mov [es:di], dx ; print char on screen
	add di, 2 ; move to next screen location
	loop nextpos3 ; repeat for all digits on stack	
	jmp leavescore




leavehp:

pop di
pop dx
pop cx
pop bx
pop ax 
pop es
pop bp
ret 



;-----------------------------------------------------------------
;-----------------------------------------------------------------
; subroutine to generate sound
;-----------------------------------------------------------------

sound :
push bp
mov bp,sp
pusha
mov cx, 5

loop7:

mov al, 0b6h
out 43h, al

;load the counter 2 value for d3
mov ax, 1fb4h
out 42h, al
mov al, ah
out 42h, al

;turn the speaker on
in al, 61h
mov ah,al
or al, 3h
out 61h, al

call delay


mov al, ah
out 61h, al

call delay
 
loop loop7

popa
pop bp
ret


;-----------------------------------------------------------------
;-----------------------------------------------------------------
; subroutine to Print score on top left of screen
;-----------------------------------------------------------------
DisplayScore:	
		push bp	
		mov bp, sp
		push ax
		
		mov ax, 0
		push ax ; push x position
		mov ax, 0
		push ax ; push y position
		mov ax, 48
		push ax ; push attribute
		mov ax, msg25
		push ax ; push offset of string
		call printstr ; print the string
		call PrintScore

pop ax
pop bp
ret


DisplayHP:	
		push bp	
		mov bp, sp
		push ax
		
		mov ax, 72
		push ax ; push x position
		mov ax, 0
		push ax ; push y position
		mov ax, 48
		push ax ; push attribute
		mov ax, msg45
		push ax ; push offset of string
		call printstr ; print the string
		call PrintHP

pop ax
pop bp
ret


;Phase 1

;-----------------------------------------------------------------
;-----------------------------------------------------------------
; subroutine to Print Sky and ground
;-----------------------------------------------------------------
Sky:
		push bp
		mov bp, sp
		pusha
		mov ax, 0xb800
		mov es, ax
		mov di, 0

PrintSky:	
			mov word[es:di], 0x3820		; Atribute byte for cyan color with ASCII for space	
			add di, 2		
			cmp di, 1440				;checking until 1440  because that is our size for sky
			jne PrintSky		
			call DisplayScore			; display score of the user
			call DisplayHP			; display HP of the Fish

ground:
			mov word[es:di], 0x6820		; Atribute byte for brown color with ASCII for space	
			add di, 2		
			cmp di, 1600				;checking until 1600  because that is our size for ground
			jne ground
	
			popa
			pop bp
			ret
			

;-----------------------------------------------------------------
;-----------------------------------------------------------------
; subroutine to make a SUN
;-----------------------------------------------------------------
Sun:


push bp
mov bp,sp
push ax
push bx
push cx
push dx
push si
push di

mov ax,0
mov bx,0

nextpos:
mov ax, 0xb800
mov es, ax


mov al, 80 					; load al with columns per row
mul byte [bp+8] 			; multiply with row number
add ax, [bp+6] 				; add col
shl ax, 1					; turn into byte offset
mov di, ax 					; point di to required location

mov al, 80 					; load al with columns per row
mul byte [bp+8] 			; multiply with row number
add ax, [bp+6] 				; add col
add bx, [bp+4] 				; add length
shl bx,1
shl ax, 1 					; turn into byte offset
add ax,bx
mov si, ax 					; point si to required location
                       
mov ax,0
mov bx,0		

middle:
                        mov word [es:di],0x4820		; Atribute byte for bright red color with ASCII for space
                        add di,2
                        cmp di, si
                        jne middle
						
						
nexpos1:
mov ax,0
mov bx,0
mov di,0
mov si,0


mov di, ax 					; point di to required location
mov al, 80 					; load al with columns per row
sub byte [bp+8],1			; to move up or down
mul byte [bp+8] 			; multiply with row number
add ax, [bp+6] 				; add col
shl ax, 1 
add ax, 2					; turn into byte offset
mov di, ax 					; point di to required location

mov al, 80 					; load al with columns per row
mul byte [bp+8] 				; multiply with row number
add ax, [bp+6] 				; add col
add bx, [bp+4] 				; add length
shl bx,1
shl ax, 1 					; turn into byte offset
add ax,bx
sub ax,2
mov si, ax 					; point si to required location
                       



				mov ax , 0
				mov bx , 0

upper:
				
                        mov word [es:di],0x4820			; Atribute byte for bright red color with ASCII for space
                        add di,2
                        cmp di, si				
                        jne upper
nexpos2:
				mov ax,0
				mov bx,0
				mov di,0
				mov si,0

				mov al, 80 					; load al with columns per row
				add byte [bp+8],2			; to move up or down
				mul byte [bp+8] 			; multiply with row number
				add ax, [bp+6] 				; add col
				shl ax, 1 					; turn into byte offset
				add ax,2
				mov di, ax 					; point di to required location



				mov al, 80					; load al with columns per row
				mul byte [bp+8] 			; multiply with row number
				add ax, [bp+6] 				; add col
				add bx, [bp+4] 				; add length
				shl bx,1
				shl ax, 1 					; turn into byte offset
				add ax,bx
				sub ax,2
				mov si, ax					; point si to required location

				mov ax,0
				mov bx,0
lower:
                        mov word [es:di],0x4820    	; Atribute byte for bright red color with ASCII for space
                        add di,2
                        cmp di,si
                        jne lower


				pop di
				pop si
				pop dx
				pop cx
				pop bx
				pop ax
				pop bp
                ret 6



;-----------------------------------------------------------------
;-----------------------------------------------------------------
; subroutine to print pyramids
;-----------------------------------------------------------------
; since different shapes like mountain and buildings were allowed hence I went with pyramid like shape to give it "egypt" vibe ()

pyramid:
			push bp
			mov bp,sp
			push ax
			push bx
			push cx
			push dx
			push es
			push si
			push di
			
			mov ax, 0xb800
			mov es, ax
			mov si, 306
			
			mov bx, 0	
height1:
			add bx, 1
			add si, 160
			cmp bx, [bp+6]			;at [bp+4] height is available
			jne height1

			mov bx, 0
distance1:
								    
			add bx, 1
			add si, 24
			cmp bx, [bp+4]			;at [bp+2] position for pyramid from frist column is available
			jne distance1

			
HalfPyramid1:				; makes a triangle with spaces in-between

			mov di, si

FirstHalf:
			mov word[es:di], 0x6820	
			add di, 158			
			cmp di, 1440							
			jbe FirstHalf				; going for below and equal because we have 4 different sizes so they can be printed at any column depending on which number you give and they will always be less than 1440 which is end of sky
		
			add si, 162
			cmp si, 1440
			jb HalfPyramid1
			

			mov ax, 0xb800
			mov es, ax
			mov si, 308
			mov bx , 0
	height2:
								;label for the size of pyramid e.g 1(largest), 2(2nd largest), 3(2nd smallest), 4(smallest)
			add bx, 1
			add si, 160
			cmp bx, [bp+6]		;at [bp+4] height is available
			jne height2
	
			mov bx, 0
	distance2:
			add bx, 1
			add si, 24
			cmp bx, [bp+4]			;at [bp+2] position for pyramid from frist column is available
			jne distance2			
		
HalfPyramid2:
								; fills the spaces formed in the previous label to make a perfect pyramid shape
			mov di, si

SecondHalf:
			mov word[es:di], 0x6820	
			add di, 158			
			cmp di, 1440							
			jbe SecondHalf
									; does same work as previous one but one column ahead to fill spaces and form perfect pyramid
			add si, 162
			cmp si, 1440
			jb HalfPyramid2
			
			pop di
			pop si
			pop es
			pop dx
			pop cx
			pop bx
			pop ax
			pop bp
			ret 4


;-----------------------------------------------------------------
;-----------------------------------------------------------------
; subroutine to print clouds
;-----------------------------------------------------------------

cloud:

push bp
mov bp,sp
push ax
push bx
push cx
push dx
push si
push di

mov ax,0
mov bx,0


mov ax, 0xb800
mov es, ax


mov al, 80 					; load al with columns per row
mul byte [bp+8] 			; multiply with row number
add ax, [bp+6] 				; add col
shl ax, 1					; turn into byte offset
mov di, ax 					; point di to required location

mov al, 80 					; load al with columns per row
mul byte [bp+8] 			; multiply with row number
add ax, [bp+6] 				; add col
add bx, [bp+4] 				; add length
shl bx,1
shl ax, 1 					; turn into byte offset
add ax,bx
mov si, ax 					; point si to required location
                       
mov ax,0
mov bx,0		

layer1:			; prints first layer of the cloud at desired location
										
                        mov word [es:di],0x7720			; Attribute byte for white color corresponding to clouds
                        add di,2
                        cmp di, si
                        jne layer1
						
						

mov ax,0
mov bx,0
mov di,0
mov si,0


mov di, ax 					; point di to required location
mov al, 80 					; load al with columns per row
sub byte [bp+8],1
mul byte [bp+8] 				; multiply with row number
add ax, [bp+6] 				; add col
shl ax, 1 					; turn into byte offset
mov di, ax 					; point di to required location

mov al, 80 					; load al with columns per row
mul byte [bp+8] 				; multiply with row number
add ax, [bp+6] 				; add col
add bx, [bp+4] 				; add length
shl bx,1
shl ax, 1 					; turn into byte offset
add ax,bx
sub ax,2
mov si, ax 					; point si to required location
                       



				mov ax , 0
			    mov bx , 0

layer2:								; prints first layer of the cloud at desired location
				
                mov word [es:di],0x7720				; Attribute byte for white color corresponding to clouds
                add di,2
                cmp di, si
                jne layer2


				pop di
				pop si
				pop dx
				pop cx
				pop bx
				pop ax
				pop bp
						; return old value of registers and pointers
                       
				ret 6		; ret six because we passed 3 parameters rows, cols, and size


;-----------------------------------------------------------------
;-----------------------------------------------------------------
; subroutine to print the sea
;-----------------------------------------------------------------


Sea:
			pusha
			mov ax, 0xb800
			mov es, ax
			mov di, 1600			
PrintSea	
			mov word[es:di], 0x1820					; Attribute byte for dark blue
			add di, 2				
			cmp di, 2720							; until 2720 because that is the limit for the sea printing
			jne PrintSea
			popa
			ret

;-----------------------------------------------------------------
;-----------------------------------------------------------------
; subroutine to print undersea/bottom of sea
;-----------------------------------------------------------------

			

UnderSea:
			pusha
			mov ax, 0xb800
			mov es, ax
			mov di, 2720

seperation:					; this label is formed to keep undersea distinct from upper side

			mov word[es:di], 0x102D				; Attribute byte for blue and ASCII for dash
			add di, 2				
			cmp di, 2880							
			jne seperation
Bottom:	
			mov word[es:di], 0x1020				; Attribute byte for blue and ASCII for space
			add di, 2				
			cmp di, 4000							
			jne Bottom
			popa
			ret

;-----------------------------------------------------------------
;-----------------------------------------------------------------
; subroutine to print waves
;-----------------------------------------------------------------


Waves:
			pusha
			mov ax, 0xb800
			mov es, ax
			mov di, 1600
Printwaves:	
			mov word[es:di], 0x107E			;we are using '~' as representation of waves
			add di, 60				
			cmp di, 2680
										
			jne Printwaves
			popa
			ret

;-----------------------------------------------------------------
;-----------------------------------------------------------------
; subroutine to print boats/ ancient passenger boats
;-----------------------------------------------------------------

boat:
					; the concept for the shapes of boats is in accordance to a wooden passenger boat with pillars and a roof for tour purposes 
push bp
mov bp,sp
push ax
push bx
push cx
push dx
push si
push di

mov ax,0
mov bx,0


mov ax, 0xb800
mov es, ax


mov al, 80 					; load al with columns per row
mul byte [bp+8] 			; multiply with row number
add ax, [bp+6] 				; add col
shl ax, 1					; turn into byte offset
mov di, ax 					; point di to required location

mov al, 80 					; load al with columns per row
mul byte [bp+8] 			; multiply with row number
add ax, [bp+6] 				; add col
add bx, [bp+4] 				; add length
shl bx,1
shl ax, 1 					; turn into byte offset
add ax,bx
mov si, ax 					; point si to required location
                       
mov ax,0
mov bx,0		

l1:
                        mov word [es:di],0x605E				
                        add di,2
                        cmp di, si
                        jne l1
						
						
next1:

mov ax,0
mov bx,0
mov di,0
mov si,0


mov di, ax 					; point di to required location
mov al, 80 					; load al with columns per row
sub byte [bp+8],1			; to print up and down from the main row we chose at the start
mul byte [bp+8] 			; multiply with row number
add ax, [bp+6] 				; add col
shl ax, 1 					; turn into byte offset
mov di, ax 					; point di to required location

mov al, 80 					; load al with columns per row
mul byte [bp+8] 				; multiply with row number
add ax, [bp+6] 				; add col
add bx, [bp+4] 				; add length
shl bx,1
shl ax, 1 					; turn into byte offset
add ax,bx
mov si, ax 					; point si to required location
                       



mov ax , 0
mov bx , 0
add di, 8

pillar:
				
                        mov word [es:di],0x387F
                        add di,8
                        cmp di, si
                        jne pillar
next2:
				mov ax,0
				mov bx,0
				mov di,0
				mov si,0

				mov al, 80 					; load al with columns per row
				add byte [bp+8],2			; to print up and down from the main row we chose at the start
				mul byte [bp+8] 			; multiply with row number
				add ax, [bp+6] 				; add col
				shl ax, 1 					; turn into byte offset
				add ax,2
				mov di, ax 					; point di to required location



				mov al, 80					; load al with columns per row
				mul byte [bp+8] 			      ; multiply with row number
				add ax, [bp+6] 				; add col
				add bx, [bp+4] 				; add length
				shl bx,1
				shl ax, 1 					; turn into byte offset
				add ax,bx
				sub ax,4
				mov si, ax					; point si to required location

				mov ax,0
				mov bx,0
l2:
                        mov word [es:di],0x605E
                        add di,2
                        cmp di,si
                        jne l2

next3:
				mov ax,0
				mov bx,0
				mov di,0
				mov si,0

				mov al, 80 					; load al with columns per row
				sub byte [bp+8],3			; to print up and down from the main row we chose at the start
				mul byte [bp+8] 			; multiply with row number
				add ax, [bp+6] 				; add col
				shl ax, 1 					; turn into byte offset
				add ax, 4
				mov di, ax 					; point di to required location



				mov al, 80					; load al with columns per row
				mul byte [bp+8] 			      ; multiply with row number
				add ax, [bp+6] 				; add col
				add bx, [bp+4] 				; add length
				shl bx,1
				shl ax, 1 					; turn into byte offset
				add ax,bx
				sub ax,2
				mov si, ax					; point si to required location

				mov ax,0
				mov bx,0
l3:
                        mov word [es:di],0x075E
                        add di,2
                        cmp di,si
                        jne l3

next4:
				mov ax,0
				mov bx,0
				mov di,0
				mov si,0

				mov al, 80 					; load al with columns per row
				add byte [bp+8],4			; to print up and down from the main row we chose at the start
				mul byte [bp+8] 			; multiply with row number
				add ax, [bp+6] 				; add col
				shl ax, 1 					; turn into byte offset
				add ax, 4
				mov di, ax 					; point di to required location



				mov al, 80					; load al with columns per row
				mul byte [bp+8] 			      ; multiply with row number
				add ax, [bp+6] 				; add col
				add bx, [bp+4] 				; add length
				shl bx,1
				shl ax, 1 					; turn into byte offset
				add ax,bx
				sub ax, 6
				mov si, ax					; point si to required location

				mov ax,0
				mov bx,0
l4:
                        mov word [es:di],0x605E
                        add di,2
                        cmp di,si
                        jne l4




				pop di
				pop si
				pop dx
				pop cx
				pop bx
				pop ax
				pop bp
                
				ret 6			; ret six because we passed 3 parameters rows, cols, and size
				
;-----------------------------------------------------------------
;-----------------------------------------------------------------
; subroutine to print fish bait at random places
;-----------------------------------------------------------------
				
				
timer:
			pusha
			push es
			mov ax,0
			mov ax, 0xb800
			mov es, ax						; point es to video memory			
		
            inc     word [cs: ticks]
			inc     word [cs: ticks2]
			
            cmp     word [cs: ticks], 200      ; 18.2 ticks per second hence 90 ticks for 5 seconds
            jne     RRandom


     GRandom:    
		    mov  word [cs: ticks], 0	
			inc word [cs: seconds]	
			
			mov byte[cs:Gflag], 1		; flag wich tell if we need to print green

			mov di, word[cs:RandomNum]
			mov word[es:di], 0x1020
			
			push 0xFFFF
	        call RANDGEN				; gives us the random number we want
			
			pop ax
			mov word [cs:RandomNum], ax
	        mov di,ax
	        mov word[es:di],0x2520
			
			

	RRandom:
	
	        cmp word[cs:ticks2],90
			jne ExitTimer
			mov  word [cs: ticks2], 0	
			mov di, word[cs:RandomNum2]
			mov word[es:di], 0x1020
			
			mov byte[cs:Rflag], 1        ; flag wich tell if we need to print red
	
			push 0xFFFF
	        call RANDGEN				; gives us the random number we want
			
			pop ax
	        mov di,ax
			add di,100
			mov word [cs:RandomNum2], di
	        mov word[es:di],0x4820

			
			
			
 ExitTimer:
 
pop es
popa
			
push ds
push bx
push cs
pop ds ; initialize ds to data segment

mov bx, [current] ; read index of current in bx
shl bx, 1
shl bx, 1
shl bx, 1
shl bx, 1
shl bx, 1 ; multiply by 2 for pcb start
mov [pcb+bx+0], ax ; save ax in current pcb
mov [pcb+bx+4], cx ; save cx in current pcb
mov [pcb+bx+6], dx ; save dx in current pcb
mov [pcb+bx+8], si ; save si in current pcb
mov [pcb+bx+10], di ; save di in current pcb
mov [pcb+bx+12], bp ; save bp in current pcb
mov [pcb+bx+24], es ; save es in current pcb
pop ax ; read original bx from stack
mov [pcb+bx+2], ax ; save bx in current pcb
pop ax ; read original ds from stack
mov [pcb+bx+20], ax ; save ds in current pcb
pop ax ; read original ip from stack
mov [pcb+bx+16], ax ; save ip in current pcb
pop ax ; read original cs from stack
mov [pcb+bx+18], ax ; save cs in current pcb
pop ax ; read original flags from stack
mov [pcb+bx+26], ax ; save cs in current pcb
mov [pcb+bx+22], ss ; save ss in current pcb
mov [pcb+bx+14], sp ; save sp in current pcb
mov bx, [pcb+bx+28] ; read next pcb of this pcb
mov [current], bx ; update current to new pcb
mov cl, 5
shl bx, cl ; multiply by 2 for pcb start
mov cx, [pcb+bx+4] ; read cx of new process
mov dx, [pcb+bx+6] ; read dx of new process
mov si, [pcb+bx+8] ; read si of new process
mov di, [pcb+bx+10] ; read diof new process
mov bp, [pcb+bx+12] ; read bp of new process
mov es, [pcb+bx+24] ; read es of new process
mov ss, [pcb+bx+22] ; read ss of new process
mov sp, [pcb+bx+14] ; read sp of new process
push word [pcb+bx+26] ; push flags of new process
push word [pcb+bx+18] ; push cs of new process
push word [pcb+bx+16] ; push ip of new process
push word [pcb+bx+20] ; push ds of new process

mov ax, [pcb+bx+0] ; read ax of new process
mov bx, [pcb+bx+2] ; read bx of new process
pop ds ; read ds of new process
			
            JMP FAR [CS:oldtimer] ; call the orignal timer				
				

;-----------------------------------------------------------------
;-----------------------------------------------------------------
; subroutine to move top segment to the left infintly to depict motion
;-----------------------------------------------------------------

				
Movesegment1:
		push bp
		mov bp, sp
		push ax
		push cx
		push ds
		push es
		push si
		push di
		
		mov ax, 0xb800
		mov es, ax
		mov ds, ax
		mov di, 160
		mov si, 160
Tloop1:
		mov ax, [DS:SI]  ; value safed in register of last block
		add si, 2		; moved to next block for right to left movement
		cld				; direction flag cleared
		mov cx, 79		;copying celss 79 times
		rep movsw
		
		mov [es:di], ax   ; moving priviouly stored value in current block
		add di, 2
		
		cmp di, 1440
		jne Tloop1

pop di
pop si
pop es
pop ds
pop cx
pop ax
pop bp
ret		


;-----------------------------------------------------------------
;-----------------------------------------------------------------
; subroutine to move middle segment to the right infintly to depict motion
;-----------------------------------------------------------------
	
Movesegment2:
		push bp
		mov bp, sp
		push ax
		push cx
		push ds
		push es
		push si
		push di
		
		mov ax, 0xb800
		mov es, ax
		mov ds, ax
		mov di, 2878
		mov si, 2878
Tloop2:
		mov ax, [DS:SI]  ; value safed in register of last block
		sub si, 2		; moved to previous block for left to right movement
		std				; direction flag set
		mov cx, 79		;copying celss 79 times
		rep movsw
		
		mov [es:di], ax   ; moving priviouly stored value in current block
		sub di, 2		
		
		cmp di, 1598
		jne Tloop2

pop di
pop si
pop es
pop ds
pop cx
pop ax
pop bp
ret		


;-----------------------------------------------------------------
;-----------------------------------------------------------------
; subroutine to check if fish has reached end of right side and then make it appear on opposite in same rows
;-----------------------------------------------------------------
rightbound:
			push bp
			mov bp, sp
			push bx
			push cx
			
			xor cx, cx
			xor bx, bx
			
			mov bx,3038

checkrbound:
			cmp di, bx
			je movtoleft
			add bx, 160
			add cx, 1
			cmp cx, 7
			jne checkrbound
			jmp returntoright
			
movtoleft:
			mov byte[cs:Bflag], 1
returntoright:

pop cx
pop bx
pop bp
ret

;-----------------------------------------------------------------
;-----------------------------------------------------------------
; subroutine to check if fish has reached end of left side and then make it appear on opposite in same rows
;-----------------------------------------------------------------

leftbound:
			push bp
			mov bp, sp
			push bx
			push cx
			
			xor cx, cx
			xor bx, bx
			
			mov bx,2880

checklbound:
			cmp di, bx
			je movtoleft
			add bx, 160
			add cx, 1
			cmp cx, 7
			jne checklbound
			jmp returntoleft
			
movtoright:

			mov byte[cs:Bflag], 1

returntoleft:
pop cx
pop bx
pop bp
ret

;-----------------------------------------------------------------
;-----------------------------------------------------------------
; subroutine to check if the user wants to exit or not
;-----------------------------------------------------------------

Checkesc:
		push bp
		mov bp, sp
		push ax
	
		call saveScreen				; save current progress
		call Ask					; print a screen which asks user for ther choice
checkkey:		
			mov ah, 0										; service 0 – get keystroke
			int 0x16										; call BIOS keyboard service
CheckY:
		cmp al, 121							; check for 'Y' key
		jne CheckN
		mov byte[cs:Aflag], 1
		jmp term
	
CheckN:
		cmp al, 110							; check for 'N' key
		jne checkkey
		mov byte[cs:flag], 0
		call restoreScreen					; if user doesn't want to exit the restore the current progress

term:

pop ax
pop bp
ret
;-----------------------------------------------------------------
sound1:

s1:
mov al, 0b6h
out 43h, al

;load the counter 2 value for d3
mov ax, 1fb4h
out 42h, al
mov al, ah
out 42h, al

;turn the speaker on
in al, 61h
mov ah,al
or al, 3h
mov cx, 0xFFFF
loop9:
		loop loop9
mov al, ah
out 61h, al
mov cx, 0xFFFF
loop10:
		loop loop10

;load the counter 2 value for a3
mov ax, 152fh
out 42h, al
mov al, ah
out 42h, al

;turn the speaker on
in al, 61h
mov ah,al
or al, 3h
out 61h, al
mov cx, 0xFFFF
loop11:
		loop loop11
mov al, ah
out 61h, al
mov cx, 0xFFFF
loop12:
		loop loop12
	
;load the counter 2 value for a4
mov ax, 0A97h
out 42h, al
mov al, ah
out 42h, al
	
;turn the speaker on
in al, 61h
mov ah,al
or al, 3h
out 61h, al
mov cx, 0xFFFF
loop14:
		loop loop14
mov al, ah
out 61h, al

mov cx, 0xFFFF
loop13:
		loop loop13
 
jmp s1


;-----------------------------------------------------------------
;-----------------------------------------------------------------
; subroutine which increases score when fish eats the bait
;-----------------------------------------------------------------

ScoreIncrease1:

push bp
mov bp, sp
pusha


GreenBait:
		
		cmp byte[cs:Gflag], 1			; if current bait eaten is green then increment score by 10
		jne back1
		add word[cs:score], 10
		mov word[cs:ticks], 196					; set ticks to 89 to print next bait immediatly
		mov byte[cs:Gflag], 0			; set to default and check again
back1:

call PrintScore							; print new score
popa
pop bp
ret

;-----------------------------------------------------------------
;-----------------------------------------------------------------
; subroutine which increases score when fish eats the bait
;-----------------------------------------------------------------

ScoreIncrease2:

push bp
mov bp, sp
pusha

RedBait:
		cmp byte[cs:Rflag], 1			; if current bait eaten is red then increment score by 50
		jne back2
		add word[cs:score], 50
		mov word[cs:ticks2],70
		mov byte[cs:Rflag], 0			; set to default and check again
back2:

call PrintScore							; print new score
popa
pop bp
ret


;-----------------------------------------------------------------
;-----------------------------------------------------------------
; subroutine which checks which arrow key is pressed and moves the fish in said direction. It also checks for esc key
;-----------------------------------------------------------------

kbisr:
		
			push ax
			push bx
			push es
			
			push di
			mov ax, 0xb800
			mov es, ax						; point es to video memory			

			
			in al, 0x60						; read a char from keyboard port, scancode
			
initialize:			
		
			mov di, word[cs:fish]			; current position of fish
			mov word [es:di], 0x1020                                       
			mov word[es:di],0x1F01		


down:
			cmp al, 0x50				; is the key down arrow key
			jne left					; no, try next comparison
			mov word [es:di], 0x1020                  
      	    add di, 160 
			
			cmp di, 4000
			jae lowerbound
	        mov word[es:di],0x1F01	
            jmp exit						; leave interrupt routine

lowerbound:
			sub di, 160                     ; rebound back to allowed area     
       	    mov word[es:di],0x1F01
			mov ax,[spisr]
			Out 61h,al 
			call sound						; play sound as warning sound
			IN al,61h
			mov [spisr],ax
			sub word[cs:HP],10
			call PrintHP							; print Current HP
			jmp exit

left:
			cmp al, 0x4b					; is the key left arrow key
			jne right						; no, leave interrupt routine
			call leftbound
			cmp byte[cs:Bflag], 0			; flag for left boundry
			jne leftaround
			
			mov word [es:di], 0x1020                  
      	    sub di, 2                          
	        mov word[es:di],0x1F01	
            jmp exit
leftaround:
			mov word [es:di], 0x1020                  
			add di, 158                          
       	    mov word[es:di],0x1F01
			jmp exit

right:
			cmp al, 0x4d				; is the key right arrow key 
			jne up					    ; no, try next comparison
			call rightbound
			cmp byte[cs:Bflag], 0		; flag for right boundry
			jne rightaround
			
			mov word [es:di], 0x1020                  
      	    add di, 2                          
	        mov word[es:di],0x1F01	
            jmp exit						; leave interrupt routine
rightaround:
			mov word [es:di], 0x1020                  
			sub di, 158                          
       	    mov word[es:di],0x1F01
			jmp exit


up:
			cmp al, 0x48			; is the key up arrow key
			jne escape		        ; if not then go to check next key
			mov word [es:di], 0x1020                  
	        sub di, 160
			
			cmp di, 2880
			jb upperbound			;has fish exceed the allowed area
       	    mov word[es:di],0x1F01
			jmp exit
			
upperbound:

			add di, 160                   ; rebound back to allowed area       
       	    mov word[es:di],0x1F01			
			mov ax,[spisr]
			Out 61h,al 
			call sound						; play sound as warning sound
			IN al,61h
			mov [spisr],ax
			sub word[cs:HP],10
			call PrintHP							; print Current HP
			jmp exit
			
escape:
			cmp al, 01			; is the key esc key
			jne nomatch			; if it's not required key leave
			mov byte[cs:flag], 1 ; flag to see if esc has been pressed by user
			jmp exit



nomatch:
			pop di
			pop es
			pop bx
			pop ax
			jmp far [cs:oldisr] ; call the orignal isr

exit:		

green:
			cmp di, word[cs:RandomNum]		; check if fish has reached the position of bait
			jne red
			call ScoreIncrease1			; increase the scores
red:	
			cmp di, word[cs:RandomNum2]		; check if fish has reached the position of bait
			jne checkHP
			call ScoreIncrease2			; increase the scores			
checkHP			
			xor bx, bx
			cmp bx, word[cs:HP]
			jne leavekbisr
			mov byte[cs:flag],1
			mov byte[cs:Hflag],1
			mov byte[cs:Aflag],1

leavekbisr:
			
			mov byte[cs:Bflag], 0		; flag for left and right boundries
			mov word[cs:fish], di		; safe current position of fish

			mov al, 0x20
			out 0x20, al					; send EOI to PIC	
			pop di
			pop es
			pop bx
			pop ax
			iret

Printing:
			push bp
			mov bp, sp
			push ax
			call Pixels1
			call Welcome   ; Welcome screen which displays instructions and credits
			
			call Sky
			
			mov ax, 3		;rows
			push ax
			mov ax, 70		;cols
			push ax
			mov ax, 8		;size
			push ax
			call Sun
			
			;for pyramid there are four sizes and depending on sizes there are at least size position at which they can be printed	
			; height range: 1-4 (1 being largest and 4 being smallest)	; position range is 1-6 (1 being closest to first column , 6 being farthest from first column)
			
			mov ax , 2		; height
			push ax
			mov ax , 1		;distance
			push ax
			call pyramid
			
			mov ax, 5		;rows
			push ax
			mov ax, 60		;cols
			push ax
			mov ax, 8		;size
			push ax
			call cloud
			
			mov ax , 1		;height
			push ax
			mov ax , 2		;distance
			push ax
			call pyramid
			
			mov ax, 2		;rows
			push ax
			mov ax, 4		;cols
			push ax
			mov ax, 8		;size
			push ax
			call cloud
			
			mov ax , 1		;height
			push ax
			mov ax , 3		;distance
			push ax
			call pyramid
			
			mov ax, 3		;rows
			push ax
			mov ax, 26		;cols
			push ax
			mov ax, 12		;size
			push ax
			call cloud 
			
			mov ax , 2		;height
			push ax
			mov ax , 4		;distance
			push ax
			call pyramid

			mov ax, 2		;rows
			push ax
			mov ax, 48		;cols
			push ax
			mov ax, 6		;size
			push ax
			call cloud
			
			mov ax , 3		;height
			push ax
			mov ax , 5		;distance
			push ax
			call pyramid
			
			mov ax, 3		;rows
			push ax
			mov ax, 70		;cols
			push ax
			mov ax, 4		;size
			push ax
			call cloud
			
			mov ax , 1		;height	(P.S. 1 is the highest)
			push ax
			mov ax , 6		;distance (P.S. 6 is farthest)
			push ax
			call pyramid


			call Sea			;Call sea for printing sea
			call Waves			;Call waves for printing wave like shape


			mov ax, 14			;rows
			push ax
			mov ax, 10			;columns
			push ax
			mov ax, 28			;size
			push ax
			call boat
		
			
			mov ax, 12			;rows
			push ax
			mov ax, 56			;columns
			push ax
			mov ax, 20			;size
			push ax
			call boat


			call UnderSea		;Call Undersea for printing bottom of sea
			
			pop ax
			pop bp
			ret
			
start:


			call Printing					; subroutine which prints sky, pyramids, sea, undersea, waves, boats, sun, clouds
			IN al,61h
			mov [spisr],ax

Allmovements:

			mov byte[cs:Aflag], 0			; put default in flag (used to make sure user wants to exit)
			
			
HookKbisr:
			
			xor ax, ax
			mov es, ax										; point es to IVT base
			
			mov ax, [es:9*4]
			mov [oldisr], ax								; save offset of old routine
			mov ax, [es:9*4+2]
			mov [oldisr+2], ax								; save segment of old routine
			
			

			cli												; disable interrupts
			mov word [es:9*4], kbisr						; store offset at n*4
			mov [es:9*4+2], cs								; store segment at n*4+2
			sti												; enable interrupts

HookTimer:

			xor ax, ax
			mov es, ax										; point es to IVT base
			
			mov ax, [es:8*4]
			mov [oldtimer], ax								; save offset of old routine
			mov ax, [es:8*4+2]
			mov [oldtimer+2], ax								; save segment of old routine
			
			cli												; disable interrupts
			mov word [es:8*4], timer						; store offset at n*4
			mov [es:8*4+2], cs								; store segment at n*4+2
			sti												; enable interrupts		

			
			
		
Move:
	
	; this label is used to move both upper and middle strip in an infinite loop
			push cs ; use current code segment
			mov ax, sound1
			push ax ; use mytask as offset
			call initpcb ; register the thread
			call Movesegment1
			call Movesegment2
			call delay					; delay to make it appear like an animation and slow it down a little

			cmp byte[cs:flag], 1
			jne Move	
			 

UnhookKbisr:
			
			mov ax, [oldisr]								; read old offset in ax
			mov bx, [oldisr+2]								; read old segment in bx
			
			cli												; disable interrupts
			mov [es:9*4], ax								; restore old offset from ax
			mov [es:9*4+2], bx								; restore old segment from bx
			sti												; enable interrupts 			

UnhookTimer:

			mov ax, [oldtimer]								; read old offset in ax
			mov bx, [oldtimer+2]								; read old segment in bx
			
			cli												; disable interrupts
			mov [es:8*4], ax								; restore old offset from ax
			mov [es:8*4+2], bx								; restore old segment from bx
			sti												; enable interrupts 			

HPZero:
		cmp byte[Hflag], 0
		jne Death
CheckForExit:
			mov ax,[spisr]
			Out 61h,al 
			call Checkesc
			cmp byte[cs:Aflag], 1							
			jne Allmovements						;if user has chosen 'n' then resume all previous operations
			call Pixels
			jmp Outro
Death:
			mov ax,[spisr]
			Out 61h,al            
			call GameOver
			call Goodbye
			call PrintScore
			jmp Termination
Outro:
			;print goodbye screen and user's final score on the screen
			          
			call Goodbye
			call PrintScore

Termination:
			mov ax, 0x4c00									; terminate program
			int 0x21