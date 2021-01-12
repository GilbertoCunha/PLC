debug=no
verbose=no
file=declaration_test.txt

compile: lexer.l parser.y AVLTrees.h AVLTrees.c
	@yacc -d parser.y
	@flex lexer.l
	@gcc AVLTrees.c errors.c translator.c aux.c y.tab.c -w
	@./a.out $(debug) $(verbose) < $(file)

lexer: lexer.l
	@flex aux_lexer.l
	@gcc lex.yy.c

graphAVL: GraphAVL.c AVLTrees.c AVLTrees.h
	@gcc -w AVLTrees.c GraphAVL.c
	@./a.out

clean:
	@rm lex.yy.c
	@rm y.tab.h
	@rm y.tab.c
	@rm *.dot
	@rm *.png
	@rm *.vm