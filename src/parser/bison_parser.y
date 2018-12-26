%{
/**
 * bison_parser.y
 * defines bison_parser.h
 * outputs bison_parser.c
 *
 * Grammar File Spec: http://dinosaur.compilertools.net/bison/bison_6.html
 *
 */
/*********************************
 ** Section 1: C Declarations
 *********************************/

#include "src/parser/bison_parser.h"
#include "src/parser/flex_lexer.h"

#include <stdio.h>
#include <string.h>

using namespace hsql;

int yyerror(YYLTYPE* llocp, SQLParserResult* result, yyscan_t scanner, const char *msg) {
	result->setIsValid(false);
	result->setErrorDetails(strdup(msg), llocp->first_line, llocp->first_column);
	return 0;
}

%}
/*********************************
 ** Section 2: Bison Parser Declarations
 *********************************/


// Specify code that is included in the generated .h and .c files
%code requires {
// %code requires block

#include "src/sql/statements.h"
#include "src/SQLParserResult.h"
#include "src/parser/parser_typedef.h"

// Auto update column and line number
#define YY_USER_ACTION \
		yylloc->first_line = yylloc->last_line; \
		yylloc->first_column = yylloc->last_column; \
		for(int i = 0; yytext[i] != '\0'; i++) { \
			yylloc->total_column++; \
			yylloc->string_length++; \
				if(yytext[i] == '\n') { \
						yylloc->last_line++; \
						yylloc->last_column = 0; \
				} \
				else { \
						yylloc->last_column++; \
				} \
		}
}

// Tell bison to create a reentrant parser
%define api.pure full

// Prefix the parser
%define api.prefix {hsql_}
%define api.token.prefix {SQL_}

%define parse.error verbose
%locations

%initial-action {
	// Initialize
	@$.first_column = 0;
	@$.last_column = 0;
	@$.first_line = 0;
	@$.last_line = 0;
	@$.total_column = 0;
	@$.string_length = 0;
};


// Define additional parameters for yylex (http://www.gnu.org/software/bison/manual/html_node/Pure-Calling.html)
%lex-param   { yyscan_t scanner }

// Define additional parameters for yyparse
%parse-param { hsql::SQLParserResult* result }
%parse-param { yyscan_t scanner }


/*********************************
 ** Define all data-types (http://www.gnu.org/software/bison/manual/html_node/Union-Decl.html)
 *********************************/
%union {
	double fval;
	int64_t ival;
	char* sval;
	uintmax_t uval;
	bool bval;

	hsql::SQLStatement* statement;
	hsql::SelectStatement* 	select_stmt;
	hsql::CreateStatement* 	create_stmt;
	hsql::InsertStatement* 	insert_stmt;
	hsql::DeleteStatement* 	delete_stmt;
	hsql::UpdateStatement* 	update_stmt;
	hsql::DropStatement*   	drop_stmt;
	
	hsql::TableName table_name;
	hsql::TableRef* table;
	hsql::Expr* expr;
	hsql::OrderDescription* order;
	hsql::OrderType order_type;
	hsql::LimitDescription* limit;
	hsql::ColumnDefinition* column_t;
	hsql::ColumnConstraint* cconstraint_t;
	hsql::GroupByDescription* group_t;
	hsql::UpdateClause* update_t;

	std::vector<hsql::SQLStatement*>* stmt_vec;

	std::vector<char*>* str_vec;
	std::vector<hsql::TableRef*>* table_vec;
	std::vector<hsql::ColumnDefinition*>* column_vec;
	std::vector<hsql::ColumnConstraint*>* cconstraint_vec;
	std::vector<hsql::UpdateClause*>* update_vec;
	std::vector<hsql::Expr*>* expr_vec;
	std::vector<hsql::OrderDescription*>* order_vec;
}


/*********************************
 ** Descrutor symbols
 *********************************/
%destructor { } <fval> <ival> <uval> <bval> <order_type>
%destructor { free( ($$.name) ); free( ($$.schema) ); } <table_name>
%destructor { free( ($$) ); } <sval>
%destructor {
	if (($$) != nullptr) {
		for (auto ptr : *($$)) {
			delete ptr;
		}
	}
	delete ($$);
} <str_vec> <table_vec> <column_vec> <update_vec> <expr_vec> <order_vec> <stmt_vec>
%destructor { delete ($$); } <*>


/*********************************
 ** Token Definition
 *********************************/
%token <sval> IDENTIFIER STRING
%token <fval> FLOATVAL
%token <ival> INTVAL

/* SQL Keywords */
%token CURRENT_TIMESTAMP AUTOINCREMENT CURRENT_DATE
%token CURRENT_TIME TRANSACTION CONSTRAINT DEFERRABLE
%token REFERENCES EXCLUSIVE IMMEDIATE INITIALLY INTERSECT
%token RECURSIVE SAVEPOINT TEMPORARY CONFLICT DATABASE
%token DEFERRED DISTINCT RESTRICT ROLLBACK ANALYZE BETWEEN
%token BOOLEAN CASCADE COLLATE DEFAULT EXPLAIN FOREIGN
%token INDEXED INSTEAD INTEGER NATURAL NOTNULL PRIMARY
%token REINDEX RELEASE REPLACE TRIGGER VIRTUAL WITHOUT
%token ACTION ATTACH BEFORE COLUMN COMMIT CREATE DELETE
%token DETACH DOUBLE ESCAPE EXCEPT EXISTS HAVING IGNORE
%token INSERT ISNULL OFFSET PRAGMA REGEXP RENAME SELECT
%token UNIQUE UPDATE VACUUM VALUES ABORT AFTER ALTER BEGIN
%token CHECK CROSS FLOAT GROUP INDEX INNER LIMIT MATCH ORDER
%token OUTER QUERY RAISE RIGHT TABLE UNION USING WHERE BLOB
%token CASE CAST DESC DROP EACH ELSE FAIL FROM FULL GLOB
%token INTO JOIN LEFT LIKE LONG NULL PLAN REAL TEMP TEXT
%token THEN VIEW WHEN WITH ADD ALL AND ASC END FOR INT KEY
%token NOT ROW SET AS BY IF IN IS NO OF ON OR TO

/*********************************
 ** Non-Terminal types (http://www.gnu.org/software/bison/manual/html_node/Type-Decl.html)
 *********************************/
%type <stmt_vec>	statement_list
%type <statement> 	statement
%type <select_stmt> select_statement select_with_paren select_no_paren select_clause select_paren_or_clause
%type <create_stmt> create_statement
%type <insert_stmt> insert_statement
%type <delete_stmt> delete_statement
%type <update_stmt> update_statement
%type <drop_stmt>	drop_statement
%type <table_name>  table_name
%type <sval> 		opt_alias alias
%type <bval> 		opt_not_exists opt_exists opt_distinct opt_virtual opt_temporary opt_or_replace
%type <uval>		opt_join_type column_type
%type <table> 		from_clause table_ref table_ref_atomic table_ref_name nonjoin_table_ref_atomic
%type <table>		join_clause table_ref_name_no_alias
%type <expr> 		expr operand scalar_expr unary_expr binary_expr logic_expr exists_expr
%type <expr>		function_expr between_expr expr_alias param_expr
%type <expr> 		column_name literal int_literal num_literal string_literal
%type <expr> 		comp_expr opt_where join_condition opt_having case_expr case_list in_expr hint
%type <expr> 		array_expr array_index null_literal
%type <limit>		opt_limit opt_top
%type <order>		order_desc
%type <order_type>	opt_order_type
%type <column_t>	column_def
%type <cconstraint_t>	column_constraint
%type <update_t>	update_clause
%type <group_t>		opt_group

%type <str_vec>		ident_commalist opt_column_list
%type <expr_vec> 	expr_list select_list literal_list
%type <table_vec> 	table_ref_commalist
%type <order_vec>	opt_order order_list
%type <update_vec>	update_clause_commalist
%type <column_vec>	column_def_commalist
%type <cconstraint_vec>	column_constraint_list column_constraint_list_nullable

/******************************
 ** Token Precedence and Associativity
 ** Precedence: lowest to highest
 ******************************/
%left		OR
%left		AND
%right		NOT
%nonassoc	'=' EQUALS NOTEQUALS LIKE ILIKE
%nonassoc	'<' '>' LESS GREATER LESSEQ GREATEREQ

%nonassoc	NOTNULL
%nonassoc	ISNULL
%nonassoc	IS				/* sets precedence for IS NULL, etc */
%left		'+' '-'
%left		'*' '/' '%'
%left		'^'
%left		CONCAT

/* Unary Operators */
%right  UMINUS
%left		'[' ']'
%left		'(' ')'
%left		'.'
%left   JOIN
%%
/*********************************
 ** Section 3: Grammar Definition
 *********************************/

// Defines our general input.
input:
		statement_list opt_semicolon {
			for (SQLStatement* stmt : *$1) {
				// Transfers ownership of the statement.
				result->addStatement(stmt);
			}

			unsigned param_id = 0;
			for (void* param : yyloc.param_list) {
				if (param != nullptr) {
					Expr* expr = (Expr*) param;
					expr->ival = param_id;
					result->addParameter(expr);
					++param_id;
				}
			}
			delete $1;
		}
	;


statement_list:
		statement {
			$1->stringLength = yylloc.string_length;
			yylloc.string_length = 0;
			$$ = new std::vector<SQLStatement*>();
			$$->push_back($1);
		}
	|	statement_list ';' statement {
			$3->stringLength = yylloc.string_length;
			yylloc.string_length = 0;
			$1->push_back($3);
			$$ = $1;
		}
	;

statement:
		select_statement { $$ = $1; }
	|	create_statement { $$ = $1; }
	|	insert_statement { $$ = $1; }
	|	delete_statement { $$ = $1; }
	|	update_statement { $$ = $1; }
	|	drop_statement { $$ = $1; }
	;

/******************************
 * Create Statement
 * CREATE TABLE students (name TEXT, student_number INTEGER, city TEXT, grade DOUBLE)
 * TODO: CREATE INDEX; CREATE TRIGGER
 ******************************/
create_statement:
		CREATE opt_virtual opt_temporary TABLE opt_not_exists table_name '(' column_def_commalist ')' {
			$$ = new CreateStatement(kCreateTable);
			$$->isVirtual = $2;
			$$->isTemporary = $3;
			$$->ifNotExists = $5;
			$$->schema = $6.schema;
			$$->tableName = $6.name;
			$$->columns = $8;
		}
	|	CREATE VIEW opt_not_exists table_name opt_column_list AS select_statement {
			$$ = new CreateStatement(kCreateView);
			$$->ifNotExists = $3;
			$$->schema = $4.schema;
			$$->tableName = $4.name;
			$$->viewColumns = $5;
			$$->select = $7;
		}
	;

opt_not_exists:
		IF NOT EXISTS { $$ = true; }
	|	/* empty */ { $$ = false; }
	;

opt_virtual:
		VIRTUAL { $$ = true; }
	|	/* empty */ { $$ = false; }
	;

opt_temporary:
		TEMP { $$ = true; }
	|	TEMPORARY { $$ = true; }
	|	/* empty */ { $$ = false; }
	;

column_def_commalist:
		column_def { $$ = new std::vector<ColumnDefinition*>(); $$->push_back($1); }
	|	column_def_commalist ',' column_def { $1->push_back($3); $$ = $1; }
	;

column_def:
		IDENTIFIER column_type column_constraint_list_nullable {
			$$ = new ColumnDefinition($1, (ColumnDefinition::DataType) $2, $3);
		}
	;

column_constraint_list_nullable:
		column_constraint_list  { $$ = $1; }
	|	/* empty */ { $$ = new std::vector <ColumnConstraint*>(); }
	;

column_constraint_list:
		column_constraint  { $$ = new std::vector<ColumnConstraint*>(); $$->push_back($1); }
	|	column_constraint_list column_constraint { $1->push_back($2); $$ = $1; }
	;

column_constraint:
		PRIMARY KEY { $$ = new ColumnConstraint(ColumnConstraint::PRIMARYKEY); }
	|	NOT NULL { $$ = new ColumnConstraint(ColumnConstraint::NOTNULL); }
	|	NOTNULL { $$ = new ColumnConstraint(ColumnConstraint::NOTNULL); }
	|	UNIQUE { $$ = new ColumnConstraint(ColumnConstraint::UNIQUE); }
	|	DEFAULT expr { $$ = new ColumnConstraint(ColumnConstraint::DEFAULT, $2); }
	; // TODO: foreign key; autoincrease


column_type:
		INT { $$ = ColumnDefinition::INTEGER; }
	|	INTEGER { $$ = ColumnDefinition::INTEGER; }
	|	LONG { $$ = ColumnDefinition::INTEGER; }
	|	BOOLEAN { $$ = ColumnDefinition::INTEGER; }
	|	TEXT { $$ = ColumnDefinition::TEXT; }
	|	BLOB { $$ = ColumnDefinition::TEXT; }
	|	REAL { $$ = ColumnDefinition::REAL; }
	|	DOUBLE { $$ = ColumnDefinition::REAL; }
	|	FLOAT { $$ = ColumnDefinition::REAL; }
	;

/******************************
 * Drop Statement
 * DROP TABLE students;
 ******************************/

drop_statement:
		DROP TABLE opt_exists table_name {
			$$ = new DropStatement(kDropTable);
			$$->ifExists = $3;
			$$->schema = $4.schema; $$->name = $4.name;
		}
	|	DROP VIEW opt_exists table_name {
			$$ = new DropStatement(kDropView);
			$$->ifExists = $3;
			$$->schema = $4.schema;
			$$->name = $4.name;
		}
	;

opt_exists:
		IF EXISTS   { $$ = true; }
	|	/* empty */ { $$ = false; }
	;

/******************************
 * Delete Statement
 * DELETE FROM students WHERE grade > 3.0
 * DELETE FROM students 
 ******************************/
delete_statement:
		DELETE FROM table_name opt_where {
			$$ = new DeleteStatement();
			$$->schema = $3.schema;
			$$->tableName = $3.name;
			$$->expr = $4;
		}
	;

/******************************
 * Insert Statement
 * INSERT INTO students VALUES ('Max', 1112233, 'Musterhausen', 2.3)
 * INSERT INTO employees SELECT * FROM stundents
 ******************************/
insert_statement:
		INSERT opt_or_replace INTO table_name opt_column_list VALUES '(' expr_list ')' {
			$$ = new InsertStatement(kInsertValues);
			$$->orReplace = $2;
			$$->schema = $4.schema;
			$$->tableName = $4.name;
			$$->columns = $5;
			$$->values = $8;
		}
	|	INSERT opt_or_replace INTO table_name opt_column_list select_no_paren {
			$$ = new InsertStatement(kInsertSelect);
			$$->orReplace = $2;
			$$->schema = $4.schema;
			$$->tableName = $4.name;
			$$->columns = $5;
			$$->select = $6;
		}
	;

opt_or_replace:
		OR REPLACE { $$ = true; }
	|	/* empty */ { $$ = false; }
	;

opt_column_list:
		'(' ident_commalist ')' { $$ = $2; }
	|	/* empty */ { $$ = nullptr; }
	;


/******************************
 * Update Statement
 * UPDATE students SET grade = 1.3, name='Felix Fürstenberg' WHERE name = 'Max Mustermann';
 ******************************/

update_statement:
	UPDATE table_ref_name_no_alias SET update_clause_commalist opt_where {
		$$ = new UpdateStatement();
		$$->table = $2;
		$$->updates = $4;
		$$->where = $5;
	}
	;

update_clause_commalist:
		update_clause { $$ = new std::vector<UpdateClause*>(); $$->push_back($1); }
	|	update_clause_commalist ',' update_clause { $1->push_back($3); $$ = $1; }
	;

update_clause:
		IDENTIFIER '=' expr {
			$$ = new UpdateClause();
			$$->column = $1;
			$$->value = $3;
		}
	;

/******************************
 * Select Statement
 ******************************/

select_statement:
		select_with_paren
	|	select_no_paren
	|	select_with_paren set_operator select_paren_or_clause opt_order opt_limit {
			// TODO: allow multiple unions (through linked list)
			// TODO: capture type of set_operator
			// TODO: might overwrite order and limit of first select here
			$$ = $1;
			$$->unionSelect = $3;
			$$->order = $4;

			// Limit could have been set by TOP.
			if ($5 != nullptr) {
				delete $$->limit;
				$$->limit = $5;
			}
		}
	;

select_with_paren:
		'(' select_no_paren ')' { $$ = $2; }
	|	'(' select_with_paren ')' { $$ = $2; }
	;

select_paren_or_clause:
		select_with_paren
	|	select_clause
	;

select_no_paren:
		select_clause opt_order opt_limit {
			$$ = $1;
			$$->order = $2;

			// Limit could have been set by TOP.
			if ($3 != nullptr) {
				delete $$->limit;
				$$->limit = $3;
			}
		}
	|	select_clause set_operator select_paren_or_clause opt_order opt_limit {
			// TODO: allow multiple unions (through linked list)
			// TODO: capture type of set_operator
			// TODO: might overwrite order and limit of first select here
			$$ = $1;
			$$->unionSelect = $3;
			$$->order = $4;

			// Limit could have been set by TOP.
			if ($5 != nullptr) {
				delete $$->limit;
				$$->limit = $5;
			}
		}
	;

set_operator:
		set_type opt_all
	;

set_type:
		UNION
	|	INTERSECT
	|	EXCEPT
	;

opt_all:
		ALL
	|	/* empty */
	;



select_clause:
		SELECT opt_distinct select_list from_clause opt_where opt_group {
			$$ = new SelectStatement();
			//$$->limit = $2;
			$$->selectDistinct = $2;
			$$->selectList = $3;
			$$->fromTable = $4;
			$$->whereClause = $5;
			$$->groupBy = $6;
		}
	;

opt_distinct:
		DISTINCT { $$ = true; }
	|	/* empty */ { $$ = false; }
	;

select_list:
		expr_list
	;

from_clause:
		FROM table_ref { $$ = $2; }
	;


opt_where:
		WHERE expr { $$ = $2; }
	|	/* empty */ { $$ = nullptr; }
	;

opt_group:
		GROUP BY expr_list opt_having {
			$$ = new GroupByDescription();
			$$->columns = $3;
			$$->having = $4;
		}
	|	/* empty */ { $$ = nullptr; }
	;

opt_having:
		HAVING expr { $$ = $2; }
	|	/* empty */ { $$ = nullptr; }

opt_order:
		ORDER BY order_list { $$ = $3; }
	|	/* empty */ { $$ = nullptr; }
	;

order_list:
		order_desc { $$ = new std::vector<OrderDescription*>(); $$->push_back($1); }
	|	order_list ',' order_desc { $1->push_back($3); $$ = $1; }
	;

order_desc:
		expr COLLATE IDENTIFIER opt_order_type { $$ = new OrderDescription($4, $1, $3); }
	|	expr opt_order_type { $$ = new OrderDescription($2, $1); }
	;

opt_order_type:
		ASC { $$ = kOrderAsc; }
	|	DESC { $$ = kOrderDesc; }
	|	/* empty */ { $$ = kOrderAsc; }
	;

// TODO: LIMIT can take more than just int literals.

opt_limit:
		LIMIT expr { $$ = new LimitDescription($2, nullptr); }
	|	LIMIT expr OFFSET expr { $$ = new LimitDescription($2, $4); }
	|	/* empty */ { $$ = nullptr; }
	;

/******************************
 * Expressions
 ******************************/
expr_list:
		expr_alias { $$ = new std::vector<Expr*>(); $$->push_back($1); }
	|	expr_list ',' expr_alias { $1->push_back($3); $$ = $1; }
	;

literal_list:
		literal { $$ = new std::vector<Expr*>(); $$->push_back($1); }
	|	literal_list ',' literal { $1->push_back($3); $$ = $1; }
	;

expr_alias:
		expr opt_alias {
			$$ = $1;
			$$->alias = $2;
		}
	;

expr:
		operand
	|	between_expr
	|	logic_expr
	|	exists_expr
	|	in_expr
	;

operand:
		'(' expr ')' { $$ = $2; }
	|	scalar_expr
	|	unary_expr
	|	binary_expr
	|	case_expr
	|	function_expr
	|	'(' select_no_paren ')' { $$ = Expr::makeSelect($2); }
	;

scalar_expr:
		column_name
	|	literal
	;

unary_expr:
		'-' operand { $$ = Expr::makeOpUnary(kOpUnaryMinus, $2); }
	|	NOT operand { $$ = Expr::makeOpUnary(kOpNot, $2); }
	|	operand ISNULL { $$ = Expr::makeOpUnary(kOpIsNull, $1); }
	|	operand IS NULL { $$ = Expr::makeOpUnary(kOpIsNull, $1); }
	|	operand IS NOT NULL { $$ = Expr::makeOpUnary(kOpNot, Expr::makeOpUnary(kOpIsNull, $1)); }
	;

binary_expr:
		comp_expr
	|	operand '-' operand			{ $$ = Expr::makeOpBinary($1, kOpMinus, $3); }
	|	operand '+' operand			{ $$ = Expr::makeOpBinary($1, kOpPlus, $3); }
	|	operand '/' operand			{ $$ = Expr::makeOpBinary($1, kOpSlash, $3); }
	|	operand '*' operand			{ $$ = Expr::makeOpBinary($1, kOpAsterisk, $3); }
	|	operand '%' operand			{ $$ = Expr::makeOpBinary($1, kOpPercentage, $3); }
	|	operand '^' operand			{ $$ = Expr::makeOpBinary($1, kOpCaret, $3); }
	|	operand LIKE operand		{ $$ = Expr::makeOpBinary($1, kOpLike, $3); }
	|	operand NOT LIKE operand	{ $$ = Expr::makeOpBinary($1, kOpNotLike, $4); }
	|	operand ILIKE operand		{ $$ = Expr::makeOpBinary($1, kOpILike, $3); }
	|	operand CONCAT operand	{ $$ = Expr::makeOpBinary($1, kOpConcat, $3); }
	;

logic_expr:
		expr AND expr	{ $$ = Expr::makeOpBinary($1, kOpAnd, $3); }
	|	expr OR expr	{ $$ = Expr::makeOpBinary($1, kOpOr, $3); }
	;

in_expr:
		operand IN '(' expr_list ')'			{ $$ = Expr::makeInOperator($1, $4); }
	|	operand NOT IN '(' expr_list ')'		{ $$ = Expr::makeOpUnary(kOpNot, Expr::makeInOperator($1, $5)); }
	|	operand IN '(' select_no_paren ')'		{ $$ = Expr::makeInOperator($1, $4); }
	|	operand NOT IN '(' select_no_paren ')'	{ $$ = Expr::makeOpUnary(kOpNot, Expr::makeInOperator($1, $5)); }
	|   operand IN '(' ')'                      { $$ = Expr::makeInOperator($1); }
	|   operand NOT IN '(' ')'                  { $$ = Expr::makeOpUnary(kOpNot, Expr::makeInOperator($1)); }
	;

// CASE grammar based on: flex & bison by John Levine
// https://www.safaribooksonline.com/library/view/flex-bison/9780596805418/ch04.html#id352665
case_expr:
		CASE expr case_list END         	{ $$ = Expr::makeCase($2, $3, nullptr); }
	|	CASE expr case_list ELSE expr END	{ $$ = Expr::makeCase($2, $3, $5); }
	|	CASE case_list END			        { $$ = Expr::makeCase(nullptr, $2, nullptr); }
	|	CASE case_list ELSE expr END		{ $$ = Expr::makeCase(nullptr, $2, $4); }
	;

case_list:
		WHEN expr THEN expr              { $$ = Expr::makeCaseList(Expr::makeCaseListElement($2, $4)); }
	|	case_list WHEN expr THEN expr    { $$ = Expr::caseListAppend($1, Expr::makeCaseListElement($3, $5)); }
	;

exists_expr:
		EXISTS '(' select_no_paren ')' { $$ = Expr::makeExists($3); }
	|	NOT EXISTS '(' select_no_paren ')' { $$ = Expr::makeOpUnary(kOpNot, Expr::makeExists($4)); }
	;

comp_expr:
		operand '=' operand			{ $$ = Expr::makeOpBinary($1, kOpEquals, $3); }
	|	operand NOTEQUALS operand	{ $$ = Expr::makeOpBinary($1, kOpNotEquals, $3); }
	|	operand '<' operand			{ $$ = Expr::makeOpBinary($1, kOpLess, $3); }
	|	operand '>' operand			{ $$ = Expr::makeOpBinary($1, kOpGreater, $3); }
	|	operand LESSEQ operand		{ $$ = Expr::makeOpBinary($1, kOpLessEq, $3); }
	|	operand GREATEREQ operand	{ $$ = Expr::makeOpBinary($1, kOpGreaterEq, $3); }
	;

function_expr:
		IDENTIFIER '(' ')' { $$ = Expr::makeFunctionRef($1, new std::vector<Expr*>(), false); }
	|	IDENTIFIER '(' opt_distinct expr_list ')' { $$ = Expr::makeFunctionRef($1, $4, $3); }
	;

between_expr:
		operand BETWEEN operand AND operand { $$ = Expr::makeBetween($1, $3, $5); }
	;

column_name:
		IDENTIFIER { $$ = Expr::makeColumnRef($1); }
	|	IDENTIFIER '.' IDENTIFIER { $$ = Expr::makeColumnRef($1, $3); }
	|	IDENTIFIER '.' STRING     { $$ = Expr::makeColumnRef($1, $3); }
	|	IDENTIFIER '.' TEXT       { $$ = Expr::makeColumnRef($1, strdup("text")); }
	|	IDENTIFIER '.' RECURSIVE  { $$ = Expr::makeColumnRef($1, strdup("recursive")); }
	|	'*' { $$ = Expr::makeStar(); }
	|	IDENTIFIER '.' '*' { $$ = Expr::makeStar($1); }
	;

literal:
		string_literal
	|	num_literal
	|	null_literal
	|	param_expr
	;

string_literal:
		STRING { $$ = Expr::makeLiteral($1); }
	;


num_literal:
		FLOATVAL { $$ = Expr::makeLiteral($1); }
	|	int_literal
	;

int_literal:
		INTVAL { $$ = Expr::makeLiteral($1); }
	;

null_literal:
	    	NULL { $$ = Expr::makeNullLiteral(); }
	;

param_expr:
		'?' {
			$$ = Expr::makeParameter(yylloc.total_column);
			$$->ival2 = yyloc.param_list.size();
			yyloc.param_list.push_back($$);
		}
	|	':' IDENTIFIER { $$ = Expr::makeNamedParameter($2); }
	;


/******************************
 * Table
 ******************************/
table_ref:
		table_ref_atomic
	|	table_ref_commalist ',' table_ref_atomic {
			$1->push_back($3);
			auto tbl = new TableRef(kTableCrossProduct);
			tbl->list = $1;
			$$ = tbl;
		}
	;


table_ref_atomic:
		nonjoin_table_ref_atomic
	|	join_clause
	;

nonjoin_table_ref_atomic:
		table_ref_name
	|	'(' select_statement ')' opt_alias {
			auto tbl = new TableRef(kTableSelect);
			tbl->select = $2;
			tbl->alias = $4;
			$$ = tbl;
		}
	;

table_ref_commalist:
		table_ref_atomic { $$ = new std::vector<TableRef*>(); $$->push_back($1); }
	|	table_ref_commalist ',' table_ref_atomic { $1->push_back($3); $$ = $1; }
	;


table_ref_name:
		table_name opt_alias {
			auto tbl = new TableRef(kTableName);
			tbl->schema = $1.schema;
			tbl->name = $1.name;
			tbl->alias = $2;
			$$ = tbl;
		}
	;


table_ref_name_no_alias:
		table_name {
			$$ = new TableRef(kTableName);
			$$->schema = $1.schema;
			$$->name = $1.name;
		}
	;


table_name:
		IDENTIFIER                { $$.schema = nullptr; $$.name = $1;}
	|	IDENTIFIER '.' IDENTIFIER { $$.schema = $1; $$.name = $3; }
	;


alias:
		AS IDENTIFIER { $$ = $2; }
	|	AS STRING     { $$ = $2; }
	|	IDENTIFIER
	|	STRING
	;

opt_alias:
		alias
	|	/* empty */ { $$ = nullptr; }


/******************************
 * Join Statements
 ******************************/

join_clause:
		table_ref_atomic NATURAL JOIN nonjoin_table_ref_atomic
		{
			$$ = new TableRef(kTableJoin);
			$$->join = new JoinDefinition();
			$$->join->type = kJoinNatural;
			$$->join->left = $1;
			$$->join->right = $4;
		}
	|	table_ref_atomic opt_join_type JOIN table_ref_atomic ON join_condition
		{
			$$ = new TableRef(kTableJoin);
			$$->join = new JoinDefinition();
			$$->join->type = (JoinType) $2;
			$$->join->left = $1;
			$$->join->right = $4;
			$$->join->condition = $6;
		}
	|
		table_ref_atomic opt_join_type JOIN table_ref_atomic USING '(' column_name ')'
		{
			$$ = new TableRef(kTableJoin);
			$$->join = new JoinDefinition();
			$$->join->type = (JoinType) $2;
			$$->join->left = $1;
			$$->join->right = $4;
			auto left_col = Expr::makeColumnRef(strdup($7->name));
			if ($7->alias != nullptr) left_col->alias = strdup($7->alias);
			if ($1->getName() != nullptr) left_col->table = strdup($1->getName());
			auto right_col = Expr::makeColumnRef(strdup($7->name));
			if ($7->alias != nullptr) right_col->alias = strdup($7->alias);
			if ($4->getName() != nullptr) right_col->table = strdup($4->getName());
			$$->join->condition = Expr::makeOpBinary(left_col, kOpEquals, right_col);
			delete $7;
		}
	;

opt_join_type:
		INNER		{ $$ = kJoinInner; }
	|	LEFT OUTER	{ $$ = kJoinLeft; }
	|	LEFT		{ $$ = kJoinLeft; }
	|	RIGHT OUTER	{ $$ = kJoinRight; }
	|	RIGHT		{ $$ = kJoinRight; }
	|	FULL OUTER	{ $$ = kJoinFull; }
	|	OUTER		{ $$ = kJoinFull; }
	|	FULL		{ $$ = kJoinFull; }
	|	CROSS		{ $$ = kJoinCross; }
	|	/* empty, default */	{ $$ = kJoinInner; }
	;


join_condition:
		expr
		;


/******************************
 * Misc
 ******************************/

opt_semicolon:
		';'
	|	/* empty */
	;


ident_commalist:
		IDENTIFIER { $$ = new std::vector<char*>(); $$->push_back($1); }
	|	STRING     { $$ = new std::vector<char*>(); $$->push_back($1); }
	|	RECURSIVE  { $$ = new std::vector<char*>(); $$->push_back(strdup("recursive")); }
	|	ident_commalist ',' IDENTIFIER { $1->push_back($3); $$ = $1; }
	|	ident_commalist ',' STRING     { $1->push_back($3); $$ = $1; }
	|	ident_commalist ',' RECURSIVE  { $1->push_back(strdup("recursive")); $$ = $1; }
	;

%%
/*********************************
 ** Section 4: Additional C code
 *********************************/

/* empty */

