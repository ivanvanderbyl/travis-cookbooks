#
# Cookbook Name:: python::dead_snakes_ppa
# Recipe:: default
# Copyright 2011, Michael S. Klishin & Travis CI development team
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

case node['platform']
when "ubuntu"
  apt_repository "fkrull_deadsnakes" do
    uri          "http://ppa.launchpad.net/fkrull/deadsnakes/ubuntu"
    distribution node['lsb']['codename']
    components   ['main']

    action :add
  end
end

python_pkgs = value_for_platform(
  ["debian","ubuntu"] => {
    "default" => (%w(python-dev) + node.python.multi.pythons)
  }
)

python_pkgs.each do |pkg|
  package pkg do
    action :install
  end
end


include_recipe "python::pip"
include_recipe "python::virtualenv"

# not a good practice but sufficient for travis-ci.org needs, so lets keep it
# hardcoded. MK.
installation_root = "/home/ubuntu/virtualenv"

directory(installation_root) do
  owner "ubuntu"
  group "ubuntu"
  mode  "0755"

  action :create
end


node.python.multi.pythons.each do |py|
  python_virtualenv "/home/ubuntu" do
    owner       "ubuntu"
    group       "ubuntu"
    interpreter py
    path        "#{installation_root}/#{py}"

    action :create
  end
end
