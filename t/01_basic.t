use strict;
use warnings;
use utf8;
use Test::More;

use App::TestRequires::Scanner;

my $ret = App::TestRequires::Scanner->scan_string('use Test::Requires 0.99 {"DBI" => 1};');
is_deeply [keys %$ret], ['DBI'];

$ret = App::TestRequires::Scanner->scan_string('use Test::Requires {DBI => "1"};');
is_deeply [keys %$ret], ['DBI'];

$ret = App::TestRequires::Scanner->scan_string('use Test::Requires 0.99 "DBI";');
is_deeply [keys %$ret], ['DBI'];

$ret = App::TestRequires::Scanner->scan_string('use Test::Requires 0.99 ("DBI");
use Test::More 0.98'
);
is_deeply [keys %$ret], ['DBI'];

done_testing;

__DATA__

use Test::Requires 0.07 {DBI => 0.01, };
use Test::Requires 'DBI';

