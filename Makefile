saida.html: lex.yy.c funcs.o 
	gcc lex.yy.c funcs.o
	./a.out < exemplo-utf8.bib > saida.html
lex.yy.c: filtrobase.l
	flex filtrobase.l
funcs.o: funcs.c funcs.h
	gcc -c funcs.c
clean: 
	rm a.out
	rm lex.yy.c 
	
   
