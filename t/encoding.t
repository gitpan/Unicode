print "1..38\n";

use Unicode::String qw(latin1 ucs4 utf16 utf8 utf7);

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


#--- Test UTF7 encoding ---

# Examples from RFC 1642...
#
#      Example. The Unicode sequence "A<NOT IDENTICAL TO><ALPHA>."
#      (hexadecimal 0041,2262,0391,002E) may be encoded as follows:
#
#            A+ImIDkQ.
#
#      Example. The Unicode sequence "Hi Mom <WHITE SMILING FACE>!"
#      (hexadecimal 0048, 0069, 0020, 004D, 006F, 004D, 0020, 263A, 0021)
#      may be encoded as follows:
#
#            Hi Mom +Jjo-!

$u = utf7("A+ImIDkQ.");
print "HEX: ", $u->hex, "\n";
print "UTF7: ", $u->utf7, "\n";
print "not " unless $u->hex eq "U+0041 U+2262 U+0391 U+002e";
print "ok 22\n";

$utf7 = $u->utf7("Hi Mom +Jjo-!");
print "not " unless $utf7 =~ /^A\+ImIDkQ-?\.$/;
print "ok 23\n";

print "HEX: ", $u->hex, "\n";
print "UTF7: ", $u->utf7, "\n";

print "not " unless $u->hex eq "U+0048 U+0069 U+0020 U+004d U+006f U+006d U+0020 U+263a U+0021";
print "ok 24\n";

print "not " unless $u->utf7 eq "Hi Mom +Jjo-!" || $u->utf7 eq "Hi Mom +JjoAIQ-";
print "ok 25\n";

#      Example. The Unicode sequence representing the Han characters for
#      the Japanese word "nihongo" (hexadecimal 65E5,672C,8A9E) may be
#      encoded as follows:

$u = utf7("+ZeVnLIqe-");
print "not " unless $u->hex eq "U+65e5 U+672c U+8a9e";
print "ok 26\n";
print "not " unless $u->utf7 eq "+ZeVnLIqe-";
print "ok 27\n";

# Appendix A -- Examples
#
#   Here is a longer example, taken from a document originally in Big5
#   code. It has been condensed for brevity. There are two versions: the
#   first uses optional characters from set O (and thus may not pass
#   through some mail gateways), and the second uses no optional
#   characters.

$text = <<'EOT';
   Below is the full Chinese text of the Analects (+itaKng-).

   The sources for the text are:

   "The sayings of Confucius," James R. Ware, trans.  +U/BTFw-:
   +ZYeB9FH6ckh5Pg-, 1980.  (Chinese text with English translation)

   +Vttm+E6UfZM-, +W4tRQ066bOg-, +UxdOrA-:  +Ti1XC2b4Xpc-, 1990.

   "The Chinese Classics with a Translation, Critical and
   Exegetical Notes, Prolegomena, and Copius Indexes," James
   Legge, trans., Taipei:  Southern Materials Center Publishing,
   Inc., 1991.  (Chinese text with English translation)

   Big Five and GB versions of the text are being made available
   separately.

   Neither the Big Five nor GB contain all the characters used in
   this text.  Missing characters have been indicated using their
   Unicode/ISO 10646 code points.  "U+-" followed by four
   hexadecimal digits indicates a Unicode/10646 code (e.g.,
   U+-9F08).  There is no good solution to the problem of the small
   size of the Big Five/GB character sets; this represents the
   solution I find personally most satisfactory.

   (omitted...)

   I have tried to minimize this problem by using variant
   characters where they were available and the character
   actually in the text was not.  Only variants listed as such in
   the +XrdxmVtXUXg- were used.

   (omitted...)

   John H. Jenkins
   +TpVPXGBG-
   John_Jenkins@taligent.com
   5 January 1993
EOT

$u = utf7($text);
$utf = $u->utf7;

unless ($utf eq $text) {
   print $u->length, " $utf\n";
   open(F, ">utf7-$$.orig"); print F $text;
   open(F, ">utf7-$$.enc");  print F $utf;
   close(F);
   system("diff -u0 utf7-$$.orig utf7-$$.enc");
   unlink("utf7-$$.orig", "utf7-$$.enc");
}

print "not " unless $utf eq $text;
print "ok 28\n";

# Test encoding of different encoding byte lengths
for my $len (1 .. 6) {
   $u = Unicode::String->new;
   $u->pack(map {1000 + $_} 1 .. $len);
   print $u->hex, "\n";
   print $u->utf7, "\n";
   $u2 = utf7($u->utf7);
   print "not " unless $u->utf16 eq $u2->utf16;
   print "ok ", 28+$len, "\n";
}

$Unicode::String::UTF7_OPTIONAL_DIRECT_CHARS = 0;

$u = latin1("a=4!æøå");
$utf = $u->utf7;

print "not " if $utf7 =~ /[=!]/;
print "ok 35\n";

print "not " unless utf7($utf)->latin1 eq "a=4!æøå";
print "ok 36\n";

#--- Swapped bytes ---

$u = utf16("ÿþa\0b\0c\0");
print $u->hex, "\n";
print "not " unless $u->latin1 eq "abc";
print "ok 37\n";

$u = utf16("þÿ\0a\0b\0c");
print $u->hex, "\n";
print "not " unless $u->latin1 eq "abc";
print "ok 38\n";

