#!/bin/bash

# pick MESSAGES_TO_NUMBERS from config
source /Users/njindal/build/tweet-generator-schedular/config.sh
NUM_MESSAGES_TO_SEND=3

send_message() {
    local message_data=$1

    for number in "${MESSAGES_TO_NUMBERS[@]}"; do
        string_to_send=$(echo "tell application \"Messages\" to send \"$message_data\" to buddy \"$number\"")
        echo $string_to_send
        osascript -e "$string_to_send"
    done
}

generate_tweet() {
    instruction="<s>[INST] Craft a vibrant and surprising Tweet about happiness and fulfillment. Start with a captivating hook that piques curiosity and draws readers in. The tweet should be wide-reaching, evoking a sense of energy and positivity while also offering a fresh perspective. Make sure it’s relatable and leaves a lasting impression, with no hashtags included. [/INST]"

    output=$(/opt/homebrew/bin/llama-cli -m /Users/njindal/build/tweet-generator-schedular/mistral-7b-instruct-v0.1.Q8_0.gguf -p "$instruction" -n 128 --log-file /tmp/dust.log --log-disable --temp 1.0)

    # strip instruction and provide the output after that
    tweet=$(echo $output | sed -n 's/.*\[\/INST\]//p')

    # if there is a double quote in start and end both remove it
    tweet=$(echo $tweet | sed 's/^"//g' | sed 's/"$//g')

    # remove hashtags from end of tweet like #happiness #fulfillment only from the end
    tweet=$(echo $tweet | sed 's/ #[^ ]*//g')

    # escape double quotes
    tweet=$(echo $tweet | sed 's/"/\\"/g')

    echo $tweet
}

# day-HH:MM:SS
date_sent=$(date "+%A-%H:%M:%S")

send_message "Message sent at $date_sent"

for i in $(seq 1 $NUM_MESSAGES_TO_SEND); do
    tweet=$(generate_tweet)
    send_message "$tweet"
done