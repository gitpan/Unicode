package Unicode;
use Carp;

# Copyright (c) 1997, Gisle Aas.

$VERSION = sprintf("%d.%02d", q$Revision: 1.1 $ =~ /(\d+)\.(\d+)/);

sub new
{
    my($class,$str) = @_;
    croak "Odd length of Unicode string"
	if defined($str) && length($str)%2 != 0;
    bless \$str, $class;
}

sub ucs2
{
    my $self = shift;
    $$self;
}

sub ucs4
{
    my $self = shift;
    pack("N*", unpack("n*", $$self));
}

sub utf8
{
    my $self = shift;
    unless (ref $self) {
	# act as ctor
	my $u = new Unicode;
	$u->utf8($self);
	return $u;
    }

    my $old;
    if (defined $$self) {
	# encode UTF-8
	for $uc (unpack("n*", $$self)) {
	    if ($uc < 0x80) {
		# 1 byte representation
		$old .= chr($uc);
	    } elsif ($uc < 0x800) {
		# 2 byte representation
		$old .= chr(0xC0 | ($uc >> 6)) .
                        chr(0x80 | ($uc & 0x3F));
	    } else {
		# 3 byte representation
		$old .= chr(0xE0 | ($uc >> 12)) .
		        chr(0x80 | (($uc >> 6) & 0x3F)) .
			chr(0x80 | ($uc & 0x3F));
	    }
	}
    }

    if (@_) {
	if (defined $_[0]) {
	    $$self = "";
	    my $bytes = shift;
	    $bytes =~ s/^[\200-\277]+//;  # can't start with 10xxxxxx
	    while (length $bytes) {
		if ($bytes =~ s/^([\000-\177]+)//) {
		    $$self .= pack("n*", unpack("C*", $1));
		} elsif ($bytes =~ s/^([\300-\337])([\200-\277])//) {
		    my($b1,$b2) = (ord($1), ord($2));
		    $$self .= pack("n", (($b1 & 0x1F) << 6) | ($b2 & 0x3F));
		} elsif ($bytes =~ s/^([\340-\357])([\200-\277])([\200-\277])//) {
		    my($b1,$b2,$b3) = (ord($1), ord($2), ord($3));
		    $$self .= pack("n", (($b1 & 0x0F) << 12) |
                                        (($b2 & 0x3F) <<  6) |
				         ($b3 & 0x3F));
		} else {
		    croak "Bad UTF-8 data";
		}
	    }
	} else {
	    $$self = undef;
	}
    }

    $old;
}

sub latin1
{
    my $self = shift;
    unless (ref $self) {
	# act as ctor
	my $u = new Unicode;
	$u->latin1($self);
	return $u;
    }

    my $old;
    # XXX: should really check that none of the chars > 256
    $old = pack("C*", unpack("n*", $$self)) if defined $$self;

    if (@_) {
	# set the value
	if (defined $_[0]) {
	    $$self = pack("n*", unpack("C*", $_[0]));
	} else {
	    $$self = undef;
	}
    }
    $old;
}

sub hex
{
    my $self = shift;
    return undef unless defined($$self);
    my $str = unpack("H*", $$self);
    $str =~ s/(....)/$1 /g;
    $str;
}

sub length
{
    my $self = shift;
    length($$self) / 2;
}

sub chr
{
    my $self = shift;
    return undef unless defined $$self;
    unpack("n", $$self);
}

sub ord
{
    my($self,$val) = @_;
    unless (ref $self) {
	# act as ctor
	my $u = new Unicode;
	$u->ord($self);
	return $u;
    }
    $$self = pack("n", $val);
}


sub substr
{
    my($self, $offset, $length) = @_;
    $offset *= 2;
    $length *= 2;
    my $substr = substr($$self, $offset, $length);
    bless \$substr, ref($self);
}

1;
