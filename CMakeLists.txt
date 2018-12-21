cmake_minimum_required(VERSION 3.4)
project(sqliteparser)

set(CMAKE_CXX_STANDARD 14)

if (${CMAKE_SYSTEM_NAME} STREQUAL "Darwin")
    message("MacOS device, searching in brew path")
    set(BISON_EXECUTABLE "/usr/local/opt/bison/bin/bison" CACHE PATH "Bison executable")
endif ()

file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/src/parser/)

FIND_PACKAGE(BISON 3.0.0 REQUIRED)
SET(BisonOutput ${CMAKE_BINARY_DIR}/parser/bison_parser.c)
BISON_TARGET(bison_parser src/parser/bison_parser.y ${CMAKE_CURRENT_BINARY_DIR}/src/parser/bison_parser.cpp
        DEFINES_FILE ${CMAKE_CURRENT_BINARY_DIR}/src/parser/bison_parser.h)

FIND_PACKAGE(FLEX REQUIRED)
FLEX_TARGET(flex_lexer src/parser/flex_lexer.l ${CMAKE_CURRENT_BINARY_DIR}/src/parser/flex_lexer.cpp
        DEFINES_FILE ${CMAKE_CURRENT_BINARY_DIR}/src/parser/flex_lexer.h)
ADD_FLEX_BISON_DEPENDENCY(flex_lexer bison_parser)

set(sqliteparser_SRCS
        ${BISON_bison_parser_OUTPUTS}
        ${FLEX_flex_lexer_OUTPUTS}
        src/parser/parser_typedef.h
        src/SQLParser.cpp
        src/SQLParser.h
        src/SQLParserResult.cpp
        src/SQLParserResult.h
        src/util/sqlhelper.cpp
        src/util/sqlhelper.h
        src/sql/CreateStatement.h
        src/sql/DeleteStatement.h
        src/sql/DropStatement.h
        src/sql/Expr.cpp
        src/sql/Expr.h
        src/sql/InsertStatement.h
        src/sql/SelectStatement.h
        src/sql/SQLStatement.cpp
        src/sql/SQLStatement.h
        src/sql/statements.cpp
        src/sql/statements.h
        src/sql/Table.h
        src/sql/UpdateStatement.h
        )

message(${sqliteparser_SRCS})

include_directories(${CMAKE_CURRENT_BINARY_DIR})
include_directories(${CMAKE_SOURCE_DIR})

add_library(sqliteparser ${sqliteparser_SRCS})