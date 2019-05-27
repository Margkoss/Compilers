%{
    #include "json.tab.h"
    void yyerror(char* s);
    int yylex();
%}
%%
[0-9]+          {yylval = atoi(yytext); return number;}
.               {ECHO; yyerror ("unexpected character");}
%%
int yywrap(void)
{
    return 1;
}