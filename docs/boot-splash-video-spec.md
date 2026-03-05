# PowerTune Boot Splash Video Specification

## Export Settings

| Parameter       | Value                          |
|-----------------|--------------------------------|
| Resolution      | 1600 x 720                     |
| Codec           | H.264 Baseline Profile         |
| Level           | 4.0                            |
| Frame Rate      | 30 fps                         |
| Pixel Format    | yuv420p                        |
| Bitrate         | 4-6 Mbps CBR                   |
| Audio           | AAC, 44100 Hz, Mono (silence)  |
| Container       | MP4 with faststart             |
| Background      | Solid black (no transparency)  |
| Duration        | 3 seconds recommended          |

## Why These Settings

- **1600x720** matches the display's native resolution. No scaling on the Pi.
- **H.264 Baseline** uses the Pi 4's dedicated hardware decoder. Zero CPU usage for decode.
- **30 fps** is the sweet spot: smooth motion without excessive data.
- **Solid black background** is mandatory. Transparency is not supported by the framebuffer output and will render as white.
- **Silent audio track** is required. The GStreamer pipeline expects both video and audio streams in the container.

## ffmpeg Command

If converting from an existing video or image sequence:

```
ffmpeg -i source_video.mov \
  -c:v libx264 -profile:v baseline -level 4.0 \
  -pix_fmt yuv420p \
  -r 30 \
  -b:v 5M -maxrate 6M -bufsize 8M \
  -refs 1 \
  -f lavfi -i anullsrc=r=44100:cl=mono \
  -c:a aac -b:a 64k \
  -shortest \
  -movflags +faststart \
  bootsplash.mp4
```

## NLE Export (After Effects / DaVinci Resolve / Premiere Pro)

1. Set composition/timeline to 1600 x 720, 30 fps.
2. Render with solid black background.
3. Export as H.264 / MP4.
4. Profile: Baseline.
5. Bitrate: CBR 5 Mbps.
6. Audio: AAC, 44100 Hz, Mono. Mute or include your own audio.
7. Enable "Fast Start" / "Web Optimized" / moov atom at start.

## Deployment

Copy the file to the Pi and reboot:

```
scp bootsplash.mp4 root@192.168.15.129:/home/pi/bootsplash.mp4
ssh root@192.168.15.129 reboot
```

The boot splash service (`/etc/init.d/bootsplash`) runs early in the init
sequence and plays the video with hardware-accelerated H.264 decoding to
the framebuffer. Once playback finishes, the PowerTune dashboard launches.

## Playback Pipeline

The GStreamer pipeline used at boot:

```
gst-launch-1.0 filesrc location=/home/pi/bootsplash.mp4 ! qtdemux name=d \
  d.video_0 ! queue ! h264parse ! v4l2h264dec ! video/x-raw,format=RGB16 \
  ! videoscale method=0 ! fbdevsink sync=true \
  d.audio_0 ! queue ! fakesink
```

- `v4l2h264dec` -- Raspberry Pi 4 hardware H.264 decoder
- `fbdevsink` -- writes decoded frames to /dev/fb0
- `sync=true` -- maintains frame timing for smooth playback
