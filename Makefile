run: saida.html
	./a.out "$(ARGS)" < aux.txt > saida.html
	dot -Kfdp -Tpng -Goverlap=false -Gsplines=true graph.dot > graph.png

saida.html: lista_autores
	flex filtrobase.l
	gcc lex.yy.c funcs.c -lm

lista_autores:
	flex name_filter.l
	gcc lex.yy.c funcs.c
	./a.out < exemplo-utf8.bib > aux.txt
	cat lista_autores.txt

clean:
	rm a.out
	rm lex.yy.c
	rm aux.txt
	rm lista_autores.txt
	rm saida.htlm
	rm graph.dot
	rm graph.png