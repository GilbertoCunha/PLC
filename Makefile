run: saida.html
	./a.out "$(name)" < aux.txt > saida.html
	dot -Kfdp -Tpng -Goverlap=false -Gsplines=true graph.dot > graph.png

saida.html: name_filter
	flex filtrobase.l
	gcc lex.yy.c funcs.c -lm

find_authors: name_filter
	grep -e "$(name)" -o lista_autores.txt

name_filter:
	flex name_filter.l
	flex name_filter.l
	gcc lex.yy.c funcs.c
	./a.out < "$(file)" > aux.txt

list_authors:
	flex name_filter.l
	gcc lex.yy.c funcs.c
	./a.out < $(file)$ > aux.txt
	cat lista_autores.txt

clean:
	rm a.out
	rm lex.yy.c
	rm aux.txt
	rm lista_autores.txt
	rm graph.dot
	rm graph.png
	rm saida.htlm