#!/usr/bin/perl
# Jakub Dziurka

use strict;
use warnings;
use DBI;

my $db_f = "database.db";
unlink $db_f if -e $db_f;

my $db_h = DBI->connect("dbi:SQLite:dbname=$db_f", "", "" , {
    RaiseError => 1, 
    AutoCommit => 1 
});

sub column_type {
    my ($col) = @_;

    if ($col eq 'id') {
        return 'INTEGER UNIQUE';
    }
    elsif ($col =~ /date/i) {
        return 'DATE';
    }
    elsif ($col =~ /^i/) {
        return 'INTEGER';
    }
    else {
        return 'TEXT';
    }
}

foreach my $csv_file (@ARGV) {

    open my $fh, '<', $csv_file
        or die "Nie można otworzyć $csv_file\n";

    (my $table = $csv_file) =~ s/\.csv$//;

    my $header = <$fh>;
    chomp $header;
    my @columns = split /,/, $header;

    my @defs;
    for my $col (@columns) {
        push @defs, "$col " . column_type($col);
    }

    my $create_sql = "CREATE TABLE $table (" . join(", ", @defs) . ")";
    $db_h->do($create_sql);

    my $placeholders = join(",", ("?") x @columns);
    my $insert_sql = "INSERT INTO $table VALUES ($placeholders)";
    my $sth = $db_h->prepare($insert_sql);

    while (my $line = <$fh>) {
        chomp $line;
        my @values = split /,/, $line;
        $sth->execute(@values);
    }

    close $fh;
}

my $query = qq{
    SELECT
        e.name,
        e.surname,
        u.email,
        SUM(s.salary) AS total_salary
    FROM employees e
    JOIN user_data u ON e.id = u.employee_id
    JOIN salaries s ON e.id = s.employee_id
    GROUP BY e.id
    ORDER BY total_salary DESC, u.email ASC
    LIMIT 4
};

my $sth = $db_h->prepare($query);
$sth->execute();

print "Top 4 employees with highest total salaries:\n";
print "----------------------------------------\n";
while (my $row = $sth->fetchrow_arrayref) {
    print "$row->[0] | $row->[1] | $row->[2] | $row->[3]\n";
}

$db_h->disconnect;
