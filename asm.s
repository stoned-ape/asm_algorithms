// declare symbols for the linker
.global _power
.global _fac
.global _exp
.global _merge_sort
.global _exp2
.global _log

// Written by Mark.
// x86_64 macOS X
// ATT Syntax
// System V calling convention
// regs rax,rbx,rcx,rdx,rsi,rdi,rsp,rbp,r8,r9,r10,...,r15
// float regs xmm0,...,xmm15
// args 1:rdi,2:rsi,3:rdx,4:rcx,5:r8,6:r9,7:16(%rbp),8:24(%rbp),...
// float args 1:xmm0,...,8:xmm7
// callee saved regs rbx,rbp,r12,...,r15
// return rax
// float return xmm0




//double _exp(double x){
//    double s=1;
//    double a=1;
//    for(double n=1;n<100;n++){
//        a/=n;
//        a*=x;
//        s+=a;
//    }
//    return s;
//}

// where: s=xmm0; a=xmm1; x=xmm2; n=xmm3; xmm4=100.0; xmm5=1.0;

_exp:    // double exp(double xmm0);
    pushq %rbp
    movq %rsp,%rbp
    pushq %rax
    subq $40,%rsp
    // save float registers
    movsd %xmm1,32(%rsp)
    movsd %xmm2,24(%rsp)
    movsd %xmm3,16(%rsp)
    movsd %xmm4, 8(%rsp)
    movsd %xmm5,  (%rsp)
    movq %xmm0,%xmm2
    movq $1,%rax
    cvtsi2sdq %rax,%xmm5
    movsd %xmm5,%xmm0
    movsd %xmm5,%xmm1
    movsd %xmm5,%xmm3
    movq $400,%rax
    cvtsi2sdq %rax,%xmm4
_exp.for:
    comisd %xmm4,%xmm3
    jle _exp.endfor
    divsd %xmm3,%xmm1
    mulsd %xmm2,%xmm1
    addsd %xmm1,%xmm0
    addsd %xmm5,%xmm3
    jmp _exp.for
_exp.endfor:
    // restore float registers
    movsd 32(%rsp),%xmm1
    movsd 24(%rsp),%xmm2
    movsd 16(%rsp),%xmm3
    movsd  8(%rsp),%xmm4
    movsd   (%rsp),%xmm5
    addq $40,%rsp
    popq %rax
    popq %rbp
    ret




//double log(double x){
//    if(x<=0) return 0./0.;
//    double sgn=1;
//    if(x>1){
//        x=1/x;
//        sgn=-1;
//    };
//    x-=1;
//    double s=0;
//    double p=x;
//    for(double n=1;n<100;n++){
//        double t=sgn*p/n;
//        s+=t;
//        p*=x;
//        sgn*=-1;
//    }
//    return s;
//}

// where x=xmm1; s=xmm0; p=xmm2; n=xmm3; sgn=xmm4; t=xmm5, xmm6=100, xmm7=-1.0

_log:   // double log(double xmm0);
    pushq %rbp
    movq %rsp,%rbp
    pushq %rax
    pushq %rbx
    subq $64,%rsp
    // save float registers
    movsd %xmm1,48(%rsp)
    movsd %xmm2,40(%rsp)
    movsd %xmm3,32(%rsp)
    movsd %xmm4,24(%rsp)
    movsd %xmm5,16(%rsp)
    movsd %xmm6, 8(%rsp)
    movsd %xmm7,  (%rsp)
    movsd %xmm0,%xmm1
    movq $0,%rax
    cvtsi2sdq %rax,%xmm0
    ucomisd %xmm0,%xmm1
    jbe _log.if1
    jmp _log.endif1
_log.if1:
    divsd %xmm0,%xmm0
    jmp _log.return
_log.endif1:
    movq $1,%rax
    cvtsi2sdq %rax,%xmm0
    movsd %xmm0,%xmm4
    ucomisd %xmm0,%xmm1
    jae _log.if2
    jmp _log.endif2
_log.if2:
    divsd %xmm1,%xmm0
    movsd %xmm0,%xmm1
    movq $-1,%rax
    cvtsi2sdq %rax,%xmm4
_log.endif2:
    movq $1,%rax
    cvtsi2sdq %rax,%xmm6
    subsd %xmm6,%xmm1
    movsd %xmm6,%xmm3
    movsd %xmm1,%xmm2
    movq $0,%rax
    cvtsi2sdq %rax,%xmm0
    movq $400,%rax
    cvtsi2sdq %rax,%xmm6
    movq $-1,%rax
    cvtsi2sdq %rax,%xmm7
_log.for:
    comisd %xmm6,%xmm3
    jle _log.endfor
    movsd %xmm2,%xmm5
    divsd %xmm3,%xmm5
    mulsd %xmm4,%xmm5
    addsd %xmm5,%xmm0
    mulsd %xmm1,%xmm2
    mulsd %xmm7,%xmm4
    subsd %xmm7,%xmm3
    jmp _log.for
_log.endfor:
_log.return:
    // restore float registers
    movsd 48(%rsp),%xmm1
    movsd 40(%rsp),%xmm2
    movsd 32(%rsp),%xmm3
    movsd 24(%rsp),%xmm4
    movsd 16(%rsp),%xmm5
    movsd  8(%rsp),%xmm6
    movsd   (%rsp),%xmm7
    addq $64,%rsp
    popq %rbx
    popq %rax
    popq %rbp
    ret
    

_merge_sort:                    // void merge_sort(long *rdi,long rsi){
    pushq %rbp
    movq %rsp,%rbp
    /// callee saved registers
    pushq %rbx
    pushq %r12
    pushq %r13
    pushq %rax

    cmp $1,%rsi
    jle endsort                 // if(rsi<=1) return;
   
    movq %rsi,%rax              // long rax=rsi;
    movq $2,%rbx                // long rbx=2;
    xor %rdx,%rdx               // long rdx=0;
    idivq %rbx                  // rax/=rbx;
    pushq %rsi                  // long tmp0=rsi;
    pushq %rdi
    movq %rax,%rsi              // rsi=rax;
    call _merge_sort            // _merge_sort(rdi,rsi)
    popq %rdi
    popq %rsi                   // rsi=tmp0;
       
    pushq %rsi                  // tmp0=rsi;
    pushq %rdi
    subq %rax,%rsi              // rsi-=rax;
    leaq (%rdi,%rax,8),%rdi     // rdi+=8*rax;
    call _merge_sort            // _merge_sort(rdi,rsi);
    popq %rdi
    popq %rsi                   // rsi=tmp0;
   
    leaq (,%rsi,8),%rbx         // rbx=8*rsi;
    sub %rbx,%rsp
    movq %rsp,%r8               // long *r8=new long[rsi];
   
    xor %r9,%r9                 // long r9=0;
    xor %r10,%r10               // long r10=0;

    leaq (%rdi,%rax,8),%rdx     // long *rdx=&rdi[rax]
    
    xorq %rcx,%rcx              // long rcx=0;
for:                            // for(long rcx=0;rcx<rsi;rdx++){
    cmp %rsi,%rcx
    jge endfor                  // rcx<rsi;

    movq (%rdi,%r9,8),%r12      // long r12=rdi[r9];
    movq (%rdx,%r10,8),%r13     // long r13=rdx[r10];
    cmp %r13,%r12
    jl test3                    // r12<r13
test2:
    pushq %rsi                  // long tmp=rsi;
    subq %rax,%rsi              // rsi-=rax;
    cmp %rsi,%r10
    popq %rsi                   // rsi=tmp
    jge test3                   // r10>=rax
    jmp else
test3:
    cmp %rax,%r9
    jl if                       // r9<rax

    jmp else
    if:                         // if((rdi[r9]<rdx[r10] ||  r10>=rsi-rax) && r9<rax){
        movq (%rdi,%r9,8),%r11
        movq %r11,(%r8,%rcx,8)  // r8[rcx]=rdi[r9];
        inc %r9                 // r9++;
        jmp endif
    else:                       // }else{
        movq (%rdx,%r10,8),%r11
        movq %r11,(%r8,%rcx,8)  // r8[rcx]=rdx[r10];
        inc %r10                // r10++;
    endif:                      // }
   
    inc %rcx                    // rcx++
    jmp for
endfor:                         // }
   
    xorq %rcx,%rcx              // long rcx=0;
for1:                           // for(long rcx=0;rcx<rsi;rdx++);
    cmp %rsi,%rcx
    jge endfor1                 // rcx<rsi;
   
    movq (%r8,%rcx,8),%r11
    movq %r11,(%rdi,%rcx,8)     // rdi[rcx]=r8[rcx]
       
    inc %rcx                    // rcx++
    jmp for1
endfor1:                        // }
    add %rbx,%rsp               // free(r8);
endsort:
    popq %rax
    popq %r13
    popq %r12
    popq %rbx
    popq %rbp
    ret                         // return; }



_fac:                    // double fac(long rdi){
    pushq %rbp
    mov %rsp,%rbp
    movq $1,%rax         // long rax=1;
    movq $1,%rcx         // long rcx=1;
head1:                   // for(long rcx=1;rcx<=rdi;rcx++){
    cmp %rcx,%rdi
    jl end1              // rcx<=rdi;
    imulq %rcx,%rax      // rax*=rcx;
    inc %rcx             // rcx++
    jmp head1
end1:                    // }
    cvtsi2sdq %rax,%xmm0 // double xmm0=(double)rax
    popq %rbp
    ret                  // return xmm0; }




_power:               // double power(double xmm0,long rdi){
    pushq %rbp
    mov %rsp,%rbp
    sub $8,%rsp
    movsd %xmm1,(%rsp)
    
    movsd %xmm0,%xmm1 // double xmm1=xmm0;
    mov $4607182418800017408,%rax
    pushq %rax
    movsd (%rsp),%xmm0// xmm0=1.0;
    addq $8,%rsp
    
    xor %rcx,%rcx     // long rcx=0
head0:                // for(long rcx=0;rcx<rdi;rcx++){
    cmp %rcx,%rdi
    jle end0          // rcx<rdi
 
    mulsd %xmm1,%xmm0 // xmm0*=xmm1;
     
    inc %rcx          // rcx++
    jmp head0
end0:                 // }
    movsd (%rsp),%xmm1
    add $8,%rsp
    popq %rbp
    ret               // return xmm0; }
    








// terrible way to compute exponentials
_exp2:                 // double exp2(double xmm0);
    pushq %rbp
    mov %rsp,%rbp

    movsd %xmm0,%xmm1  // double xmm1=xmm0;

    movq $0,%rax
    pushq %rax
    movsd (%rsp),%xmm2 // double xmm2=0.0; /// sum accumulator
    addq $8,%rsp

    movq $0,%rcx       // long rcx=0;  /// loop iterator
head2:                 // for(long rcx=0;rcx<21;rcx++){
    cmpq $21,%rcx
    jge end2           // rcx<21;

    movsd %xmm1,%xmm0  // double xmm0=xmm1;
    movq %rcx,%rdi     // long rdi=rcx;
    pushq %rcx
    call _power
    popq %rcx
    movsd %xmm0,%xmm3  // double xmm3=power(xmm0,rdi);

    movq %rcx,%rdi     // rdi=rcx;
    pushq %rcx
    call _fac
    popq %rcx
    movsd %xmm0,%xmm4  // double xmm4=fac(rdi);

    divsd %xmm4,%xmm3  // xmm3/=xmm4;
    addsd %xmm3,%xmm2  // xmm2+=xmm3;

    inc %rcx           // rcx++
    jmp head2
end2:                  // }
    movsd %xmm2,%xmm0  // xmm0=xmm2;
    popq %rbp
    ret                // return xmm0; }

