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
- **Responsive Multi-Device Layout**: Fully adaptive across desktop workstations, tablets, and mobile devices.
- **Hardware Keyboard Control**:
  - `[SPACE]` – Play / Pause
  - `[F]` – Fullscreen
  - `[P]` / `[N]` – Previous / Next Chapter
  - `[1]` / `[2]` / `[3]` – Dialogue Solo / Score Solo / Master Sum
  - `[←]` / `[→]` – Seek -5s / +5s

## Separation Pipeline

Audio stems were separated using Demucs HTDemucs v4 in 4-stem mode (`vocals`, `drums`, `bass`, `other`), recombining `drums + bass + other` into an isolated high-bitrate AAC score track and preserving clean dialogue in a matching stem, synchronized to sub-millisecond precision with the video stream.

## Live Deployment

- **Hosted Media**: Streamed via Google Cloud Storage with HTTP Range requests (`gs://thelemonyfresh_media_share/other_peoples_money/`).
- **Web App**: Deployed on GitHub Pages.
