#ifndef __SQLPARSER__CREATE_STATEMENT_H__
#define __SQLPARSER__CREATE_STATEMENT_H__

#include "src/sql/SQLStatement.h"

// Note: Implementations of constructors and destructors can be found in statements.cpp.
namespace hsql {
  struct SelectStatement;

  struct ForeignKeyEvent {
    enum ForeignKeyEventType {
      kFKDelete,
      kFKUpdate,
      kFKMatch,
    };
    enum ForeignKeyEventAction {
      kFKSetNull,
      kFKSetDefault,
      kFKCascade,
      kFKRestrict,
      kFKNoAction
    };

    ForeignKeyEvent(ForeignKeyEventType type);
    virtual ~ForeignKeyEvent();

    ForeignKeyEventType type;
    char *match;
    ForeignKeyEventAction action;
  };

  struct ForeignKeyConstraint {
    enum ForeignKeyDeferred {
      kDeferred,
      kNotDeferred,
      kUndefined
    };

    ForeignKeyConstraint(char *table);
    virtual ~ForeignKeyConstraint();

    char *table;
    std::vector<char *> *columns;
    std::vector<ForeignKeyEvent *> *events;
    ForeignKeyDeferred deferred;
  };

  // Represents definition of a column constraint
  struct ColumnConstraint {
    enum ConstraintType {
      PRIMARYKEY,
      NOTNULL,
      UNIQUE,
      DEFAULT,
      AUTOINCREMENT,
      FOREIGNKEY
    };

    ColumnConstraint(ConstraintType type);
    ColumnConstraint(ConstraintType type, Expr *expr);
    ColumnConstraint(ConstraintType type, ForeignKeyConstraint *constraint);
    virtual ~ColumnConstraint();

    ConstraintType type;
    Expr *expr;
    ForeignKeyConstraint *fk;
  };

  // Represents definition of a table column
  struct ColumnDefinition {
    enum DataType {
      UNKNOWN,
      TEXT,
      INTEGER,
      REAL,
      BLOB,
      DATETIME
    };

    ColumnDefinition(char* name, DataType type, std::vector<hsql::ColumnConstraint*>* constraints);
    virtual ~ColumnDefinition();

    char* name;
    DataType type;

    bool isPrimaryKey;
    bool isUnique;
    bool nullable;
    Expr* defaultVal;
    bool isAutoIncrement;
    bool hasTypemod;
    int typemod;
    bool isForeignKey;
    char *referenceTable;
    char *referenceColumn;
    std::vector<ForeignKeyEvent*>* fkEvents;
  };

  enum CreateType {
    kCreateTable,
    kCreateView,
    kCreateIndex,
    kCreateTrigger,
  };

  enum TriggerType {
    kTriggerBefore,
    kTriggerAfter,
    kTriggerInsteadOf
  };

  enum TriggerEvent {
    kTriggerEventDelete,
    kTriggerEventInsert,
    kTriggerEventUpdate
  };

  // Represents SQL Create statements.
  // Example: "CREATE TABLE students (name TEXT, student_number INTEGER, city TEXT, grade DOUBLE)"
  struct CreateStatement : SQLStatement {
    CreateStatement(CreateType type);
    virtual ~CreateStatement();

    //General variables
    CreateType type;
    bool isUnique;       // default: false
    bool isVirtual;      // default: false
    bool isTemporary;    // default: false
    bool ifNotExists;    // default: false
    char* schema;        // default: nullptr
    char* tableName;     // default: nullptr

    // CREATE INDEX variables
    char* indexName;                    // default: nullptr
    std::vector<char*> *indexedColumns; // default: nullptr

    // CREATE TABLE variables
    std::vector<ColumnDefinition*>* columns; // default: nullptr

    // CREATE VIEW variables
    std::vector<char*>* viewColumns;
    SelectStatement* select;

    // CREATE TRIGGER variables
    char *triggerName; // default: nullptr
    TriggerType  triggerType;
    TriggerEvent triggerEvent;
    std::vector<SQLStatement*> *triggerStatementList;
  };

} // namespace hsql

#endif
