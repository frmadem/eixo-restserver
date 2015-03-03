use t::test_base;

use LWP::UserAgent;
use Eixo::RestServer::BinderPlack;

use HTTP::Server::Simple::PSGI;

my $test_request;

my $RESPONSE;

my $PID;

my $PORT = 2000+int(rand(1000));
my $HOST = '127.0.0.1';

eval{

	my $process;

	unless($PID = fork){

		eval{
			my $server = A->new(
			
				server=>$process = Eixo::RestServer::BinderPlack->new
			);

			my $psgi = HTTP::Server::Simple::PSGI->new($PORT);
   			
			$psgi->host($HOST);
   			$psgi->app($server->install);
   			$psgi->run;	

		};
		if($@){

			print Dumper($@);

		}

		exit 0;
	}

	sleep(2);

	my $ua = LWP::UserAgent->new;

	my $url = "http://$HOST:$PORT/a";

	my $r = $ua->get($url);

	ok($r->is_success, 'Request completed');

	ok($r->decoded_content =~ /A/, 'Body correct');

	$url = "http://$HOST:$PORT/b/bear";

	$r = $ua->get($url);

	ok($r->is_success, 'Request completed');

	ok($r->decoded_content =~ /B\=bear/, 'Body correct');

	$url = "http://127.0.0.1:$PORT/c/bear?type=panda";

	$r = $ua->put($url);

	ok($r->is_success, 'Request completed');

	ok($r->decoded_content =~ /C\=panda_bear/, 'Body correct');
	
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

sub GET_b :F(id){
	my ($self, %args) = @_;
	
	$_[0]->ok(

		"B=" .$args{id}

	);

}

sub PUT_c :F(id){
	my ($self, %args) = @_;

	$_[0]->ok(

		"C=" .$args{type} . '_' . $args{id}

	);

}

