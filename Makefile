saida.html: lex.yy.c 
	gcc lex.yy.c funcs.c
	./a.out < cenas.txt > saida.html
lex.yy.c: filtrobase.l and_filter.l
	flex and_filter.l
	gcc lex.yy.c
	./a.out < exemplo-utf8.bib > cenas.txt
	flex filtrobase.l
clean: 
	rm a.out
	rm lex.yy.c 
	
   
