package TestApi;

use Eixo::Base::Clase qw(CatroEixos::Server);

use Eixo::RestServer::AutomaticPaths;

sub POST_test_apply :F(id)  { 
       my ($self, %args) = @_;
}

__PACKAGE__->POST(
        
    '/test/:id/apply',

    command=>'Test.apply', 

    args => {
        forzar => 's'
    } ,

    queue => 'cola_rapida'
     
);

__PACKAGE__->GET (
	'/test2/:id/apply2',
	args => {a => 1}
);



package main;

use t::test_base;


use strict;
my $i = 0;

TestApi->new->__defer('_test__id_apply', undef,__url => '/test/23/apply');
END_RUN:
goto FIN if($i++ > 1);

TestApi->new->__defer('_test2__id_apply2', undef,__url => '/test2/232/apply2');
FIN:

my $paths = (Eixo::RestServer::AutomaticPaths->getPaths('TestApi'));

ok(
	$paths->[0]->{method} eq '_test__id_apply' &&
	$paths->[0]->{url} eq '/test/*/apply' &&
	$paths->[0]->{verb} eq 'POST',

	'First POST route definition extracted correctly'
);

ok(
	$paths->[1]->{method} eq '_test2__id_apply2' &&
	$paths->[1]->{url} eq '/test2/*/apply2' &&
	$paths->[1]->{verb} eq 'GET',

	'GET route definition with default extracted correctly'
);

done_testing();

