#!/usr/bin/env bash
# Skrypt do testowania skryptu do usuwania duplikatów
set -e

# Usuń poprzedni katalog testowy
rm -rf TEST_DIR
mkdir TEST_DIR

# Tworzymy pliki unikalne
echo "Hello World" > TEST_DIR/file1.txt
echo "Bash scripting" > TEST_DIR/file2.txt

# Tworzymy duplikaty
cp TEST_DIR/file1.txt TEST_DIR/file1_copy.txt
cp TEST_DIR/file2.txt TEST_DIR/file2_copy.txt

# Tworzymy kilka podkatalogów
mkdir -p TEST_DIR/sub1
mkdir -p TEST_DIR/sub2

# Pliki w podkatalogach
echo "Subfolder content" > TEST_DIR/sub1/file3.txt
cp TEST_DIR/sub1/file3.txt TEST_DIR/sub2/file3_copy.txt

# Wyświetlamy strukturę dla sprawdzenia
echo "Struktura katalogu testowego:"
find TEST_DIR -type f

echo ""
echo "Testowe pliki gotowe. Możesz teraz uruchomić swój skrypt:"
echo "./cmd.sh TEST_DIR"
echo "lub z opcją --replace-with-hardlinks:"
echo "./cmd.sh --replace-with-hardlinks TEST_DIR"
