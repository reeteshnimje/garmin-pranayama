# Connect IQ Store Listing

Everything needed to submit Pranayama to the Connect IQ Store. Copy the fields
below into the developer dashboard at <https://apps.garmin.com/developer/dashboard>.

## App name

**Pranayama — Breath & Meditation**

(The on-device launcher name stays the short "Pranayama".)

## Short description (one line)

> Build your own pranayama practices and run them eyes-closed, fully offline.

## Full description

> **Pranayama turns your Forerunner into a personal breathwork guide — no phone, no network, no subscription.**
>
> Most breathing apps decide the practice for you. Pranayama doesn't. Compose a
> session from classical techniques, set the breath lengths and repetitions you
> actually use, and start it the next morning with a single press.
>
> **Five techniques**
> • Anulom Vilom (alternate-nostril, classical 1:4:2 breath ratio)
> • Bhramari
> • Bhastrika
> • Kapalbhati
> • Silent Meditation
>
> **Made for eyes-closed practice**
> A distinct vibration marks every phase — one short pulse to inhale, two quick
> pulses to hold, one long pulse to exhale, silence to rest. You never need to
> look at the watch. When you do, a colour-coded ring around the screen breathes
> with you: filling as you inhale, holding full, draining as you exhale.
>
> **Effortless to start, safe to stop**
> Your last practice is one button away on the home screen. A gentle five-second
> settle-in precedes the first breath. Pause any time; the watch confirms before
> ending so a long sit is never lost by accident.
>
> **It remembers**
> Completed sessions save to Garmin Connect as Breathwork activities with heart
> rate, and your practice streak is tracked right on the watch.
>
> Breathe well.

## Category

Health & Fitness  (secondary: Tools / Utilities)

## Compatible devices

Forerunner 265

## Permissions requested

- **FIT / Activity Recording** — to save completed sessions to Garmin Connect as Breathwork activities.

No internet, position, or user-profile permissions are used. The app stores
practice definitions and history only on the watch.

## Privacy policy

Not required — the app collects no personal data and makes no network requests.
If the dashboard asks for a URL, state that no data is collected or transmitted.

## Store assets

| Asset | Requirement | File |
|---|---|---|
| Store icon | Square, provided at multiple sizes | `assets/500x500icon.png`, `assets/128x128icon.png` |
| Screenshots | 1–10, device-framed | `assets/screenshot-home.png`, `screenshot-usage.png`, `screenshot-complete.png`, `screenshot-setup.png`, `screenshot-manage.png` |
| App binary | Signed `.iq` package | produced by `./scripts/package.sh` → `bin/pranayama.iq` |

Suggested screenshot order and captions:

1. **home** — "Your practice, one press away."
2. **setup** — "Compose from five techniques."
3. **usage** — "A ring that breathes with you."
4. **complete** — "Streaks and Garmin Connect sync."
5. **manage** — "Edit and organise your practices."

## Pricing

Free.

## Submission checklist

- [ ] Connect IQ developer account created
- [ ] `developer_key` backed up somewhere safe (required for every future update)
- [ ] `./scripts/package.sh` produces `bin/pranayama.iq` with no errors
- [ ] Store icon uploaded
- [ ] Screenshots uploaded with captions
- [ ] Description, category, permissions filled in
- [ ] `.iq` uploaded and submitted for review
