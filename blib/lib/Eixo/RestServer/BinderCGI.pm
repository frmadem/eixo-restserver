package Eixo::RestServer::BinderCGI;

use strict;
use parent qw(Eixo::RestServer::Binder);

use Eixo::Base::Clase;

has(

	port=>undef,
	
	pid=>undef,

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

	$self->{pid} = &Eixo::RestServer::BinderCGIProcess::start_server(

		$self->port,
		
		sub {

			my ($cgi) = @_;

			my ($head, $args) = $self->__format($cgi);

			$self->run($head, $args)

		}

	);
	
}

sub __format{
	my ($self, $cgi) = @_;

	{		
		URL=>$cgi->path_info,

		METHOD=>$cgi->request_method,
	},

	{

	}
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
	my ($self, $cgi) = @_;

	$self->{cgi} = $cgi;

	my $ret = $self->{on_request}->($cgi);

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

	}

1;


