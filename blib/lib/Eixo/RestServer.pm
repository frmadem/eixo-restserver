package Eixo::RestServer;

use 5.014002;
use strict;
use warnings;

use lib '/home/fmaseda/Eixo-RestServer/lib';

use Eixo::Base::Clase;
use Eixo::RestServer::Parser;



has(

	server=>undef,

);

sub install{
	my ($self) = @_;

	my $methods = &Eixo::RestServer::Parser::parse($self);

	$self->server->install($self);

}

sub process{
	my ($self, $entity, $verb, %args) = @_;


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
