%{
  /* libs*/
  #include <stdio.h>
  #include <stdlib.h>
  #include <string.h>
  #include <ctype.h>

  /*Flex and bison*/
  FILE *yyin;
  extern int yylineno;
  void yyerror (char *s);
  int yylex();

  /*User functions*/
  void checkCreatedAt(char* createdAt);
  void checkRequirements(int textField, int idStrField, int createdAtField);
  int checkUser(int idField, int nameField, int screenNameField, int locationField);

  /*Error handling*/
  int errorArrayEnd = 0;
  char *error[20] = {NULL};
  int errorLineno[20] = {0};
  char *strUnique[50];
  char *strings;

  /* Required fields counters */
  int userID[20];
  int endOfArray=1;
  int endOfArray1=1;
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
%%
JSON: O_BEGIN O_END
    | O_BEGIN MEMBERS O_END
    ;

MEMBERS: PAIR
       | PAIR COMMA MEMBERS
       ;

PAIR: STRING COLON VALUE 
    | TEXT_INIT COLON STRING{
      if(strlen($3) <= 140){
        textField++;
      }else{
        error[errorArrayEnd] = "\n\x1B[31mtext field is supposed to be less or equal to 140 characters";
        errorLineno[errorArrayEnd] = yylineno;
        errorArrayEnd++;
      }
    }

    | USER_INIT COLON O_BEGIN REQUIRED_VALUES O_END
    |ID_STR COLON STRING{
    int isDigitCounter = 0;
    for(int i = 0; i < strlen($3); i++){
      if($3[i] == *"\"")
        continue;
      if(isdigit($3[i]))
        isDigitCounter++;

    }

    if(isDigitCounter == (strlen($3) - 2)){         /*adjusting for the double quotes the string is supposed to have*/   
      
      int uniqueExist=0;
      strUnique[0] = malloc(strlen($3)+1);
      strings = (char*)malloc(strlen($3)+1);
      strcpy(strings , $3);
      for(int i = 0; i < endOfArray1; i++){   
              if( !strcmp(strUnique[i], strings) ){
                uniqueExist=1;
                error[errorArrayEnd] = "\n\x1B[31mDuplicate id_str fields\n";
                errorLineno[errorArrayEnd] = yylineno;
                errorArrayEnd++;
              }
        }
        if(uniqueExist==0){
          strUnique[endOfArray1]=$3;
          endOfArray1++;
        }
      idStrField++;
    }else if(isDigitCounter == 0){
      error[errorArrayEnd] = "\n\x1B[31mid_str expected alphanumerical integer, string given\n";
      errorLineno[errorArrayEnd] = yylineno;
      errorArrayEnd++;
    }else{
      error[errorArrayEnd] = "\n\x1B[31mid_str field contains characters\n";
      errorLineno[errorArrayEnd] = yylineno;
      errorArrayEnd++;
    }
    }
    |CREATED_AT COLON STRING{
      checkCreatedAt($3);
      createdAtField++; 
    }
    ;

REQUIRED_VALUES: REQUIRED_VALUE
               |REQUIRED_VALUE COMMA REQUIRED_VALUES
               ;

REQUIRED_VALUE: STRING COLON NUMBER{
    if(!strcmp($1,"\"id\"") && $3 >= 0){
      userID[endOfArray] = $3;
      for(int i = 0; i < endOfArray; i++){
        if(i==endOfArray){
          continue;
        }
          if(userID[i] == userID[endOfArray]){
            error[errorArrayEnd] = "\n\x1B[31mDuplicate ids\n";
            errorLineno[errorArrayEnd] = yylineno;
            errorArrayEnd++;
        }
      } 
      endOfArray++;
      idField++;
    }
  }

  |STRING COLON STRING
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
  }
  ;

ARRAY: A_BEGIN A_END
     | A_BEGIN ELEMENTS A_END
     ;

ELEMENTS: VALUE
        | VALUE COMMA ELEMENTS
        ;

VALUE: STRING
     | NUMBER
     | ARRAY
     | JSON
     ;
%%
int main ( int argc, char *argv[] ) {

  if(!(argc == 2)){
    printf("%sCannot open %d files!\nExiting...\n", KRED, (--argc));
    return 1;
  }
  
  yyin = fopen(argv[1],"r");

  if(yyin == NULL)
  {
    printf("%sError -> no file '%s'\n",KRED,argv[1]);   
    exit(1);             
  }

  yyparse();
  fclose(yyin);

  if(!(error[0] == NULL)){
    printf("\n%s/----------ERRORS----------/\n\n",KRED);
    for(int i = 0; i <= errorArrayEnd-1; i++){
      printf("Error %d at line %d: %s\n", i+1, errorLineno[i], error[i]);
    }
    return 1;
  }

  checkRequirements(textField, idStrField, createdAtField);
  return 0;
}

// Helper function for checking if the datetime in "created_at field is ok"
void checkCreatedAt(char* createdAt){
  
  const char *DAYS[] = {"Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"};
  const char *MONTHS[] = {"Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"};

  char* parsed;
  char* components[10];
  int validateComponents[7];

  // Get the first token
  parsed = strtok (createdAt," \",.:");
  components[0] = parsed;
  validateComponents[0] = 0;
  int i = 1;

  //Get the rest of the tokens and put them in the array
  for(int i = 1; i <= 7; i++){
    if(parsed == NULL)
      break;
    else{
      parsed = strtok (NULL, " \",.:");
      validateComponents[i] = 0;
      components[i] = parsed;
    }
  }
  
  //Check if the day belongs in DAYS if not add to the error array
  for(int i = 0; i < 7; i++){
    if(!strcmp(DAYS[i],components[0])){
      validateComponents[0] = 1;
      break;
    }
  }

  //Check if the month belongs in MONTHS if not add to the error array
  for(int i = 0; i < 12; i++){
    if(!strcmp(MONTHS[i],components[1])){
      validateComponents[1] = 1;
      break;
    }
  }

  //Check the hours minutes and seconds
  int hours = atoi(components[3]) >= 0 && atoi(components[3]) < 24;
  int minutes = atoi(components[4]) >= 0 && atoi(components[4]) < 60;
  int seconds = atoi(components[5]) >= 0 && atoi(components[5]) < 60;
  
  if(hours){
    validateComponents[3] = 1;
  }
  if(minutes){
    validateComponents[4] = 1;
  }
  if(seconds){
    validateComponents[5] = 1;
  }

  //Check the date
  if(atoi(components[2]) > 0 && atoi(components[2]) <= 31){
    validateComponents[2] = 1;
    if(!strcmp(MONTHS[1],components[1]) && atoi(components[2]) > 28){
      validateComponents[2] = 0;
    }
  }

  // Check timezone
  if(components[6][0]=='+'){
      parsed = strtok (components[6],"+");
      if (atoi(parsed)<=1400 && atoi(parsed)>=0){
        validateComponents[6] = 1;        
      }
  }else if (components[6][0]=='-'){
      parsed = strtok (components[6],"-");
      if (atoi(parsed)<=1200 && atoi(parsed)>=0){
        validateComponents[6]=1;
      }
  }
  for(int i = 0; i < 7; i++){
    if(!validateComponents[i]){
      error[errorArrayEnd] = "\n\x1B[31mCreated_at field invalid timestamp\n";
      errorLineno[errorArrayEnd] = yylineno;
      errorArrayEnd++;
    }
  }
}

// Helper function for checking what mandatory fields are completed
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
    exit(1);
  }
}

// Helper function for checking the user fields
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

// Bison function for printing errors
void yyerror(char *s) {
    fprintf(stderr, "LINE %d: %s\n", yylineno, s);
}