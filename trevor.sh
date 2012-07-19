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

# Variable declarations. Don't change these =)
virtualenv='https://raw.github.com/pypa/virtualenv/develop/virtualenv.py'
project='project'
working_dir=`pwd`
repository=$1
branch=$2

# User variable declarations. Set these if you want to use them!
hipchat_auth_token=''

# Let's get started, shall we?
echo 'Hi, I am Trevor!'
echo

# Work it.
cd $working_dir
wget $virtualenv
python virtualenv.py testbox

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

# Run Django test suite and send results into HipChat.
if python manage.py test 2>&1 | grep -q 'OK'
then
    echo
    echo 'Pass'
    echo

    # If HipChat auth token is set, send the message to the room.
    if [ ! -z "$hipchat_auth_token" ]
    then
        curl -d "room_id=ourCSA&from=Trevor&message=Build+Status:+Passing&color=green" https://api.hipchat.com/v1/rooms/message?auth_token=$hipchat_auth_token&format=json
    fi
else
    echo
    echo 'Fail'
    echo

    # If HipChat auth token is set, send the message to the room.
    if [ ! -z "$hipchat_auth_token" ]
    then
        curl -d "room_id=ourCSA&from=Trevor&message=Build+Status:+Failing&color=red&notify=1" https://api.hipchat.com/v1/rooms/message?auth_token=$hipchat_auth_token&format=json
    fi
fi

cd $working_dir

# Clean it.
rm -rf testbox
rm virtualenv.py*
