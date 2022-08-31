#	8 Mo phong o dia RAID 5
#	He thong o dia RAID5 can toi thieu 3 o dia cung trong do phan du lieu parity se duoc chua lan luot len 3
#	o dia nhu trong hinh ben Hay viet chuong trinh mo phong hoat dong cua RAID 5 voi 3 o dia voi gia dinh
#	rang moi block du lieu co 4 ki tu Giao dien nhu trong minh hoa duoi Gioi han chuoi ki tu nhap vao co do
#	dai la boi cua 8 	DCE.****ABCD1234HUSTHUST
.data
Start: .asciiz "Nhap chuoi ky tu : "
Hex: .byte '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f' 
Disk1: .space 4
Disk2: .space 4
Disk3: .space 4
Array: .space 4
String: .space 1000
Enter: .asciiz "\n"
Error: .asciiz "Do dai chuoi khong hop le! Nhap lai.\n"
Message1: .asciiz "      Disk 1                 Disk 2               Disk 3\n"
Message2: .asciiz "----------------       ----------------       ----------------\n"
Message3: .asciiz "|     "
Message4: .asciiz "     |       "
Message5: .asciiz "[[ "
Message6: .asciiz "]]       "
Comma: .asciiz ","
Message7: .asciiz "Ban muon nhap lai khong?"
.text
Input:	
	li $v0, 4		# in chuoi Start
	la $a0, Start
	syscall
	li $v0, 8		# doc chuoi tu ban phim
	la $a0, String	 
	li $a1, 1000	
	syscall
	addi $s0, $a0, 0	# s0 = dia chi xau vua nhap
# Kiem tra do dai co chia het cho 8 hay khong
	addi $t9, $zero, 0 	# t9 = chieu dai xau
	addi $t0, $zero, 0 	# t0 = bien chay
Length: 
	addi $t8, $t9, 0
	add $t1, $s0, $t0 	# t1 = dia chi String[i]
	lb $t2, 0($t1) 	# t2 = String[i]
	beq $t2, 10, Test 	# t2 = '\n' ket thuc xau
	addi $t9, $t9, 1 	# length++
	addi $t0, $t0, 1	# index++
	j Length
	nop
Test: 
	beqz $t9, Errors
	and $t1, $t9, 0x00000007		# xoa het cac bit cua t9 ve 0, chi giu lai 3 bit cuoi
	beq $t1, 0, Run			# 3 bit cuoi bang 0 thi so chia het cho 8
Errors:
	li $v0, 4
	la $a0, Error
	syscall
	j Input
# In ra man hinh theo he 16
HEX:	
	srl $a0, $t5, 4
	la $t6, Hex
	add $t6, $t6, $a0
	lb $a0, 0($t6)		# in ki tu dau cua he 16
	li $v0, 11
	syscall
	la $t6, Hex
	andi $a0, $t5, 0x0000000f	# lay 4 bit cuoi cung cua t5 
	add $t6, $t6, $a0
	lb $a0, 0($t6)		# in in ki tu thu 2 cua he 16
	li $v0, 11
	syscall
	jr $ra
# Mo phong Raid 5
Run:
	li $v0, 4
	la $a0, Message1	
	syscall		# in chuoi ban dau
	li $v0, 4
	la $a0, Message2
	syscall
Line1:	
	addi $t0, $zero, 0	# t0 luu so ki tu da xet
	la $s1, Disk1
	la $s2, Disk2
	la $s3, Array
	li $v0, 4		# in "|      "
	la $a0, Message3
	syscall
Loop1:
# Disk 1
	lb $t1, ($s0)		# t1 chua dia chi tung byte cua disk 1
	addi $t9, $t9, -1
	sb $t1, ($s1)		# luu t1 vao s1
# Disk 2
	add $s4, $s0, 4
	lb $t2, ($s4)		# t2 chua dia chi tung byte cua disk 2
	addi $t9, $t9, -1
	sb $t2, ($s2)
# Disk 3
	xor $t3, $t1, $t2	# t3 = t1 xor t2
	sb $t3, ($s3)  	# luu t3 vao s3
	addi $s3, $s3, 1	# s3 += 1
	addi $t0, $t0, 1 	# so ki tu da luu + 1
	addi $s0, $s0, 1	# dia chi xau + 1 
	addi $s1, $s1, 1 	# s1 ++
	addi $s2, $s2, 1	# s2 ++
	blt $t0, 4, Loop1	# neu t0 < 4 -> Luu tiep
	la $s1, Disk1		
	la $s2, Disk2
# in Disk 1
	addi $t4, $zero,  0	
Loop11:
	lb $a0, ($s1)		# in tung byte cua Disk 1
	li $v0, 11		
	syscall		
	addi $t4, $t4, 1
	addi $s1, $s1, 1
	blt $t4, 4, Loop11	# neu t4 < 4 -> in ki tu tiep theo
	li $v0, 4		# in "       |     "
	la $a0, Message4
	syscall
	li $v0, 4
	la $a0, Message3	# in " |      "
	syscall
	addi $t4, $zero, 0
# In Disk 2
Loop12:
	lb $a0, ($s2)		# in tung byte cua Disk 2
	li $v0, 11
	syscall
	addi $t4, $t4, 1
	addi $s2, $s2, 1
	blt $t4, 4, Loop12	# t4 < 4 -> in byte tiep theo
	li $v0, 4	
	la $a0, Message4
	syscall		# in "       |      "
	li $v0, 4
	la $a0, Message5	# in "[[   "
	syscall
	la $s3, Array		
	addi $t4, $zero, 0
	addi $t5, $zero, 0
Loop13:
	lb $t5, ($s3)		# lay tung byte tu s3
	jal HEX		# in disk 3
	li $v0, 4
	la $a0, Comma	# in ", "
	syscall
	addi $t4, $t4, 1
	addi $s3, $s3, 1
	blt $t4, 3, Loop13	# in 3 dau phay thi dung
	lb $t5, ($s3)
	jal HEX
	li $v0, 4
	la $a0, Message6	# in " ]]"
	syscall		
	li $v0, 4		# xuong dong
	la $a0, Enter
	syscall
	beq $t9, 0, Exit	#  neu den cuoi xau, kt chuong trinh
# Line 2
	la $s2, Array		# Line 2, 3 tuong tu
	la $s1, Disk1
	la $s3, Disk3
	addi $s0, $s0, 4
	addi $t0, $zero, 0
	li $v0, 4
	la $a0, Message3
	syscall
Loop2:	
	lb $t1, ($s0)
	addi $t9, $t9, -1
	sb $t1, ($s1)
	add $s4, $s0, 4
	lb $t3, ($s4)
	addi $t9, $t9, -1
	sb $t3, ($s3)
	xor $t2, $t1, $t3
	sw $t2, ($s2)
	addi $s2, $s2, 4
	addi $t0, $t0, 1
	addi $s0, $s0, 1
	addi $s1, $s1, 1
	addi $s3, $s3, 1
	blt $t0, 4, Loop2
	la $s1, Disk1
	la $s3, Disk3
	addi $t4, $zero, 0
Loop21:
	lb $a0, ($s1)
	li $v0, 11
	syscall
	addi $t4, $t4, 1
	addi $s1, $s1, 1
	blt $t4, 4, Loop21
	li $v0, 4
	la $a0, Message4
	syscall
	la $s2, Array
	addi $t4, $zero, 0
	li $v0, 4
	la $a0, Message5
	syscall
Loop22:
	lb $t5, ($s2)
	jal HEX
	li $v0, 4
	la $a0, Comma
	syscall
	addi $t4, $t4, 1
	addi $s2, $s2, 4
	blt $t4, 3, Loop22
	lb $t5, ($s2)
	jal HEX
	li $v0, 4
	la $a0, Message6
	syscall
	li $v0, 4
	la $a0, Message3
	syscall
	addi $t5, $zero, 0
Loop23:
	lb $a0, ($s3)
	li $v0, 11
	syscall
	addi $t5, $t5, 1
	addi $s3, $s3, 1
	blt $t5, 4, Loop23
	li $v0, 4
	la $a0, Message4
	syscall
	li $v0, 4
	la $a0, Enter
	syscall
	beq $t9, 0, Exit
# Line 3
	la $a2, Array	 # tuong tu
	la $s2, Disk2
	la $s3, Disk3
	addi $s0, $s0, 4
	addi $t0, $zero, 0
	li $v0, 4
	la $a0, Message5
	syscall
Loop3:
	lb $t1, ($s0)
	addi $t9, $t9, -1
	sb $t1, ($s1)
	add $s4, $s0, 4
	lb $t2, ($s4)
	addi $t9, $t9, -1
	sb $t2, ($s3)
	xor $t3, $t1, $t2
	sw $t3, ($a2)
	addi $a2, $a2, 4
	addi $t0, $t0, 1
	addi $s0, $s0, 1
	addi $s1, $s1, 1
	addi $s3, $s3, 1
	blt $t0, 4, Loop3
	la $s2, Disk2
	la $s3, Disk3
	la $a2, Array
	addi $t4, $zero, 0
Loop31:
	lb $t5, ($a2)
	jal HEX
	li $v0, 4
	la $a0, Comma
	syscall
	addi $t4, $t4, 1
	addi $a2, $a2, 4
	blt $t4, 3, Loop31	
	lb $t5, ($a2)
	jal HEX
	li $v0, 4
	la $a0, Message6
	syscall
	li $v0, 4
	la $a0, Message3
	syscall
	addi $t4, $zero, 0
Loop32:
	lb $a0, ($s2)
	li $v0, 11
	syscall
	addi $t4, $t4, 1
	addi $s2, $s2, 1
	blt $t4, 4, Loop32
	addi $t4, $zero, 0
	addi $t5, $zero, 0
	li $v0, 4
	la $a0, Message4
	syscall	
	li $v0, 4
	la $a0, Message3
	syscall	
Loop33:
	lb $a0, ($s3)
	li $v0, 11
	syscall
	addi $t5, $t5, 1
	addi $s3, $s3, 1
	blt $t5, 4, Loop33
	li $v0, 4
	la $a0, Message4
	syscall
	li $v0, 4
	la $a0, Enter
	syscall
	beq $t9, 0, Exit
# Chua het chuoi, xet 6 block tiep theo
Next: 
	addi $s0, $s0, 4	# ky tu tiep theo 
	j Line1		# quay lai in tu dong 1
Exit:	
	li $v0, 4
	la $a0, Message2
	syscall
	li $v0, 50		# Hoi nguoi dung co muon nhap lai ko?
	la $a0, Message7
	syscall
	beq $a0, 0, Yes
	j Exits
# Yes: dua string ve trang thai ban dau de thuc hien lai qua trinh
Yes:	
	la $s0, String
	add $s4, $s0, $t8		# s3: dia chi byte cuoi cung duoc su dung trong string
	li $t1, 0
Again: 
	sb $t1, ($s0)			# set byte o dia chi s0 thanh 0
	nop
	addi $s0, $s0, 1
	beq $s0, $s4, Input
	j Again
Exits:	
	li $v0, 10
	syscall
