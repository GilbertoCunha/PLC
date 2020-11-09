run: saida.html
	./a.out "$(ARGS)" < aux.txt > saida.html
	dot -Kfdp -Tpng -Goverlap=false -Gsplines=true graph.dot > graph.png

saida.html: name_filter
	flex filtrobase.l
	gcc lex.yy.c funcs.c -lm

name_filter: lista_autores
	flex name_filter.l
	gcc lex.yy.c
	./a.out < cenas.txt > aux.txt

lista_autores:
	flex and_filter.l
	gcc lex.yy.c funcs.c
	./a.out < exemplo-utf8.bib > cenas.txt
	cat lista_autores.txt

clean:
	rm a.out
	rm lex.yy.c
	rm aux.txt
	rm lista_autores.txt
	rm cenas.txt
	rm saida.htlm
	rm graph.dot
	rm graph.png