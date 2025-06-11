CC = g++
CFLAGS = -O2 -march=native
LDFLAGS = -lseccomp
TARGET = gen-filter
SOURCE = gen-filter.cpp

all: $(TARGET)

$(TARGET): $(SOURCE)
	$(CC) $(SOURCE) $(LDFLAGS) $(CFLAGS) -o $(TARGET)
	chmod +x $(TARGET)

clean:
	rm -f $(TARGET)

.PHONY: all clean
