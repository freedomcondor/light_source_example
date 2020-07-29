#
# Set minimum required version
#
cmake_minimum_required(VERSION 3.1)

project(srocs-dc CXX)

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

#
# Compile loop function
#
add_subdirectory(loop_functions)

#
# Configure examples
#
configure_file(
  ${CMAKE_SOURCE_DIR}/experiment/builderbot_example_basic.argos.in
  ${CMAKE_BINARY_DIR}/experiment/builderbot_example_basic.argos
  )

configure_file(
  ${CMAKE_SOURCE_DIR}/experiment/builderbot_example_basic.lua
  ${CMAKE_BINARY_DIR}/experiment/builderbot_example_basic.lua)

configure_file(
  ${CMAKE_SOURCE_DIR}/experiment/wall_following.lua
  ${CMAKE_BINARY_DIR}/experiment/wall_following.lua)

configure_file(
  ${CMAKE_SOURCE_DIR}/experiment/example_block_basic.lua
  ${CMAKE_BINARY_DIR}/experiment/example_block_basic.lua
  COPYONLY)

configure_file(
  ${CMAKE_SOURCE_DIR}/experiment/sample_rules.lua
  ${CMAKE_BINARY_DIR}/experiment/sample_rules.lua
  COPYONLY)