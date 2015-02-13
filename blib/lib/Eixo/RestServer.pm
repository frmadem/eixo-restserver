package Eixo::RestServer;

use 5.008;
use strict;
use warnings;

use lib '/home/fmaseda/Eixo-RestServer/lib';

use attributes;

use Eixo::Base::Clase;
use Eixo::RestServer::Parser;
use Eixo::RestServer::Queues;
use Eixo::RestServer::Job;

my %ATTR;

has(

	server=>undef,

	methods_r=>undef,

	queues=>undef,

	response=>undef,
);

sub initialize{

	$_[0]->queues(

		Eixo::RestServer::Queues->new

	);
}

sub install{
	my ($self) = @_;

	no strict 'refs';

	my $methods = &Eixo::RestServer::Parser::parse($self);

	$self->server->install($self);

	$self->methods_r({

		map {

			$_->{entity} .'_' . $_->{verb} => $_		


		} @$methods

	});
}

sub process{
	my ($self, $entity, $verb, %args) = @_;

	$self->response('');

	my $action = $self->route($entity, $verb);

	$self->__RUN($action, %args) if($action);

}

sub route{
	my ($self, $entity, $verb) = @_;

	if(my $action = $self->methods_r->{$entity . '_' . $verb}){
		return $action->{code};
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

		$self->__defer($code, %args) if(&__hasAdverb($sym, 'DEFER'));

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

	my $id = $args{id} || Eixo::RestServer::Job::ID;

	Eixo::RestServer::Job->new(

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

	&__declareAdverb($code, 'DEFER');

}

	sub __defer{
		my ($self, $method, @args) = @_;

		#
		# Instance a Job
		#
		my $job = $self->jobInstance();

		$self->$method($job, @args);

		$self->ok(

			$job->id	

		);
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

		$self->ok(

			$job->serialize

		);

	}
	else{

		$self->expectationFailed;
	
	}
}



1;
