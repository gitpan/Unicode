print "1..4\n";

use Unicode::String;

$u = Unicode::String::latin1("abc���");

print "not " unless $u->latin1 eq "abc���";
print "ok 1\n";

print "not " unless $u->length == 6;
print "ok 2\n";

print "not " unless $u->ucs2 eq "\0a\0b\0c\0�\0�\0�";
print "ok 3\n";

print "not " unless $u->utf8 eq "abcæøå";
print "ok 4\n";
