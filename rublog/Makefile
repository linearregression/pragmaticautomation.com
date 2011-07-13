# -*- Makefile -*-
# Release must have VERSION variable set
#
#    make VERSION=0.1 release
#

CVS = CVS_RSH=ssh cvs

TAG	:=	$(shell echo V$(VERSION) | sed s/\\./_/g)

release:	clean stamp tar

stamp:
		ruby -pi -e 'sub!(/".*?"/, %{"$(VERSION)"}) if /RUBLOG_VERSION/' RubLog.rb
		$(CVS) commit -m 'Create release $(VERSION)'
		$(CVS) rtag  $(TAG) rublog

tar:
		$(CVS) export -d rublog-$(VERSION) -r $(TAG) rublog
		tar czf rublog-$(VERSION).tgz rublog-$(VERSION)
		rm -rf rublog-$(VERSION)

clean:
		@-find . -name '*~' | xargs rm


