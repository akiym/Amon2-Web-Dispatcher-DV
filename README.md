# NAME

Amon2::Web::Dispatcher::DV - Sinatra like dispatcher with Data::Validator

# SYNOPSIS

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

# DESCRIPTION

Most of code taken from [Ukigumo::Server::API::Dispatcher](http://search.cpan.org/perldoc?Ukigumo::Server::API::Dispatcher).

# LICENSE

Copyright (C) Takumi Akiyama.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

Takumi Akiyama <t.akiym@gmail.com>
