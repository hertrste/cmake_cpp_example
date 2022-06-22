cmake_minimum_required(VERSION 3.13)

# A dummy lib that represents some custom libc compatiblity layer in an
# non-std environment.
project(libc CXX)

add_library(libc INTERFACE)
add_library(libc::libc ALIAS libc)

target_include_directories(libc INTERFACE  
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>  
    $<INSTALL_INTERFACE:include>
)

install(TARGETS libc EXPORT libcConfig
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
  RUNTIME DESTINATION lib
  INCLUDES DESTINATION include
  )
install(EXPORT libcConfig
  FILE libcConfig.cmake
  NAMESPACE libc::
  DESTINATION lib/cmake/libc
  )
install(FILES
  include/cstdio
  DESTINATION include
  )

