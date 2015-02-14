use t::test_base;

use LWP::UserAgent;
use Eixo::RestServer::BinderCGI;

my $test_request;

my $RESPONSE;

my $PID;

my $PORT = int(rand(1000));

eval{

	my $process;

	my $server = A->new(
	
		server=>$process = Eixo::RestServer::BinderCGI->new(
	
			port=>$PORT
		)
	);

	$server->install;
	
	print "$PORT\n";

	$PID = $process->pid;

	sleep(1);

	ok(kill(0, $PID), 'El proceso se ha lanzado');

};
if($@){
	print Dumper($@);
}

if($PID){

	kill(9, $PID);

	waitpid($PID, 0);
}

done_testing();

package A;

use strict;
use parent qw(Eixo::RestServer);

sub GET_a{

	$_[0]->ok(

		"A"

	);

}

sub GET_b{

	$_[0]->ok(

		"B"

	);

}

