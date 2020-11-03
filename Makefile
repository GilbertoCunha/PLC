filtro: filtrobase.l
	@flex filtrobase.l
	@gcc lex.yy.c
	@./a.out < exemplo-utf8.bib > saida.html
	@rm lex.yy.c
	@rm a.out