package Eixo::RestServer::AutomaticPaths;

use strict;
use Eixo::Base::Clase 'Eixo::Base::Singleton';

has(

    servers=>{}        
        
);

sub addPath{
    my ($instance, $class, $method, $url, $verb) = @_;

    $instance->servers->{$class} = [] unless($instance->servers->{$class});

    push @{$instance->servers->{$class}}, {

        method=>$method,

        url=>$url,

        verb=>$verb

    };

}

sub getPaths{
    my ($instance, $class) = @_;

    $instance->servers->{$class} || [];
}


__PACKAGE__->make_singleton();

1;
