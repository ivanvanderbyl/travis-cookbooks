#
# Cookbook Name:: travis_build_environment
# Recipe:: ubuntu
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


cookbook_file "/etc/profile.d/travis_environment.sh" do
  owner "ubuntu"
  group "ubuntu"
  mode 0755

  source "ubuntu/travis_environment.sh"
end


cookbook_file "/home/ubuntu/.gemrc" do
  owner "ubuntu"
  group "ubuntu"
  mode 0755

  source "ubuntu/dot_gemrc.yml"
end


cookbook_file "/home/ubuntu/.bashrc" do
  owner "ubuntu"
  group "ubuntu"
  mode 0755

  source "ubuntu/dot_bashrc.sh"
end


directory "/home/ubuntu/.ssh" do
  owner  "ubuntu"
  group  "ubuntu"
  mode   "0755"

  action :create
end


cookbook_file "/home/ubuntu/.ssh/known_hosts" do
  owner "ubuntu"
  group "ubuntu"
  mode  0600

  source "ubuntu/known_hosts"
end


directory "/home/ubuntu/builds" do
  owner "ubuntu"
  group "ubuntu"
  mode "0755"
  action :create
end


mount "/home/ubuntu/builds" do
  fstype   "tmpfs"
  device   "/dev/null" # http://tickets.opscode.com/browse/CHEF-1657, doesn't seem to be included in 0.10.0
  options  "defaults,size=#{node.travis_build_environment.builds_volume_size},noatime"
  action   [:mount, :enable]
  only_if { node.travis_build_environment[:use_tmpfs_for_builds] }
end
