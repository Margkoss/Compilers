%{
    #include "json.tab.h"
    void yyerror(char* s);
    int yylex();
%}
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
{DBL_QUOTE}user{DBL_QUOTE} {
    return USER_INIT;
}
{DBL_QUOTE}text{DBL_QUOTE} {
    return TEXT_INIT;
};
{DBL_QUOTE}{CHARS}{DBL_QUOTE} {
    yylval.str=strdup(yytext);
    return STRING;
};
{NUMBER} {
    yylval.intval=atoi(strdup(yytext));
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
    return O_BEGIN;
};

\} {
    return O_END;
};

\[ {
    return A_BEGIN;
};

\] {
    return A_END;
};

, {
    return COMMA;
};
: {
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