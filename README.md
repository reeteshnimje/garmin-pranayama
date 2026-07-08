# Pranayama — Garmin Watch App

Offline Connect IQ watch app for building and running custom pranayama and meditation sessions on the Garmin Forerunner 265.

## Features

- **Session builder** — pick from five activities (Anulom Vilom, Bhramari, Bhastrika, Kapalbhati, Meditation), order them, and tune each one's timing and repetitions.
- **Guided runner** — color-coded progress ring around the bezel, phase countdown, per-phase vibration cues so the session works eyes-closed.
- **Fully offline** — sessions are stored on the watch with `Application.Storage`; no phone or network needed.

## Architecture

| File | Responsibility |
|---|---|
| [source/App.mc](source/App.mc) | App lifecycle, entry view |
| [source/Home.mc](source/Home.mc) | Home menu (native Menu2): saved sessions + New Session |
| [source/SessionMenu.mc](source/SessionMenu.mc) | Per-session actions: Start / Edit / Delete (with confirmation) |
| [source/Builder.mc](source/Builder.mc) | Three-step builder flow: select activities → order → configure |
| [source/NumberPicker.mc](source/NumberPicker.mc) | Full-screen value spinner (UP/DOWN adjust, START save) |
| [source/Runner.mc](source/Runner.mc) | Session playback: ms-accurate phase timing, progress ring, haptics |
| [source/SessionMath.mc](source/SessionMath.mc) | Durations, defaults, field specs, normalization |
| [source/SessionStore.mc](source/SessionStore.mc) | Persistence (Application.Storage) |
| [source/Vibes.mc](source/Vibes.mc) | Vibration helpers |
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
