%{
    /* Credits
        https://westes.github.io/flex/manual/Patterns.html
        https://www.w3schools.com/jsref/jsref_operators.asp
        https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Lexical_grammar
        https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Expressions_and_operators
    */

    #include <stdio.h>
    #include <string.h>
    #include <stdbool.h>

    unsigned long long lineIdx = 1;
    unsigned short bufferIdx = 0;
    char buffer[4096];
    char outputFileName[128];
    FILE* outputFile;

    void token(const char* label, const char* yytext)
    {
        fprintf(outputFile, "%s, \"%s\", line %llu, length %lu\n", label, yytext, lineIdx, strlen(yytext));
    }

    void handleNewLines(const char* label, const char* text)
    {
        unsigned long long startIdx = lineIdx;
        for (const char* c = text; *c; ++c)
        {
            if (*c == '\n')
            {
                ++lineIdx;
            }
        }
        startIdx == lineIdx
            ? fprintf(outputFile, "%s, \"%s\", line %llu, length %lu\n", label, text, lineIdx, strlen(text))
            : fprintf(outputFile, "%s, \"%s\", lines %llu-%llu, length %lu\n", label, text, startIdx, lineIdx, strlen(text));
    }

    int endOfFile(bool error)
    {
        const char* message = error
            ? "Error, unterminated multiline comment starting at line %llu\n"
            : "End of file, line %llu\n";
        fprintf(outputFile, message, lineIdx);
        fclose(outputFile);
        return error;
    }

    void appendToBuffer(char* buffer, const char* str) {
        for (const char* c = str; *c; ++c) {
            buffer[bufferIdx++] = *c;
        }
        buffer[bufferIdx] = '\0';
    }

    FILE* openJsFile(const char* filename) {
        size_t len = strlen(filename);
        return (len >= 3 && strcmp(filename + len - 3, ".js") == 0)
            ? (strncpy(outputFileName, filename, len - 3), strcat(outputFileName, ".txt"), fopen(filename, "r"))
            : (FILE*)NULL;
    }
%}

WHITESPACE [ \t]+
NEW_LINE   [\n\r]
SEPARATOR  "("|")"|"["|"]"|"{"|"}"|";"
COMMENT    "//".*
IDENTIFIER [A-Za-z_$][A-Za-z0-9_]*
KEYWORD    "async"|"await"|"break"|"case"|"catch"|"class"|"const"|"continue"|"debugger"|"default"|"do"|"else"|"export"|"extends"|"finally"|"for"|"function"|"if"|"import"|"let"|"return"|"static"|"super"|"switch"|"this"|"throw"|"try"|"var"|"yield"|"while"|"with"

NULL        "null"
BOOLEAN     "true"|"false"
DIGIT       [0-9]
INTEGER     "0"|[1-9]{DIGIT}*
DOUBLE      {INTEGER}"."{DIGIT}+|{INTEGER}"."|"."{DIGIT}+
EXPONENTIAL {DIGIT}+("e"|"E")("+"|"-")?{DIGIT}+
BINARY      "0"("b"|"B")[0-1]+
OCTAL       "0"("o"|"O")?[0-7]+
HEXADECIMAL "0"("x"|"X")[0-9A-F]+
BIG_INT     ({INTEGER}|{BINARY}|{HEXADECIMAL}|["0"{"o"|"O"}[0-7]+])"n"
STRING      \"(\\.|[^"\\\n]|\\\n)*\"|\'(\\.|[^'\\\n]|\\\n)*\'|\`(\\.|[^`\\\n]|\\\n)*\`
REGEX       \/([^/*\n][^/\n]*)\/[gimsuy]*

BASIC_OPERATOR      "+"|"-"|"*"|"/"|"%"|"**"|"<<"|">>"|">>>"|"&"|"^"|"|"|"&&"|"||"|"??"
ASSIGNMENT_OPERATOR {BASIC_OPERATOR}?"="
COMPARISON_OPERATOR "=="|"==="|"!="|"!=="|">"|">="|"<"|"<="
SPECIAL_OPERATOR    "delete"|"in"|"instanceof"|"new"|"typeof"|"void"
OPERATOR            "."|","|":"|"!"|"?."|"..."|"++"|"--"|{BASIC_OPERATOR}|{ASSIGNMENT_OPERATOR}|{COMPARISON_OPERATOR}|{SPECIAL_OPERATOR}

%x MULTILINE_COMMENT

%%
{KEYWORD} {
    token("Keyword", yytext);
}

{STRING} {
    handleNewLines("String", yytext);
}

{REGEX} {
    token("Regex", yytext);
}

{OPERATOR} {
    token("Operator", yytext);
}

{SEPARATOR} {
    token("Separator", yytext);
}

{NULL} {
    token("null", yytext);
}

{BOOLEAN} {
    token("Boolean", yytext);
}

{INTEGER} {
    token("Integer", yytext);
}

{DOUBLE} {
    token("Double", yytext);
}

{EXPONENTIAL} {
    token("Exponential", yytext);
}

{BINARY} {
    token("Binary", yytext);
}

{OCTAL} {
    token("Octal", yytext);
}

{HEXADECIMAL} {
    token("Hexadecimal", yytext);
}

{BIG_INT} {
    token("BigInt", yytext);
}

{IDENTIFIER} {
    token("Variable", yytext);
}

{WHITESPACE} {
    /* do nothing */
}

{NEW_LINE} {
    ++lineIdx;
}

{COMMENT} {
    token("Comment", yytext);
}

"/*" {
    BEGIN(MULTILINE_COMMENT);
    appendToBuffer(buffer, "/*");
}

<MULTILINE_COMMENT>(.|\n) {
    appendToBuffer(buffer, yytext);
}

<MULTILINE_COMMENT>"*/" {
    appendToBuffer(buffer, "*/");
    handleNewLines("Multiline comment", buffer);
    bufferIdx = 0;
    buffer[bufferIdx] = '\0';
    BEGIN(INITIAL);
}

<MULTILINE_COMMENT><<EOF>> {
    return endOfFile(true);
}

<<EOF>> {
    return endOfFile(false);
}

. {
    token("Error", yytext);
}
%%

int yywrap(){}

int main(int argc, char** argv)
{
    yyin = (argc >= 2) ? openJsFile(argv[1]) : stdin;
    outputFile = (outputFile = fopen(outputFileName, "w")) ? outputFile : stdout;

    return yyin == NULL
        ? (fprintf(stderr, "Error: Only JavaScript (.js) files are allowed!\n"), 1)
        : (yylex(), 0);
}
