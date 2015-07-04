#
# Cookbook Name:: posty
# Recipe:: spamassassin
#
# Copyright 2015, posty-soft.org
#
# Licensed under the LGPL v3
# https://www.gnu.org/licenses/lgpl.html
#

Chef::Log.info("[Installing spamassassin and spamc]")
package 'spamassassin spamc'

Chef::Log.info("[Configuring spamassassin cronjob]")
template "/etc/cron.daily/spamassassin" do
  source "spamassassin/cron.daily.erb"
  mode "0755"
  owner "root"
  group "root"
end

Chef::Log.info("[Configuring spamassassin]")
template "/etc/spamassassin/local.cf" do
  source "spamassassin/local.cf.erb"
  mode "0644"
  owner "root"
  group "root"
end

Chef::Log.info("[Updating spamassassin rules]")
execute "update" do
  command "sa-update && sa-update --nogpg --channel spamassassin.heinlein-support.de"
  user "root"
  returns [0,1,2,3,4]
end