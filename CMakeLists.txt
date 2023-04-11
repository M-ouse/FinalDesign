cmake_minimum_required(VERSION 3.1)
project(stool)

set(CMAKE_PREFIX_PATH "/usr/lib/llvm-15/cmake") 
SET(CMAKE_BUILD_TYPE "Debug")
set(CMAKE_EXPORT_COMPILECOMMANDS ON)
set(LLVM_ENABLE_DUMP ON)
set(3rd_party src/third_party)
#set(LLVM_DIR /usr/lib/llvm-12/)

find_package(LLVM REQUIRED CONFIG)
add_definitions(${LLVM_DEFINITIONS})
include_directories(${LLVM_INCLUDE_DIRS})
link_directories(${LLVM_LIBRARY_DIRS})

message(STATUS "LLVM_INCLUDE_DIRS: ${LLVM_INCLUDE_DIRS}")
message(STATUS "3rd_party: ${3rd_party}")

include_directories(${3rd_party})
aux_source_directory (src source)
add_executable(stool ${source})

llvm_map_components_to_libnames(llvm_libs analysis binaryformat bitreader bitstreamreader bitwriter codegen core coroutines coverage demangle dwarflinker extensions filecheck instrumentation interpreter  irreader option  passes profiledata riscvinfo runtimedyld scalaropts support symbolize tablegen textapi transformutils)
message(STATUS "LLVM libs: ${llvm_libs}")
target_link_libraries(stool ${llvm_libs})
add_compile_options(-std=c++14)