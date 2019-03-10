%{
  #include <cstdio>
  #include <iostream>
  using namespace std;

  extern int yylex();
  extern int yyparse();
  extern FILE *yyin;
  bool print;

  void yyerror(char const *s);
%}

%union {
  int ival;
  float fval;
  char *sval;
}

%token <ival> INT NEGATIVENUM POSITIVENUM 
%token <fval> FLOAT
%token <sval> STRING 
%token        EOL

%right      SUB ADD MOD DIV MUL INT 
%precedence OPAREN CPAREN 

%type  <ival> expression
%type  <ival> expression2
%type  <ival> expression3
%type  <ival> expression4
%type  <ival> expression5

%%

start: input
| start input
| error       
;

input: expression EOL             {if(print) cout << "" << $1 << endl; else print = true;}
| expression                      {if(print) cout << "" << $1 << endl; else print = true;}
| expression error                {print = false;}
;

expression: expression2       
| expression SUB expression2 { $$ = $1 - $3; }
| expression ADD expression2 { $$ = $1 + $3; }
;

expression2: expression3
| expression2 DIV expression3 { 
                                if($3 == 0){
                                    if(print){
                                        cout << "Error: division by zero" << endl;     
                                        print = false;
                                    }
                                    $$ = 0;
                                } else $$ = ($1 / $3); 
                              }

| expression2 MOD expression3 {
                                if($3 == 0){
                                  if(print){
                                    cout << "Error (modulo): division by zero" << endl;
                                    print  = false;
                                  }
                                  $$ = 0;
                                } else $$ = ($1 % $3);
                              }

expression3: expression4     
| expression3 MUL expression4 { $$ = $1 * $3; }
; 

expression4: expression5            
| POSITIVENUM                 { $$ = $1;      }
| NEGATIVENUM                 { $$ = $1 * -1; }
| expression5 INT             { print = false; cout << "Error: syntax error" << endl; }
;


expression5: INT                { $$ = $1;}
| OPAREN expression CPAREN      { $$ = $2;}
| INT OPAREN expression CPAREN  { print = false; cout << "Error: syntax error" << endl;}
| INT INT                       { print = false; cout << "Error: syntax error" << endl;}
;


%%

int main(int, char**) {
    print = true;

    // Open a file handle to a particular file:
    FILE *myfile = fopen("input.txt", "r");
    // Make sure it is valid:
    if (!myfile) {
        cout << "I can't open \"input.txt\"" << endl;
        return -1;
    }

    // Set Flex to read from it instead of defaulting to STDIN:
    yyin = myfile;

    // Parse through the input:
    yyparse();

}

void yyerror(char const *s) {
  cout << "Error: " << s << endl;
  print = false;
}

