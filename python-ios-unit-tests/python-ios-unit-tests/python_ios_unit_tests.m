#import "python_ios_unit_tests.h"

#import <Python.h>

@implementation python_ios_unit_tests

- (void)setUp
{
  [super setUp];
  
  // Change the executing path to YourApp
  chdir("YourApp");
  
  // Special environment to prefer .pyo, and don't write bytecode if .py are found
  // because the process will not have write attribute on the device.
  putenv("PYTHONOPTIMIZE=2");
  putenv("PYTHONDONTWRITEBYTECODE=1");
  putenv("PYTHONNOUSERSITE=1");
  putenv("PYTHONPATH=.");
  putenv("PYTHONVERBOSE=1");
  
  // get the bundle for current unit test, NB not the same as application
  NSBundle* bundle = [NSBundle bundleForClass:[self class]];
  
  NSString * resourcePath = [bundle resourcePath];
  NSLog(@"PythonHome is: %s", (char *)[resourcePath UTF8String]);
  Py_SetPythonHome((char *)[resourcePath UTF8String]);
  
  // modules will be found in $PYTHONHOME/lib/python27.zip
  
  NSLog(@"Initializing python");
  Py_Initialize();
  //PySys_SetArgv(argc, argv);
  
  PyEval_InitThreads();
}

- (void)tearDown
{
  Py_Finalize();
  [super tearDown];
}

- (void)testRunSimpleString
{
  STAssertEquals(0, PyRun_SimpleString("a = 0"), nil);
}

- (void)testImportStaticModule
{
  PyObject* module = PyImport_ImportModule("math");
  
  if (module == NULL)
  {
    STFail(@"Failed to import 'math' module");
  }
  else
  {
    Py_DecRef(module);
  }
}

- (void)testImportPythonModule
{
  PyObject* module = PyImport_ImportModule("traceback");
  
  if (module == NULL)
  {
    STFail(@"Failed to import 'traceback' module");
  }
  else
  {
    Py_DecRef(module);
  }
}

@end
