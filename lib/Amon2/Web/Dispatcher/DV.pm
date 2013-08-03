package Amon2::Web::Dispatcher::DV;
use strict;
use warnings;
our $VERSION = "0.01";
use Data::Validator;
use Router::Simple;

sub import {
    my $class = shift;
    my $caller = caller(0);

    my $router = Router::Simple->new();

    no strict 'refs';
    *{"$caller\::dispatch"} = sub {
        my ($klass, $c) = @_;

        if (my $controller = $router->match($c->req->env)) {
            my $rule = $controller->{rule} or die;
            my $args = $rule->validate(%{$c->req->parameters});
            if ($rule->has_errors) {
                my $errors = $rule->clear_errors;
                my $message = join("\n", map { $_->{message} } @$errors);
                my $res = $c->render_json( +{ error => +{ message => $message } } );
                $res->code(400);
                return $res;
            }
            my $res = $controller->{code}->($c, $args);
            if (ref $res eq 'HASH') {
                return $c->render_json($res); # succeeded
            } else {
                return $res; # succeeded
            }
        } else {
            return $c->res_404(); # not found...
        }
    };

    *{"$caller\::post"} = sub {
        my ($path, $rule_src, $code) = @_;
        my $rule = Data::Validator->new(@$rule_src)->with('NoThrow');
        $router->connect($path,
            +{
                code => $code,
                rule => $rule,
            },
            {method => 'POST'}
        );
    };
    *{"$caller\::get"} = sub {
        my ($path, $rule_src, $code) = @_;
        my $rule = Data::Validator->new(@$rule_src)->with('NoThrow');
        $router->connect($path,
            +{
                code => $code,
                rule => $rule,
            },
            {method => 'GET'}
        );
    };
    *{"$caller\::any"} = sub {
        if (@_ == 4) {
            my ($methods, $path, $rule_src, $code) = @_;
            my $rule = Data::Validator->new(@$rule_src)->with('NoThrow');
            $router->connect($path,
                +{
                    code => $code,
                    rule => $rule,
                },
                {method => [map { uc $_ } @$methods]}
            );
        } else {
            my ($path, $rule_src, $code) = @_;
            my $rule = Data::Validator->new(@$rule_src)->with('NoThrow');
            $router->connect($path,
                +{
                    code => $code,
                    rule => $rule,
                }
            );
        }
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Amon2::Web::Dispatcher::DV - Sinatra like dispatcher with Data::Validator

=head1 SYNOPSIS

    use Amon2::Web::Dispatcher::DV;

    get '/api/v1/branch/list' => [
        project  => { isa => 'Str' },
    ] => sub {
        my ($c, $args) = @_;

        return +{
            branches => scalar(Ukigumo::Server::Command::Branch->list(
                %$args
            ))
        };
    };

=head1 DESCRIPTION

Most of code taken from L<Ukigumo::Server::API::Dispatcher>.

=head1 LICENSE

Copyright (C) Takumi Akiyama.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Takumi Akiyama E<lt>t.akiym@gmail.comE<gt>

=cut

