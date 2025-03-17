%{
#include <stdio.h>
#include <string.h>

// Flags to identify the language
int is_c = 0, is_cpp = 0, is_java = 0;

// Flags to track key program components
int has_main = 0;           // For C/C++ main function
int has_java_class = 0;     // For Java class or interface
int has_java_main = 0;      // For Java main method

// Counters for language-specific features
int c_features = 0;         // C-specific indicators (e.g., <stdio.h>, struct)
int cpp_features = 0;       // C++-specific indicators (e.g., <iostream>, cout)
int java_features = 0;      // Java-specific indicators (e.g., import, extends)

// Counters for structural validation
int brace_level = 0;        // Tracks {}
int paren_level = 0;        // Tracks ()
int bracket_level = 0;      // Tracks []
%}

%x SL_COMMENT ML_COMMENT STRING CHARLIT

%%

 /* Preprocessor directives and namespace for C/C++ */
^"#include"[\t ]*[<"].+[>"]    { 
    if (strstr(yytext, "<stdio.h>") || strstr(yytext, "<stdlib.h>")) c_features = 1; 
    if (strstr(yytext, "<iostream>") || strstr(yytext, "<string>") || 
        strstr(yytext, "<vector>") || strstr(yytext, "<algorithm>")) cpp_features = 1; 
}

^"using namespace std;"        { cpp_features = 1; }

 /* Java-specific package and import statements */
^"import "[a-zA-Z0-9.*;]+      { java_features = 1; }
^"package "[a-zA-Z0-9.]+";"?   { java_features = 1; }

 /* Java class and interface declarations */
("public"|"private"|"protected")[ \t\n]+("abstract"[ \t\n]+)?"class"[ \t\n]+[a-zA-Z_][a-zA-Z0-9_]* { has_java_class = 1; }
("public"|"private"|"protected")[ \t\n]+"interface"[ \t\n]+[a-zA-Z_][a-zA-Z0-9_]* { has_java_class = 1; }
"class"[ \t]+[a-zA-Z_][a-zA-Z0-9_]*[ \t\n]*"{" { has_java_class = 1; }

 /* Java main method detection (supports both String[] args and String args[] syntax) */

"public"[ \t\n]+"static"[ \t\n]+"void"[ \t\n]+"main"[ \t\n]*\([ \t\n]*String[ \t\n]*\[\][ \t\n]*[a-zA-Z_][a-zA-Z0-9_]*[ \t\n]*\) { has_java_main = 1; }
"public"[ \t\n]+"static"[ \t\n]+"void"[ \t\n]+"main"[ \t\n]*\([ \t\n]*String[ \t\n]*[a-zA-Z_][a-zA-Z0-9_]*[ \t\n]*\[\][ \t\n]*\) { has_java_main = 1; }


 /* C/C++ main function */
"int main("[^)]*")"            { has_main = 1; }

 /* Language-specific keywords and operators */
"cout"|"cin"|"endl"            { cpp_features = 1; }  // C++ stream operators
"new"|"delete"                 { cpp_features = 1; }  // C++ memory operators
"template"|"virtual"|"namespace" { cpp_features = 1; }  // C++ keywords

"extends"|"implements"         { java_features = 1; }  // Java keywords
"struct"                       { c_features = 1; }     // C keyword (also in C++, but common in C)

 /* Comments (ignored to avoid false positives) */
"//"                           BEGIN(SL_COMMENT);
<SL_COMMENT>[^\n]*             { /* Ignore */ }
<SL_COMMENT>\n                 BEGIN(INITIAL);

"/*"                           BEGIN(ML_COMMENT);
<ML_COMMENT>"*/"               BEGIN(INITIAL);
<ML_COMMENT>.|\n               { /* Ignore */ }

 /* String and character literals (ignored) */
\"                             BEGIN(STRING);
<STRING>\\\"                   { /* Escaped quote */ }
<STRING>[^\\\"]+              { /* String content */ }
<STRING>\"                    BEGIN(INITIAL);

\'                             BEGIN(CHARLIT);
<CHARLIT>\\\'                 { /* Escaped char */ }
<CHARLIT>[^\\\']+            { /* Char content */ }
<CHARLIT>\'                   BEGIN(INITIAL);

 /* Structural tokens */
"{"                            { brace_level++; }
"}"                            { brace_level--; }
"("                            { paren_level++; }
")"                            { paren_level--; }
"["                            { bracket_level++; }
"]"                            { bracket_level--; }

 /* Ignore other characters */
.|\n                           { /* Ignore */ }

 /* End of input */
<<EOF>>                        { return 0; }

%%

int main() {
    yylex();

    // Determine the language based on detected features and structure
    if (has_java_class && has_java_main && brace_level == 0 && paren_level == 0 && bracket_level == 0) {
        is_java = 1;
    } else if (has_main && cpp_features && java_features == 0 && brace_level == 0 && paren_level == 0 && bracket_level == 0) {
        is_cpp = 1;
    } else if (has_main && c_features && cpp_features == 0 && java_features == 0 && brace_level == 0 && paren_level == 0 && bracket_level == 0) {
        is_c = 1;
    }

    // Output the result
    if (is_java) {
        printf("Valid Java program\n");
    } else if (is_cpp) {
        printf("Valid C++ program\n");
    } else if (is_c) {
        printf("Valid C program\n");
    } else {
        printf("Not a valid C/C++/Java program\n");
    }

    return 0;
}

int yywrap() {
    return 1;  // No additional input files
}