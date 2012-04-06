#import "python_ios_unit_tests.h"

#import <Python.h>

@implementation python_ios_unit_tests

- (void)setUp
{
  [super setUp];
  Py_Initialize();
}

- (void)tearDown
{
  Py_Finalize();
  [super tearDown];
}

- (void)testExample
{
  STAssertEquals(0, PyRun_SimpleString("a = 0"), nil);
}

@end
