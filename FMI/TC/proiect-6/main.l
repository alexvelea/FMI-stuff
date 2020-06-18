WHITESPACE [ \t]

    void PrintLeadingWhitespaces();

%%

^{WHITESPACE}*"#"(.|(\\\n))*    {
    PrintLeadingWhitespaces();
    printf("[preprocessor token]"); 
}

"//"[^\n]*					printf("[single-line-comment]");
"/*"([^*]|(\*[^\/]))*"*/"	printf("[multiple-line-comment]");


typedef|struct|enum|union 							|
extern|auto|volatile|register|static|const 			|
signed|unsigned|short|long							|
void|char|int|float|double							|
break|continue										|
switch|default|case									|
do|while|for										|
if|else												|
goto|sizeof											|
return	{
	printf("[keyword]");
}

[a-zA-Z_][a-zA-Z_0-9]*		printf("[identifier]");

0[x|X][0-9|a-f|A-F]+	printf("[number in base 16]");
0[b|B][0|1]+			printf("[number in base 2]");
0[0-7]+					printf("[number in base 8]");
[0-9]+					printf("[number in base 10]");
[0-9]+\.[0-9]+			printf("[real number]");

\"([^\"\\\n]|(\\\n)|(\\.))*\"	printf("[string literal]");

"+="|"-="|"*="|"/="|"^="|"&="|"|="|"%="|">>="|"<<="|"="		printf("[assignment operators]");
"+"|"-"|"*"|"/"|"%"											printf("[math operator]");
"<<"|">>"|"&"|"|"|"^"										printf("[binary operator]");
"~"|"!"|"++"|"--"|"&"										printf("[unary operator]"); // somehow sizeof is a unary operator as well
"&&"|"||"													printf("[logical operator]");
"<="|">="|"<"|">"											printf("[relational operator]");

"("|")"|"["|"]"|"{"|"}"|","|";" 	ECHO;
" "|"\t"|"\n"						ECHO;
.							printf("Bad token '%c'", yytext[0]);
%%

void PrintLeadingWhitespaces() {
    int i = 0;
    while (yytext[i] == ' ' || yytext[i] == '\t') {
        printf("%c", yytext[i]);
        i += 1;
    }
}

