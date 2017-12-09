# https://github.com/hyrise/sql-parser/blob/master/src/parser/keywordlist_generator.py
# Modified by Adam Yi.

import math

with open("sqlite_keywords.txt", 'r') as fh:
    keywords = [line.strip() for line in fh.readlines() if not line.strip().startswith("//") and len(line.strip()) > 0]
    keywords = sorted(set(keywords)) # Sort by name
    keywords = sorted(keywords, key=lambda x: len(x), reverse=True) # Sort by length

    #################
    # Flex

    max_len = len(max(keywords, key=lambda x: len(x))) + 1

    for keyword in keywords:
        len_diff = (max_len) - len(keyword)
        tabs = ''.join([' ' for _ in range(len_diff)])
        print "%s%sTOKEN(%s)" % (keyword, tabs, keyword)

    #
    #################


    #################
    # Bison
    line = "%token"
    max_len = 60

    print "/* SQL Keywords */"
    for keyword in keywords:

        if len(line + " " + keyword) > max_len:
            print line
            line = "%token " + keyword
        else:
            line = line + " " + keyword
    print line

    #
    #################
