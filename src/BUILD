load("//tools:build_rules/lexyacc.bzl", "genlex", "genyacc")

genyacc(
    name = "bison",
    src = "parser/bison_parser.y",
    out = "parser/bison_parser.cpp",
    hdr = "parser/bison_parser.h",
)

genlex(
    name = "lexer",
    src = "parser/flex_lexer.l",
    out = "parser/flex_lexer.cpp",
    hdr = "parser/flex_lexer.h",
)

cc_library(
    name = "parser",
    srcs = [
        ":lexer",
        ":bison",
    ],
    hdrs = glob([
        ":lexer",
        ":bison",
        "**/*.h",
    ]),
)

cc_library(
    name = "sql",
    srcs = glob(["sql/*.cpp"]),
    hdrs = glob(["sql/*.h"]),
)

cc_library(
    name = "main",
    srcs = glob(["*.cpp"]),
    hdrs = glob(["**/*.h"]),
    deps = [
        ":parser",
        ":sql",
    ],
    visibility = ["//visibility:public"],
)

cc_library(
    name = "helper",
    srcs = ["util/sqlhelper.cpp"],
    hdrs = glob(["**/*.h"]),
    visibility = ["//visibility:public"],
)
