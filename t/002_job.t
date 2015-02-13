use t::test_base;

use strict;
use Eixo::RestServer::Job;

my $job = Eixo::RestServer::Job->new(

	id => Eixo::RestServer::Job::ID


);

ok($job->id, 'Job has an ID');
ok($job->status eq 'WAITING', 'Job status is ok');

$job->setError('This is an error');

ok($job->status eq 'ERROR' && $job->results->{error} =~ /This/, 'Error is properly established');


my $serialized = $job->serialize;

ok($serialized, 'Serialized job');

my $job2 = $job->unserialize($serialized);

ok(ref($job2) && $job2->id eq $job->id, 'Unserialized job is ok');

done_testing();

