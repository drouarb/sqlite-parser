
#include "src/sql/statements.h"

namespace hsql {

  // ColumnDefinition
  ColumnDefinition::ColumnDefinition(char* name, DataType type, std::vector<hsql::ColumnConstraint*>* constraints) :
    name(name),
    type(type),
    isPrimaryKey(false),
    isUnique(false),
    nullable(true),
    defaultVal(nullptr),
    isAutoIncrement(false),
    hasTypemod(false) {
      for (ColumnConstraint* c : *constraints) {
        switch (c->type) {
          case ColumnConstraint::PRIMARYKEY:
            isPrimaryKey = true;
            isUnique = true;
            nullable = false;
            break;
          case ColumnConstraint::NOTNULL:
            nullable = false;
            break;
          case ColumnConstraint::UNIQUE:
            isUnique = true;
            break;
          case ColumnConstraint::DEFAULT:
            delete(defaultVal);
            defaultVal = c->expr;
            break;
          case ColumnConstraint::AUTOINCREMENT:
            isAutoIncrement = true;
            break;
        }
        delete c;
      }
      delete constraints;
  };

  ColumnDefinition::~ColumnDefinition() {
    free(name);
    delete defaultVal;
  }

  // ColumnConstraint
  ColumnConstraint::ColumnConstraint(ConstraintType type) :
    type(type) {};

  ColumnConstraint::ColumnConstraint(ConstraintType type, Expr *expr) :
    type(type),
    expr(expr) {};

  ColumnConstraint::~ColumnConstraint() { }

  // CreateStatemnet
  CreateStatement::CreateStatement(CreateType type) :
    SQLStatement(kStmtCreate),
    type(type),
    ifNotExists(false),
    schema(nullptr),
    tableName(nullptr),
    indexName(nullptr),
    indexedColumn(nullptr),
    columns(nullptr),
    viewColumns(nullptr),
    select(nullptr),
    triggerName(nullptr),
    triggerStatementList(nullptr) {};

  CreateStatement::~CreateStatement() {
    free(schema);
    free(tableName);
    delete select;
    delete indexName;
    delete indexedColumn;
    delete triggerName;
    delete triggerStatementList;

    if (columns != nullptr) {
      for (ColumnDefinition* def : *columns) {
        delete def;
      }
      delete columns;
    }

    if (viewColumns != nullptr) {
      for (char* column : *viewColumns) {
        free(column);
      }
      delete viewColumns;
    }
  }

  // DeleteStatement
  DeleteStatement::DeleteStatement() :
    SQLStatement(kStmtDelete),
    schema(nullptr),
    tableName(nullptr),
    expr(nullptr) {};

  DeleteStatement::~DeleteStatement() {
    free(schema);
    free(tableName);
    delete expr;
  }

  // DropStatament
  DropStatement::DropStatement(DropType type) :
    SQLStatement(kStmtDrop),
    type(type),
    schema(nullptr),
    name(nullptr) {}

  DropStatement::~DropStatement() {
    free(schema);
    free(name);
  }

  // InsertStatement
  InsertStatement::InsertStatement(InsertType type) :
    SQLStatement(kStmtInsert),
    type(type),
    schema(nullptr),
    tableName(nullptr),
    columns(nullptr),
    values(nullptr),
    select(nullptr) {}

  InsertStatement::~InsertStatement() {
    free(schema);
    free(tableName);
    delete select;

    if (columns != nullptr) {
      for (char* column : *columns) {
        free(column);
      }
      delete columns;
    }

    if (values != nullptr) {
      for (Expr* expr : *values) {
        delete expr;
      }
      delete values;
    }
  }

  //Pragma Statement
  PragmaStatement::PragmaStatement() :
    SQLStatement(kStmtPragma),
    expr(nullptr) {}

  PragmaStatement::~PragmaStatement(){
    delete expr;
  }

  //Alter Statement
  AlterStatement::AlterStatement(hsql::AlterType type) :
    SQLStatement(kStmtAlter),
    alterType(type),
    schema(nullptr),
    tableName(nullptr),
    columnName(nullptr),
    newName(nullptr),
    columnDefinition(nullptr) { }

  AlterStatement::~AlterStatement() {
    delete schema;
    delete tableName;
    delete columnName;
    delete newName;
    delete columnDefinition;
  }
  // SelectStatement.h

  // OrderDescription
  OrderDescription::OrderDescription(OrderType type, Expr* expr) :
    type(type),
    expr(expr),
    collation(nullptr) {}

  OrderDescription::OrderDescription(OrderType type, Expr* expr, char* collation) :
    type(type),
    expr(expr),
    collation(collation) {}


  OrderDescription::~OrderDescription() {
    delete expr;
    delete collation;
  }

  // LimitDescription
  LimitDescription::LimitDescription(Expr *limit, Expr *offset) :
    limit(limit),
    offset(offset) {}

  LimitDescription::~LimitDescription() {
    delete limit;
    delete offset;
  }

  // GroypByDescription
  GroupByDescription::GroupByDescription() :
    columns(nullptr),
    having(nullptr) {}

  GroupByDescription::~GroupByDescription() {
    delete having;

    if (columns != nullptr) {
      for (Expr* expr : *columns) {
        delete expr;
      }
      delete columns;
    }
  }

  // SelectStatement
  SelectStatement::SelectStatement() :
    SQLStatement(kStmtSelect),
    fromTable(nullptr),
    selectDistinct(false),
    selectList(nullptr),
    whereClause(nullptr),
    groupBy(nullptr),
    unionSelect(nullptr),
    order(nullptr),
    limit(nullptr) {};

  SelectStatement::~SelectStatement() {
    delete fromTable;
    delete whereClause;
    delete groupBy;
    delete unionSelect;
    delete limit;

    // Delete each element in the select list.
    if (selectList != nullptr) {
      for (Expr* expr : *selectList) {
        delete expr;
      }
      delete selectList;
    }

    if (order != nullptr) {
      for (OrderDescription* desc : *order) {
        delete desc;
      }
      delete order;
    }
  }

  // UpdateStatement
  UpdateStatement::UpdateStatement() :
    SQLStatement(kStmtUpdate),
    table(nullptr),
    updates(nullptr),
    where(nullptr) {}

  UpdateStatement::~UpdateStatement() {
    delete table;
    delete where;

    if (updates != nullptr) {
      for (UpdateClause* update : *updates) {
        free(update->column);
        delete update->value;
        delete update;
      }
      delete updates;
    }
  }

  // TableRef
  TableRef::TableRef(TableRefType type) :
    type(type),
    schema(nullptr),
    name(nullptr),
    alias(nullptr),
    select(nullptr),
    list(nullptr),
    join(nullptr) {}

  TableRef::~TableRef() {
    free(schema);
    free(name);
    free(alias);

    delete select;
    delete join;

    if (list != nullptr) {
      for (TableRef* table : *list) {
        delete table;
      }
      delete list;
    }
  }

  bool TableRef::hasSchema() const {
    return schema != nullptr;
  }

  const char* TableRef::getName() const {
    if (alias != nullptr) return alias;
    else return name;
  }

  // JoinDefinition
  JoinDefinition::JoinDefinition() :
    left(nullptr),
    right(nullptr),
    condition(nullptr),
    type(kJoinInner) {}

  JoinDefinition::~JoinDefinition() {
    delete left;
    delete right;
    delete condition;
  }

} // namespace hsql
