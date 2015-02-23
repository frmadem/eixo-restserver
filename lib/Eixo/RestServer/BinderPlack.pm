package Eixo::RestServer::BinderPlack;

use strict;
use parent qw(Eixo::RestServer::Binder);

use Eixo::Base::Clase;

sub response{
	my ($self, $response) = @_;

	return [

		$response->{code},

		[],

		[$response->{body}]

	];		

}

sub __install{
	my ($self) = @_;

		
	sub {

		my ($cgi) = @_;

		my ($head, $args) = $self->__format($cgi);

		$self->run($head, $args)

	}
	
}

sub __format{
	my ($self, $cgi) = @_;

	{

		URL => $cgi->{PATH_INFO},

		METHOD=>$cgi->{REQUEST_METHOD},	

		HEADERS => map {

			my ($k) = $_ =~ /^HTTP_(.+)$/;

			lc($k) => $cgi->{$_}

		} grep { $_ =~ /^HTTP_/ } keys(%$cgi)

	},

	{
		GET_ARGS=>{map {

			$_ =~ /(\w+)\=(.+)$/;

			$1 => $2

		} split(/\&/, $cgi->{QUERY_STRING}) }
		
	}

}


1;
