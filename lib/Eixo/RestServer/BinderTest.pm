package Eixo::RestServer::BinderTest;

use strict;
use Eixo::Base::Clase;
use parent qw(Eixo::RestServer::Binder);

has(

	on_request=>undef,

	on_response=>undef,

);

sub request{
	my ($self, $entity, $verb, %args) = @_;

	$self->on_request->($entity, $verb, %args);		
}

sub response{

	$_[0]->on_response->(@_[1..$#_]);

}

sub __install{
	my ($self) = @_;

	$_[0]->on_request(sub {

		$self->process(@_);

	});
	
}

1;
