#!/usr/bin/perl
#Jakub Dziurka

use strict;
use warnings;

use lib '.';
use Modul;

die "ARG ERROR\n" if @ARGV < 4;

my ($xls, $csv, $n, $m) = @ARGV;

Modul::init($n, $m);
Modul::addReadXLS($xls);
Modul::saveCSV($csv);
