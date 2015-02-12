package Eixo::RestServer::BinderCGI;

use strict;
use Eixo::Base::Clase;
use parent qw(Eixo::RestServer::Binder);

has(

	port=>undef,
	

);

sub response{
	my ($self, $response) = @_;

	return [

		[$response->{code}],

		[],

		[$response->{body}]

	];		

}

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
	my ($self) = @_;

	my @args;

	my $ret = $self->{on_request}->(@args);

	
	$self->__head($ret->[0], $ret->[1]);
	$self->__body($ret->[2]);

}

	sub __head{
		my ($self, $code, $head_args) = @_;

		my $c = $code->[0];

		print "HTTP/1.0 $c\r\n";

	}


	sub __body{
		my ($self, $body) = @_;

		print join('', @{$body});

	}

1;


