# Example toolchain file simulating a cross-compile toolchain using the clang
# compiler for some non-std target environment

set(CMAKE_SYSTEM_NAME x86_64_Baremetal)

set(CMAKE_C_COMPILER clang)
set(CMAKE_CXX_COMPILER clang++)

# Disable the unit test build
set(BUILD_TESTING OFF)

add_compile_options(
    -nostdinc # no cstdio
    -mno-red-zone
    -m64
    -march=westmere
    -mno-3dnow
    -mno-mmx
    -mno-sse
    )

# XXX
# Is this something sane todo?
#
# Link our libc compatibility lib to ALL cmake targets that are going to be
# created later. This allows to transparantly compile for Linux and non-std
# environments and the cmake project does not need to know.
link_libraries(libc::libc)
