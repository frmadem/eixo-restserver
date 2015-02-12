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

has(

	server=>undef,

	methods_r=>undef,

	queues=>Eixo::RestServer::Queues->new,

	response=>undef,
);

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

	my $action = $self->route($entity, $verb);

	$self->__RUN($action, %args) if($action);

}

sub route{
	my ($self, $entity, $verb) = @_;

	if(my $action = $self->methods_r->{$entity . '_' . $verb}){
		return $action->{code};
	}
	else{
		$self->notFound;
	}

}


	sub __RUN{
		my ($self, $code, %args) = @_;

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
}



sub notFound{

	use Data::Dumper; die(Dumper($_[0]));

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
sub Restricted :ATTR(CODE){
	#my ($pkg, $sym, $code, $attr_name, $data) = @_;	

	#no warnings 'redefine';

	#*{$sym} = sub {

	#	my ($self, @args) = @_;

	#	if($self->authorized(@args)){
	#		$code->($self, @args);
	#	}
	#	else{

	#		$self->not_authorized();
	#	}


	#};

}

#
# Deferred execution 
#
sub Defer :ATTR(CODE){
	my ($pkg, $sym, $code, $attr_name, $data) = @_;	

	no warnings 'redefine';

	*{$sym} = sub {

		my ($self, @args) = @_;

		

	};
	

}

	sub __defer{
		my ($self, $method, @args) = @_;

		#
		# Instance a Job
		#
		my $job = $self->jobInstance();

		$self->$method($job, @args);
	}


1;
