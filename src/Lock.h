#pragma once

#include "Util.h"

typedef struct
{
    uint64_t __lockFlag;
    uint64_t __RFLAGS;
} Lock;


void lockInit(Lock *this);
void lockAcquire(Lock *this);
void lockRelease(Lock *this);
