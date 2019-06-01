%{
    void yyerror (char *s);
    int yylex();
    #include <stdio.h>     /* C declarations used in actions */
    #include <stdlib.h>
    #include <string.h>
    #include <ctype.h>
%}
%union {
  int intval;
  double val;
  char* str;
}
%start            JSON
%token            true false null
%left             O_BEGIN O_END A_BEGIN A_END
%left             COMMA
%left             COLON
%token            <intval> NUMBER
%token            <str> STRING
%type             <str> JSON ARRAY
%%
JSON: O_BEGIN O_END
{
  $$ = "{}";
  printf("%s\n",$$);
}
| O_BEGIN MEMBERS O_END
{
  ;
};
MEMBERS: PAIR
{
  ;
}
| PAIR COMMA MEMBERS
{
  ;
};
PAIR: STRING COLON VALUE 
{
  printf("%s",$1);
}
;
ARRAY: A_BEGIN A_END
{
  $$ = "[]";
  printf("%s\n",$$);
}
| A_BEGIN ELEMENTS A_END
{
  ;
};
ELEMENTS: VALUE
{
  // $$ = $1;
  ;
}
| VALUE COMMA ELEMENTS
{
  ;
};
VALUE: STRING
{
  printf("%s",$1);
}
| NUMBER
{
  printf("%d",$1);
}
| ARRAY
{
  ;
}
| JSON
{
  ;
};
%%
int main (void) {
	return yyparse ( );
}

void yyerror (char *s) {fprintf (stderr, "%s\n", s);}