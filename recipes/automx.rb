#
# Cookbook Name:: posty
# Recipe:: automx
#
# Copyright 2015, posty-soft.org
#
# Licensed under the LGPL v3
# https://www.gnu.org/licenses/lgpl.html
#

automx_path = "/srv/automx"

Chef::Log.info("[Install automx]")
package "memcached python-sqlalchemy python-mysqldb dnsutils python-lxml python-ipaddr python-dateutil python-m2crypto libapache2-mod-wsgi"

execute "enable-apache2-wsgi" do
  command "a2enmod wsgi"
  notifies :restart, "service[apache2]"
end

execute "enable-apache2-rewrite" do
  command "a2enmod rewrite"
  notifies :restart, "service[apache2]"
end

git "#{automx_path}" do
  repository "https://github.com/sys4/automx.git"
  revision "master"
  user "root"
  group "www-data"
  action :sync
end

link "/var/www/automx" do
  to "/srv/automx/src/html"
  owner "www-data"
  group "www-data"
end
link "/var/www/automx/index.html" do
  to "/var/www/automx/index.html.de"
  owner "www-data"
  group "www-data"
end
execute "Copy automx to www folder" do
  command "cp #{automx_path}/src/automx_wsgi.py /var/www/automx/"
  not_if { File.exists?("/var/www/automx/automx_wsgi.py") }
end

execute "Copy automx-test to bin folder" do
  command "cp #{automx_path}/src/automx-test /usr/bin/automx-test"
  not_if { File.exists?("/usr/bin/automx-test") }
end

execute "Copy automx folder to python lib folder" do
  command "cp -r #{automx_path}/src/automx /usr/lib/python2.7"
  not_if { File.exists?("/usr/lib/python2.7/automx") }
end

template "/etc/automx.conf" do
  source "automx/automx.conf"
  owner "root"
  group "root"
  mode "0644"
  variables(:domain => node["posty"]["mail"]["domain"], :server => node["posty"]["mail"]["hostname"])
end

directory "/var/log/automx" do
  owner 'www-data'
  group 'www-data'
  mode '0700'
  action :create
end
file "/var/log/automx/automx.log" do
  owner 'www-data'
  group 'www-data'
  mode '0644'
  action :create_if_missing
end
