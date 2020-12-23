compile: lexer.l parser.y
	@yacc -d parser.y
	@flex lexer.l
	@gcc y.tab.c `pkg-config --cflags --libs glib-2.0` -w

lexer: lexer.l
	@flex lexer.l
	@gcc lex.yy.c