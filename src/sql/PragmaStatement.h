#ifndef SQLITEPARSER_PRAGMASTATEMENT_H
#define SQLITEPARSER_PRAGMASTATEMENT_H

#include "src/sql/SQLStatement.h"

namespace hsql {
  enum PragmaType {
    kPragmaFunction,
    kPragmaSetValue
  };

  struct PragmaStatement : SQLStatement {
    PragmaStatement();
    virtual ~PragmaStatement();

    PragmaType type;
    Expr *expr;
  };
}

#endif //SQLITEPARSER_PRAGMASTATEMENT_H
