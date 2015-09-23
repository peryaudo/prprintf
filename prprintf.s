	.text
.globl _prsnprintf
_prsnprintf:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$12, %esp
	
	movl	8(%ebp), %edi	# result buffer
	movl	16(%ebp), %esi	# format string

	movl	$1, 0(%esp)	# 0(esp): current argument index
	# 4(esp): tmp
	# 8(esp): tmp

	# al: read value
	# dl: written value
	# ecx: number of bytes written

	xor	%ecx, %ecx
loop:
	# Goto end if %ecx >= 12(%ebp)
	cmpl	12(%ebp), %ecx
	jge	end

	movb	(%esi), %al
	incl	%esi
	testb	%al, %al
	je	end

	cmpb	$37, %al
	je	percent

	movb	%al, %dl
	call	append
	jmp	loop

percent:
	movb	(%esi), %al
	incl	%esi
	testb	%al, %al
	je	end

percent_percent:
	cmpb	$37, %al
	jne	percent_s
	movb	%al, %dl
	call	append
	jmp	loop

percent_s:
	cmpb	$115, %al
	jne	percent_d
	movl	%esi, 4(%esp)
	movl	0(%esp), %eax
	movl	16(%ebp, %eax, 4), %esi
percent_s_loop:
	movb	(%esi), %al
	incl	%esi
	testb	%al, %al
	je	percent_s_end
	movb	%al, %dl
	call	append
	jmp	percent_s_loop
percent_s_end:
	movl	4(%esp), %esi
	incl	0(%esp)
	jmp	loop

percent_d:
	cmpb	$100, %al
	jne	percent_i

	movl	$10, %ebx
	jmp	percent_num

percent_i:
	cmpb	$105, %al
	jne	percent_x

	movl	$10, %ebx
	jmp	percent_num

percent_x:
	cmpb	$120, %al
	jne	percent_large_x

	movl	$16, %ebx
	jmp	percent_num

percent_large_x:
	cmpb	$88, %al
	jne	percent_u

	movl	$16, %ebx
	jmp	percent_num

percent_u:
	# TODO(peryaudo): implement
	jmp	loop

percent_num:
	movl	0(%esp), %eax
	movl	16(%ebp, %eax, 4), %eax
	movl	%edi, 4(%esp)
	testl	%eax, %eax
	jns	percent_num_loop
	movb	$45, %dl
	call	append
	negl	%eax
	movl	%edi, 4(%esp)
percent_num_loop:
	xorl	%edx, %edx
	divl	%ebx
	cmpl	$10, %edx
	jl	percent_num_less_than_ten
	addl	$39, %edx
percent_num_less_than_ten:
	addl	$48, %edx
	call	append
	testl	%eax, %eax
	jne	percent_num_loop
percent_num_end:
	incl	0(%esp)

	movl	4(%esp), %eax
	movl	%esi, 4(%esp)
	movl	%edi, 8(%esp)
	movl	%eax, %esi
	decl	%edi
percent_num_reverse:
	# Goto end if %edi < %esi
	cmpl	%esi, %edi
	jl	percent_num_reverse_end
	movb	(%esi), %al
	movb	(%edi), %bl
	movb	%al, (%edi)
	movb	%bl, (%esi)
	decl	%edi
	incl	%esi
	jmp	percent_num_reverse
percent_num_reverse_end:
	movl	4(%esp), %esi
	movl	8(%esp), %edi
	jmp	loop

end:
	movl	%ecx, %eax

	movb	$0, %dl
	call	append

	leave
	ret

append:
	# Goto end if %ecx >= 12(%ebp)
	cmpl	12(%ebp), %ecx
	jge	append_end

	movb	%dl, (%edi)
	incl	%ecx
	incl	%edi
append_end:
	ret
