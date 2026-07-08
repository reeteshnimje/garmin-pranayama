# Pranayama — Garmin Watch App

Offline Connect IQ watch app for building and running custom pranayama and meditation sessions on the Garmin Forerunner 265.

## Features

- **One press to practice** — the home screen is a quick-start carousel showing your last-used session; START begins it, UP/DOWN moves between practices, and a trailing "Manage" card handles create/edit/delete (no MENU button required — the FR265 doesn't have one).
- **Session builder** — pick from five activities (Anulom Vilom, Bhramari, Bhastrika, Kapalbhati, Meditation), order them, and tune each one's timing and repetitions. New sessions are auto-named from their contents.
- **Eyes-closed haptic language** — one short pulse for inhale, two quick pulses for hold, one long pulse for exhale, silence for pause. The whole session runs without looking at the screen.
- **Breath-paced ring** — the bezel ring fills as you inhale, holds full, and drains as you exhale; timed activities count down.
- **Settle-in countdown** — five quiet seconds before the first inhale.
- **Pause and end-guard** — START pauses/resumes mid-session; BACK asks for confirmation before ending.
- **Garmin Connect sync** — completed sessions are saved as Breathwork activities (FIT recording with heart rate). Sessions ended before one minute are discarded.
- **Streaks** — practice history is kept on-watch; the home card and completion screen show your current streak.
- **Starter presets** — first launch seeds "Morning Calm" (Anulom Vilom + meditation) and "Quick Reset" (Bhramari) so there's a practice ready immediately.

## Architecture

| File | Responsibility |
|---|---|
| [source/App.mc](source/App.mc) | App lifecycle, preset seeding, entry view |
| [source/Home.mc](source/Home.mc) | Quick-start card + management menu (native Menu2) |
| [source/SessionMenu.mc](source/SessionMenu.mc) | Per-session actions: Start / Edit / Delete (with confirmation) |
| [source/Builder.mc](source/Builder.mc) | Three-step builder flow: select activities → order → configure |
| [source/NumberPicker.mc](source/NumberPicker.mc) | Full-screen value spinner (UP/DOWN adjust, START save) |
| [source/Runner.mc](source/Runner.mc) | Playback: ms-accurate timing, breath-paced ring, pause, FIT recording |
| [source/History.mc](source/History.mc) | Practice log and streak calculation |
| [source/SessionMath.mc](source/SessionMath.mc) | Durations, defaults, field specs, normalization |
| [source/SessionStore.mc](source/SessionStore.mc) | Persistence, last-session tracking, starter presets |
| [source/Vibes.mc](source/Vibes.mc) | Haptic language (per-phase vibration patterns) |
| [source/Constants.mc](source/Constants.mc) | Activity types, storage keys, colors |

Breath ratios follow the classical 1:4:2 pattern for Anulom Vilom (inhale : hold : exhale), derived from the configured inhale length.

## Build

Requires the Garmin Connect IQ SDK and a Java 17 runtime. The helper scripts call the SDK's Java entrypoints directly:

```sh
./scripts/build.sh                 # compile to bin/pranayama.prg
./scripts/run-sim.sh               # load into the Connect IQ simulator (launch it first)
```

Optional arguments:

```sh
./scripts/build.sh /path/to/developer_key /path/to/output.prg
./scripts/run-sim.sh /path/to/output.prg fr265
```

Override SDK/Java locations with `CIQ_SDK_BIN` and `JAVA_BIN` environment variables.

The developer signing key (`developer_key`) is intentionally untracked — generate your own via the Connect IQ SDK if you fork this.

## References

See [docs/garmin-official-references.md](docs/garmin-official-references.md) for the Garmin documentation used for lifecycle, storage, views, input, timers, vibration, and Forerunner 265 targeting.
