#! /bin/bash

echo "Shallalist: starting update"

# Extract the things we're interested in from the archive
wget http://www.shallalist.de/Downloads/shallalist.tar.gz -O shallalist.tar.gz
tar -xzf shallalist.tar.gz 'BL/aggressive' 'BL/anonvpn' 'BL/drugs' 'BL/dynamic' \
'BL/gamble' 'BL/hacking' 'BL/redirector' 'BL/sex/lingerie' \
'BL/spyware' 'BL/violence' 'BL/warez'

# Copy the blacklist items to the sources directory
cp -R BL/* sources

# Process the files
line=$(git status --porcelain --untracked-files=no | grep "sources")
echo "Shallalist: processing $line"

IFS=$'\n'
set -f

# Loop through the changed files and process them
if [ "$line" != "" ]; then
    for i in $line; do
        filename=$(echo "$i" | awk -F " " '{ print $2 }')
        filetype=$(echo "$i" | awk -F '\/' '{ print $NF }')
        cleanfile=$(echo "${filename}" | sed 's/\/sources\/sex\/lingerie/\/sex\.lingerie/g;s/\/sources//g')
        echo "Shallalist: updating $cleanfile"

        ./process.sh $filetype < $filename > $cleanfile

    done

    # Check everythng in
    git pull origin master
    git add shalla*
    git commit -m "Latest shallalist"
    git push

    echo "Shallalist: update complete"
else
    echo "Shallalist: nothing to update"
fi

