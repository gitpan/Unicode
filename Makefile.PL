require 5.004;
use ExtUtils::MakeMaker;

WriteMakefile(
	NAME     => 'Unicode',
	VERSION  => '19970710',
 	dist     => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
);
