#!/bin/bash

while true
do
        echo "Polling Queue"

        bucket_name="s3://video-compression-s3/"
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

                aws sqs delete-message --queue-url https://sqs.us-east-2.amazonaws.com/712526075904/VideoUploadSQS --receipt-handle "${receipt}"

                object_key=`jq '.Body.Records[0].s3.object.key' <<< "$first_message"`
                object_key=`sed 's/\"//g' <<< $object_key`
                object_key_no_path=`sed 's|.*/||' <<< $object_key`

                aws s3 cp "${bucket_name}${object_key}" "${object_key_no_path}"

                ffmpeg -i before.mp4 -vf scale=320:240 "${object_key_no_path}_lq.mp4"

                new_path="${bucket_name}${object_key_no_path}"
                aws s3 cp "${object_key_no_path}_lq.mp4" "${new_path}/lq"
                aws s3 cp "${object_key_no_path}" "${new_path}/sq"
                aws s3 rm "${bucket_name}${object_key}"

                rm "${object_key_no_path}"
                rm "${object_key_no_path}_lq.mp4"
        fi

        sleep 10
done

