/**
 * Copyright 2020, Saab AB
 *
 * This software may be distributed and modified according to 
 * the terms of the GNU General Public License version 2. 
 * Note that NO WARRANTY is provided.
 * See "LICENSE.GPLv2" for details.
 */
#include "macro.h"
.section .text.init
.globl _start
_start:
    /* initialize global pointer */
    .option push
    .option norelax
    la      gp, __global_pointer$
    .option pop
    /* initialize kernel sp */
    la      sp, _sp

    /* relocated data segment if required */
    la      t0, _data_src_start
    la      t1, _data_dst_start
    la      t2, _data_dst_end

    beq     t0, t1, 2f
1:  bge     t1, t2, 2f
    lw      a0, 0(t0)
    addi    t0, t0, 4 
    sw      a0, 0(t1)
    addi    t1, t1, 4 
    j       1b
2:

    /* start the kernel */
    csrwi   mscratch, 0     /* mscratch == 0 means kernel mode */
    la      t0, __hang      /* set hang as default trap vector */ 
    csrw    mtvec, t0       
    call    KernelInit      /* call the kernel entry function */

    /* we reach this only if error in kernel */
__hang:
    ebreak
    j       __hang
