/**
 * lexer
 *
 *
 */


/***************************
 ** Section 1: Definitions
 ***************************/
%{

#include "src/sql/Expr.h"
#include "src/parser/bison_parser.h"
#include <stdio.h>

#define TOKEN(name) { return SQL_##name; }

%}
/***************************
 ** Section 2: Rules
 ***************************/

/* Make reentrant */
%option reentrant
%option bison-bridge

/* performance tweeks */
%option never-interactive
%option batch

/* other flags */
%option noyywrap
%option nounput
%option warn
%option case-insensitive
%option prefix="hsql_"
%option bison-locations 
/* %option nodefault */


%s COMMENT

/***************************
 ** Section 3: Rules
 ***************************/
%%

--				BEGIN(COMMENT);
<COMMENT>[^\n]*	/* skipping comment content until a end of line is read */;
<COMMENT>\n 	BEGIN(INITIAL);

[ \t\n]+	/* skip whitespace */;

CURRENT_TIMESTAMP TOKEN(CURRENT_TIMESTAMP)
AUTOINCREMENT     TOKEN(AUTOINCREMENT)
CURRENT_DATE      TOKEN(CURRENT_DATE)
CURRENT_TIME      TOKEN(CURRENT_TIME)
TRANSACTION       TOKEN(TRANSACTION)
CONSTRAINT        TOKEN(CONSTRAINT)
DEFERRABLE        TOKEN(DEFERRABLE)
REFERENCES        TOKEN(REFERENCES)
EXCLUSIVE         TOKEN(EXCLUSIVE)
IMMEDIATE         TOKEN(IMMEDIATE)
INITIALLY         TOKEN(INITIALLY)
INTERSECT         TOKEN(INTERSECT)
RECURSIVE         TOKEN(RECURSIVE)
SAVEPOINT         TOKEN(SAVEPOINT)
TEMPORARY         TOKEN(TEMPORARY)
CONFLICT          TOKEN(CONFLICT)
DATABASE          TOKEN(DATABASE)
DEFERRED          TOKEN(DEFERRED)
DISTINCT          TOKEN(DISTINCT)
RESTRICT          TOKEN(RESTRICT)
ROLLBACK          TOKEN(ROLLBACK)
ANALYZE           TOKEN(ANALYZE)
BETWEEN           TOKEN(BETWEEN)
BOOLEAN           TOKEN(BOOLEAN)
CASCADE           TOKEN(CASCADE)
COLLATE           TOKEN(COLLATE)
DEFAULT           TOKEN(DEFAULT)
EXPLAIN           TOKEN(EXPLAIN)
FOREIGN           TOKEN(FOREIGN)
INDEXED           TOKEN(INDEXED)
INSTEAD           TOKEN(INSTEAD)
INTEGER           TOKEN(INTEGER)
NATURAL           TOKEN(NATURAL)
NOTNULL           TOKEN(NOTNULL)
PRIMARY           TOKEN(PRIMARY)
REINDEX           TOKEN(REINDEX)
RELEASE           TOKEN(RELEASE)
REPLACE           TOKEN(REPLACE)
TRIGGER           TOKEN(TRIGGER)
VIRTUAL           TOKEN(VIRTUAL)
WITHOUT           TOKEN(WITHOUT)
ACTION            TOKEN(ACTION)
ATTACH            TOKEN(ATTACH)
BEFORE            TOKEN(BEFORE)
COLUMN            TOKEN(COLUMN)
COMMIT            TOKEN(COMMIT)
CREATE            TOKEN(CREATE)
DELETE            TOKEN(DELETE)
DETACH            TOKEN(DETACH)
DOUBLE            TOKEN(DOUBLE)
ESCAPE            TOKEN(ESCAPE)
EXCEPT            TOKEN(EXCEPT)
EXISTS            TOKEN(EXISTS)
HAVING            TOKEN(HAVING)
IGNORE            TOKEN(IGNORE)
INSERT            TOKEN(INSERT)
ISNULL            TOKEN(ISNULL)
OFFSET            TOKEN(OFFSET)
PRAGMA            TOKEN(PRAGMA)
REGEXP            TOKEN(REGEXP)
RENAME            TOKEN(RENAME)
SELECT            TOKEN(SELECT)
UNIQUE            TOKEN(UNIQUE)
UPDATE            TOKEN(UPDATE)
VACUUM            TOKEN(VACUUM)
VALUES            TOKEN(VALUES)
ABORT             TOKEN(ABORT)
AFTER             TOKEN(AFTER)
ALTER             TOKEN(ALTER)
BEGIN             TOKEN(BEGIN)
CHECK             TOKEN(CHECK)
CROSS             TOKEN(CROSS)
FLOAT             TOKEN(FLOAT)
GROUP             TOKEN(GROUP)
INDEX             TOKEN(INDEX)
INNER             TOKEN(INNER)
LIMIT             TOKEN(LIMIT)
MATCH             TOKEN(MATCH)
ORDER             TOKEN(ORDER)
OUTER             TOKEN(OUTER)
QUERY             TOKEN(QUERY)
RAISE             TOKEN(RAISE)
RIGHT             TOKEN(RIGHT)
TABLE             TOKEN(TABLE)
UNION             TOKEN(UNION)
USING             TOKEN(USING)
WHERE             TOKEN(WHERE)
BLOB              TOKEN(BLOB)
CASE              TOKEN(CASE)
CAST              TOKEN(CAST)
DESC              TOKEN(DESC)
DROP              TOKEN(DROP)
EACH              TOKEN(EACH)
ELSE              TOKEN(ELSE)
FAIL              TOKEN(FAIL)
FROM              TOKEN(FROM)
FULL              TOKEN(FULL)
GLOB              TOKEN(GLOB)
INTO              TOKEN(INTO)
JOIN              TOKEN(JOIN)
LEFT              TOKEN(LEFT)
LIKE              TOKEN(LIKE)
LONG              TOKEN(LONG)
NULL              TOKEN(NULL)
PLAN              TOKEN(PLAN)
REAL              TOKEN(REAL)
TEMP              TOKEN(TEMP)
TEXT              TOKEN(TEXT)
THEN              TOKEN(THEN)
VIEW              TOKEN(VIEW)
WHEN              TOKEN(WHEN)
WITH              TOKEN(WITH)
ADD               TOKEN(ADD)
ALL               TOKEN(ALL)
AND               TOKEN(AND)
ASC               TOKEN(ASC)
END               TOKEN(END)
FOR               TOKEN(FOR)
INT               TOKEN(INT)
KEY               TOKEN(KEY)
NOT               TOKEN(NOT)
ROW               TOKEN(ROW)
SET               TOKEN(SET)
AS                TOKEN(AS)
BY                TOKEN(BY)
IF                TOKEN(IF)
IN                TOKEN(IN)
IS                TOKEN(IS)
NO                TOKEN(NO)
OF                TOKEN(OF)
ON                TOKEN(ON)
OR                TOKEN(OR)
TO                TOKEN(TO)

"!="		TOKEN(NOTEQUALS)
"<>" 		TOKEN(NOTEQUALS)
"<="		TOKEN(LESSEQ)
">="		TOKEN(GREATEREQ)
"||"		TOKEN(CONCAT)

[-+*/(){},.;<>=^%:?[\]|]	{ return yytext[0]; }

-?[0-9]+"."[0-9]* |
"."[0-9]*	{
	yylval->fval = atof(yytext);
	return SQL_FLOATVAL;
}

-?[0-9]+	{
	yylval->ival = atol(yytext);
	return SQL_INTVAL;
}

[\"'`][^\"\n]+[\"'`] {
	// Crop the leading and trailing quote char
	yylval->sval = hsql::substr(yytext, 1, strlen(yytext)-1);
	return SQL_IDENTIFIER;
}

[A-Za-z][A-Za-z0-9_]* {
	yylval->sval = strdup(yytext);
	return SQL_IDENTIFIER;
}

'[^'\n]*' {
	// Crop the leading and trailing quote char
	yylval->sval = hsql::substr(yytext, 1, strlen(yytext)-1);
	return SQL_STRING;
}

. { fprintf(stderr, "[SQL-Lexer-Error] Unknown Character: %c\n", yytext[0]); return 0; }


%%
/***************************
 ** Section 3: User code
 ***************************/

int yyerror(const char *msg) {
    fprintf(stderr, "[SQL-Lexer-Error] %s\n",msg); return 0;
}
