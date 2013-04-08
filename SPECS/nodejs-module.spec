%define _prefix		/usr

Name:				nodejs-%{module_name}
Version:			%{x_ver}
Release:			1
Summary:			%{x_desc}
Packager:			Wei Kin Huang <wei@weikinhuang.com>
License:			Copyright Joyent, Inc. and other Node contributors.
URL:				%{x_homepage}
Group:				Development/Libraries

Source:				nodejs-%{module_name}.tar.gz


BuildRoot:			%{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildArch:			%{_arch}


Requires:			node >= %{x_node_ver}


%description
%{x_desc}


%prep
%setup -q -n nodejs-%{module_name}


%build


%install
rm -rf $RPM_BUILD_ROOT

%__install -d "%{buildroot}%{_prefix}"
cp -pr ./* "%{buildroot}%{_prefix}"


%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(-,root,root,-)
%{_prefix}/lib/node_modules/%{module_name}/
%{x_bin_files}
%doc


%changelog
* Mon Apr  8 2013 Wei Kin Huang <wei@weikinhuang.com>
- Initial version
