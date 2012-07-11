#!/bin/bash

#-------------------------------------------------------------------------------
# Trevor - Work it. Build it. Test it. Deploy it.
#
# Dan Riti - http://github.com/notfunk
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# Usage  : ./trevor.sh <repository> <branch>'
# Example: ./trevor.sh git@github.com:username/repo.git master
#-------------------------------------------------------------------------------

# Check if arguments are set.
if [ -z $1 -o -z $2 ]
then
    echo 'You must specify a repository and branch to clone.'
    echo
    echo 'usage: ./trevor.sh <repository> <branch>'
    echo

    exit 1
fi

# Check if virtualenv is installed.
if ! command -v virtualenv >/dev/null
then
    echo 'Trevor requires virtualenv but it is not installed. Aborting.'

    exit 1
fi

repository=$1
branch=$2
project='project'
working_dir=`pwd`

echo 'Hi, I am Trevor!'
echo

# Work it.
virtualenv testbox

source testbox/bin/activate

mkdir testbox/src
cd testbox

# Build it.
git clone $repository src/$project

cd src/$project

git checkout -b run-test
git fetch origin
git merge origin/$branch

pip install -r requirements.txt

# Test it.
file=`find . -name "manage.py"`

# Check if Django manage.py exists.
if [ -z $file ]
then
    echo 'Trevor can not find your Django project. Aborting.'

    exit 1
fi

dir=`dirname $file`
cd $dir

if python manage.py test 2>&1 | grep -q 'OK'
then
    echo
    echo 'Pass'
    echo
else
    echo
    echo 'Fail'
    echo
fi

cd $working_dir

# Clean it.
rm -rf testbox
