package Eixo::RestServer::BinderCGI;

use strict;
use Eixo::Base::Clase;
use parent qw(Eixo::RestServer::Binder);

has(

	port=>undef,
	

);

sub __install{
	my ($self) = @_;

	&Eixo::RestServer::BinderCGIProcess::start_server(

		$self->port,
		
		sub {

			$self->run(@_)

		}

	);
	
}


package Eixo::RestServer::BinderCGIProcess;

use strict;
use parent qw(HTTP::Server::Simple::CGI);

sub start_server{
	my ($port, $on_request) = @_;

	my $server = __PACKAGE__->new;
	
	$server->{on_request} = $on_request;

	$server->port($port);

	$server->background;

}

sub handle_request{

}


1;


