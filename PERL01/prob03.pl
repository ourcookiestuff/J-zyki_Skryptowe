#!/usr/bin/perl
#Jakub Dziurka

use strict;
use warnings;

my ($fileA, $fileB, $fileOut) = @ARGV;

# Wczytywanie macierzy A
open my $fA, '<', $fileA or die "Nie można otworzyć $fileA: $!";
my @A;

while (<$fA>) {
    next if /^\s*$/;
    my @row = split;
    push @A, \@row;
}
close $fA;

# Wczytywanie macierzy B
open my $fB, '<', $fileB or die "Nie można otworzyć $fileB: $!";
my @B;

while (<$fB>) {
    next if /^\s*$/;
    my @row = split;
    push @B, \@row;
}
close $fB;

# Wymiary
my $rowsA = @A;
my $colsA = @{$A[0]};
my $rowsB = @B;
my $colsB = @{$B[0]};

if ($colsA != $rowsB) {
    die "Wymiary macierzy nie pasują do mnożenia!\n";
}

# Mnożenie macierzy
my @C;

for my $i (0 .. $rowsA - 1) {
    for my $j (0 .. $colsB - 1) {
        my $sum = 0;
        for my $k (0 .. $colsA - 1) {
            $sum += $A[$i][$k] * $B[$k][$j];
        }
        $C[$i][$j] = $sum;
    }
}

# Zapis wyniku
open my $out, '>', $fileOut or die "Nie można zapisać do $fileOut: $!";

for my $i (0 .. $#C) {
    for my $j (0 .. $#{$C[$i]}) {
        printf $out "%8.3f", $C[$i][$j];

        print $out " " if $j < $#{$C[$i]};
    }
    print $out "\n";
}

close $out;
