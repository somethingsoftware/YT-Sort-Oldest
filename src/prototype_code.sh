#!/bin/bash

CHANNEL=$1

parse_continuationJSON() {
    local continuationJSON=$(echo $@ | grep -Po '"continuationCommand":.*?\}' | tail -n1)
    echo $continuationJSON | sed -e 's/.*token":.\{0,1\}"//g;s/".*//g'
}
rm -rf output 2>/dev/null || true
mkdir output 2>/dev/null || true

cat << EOF > req.json
{
    "context": {
        "client": {
            "clientName": "WEB",
            "clientVersion": "2.20230317.00.00",
            "osVersion": "",
            "originalUrl": "$CHANNEL"

        }
    },
    "continuation": ""
}
EOF

cat << EOF > headers.txt
accept-encoding: text/plain
cache-control: no-cache
content-type: application/json
origin: https://www.youtube.com
EOF

text=$(curl -sN -XGET -H @headers.txt $1)

API_KEY_JSON=$(echo $text  | grep -Po '"INNERTUBE_API_KEY":".*?"')
KEY=$(echo $API_KEY_JSON | sed -e 's/.*:"//g; s/"//g')

continuationKEY=$(parse_continuationJSON $text)

FILENUM=0
CONTINUE="y"
read -s -p "Read all videos? y/n" ALL
echo ""

while [[ "$CONTINUE" == "y" ]] || [[ "$ALL" == "y" ]]; do

#put continuationKEY in json
sed -i 's/"continuation": ".*"/"continuation": "'$continuationKEY'"/g' req.json

JSON=$(curl -sN -XPOST -H @headers.txt 'https://www.youtube.com/youtubei/v1/browse?key='$KEY'&prettyPrint=true' -d @req.json | tee output/reqest_$FILENUM.json)

VID_COUNT=$(cat output/* | grep '^ \{0,20\}"videoId"' | sed -e 's/.*: "//g;s/".*//g' | sort | uniq | wc -l)


continuationKEY=$(parse_continuationJSON $JSON)

if [[ "$continuationKEY" == "" ]]; then
    echo -e "\rTotal Video count: $VID_COUNT"
    echo "No more continuation"
    break
fi

if [[ "$ALL" != "y" ]]; then
    echo "Video count: $VID_COUNT"
    read -s -p "Continue? y/n" CONTINUE
    echo ""
else
    echo -ne "\rVideo count: $VID_COUNT"
    sleep 0.5
fi
FILENUM=$((FILENUM+1))
done

rm req.json headers.txt