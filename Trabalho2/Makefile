compile: lexer.l parser.y
	@yacc -d parser.y
	@flex lexer.l
	@gcc y.tab.c

lexer: lexer.l
	@flex lexer.l
	@gcc lex.yy.c