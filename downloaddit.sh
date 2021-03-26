#!/bin/bash
# Download reddit videos

outfile="./output.html" #Output for the web page file
url="$1" # Post url from reddit
videoOutput="$2" # Final video

function main() {
        removeFiles
        echo "Downloading page..."
        wget -q -O $outfile $url
        res=$?
        
        echo "Checking errors..." 
        checkErrors "$res"

        echo "Parsing video URL..."
        videoURL=$(parseURL)
        
        echo "Downloading video..."
        mergeAudioVideo $videoURL

        echo "Cleaning up the mess..."
        removeFiles

        echo "Done! Video saved in $videoOutput"     

        echo "Done! Video saved in $videoOutput"
}

function downloadVideo() {
        for SIZE in 720 480 96; do
                wget -q "$1/DASH_$SIZE.mp4" -O - && break
        done
}
function downloadAudio(){
        wget -q "$1/DASH_audio.mp4" -O -
}

function mergeAudioVideo(){
        if wget -q --spider "$1/DASH_audio.mp4"; then
                ffmpeg -i <(downloadVideo $1) -i <(downloadAudio $1) -c:v copy -c:a aac "$videoOutput"
        else
                downloadVideo "$1" > "$videoOutput"
        fi
}

function parseURL() {
        sed -E 's/\},\s*\{/\},\n\{/g' "$outfile" |
        grep -o -E 'https://v.redd.it/.{0,13}' | 
        head -n1
}

function removeFiles() {
        rm -f output.html DASH_720.mp4 DASH_audio.mp4
}

function checkErrors() {
        if [ $1 -ne 0 ]; then
                echo 'Error downloading page'
                exit -1
        fi
}

main
