filtro: filtrobase.l
	@flex filtrobase.l
	@gcc lex.yy.c funcs.c
	@./a.out < exemplo-utf8.bib > saida.html
	@rm lex.yy.c
	@rm a.out
