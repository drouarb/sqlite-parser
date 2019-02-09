#ifndef __SQLPARSER__SELECT_STATEMENT_H__
#define __SQLPARSER__SELECT_STATEMENT_H__

#include "src/sql/SQLStatement.h"
#include "src/sql/Expr.h"
#include "src/sql/Table.h"

namespace hsql {
  // Description of the order by clause within a select statement.
  struct OrderDescription {
    OrderDescription(OrderType type, Expr* expr);
    OrderDescription(OrderType type, Expr* expr, char* collation);
    virtual ~OrderDescription();

    OrderType type;
    Expr* expr;
    char* collation;
  };

  // Description of the limit clause within a select statement.
  struct LimitDescription {
    LimitDescription(Expr *limit, Expr *offset);
    virtual ~LimitDescription();

    Expr *limit;
    Expr *offset;
  };

  // Description of the group-by clause within a select statement.
  struct GroupByDescription {
    GroupByDescription();
    virtual ~GroupByDescription();

    std::vector<Expr*>* columns;
    Expr* having;
  };

  // Representation of a full SQL select statement.
  // TODO: add union_order and union_limit.
  struct SelectStatement : SQLStatement {
    SelectStatement();
    virtual ~SelectStatement();

    TableRef* fromTable;
    bool selectDistinct;
    std::vector<Expr*>* selectList;
    Expr* whereClause;
    GroupByDescription* groupBy;

    SelectStatement* unionSelect;
    std::vector<OrderDescription*>* order;
    LimitDescription* limit;
  };

} // namespace hsql

#endif
