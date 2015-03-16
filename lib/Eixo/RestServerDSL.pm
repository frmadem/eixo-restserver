package Eixo::RestServerDSL;

use 5.008;
use strict;
use warnings;

use Exporter qw(import);


our @EXPORT = qw(POST GET PUT DELETE PATCH);


#
# Classical method-definers
#
sub GET{

    &__definer('GET',@_);
}

sub POST{
    &__definer('POST',@_);
}

sub PUT{
    &__definer('PUT',@_);
}

sub DELETE{
    &__definer('DELETE',@_);

}

sub PATCH{
    &__definer('PATCH',@_);
}


sub __definer{
    my $clase = (caller(1))[0];

    my ($verb, $url, %args) = @_;

    #push $self->{ROUTES}->{$url},  {method => $verb, args => {%args}}

    my $new_method = &toMethodName($url);

    ($url, my $cortadores) = &placeholders($url);  

    my %fixed_args = %{$args{args} || {}};

    no strict 'refs';

    *{$clase . '::' . $new_method} = sub {

            my ($self, $job, %nargs) = @_;

            my @t = split(/\/+/, $nargs{__url});

            my %url_args = map {

                $_->(\@t)

            } @$cortadores;

            $job->queue($args{queue} || $self->DEFAULT_QUEUE);

            $job->args({(%nargs, %url_args, %fixed_args)});

            $job->args->{command} = ($args{command} || &inferCommand($verb, $url));

            $self->addJob($job);

    };


    Eixo::RestServer::AutomaticPaths->addPath(
    
        $clase,

        $new_method,

        $url,

        $verb        
            
    );

}

sub inferCommand {
    my ($verb, $url) = @_;

    my @parts =  ( grep { $_ !~ /\*/ } split /\//, $url);

    return ucfirst($parts[1]).'.'.$parts[2];
}


sub placeholders{
    my ($url) = @_;

    my $tramo = 0;

    my @cortadores;

    map {
 
        if($_ =~ /\:(\w+)/)  {

            my $clave = $1;
            my $n = $tramo;

            push @cortadores, sub {

                    $clave => $_[0]->[$n]

            };

        }

        $tramo++;
       
        #/foo/:id/:accion/lanzar
        #
        # /foo/346/borrar/lanzar

    } split(/\/+/, $url); 

    $url =~ s/\:(\w+)/\*/g;

    $url, \@cortadores;
}


sub toMethodName{
    my ($url) = @_;

    $url =~ s/\//_/g;
    $url =~ s/\:/_/g;

    $url;
}

1;
