require 5.002;
use ExtUtils::MakeMaker;

WriteMakefile(
	NAME          => 'Unicode',
	VERSION_FROM  => 'Unicode.pm',
 	dist          => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
);
