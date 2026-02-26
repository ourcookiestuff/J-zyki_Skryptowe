#!/usr/bin/perl
#Jakub Dziurka

use strict;
use warnings;

# parsowanie argumentów
my %opt = (
    c => 0,
    m => 0,
    l => 0,
    i => 0,
    w => 0,
    p => 0,
    x => 0,
);

while (@ARGV and $ARGV[0] =~ /^-(.+)/) {
    my $flags = $1;
    shift @ARGV;

    foreach my $f (split //, $flags) {
        die "Unsupported option -$f\n" unless exists $opt{$f};
        $opt{$f} = 1;
    }
}

if (!$opt{c} && !$opt{m} && !$opt{l} && !$opt{w} && !$opt{p}) {
    $opt{l} = 1;
    $opt{w} = 1;
    $opt{c} = 1;
}

# plik lub stdin
my $filename = '-';
if (@ARGV > 0) {
    $filename = $ARGV[0];
}

my $fh;
if ($filename eq '-') {
    $fh = *STDIN;
} else {
    open($fh, '<', $filename) or die "Cannot open $filename: $!";
}

# liczenie poszczególnych opcji
my $bytes = 0;
my $chars = 0;
my $lines = 0;
my $words = 0;

my %freq;

while (my $line = <$fh>) {

    if ($opt{l}) {
        $lines++;
    }

    if ($opt{c}) {
        $bytes += length($line);
    }

    if ($opt{m}) {
        use Encode 'decode';
        my $decoded = decode('UTF-8', $line);
        $chars += length($decoded);
    }

    if ($opt{w}) {
        my @w = split /\s+/, $line;
        $words += scalar grep { length } @w;
    }

    if ($opt{p}) {
        chomp $line;
        my @raw = split /[ \t\r\n]+/, $line;

        for my $word (@raw) {
            if (length($word) == 0) {
                next;
            }

            my $key = $word;
            $key = lc $key if $opt{i};
            $freq{$key}++;
        }
    }
}

# wypisywanie wyników
if ($opt{l}) {
    printf "%d %s\n", $lines,  $filename;
} 
if ($opt{w}) {
    printf "%d %s\n", $words,  $filename;
}
if ($opt{c}) {
    printf "%d %s\n", $bytes,  $filename;
}
if ($opt{m}) {
    printf "%d %s\n", $chars,  $filename;
}
if ($opt{p}) {
    my @items;

    for my $w (keys %freq) {
        my $printed = $w;
        $printed =~ s/[^a-zA-Z]/?/g;
        push @items, [$printed, $freq{$w}];
    }

    my $limit = 9;
    if ($opt{x}) {
        $limit = 200;
    }

    @items = sort {$b->[1] <=> $a->[1] || $a->[0] cmp $b->[0]} @items;

    for my $i (0 .. $limit) {
        last if $i > $#items;
        print "$items[$i][0] $items[$i][1]\n";
    }
}
