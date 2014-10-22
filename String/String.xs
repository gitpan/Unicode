/* Copyright (c) 1997, Gisle Aas. */

#ifdef __cplusplus
extern "C" {
#endif
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#ifdef __cplusplus
}
#endif


MODULE = Unicode::String	PACKAGE = Unicode::String

SV*
latin1(self,...)
	SV* self

	PREINIT:
	SV*    new;
	SV*    str;

	CODE:
        RETVAL = 0;
	if (!sv_isobject(self)) {
	    new = self;
	    RETVAL = self = newSV(0);
	    newSVrv(self, "Unicode::String");
	} else if (items > 1) {
	    new = ST(1);
        } else {
	    new = 0;
        }

	str = SvRV(self);
	if (GIMME_V != G_VOID && !RETVAL) {
            U8 *beg, *s;
	    STRLEN len;
            U16* usp = (U16*)SvPV(str,len);
	    len /= 2;
	    RETVAL = newSV(len+1);
	    SvPOK_on(RETVAL);
	    beg = s = SvPVX(RETVAL);
	    while (len--) {
	        U16 us = ntohs(*usp++);
                if (us > 255) {
                    warn("Data outside latin1 range (pos=%d, ch=U+%x)", s - beg, us);
		} else {
	            *s++ = us;
                }
	    }
	    SvCUR_set(RETVAL, s - beg);
            *s='\0';
        }

	if (new) {
            U16 *usp;
            STRLEN len;
	    U8 *s = SvPV(new, len);
	    SvGROW(str, len*2 + 2);
	    SvPOK_on(str);
	    SvCUR_set(str,len*2);
	    usp = (U16*)SvPV(str,na);
            while (len--) {
	       *usp++ = htons((U16)*s++);
            }
	    *usp = 0;
        }
	if (!RETVAL)
	    RETVAL = newSViv(0);

	OUTPUT:
	RETVAL

SV*
ucs4(self,...)
	SV* self

	PREINIT:
	SV*    new;
	SV*    str;

	CODE:
	RETVAL = 0;
	if (!sv_isobject(self)) {
	    new = self;
	    RETVAL = self = newSV(0);
            newSVrv(self, "Unicode::String");
	} else if (items > 1) {
	    new = ST(1);
        } else {
	    new = 0;
        }

	str = SvRV(self);

	if (GIMME_V != G_VOID && !RETVAL) {
            U32* to, *beg;
	    STRLEN len;   /* source length */
	    U16* from = (U16*)SvPV(str, len);
	    len /= 2;
	    RETVAL = newSV(len*4 + 1);
	    SvPOK_on(RETVAL);
	    beg = to = (U32*)SvPV(RETVAL, na);
            while (len--) {
		U16 us = ntohs(*from++);
		if (us >= 0xD800 && us <= 0xDFFF) {  /* surrogate */
                    U16 low = len ? ntohs(*from) : 0;
                    if (us >= 0xDC00 || low < 0xDC00 || low > 0xDFFF) {
			/* bad surrogate pair */
			warn("Bad surrogate pair U+%04x U+%04x", us, low);
		    } else {
			len--; from++;
			*to++ = htonl((us-0xD800)*0x400 + low-0xDC00 + 0x10000);
                    }
	        } else {
		    *to++ = htonl(us);
                }
            }
	    SvCUR_set(RETVAL, (to - beg) * 4);
	    SvPVX(RETVAL)[SvCUR(RETVAL)] = '\0';
	}

	if (new) {
	    STRLEN len;
	    U32* from = (U32*)SvPV(new, len);
	    len /= 4;
	    SvGROW(str, len*2 + 1);  /* enough if we don't need surrogates */
	    SvPOK_on(str);
            SvCUR_set(str, 0);
	    while (len--) {
                U32 uc = ntohl(*from++);
		if (uc > 0xFFFF) {
		    if (uc > 0x10FFFF) {
			/* can't be represented */
			warn("UCS4 char (0x%08x) can not be encoded as UTF16", uc);
                    } else {
			/* generate two surrogates */
			U16 high, low;
			uc -= 0x10000;
			high = htons(uc/0x400 + 0xD800);
			low  = htons(uc%0x400 + 0xDC00);
			sv_catpvn(str, (char*)&high, 2);
			sv_catpvn(str, (char*)&low,  2);
                    }
		} else {
                    U16 s = htons(uc);
		    sv_catpvn(str, (char*)&s, 2);
		}
	    }
	    /* ensure '\0' termination of string */
	    SvGROW(str, SvCUR(str)+1);
	    SvPVX(str)[SvCUR(str)] = '\0';
	}

	if (!RETVAL)
	    RETVAL = newSViv(0);

	OUTPUT:
	RETVAL


SV*
utf8(self,...)
	SV* self

	PREINIT:
	SV*    new;
	SV*    str;

	CODE:
	RETVAL = 0;
	if (!sv_isobject(self)) {
	    new = self;
	    RETVAL = self = newSV(0);
            newSVrv(self, "Unicode::String");
	} else if (items > 1) {
	    new = ST(1);
        } else {
	    new = 0;
        }

	str = SvRV(self);
	if (GIMME_V != G_VOID && !RETVAL) {
	    /* encode str */
	    STRLEN len;
	    U16* from = (U16*)SvPV(str, len);
	    len /= 2;
	    RETVAL = newSV(len*1.2 + 1);  /* guess osuitable for euro-text */
	    SvPOK_on(RETVAL);
	    SvCUR_set(RETVAL, 0);
            while (len--) {
		register U32 us = ntohs(*from++);
	        if (us >= 0xD800 && us <= 0xDFFF) {  /* surrogate */
                    U16 low = len ? ntohs(*from) : 0;
                    if (us >= 0xDC00 || low < 0xDC00 || low > 0xDFFF) {
			/* bad surrogate pair */
			warn("Bad surrogate pair U+%04x U+%04x", us, low);
		    } else {
			len--; from++;
			us = (us-0xD800)*0x400 + low-0xDC00 + 0x10000;
                    }
                }
		if (us < 0x80) {
		    U8 c = us;
		    sv_catpvn(RETVAL, &c, 1);
                } else if (us < 0x800) {
		    U8 c[2];
                    c[1] = (us & 0077) | 0200;
                    c[0] = (us >> 6)   | 0300;
                    sv_catpvn(RETVAL, c, 2);
                } else if (us < 0x10000) {
		    U8 c[3];
                    c[2] = (us & 0077) | 0200; us >>= 6;
		    c[1] = (us & 0077) | 0200; us >>= 6;
		    c[0] =  us         | 0340;
	            sv_catpvn(RETVAL, c, 3);
                } else if (us < 0x200000) {
                    U8 c[4];
                    c[3] = (us & 0077) | 0200; us >>= 6;
                    c[2] = (us & 0077) | 0200; us >>= 6;
		    c[1] = (us & 0077) | 0200; us >>= 6;
		    c[0] =  us         | 0360;
	            sv_catpvn(RETVAL, c, 4);
                } else {
		     /* this can't really happen since we start with utf16 */
	             warn("Large char (%08X) ignored", us);
                }
	    }
	    /* ensure '\0' termination of string */
	    SvGROW(str, SvCUR(str)+1);
	    SvPVX(str)[SvCUR(str)] = '\0';
	}

	if (new) {
	    /* decode new */
	    STRLEN len;
	    U8* from = SvPV(new, len);
	    SvGROW(str, len + 1);  /* must be at least this big */
	    SvPOK_on(str);
            SvCUR_set(str, 0);
            while (len--) {
	        U8 s[2];
		U8 u = *from++;
                if (u < 0x80) {
                    s[0] = '\0';
                    s[1] = u;
		    sv_catpvn(str, s, 2);
                } else if ((u & 0340) == 0300) {
                    /* 2 bytes to decode */
		    if (!len) {
			warn("Missing second byte of utf8 encoded char");
                    } else {
			U8 u2 = *from;
			if ((u2 & 0300) != 0200) {
			    warn("Bad second byte of utf8 encoded char");
                        } else {
			    from++; len--;  /* consume it */
			    s[0] = (u & 0037) >> 2;
			    s[1] = ((u & 0003) << 6) | (u2 & 0077);
			    sv_catpvn(str, s, 2);
			}
		    }
                } else if ((u & 0360) == 0340) {
		    /* 3 bytes to decode */
		    if (len < 2) {
			warn("Missing 2nd or 3rd byte of utf8 encoded char");
                    } else {
			U8 u2 = from[0];
			U8 u3 = from[1];
			if ((u2 & 0300) != 0200 || (u3 & 0300) != 0200) {
			    warn("Bad 2nd or 3rd byte of utf8 encoded char");
                        } else {
			    from += 2; len -= 2; /* consume them */
			    s[0] = (u  << 4) | (u2 & 0077) >> 2;
			    s[1] = (u2 << 6) | (u3 & 0077);
			    sv_catpvn(str, s, 2);
			}
                    }
                } else if ((u & 0370) == 0360) {
		    /* 4 bytes to decode, encoded using surrogates */
	            if (len < 3) {
			warn("Missing 2nd, 3rd or 4th byte of utf8 encoded char");
                    } else {
			if ((from[0] & 0300) != 0200 ||
			    (from[1] & 0300) != 0200 ||
			    (from[2] & 0300) != 0200)
			{
			    warn("Bad 2nd, 3rd or 4th byte of utf8 encoded char");
			} else {
			    U32 c = (u & 0007) << 6;
			    c |= (from[0] & 0077); c <<= 6;
			    c |= (from[1] & 0077); c <<= 6;
			    c |= (from[2] & 0077);
			    from += 3; len -= 3;
			    /* c must now be encoded as two surrogates */
			    if (c > 0x10FFFF) {
				warn("Can't represent 0x%08X as utf16", c);
                            } else {
				/* generate two surrogates */
				U16 high, low;
				c -= 0x10000;
				high = htons(c/0x400 + 0xD800);
				low  = htons(c%0x400 + 0xDC00);
				sv_catpvn(str, (char*)&high, 2);
				sv_catpvn(str, (char*)&low,  2);
			    }
			}
		    }
                } else if ((u & 0374) == 0370) {
                    /* 5 bytes to decode, can't happend */
		    warn("Can't represent 5 byte encoded chars");
                } else {
		    warn("Bad utf8 byte (0x%02X) ignored", u);
                }
            }
	}

	if (!RETVAL)
	    RETVAL = newSViv(0);

	OUTPUT:
	RETVAL

