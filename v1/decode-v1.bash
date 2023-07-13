#!/bin/bash

while true
do
    echo "Polling Queue"

    bucket_name="<bucket-name>"
    queue_url="<queue-name>"

    json=`aws sqs receive-message --queue-url "${queue_url}"`
    if [ "$json" ]
    then
        json=`sed 's/\\\"/\"/g' <<< $json`
        json=`sed 's/\"{/{/g' <<< $json`
        json=`sed 's/}\"/}/g' <<< $json`
        echo "$json"

        first_message=`jq '.Messages[0]' <<< "$json"`

        receipt=`jq '.ReceiptHandle' <<< "$first_message"`
        receipt=`sed 's/\"//g' <<< $receipt`

        aws sqs delete-message --queue-url "$queue_url" --receipt-handle "${receipt}"

        object_key=`jq '.Body.Records[0].s3.object.key' <<< "$first_message"`
        object_key=`sed 's/\"//g' <<< $object_key`
        object_key_no_path=`sed 's|.*/||' <<< $object_key`

        aws s3 cp "${bucket_name}uploads/${object_key}" ~/sq.mp4

        ffmpeg -i ~/sq.mp4 -vf scale=320:240 ~/lq.mp4

        new_path="${bucket_name}${object_key_no_path}"
        aws s3 cp ~/lq.mp4 "${new_path}/lq.mp4"
        aws s3 cp ~/sq.mp4 "${new_path}/sq.mp4"
        aws s3 rm "${bucket_name}${object_key}"

        rm ~/lq.mp4
        rm ~/sq.mp4
    fi

        sleep 10
done

