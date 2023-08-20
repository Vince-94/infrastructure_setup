# GTest Demo

- [GTest Demo](#gtest-demo)
  - [Description](#description)
  - [Set Environment](#set-environment)
    - [Local](#local)
    - [Docker](#docker)
    - [Podman](#podman)
  - [Test Cases](#test-cases)
    - [Example 1: Factorial](#example-1-factorial)
    - [Example 2: Shape](#example-2-shape)
    - [Example 3: Calculator](#example-3-calculator)
    - [Example 4: File Manager](#example-4-file-manager)
  - [Hints](#hints)
    - [C++ test architecture](#c-test-architecture)
    - [Build tools](#build-tools)
  - [Reference](#reference)
  - [Roadmap](#roadmap)

## Description
This repo is intended to give a demo of use cases of unit testing with gtest/gmock.

## Set Environment

### Local

```sh
# install C++ compilers
sudo apt install build-essential clang clang-tidy clang-tools cmake ccache cppcheck
# install gtest, gmock, lcov
sudo apt install libgtest-dev libgmock-dev lcov
```

### Docker

- Pre-requisite: Install docker
  ```sh
  source docker.sh install
  ```

- Build an image
  ```sh
  source docker.sh build
  ```

- Run the container
  ```sh
  source docker.sh run
  ```

### Podman
- Pre-requisite: Install podman
  ```sh
  source podman.sh install
  ```

- Build an image
  ```sh
  source podman.sh build
  ```

- Run the container
  ```sh
  source podman.sh run
  ```


## Test Cases

### Example 1: Factorial
Function that calculates the factorial af an integer.

The test demonstrates:
- TEST macro
- difference between EXPECT_/ASSERT_
  - EXPECT_*(actual_value, matcher) - Asserts that actual_value matches matcher.
  - ASSERT_*(actual_value, matcher) - The same as EXPECT_THAT(actual_value, matcher), except that it generates a fatal failure.
- basic assertions: EXPECT_EQ, EXPECT_NE, EXPECT_EXIT


```sh
# application
g++ -std=c++11 -o main factorial.cpp main.cpp
./main

# test
g++ -std=c++11 -o test_factorial test_factorial.cpp factorial.cpp -lgtest -lgtest_main -pthread -lpthread
./test_factorial
```

Coverage: -g -fprofile-arcs -ftest-coverage
lcov --capture --directory . --output-file coverage.info


### Example 2: Shape
Class to calculate some shapes properties (perimeter, area).

The test demonstrates:
- fixtures
- TEST_F macro

```sh
# application
g++ -std=c++11 -o main main.cpp shape.cpp
./main

# test
g++ -std=c++11 -o test_shape test_shape.cpp shape.cpp -lgtest -lgtest_main -pthread -lpthread
./test_shape
```

### Example 3: Calculator
Class to perform some math operations (add, subtract, multiply, divide).

The test demonstrates how to:
- value-parametrized testing
- TEST_P and INSTANTIATE_TEST_SUITE_P macros
- type-parametrized testing
- TYPED_TEST and TYPED_TEST_SUITE macros

```sh
# application
g++ -std=c++11 -o main main.cpp calculator.cpp
./main

# test
g++ -std=c++11 -o test_calculator test_calculator.cpp calculator.cpp -lgtest -lgtest_main -pthread -lpthread
./test_calculator
```


### Example 4: File Manager
Class to handle files (existance, creating, deleting).

The test demonstrates how to
- mock object
  ```sh
  MOCK_METHOD(return_type, member_function, (parameters), (override));
  MOCK_METHOD(return_type, member_function, (parameters), (const, override));
  ```
- assertion: EXPECT_CALL
- matchers:
  - wildcard
    - `EXPECT_*(actual_value, _)` - wildcard
    - `EXPECT_*(actual_value, A\<int>())` - wildcard by type
  - comparison:
      - `EXPECT_*(actual_value, Ge(value))` - actual value is "greater or equal" than value
  - floating point
  - string
  - function/functors/callback
  - ...

```sh
# application
g++ -std=c++11 -o main main.cpp file_manager.cpp
./main

# test
g++ -std=c++11 -o test_file_manager test_file_manager.cpp file_manager.cpp -lgtest -lgmock -lgtest_main -pthread -lpthread
./test_file_manager
```


## Hints

### C++ test architecture

```sh
project_root/
├── include/
│   ├── project_name/
│   │   ├── module1.hpp
│   │   ├── module2.hpp
│   │   └── ...
├── src/
│   ├── module1.cpp
│   ├── module2.cpp
│   └── ...
├── tests/
│   ├── test_module1.cpp
│   ├── test_module2.cpp
│   └── ...
├── main.cpp
├── CMakeLists.txt
└── README.md
```

### Build tools
1. **GNU Make** (OLD): the old Makefile fashion:
   - imperative
   - manual dependencies management
   - restricted abstration
   - restricted to Unix-like system

    <br/>

    *Makefile*
    ```makefile
    CC = g++
    CFLAGS = -Wall

    all: my_app

    my_app: main.cpp my_lib.cpp
        $(CC) $(CFLAGS) -o $@ $^
    ```

    Build command:
    ```sh
    make
    ```

2. **CMake**: based on GNU Make, but using CMakeLists.txt allowing to manage larger and more complex projects:
   - imperative
   - automated dependencies management
   - wider abstraction
   - cross platform

    <br/>

    *CMakeLists.txt*
    ```makefile
    cmake_minimum_required(VERSION 3.10)
    project(my_app)

    set(CMAKE_CXX_STANDARD 11)

    add_executable(my_app main.cpp my_lib.cpp)
    ```

    Build command:
    ```sh
    mkdir build
    cd build
    cmake ..
    make
    ```

    Run all the tests:
    ```sh
    export GTEST_COLOR=1
    ctest -V
    ```

3. **Bazel**: Google build system with the aim of scalability and reproducibility.
   - declarative
   - highly scalable
   - hermetic build (build environment is consistent and predictable)
   - language agnostic (C++, Python, ...)
   - build optimization (caching and parallelization)

    <br/>

    *BUILD*
    ```bazel
    cc_binary(
        name = "my_app",
        srcs = ["main.cpp", "my_lib.cpp"],
    )
    ```

    Build command:
    ```sh
    bazel build :myapp
    ```


## Reference
- http://google.github.io/googletest/
- [CMake documentation](https://cmake.org/)
- [CMake with gtest](http://google.github.io/googletest/quickstart-cmake.html)
- [Bazel introuction](https://www.youtube.com/watch?v=vEQQ9QOVpdU&pp=ugMICgJpdBABGAHKBQxiYXplbCB4YXZpZXI%3D)
- [Bazel with gtest](http://google.github.io/googletest/quickstart-bazel.html)
- [Adaptive AUTOSAR](https://www.asam.net/index.php?eID=dumpFile&t=f&f=803&token=05bcecdd409e084e9828eeb3e977e0bb78d2f229)



## Roadmap
- [x] include in example 2 an EXPECT_THROW
- [x] build with CMake
  - [x] run test at once
  - [ ] divide CMAkeLists for each pkg
- [x] add test to join test 2 and 3 (including libs)
- [ ] build with Bazel
