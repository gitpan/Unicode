print "1..4\n";

use Unicode;
$u = Unicode::latin1("abcÊ¯Â");

print "not " unless $u->latin1 eq "abcÊ¯Â";
print "ok 1\n";

print "not " unless $u->length == 6;
print "ok 2\n";

print "not " unless $u->ucs2 eq "\0a\0b\0c\0Ê\0¯\0Â";
print "ok 3\n";

print "not " unless $u->utf8 eq "abc√¶√∏√•";
print "ok 4\n";
