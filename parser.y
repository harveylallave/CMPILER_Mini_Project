%{
  #include <cstdio>
  #include <iostream>
  using namespace std;

  // Declare stuff from Flex that Bison needs to know about:
  extern int yylex();
  extern int yyparse();
  extern FILE *yyin;
  bool print;

  void yyerror(const char *s);
%}

// Bison fundamentally works by asking flex to get the next token, which it
// returns as an object of type "yystype".  Initially (by default), yystype
// is merely a typedef of "int", but for non-trivial projects, tokens could
// be of any arbitrary data type.  So, to deal with that, the idea is to
// override yystype's default typedef to be a C union instead.  Unions can
// hold all of the types of tokens that Flex could return, and this this means
// we can return ints or floats or strings cleanly.  Bison implements this
// mechanism with the %union directive:
%union {
  int ival;
  float fval;
  char *sval;
}

// Define the "terminal symbol" token types I'm going to use (in CAPS
// by convention), and associate each with a field of the %union:
%token <ival> INT NEGATIVENUM POSITIVENUM error
%token <fval> FLOAT
%token <sval> STRING 
%right  ADD SUB MUL DIV MOD 
%nonassoc OPAREN CPAREN 
%token EOL EOD

%type  <ival> expression
%type  <ival> expression2
%type  <ival> expression3
%type  <ival> expression4
%type  <ival> expression5

%%

start: input
| start input
;

input: expression            
| expression EOL             {if(print) cout << "" << $1 << endl; else print = true;}
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
| expression2 MOD expression3 { $$ = $1 % $3; }
;

expression3: expression4     
| expression3 MUL expression4 { $$ = $1 * $3; }
; 

expression4: expression5            
| POSITIVENUM                 { $$ = $1;      }
| NEGATIVENUM                 { $$ = $1 * -1; }
;


expression5: INT            { $$ = $1;}
| OPAREN expression CPAREN    { $$ = $2;}
| error                       { print = false; }
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

void yyerror(const char *s) {
  cout << "Error: " << s << endl;
  // might as well halt now:
  //exit(-1);
  

/* 

// This is the actual grammar that bison will parse, but for right now it's just
// something silly to echo to the screen what bison gets from flex.  We'll
// make a real one shortly:

snazzle:
  INT snazzle      {cout << "bison found an int: " << $1 << endl;}
  | FLOAT snazzle  {cout << "bison found a float: " << $1 << endl;}
  | STRING snazzle {cout << "bison found a string: " << $1 << endl; free($1);}
  | INT            {cout << "bison found an int: " << $1 << endl;}
  | FLOAT          {cout << "bison found a float: " << $1 << endl;}
  | STRING         {cout << "bison found a string: " << $1 << endl; free($1);}
  ;
  */
}

