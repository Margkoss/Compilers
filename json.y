%{
  /* libs and functions */
  extern int yylineno;
  void checkRequirements(int textField, int idStrField, int createdAtField);
  int checkUser(int idField, int nameField, int screenNameField, int locationField);
  void yyerror (char *s);
  int yylex();
  int userID[20];
  #include <stdio.h>
  #include <stdlib.h>
  #include <string.h>
  #include <ctype.h>

  FILE *yyin;

  /* Required fields counters */
  int endOfArray=1;
  int textField = 0;
  int idStrField = 0;
  int createdAtField = 0;
  int idField = 0;
  int nameField = 0;
  int screenNameField = 0;
  int locationField = 0;

  /* Emojis */
  const char thumbsUp[5] = {0xF0, 0x9F, 0x91, 0x8D, '\0'};
  const char check[4] = {0xE2, 0x9C, 0x85, '\0'};

  /* Colors */
  #define KRED  "\x1B[31m"
  #define KBLU  "\x1B[34m"
%}
%union {
  int intval;
  double val;
  char* str;
}
%start            JSON
%token            true false null CREATED_AT
%left             O_BEGIN O_END A_BEGIN A_END
%left             COMMA
%left             COLON
%token            <intval> NUMBER
%token            <str> STRING TEXT_INIT USER_INIT ID_STR 
%type             <str> JSON ARRAY
%%
JSON: O_BEGIN O_END
{
  $$ = "{}";
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
    textField++;
  }else{
    yyerror("\x1B[31mtext field is supposed to be less or equal to 140 characters");
    exit(1);
  }
}
| USER_INIT COLON O_BEGIN REQUIRED_VALUES O_END
{
  ;
}
|ID_STR COLON STRING
{
  int isDigitCounter = 0;
  for(int i = 0; i < strlen($3); i++){
    if($3[i] == *"\"")
      continue;
    if(isdigit($3[i]))
      isDigitCounter++;
  }
  if(isDigitCounter == (strlen($3) - 2)){         /*adjusting for the double quotes the string is supposed to have*/
    idStrField++;
  }else if(isDigitCounter == 0){
    yyerror("\x1B[31mid_str field expected alphanumerical integer,alphanumerical string given");
    exit(1);
  }else{
    yyerror("\x1B[31mid_str field contains characters");
    exit(1);
  }
}
|CREATED_AT COLON STRING
{
  createdAtField++;
};
REQUIRED_VALUES: REQUIRED_VALUE
|REQUIRED_VALUE COMMA REQUIRED_VALUES;
REQUIRED_VALUE: STRING COLON NUMBER
{
  if(!strcmp($1,"\"id\"") && $3 >= 0){
    userID[endOfArray] = $3;
    for(int i = 0; i < endOfArray; i++){
      if(i==endOfArray){
        continue;
      }
        if(userID[i] == userID[endOfArray]){
          yyerror("\x1B[31mDuplicate ids");
          exit(1);
      }
    } 
    endOfArray++;
    idField++;
  }
}
| STRING COLON STRING
{
  if(!strcmp($1,"\"name\"")){
    nameField++;
  }
  if(!strcmp($1,"\"screen_name\"")){
    screenNameField++;
  }
  if(!strcmp($1,"\"location\"")){
    locationField++;
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
int main ( int argc, char *argv[] ) {
  if(!(argc == 2)){
    printf("%sCannot open %d files!\nExiting...\n", KRED, (--argc));
    return 1;
  }
  yyin = fopen(argv[1],"r");
  yyparse();
  fclose(yyin);
  checkRequirements(textField, idStrField, createdAtField);
  return 0;
}

void checkRequirements(int textField, int idStrField, int createdAtField){
  if(textField){
    printf("\n%stext field ok!          %s\n",KBLU,thumbsUp);
  }
  else{
    printf("%sERROR:text field missing          \n",KRED);
    exit(1);
  }
  if(idStrField){
    printf("%sid_str field ok!          %s\n",KBLU,thumbsUp);
  }else{
    printf("%sERROR:id_str field missing          \n",KRED);
    exit(1);
  }
  if(createdAtField){
    printf("%screated_at field ok!          %s\n",KBLU,thumbsUp);
  }else{
    printf("%sERROR:created_at field missing          \n",KRED);
    exit(1);
  }
  
  int userField = checkUser(idField, nameField, screenNameField, locationField);

  if(userField == 4){
    printf("%suser field ok!          %s\n",KBLU,thumbsUp);
  }
  else if(userField == 0){
    printf("%sERROR:user field missing          \n",KRED);
    exit(1);
  }
  else{
    printf("%suser field bad          \n",KRED);
  }
}

int checkUser(int idField, int nameField, int screenNameField, int locationField){
  int userChecks = 0;

  if(idField){
    printf("\t%suser id field ok!          %s\n",KBLU,check);
    userChecks++;
  }
  if(nameField){
    printf("\t%suser name field ok!          %s\n",KBLU,check);
    userChecks++;
  }
  if(screenNameField){
    printf("\t%suser screen name field ok!          %s\n",KBLU,check);
    userChecks++;
  }
  if(locationField){
    printf("\t%suser location field ok!          %s\n",KBLU,check);
    userChecks++;
  }

  return userChecks;
}

void yyerror(char *s) {
    fprintf(stderr, "LINE %d: %s\n", yylineno, s);
}