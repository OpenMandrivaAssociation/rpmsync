Summary:	Script to rsync update an RPM repository mirror
Name:		rpmsync
Version:	1.7
Release:	%mkrel 7
License:	LGPL
Group:		Networking/File transfer
Source0:	%{name}.pl
Source1:	README
Source2:	exclude.lst
Requires:	rsync
BuildArch:	noarch
BuildRoot:	%{_tmppath}/%{name}-buildroot

%description
- Script to rsync update an RPM repository mirror; most useful for
  frequently updated distributions, like Mandriva Cooker, RedHat Rawhide
  or security updates for a specific version of an RPM-based distribution
- Moves RPMs so you can rsync between package versions
- Supports mirroring directories and individual files

%prep

%setup -T -c
cp -f %{SOURCE0} %{SOURCE1} %{SOURCE2} .

%install
rm -rf %{buildroot}

install -d %{buildroot}%{_bindir}
install -m0755 %{name}.pl %{buildroot}%{_bindir}/%{name}

%clean
rm -rf %{buildroot}

%files
%defattr(-,root,root)
%doc README exclude.lst
%attr(0755,root,root) %{_bindir}/%{name}


%changelog
* Tue Sep 08 2009 Thierry Vignaud <tvignaud@mandriva.com> 1.7-7mdv2010.0
+ Revision: 433456
- rebuild

* Sat Aug 02 2008 Thierry Vignaud <tvignaud@mandriva.com> 1.7-6mdv2009.0
+ Revision: 260339
- rebuild

* Mon Jul 28 2008 Thierry Vignaud <tvignaud@mandriva.com> 1.7-5mdv2009.0
+ Revision: 251500
- rebuild

* Sun Mar 23 2008 Frederik Himpe <fhimpe@mandriva.org> 1.7-3mdv2008.1
+ Revision: 189535
- Make it work correctly with rsync 3.0.0

  + Olivier Blin <oblin@mandriva.com>
    - restore BuildRoot

  + Thierry Vignaud <tvignaud@mandriva.com>
    - kill re-definition of %%buildroot on Pixel's request

* Wed Sep 19 2007 Oden Eriksson <oeriksson@mandriva.com> 1.7-2mdv2008.0
+ Revision: 90588
- bunzip the sources so that they are under version control
  and added some svn props


* Tue Aug 08 2006 Thomas Backlund <tmb@mandriva.org> 1.7-1mdv2007.0
+ 2006-08-08 01:26:37 (54260)
- From David Walser <luigiwalser@yahoo.com>:
  - Add support for rsync -H (preserve hard links) command-line option

* Fri Jul 14 2006 Olivier Thauvin <nanardon@mandriva.org>
+2006-07-14 23:16:46 (41272)
- releasing the package

* Fri Jul 14 2006 Olivier Thauvin <nanardon@mandriva.org>
+2006-07-14 23:16:06 (41271)
- remove mandrake reference
- remove url (useless...)

* Fri Jul 14 2006 Olivier Thauvin <nanardon@mandriva.org>
+2006-07-14 22:01:04 (41242)
- rebuild

* Fri Jul 14 2006 Olivier Thauvin <nanardon@mandriva.org>
+2006-07-14 22:00:16 (41241)
Import rpmsync

* Thu Apr 08 2004 David Walser <luigiwalser@yahoo.com> 1.6-1mdk
- Fix for when multiple sources are specified on command-line (1.5 broke it)
- update default configuration and README to reflect new mirror structure

* Mon Mar 22 2004 David Walser <luigiwalser@yahoo.com> 1.5-1mdk
- Add support for trailing slash for source given on command-line
- Fix when rsync path on command-line is one directory

* Sun Mar 21 2004 David Walser <luigiwalser@yahoo.com> 1.4-1mdk
- Add support for :: syntax for specifying rsync server on command-line
- exit immediately if local path is invalid

* Wed Feb 18 2004 David Walser <luigiwalser@yahoo.com> 1.3-1mdk
- Fix for using relative local path (thanks Keld Jørn Simonsen)
- change updates example in README to 10.0
- fix first changelog entry

* Tue Jan 20 2004 David Walser <luigiwalser@yahoo.com> 1.2-1mdk
- Fix for when banner is complelety empty (thanks Luca Berra)

* Sat Oct 25 2003 David Walser <luigiwalser@yahoo.com> 1.1-1mdk
- Fix for when source has no slash in it (like updates example in README)
- fix updates example in README
- from Jaco Greeff <jaco@linuxminicd.org> :
	- Added rsync require
	- Fixed typo in first changelog entry

* Thu Oct 16 2003 David Walser <luigiwalser@yahoo.com> 1.0-2mdk
- Fix command-line support (variable scope problem); thanks Aaron Peromsik

