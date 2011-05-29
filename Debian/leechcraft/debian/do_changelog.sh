#! /bin/sh

# $Id: do_changelog.sh 2396 2008-06-08 14:03:37Z roman_rybalko $

oldrev=$1
newrev=$2

[ -z "$newrev" -o -z "$oldrev" ] && { echo "USAGE: $0 <oldrev> <newrev>"; exit 1; }

set -e
set -x

CHLOG=changelog.new
cd ..
echo "leechcraft (`git describe $2`) unstable; urgency=low" > debian/$CHLOG
echo >> debian/$CHLOG
git log --pretty=format:'  %s' $1..$2 | sed -r "s/\. \+/\.\n  \+/" | sed -r "s/\. \*/\.\n  \*/" | sed -r "s/\> \*/\n  \*/" | sed -r "s/\. \-/\.\n  \-/" | sed -r "s/(.{1,72})(.+)/\1/" | grep "[:alphanum:]\+" >> debian/$CHLOG
cd debian
echo >> $CHLOG
echo -n " -- Georg Rudoy <0xd34df00d@gmail.com>  " >> $CHLOG
date -R >> $CHLOG
echo >> $CHLOG
cat changelog >> $CHLOG

mv -f $CHLOG changelog
