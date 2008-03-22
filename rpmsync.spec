Summary:	Script to rsync update an RPM repository mirror
Name:		rpmsync
Version:	1.7
Release:	%mkrel 3
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
