use t::test_base;


use strict;

package TestApi;

use Eixo::Base::Clase qw(Eixo::RestServer);

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

die Dumper(Eixo::RestServer::AutomaticPaths->getPaths(__PACKAGE__)); use Data::Dumper;
