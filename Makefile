
all: clean
	as -gstabs -o out.o main.S
	gcc -g -no-pie -m64 -lc -lcurl -o bin/main out.o

init:
	sudo apt install libcurl4-openssl-dev
	mkdir -p bin
	touch token.txt
	clear
	more init_notes.txt

clean:
	rm -f out.o
	rm -f bin/*

commit:
	dos2unix *
	git add .
	git commit

# this is used for example to check what value is an C constant
test:
	gcc -lcurl -o bin/test test.c
