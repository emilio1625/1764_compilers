CC		=	gcc
CFLAGS	=	-Wall -Wextra -g3 -std=gnu99 -I./include
MAINC	=	"src/main.c"
PARSERC	=	"src/parser.c"
PARSERH	=	"include/parser.h"
LEXERC	=	"src/lexer.c"
LEXERH	=	"include/lexer.h"
TTABLEC =	"src/tabla_tipos.c"
STABLEC =	"src/tabla_simbolos.c"
STACKC  =   "src/stack.c"
PARSERD	=	"src/parser.dot"
PARSERI	=	"parser.png"
OUTPUT	=	"compilador"
TESTF	=	"fibonacci.e"

src/lexer.c include/lexer.h: src/lexer.l
	flex --header-file=$(LEXERH) --outfile=$(LEXERC) src/lexer.l

src/parser.c include/parser.h: src/parser.y
	bison --defines=$(PARSERH) --output=$(PARSERC) src/parser.y

src/parser.dot: src/parser.y
	bison --defines=$(PARSERH) --output=$(PARSERC) --graph=$(PARSERD) src/parser.y

parser.png: src/parser.dot
	dot -Tpng $(PARSERD) > $(PARSERI)

compiler: src/main.c src/lexer.c src/parser.c include/parser.h include/lexer.h
	gcc $(CFLAGS) -o $(OUTPUT) $(STACKC) $(TTABLEC) $(STABLEC) $(PARSERC) $(LEXERC) $(MAINC)

test:
	./$(OUTPUT) $(TESTF)

all: clean compiler test

clean:
	rm -rf $(PARSERC) $(PARSERH) $(LEXERC) $(LEXERH) $(PARSERD) $(PARSERI) $(OUTPUT)
