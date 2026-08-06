#!/bin/sh

OMC_TMP_URL=/data/local/tmp/openmediacenter-url.txt

android_open_url() {
  URL="$1"

  [ -z "$URL" ] && return 1

  printf "%s\n" "$URL" > "$OMC_TMP_URL"

  PATH=/system/bin:/bin:/sbin:/usr/bin:/usr/sbin \
  /system/bin/am start \
    -n org.videolan.vlc/.gui.video.VideoPlayerActivity \
    -a android.intent.action.VIEW \
    -d "$URL" \
    -t "video/*"
}

resolve_youtube_url() {
  URL="$1"

  case "$URL" in
    http://*|https://*) ;;
    *) return 1 ;;
  esac

  QUALITY="${VIDEO_QUALITY:-360}"

  yt-dlp --no-warnings --no-playlist \
    -f "18/best[ext=mp4][height<=${QUALITY}]/best[height<=${QUALITY}]" \
    -g "$URL" | head -n 1
}
android_open_audio() {
  URL="$1"

  [ -z "$URL" ] && return 1

  busybox chroot /proc/1/root /system/bin/sh -c \
  "export PATH=/system/bin:/system/xbin:/sbin:/vendor/bin; \
  export LD_LIBRARY_PATH=/system/lib:/vendor/lib; \
  /system/bin/am start \
  -a android.intent.action.VIEW \
  -d '$URL' \
  -t 'audio/aac'"
}
