/*
Copyright (c) 2002 Peter O'Gorman <ogorman@users.sourceforge.net>

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/


/* Just to prove that it isn't that hard to add Mac calls to your code :)
   This works with pretty much everything, including kde3 xemacs and the gimp,
   I'd guess that it'd work in at least 95% of cases, use this as your starting
   point, rather than the mess that is dlfcn.c, assuming that your code does not
   require ref counting or symbol lookups in dependent libraries
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <stdarg.h>
#include <limits.h>
#include <mach-o/dyld.h>
#include <AvailabilityMacros.h>
#include <dlfcn.h>

//#include "dlfcn_static.h"

void *ctypes_dlopen(const char *path, int mode)
{
    return RTLD_MAIN_ONLY;
}

const char *ctypes_dlerror(void)
{
    return dlerror();
}

int ctypes_dlclose(void *handle)
{
    return dlclose(handle);
}

void *ctypes_dlsym(void *handle, const char *symbol)
{
    void* result = dlsym(handle, symbol);
    return result;
}

int ctypes_dladdr(const void *handle, Dl_info *info) {
    return 0;
}
