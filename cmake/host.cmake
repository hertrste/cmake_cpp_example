# Example toolchain file simulating a host toolchain e.g. for unit tests

set(CMAKE_SYSTEM_NAME Linux)

add_compile_options(
    -Wno-format-security
)
