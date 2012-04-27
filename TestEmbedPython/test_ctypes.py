import ctypes

rtgu2 = ctypes.cdll.LoadLibrary("rtgu2")
rtguTestCTypesFn = rtgu2.rtguTestCTypesFn

print "hello from python."
for i in xrange(65536):
  rtguTestCTypesFn()

print dir(rtgu2)
