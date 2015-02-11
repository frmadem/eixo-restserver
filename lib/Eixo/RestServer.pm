package Eixo::RestServer;

use 5.008;
use strict;
use warnings;

use lib '/home/fmaseda/Eixo-RestServer/lib';

use Eixo::Base::Clase;
use Eixo::RestServer::Parser;

has(

	server=>undef,

	methods_r=>undef,
);

sub install{
	my ($self) = @_;

	no strict 'refs';

	my $methods = &Eixo::RestServer::Parser::parse($self);

	$self->server->install($self);

	$self->methods_r({

		map {

			$_->{entity} .'_' . $_->{verb} => $_		


		} @$methods

	});
}

sub process{
	my ($self, $entity, $verb, %args) = @_;

	my $action = $self->route($entity, $verb);

	$self->$action(%args) if($action);

}

sub route{
	my ($self, $entity, $verb) = @_;

	if(my $action = $self->methods_r->{$entity . '_' . $verb}){
		return $action->{code};
	}
	else{
		$self->notFound;
	}

}

sub notFound{

	use Data::Dumper; die(Dumper($_[0]));

}


sub ok{
	my ($self, $response) = @_;
	
	{
		code=>200,

		body=>$response

	}
}

sub ko{
	my ($self, $code, $response) = @_;

	{
		code=>$code,

		body=>$response

	}
}


#
# Restricted install
#
sub Restricted :ATTR(CODE){
	my ($pkg, $sym, $code, $attr_name, $data) = @_;	

	no warnings 'redefine';

	*{$sym} = sub {

		my ($self, @args) = @_;

		if($self->authorized(@args)){
			$code->($self, @args);
		}
		else{

			$self->not_authorized();
		}


	};

}


#package A;
#
#use strict;
#use parent -norequire, qw(Eixo::RestServer);
#
#use Eixo::RestServer::BinderCGI;
#
#sub GET_alumno{
#
#}
#
#sub PUT_alumno :Restricted{
#
#}
#
#sub DELETE_alumno :Restricted{
#
#}
#
#use Data::Dumper;
#
#die Dumper(A->new(
#
#	server=>Eixo::RestServer::BinderCGI->new
#
#)->install);

1;
