use 5.014002;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'Eixo::RestServer',
    VERSION_FROM      => 'lib/Eixo/RestServer.pm', # finds $VERSION
    PREREQ_PM         => {
                            'Eixo::Base' => '1',
                            'JSON' => '2.5',
                            'Data::UUID' => '1.2'

                        },
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/Eixo/RestServer.pm', # retrieve abstract from module
       AUTHOR         => 'Francisco <fmaseda@>') : ()),
);
