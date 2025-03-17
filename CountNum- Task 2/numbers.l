%{
#include <stdio.h>
int pos_int = 0;    /* Positive integers */
int neg_int = 0;    /* Negative integers */
int pos_frac = 0;   /* Positive fractions */
int neg_frac = 0;   /* Negative fractions */
%}

%%

[+-]?[0-9]+\.[0-9]+    { 
    if (yytext[0] == '-') neg_frac++; 
    else pos_frac++; 
}   /* Fractions like -12.3, +45.6, 78.9 */

[+-]?[0-9]+            { 
    if (yytext[0] == '-') neg_int++; 
    else pos_int++; 
}   /* Integers like -123, +45, 678 */

.                      { /* Ignore other characters */ }

%%

int main() {
    yylex();
    printf("Positive integers: %d\n", pos_int);
    printf("Negative integers: %d\n", neg_int);
    printf("Positive fractions: %d\n", pos_frac);
    printf("Negative fractions: %d\n", neg_frac);
    return 0;
}

int yywrap() {
    return 1;
}