print "1..21\n";

use Unicode::String qw(latin1 ucs4 utf8 utf16);

#use Devel::Dump;

$SIG{__WARN__} = sub { print "$_[0]"; };

$u = latin1("abcæøå");
#Dump($u);

#---- Test Latin1 encoding ----

print "not " unless $u->latin1 eq "abcæøå";
print "ok 1\n";

print "not " unless $u->length == 6;
print "ok 2\n";

print "not " unless $u->ucs4 eq "\0\0\0a\0\0\0b\0\0\0c\0\0\0æ\0\0\0ø\0\0\0å";
print "ok 3\n";

print "not " unless $u->utf16 eq "\0a\0b\0c\0æ\0ø\0å";
print "ok 4\n";

print "not " unless $u->utf8 eq "abcÃ¦Ã¸Ã¥";
print "ok 5\n";

# print "not " unless $u->utf7 eq "abc????";
# print "ok 6\n";

print "not " unless $u->hex eq "U+0061 U+0062 U+0063 U+00e6 U+00f8 U+00e5";
print "ok 6\n";

$u = latin1("abc");
$a = $u->latin1("def");
$b = $u->latin1;
$u->latin1("ghi");

print "not " unless $a eq "abc" && $b eq "def" && $u->latin1 eq "ghi";
print "ok 7\n";

$u = utf16("aa\0bcc\0d");
print $u->hex, "\n";

print "Expect 2 lines of warnings...\n";
$x = $u->latin1;

print "not " unless $x eq "bd";
print "ok 8\n";

#---- Test UCS4 encoding ----

$x = "\0\0\0a\0\0bb\0\3cc\0\1\0\2\0\0\0\0";
$u = ucs4($x);
print $u->hex, "\n";

print "not " unless $u->length == 7;
print "ok 9\n";

print "not " unless $u->hex eq "U+0061 U+6262 U+d898 U+df63 U+d800 U+dc02 U+0000";
print "ok 10\n";

print "not " unless $u->ucs4 eq $x;
print "ok 11\n";

$a = $u->ucs4("");
print "not " unless $a eq $x && $u->length == 0;
print "ok 12\n";

print "Expect 2 lines of warnings...\n";
$u->ucs4("    \0\x10\xff\xff\0\x11\0\0\0\0\0\0");
print $u->hex, "\n";
print "not " unless $u->hex eq "U+dbff U+dfff U+0000";
print "ok 13\n";

#--- Test UTF8 encoding ---

$u = utf8("");
print "not " unless $u->length == 0 && $u->utf8 eq "";
print "ok 14\n";

$u = utf8("abc");
$old = $u->utf8("def");
print "not " unless $old eq "abc" && $u->latin1 eq "def";
print "ok 15\n";

$u = utf16("\0a\0å\1\0\7a\8\0aa");
print "UTF16: ", $u->hex, "\n";
$x = unpack("H*", $u->utf8);
print "UTF8x: $x\n";
print "not " unless $x eq "61c3a5c480dda1e3a080e685a1";  #XXX check this up
print "ok 16\n";

$u2 = utf8($u->utf8);
print "not " unless $u->utf16 eq $u2->utf16;
print "ok 17\n";

# Test surrogates and utf8
print "Surrogates...\n";

$u = ucs4("\0\1\0\0\0\x10\xFF\xFF");
print $u->hex, "\n";
$x = unpack("H*", $u->utf8);
print "UTF8: $x\n";
print "not " unless $x eq "f0908080f48fbfbf";
print "ok 18\n";

$u->utf8(pack("H*", $x));
print $u->hex, "\n";
print unpack("H*", $u->ucs4), "\n";

print "not " unless $u->ucs4 eq "\0\1\0\0\0\x10\xFF\xFF";
print "ok 19\n";

print "Expect a warning with this incomplete surrogate pair...\n";
$u = utf16("\xd8\x00");
print $u->hex, "\n";
$u2 = utf8($u->utf8);
print "not " unless $u2->hex eq "U+d800";
print "ok 20\n";

print "...and lots of noice from this...\n";
$u = utf8("¤¤a\xf7¤¤¤b\xf8¤¤¤¤c\xfc¤¤¤¤¤d\xfd\xfe\xffef");
print $u->hex, "\n";

print "not " unless $u->utf8 eq "abcdef";
print "ok 21\n";
