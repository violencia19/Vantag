# Sound Assets

This folder contains sound effects for the Vantag app.

## Sound Files

| File | Duration | Frequency | Purpose |
|------|----------|-----------|---------|
| `tap.mp3` | 50ms | 1200Hz | Button tap UI feedback |
| `success.mp3` | 200ms | 880→1320Hz | Expense added, settings saved |
| `coin.mp3` | 60ms | 2400Hz | Money-related actions |
| `celebration.mp3` | 500ms | C5-E5-G5-C6 | Pursuit completed, achievement |
| `victory.mp3` | 450ms | E5-A5-C6 | "Vazgectim" decision |
| `warning.mp3` | 300ms | 440→349Hz | Spending threshold exceeded |
| `countdown_tick.mp3` | 30ms | 1000Hz | Timer countdown |
| `cash_out.mp3` | 100ms | 1800→1400Hz | Expense confirmation |

## Audio Generation

All sounds are generated using FFmpeg with pure sine wave tones:
- Musical intervals (thirds, fifths) for pleasant sound
- Smooth fade in/out to avoid harsh attacks
- Short durations (30-500ms) for non-intrusive feedback
- Controlled volume levels (0.3-0.6 range)

## Audio Specifications

- Format: MP3 (libmp3lame)
- Sample Rate: 44.1kHz
- Bit Rate: 128 kbps
- Channels: Mono
- License: Generated tones (no licensing required)
