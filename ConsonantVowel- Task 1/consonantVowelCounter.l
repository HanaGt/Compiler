%{
#include <stdio.h>
int vowel_count = 0;
int consonant_count = 0;
%}

%%

[aeiou]         { vowel_count++; }    /* Match lowercase vowels */
[AEIOU]         { vowel_count++; }    /* Match uppercase vowels */
[b-df-hj-np-tv-z] { consonant_count++; } /* Match lowercase consonants */
[B-DF-HJ-NP-TV-Z] { consonant_count++; } /* Match uppercase consonants */
.               { /* Ignore non-alphabetic characters */ }

%%

int main() {
    yylex();  /* Process the input */
    printf("Vowels: %d\n", vowel_count);
    printf("Consonants: %d\n", consonant_count);
    return 0;
}

int yywrap() {
    return 1;  /* Indicate end of input */
}