package Eixo::RestServer::Job;

use strict;
use Eixo::Base::Clase;

use Data::UUID;

my $UUID_INSTANCE;

BEGIN{
	$UUID_INSTANCE = Data::UUID->new;
}

sub WAITING 	{ 'WAITING' }
sub PROCESSING	{ 'PROCESSING' }
sub FINISHED	{ 'FINISHED' }
sub ERROR	{ 'ERROR' }


sub ID{

	$UUID_INSTANCE->create_str;
}

has(

	id=>undef,

	queue=>undef,

	status=>WAITING,

	tasked=>time,

	args=>{},

	results=>{},

);

sub setArg{
	my ($self, $key, $value) = @_;

	$self->args->{$key} = $value;
}

sub setResult{
	my ($self, $key, $value) = @_;

	$self->results->{$key} = $value;
} 

sub setError{

	$_[0]->status(ERROR);

	$_[0]->setResult('error', $_[1]);


}

1;
