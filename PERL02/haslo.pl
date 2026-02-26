#!/usr/bin/perl
# Jakub Dziurka
use strict;
use warnings;

# wejście
my $input = shift or die "Usage: $0 szyfr.txt\n";

open my $IN, '<:raw', $input or die "Cannot open $input: $!";
local $/;
my $text = <$IN>;
close $IN;

# normalizacja
$text = uc $text;
$text =~ s/[^A-Z ]/ /g;
$text =~ s/\s+/ /g;

# alfabet
my @alphabet = ('A'..'Z','_');

# częstotliwość znaków
my %char_freq;
$char_freq{$_} = 0 for @alphabet;
$char_freq{$_}++ for split //, $text;

my @cipher_rank = sort { $char_freq{$b} <=> $char_freq{$a} } @alphabet;

my @lang_rank = qw(
    _ A E I O N Z S R W C T Y K D P M L U B G H J F V X Q
);

# wc.pl
(my $wc_text = $text) =~ s/_/ /g;
open my $TMP, '>', 'tmp.txt';
print $TMP $wc_text;
close $TMP;

system("perl ./wc.pl -p -x tmp.txt > tmp.out");

open my $W, '<', 'tmp.out';

my %word_freq;
while (<$W>) {
    chomp;
    my ($w,$n) = split /\s+/, $_, 2;
    $w =~ s/\?/_/g;
    $word_freq{$w} = $n;
}
close $W;

for my $key (keys %word_freq) {
    print "$key => $word_freq{$key}\n";
}

unlink 'tmp.txt';
unlink 'tmp.out';

my @common_words = qw(
    I SIE NIE NA Z ZE DO TO W PAN JEST BYL
);

# ===== pomocnicze =====
sub idx {
    my $c = shift;
    return 26 if $c eq '_';
    return ord($c) - 65;
}

sub decrypt_word {
    my ($map,$w) = @_;
    join '', map {
        substr($map, idx($_), 1)
    } split //, $w;
}

# ===== BUDOWANIE MAPOWAŃ =====
my @maps;
my $EMPTY = '?' x 27;

sub build_maps {
    my ($map, $pos) = @_;

    if ($pos >= @cipher_rank) {
        push @maps, $map;
        return;
    }

    my $c = $cipher_rank[$pos];
    my $i = idx($c);

    if (substr($map,$i,1) ne '?') {
        build_maps($map, $pos+1);
        return;
    }

    my @candidates = ($lang_rank[$pos]);

    # sytuacja wątpliwa → rozgałęzienie
    if ($pos+1 < @cipher_rank &&
        abs($char_freq{$cipher_rank[$pos]}
          - $char_freq{$cipher_rank[$pos+1]}) < 0.01 * length($text)) {
        push @candidates, $lang_rank[$pos+1];
    }

    for my $p (@candidates) {
        next if $map =~ /\Q$p\E/;
        my $m2 = $map;
        substr($m2,$i,1) = $p;
        build_maps($m2, $pos+1);
    }
}

build_maps($EMPTY, 0);

# ===== SCORING =====
sub score {
    my $map = shift;
    my $s = 0;

    for my $w (keys %word_freq) {
        my $dw = decrypt_word($map,$w);
        $s += $word_freq{$w}
            if grep { $_ eq $dw } @common_words;
    }
    return $s;
}

my ($best, $best_score) = ('', -1);

for my $m (@maps) {
    my $s = score($m);
    if ($s > $best_score) {
        $best = $m;
        $best_score = $s;
    }
}

# ===== ODWROTNY KLUCZ =====
my $result = '?' x 27;

for my $i (0..26) {
    my $p = substr($best,$i,1);
    next if $p eq '?';
    substr($result, idx($p), 1) =
        $i==26 ? '_' : chr(65+$i);
}

print "$result\n";
