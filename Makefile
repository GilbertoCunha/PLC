run: saida.html
	@./a.out "$(name)" "html" < aux.txt > saida.html
	@dot -Kfdp -Tpng -Goverlap=false -Gsplines=true graph.dot > graph.png

saida.html: name_filter
	@flex filtrobase.l
	@gcc lex.yy.c funcs.c

find_author: name_filter
	@flex filtrobase.l	
	@gcc lex.yy.c funcs.c
	@./a.out "$(name)" "index" < aux.txt > aux2.txt
	@rm aux.txt
	@rm aux2.txt
	@cat author.txt
	@rm author.txt

name_filter:
	@flex name_filter.l
	@flex name_filter.l
	@gcc lex.yy.c funcs.c
	@./a.out < "$(file)" > aux.txt

list_authors:
	@flex name_filter.l
	@gcc lex.yy.c funcs.c
	@./a.out < $(file)$ > aux.txt
	@cat lista_autores.txt

clean:
	@rm a.out
	@rm lex.yy.c
	@rm aux.txt
	@rm lista_autores.txt
	@rm graph.dot
	@rm graph.png
	@rm saida.htlm