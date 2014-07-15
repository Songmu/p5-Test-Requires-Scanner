package App::TestRequires::Scanner;
use 5.008001;
use strict;
use warnings;

our $VERSION = "0.01";

use Compiler::Lexer;
use App::TestRequires::Scanner::Constants;

sub scan_string {
    my ($class, $string) = @_;

    my $lexer = Compiler::Lexer->new;
    my $tokens = $lexer->tokenize($string);

    $class->scan_tokens($tokens);
}

sub scan_tokens {
    my ($class, $tokens) = @_;

    my $module_name         = '';
    my $is_in_usedecl       = 0;
    my $is_in_test_requires = 0;
    my $is_in_reglist       = 0;
    my $is_in_list          = 0;
    my $is_prev_module_name = 0;
    my $is_in_hash          = 0;
    my $does_garbage_exist  = 0;
    my $hash_count          = 0;

    my %result;
    for my $token (@$tokens) {
        my $token_type = $token->{type};

        # For use statement
        if ($token_type == USE_DECL) {
            $is_in_usedecl       = 1;
            $is_prev_module_name = 1;
            next;
        }
        if ($is_in_usedecl) {
            # e.g.
            #   use Foo;
            if ($token_type == USED_NAME) {
                $module_name = $token->{data};
                $is_prev_module_name = 1;
                next;
            }

            # End of declare of use statement
            if ($token_type == SEMI_COLON) {
                $module_name         = '';
                $is_in_usedecl       = 0;
                $is_in_test_requires = 0;
                $is_in_reglist       = 0;
                $is_in_list          = 0;
                $is_prev_module_name = 0;
                $is_in_hash          = 0;
                $does_garbage_exist  = 0;
                $hash_count          = 0;

                next;
            }

            # e.g.
            #   use Foo::Bar;
            if ( ($token_type == NAMESPACE || $token_type == NAMESPACE_RESOLVER) && $is_prev_module_name) {
                $module_name .= $token->{data};
                $is_prev_module_name = 1;
                $is_in_test_requires = $module_name eq 'Test::Requires';
                next;
            }

            if (!$module_name && !$does_garbage_exist && _is_version($token_type)) {
                # For perl version
                # e.g.
                #   use 5.012;
                $is_in_usedecl       = 0;
                $is_prev_module_name = 0;
                next;
            }

            # Section for Test::Requires
            if ($is_in_test_requires) {
                $is_prev_module_name = 0;

                # For qw() notation
                # e.g.
                #   use Test::Requires qw/Foo Bar/;
                if ($token_type == REG_LIST) {
                    $is_in_reglist = 1;
                }
                elsif ($is_in_reglist) {
                    # skip regdelim
                    if ($token_type == REG_EXP) {
                        for my $_module_name (split /\s+/, $token->{data}) {
                            $result{$_module_name} = 0;
                        }
                        $is_in_reglist = 0;
                    }
                }

                # For simply list
                # e.g.
                #   use Test::Requires ('Foo', 'Bar');
                elsif ($token_type == LEFT_PAREN) {
                    $is_in_list = 1;
                }
                elsif ($token_type == RIGHT_PAREN) {
                    $is_in_list = 0;
                }
                elsif ($is_in_list) {
                    if ($token_type == STRING || $token_type == RAW_STRING) {
                        $result{$token->{data}} = 0;
                    }
                }

                # For braced list
                # e.g.
                #   use Test::Requires {'Foo' => 1, 'Bar' => 2};
                elsif ($token_type == LEFT_BRACE ) {
                    $is_in_hash = 1;
                    $hash_count = 0;
                }
                elsif ($token_type == RIGHT_BRACE ) {
                    $is_in_hash = 0;
                }
                elsif ($is_in_hash) {
                    if ( _is_string($token_type) || $token_type == KEY || _is_version($token_type) ) {
                        $hash_count++;
                        $result{$token->{data}} = 0 if $hash_count % 2;
                    }
                }

                # For string
                # e.g.
                #   use Test::Requires "Foo"
                elsif (_is_string($token_type)) {
                    $result{$token->{data}} = 0;
                }
                next;
            }


            if ($token_type != WHITESPACE) {
                $does_garbage_exist  = 1;
                $is_prev_module_name = 0;
            }
            next;
        }

    }

    \%result;
}


sub _is_string {
    my $token_type = shift;
    $token_type == STRING || $token_type == RAW_STRING;
}

sub _is_version {
    my $token_type = shift;
    $token_type == DOUBLE || $token_type == INT || $token_type == VERSION_STRING;
}

1;
__END__

=encoding utf-8

=head1 NAME

App::TestRequires::Scanner - It's new $module

=head1 SYNOPSIS

    use App::TestRequires::Scanner;

=head1 DESCRIPTION

App::TestRequires::Scanner is ...

=head1 LICENSE

Copyright (C) Songmu.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Songmu E<lt>y.songmu@gmail.comE<gt>

=cut

