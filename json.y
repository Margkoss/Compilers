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
  void checkRequirements(int textField, int idStrField, int createdAtField ,int retweetTextField, int retweetUserField, int truncatedField ,int d_t_rField);
  int checkUser(int idField, int nameField, int screenNameField, int locationField);
  void checkTweetText(char* text);

  /*Error handling*/
  int errorArrayEnd = 0;
  char *error[20] = {NULL};
  int errorLineno[20] = {0};
  char *strUnique[50];
  char *strings;

  /* Required fields counters (1st part)*/
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

  /* Required fields counters (2nd part)*/
  int retweetTextField = 0;
  int retweetUserField = 0;
  int tweetTextField = 0;
  int tweetUserField = 0;
  int truncatedField = 0;
  int d_t_rField = 0;
  int truncated = 0;
  char* originalText;
  char* originalName;

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
%token            null CREATED_AT
%left             O_BEGIN O_END A_BEGIN A_END
%left             COMMA
%left             COLON
%token            <intval> NUMBER true false TRUNCATED
%token            <str> STRING TEXT_INIT USER_INIT ID_STR RETWEET TWEET D_T_R
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
        originalText = $3;
        textField++;
      }else{
        error[errorArrayEnd] = "\n\x1B[31mtext field is supposed to be less or equal to 140 characters";
        errorLineno[errorArrayEnd] = yylineno;
        errorArrayEnd++;
      }
    }

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

    | USER_INIT COLON O_BEGIN USER_REQUIRED_VALUES O_END

    |RETWEET COLON O_BEGIN RT_REQUIRED_VALUES O_END

    |TWEET COLON O_BEGIN T_REQUIRED_VALUES O_END

    |TRUNCATED COLON true {
      truncatedField++;
      truncated = 1;
    }

    |TRUNCATED COLON false {
      truncatedField++;
      truncated = 0;
    }

    |D_T_R COLON A_BEGIN NUMBER COMMA NUMBER A_END {
      d_t_rField++;
      if(($4 < 0 || $6 > 140)){
        error[errorArrayEnd] = "\n\x1B[31mdisplay_text_range after truncated true array can't be <0 || >140\n";
        errorLineno[errorArrayEnd] = yylineno;
        errorArrayEnd++;
      }
    }
    ;

USER_REQUIRED_VALUES: USER_REQUIRED_VALUE
               |USER_REQUIRED_VALUE COMMA USER_REQUIRED_VALUES
               ;

RT_REQUIRED_VALUES: RT_REQUIRED_VALUE
               |RT_REQUIRED_VALUE COMMA RT_REQUIRED_VALUES
               ;

T_REQUIRED_VALUES: T_REQUIRED_VALUE
               |T_REQUIRED_VALUE COMMA T_REQUIRED_VALUES
               ;

USER_REQUIRED_VALUE: STRING COLON NUMBER{
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
      originalName = $3;
      screenNameField++;
    }
    if(!strcmp($1,"\"location\"")){
      locationField++;
    }
  }
  ;
  RT_REQUIRED_VALUE: TEXT_INIT COLON STRING{
    if(!strcmp($3,originalText)){
      retweetTextField++;
    }else{
      error[errorArrayEnd] = "\n\x1B[31mRetweet_status text is not the same as the original text\n";
      errorLineno[errorArrayEnd] = yylineno;
      errorArrayEnd++;
    }
  }
  | USER_INIT COLON TWEET_USER {
    retweetUserField++;
  }
  ;

  T_REQUIRED_VALUE: TEXT_INIT COLON STRING{
    tweetTextField++;
    checkTweetText($3);
  }
  | USER_INIT COLON TWEET_USER{
    tweetUserField++;
  }
  ;

  TWEET_USER: O_BEGIN STRING COLON STRING O_END {
      if(strcmp($2,"\"screen_name\"")){
        error[errorArrayEnd] = "\n\x1B[31mRetweet_status or tweet user has no screen_name property\n";
        errorLineno[errorArrayEnd] = yylineno;
        errorArrayEnd++;
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
     | true
     | false
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

  checkRequirements(textField, idStrField, createdAtField, retweetTextField, retweetUserField,truncatedField,d_t_rField);
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
void checkRequirements(int textField, int idStrField, int createdAtField ,int retweetTextField, int retweetUserField, int truncatedField ,int d_t_rField){
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

  /*2nd part requirements*/

  if(retweetTextField){
    printf("%sretweeted_status text field ok!          %s\n",KBLU,thumbsUp);
  }
  else{
    printf("%sERROR:retweeted_status text field missing          \n",KRED);
    exit(1);
  }
  if(retweetUserField){
    printf("%sretweeted_status user field ok!          %s\n",KBLU,thumbsUp);
  }
  else{
    printf("%sERROR:retweeted_status user field missing          \n",KRED);
    exit(1);
  }
  if(tweetTextField){
    printf("%stweet text field ok!          %s\n",KBLU,thumbsUp);
  }
  else{
    printf("%sERROR:tweet text field missing          \n",KRED);
    exit(1);
  }
  if(tweetUserField){
    printf("%stweet user field ok!          %s\n",KBLU,thumbsUp);
  }
  else{
    printf("%sERROR:tweet user field missing          \n",KRED);
    exit(1);
  }
  if(truncatedField && d_t_rField){
    printf("%struncated field ok!          %s\n",KBLU,thumbsUp);
  }
  else if(truncated && !d_t_rField){
    printf("%sERROR:truncated field is true yet there was no display_text_range array          \n",KRED);
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

void checkTweetText(char* text){
  char* parsed;
  char* components[10];

  // Get the first token
  parsed = strtok (text," \",.:");
  components[0] = parsed;

  //Get the rest of the tokens and put them in the array
  for(int i = 1; i < 3; i++){
    if(parsed == NULL)
      break;
    else{
      parsed = strtok (NULL, " \",.:");
      components[i] = parsed;
    }
  }

  //Check for RT
  if(strcmp(components[0],"RT")){
    error[errorArrayEnd] = "\n\x1B[31mTweet text field needs to be of format 'RT @OriginalAuthor OriginalText' and no RT found\n";
    errorLineno[errorArrayEnd] = yylineno;
    errorArrayEnd++;
  }

  // Check for @OriginalAuthor
  components[1]++;
  originalName++;
  originalName[strlen(originalName) - 1] = 0;
  
  if(strcmp(components[1],originalName)){
    error[errorArrayEnd] = "\n\x1B[31mTweet text field needs to be of format 'RT @OriginalAuthor OriginalText' and not original author name\n";
    errorLineno[errorArrayEnd] = yylineno;
    errorArrayEnd++;
  }

  // Components 2 needs to be the rest of the text so we don't have to check
}

// Bison function for printing errors
void yyerror(char *s) {
    fprintf(stderr, "LINE %d: %s\n", yylineno, s);
}