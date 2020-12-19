//
//  DebugAsserts.h
//  CreditCalendar
//
//  Created by Наиль  on 17.07.17.
//  Copyright © 2017 Alef. All rights reserved.
//

#ifndef Debug_CoreAsserts_h
#define Debug_CoreAsserts_h

#include <assert.h>

#define DEBUG_ASSERTS_TRUE(_Cond) \
    assert(_Cond)

#define DEBUG_ASSRTS_FALSE(_Cond) \
    assert(_Cond)

#define DEBUG_ASSERTS_VALID(_Class, _Object) \
    assert([_Object isKindOfClass:[_Class class]])

#define DEBUG_ASSERTS_VALID_PROTOCOL(_Proto, _Object) \
assert([(NSObject*)_Object conformsToProtocol:@ protocol(_Proto)])

#define DEBUG_ASSERTS_NOT_NIL(_Object) \
    assert(_Object)

#define DEBUG_ASSERTS_NIL(_Object) \
    assert(!_Object)

#define DEBUG_ASSERT_MAIN_THREAD \
    assert([NSThread isMainThread])

#define DEBUG_ASSERT_MESSAGE(_Message) \
assert(_Message == NULL)


#endif
