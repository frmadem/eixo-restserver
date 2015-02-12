use t::test_base;

use Eixo::RestServer::BinderTest;

my $test_request;

my $server = A->new(

	server=>$test_request = Eixo::RestServer::BinderTest->new
);

$server->install;

$test_request->request('alumno', 'GET');


package A;

use strict;
use parent qw(Eixo::RestServer);

sub authorized{
	my ($self, %args) = @_;

	$args{my_secret} eq '123'
	

}

sub GET_alumno :Restricted{

}

sub PUT_alumno :Restricted{

}

sub DELETE_alumno :Restricted{

}

sub POST_alumno :Restricted :Defer{
	my ($self, %args) = @_;

	$self->addJob('alumnos', {


	});

}

