#ifndef SQLITEPARSER_ALTERSTATEMENT_H
#define SQLITEPARSER_ALTERSTATEMENT_H

#include "src/sql/CreateStatement.h"

namespace hsql {
  enum AlterType {
    kAlterRenameTable,
    kAlterRenameColumn,
    kAlterAddColumn
  };

  struct AlterStatement : SQLStatement {
    AlterStatement(AlterType type);
    virtual ~AlterStatement();

    AlterType alterType;
    char *schema;
    char *tableName;
    char *columnName;
    char *newName;
    ColumnDefinition *columnDefinition;
  };
}

#endif //SQLITEPARSER_ALTERSTATEMENT_H
