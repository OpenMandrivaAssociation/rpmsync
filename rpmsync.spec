%define name rpmsync
%define version 1.7
%define release %mkrel 1

Summary:	Script to rsync update an RPM repository mirror
Name:		%{name}
Version:	%{version}
Release:	%{release}
Source0:	%{name}.pl.bz2
Source1:	README.bz2
Source2:	exclude.lst.bz2
License:	LGPL
Group:		Networking/File transfer
BuildRoot:	%{_tmppath}/%{name}-buildroot
BuildArch:	noarch
Requires:	rsync

%description
- Script to rsync update an RPM repository mirror; most useful for
  frequently updated distributions, like Mandriva Cooker, RedHat Rawhide
  or security updates for a specific version of an RPM-based distribution
- Moves RPMs so you can rsync between package versions
- Supports mirroring directories and individual files

%prep
%setup -T -c
cp -f %{SOURCE1} %{SOURCE2} .
bunzip2 README.bz2
bunzip2 exclude.lst.bz2

%install
rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT%{_bindir}
bzcat %{SOURCE0} > $RPM_BUILD_ROOT%{_bindir}/rpmsync


%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root)
%attr(755,root,root) %{_bindir}/rpmsync
%doc README exclude.lst



* Thu Apr  8 2004 David Walser <luigiwalser@yahoo.com> 1.6-1mdk
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

* Sat Jul 19 2003 David Walser <luigiwalser@yahoo.com> 1.0-1mdk
- initial package
- rsync excludes file support (thanks Steffen Barszus)

