package Eixo::RestServer::Router;

use strict;
use Eixo::Base::Clase;

has(

    resolve_put=>{},        

    resolve_post=>{},

    resolve_get =>{},

    resolve_delete=>{},
        
);

sub setResolve{
    my ($self, $verb, $resolve, $method) = @_;

    my $resolver = $self->{'resolve_' . lc($verb)};

    $resolver->{$self->normalizeResolve($resolve)} = $method;
}

sub route{
    my ($self, $verb, $url) = @_;

    my $resolver = $self->{'resolve_' . lc($verb)};

    foreach my $r (keys(%{$resolver})){

        if($self->match($url, $r)){
            
            return $resolver->{$r};

        }
    }
    
}


sub match{
    my ($self, $url, $resolve) = @_;

    $url =~ $resolve;       
}

sub normalizeResolve{
    my ($self, $query) = @_;

    my @t = map {
        
        if($_ eq '*') {

                '[^\/]+'

        }
        else{
                $_;
        }
        
    } split(/\/+/, $query);

    my $reg = '/'.join('/', @t);

    qr{$reg};
}


1;
