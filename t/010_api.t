use t::test_base;


use strict;



package TestApi;

use Eixo::Base::Clase qw(Eixo::RestServer);

sub POST_test_apply :F(id)  { 
       my ($self, %args) = @_;
    ('Test.apply', 
}

POST '/test/:id/apply',

    command=>'Test.apply', 

    args => {
        forzar => 's'
    } ,

    queue => 'cola_rapida'; 
