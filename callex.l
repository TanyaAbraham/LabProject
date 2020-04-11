%{
        #include<stdio.h>
%}
%%
"print"         {return PRNT;}
"True"          {return TRUE;}
"False"         {return FALSE;}
"<"             {return LT;}
">"             {return GT;}
"=="            {return EQ;}
"<="            {return LTQ;}
">="            {return GTQ;}
"!="            {return NEQ;}
[a-zA-Z]        {
                        yylval.id = yytext[0];
                        return ID;
                }
[0-9]+          {
                        yylval.num = atoi(yytext);
                        return NUM;
                }
[ \t\n]         ;
[-+=;*/(){}%]   {return yytext[0];}
.               {exit(1);}
%%
int yywrap(void)
{
        return 1;
}