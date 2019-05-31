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
%type             <str> JSON 
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
PAIR: STRING COLON STRING
{
  printf("%s %s",$1,$3);
}
| STRING COLON NUMBER
{
  printf("%s %d",$1,$3);
};
%%
int main (void) {
	return yyparse ( );
}

void yyerror (char *s) {fprintf (stderr, "%s\n", s);}