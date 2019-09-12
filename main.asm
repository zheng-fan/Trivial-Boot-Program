assume cs:code
code segment
start:
;将pss后面的代码写入软盘，写一个磁道（18个扇区）的内容
		mov ax,cs
		mov es,ax
		mov bx,offset pss
		mov al,18
		mov ch,0
		mov cl,1
		mov dh,0
		mov dl,0
		mov ah,3
		int 13h
		mov ax,4c00h
		int 21h
		
;第一个扇区的代码，将后面17个扇区的内容复制到1000:0，并转到此处执行
pss:	mov ax,1000h
		mov es,ax
		mov bx,0
		mov al,17
		mov dh,0
		mov ch,0
		mov cl,2
		mov dl,0
		mov ah,2
		int 13h
		mov word ptr cs:[7b00h],0
		mov word ptr cs:[7b02h],1000h
		jmp dword ptr cs:[7b00h]
;补完512字节
psd:	db 512 - (offset psd - offset pss) dup (0)

;主程序
ps:		jmp short sta
ta	db '1) reset pc',0
tb	db '2) start system',0
tc	db '3) clock',0
td	db '4) set clock',0
table dw ta-ps,tb-ps,tc-ps,td-ps
color db 2 ;记录当前日期显示的颜色
sta:
		mov ax,2000h
		mov ss,ax
		mov sp,0
		mov ax,cs
		mov ds,ax
		
;显示菜单
show:	call cls
		mov dh,10
		mov dl,30
		mov di,offset table - offset ps
		mov cx,4
s:		push cx
		mov cl,2
		mov si,[di]
		call showstr
		add di,2
		inc dh
		pop cx
		loop s
		
;读取选择
input:	mov ah,0
		int 16h
		cmp al,'1'
		je func1
		cmp al,'2'
		je func2
		cmp al,'3'
		je func3
		cmp al,'4'
		je func4
		jmp short input
		
;跳转至ffff:0实现reset pc
func1:	mov word ptr cs:[7b00h],0
		mov word ptr cs:[7b02h],0ffffh
		jmp dword ptr cs:[7b00h]
;将硬盘的0面0道1扇区的内容复制到0:7c00并跳转至此，实现引导硬盘
func2:	mov ax,0
		mov es,ax
		mov bx,7c00h
		mov al,1
		mov ch,0
		mov cl,1
		mov dh,0
		mov dl,80h
		mov ah,2
		int 13h
		mov word ptr cs:[7b00h],7c00h
		mov word ptr cs:[7b02h],0
		jmp dword ptr cs:[7b00h]
;先重写int9中断（加入判断按键的功能）
;再循环执行显示时钟子程序，直到键盘中断
;最后恢复之前的int9中断
func3:	mov bp,0
		push cs
		pop ds
		mov ax,0
		mov es,ax
		mov si,offset int9 - offset ps
		mov di,204h
		mov cx,offset int9end - offset int9
		cld
		rep movsb
		push es:[9*4]
		pop es:[200h]
		push es:[9*4+2]
		pop es:[202h]
		cli
		mov word ptr es:[9*4],204h
		mov word ptr es:[9*4+2],0
		sti
		call cls
func3s:	call clock
		cmp bp,1
		je func3l
		cmp bp,2
		jne func3s
		mov bp,0
		inc byte ptr cs:[color-ps]
		jmp short func3s
func3l:	mov bp,0
		cli
		push es:[200h]
		pop es:[9*4]
		push es:[202h]
		pop es:[9*4+2]
		sti
		jmp show
;先显示时钟，然后输入新时间，最后写入CMOS
func4:	jmp short func4s
f4d:db 20h dup (0)
func4s:	call cls
		call clock
		mov dh,13
		mov dl,30
		mov ax,cs
		mov ds,ax
		mov si,offset f4d - offset ps
		call getstr
f4st:	mov ax,cs
		mov ds,ax
		mov si,offset f4d - offset ps
		mov di,offset fdd - offset ps
		mov cx,6
f4s:	sub [si],30h
		sub [si+1],30h
		mov dl,[si]
		push cx
		mov cl,4
		shl dl,cl
		pop cx
		or dl,[si+1]
		mov al,[di]
		inc di
		out 70h,al
		mov al,dl
		out 71h,al
		add si,3
		loop f4s
		jmp show
		
		;mov ax,4c00h
		;int 21h

;显示时钟子程序
clock:	push ax
		push ds
		push si
		push di
		push cx
		push bx
		push dx
		jmp short f3st
fd:	db 'yy/mm/dd hh:mm:ss',0
fdd:db 9,8,7,4,2,0
f3st:	mov ax,cs
		mov ds,ax
		mov si,offset fd - offset ps
		mov di,offset fdd - offset ps
		mov cx,6
f3s:	mov bx,cx
		mov al,[di]
		inc di
		out 70h,al
		in al,71h
		mov dl,al
		mov cl,4
		and dl,11110000b
		shr dl,cl
		add dl,30h
		mov [si],dl
		and al,1111b
		add al,30h
		mov [si+1],al
		add si,3
		mov cx,bx
		loop f3s
		mov cl,cs:[color-ps]
		mov dh,12
		mov dl,30
		mov si,offset fd - offset ps
		call showstr
		pop dx
		pop bx
		pop cx
		pop di
		pop si
		pop ds
		pop ax
		ret

;显示字符串子程序
showstr:push ax
		push di
		push es
		push dx
		push si
		push cx
		mov ah,dh ;找到行地址
		mov al,10
		mul ah
		add ax,0b800h
		mov es,ax 
		
		mov ax,dx ;找到列地址
		mov ah,0
		mov di,ax
		add di,di
		
		mov ah,cl
		push cx
str_s:	pop cx
		mov al,[si]
		mov es:[di],ax
		inc si
		add di,2
		push cx
		mov ch,0
		mov cl,[si]
		jcxz str_ok
		jmp short str_s
str_ok:	pop cx
		pop cx
		pop si
		pop dx
		pop es
		pop di
		pop ax
		ret

;清屏子程序
cls:	push ax
		push ds
		push cx
		push si
		mov ax,0b800h
		mov ds,ax
		mov cx,2000
		mov si,0
cls_s:	mov byte ptr [si],' '
		mov byte ptr [si+1],7
		add si,2
		loop cls_s
		pop si
		pop cx
		pop ds
		pop ax
		ret

;输入字符串子程序
getstr:	push ax
		mov word ptr cs:[ctop-ps],0
getstrs:mov ah,0
		int 16h
		cmp al,20h
		jb notc
		mov ah,0
		call cstack
		mov ah,2
		call cstack
		jmp getstrs
notc:	cmp ah,0eh
		je backs
		cmp ah,1ch
		je ent
		jmp getstrs
backs:	mov ah,1
		call cstack
		mov ah,2
		call cstack
		jmp getstrs
ent:	mov al,0
		mov ah,0
		call cstack
		mov ah,2
		call cstack
		pop ax
		ret
cstack:	jmp short cstart
ctable	dw cpush-ps,cpop-ps,cshow-ps
ctop	dw 0
cstart:	push bx
		push dx
		push di
		push es
		cmp ah,2
		ja cret
		mov bl,ah
		mov bh,0
		add bx,bx
		jmp word ptr (ctable-ps)[bx]
cpush:	mov bx,cs:[ctop-ps]
		mov [si][bx],al
		inc word ptr cs:[ctop-ps]
		jmp cret
cpop:	cmp word ptr cs:[ctop-ps],0
		je cret
		dec word ptr cs:[ctop-ps]
		mov bx,cs:[ctop-ps]
		mov al,[si][bx]
		jmp cret
cshow:	mov bx,0b800h
		mov es,bx
		mov al,160
		mov ah,0
		mul dh
		mov di,ax
		add dl,dl
		mov dh,0
		add di,dx
		mov bx,0
cshows:	cmp bx,cs:[ctop-ps]
		jne cnempty
		mov byte ptr es:[di],' '
		jmp cret
cnempty:mov al,[si][bx]
		mov es:[di],al
		mov byte ptr es:[di+2],' '
		inc bx
		add di,2
		jmp cshows
cret:	pop es
		pop di
		pop dx
		pop bx
		ret

;新的int9中断（前面的代码会将它安装到0:200）
int9:	push ax
		push bx
		
		in al,60h
		
		pushf
		call dword ptr cs:[200h]
		
		cmp al,3bh
		jne int9s2
		mov bp,2
		jmp short int9ret
int9s2:	cmp al,1
		jne int9ret
		mov bp,1
int9ret:pop bx
		pop ax
		iret
int9end:nop

code ends
end start
