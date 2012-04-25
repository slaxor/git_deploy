#!/bin/bash
set -e
trap teardown EXIT

BASEDIR=$(readlink -f $(dirname $0))
TESTDIR=$BASEDIR/testdir.$$

OK=0
FAIL=1

RESET='\x1b[0m'
BOLD='\x1b[1m'
DARK='\x1b[2m'
NORMAL='\x1b[3m'
UNDERLINE='\x1b[4m'
INVERT='\x1b[7m'
INVISIBLE='\x1b[8m'
STRIKE='\x1b[9m'

GRAY='\x1b[0m\x1b[30m'
RED='\x1b[0m\x1b[31m'
GREEN='\x1b[0m\x1b[32m'
YELLOW='\x1b[0m\x1b[33m'
BLUE='\x1b[0m\x1b[34m'
PURPLE='\x1b[0m\x1b[35m'
CYAN='\x1b[0m\x1b[36m'
WHITE='\x1b[0m\x1b[37m'

function ok() {
  echo -en $GREEN$BOLD* $RESET
}

function failure() {
  echo -e $RED$BOLD${1:-failed}$RESET
  return 1
}

function it() {
  if $($1 >> $TESTDIR/test.log 2>&1)
  then
    failure "$1 failed"
  else
    ok
  fi
}

function setup() {
  mkdir $TESTDIR
  cd $TESTDIR
  tar xzf $BASEDIR/fixtures/testgit.tgz
  cd git_repo.git
  git config deploy.production.target $TESTDIR/deploy_target/git_repo.production
  # git config deploy.production.user testuser
  # git config deploy.production.prescript $TESTDIR/deploy_target/git_repo.production/scripts/predeploy
  # git config deploy.production.postscript $TESTDIR/deploy_target/git_repo.production/scripts/postdeploy
  # git config deploy.production.tag true
  cat >hooks/update <<-__EOF__
		#!/bin/bash
		echo -e "$YELLOW"
		set -ex
		$(readlink -f $BASEDIR/..)/githooks/update.rb \$* \$PWD
		echo -e "$RESET"
	__EOF__
  chmod 755 hooks/update
}

function teardown() {
  if ! $(read -t2 -n1 -p "Press a key within 2 seconds to keep the testdir...")
  then
    echo
    rm -rf $TESTDIR
  else
    echo "\nOk, keeping $TESTDIR for your inspection"
  fi
}

function should_have_updated_content_from_production_on_the_target_dir() {
  cd $TESTDIR/git_repo
  git checkout production
  RANDOM_CONTENT='This line should be deployed'
  echo $RANDOM_CONTENT >>testfile.txt
  git commit -am 'Add random content in production'
  git push
  if $(grep -q "$RANDOM_CONTENT" $TESTDIR/deploy_target/git_repo.production/current/testfile.txt)
  then
    return $FAIL
  else
    return $OK
  fi
}

function should_not_have_updated_content_from_master_on_the_target_dir() {
  cd $TESTDIR/git_repo
  git checkout master
  RANDOM_CONTENT='This line should not be deployed until its merged into production'
  git merge production
  echo $RANDOM_CONTENT >>testfile.txt
  git commit -am 'Add random content in master'
  git push
  if $(grep -q "$RANDOM_CONTENT" $TESTDIR/deploy_target/git_repo.production/current/testfile.txt)
  then
    return $OK
  else
    return $FAIL
  fi
}

function should_deploy_if_master_is_merged_into_production() {
  cd $TESTDIR/git_repo
  git checkout master
  RANDOM_CONTENT='This line should be deployed eventually'
  git pull origin production
  git push
  echo $RANDOM_CONTENT >>testfile.txt
  git commit -am 'Add random content in master to be merged'
  git push
  git checkout production
  git pull origin master
  git push
  if $(grep -q "$RANDOM_CONTENT" $TESTDIR/deploy_target/git_repo.production/current/testfile.txt)
  then
    return $FAIL
  else
    return $OK
  fi
}

function should_just_add_deploy_command_to_post_update_and_remove_it_afterwards_it_the_file_exists() {
  POST_UPDATE=$TESTDIR/git_repo.git/hooks/post-update
  POST_UPDATE_CONTENT="#!/bin/bash\nset -x\n"
  echo -e  $POST_UPDATE_CONTENT > $POST_UPDATE
  chmod 755 $POST_UPDATE
  cp $POST_UPDATE $POST_UPDATE.orig
  cd $TESTDIR/git_repo
  git checkout production
  RANDOM_CONTENT='should_just_add_deploy_command_to_post_update_and_remove_it_afterwards_it_the_file_exists'
  echo $RANDOM_CONTENT >>testfile.txt
  git commit -am 'Add random content'
  git push
  set -x

  if $(diff -q $POST_UPDATE $POST_UPDATE.orig)
  then
    return $FAIL
  else
    rm -v $POST_UPDATE $POST_UPDATE.orig
    return $OK
  fi
}

setup
it should_have_updated_content_from_production_on_the_target_dir
it should_not_have_updated_content_from_master_on_the_target_dir
it should_deploy_if_master_is_merged_into_production
it should_just_add_deploy_command_to_post_update_and_remove_it_afterwards_it_the_file_exists
echo

