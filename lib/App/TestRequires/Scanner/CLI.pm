package App::TestRequires::Scanner::CLI;
use strict;
use warnings;
use utf8;

use App::TestRequires::Scanner;

use File::Zglob;

sub run {
    my @argv = @_;

    my @files = zglob('{t,xt}/**/*.t');
    my $result = App::TestRequires::Scanner->scan_files(@files);
    print "$_\n" for sort keys %$result;
}

1;
