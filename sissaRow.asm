# Tiane Zhu
# Nov 8th, 2015
# Sissa's Reward

main:   addi    $a0,    $zero,  4       # put k in $a0											k = $a0;
        addi    $a1,    $zero,  1       # put 1 in current grains									grains = $a1;
        addi    $v1,    $zero,  0       # tally the total in $v1									sum = $v1;
        #...				
while:  slt     $t7,    $zero,  $a0     # set $t7 if $zero < $a0, 	i.e. 0 is less than k
        beq     $t7,    $zero,  done    # if $t7 is not set, 		i.e. 0 is not less than k, branch taken, go to done	   	while(k>0){
        add     $v1,    $a1,    $v1     # add grains at current level to total grains							sum += $a1;
        sll	$a1,	$a1, 	1     		# double current grains   									a1 = a1 * 2;
        addi		$a0,	$a0,	-1					# decrement $t1											k--;
        j       while                   # one loop finished										}
        #...
done:   addi    $v0,    $zero,  10                      #
        syscall                         # syscall 10 quits
