%{
    void yyerror (char *s);
    int yylex();
    #include <stdio.h>     /* C declarations used in actions */
    #include <stdlib.h>
    #include <ctype.h>
%}
%start      line
%token      number
%%
line: number {printf("That was a number yo");}
%%
int main (void) {
	return yyparse ( );
}

void yyerror (char *s) {fprintf (stderr, "%s\n", s);}