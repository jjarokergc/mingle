#!/bin/bash
set -e  #Stop on error
set -x  # Echo commands
PS4='$LINENO:'

# Copyright 2020 ThoughtWorks, Inc.
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
# 
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/agpl-3.0.txt>.
# Need to have tomcat installed.
unset RUBY_VERSION
unset RBENV_ROOT
unset GEMSET
unset RBENV_VERSION
unset RBENV_DIR
unset BUNDLER_ORIG_GEM_PATH
unset RUBYLIB
unset BUNDLER_ORIG_GEM_HOME
unset BUNDLE_BIN_PATH
unset BUNDLER_ORIG_PATH
unset BUNDLER_VERSION
unset GEM_PATH
unset GEM_HOME
unset BUNDLER_ORIG_RUBYLIB
unset BUNDLER_ORIG_BUNDLE_GEMFILE
unset BUNDLER_ORIG_MANPATH
unset BUNDLER_ORIG_BUNDLER_ORIG_MANPATH
unset BUNDLER_ORIG_RUBYOPT
unset BUNDLER_ORIG_BUNDLER_VERSION
unset BUNDLER_ORIG_BUNDLE_BIN_PATH
unset BUNDLER_ORIG_RB_USER_INSTALL
unset RUBYOPT
unset RBENV_GEMSET_ALREADY
unset BUNDLE_GEMFILE
unset RAILS_ENV


# Set up directories
WORKSPACE=$(cd `dirname $0` && pwd)
MINGLE_RAILS2_ROOT=$WORKSPACE/mingle
MINGLE_RAILS5_ROOT=$WORKSPACE/mingle-rails5


export RBENV_ROOT=$HOME/.rbenv$GO_AGENT_ID

# Set rbenv if necessary (such as in puppet exec resource)
# Rbenv was configured in the mingle and mingle-rails5 build scripts
if ! [[ $RBENV_SHELL = 'bash' ]]; then 
    eval "$($RBENV_ROOT/bin/rbenv init -)"
fi

# Load nvm if necessary (such as in puppet exec resource)
if ! [[ $NVM_DIR = "$HOME/.nvm" ]]; then 
  export NVM_DIR="$HOME/.nvm"
  [[ -s "$NVM_DIR/nvm.sh" ]] && . "$NVM_DIR/nvm.sh"  # This loads nvm
fi

#Build Options
export BUILD_DUAL_APP=true
export NOCRYPT=true
# Settings From 'mingle/config/warble.rb'
export ENCRYPT_CODE=false 
# Production Environment
export TEST_DUAL_APP=false  # 'false' sets 'rails.env' = 'production'

# Mingle Rails 2
cd $MINGLE_RAILS2_ROOT 
export RBENV_VERSION=$(cat $MINGLE_RAILS2_ROOT/.ruby-version)
# Build shared assets
echo "generating shared assets from $MINGLE_RAILS2_ROOT"
$RBENV_ROOT/bin/rbenv exec bundle exec rake shared_assets  --trace
cp shared_assets.yml $MINGLE_RAILS5_ROOT/config
echo "generating artifact from $MINGLE_RAILS2_ROOT"
$RBENV_ROOT/bin/rbenv exec bundle exec rake war:build[true] dual_app_installers --trace
cp lib/version.jar $MINGLE_RAILS5_ROOT/lib


# Mingle Rails 5
cd $MINGLE_RAILS5_ROOT 
export RBENV_VERSION=$(cat $MINGLE_RAILS5_ROOT/.ruby-version)
echo "generating artifact from $MINGLE_RAILS5_ROOT"
$RBENV_ROOT/bin/rbenv exec bundle exec rake war:build[true] --trace

cp $MINGLE_RAILS5_ROOT/rails_5.war $MINGLE_RAILS2_ROOT/


