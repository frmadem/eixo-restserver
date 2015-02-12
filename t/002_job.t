use t::test_base;

use Eixo::RestServer::Job;

my $job = Eixo::RestServer::Job->new(

	id => Eixo::RestServer::Job::ID


);

ok($job->id, 'Job has an ID');
ok($job->status eq 'WAITING', 'Job status is ok');

$job->setError('This is an error');

ok($job->status eq 'ERROR' && $job->results->{error} =~ /This/, 'Error is properly established');

done_testing();

