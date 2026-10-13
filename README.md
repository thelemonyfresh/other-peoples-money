# CARMEN MICRO 2000 // OTHER PEOPLE'S MONEY (1991)

An interactive retro-terminal web player for Norman Jewison's 1991 Wall Street classic *Other People's Money*, styled faithfully after Larry the Liquidator's iconic **Carmen Micro 2000** financial workstation.

## Features

- **Early 90s Pixel CRT Aesthetic**: Monospaced terminal typography (`VT323`), 3D beveled hardware pushbuttons, CRT bezel framing, and an authentic scrolling Wall Street stock marquee.
- **Dual-Stem Audio Decomposition Matrix**: Independent faders for **Dialogue (DX)** and **Original Score (MX)**, isolated via state-of-the-art Hybrid Transformer Demucs (`htdemucs_ft`).
- **Interactive Audio Stems**:
  - `[DIALOGUE SOLO]` – Isolate speech (Larry the Liquidator's speeches, boardroom negotiations).
  - `[SCORE SOLO]` – Isolate David Newman's orchestral and synth score.
  - `[MASTER SUM]` – Original balanced stereo mix.
  - Granular faders and instant hardware mutes per stem.
- **23 Scened Chapter Records**: One-click seeking across all major dramatic scenes and speeches.
- **VHS Shuttle Search**: `[◄◄ REW]` / `[FF ►►]` step through 1x–16x (REW) and 2x–16x (FF) from the current position, with a VCR on-screen display and pitch-shifted stem audio up to 4x (silent above, like a real deck). Rewind plays pre-reversed copies of the media (see `pipeline_reverse.sh`).
- **4:3 Aspect Mode**: `[ASPECT]` toggles between the original widescreen frame and a centered 4:3 pan-and-scan crop, carried into fullscreen for 4:3 video monitors.
- **Responsive Multi-Device Layout**: Fully adaptive across desktop workstations, tablets, and mobile devices.
- **Hardware Keyboard Control**:
  - `[SPACE]` / `[K]` – Play / Pause (also exits REW/FF)
  - `[J]` / `[L]` – Rewind / Fast-Forward (press again for faster)
  - `[A]` – Toggle 4:3 aspect
  - `[F]` – Fullscreen
  - `[P]` / `[N]` – Previous / Next Chapter
  - `[1]` / `[2]` / `[3]` – Dialogue Solo / Score Solo / Master Sum
  - `[←]` / `[→]` – Seek -5s / +5s

## Separation Pipeline

Audio stems were separated using Demucs HTDemucs v4 in 4-stem mode (`vocals`, `drums`, `bass`, `other`), recombining `drums + bass + other` into an isolated high-bitrate AAC score track and preserving clean dialogue in a matching stem, synchronized to sub-millisecond precision with the video stream.

### Reversed Media (for REW)

`pipeline_reverse.sh` builds time-reversed copies of the served files (`full_video.mp4`, `full_dialogue.m4a`, `full_soundtrack.m4a` in `web/media/`) for the rewind feature. It reverses the media in short chunks (ffmpeg's reverse filters hold everything in memory) and verifies the frame count and durations match the originals:

```bash
DIR=/path/to/project JOBS=8 ./pipeline_reverse.sh
```

Upload the three outputs (`full_video_rev.mp4`, `full_dialogue_rev.m4a`, `full_soundtrack_rev.m4a`) next to the originals in the bucket. Until they exist, the `[◄◄ REW]` button stays disabled and everything else works as before.

### Local Development

Serve the repo root with a server that supports HTTP Range requests (needed for seeking), e.g. `npx http-server -p 8000`, and open `http://localhost:8000`. If `media/full_video.mp4` exists (`media` is a symlink to `web/media`, recreate it with `ln -s web/media media`), the player uses the local files instead of Cloud Storage.

## Live Deployment

- **Hosted Media**: Streamed via Google Cloud Storage with HTTP Range requests (`gs://thelemonyfresh_media_share/other_peoples_money/`).
- **Web App**: Deployed on GitHub Pages.
