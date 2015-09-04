#!/bin/bash -e

if [ $# -ge 1 ]; then
  cd $1
else
  cd $(dirname $0)
fi

if [ $(ls -1 *.ts 2>/dev/null | wc -l) -eq 0 ]; then
  echo "No .ts segments found" >&2
  exit 1
fi

seq=0
filenum=0
while true; do
   for i in $(seq 1 $(ls -1 hls-high*.ts | wc -l)); do
      files="$(ls -1 hls-high*.ts | tail -n +${i} | head -n 5)"
      files="${files} $(ls -1 hls-high*.ts | head -n $[5-$(echo "$files" | wc -l)])"
      m3u8="#EXTM3U\n#EXT-X-TARGETDURATION:11\n#EXT-X-MEDIA-SEQUENCE:$seq\n"
      for file in $files; do
        filenum=$((10#${file:11:3}))
        duration=10
        #duration=$(mediainfo -f $file | grep '^Duration' | head -n 7 | tail -n 1 | awk '{ print $NF }' | xargs -I {} echo scale=0\; {} / 1000 | bc -l)
        m3u8="${m3u8}#EXTINF:$duration,\n$file\n"
      done
      printf "$m3u8\n" > live_withoutAds.m3u8
      sleep 10s
      seq=$[seq+1]
   done
done