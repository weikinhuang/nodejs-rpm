%define _prefix		/usr

Name:				nodejs
Version:			%{ver}
Release:			1
Summary:			Node.js is a server-side JavaScript environment that uses an asynchronous event-driven model.
Packager:			Wei Kin Huang <wei@weikinhuang.com>
License:			Copyright Joyent, Inc. and other Node contributors.
URL:				http://nodejs.org/
Group:				Development/Libraries

Source:				http://nodejs.org/dist/%{version}/node-v%{version}-linux-%{node_arch}.tar.gz
Source1:			nodejs.profile.d


BuildRoot:			%{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildArch:			%{arch}




%description
Node.js is a platform built on Chrome's JavaScript runtime for easily building
fast, scalable network applications. Node.js uses an event-driven, non-blocking
I/O model that makes it lightweight and efficient, perfect for data-intensive
real-time applications that run across distributed devices.


%prep
%setup -q -n node-v%{version}-linux-%{node_arch}


%build


%install
rm -rf $RPM_BUILD_ROOT

%__install -d "%{buildroot}%{_prefix}"

cp -pr ./* "%{buildroot}%{_prefix}"
rm -f "%{buildroot}%{_prefix}/ChangeLog"
rm -f "%{buildroot}%{_prefix}/LICENSE"
rm -f "%{buildroot}%{_prefix}/README.md"

%__install -d "%{buildroot}/etc/profile.d"
sed 's|\${_prefix}|%{_prefix}|' "%{SOURCE1}" > %{buildroot}/etc/profile.d/nodejs.sh

# this is installed in a different package
rm -rf "%{buildroot}%{_prefix}/bin/npm"
rm -rf "%{buildroot}%{_prefix}/lib/node_modules/npm"

%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(-,root,root,-)
%attr(0755,root,root) %dir %{_prefix}/lib/node_modules
%{_prefix}/lib/dtrace/node.d
%attr(0755,root,root) %{_prefix}/bin/node
%attr(0644,root,root) /etc/profile.d/nodejs.sh
%doc
%{_prefix}/share/man/man1/node.1.gz


%changelog
* Mon Apr  8 2013 Wei Kin Huang <wei@weikinhuang.com>
- Initial version for 0.10.3
