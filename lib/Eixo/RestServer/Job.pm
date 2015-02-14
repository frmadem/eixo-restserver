package Eixo::RestServer::Job;

use strict;
use Eixo::Base::Clase;

use JSON -convert_blessed_universally;
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

sub finished{

	$_[0]->status(FINISHED);

}

sub processing{

	$_[0]->status(PROCESSING);
}

sub serialize{
	my ($self) = @_;

	JSON->new->convert_blessed->encode( $self )
}

sub unserialize{
	my ($package, $data) = @_;

	if(ref($package)){
		$package = ref($package);
	}

	bless(JSON->new->decode($data), $package);
}

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
