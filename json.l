%{
    #include "json.tab.h"
    void yyerror(char* s);
    void printtok(char* token);
    void printnum(int num);
    int yylex();
    int ncount=0;
    int b, i=0;
    int tabcount=0;
    int dont=1;
    int a=1;
%}
%option yylineno
DIGIT1to9 [1-9]
DIGIT [0-9]
DIGITS {DIGIT}+
INT {DIGIT}|{DIGIT1to9}{DIGITS}|-{DIGIT}|-{DIGIT1to9}{DIGITS}
FRAC [.]{DIGITS}
EXP {E}{DIGITS}
E [eE][+-]?
HEX_DIGIT [0-9a-f]
NUMBER {INT}|{INT}{FRAC}|{INT}{EXP}|{INT}{FRAC}{EXP}
UNESCAPEDCHAR [ -!#-\[\]-~]
ESCAPEDCHAR \\["\\bfnrt/]
UNICODECHAR \\u{HEX_DIGIT}{HEX_DIGIT}{HEX_DIGIT}{HEX_DIGIT}
CHAR {UNESCAPEDCHAR}|{ESCAPEDCHAR}|{UNICODECHAR}
CHARS {CHAR}+
DBL_QUOTE ["]
%%
{DBL_QUOTE}created_at{DBL_QUOTE} {
    return CREATED_AT;
}
{DBL_QUOTE}id_str{DBL_QUOTE} {
    return ID_STR;
}
{DBL_QUOTE}user{DBL_QUOTE} {
    dont=0;
    printtok(strdup(yytext));
    dont=1;
    return USER_INIT;
}
{DBL_QUOTE}text{DBL_QUOTE} {
    dont=0;
    printtok(strdup(yytext));
    dont=1;
    return TEXT_INIT;
};
{DBL_QUOTE}{CHARS}{DBL_QUOTE} {
    yylval.str=strdup(yytext);
    dont=0;
    printtok(yytext);
    dont=1;
    return STRING;
};
{NUMBER} {
    yylval.intval=atoi(strdup(yytext));
    printnum(yylval.intval);
    return NUMBER;
}
true {
    return true;
};
false {
    return false;
};
null {
    return null;
};
\{ {
    ncount=1; tabcount++;
    printtok(yytext);
    ncount=0;
    return O_BEGIN;
};

\} {
    ncount=1; 
    a=0; 
    tabcount--;
    printtok(yytext);
    ncount=0; 
    a=1;
    return O_END;
};

\[ {
    ncount=1; tabcount++;
    printtok(yytext);
    ncount=0;
    return A_BEGIN;
};

\] {
    ncount=1; a=0; 
    tabcount--;
    printtok(yytext);
    ncount=0; a=1;
    return A_END;
};

, { 
    ncount=1;
    printtok(strdup(yytext));
    ncount=0;
    return COMMA;
};
: {
    dont=0;
    printtok(yytext);
    dont=1;
    return COLON;
};

[ \t\n]+ /* ignore whitespace */;

. {
    printf("Unexpected: %c\nExiting...\n",*yytext);
    exit(0);
}
%%
int yywrap(void)
{
    return 1;
}
void printtok(char* token){    
    // if(a==0){
    //     tabcount=tabcount-1;
    //     for(i=0;i<tabcount;i++){
    //         if(dont==1){
    //             printf("\t");
    //         }
    //     }
    // }

    
    if(ncount==1 && a==0)
    {   
        printf("\n");
        for(i=0;i<tabcount;i++){
            if(dont==1){
                printf("\t");
            }
        }
    }
    printf("%s", token);
    if(ncount==1 && a==1)
    {   
        printf("\n ");
        for(i=0;i<tabcount;i++){
            if(dont==1){
                printf("\t");
            }
        }
    }
}
void printnum(int num){
    printf("%d", num);
}