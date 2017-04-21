#ifndef __SQLPARSER__EXPR_H__
#define __SQLPARSER__EXPR_H__

#include <stdlib.h>
#include <memory>
#include <vector>

namespace hsql {
  struct SelectStatement;

  // Helper function used by the lexer.
  // TODO: move to more appropriate place.
  char* substr(const char* source, int from, int to);

  enum ExprType {
    kExprLiteralFloat,
    kExprLiteralString,
    kExprLiteralInt,
    kExprStar,
    kExprPlaceholder,
    kExprColumnRef,
    kExprFunctionRef,
    kExprOperator,
    kExprSelect
  };

  // Operator types. These are important for expressions of type kExprOperator.
  // Trivial types are those that can be described by a single character e.g:
  // + - * / < > = %
  // Non-trivial are: <> <= >= LIKE ISNULL NOT
  enum OperatorType {
    kOpNone,

    // Ternary operators
    kOpBetween,
    kOpCase,

    // Binary operators.
    // Simple operators are identified by the opChar field (e.g. +, -, =, >, <).
    kOpSimple,

    kOpNotEquals,
    kOpLessEq,
    kOpGreaterEq,
    kOpLike,
    kOpNotLike,
    kOpAnd,
    kOpOr,
    kOpIn,

    // Unary operators.
    kOpNot,
    kOpMinus,
    kOpIsNull,
    kOpExists
  };

  typedef struct Expr Expr;

  // Represents SQL expressions (i.e. literals, operators, column_refs).
  // TODO: When destructing a placeholder expression, we might need to alter the placeholder_list.
  struct Expr {

    Expr(ExprType type);
    virtual ~Expr();

    ExprType type;

    // TODO: Replace expressions by list.
    Expr* expr;
    Expr* expr2;
    std::vector<Expr*>* exprList;
    SelectStatement* select;
    char* name;
    char* table;
    char* alias;
    float fval;
    int64_t ival;
    int64_t ival2;

    OperatorType opType;
    char opChar;
    bool distinct;


    // Convenience accessor methods.

    bool isType(ExprType exprType) const;

    bool isLiteral() const;

    bool hasAlias() const;

    bool hasTable() const;

    const char* getName() const;

    bool isSimpleOp() const;

    bool isSimpleOp(char op) const;


    // Static constructors.

    static Expr* makeOpUnary(OperatorType op, Expr* expr);

    static Expr* makeOpBinary(Expr* expr1, char op, Expr* expr2);

    static Expr* makeOpBinary(Expr* expr1, OperatorType op, Expr* expr2);

    static Expr* makeBetween(Expr* expr, Expr* left, Expr* right);

    static Expr* makeCase(Expr* expr, Expr* then, Expr* other);

    static Expr* makeLiteral(int64_t val);

    static Expr* makeLiteral(double val);

    static Expr* makeLiteral(char* val);

    static Expr* makeColumnRef(char* name);

    static Expr* makeColumnRef(char* table, char* name);

    static Expr* makeFunctionRef(char* func_name, std::vector<Expr*>* exprList, bool distinct);

    static Expr* makePlaceholder(int id);

    static Expr* makeSelect(SelectStatement* select);

    static Expr* makeExists(SelectStatement* select);

    static Expr* makeInOperator(Expr* expr, std::vector<Expr*>* exprList);

    static Expr* makeInOperator(Expr* expr, SelectStatement* select);
  };

// Zero initializes an Expr object and assigns it to a space in the heap
// For Hyrise we still had to put in the explicit NULL constructor
// http://www.ex-parrot.com/~chris/random/initialise.html
// Unused
#define ALLOC_EXPR(var, type) 		\
	Expr* var;						\
	do {							\
		Expr zero = {type};			\
		var = (Expr*)malloc(sizeof *var);	\
		*var = zero;				\
	} while(0);
#undef ALLOC_EXPR


} // namespace hsql

#endif