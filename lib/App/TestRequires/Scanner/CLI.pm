package App::TestRequires::Scanner::CLI;
use strict;
use warnings;
use utf8;

use App::TestRequires::Scanner;
use App::TestRequires::Scanner::Result;

use File::Zglob;

sub run {
    my @argv = @_;

    my @files = zglob('{t,xt}/**/*.t');
    my $result = _scan_files(@files);
    print "$_\n" for sort keys %$result;
}

sub _scan_files {
    my @files = @_;

    my $result = App::TestRequires::Scanner::Result->new;

    for my $file (@files) {
        my $ret = App::TestRequires::Scanner->scan_file($file);
        $result->save_module($_, $ret->{$_}) for keys %$ret;
    }

    $result->modules;
}

1;
