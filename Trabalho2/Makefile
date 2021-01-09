compile: lexer.l parser.y AVLTrees.h AVLTrees.c
	@yacc -d parser.y
	@flex lexer.l
	@gcc AVLTrees.c aux.c y.tab.c `pkg-config --cflags --libs glib-2.0` -w 
	@./a.out < declaration_test.txt

lexer: lexer.l
	@flex aux_lexer.l
	@gcc lex.yy.c

graphAVL: GraphAVL.c AVLTrees.c AVLTrees.h
	@gcc -w AVLTrees.c GraphAVL.c
	@./a.out

parser_error:
	@rm *.out
	@rm lex.yy.c
	@rm y.tab.h
	@rm y.tab.c
	@rm *.dot
	@rm *.vm

clean:
	@rm *.out
	@rm lex.yy.c
	@rm y.tab.h
	@rm y.tab.c
	@rm *.dot
	@rm *.png
	@rm *.vm