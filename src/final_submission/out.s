.text
.globl main
main:
  jal L0
  li $v0,10
  syscall
.data
G0:
   .word 0
.text
.data
G1:
   .word 0
.text
Lgetchar: 
   li $v0,12
   syscall
   jr $ra 
Lprints: 
   li $v0,4
   syscall
   jr $ra 
Lprinti: 
   li $v0,1
   syscall
   jr $ra 
Lhalt: 
   li $v0,10
   syscall
   jr $ra 
Lprintb: 
   li $v0,1
   syscall
   jr $ra 
Lprintc: 
   li $v0,11
   syscall
   jr $ra 
  lw $s7,G0
L0: # main
  addi $sp,$sp,-12
  sw $ra,0($sp)
  lw $s5,4($sp)
  lw $s4,G0
  li $s3,123
L1: # =
  sw $s3,G0
  lw $s2,4($sp)
  li $s1,456
L2: # =
  sw $s1,4($sp)
  lw $s0,G1
  li $t9,789
L3: # =
  sw $t9,G1
  lw $t8,G0
  lw $t7,4($sp)
  lw $t6,G1
  li $t5,42
L4: # =
  sw $t5,G1
L5: # =
  lw $t4,G1
  sw $t4,4($sp)
L6: # =
  lw $t3,4($sp)
  sw $t3,G0
  lw $t2,8($sp)
  lw $t1,8($sp)
  li $t0,10
L7: # =
  sw $t0,8($sp)
  lw ,G0
  move $a0,
  jal Lprinti
  lw ,8($sp)
  move $a0,
  jal Lprintc
  lw ,4($sp)
  move $a0,
  jal Lprinti
  lw ,8($sp)
  move $a0,
  jal Lprintc
  lw ,G1
  move $a0,
  jal Lprinti
  lw ,8($sp)
  move $a0,
  jal Lprintc
  lw $ra,0($sp)
  addi $sp,$sp,12
  jr $ra
  lw ,G1