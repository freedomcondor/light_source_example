#
# Set the path additional cmake files must be searched for
#
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CMAKE_SOURCE_DIR}/cmake)

#
# Set build options, set flags, check libraries
#
include(${CMAKE_SOURCE_DIR}/cmake/ARGoSBuildOptions.cmake)
include(${CMAKE_SOURCE_DIR}/cmake/ARGoSBuildFlags.cmake)
include(${CMAKE_SOURCE_DIR}/cmake/ARGoSBuildChecks.cmake)

# Set up ARGoS compilation information
include_directories(BEFORE ${CMAKE_SOURCE_DIR})

add_library(dc_srocs_loop_functions MODULE
   dc_srocs_loop_functions.h
   dc_srocs_loop_functions.cpp)

target_link_libraries(dc_srocs_loop_functions
   ${SROCS_ENTITIES_LIBRARY})

