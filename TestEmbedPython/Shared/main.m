//
//  main.m
//  TestEmbedPython
//
//  Created by N on 4/2/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Python.h>

#import <dlfcn.h>

#import "test_ctypes.h"

extern PyMODINIT_FUNC initxx(void);

int main(int argc, char *argv[]) {
  
  NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

  char* resString;
  float angle;
  
  // customize python through environment variables
  putenv("PYTHONOPTIMIZE=2");
  putenv("PYTHONDONTWRITEBYTECODE=1");      /* no write access in Application Bundle */
  putenv("PYTHONNOUSERSITE=1");
  putenv("PYTHONPATH=.");
  putenv("PYTHONVERBOSE=0");                /* debugging */
  
  NSBundle* bundle = [NSBundle mainBundle];
  NSString * resourcePath = [bundle resourcePath];
  NSLog(@"PythonHome is: %s", (char *)[resourcePath UTF8String]);
  Py_SetPythonHome((char *)[resourcePath UTF8String]);
  chdir((char *)[resourcePath UTF8String]);
  
  PyImport_AppendInittab("xx", initxx);
  Py_Initialize();
  
  PyObject* sys_name = PyString_FromString("sys");
  PyObject* sys = PyImport_Import( sys_name );
  PyObject* platform = PyObject_GetAttrString(sys, "platform");
  PyArg_Parse(platform, "s", &resString);
  
  NSLog( @"Python sys.platform = %@", [NSString stringWithCString:resString encoding:NSASCIIStringEncoding] );
  
  PyObject* math_name = PyString_FromString("math");
  PyObject* math = PyImport_Import( math_name );
  PyObject* degrees = PyObject_GetAttrString(math, "degrees");
  PyObject* args = Py_BuildValue("(f)", 0.0);
  PyObject* result = PyEval_CallObject(degrees, args);
  PyArg_Parse(result, "f", &angle);
  
  NSLog( @"Python math.degrees(0) = %f", angle );

  PyObject* xx_name = PyString_FromString("xx");
  PyObject* xx = PyImport_Import( xx_name );

  PyObject* ctypes = PyImport_ImportModule("ctypes");
  PyObject* ctypes_cdll = PyObject_GetAttrString(ctypes, "cdll");
  PyObject* ctypes_LoadLib = PyObject_GetAttrString(ctypes_cdll, "LoadLibrary");
  PyObject* args_ = Py_BuildValue("(s)", "rtgu2");
  PyObject* dynlib = PyEval_CallObject(ctypes_LoadLib, args_);
  
  // call rtguTestCTypesFn() with ctypes
  
  PyObject* testfn = PyObject_GetAttrString(dynlib, "rtguTestCTypesFn");
  PyErr_Print();
  PyObject* args__ = Py_BuildValue("()");
  PyObject* result_ = PyEval_CallObject(testfn, args__);
  
  PyObject* pName = PyString_FromString("test_ctypes");
  PyObject* pModule = PyImport_Import(pName);
  Py_DECREF(pName);
  
  /*
  printf("%p", dlsym(RTLD_MAIN_ONLY, "Py_SetProgramName"));
  
  PyObject *globals = PyDict_New();
  if (PyDict_GetItemString(globals, "__builtins__") == NULL) {
    if (PyDict_SetItemString(globals, "__builtins__",
                             PyEval_GetBuiltins()) != 0)
      return 1;
  }

  PyObject *val;
  val = PyRun_String("import ctypes", Py_eval_input, globals, 0);
  val = PyRun_String("ctypes.cdll", Py_eval_input, globals, 0);
  val = PyRun_String("ctypes.cdll.LoadLibrary('rtgu2')", Py_eval_input, globals, 0);

  Py_DECREF(globals);
  */
  Py_Finalize();
  
  int retVal = UIApplicationMain(argc, argv, nil, nil);

  [pool release];
  return retVal;
}
