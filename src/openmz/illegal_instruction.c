#include "illegal_instruction.h"
#include "user_trap.h"

#define URET_CODE 0x00200073UL
static inline void HandleUret(void)
{
    /* restore trap values and pc */
    Zone* zone = HART.current;
    zone->regs[PC] = zone->uepc;
    zone->ucause = 0;
    zone->uepc = 0;
    zone->utval = 0;
    /* restore trap handling */
    if (zone->ustatus & USTATUS_PIE)
        zone->ustatus |= USTATUS_IE;
    HART.event = EVENT_URET;
}

void HandleIllegalInstruction(uptr mcause, uptr mtval)
{
    if (mtval == URET_CODE) {
        HandleUret();
    } else {
        HandleUserTrap(mcause, mtval);
    }
    // TODO: add CSR instruction emulation
}