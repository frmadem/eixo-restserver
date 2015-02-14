package Eixo::RestServer::Binder;

use strict;
use Eixo::Base::Clase;

has(

	instance=>undef,

);

sub install{ 
	my ($self, $instance) = @_;

	$self->instance($instance);

	return $_[0]->__install;
}

sub process{
	my ($self, $entity, $verb, %args) = @_;

	$self->instance->process($entity, $verb, %args);
}

sub run{
	my ($self, $head, $args) = @_;

	my ($entity, $verb, %args) = $self->__parser($head, $args);

	$self->instance->process($entity, $verb, %args);
	
}

sub response{
	my ($self, $response) = @_;

}

sub __parser{
	my ($self, $head, $args) = @_;

	#
	# Entity comes from the url
	#	
	my ($entity) = $head->{URL} =~ /^\/(\w+)/;

	my ($verb) = $head->{METHOD};

	#
	# ARGS = (GET + POST)
	#
	my %args = %{$args->{GET_ARGS} || {}}, %{$args->{POST_ARGS} || {}};

	$args{__url} = $head->{URL};

	$entity, $verb, %args;


}


sub __install{

	die(ref($_[0]) . '::__install: ABSTRACT!');

}

1;
