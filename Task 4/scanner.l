%{
#include <stdio.h>
%}

%%

"{"[^}]*"}"         ; /* Skip comments, allowing any characters except } between braces */
[ \t\n]+            ; /* Skip whitespace: spaces, tabs, newlines */

"if"                { printf("IF\n"); }
"then"              { printf("THEN\n"); }
"else"              { printf("ELSE\n"); }
"end"               { printf("END\n"); }
"repeat"            { printf("REPEAT\n"); }
"until"             { printf("UNTIL\n"); }
"read"              { printf("READ\n"); }
"write"             { printf("WRITE\n"); }

":="                { printf("ASSIGN\n"); }
"<"                 { printf("LT\n"); }
">"                 { printf("GT\n"); }  /* Added for greater-than operator */
"="                 { printf("EQ\n"); }

"+"                 { printf("PLUS\n"); }
"-"                 { printf("MINUS\n"); }
"*"                 { printf("MUL\n"); }
"/"                 { printf("DIV\n"); }

";"                 { printf("SEMI\n"); }
"("                 { printf("LPAREN\n"); }
")"                 { printf("RPAREN\n"); }

[a-zA-Z][a-zA-Z0-9]* { printf("ID(%s)\n", yytext); }  /* Identifiers, case-sensitive */
[0-9]+              { printf("NUM(%s)\n", yytext); }  /* Integer numbers */

.                   { printf("Invalid token: %s\n", yytext); }  /* Catch invalid characters */

%%

int main() {
    yylex();
    return 0;
}

int yywrap() {
    return 1;
}