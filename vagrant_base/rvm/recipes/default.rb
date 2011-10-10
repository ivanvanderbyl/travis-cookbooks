#
# Cookbook Name:: rvm
# Recipe:: default

# Make sure that the package list is up to date on Ubuntu/Debian.
include_recipe "apt" if ['debian', 'ubuntu'].member? node[:platform]

# Make sure we have all we need to compile ruby implementations:
include_recipe "networking_basic"
include_recipe "build-essential"
include_recipe "git"
include_recipe "libyaml"
include_recipe "libgdbm"

case node[:platform]
when "debian","ubuntu"
  %w(libreadline5-dev libssl-dev libxml2-dev libxslt1-dev zlib1g-dev).each do |pkg|
    package pkg
  end
end

bash "install RVM" do
  user        "ubuntu"
  cwd         "/home/ubuntu"
  environment Hash['HOME' => "/home/ubuntu", 'rvm_user_install_flag' => '1']
  code        <<-SH
  curl -s https://raw.github.com/wayneeseguin/rvm/master/binscripts/rvm-installer -o /tmp/rvm-installer
  chmod +x /tmp/rvm-installer
  /tmp/rvm-installer --version #{node.rvm.version}
  SH
  not_if      "test -d /home/ubuntu/.rvm"
end

cookbook_file "/etc/profile.d/rvm.sh" do
  owner "ubuntu"
  group "ubuntu"
  mode 0755
end

cookbook_file "/home/ubuntu/.rvmrc" do
  owner "ubuntu"
  group "ubuntu"
  mode  0755

  source "dot_rvmrc.sh"
end
