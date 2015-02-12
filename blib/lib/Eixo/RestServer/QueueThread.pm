package Eixo::RestServer::QueueThread;

use strict;
use parent qw(Eixo::RestServer::Queue);

use threads;
use Thread::Queue;

has(

	module=>undef,

	q_i=>undef,

	q_o=>undef,

);

sub __initialize{
	
	$_[0]->SUPER::__initialize;

	unless($_[0]->module && $_[0]->module->isa('Eixo::RestServer::Process')){

		die(ref($_[0]) . '::__initialize: module must exist and be an instance of Process');

	}

}

sub init{
	my ($self) = @_;

	my $module = $self->module;
	my ($q_i, $q_o) = (Thread::Queue->new, Thread::Queue->new);

	threads->create(sub {

		$module->new(

			q_e=>$_[0],

			q_s=>$_[1]

		)->loop();		

	}, $q_i, $q_o);
}

sub add{
	my ($self, $job) = @_;

	$self->q_i->enqueue($job->serialize);
}

sub remove{

}


1;
