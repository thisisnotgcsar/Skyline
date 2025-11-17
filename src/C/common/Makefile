LIB = skyline_utils

all: $(LIB).a

$(LIB).a: $(LIB).o
	ar rcs $@ $^

$(LIB).o: $(LIB).c $(LIB).h
	gcc -c $< -o $@

.PHONY: all clean
clean:
	rm -f $(LIB).o $(LIB).a