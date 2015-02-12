package Eixo::RestServer::Queues;

use strict;
use Eixo::Base::Clase;

has(

	queues=>{},

	jobs_resolve=>{},

);

#
# Jobs administration
#
sub getJob{
	my ($self, $id) = @_;

	if(my $queue_name = $self->jobs_resolve->{$id}){

		$self->queues->{$queue_name}->status($id);

	}
}


sub addJob{
	my ($self, $job) = @_;

	#
	# Add resolve
	#
	$self->jobs_resolve->{$job->id} = $job->queue;

	#
	# Add job to the queue
	#
	$self->queues->{$job->queue}->add($job);
}

#
# Queues administration
#

sub createQueue{
	my ($self, $queue) = @_;

	unless($queue && $queue->isa('Eixo::RestServer::Queue')){

		die(ref($self) . '::createQueue: queue must exist and be an instance of Eixo::RestServer::Queue');

		$self->queues->{$queue->name} = $queue;

	}
}


1;
