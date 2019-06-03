%{
  void yyerror (char *s);
  int yylex();
  #include <stdio.h>     /* C declarations used in actions */
  #include <stdlib.h>
  #include <string.h>
  #include <ctype.h>

  int requiredFields = 0;
  const char thumbsUp[5] = {0xF0, 0x9F, 0x91, 0x8D, '\0'};
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
%token            <str> STRING TEXT_INIT USER_INIT
%type             <str> JSON ARRAY
%%
JSON: O_BEGIN O_END
{
  $$ = "{}";
  // printf("%s\n",$$);
}
| O_BEGIN MEMBERS O_END
{
  ;
};
MEMBERS: PAIR
| PAIR COMMA MEMBERS;
PAIR: STRING COLON VALUE 
| TEXT_INIT COLON STRING
{
  if(strlen($3) <= 140){
    printf("text field ok!      %s\n",thumbsUp);
  }else{
    printf("text field not acceptable\nexiting...\n\n");
    exit(1);
  }
}
| USER_INIT COLON O_BEGIN REQUIRED_VALUES O_END
{
  if(requiredFields == 4){
    printf("user field ok!      %s\n",thumbsUp);
  }
  else
  {
    printf("%suser field not acceptable\nexiting...\n\n","\x1B[31m");
    exit(1);
  }
};
REQUIRED_VALUES: REQUIRED_VALUE
|REQUIRED_VALUE COMMA REQUIRED_VALUES;
REQUIRED_VALUE: STRING COLON NUMBER
{
  
  if(!strcmp($1,"\"id\"") && $3 > 0){
    requiredFields++;
    printf("User id field OK      %s\n",thumbsUp);
  }
}
| STRING COLON STRING
{
  if(!strcmp($1,"\"name\"")){
    requiredFields++;
    printf("User name field OK      %s\n",thumbsUp);
  }
  if(!strcmp($1,"\"screen_name\"")){
    requiredFields++;
    printf("User screen_name field OK      %s\n",thumbsUp);
  }
  if(!strcmp($1,"\"location\"")){
    requiredFields++;
    printf("User location field OK      %s\n",thumbsUp);
  }
};
ARRAY: A_BEGIN A_END
{
  $$ = "[]";
  // printf("%s\n",$$);
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
  // printf("%s",$1);
}
| NUMBER
{
  // printf("%d",$1);
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