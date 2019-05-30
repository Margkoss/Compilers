%{
    void yyerror (char *s);
    int yylex();
    #include <stdio.h>     /* C declarations used in actions */
    #include <stdlib.h>
    #include <ctype.h>
%}
%union {
  int intval;
  double val;
  char* str;
}
%start      line
%token      number
%token      STRING
%%
line: number {printf("That was a number yo");}
    | STRING {printf("string yo");}
%%
int main (void) {
	return yyparse ( );
}

void yyerror (char *s) {fprintf (stderr, "%s\n", s);}