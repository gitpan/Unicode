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
	U16*   usp;
        U16    us;
	U8*    s;
	STRLEN len;
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
	    usp = (U16*)SvPV(str,len);
   	    if ((len % 2) != 0)
	        croak("Odd length string");
	    len /= 2;
	    RETVAL = newSV(len+1);
	    SvPOK_on(RETVAL);
	    SvCUR_set(RETVAL, len);
	    s = SvPVX(RETVAL);
	    while (len--) {
	        us = ntohs(*usp++);
                if (us > 255)
                    croak("Data outside latin1 range (pos=%d, ch=U+%x)", SvCUR(RETVAL)-len-1, us);
	        *s++ = us;
	    }
            *s='\0';
        }

	if (new) {
	    s = SvPV(new, len);
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
	    RETVAL = newSV(0);

	OUTPUT:
	RETVAL
