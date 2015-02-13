use t::test_base;

use Eixo::RestServer::BinderTest;

my $test_request;

my $RESPONSE;

my $server = A->new(

	server=>$test_request = Eixo::RestServer::BinderTest->new(

		on_response=>sub {

			$RESPONSE = $_[0];

		}

	)
);

$server->install;

$test_request->request('alumno', 'GET');

ok($RESPONSE && ref($RESPONSE) eq 'HASH', 'A response has been obtained');

ok($RESPONSE->{code} == 200, 'Response\'s code is ok');

ok($RESPONSE->{body} eq 'GET_alumno', 'Body is all right');

$test_request->request('alumno', 'PUT');

ok($RESPONSE && ref($RESPONSE) eq 'HASH', 'A response has been obtained');

ok($RESPONSE->{code} == 403, 'Response\'s code is ok');

$test_request->request('alumno', 'PUT', my_secret=>'123');

ok($RESPONSE && ref($RESPONSE) eq 'HASH', 'A response has been obtained');

ok($RESPONSE->{code} == 200, 'Response\'s code is ok');

ok($RESPONSE->{body} eq 'PUT_alumno', 'Body is all right');

$test_request->request('teacher', 'PUT', my_secret=>'123');

ok($RESPONSE->{code} == 404, 'Response\'s code is ok');

$test_request->request('alumnos', 'GET', __url=>'/alumno/yo/11');

ok($RESPONSE && ref($RESPONSE) eq 'HASH', 'A response has been obtained');

ok($RESPONSE->{code} == 200, 'Response\'s code is ok');

ok($RESPONSE->{body} eq 'yo_11', 'Formatter is working');

done_testing();

package A;

use strict;
use parent qw(Eixo::RestServer);

sub authorized{
	my ($self, %args) = @_;

	$args{my_secret} eq '123'
	

}

sub GET_alumno{

	$_[0]->ok(
		
		'GET_alumno',
		 
			
	);
}

sub GET_alumnos :F(id, action){
	my ($self, %args) = @_;

	$self->ok(

		$args{id} . '_' . $args{action}
		 
	);
}

sub PUT_alumno :Restricted{

	$_[0]->ok(

		'PUT_alumno'

	);

}

sub DELETE_alumno {

}

sub POST_alumno {

}

