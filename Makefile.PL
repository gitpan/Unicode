require 5.002;
use ExtUtils::MakeMaker;

WriteMakefile(
	NAME     => 'Unicode',
	VERSION  => '19970704',
 	dist     => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
);
