#!/usr/bin/perl
#Jakub Dziurka

use strict;
use warnings;

my %zwierzetaIN;

while(my $zwierze = <STDIN>) {
    chomp $zwierze;
    $zwierzetaIN{$zwierze}++;
}

my @zwierzeta = keys %zwierzetaIN;
my @zwierzetaSORTED = sort @zwierzeta;

foreach my $zwierze (@zwierzetaSORTED) {
    print "$zwierze $zwierzetaIN{$zwierze}\n";
}
