package com.appian.intellij.k;

import static com.appian.intellij.k.psi.KTypes.*;

import com.intellij.lexer.FlexLexer;
import com.intellij.psi.tree.IElementType;

%%

%class KLexer
%implements FlexLexer
%unicode
%function advance
%type IElementType
%eof{  return NEWLINE;
%eof}

LINE_WS=[\ \t\f]
NEWLINE=\r|\n|\r\n
WHITE_SPACE=({LINE_WS}|{NEWLINE})*{LINE_WS}+

COMMENT1="/" [^\r\n]+ {NEWLINE}?
COMMENT2={WHITE_SPACE}+ "/" [^\r\n]* {NEWLINE}?

SIMPLE_COMMAND="\\"(
  [dafv_ib] // ({WHITE_SPACE}+{USER_IDENTIFIER})?
 |([ls12x]|"kr") // {WHITE_SPACE}+{USER_IDENTIFIER}
 |[egopPSTwWz] // ({WHITE_SPACE}+{NUMBER})? // 't' is not included b/c in K3 it takes an expression
 |[bBrsu\\wm]
 |[cC] //{NUMBER_VECTOR}
  )
MODE=[qk]")"
COMPLEX_COMMAND="\\"{USER_IDENTIFIER} // takes OS command and/or arbitrary expression as argument
USER_IDENTIFIER=([a-zA-Z]|\.[a-zA-Z])([_a-zA-Z0-9]|\.[a-zA-Z])*
PATH=[.a-zA-Z/][._a-zA-Z0-9/]*

// q functions
Q_SYSTEM_FUNCTION=(abs|acos|aj|aj0|all|and|any|asc|asin|asof|atan|attr|avg|avgs|bin|binr|by|ceiling|cols|cor|cos|count
       |cov|cross|csv|cut|deltas|desc|dev|differ|distinct|div|dsave|each|ej|ema|enlist|eval|except
       |exit|exp|fby|fills|first|fkeys|flip|floor|get|getenv|group|gtime|hclose|hcount|hdel|hopen
       |hsym|iasc|idesc|ij|in|insert|inter|inv|key|keys|last|like|lj|ljf|load|log|lower|lsq|ltime|ltrim|mavg
       |max|maxs|mcount|md5|mdev|med|meta|min|mins|mmax|mmin|mmu|mod|msum|neg|next|not|null|or|over|parse
       |peach|pj|prd|prds|prev|prior|rand|rank|ratios|raze|read0|read1|reciprocal|reverse|rload|rotate|rsave
       |rtrim|save|scan|scov|sdev|set|setenv|show|signum|sin|sqrt|ss|ssr|string|sublist|sum|sums|sv
       |svar|system|tables|tan|til|trim|type|uj|ungroup|union|upper|upsert|value|var|view|views|vs
       |wavg|where|within|wj|wj1|wsum|ww|xasc|xbar|xcol|xcols|xdesc|xexp|xgroup|xkey|xlog|xprev|xrank)

Q_SQL_TEMPLATE=(select|exec|update|delete)

INT_TYPE=[ihjfepnuvt]
FLOAT_TYPE=[fe]
TIMESPAN_STAMP_TYPE=[pn]
Q_DATETIME_TYPE=[mdz]
Q_TIME_TYPE=[uvt]
// only positive numbers
Q_NIL=-?0[Nn]
Q_BINARY=[01]"b"
Q_HEX_CHAR=[[:digit:]A-Fa-f]
Q_HEX_NUMBER="0x"{Q_HEX_CHAR}{Q_HEX_CHAR}?
NUMBER_POSITIVE={Q_BINARY}|{Q_HEX_NUMBER}
// positive & negative
INFINITY=-?0[iIwW] // iI are from k3; wW are from k4; nN are from both
Q_MONTH=[:digit:]{4}\.[:digit:]{2}
Q_DATE={Q_MONTH}\.[:digit:]{2}
Q_MINUTE=[:digit:]{2,3}\:[0-5][:digit:]
Q_SECOND={Q_MINUTE}\:[0-5][:digit:]
Q_TIME=[:digit:]+(\:[:digit:]{2}(\:[0-5][:digit:](\.[:digit:]+)?)?)?
Q_DATETIME={Q_DATE}"T"{Q_TIME}
Q_TIMESTAMP=-?{Q_DATE}("D"{Q_TIME})?
NUMBER_INTEGER=-?(0|[1-9][0-9]*)
Q_TIMESPAN={NUMBER_INTEGER}"D"({Q_TIME})?
NUMBER_FLOAT={NUMBER_INTEGER}(\.[0-9]*)|(\.[0-9]+)
NUMBER_EXP={NUMBER_INTEGER}(\.[0-9]+)?([eE][+-]?[0-9]*)
// all numbers
NUMBER={NUMBER_INTEGER}{INT_TYPE}?|({NUMBER_FLOAT}|{NUMBER_EXP}){FLOAT_TYPE}?|
       ({INFINITY}|{Q_NIL})({INT_TYPE}|{Q_DATETIME_TYPE})?|{Q_NIL}"g"|
       ({Q_TIMESTAMP}|{Q_TIMESPAN}|{NUMBER_FLOAT}){TIMESPAN_STAMP_TYPE}?|
       {NUMBER_POSITIVE}|({Q_MINUTE}|{Q_SECOND}|{Q_TIME}){Q_TIME_TYPE}?|{Q_DATE}[dz]?|{Q_DATETIME}"z"?|{Q_MONTH}"m"?
BINARY_VECTOR=[01][01]+"b"|"0x"{Q_HEX_CHAR}{2}{Q_HEX_CHAR}+
VECTOR_INT={NUMBER_INTEGER}|{Q_NIL}|{INFINITY}
VECTOR_FLOAT={NUMBER_INTEGER}|{NUMBER_FLOAT}|{NUMBER_EXP}|{Q_NIL}|{INFINITY}
VECTOR_TIME={NUMBER_INTEGER}|{Q_NIL}|{Q_MINUTE}|{Q_SECOND}|{Q_TIME}|{INFINITY}
VECTOR_MONTH={Q_MONTH}|{Q_NIL}|{INFINITY}
VECTOR_DATE={Q_DATE}|{Q_NIL}|{INFINITY}
VECTOR_DATETIME={Q_DATETIME}|{Q_DATE}|{Q_NIL}|{INFINITY}
VECTOR_TIMESTAMP={Q_TIMESTAMP}|{Q_TIMESPAN}|{NUMBER_FLOAT}|{VECTOR_TIME}
NUMBER_VECTOR={VECTOR_INT}({WHITE_SPACE}{VECTOR_INT})+{INT_TYPE}?|
              {VECTOR_FLOAT}({WHITE_SPACE}{VECTOR_FLOAT})+{FLOAT_TYPE}?|
              {VECTOR_TIMESTAMP}({WHITE_SPACE}{VECTOR_TIMESTAMP})+{TIMESPAN_STAMP_TYPE}?|
              {VECTOR_TIME}({WHITE_SPACE}{VECTOR_TIME})+{Q_TIME_TYPE}?|
              {VECTOR_MONTH}({WHITE_SPACE}{VECTOR_MONTH})+"m"?|
              {VECTOR_DATE}({WHITE_SPACE}{VECTOR_DATE})+"d"?|
              {VECTOR_DATETIME}({WHITE_SPACE}{VECTOR_DATETIME})+"z"?|
              {BINARY_VECTOR}
C=([^\\\"]|\\[^\ \t])
CHAR=\"{C}\"
CHAR_VECTOR=\"{C}*\"
SYMBOL="`"([._a-zA-Z0-9]+|{CHAR_VECTOR})?
SYMBOL_VECTOR={SYMBOL} ({WHITE_SPACE}*{SYMBOL})+
PRIMITIVE_VERB=[!#$%&*+,-.<=>?@\^_|~]
ADVERB=("/" | \\ | ' | "/": | \\: | ':)+
CONTROL="if"|"do"|"while"
CONDITIONAL=":"|"?"|"$"|"@"|"." // ":" is from k3

%state ADVERB_STATE
%state BLOCK_COMMENT_1
%state BLOCK_COMMENT_2
%state COMMAND_STATE
%state COMMAND_STATE_COMMENT
%state COMMENT_STATE
%state DROP_CUT_STATE

%%

<ADVERB_STATE> {
  {ADVERB}                                    { yybegin(YYINITIAL); return ADVERB;}
}

<BLOCK_COMMENT_1> {
  ^"/"{NEWLINE}                               { yybegin(YYINITIAL); return COMMENT; }
  {NEWLINE}+                                  { return COMMENT; }
  .*                                          { return COMMENT; }
}

<BLOCK_COMMENT_2> {
  ^"\\"{NEWLINE}                              { yybegin(YYINITIAL); return COMMENT; }
  {NEWLINE}+                                  { return COMMENT; }
  .*                                          { return COMMENT; }
}

<COMMAND_STATE> {
  // root, parent & attributes directory
  [.~\^]                                      { yybegin(YYINITIAL); return USER_IDENTIFIER; }
  {WHITE_SPACE}                               { return com.intellij.psi.TokenType.WHITE_SPACE; }
  {USER_IDENTIFIER}                           { yybegin(COMMAND_STATE_COMMENT); return USER_IDENTIFIER; }
  {PATH}                                      { yybegin(COMMAND_STATE_COMMENT); return USER_IDENTIFIER; }
  {NUMBER}                                    { yybegin(COMMAND_STATE_COMMENT); return NUMBER; }
  {NUMBER_VECTOR}                             { yybegin(COMMAND_STATE_COMMENT); return NUMBER_VECTOR; }
  {NEWLINE}+                                  { yybegin(YYINITIAL); return NEWLINE; }
}

<COMMAND_STATE_COMMENT> {
  [^\r\n]+                                    { return COMMENT;}
  {NEWLINE}+                                  { yybegin(YYINITIAL); return NEWLINE; }
}

<COMMENT_STATE> {
  {COMMENT1}                                  { yybegin(YYINITIAL); return COMMENT;}
}

<DROP_CUT_STATE> {
  "_"/{ADVERB}                                { yybegin(ADVERB_STATE); return PRIMITIVE_VERB;}
  "_"                                         { yybegin(YYINITIAL); return PRIMITIVE_VERB;}
}

<YYINITIAL> {
  {NEWLINE}+                                  { return NEWLINE; }
  ^"\\d"                                      { yybegin(COMMAND_STATE); return CURRENT_NAMESPACE; }
  ^{SIMPLE_COMMAND}                           { yybegin(COMMAND_STATE); return COMMAND; }
  ^{COMPLEX_COMMAND}                          { return COMMAND; }
  ^{MODE}                                     { return MODE; }
  {NUMBER_VECTOR}/{ADVERB}                    { yybegin(ADVERB_STATE); return NUMBER_VECTOR; }
  {NUMBER_VECTOR}/"_"                         { yybegin(DROP_CUT_STATE); return NUMBER_VECTOR; }
  {NUMBER_VECTOR}                             { return NUMBER_VECTOR; }
  [0-6]":"/{ADVERB}                           { yybegin(ADVERB_STATE); return PRIMITIVE_VERB; }
  [0-6]":"/[^\[]                              { return PRIMITIVE_VERB; }
  {CONTROL}/"["                               { return CONTROL; }
  {CONDITIONAL}/"["                           { return CONDITIONAL; }
  {SYMBOL_VECTOR}/{ADVERB}                    { yybegin(ADVERB_STATE); return SYMBOL_VECTOR; }
  {SYMBOL_VECTOR}                             { return SYMBOL_VECTOR; }
  {SYMBOL}/{ADVERB}                           { yybegin(ADVERB_STATE); return SYMBOL; }
  {SYMBOL}                                    { return SYMBOL; }
  {WHITE_SPACE}                               { return com.intellij.psi.TokenType.WHITE_SPACE; }
  ^{COMMENT1}                                 { return COMMENT; }
  {COMMENT2}/{NEWLINE}                        { return COMMENT; }
  {COMMENT2}                                  { return COMMENT; }

  "-"/-[0-9]                                  { return PRIMITIVE_VERB;} // --6 -> 6
  {PRIMITIVE_VERB}/{ADVERB}                   { yybegin(ADVERB_STATE); return PRIMITIVE_VERB;}
  {PRIMITIVE_VERB}                            { return PRIMITIVE_VERB;}

  "("                                         { return OPEN_PAREN; }
  ")"/{ADVERB}                                { yybegin(ADVERB_STATE); return CLOSE_PAREN; }
  ")"/"_"                                     { yybegin(DROP_CUT_STATE); return CLOSE_PAREN; }
  ")"                                         { return CLOSE_PAREN; }
  ";"/{COMMENT1}                              { yybegin(COMMENT_STATE); return SEMICOLON; }
  ";"                                         { return SEMICOLON; }
  "["                                         { return OPEN_BRACKET; }
  "]"/{ADVERB}                                { yybegin(ADVERB_STATE); return CLOSE_BRACKET; }
  "]"/"_"                                     { yybegin(DROP_CUT_STATE); return CLOSE_BRACKET; }
  "]"                                         { return CLOSE_BRACKET; }
  "{"                                         { return OPEN_BRACE; }
  "}"/{ADVERB}                                { yybegin(ADVERB_STATE); return CLOSE_BRACE; }
  "}"                                         { return CLOSE_BRACE; }

  {Q_SYSTEM_FUNCTION}/{ADVERB}                { yybegin(ADVERB_STATE); return Q_SYSTEM_FUNCTION; }
  {Q_SYSTEM_FUNCTION}                         { return Q_SYSTEM_FUNCTION; }
  {Q_SQL_TEMPLATE}                            { return Q_SQL_TEMPLATE; }
  "from"                                      { return Q_SQL_FROM; }
  {USER_IDENTIFIER}/{ADVERB}                  { yybegin(ADVERB_STATE); return USER_IDENTIFIER; }
  {USER_IDENTIFIER}                           { return USER_IDENTIFIER; }
  {NUMBER}/{ADVERB}                           { yybegin(ADVERB_STATE); return NUMBER; }
  {NUMBER}/"_"                                { yybegin(DROP_CUT_STATE); return NUMBER; }
  {NUMBER}                                    { return NUMBER; }
  {CHAR}/{ADVERB}                             { yybegin(ADVERB_STATE); return CHAR; }
  {CHAR}                                      { return CHAR; }
  {CHAR_VECTOR}/{ADVERB}                      { yybegin(ADVERB_STATE); return STRING; }
  {CHAR_VECTOR}                               { return STRING; }

  ":"/{ADVERB}                                { yybegin(ADVERB_STATE); return COLON; }
  ":"                                         { return COLON; }
  "'"                                         { return SIGNAL; }
  ^"\\"{NEWLINE}                              { yybegin(BLOCK_COMMENT_1); return COMMENT; }
  ^"/"{NEWLINE}                               { yybegin(BLOCK_COMMENT_2); return COMMENT; }
  "\\"                                        { return TRACE; }

}

[^] { return com.intellij.psi               .TokenType.BAD_CHARACTER; }
