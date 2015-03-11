package Eixo::RestServer;


use 5.008;
use strict;
use warnings;

use attributes;

use Eixo::Base::Clase;
use Eixo::RestServer::Parser;
use Eixo::Queue::Queues;
use Eixo::Queue::Job;

use Eixo::RestServer::Router;
use Eixo::RestServer::AutomaticPaths;

use MIME::Base64;

our $VERSION = '0.006';
our @EXPORT = qw(POST GET PUT DELETE);

my %ATTR;

my %URLS;

has(

	server=>undef,

	methods_r=>undef,

	queues=>undef,

	response=>undef,

    router=>undef,
);

sub initialize{

	$_[0]->queues(

		Eixo::Queue::Queues->new

	);

    $_[0]->router(
    
        Eixo::RestServer::Router->new

    ) unless($_[0]->router);
}

sub install{
	my ($self) = @_;

	no strict 'refs';

	my $methods = &Eixo::RestServer::Parser::parse($self);

	$self->methods_r({

		map {

			$_->{entity} .'_' . $_->{verb} => $_		


		} @$methods

	});

    #
    # Declare paths 
    #
    foreach(@{Eixo::RestServer::AutomaticPaths->getPaths(ref($self))}){

            $self->router->setResolve(
            
                    $_->{verb},

                    $_->{url},

                    $_->{method}    

            );
    }

	return $self->server->install($self);
}

sub process{
	my ($self, $entity, $verb, %args) = @_;

	$self->response('');

	my ($action, $routed) = $self->route($entity, $verb, $args{__url});

	$self->__RUN($action, %args, __forceDefer=>$routed) if($action);

}

sub route{
	my ($self, $entity, $verb, $url) = @_;

	if(my $action = $self->methods_r->{$entity . '_' . $verb}){
		return $action->{code};
	}
    elsif($action = $self->router->route($verb, $url)){
        return $self->can($action), '__forceDefer';
    }
	else{
		return $self->can('notFound');
	}

}


sub __RUN{
	my ($self, $code, %args) = @_;

	my $sym = ref($code) ? $code : ($code = $self->can($code));

	$self->__restricted(%args) if(&__hasAdverb($sym, 'RESTRICTED'));

	if(my $d = &__hasAdverb($sym, 'F')){

		%args = $self->__formatArgs($d->{formatter}, %args) 

	}

 
	if(my $d = &__hasAdverb($sym, 'DEFER')){

		$self->__defer($code, $d->{queue}, %args);

	}

    if($args{__forceDefer}){
        
        $self->__defer($code, undef, %args);

    }

	$self->$code(%args);

	END_RUN:

	$self->server->response(

		$self->response

	);

}

#
# Queues
# 

sub createQueue{
	my ($self, $queue) = @_;

	$self->queues->createQueue($queue);

}

#
# Jobs
#
sub addJob{
	my ($self, $job) = @_;

	$self->queues->addJob($job);
}

sub getJob{
	my ($self, $id) = @_;

	$self->queues->getJob($id);
}

#
# Job helper
#
sub jobInstance{
	my ($self, %args) = @_;

	my $id = $args{id} || Eixo::Queue::Job::ID;

	Eixo::Queue::Job->new(

		id=>$id

	);
}



sub notFound{

	$_[0]->ko(

		'404'

	);

}

sub notAuthorized{

	$_[0]->ko(

		'403'
	);
}

sub badRequest{

	$_[0]->ko(

		'400'

	);
}

sub expectationFailed{

	$_[0]->ko(

		'417'

	);
}

sub accepted{

	$_[0]->response({

		code=>202,

		body=>$_[1]

	});
	
}

sub ok{
	my ($self, $response) = @_;
	
	$self->response({

		code=>200,

		body=>$response

	});

	goto END_RUN;
}

sub ko{
	my ($self, $code, $response) = @_;

	$self->response({
		code=>$code,

		body=>$response

	});

	goto END_RUN;
}




#
# Restricted install
#
sub Restricted :ATTR(ANY){
	my ($pkg, $sym, $code, $attr_name, $data) = @_;	

	&__declareAdverb($code, 'RESTRICTED');

}

	sub __restricted{
		my ($self, @args) = @_;

		$self->authorized(@args) || $self->notAuthorized();

	}

#
# Deferred execution 
#
sub Defer :ATTR(CODE){
	my ($pkg, $sym, $code, $attr_name, $data) = @_;	

	&__declareAdverb($code, 'DEFER', queue=>$data->[0]);

}

	sub __defer{
		my ($self, $method, $queue, @args) = @_;

		#
		# Instance a Job
		#
		my $job = $self->jobInstance();

		$job->queue($queue);

		$self->$method($job, @args);

		if($job->status eq 'FINISHED'){

			$self->ok(

				$job->serialize

			);

		}
		else{

			$self->accepted(

				$job->id	

			);

			goto END_RUN;
		}
	}

#
# Url format
#
sub F :ATTR(CODE){
	my ($pkg, $sym, $code, $attr_name, $data) = @_;	

	my $formatter =  sub {

		$_[0] =~ s/^\/+//;

		my ($entity, @parts) = split(/\/+/, $_[0]);

		my $i = 0;

		map {

			$_ => $parts[$i++]

		} @{$data || []};

	};

	&__declareAdverb($code, 'F', formatter=>$formatter);
}

	sub __formatArgs{
		my ($self, $formatter, %args) = @_;

		if(my $url = $args{__url}){

			%args = (%args, $formatter->($url));

		}

		%args;
	}

#
# Adverbs
#
sub __declareAdverb{
	my ($sym, $value, %args) = @_;

	$ATTR{$sym} = {} unless($ATTR{$sym});

	$ATTR{$sym}->{$value} = \%args;

}

sub __hasAdverb{
	my ($sym, $value) = @_;

	if(my $h = $ATTR{$sym}){

		$h->{$value};
	}

}


#======================================
#    Default methods
#======================================
sub GET_job :F(id){
	my ($self, %args) = @_;	

	$self->badRequest unless($args{id});

	if(my $job = $self->getJob($args{id})){

		$self->accepted(

			$job->serialize

		);

	}
	else{

		$self->notFound;
	
	}
}

#
# Classical method-definers
#
sub GET{

        my $class = (caller(0))[0];

        $class->DEFINER('GET', @_[1..$#_]);
}

sub POST{

        my $class = (caller(0))[0];

        $class->DEFINER('POST', @_[1..$#_]);
}

sub PUT{

        my $class = (caller(0))[0];

        $class->DEFINER('PUT', @_[1..$#_]);

}

sub DELETE{

        my $class = (caller(0))[0];

        $class->DEFINER('DELETE', @_[1..$#_]);

}

sub DEFINER{
    my ($clase, $verb, $url, %args) = @_;

    my $new_method = $clase->toMethodName($url);

    ($url, my $cortadores) = $clase->placeholders($url);  

    no strict 'refs';

    *{$clase . '::' . $new_method} = sub {
            my ($self, $job, %nargs) = @_;

            my @t = split(/\/+/, $args{__url});

            my %url_args = map {

                $_->(\@t)

            } @$cortadores;

            $job->queue($args{queue}) if(exists($args{queue}));

            $job->args({%nargs, %url_args, %{$args{args}}});

            $job->command($args{command} || $clase->inferCommand($verb, $url));
    };

    Eixo::RestServer::AutomaticPaths->addPath(
    
        $clase,

        $new_method,

        $url,

        $verb        
            
    );

}

sub inferCommand {
    my ($self, $verb, $url) = @_;

    my @partes =  (grep { !~ /\*/ } split /\//, $url);

    return uc_first($parts[0]).'.'.$partes[1];
}

sub placeholders{
    my ($self, $url) = @_;

    my $tramo = 0;

    my @cortadores;

    map {
 
        if($_ =~ /\:(\w+)/)  {

            my $clave = 1;
            my $n = $tramo;

            push @cortadores, sub {

                    $clave = $_[0]->[$n]

            };

            $tramo++;
        }

    } split(/\//, $url); 

    $url =~ s/\:(\w+)/\*/g;

    $url, \@cortadores;
}

sub toMethodName{
    my ($self, $url) = @_;

    $url =~ s/\//_/g;
    $url =~ s/\:/_/g;

    $url;
}

1;
