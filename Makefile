# tool macros
CC := # intentionally not used for the comparison of compilers
CCFLAGS := -Os
DBGFLAGS := # -g
CCOBJFLAGS := $(CCFLAGS) -c

# path macros
BIN_PATH := bin
OBJ_PATH := obj
SRC_PATH := src

# default rule
default: makedir all

# non-phony targets
$(BIN_PATH)/gcc-hello: $(OBJ_PATH)/gcc-hello.o
	gcc -Os obj/gcc-hello.o -o bin/gcc-hello -s
	gcc -Os obj/gcc-hello.o -o bin/gcc-hello-static -s -static

$(BIN_PATH)/musl-hello: $(OBJ_PATH)/musl-hello.o
	musl-gcc -Os obj/musl-hello.o -o bin/musl-hello -s
	musl-gcc -Os obj/musl-hello.o -o bin/musl-hello-static -s -static

$(BIN_PATH)/tcc-hello: $(OBJ_PATH)/tcc-hello.o
	tcc obj/tcc-hello.o -o bin/tcc-hello

$(OBJ_PATH)/gcc-hello.o: $(SRC_PATH)/hello.c
	gcc $(CCOBJFLAGS) $(DBGFLAGS) $(SRC_PATH)/hello.c -o $(OBJ_PATH)/gcc-hello.o

$(OBJ_PATH)/musl-hello.o: $(SRC_PATH)/hello.c
	musl-gcc $(CCOBJFLAGS) $(DBGFLAGS) $(SRC_PATH)/hello.c -o $(OBJ_PATH)/musl-hello.o

$(OBJ_PATH)/tcc-hello.o: $(SRC_PATH)/hello.c
	tcc $(CCOBJFLAGS) $(DBGFLAGS) $(SRC_PATH)/hello.c -o $(OBJ_PATH)/tcc-hello.o

# phony rules
.PHONY: makedir
makedir:
	@mkdir -p $(BIN_PATH) $(OBJ_PATH)

.PHONY: all
all: $(BIN_PATH)/gcc-hello $(BIN_PATH)/musl-hello $(BIN_PATH)/tcc-hello

.PHONY: clean
clean:
	@# "@" prevents this text from echoing to the terminal. We still need the hash so make knows this is a comment.
	@# Gets rid of executables (without a file extension) using the find command
	@# then specifically removes the object files.
	@# find ./bin -type f -not -iname "*.*" -delete && rm -f obj/*.o
	@rm -r bin obj