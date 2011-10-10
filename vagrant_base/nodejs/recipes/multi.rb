#
# Cookbook Name:: node.js
# Recipe:: n
# Copyright 2011, Travis CI development team
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require "tmpdir"

permissions_setup = Proc.new do |resource|
  resource.owner "ubuntu"
  resource.group "ubuntu"
  resource.mode 0755
end

directory "/home/ubuntu/.nvm" do
  permissions_setup.call(self)
end

# Note that nvm will automatically install npm, the node package manager,
# for each installed version of node.
cookbook_file "/home/ubuntu/.nvm/nvm.sh" do
  permissions_setup.call(self)
end

cookbook_file "/etc/profile.d/nvm.sh" do
  permissions_setup.call(self)
  source "profile_entry.sh"
end

nvm = "source /home/ubuntu/.nvm/nvm.sh; nvm"

bash "syncing nvm with http://nodejs.org/" do
  user "ubuntu"
  cwd "/home/ubuntu"
  code "#{nvm} sync"
end

node[:nodejs][:versions].each do |node|
  bash "installing node version #{node}" do
    creates "/home/ubuntu/.nvm/#{node}"
    user "ubuntu"
    group "ubuntu"
    cwd "/home/ubuntu"
    environment({'HOME' => "/home/ubuntu"})
    code  "#{nvm} install v#{node}"
  end
end

bash "make the default node" do
  user "ubuntu"
  code "#{nvm} alias default v#{node[:default]}"
end

node[:nodejs][:aliases].each do |existing_name, new_name|
  bash "alias node #{existing_name} => #{new_name}" do
    user "ubuntu"
    cwd "/home/ubuntu"
    code "#{nvm} alias #{new_name} v#{existing_name}"
  end
end
