#!/usr/bin/perl
#Jakub Dziurka

use strict;
use warnings;

my @zwierzeta = ("kot", "pies", "papuga", "kanarek", "ryba");

print "$zwierzeta[0]\n";

my $liczba = scalar @zwierzeta;
print "$liczba\n";

$zwierzeta[1] = "kanarek";

push(@zwierzeta, "żaba");
$liczba = scalar @zwierzeta;
print "$liczba\n";

pop(@zwierzeta);
$liczba = scalar @zwierzeta;
print "$liczba\n";

foreach my $zwierze (@zwierzeta) {
    print "$zwierze\n";
}

for my $i (0..$#zwierzeta) { 
    print "$i $zwierzeta[$i]\n";
}

for my $i (1..3) {
    print "$zwierzeta[$i]\n";
}
