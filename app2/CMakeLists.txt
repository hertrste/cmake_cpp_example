cmake_minimum_required(VERSION 3.13)
project(MyApp2 CXX)

project(MyApp2 CXX)
add_executable(MyApp2 main.cpp)

find_package(A REQUIRED)
find_package(B REQUIRED)
find_package(C REQUIRED)
find_package(D REQUIRED)

target_link_libraries(MyApp2
  A::A
  B::B
  )
install(TARGETS MyApp2 DESTINATION bin)
