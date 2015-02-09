package Eixo::RestServer::Parser;

use strict;

my $REST_VERBS = qr/(GET|POST|DELETE|PUT)/;

my $ACTION = qr/$REST_VERBS\_(\w+)$/;

sub parse{
	my ($module) = @_;	

	unless($module->isa('Eixo::RestServer')){
	
		die("Must be an instance of RestServer Class");

	}

	my @methods = grep {

		$_ =~ /^$REST_VERBS/

	} $module->methods;

	[
		map {

			&__parseAction($_, $module)

		} @methods

	]

}

	sub __parseAction{
		my ($action, $module) = @_;
	
		my ($verb, $entity) = $action =~ /$ACTION/;	

		{

			entity=>$entity,

			verb=>$verb,

			code=> $module->can($action)

		}

	}


1;
