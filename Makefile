run: saida.html
	./a.out "$(ARGS)" < cenas.txt > saida.html
	dot -Kfdp -Tpng -Goverlap=false -Gsplines=true graph.dot > graph.png

saida.html: lista_autores
	flex filtrobase.l
	gcc lex.yy.c funcs.c -lm

lista_autores: name_filter
	flex and_filter.l
	gcc lex.yy.c funcs.c
	./a.out < aux.txt > cenas.txt
	cat lista_autores.txt

name_filter:
	flex name_filter.l
	gcc lex.yy.c
	./a.out < exemplo-utf8.bib > aux.txt

clean:
	rm a.out
	rm lex.yy.c
	rm aux.txt
	rm lista_autores.txt
	rm cenas.txt
	rm graph.dot
	rm graph.png