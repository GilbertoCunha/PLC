run: saida.html
	./a.out "$(ARGS)" < cenas.txt > saida.html
	dot -Kfdp -Tpng -Goverlap=false -Gsplines=true graph.dot > graph.png

saida.html: lex.yy.c 
	gcc lex.yy.c funcs.c -lm

lex.yy.c: filtrobase.l and_filter.l
	flex and_filter.l
	gcc lex.yy.c
	./a.out < exemplo-utf8.bib > cenas.txt
	flex filtrobase.l

clean: 
	rm a.out
	rm lex.yy.c 
	rm graph.dot
	rm graph.png
	rm cenas.txt
