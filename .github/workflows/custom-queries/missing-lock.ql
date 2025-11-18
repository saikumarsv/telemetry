// This query detects missing lock patterns in C/C++ code.
// Specifically, it identifies cases where `pthread_mutex_lock` is called
// without a corresponding `pthread_mutex_unlock`.

import cpp

predicate MissingUnlock(FunctionCall lockCall, FunctionCall unlockCall) {
  lockCall.getTarget().hasName("pthread_mutex_lock") and
  unlockCall.getTarget().hasName("pthread_mutex_unlock") and
  lockCall.getEnclosingFunction() = unlockCall.getEnclosingFunction() and
  lockCall.getArgument(0) = unlockCall.getArgument(0)
}

from FunctionCall lockCall
where
  lockCall.getTarget().hasName("pthread_mutex_lock") and
  not exists(FunctionCall unlockCall | MissingUnlock(lockCall, unlockCall))
select lockCall, "This lock is not followed by an unlock."