#!/bin/bash
set -ex
BASEDIR=$(readlink -f $(dirname $0))
TESTDIR=$BASEDIR/testdir.$$

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

function error() {
  echo $1
  exit 1
}

mkdir $TESTDIR
cd $TESTDIR
tar xzf $BASEDIR/fixtures/testgit.tgz
cd git_repo.git
git config deploy.production.target $TESTDIR/deploy_target/git_repo.production
# git config deploy.production.user testuser
# git config deploy.production.prescript $TESTDIR/deploy_target/git_repo.production/scripts/predeploy
# git config deploy.production.postscript $TESTDIR/deploy_target/git_repo.production/scripts/postdeploy
# git config deploy.production.tag true
cat >hooks/update <<__EOF__
#!/bin/bash
echo -e "$YELLOW"
set -ex
$(readlink -f $BASEDIR/..)/githooks/deploy.rb \$* \$PWD
echo -e "$RESET"
__EOF__
chmod 755 hooks/update

# testing git now
cd $TESTDIR/git_repo
git co production

RANDOM_CONTENT='This line should be deployed'
echo $RANDOM_CONTENT >>testfile.txt
git commit -am 'Add random content'
git push

grep -q "$RANDOM_CONTENT" $TESTDIR/deploy_target/git_repo.production/current/testfile.txt && error 'production should have been deployed but it wasnt'

# rm -rf $TESTDIR

