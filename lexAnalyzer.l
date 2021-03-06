
/* CMPILER Mini Project (Simple Calculator) */

/* Bison should run first (because we're getting the list of tokens from bison) */

/*      % bison -d parser.y                                 */
/*      % flex lexAnalyzer.l                                */
/*      % g++ parser.tab.c lex.yy.c -lfl -o lexAnalyzer     */
/*      % lexAnalyzer                                       */

%{
  #include <cstdio>
  #include <string>
  #include <iostream>

  #include "parser.tab.h"  // to get the token types from Bison

%}

%%
[ \t]             ;
\-[0-9]+          { char temp[strlen(yytext) - 1];
                    memcpy( temp, &yytext[1], strlen(yytext));
                    temp[strlen(yytext) - 1] = '\0';
                    yylval.ival = atoi(temp); 
                    return NEGATIVENUM; }
\+[0-9]+          { char temp[strlen(yytext) - 1];
                    memcpy( temp, &yytext[1], strlen(yytext));
                    temp[strlen(yytext) - 1] = '\0';
                    yylval.ival = atoi(temp); 
                    return POSITIVENUM; }
[0-9]+            { yylval.ival = atoi(yytext); return INT; }
\+                { return ADD; }
\-                { return SUB; }
\*                { return MUL; }
\/                { return DIV; }
\%                { return MOD; }
\(                { return OPAREN; }
\)                { return CPAREN; }
\n                { return EOL; }
.*[a-z|A-Z|\!|\@|\#|\$|\^|\&|\_|\=|\`|\~|\[|\]|\;|\:\'|\"|\,|\<|\.|\>|\\|\||\?].* { return LEXERROR; }

%%