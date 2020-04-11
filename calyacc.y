%{
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define SIZE 200
int i=0,line=1;
char temp[10],lineW[100];
struct TAF
{
        char res[10],operator[10],op1[10],op2[10];
};
struct TAF row[20];
char s[SIZE];
int writeLine(char *s)
{
        FILE *fptr;
        fptr = fopen("intcode.txt","a");
		if(fptr==NULL)
        {
                printf("Error opening output file");
                return 0;
        }
        fprintf(fptr,"%s\n", s);
        fclose(fptr);
        return 1;
}
int letterValue(char letter)
{
        int x = -1;
        if(islower(letter)) {
                x = letter - 'a' + 26;
        } else if(isupper(letter)) {
                x = letter - 'A';
        }
        return x;
}
int symbols[52];
int symVal(char symbol)
{
        int bucket = letterValue(symbol);
        return symbols[bucket];
}
void updateSymVal(char symbol, int val)
{
        int bucket = letterValue(symbol);
        symbols[bucket] = val;
}
void writeFile()
{
        int count = 0;
        char buffer[50];

        while(count < i)
        {

                if (strcmp(row[count].res, "")==0)
                {
                        sprintf(buffer,"%s\t%s", row[count].operator, row[count].op1);
                        writeLine(buffer);
                        count++;
                        continue;
                }
                sprintf(buffer, "%s\t:=\t%s\t%s\t%s", row[count].res, row[count].op1, row[count].operator, row[count].op2);
                writeLine(buffer);
                count++;
        }
}
void yyerror (char *s)
{
        fprintf (stderr, "%s at line %d\n", s, line);
}
int addToTable(char operand, char operator1, char operator2);
%}
%code requires {
        struct incod
        {
                char CV[10];
                int val;
        };
}

%union {int num; char id; int cond; struct incod code;}
%start STMT
%token <num> NUM
%token <id> ID
%token <num> TRUE
%token <num> FALSE
%token PRNT LT GT EQ LTQ GTQ NEQ
%type <num> STMT
%type <code> E T LastT CND
%type <id> ASGN
%left '-'
%left '+'
%left '%'
%left '*'
%left '/'

%%

STMT:   ASGN ';'        {line++;}
        | STMT ASGN ';' {line++;}
        | PRNT E ';'         {
                                        printf("%d\n", $2.val);
                                        strcpy(row[i].operator, "OUTPUT ");
                                        strcpy(row[i].op1, $2.CV);
										i++;
                                        line++;
                                }
        | STMT PRNT E ';'       {
                                        printf("%d\n", $3.val);
                                        strcpy(row[i].operator, "OUTPUT ");
                                        strcpy(row[i].op1, $3.CV);
                                        i++;
                                        line++;
                                }
        | PRNT CND ';'  {
                            printf("%d\n", $2.val);
							strcpy(row[i].operator, "OUTPUT");
                            strcpy(row[i].op1, $2.CV);
                            i++;
                            line++;
                        }
        | STMT PRNT CND ';'     {
                                    printf("%d\n", $3.val);
                                    strcpy(row[i].operator, "OUTPUT");
                                    strcpy(row[i].op1, $3.CV);
                                    i++;
                                    line++;
								}
CND:    E LT E  {
                    $$.val = ($1.val<$3.val);
                    sprintf($$.CV, "t%d", i);
                    strcpy(row[i].res, $$.CV);
                    strcpy(row[i].op1, $1.CV);
                    strcpy(row[i].op2, $3.CV);
					sprintf(temp, "%c", '<');
                    strcpy(row[i].operator, temp);
                    i++;
                }
        |E GT E {
                    $$.val = ($1.val>$3.val);
                    sprintf($$.CV, "t%d", i);
                    strcpy(row[i].res, $$.CV);
                    strcpy(row[i].op1, $1.CV);
                    strcpy(row[i].op2, $3.CV);
                    sprintf(temp, "%c", '>');
                    strcpy(row[i].operator, temp);
                    i++;
                }
        |E EQ E {
                    $$.val = ($1.val==$3.val);
                    sprintf($$.CV, "t%d", i);
                    strcpy(row[i].res, $$.CV);
                    strcpy(row[i].op1, $1.CV);
					strcpy(row[i].op2, $3.CV);
                    sprintf(temp, "%s", "==");
                    strcpy(row[i].operator, temp);
                    i++;
                }
        |E LTQ E    {
                        $$.val = ($1.val<=$3.val);
                        sprintf($$.CV, "t%d", i);
                        strcpy(row[i].res, $$.CV);
                        strcpy(row[i].op1, $1.CV);
						strcpy(row[i].op2, $3.CV);
                        sprintf(temp, "%s", "<=");
                        strcpy(row[i].operator, temp);
                        i++;
                    }
	    |E GTQ E    {
                        $$.val = ($1.val>=$3.val);
                        sprintf($$.CV, "t%d", i);
                        strcpy(row[i].res, $$.CV);
                        strcpy(row[i].op1, $1.CV);
                        strcpy(row[i].op2, $3.CV);
                        sprintf(temp, "%s", ">=");
                        strcpy(row[i].operator, temp);
                        i++;
                    }
        |E NEQ E    {
						$$.val = ($1.val!=$3.val);
                        sprintf($$.CV, "t%d", i);
                        strcpy(row[i].res, $$.CV);
                        strcpy(row[i].op1, $1.CV);
						strcpy(row[i].op2, $3.CV);
                        sprintf(temp, "%s", "!=");
                        strcpy(row[i].operator, temp);
                        i++;
                    }
        |TRUE   {
                    $$.val = 1;
                    sprintf($$.CV, "t%d", i);
                    strcpy(row[i].res, $$.CV);
                    strcpy(row[i].op1, "1");
                    i++;
                }
        |FALSE  {
                    $$.val = 0;
                    sprintf($$.CV, "t%d", i);
                    strcpy(row[i].res, $$.CV);
					strcpy(row[i].op1, "0");
                    i++;
                }
                ;


ASGN:   ID '=' E    {
                        updateSymVal($1, $3.val);
                        sprintf(temp, "%d", $3.val);
                        sprintf(temp, "%c", $1);
                        strcpy(row[i].res, temp);
                        sprintf(temp, "%s", $3.CV);
                        strcpy(row[i].op1, temp);
                        $$ = $3.val;
                        i++;
                    }
        |ID '=' CND     {
                                updateSymVal($1, $3.val);
                                sprintf(temp, "%c", $1);
                                strcpy(row[i].res, temp);
                                sprintf(temp, "%s", $3.CV);
                                strcpy(row[i].op1, temp);
                                $$ = $3.val;
                                i++;
                        }
        ;

E:      T       {
                        sprintf($$.CV, "%s", $1.CV);
                        $$.val = $1.val;
                }
        |E '+' T        {
                                sprintf($$.CV, "t%d", i);
                                strcpy(row[i].res, $$.CV);
                                strcpy(row[i].op1, $1.CV);
                                strcpy(row[i].op2, $3.CV);
                                sprintf(temp, "%c", '+');
                                strcpy(row[i].operator, temp);
                                $$.val = $1.val+$3.val;
                                i++;
                        }
        | E '-' T       {
                                sprintf($$.CV, "t%d", i);
                                strcpy(row[i].res, $$.CV);
                                strcpy(row[i].op1, $1.CV);
                                strcpy(row[i].op2, $3.CV);
                                sprintf(temp, "%c", '-');
                                strcpy(row[i].operator, temp);
                                $$.val = $1.val-$3.val;
                                i++;
                        }

T:      LastT   {
                        $$.val = $1.val;
                }
		        | T '*' LastT   {
                                sprintf($$.CV, "t%d", i);
                                strcpy(row[i].res, $$.CV);
                                strcpy(row[i].op1, $1.CV);
                                strcpy(row[i].op2, $3.CV);
                                sprintf(temp, "%c", '*');
                                strcpy(row[i].operator, temp);
                                $$.val = $1.val*$3.val;
                                i++;
                        }
        | T '/' LastT   {
                                sprintf($$.CV, "t%d", i);
                                strcpy(row[i].res, $$.CV);
                                strcpy(row[i].op1, $1.CV);
                                strcpy(row[i].op2, $3.CV);
                                sprintf(temp, "%c", '/');
                                strcpy(row[i].operator, temp);
                                $$.val = $1.val/$3.val;
                                i++;
                        }
        | T '%' LastT   {
                                sprintf($$.CV, "t%d", i);
                                strcpy(row[i].res, $$.CV);
                                strcpy(row[i].op1, $1.CV);
                                strcpy(row[i].op2, $3.CV);
                                sprintf(temp, "%c", '%');
                                strcpy(row[i].operator, temp);
                                $$.val = $1.val%$3.val;
                                i++;
                        }
        ;

LastT:  NUM     {
                        sprintf($$.CV, "%d", $1);
                        $$.val = $1;
                }
        |ID     {
                        int value = symVal($1);
                        if(value == NULL)
                        yyerror("Not initialized");
                        else
                        {
                                sprintf(temp, "%d", value);
                                sprintf($$.CV, "%c", $1);
                                $$.val = value;
                        }
                }
        ;

%%
#include "lex.yy.c"
int main (void)
{
        yyin=fopen("equations.txt","r");
        printf("\nUSING INPUT FROM equations.txt\nOutput is:\n");
        yyparse();
        writeFile();
        printf("PERFORM vi intcode.txt TO GET THE INTERMEDIATE CODE :)\n");
}