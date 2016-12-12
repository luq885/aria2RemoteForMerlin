#!/bin/sh

#change to your github username
git_user='luq885'
gist_token=$(cat gistToken)
#gist_token='your token'

list_file='aria2list123456'

aria2_rpc='http://192.168.1.1:6800/jsonrpc'
gist_file='gist.json'
log_file='history.log'

createHttpTask(){
    curl -H "Content-Type: application/json" -X POST -d "{\"id\":\"0\",\"method\":\"aria2.addUri\",\"params\":[[\"$1\"]]}" $aria2_rpc
}

checkIfInLog(){
    if [ ! -f "./$log_file" ]; then
        touch $log_file
        echo 0
        return
    fi
}

checkAndDownload(){
    url=$1;
    if [[ $url == re* ]]; then
        url=$(echo $url | sed -n 's/re //g')
    else
        is_downloaded=$(checkIfInLog $url)
        echo $is_downloaded
    fi
    return
    if [[ $url == http* ]]; then
        createHttpTask $url
    fi
}

if [ -f "./$list_file" ]; then
    rm $list_file
fi
if [ -f "./$gist_file" ]; then
    rm $gist_file
fi
curl -H "Authorization: token $gist_token" https://api.github.com/users/$git_user/gists >$gist_file
raw_url=$(sed -n "/\"raw_url\": \".*$list_file\",/p" $gist_file)
file_url=$(echo $raw_url | sed -e 's/.*"raw_url": "//g' -e 's/",//g')
wget $file_url 
for line in $(cat $list_file)
do
    checkAndDownload $line
done

