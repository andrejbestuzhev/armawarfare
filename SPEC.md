# ArmaWarfare (BECTI) — Mission Spec

Gameplay/scripting specification for this mission. Infrastructure (server
provisioning, PBO packing, deployment) is documented in the **parent server
repo's** `SPEC.md`; this file covers only in-mission logic.

- Engine: Real Virtuality 4 (Arma 3), SQF
- Base: BECTI (Benny Edition CTI 0.97 — Zerty Modification), Strategic Mode
- Map: Altis

---

## 1. Town Activation, Occupation & Capture

The **town lifecycle** in Strategic Mode. Source of truth:
`Addons/Strat_mode/Functions/SM_Allow_Capture.sqf` (the per-side 5 s loop) and
the per-town FSMs under `Addons/Strat_mode/FSM/`.

### 1.1 Key terms
- **Active town** — a town present in a side's `CTI_ACTIVE` list. Membership is
  what makes the engine **spawn that town's defenders**; removal **despawns**
  them. Each side (West/East) keeps its **own** `CTI_ACTIVE` and runs its own
  `SM_Allow_Capture` loop every 5 s.
- **Activation radius** — `CTI_TOWNS_RESISTANCE_DETECTION_RANGE` = **800 m** from
  town centre, units below `..._RANGE_AIR` = **60 m** altitude (aerial units are
  ignored).
- **Flag / capture zone** — `CTI_TOWNS_CAPTURE_RANGE` = **75 m** (much smaller
  than the activation radius).
- **Owner** — `cti_town_sideID`. A **neutral** town's owner is **Resistance**
  (`CTI_RESISTANCE_ID`); "foreign/enemy unit" always means *not the owner's side*.

### 1.2 Activation → Deactivation (the core rules)
- **Activate** (spawn defence): a unit — **player OR AI** — of a side enters the
  activation radius of a town **not owned by that side**. The defenders that
  spawn depend on the owner:
  - **Neutral town** → **Resistance** garrison (`town_resistance.fsm`).
  - **Owned town** (West/East) → the **owner's** garrison (`town_occupation.fsm`).
- **Stay active** while the town's garrison is present — `cti_town_occupation_active`
  (enemy-owned) or `cti_town_resistance_active` — or it is the commander's priority
  target (`SM_Allow_Capture.sqf` cleanup pass).
- **Deactivate** = **despawn all defence.** The town leaves `CTI_ACTIVE` and its
  spawned squads are deleted once the garrison flag clears — i.e. once there has
  been **no enemy contact** for the garrison timeout (see 1.3).

### 1.3 The occupation / resistance flags
`cti_town_occupation_active` and `cti_town_resistance_active` mean **"this town's
garrison is currently spawned and live."** Properties:
- Each flag is written by **its FSM only** (`town_occupation.fsm` /
  `town_resistance.fsm`). Every other system **reads** them, never writes.
- Set **true** right after the garrison spawns (`CTI_SE_FNC_SpawnTownOccupation`),
  **false** when the FSM despawns it.
- Despawn is **timeout-driven, not death-driven**: the garrison is removed
  `CTI_TOWNS_OCCUPATION_INACTIVE_MAX` = **240 s** (occupation) /
  `CTI_TOWNS_RESISTANCE_INACTIVE_MAX` = **30 s** (resistance) after the last enemy
  contact — the flag does **not** flip the instant the last defender dies.
- They **gate capture**: the capture counter only ticks while the town is in
  `CTI_ACTIVE` **and** a garrison flag is set (`town_capture.fsm`).

### 1.4 Capture (verified working — do not touch)
Logic in `town_capture.fsm`:
- Counts units of each side within the 75 m flag zone (`countSide`): `_west`,
  `_east`, `_resistance`. Garrison defenders of the owner are zeroed as
  *capturers* but still **protect** (push the capture level back up).
- **Dominion = strict majority**: a side captures only if its count is strictly
  greater than each of the other two. A tie or mixed presence → `civilian` →
  **capture frozen** (this is "side A and side B both at the flag → no capture").
- **Resistance is a full capturing side** (e.g. a Resistance soldier can walk
  onto the flag of a side's town that was just cleared and take it).
- Capture is a counter: `CTI_TOWNS_CAPTURE_VALUE_CEIL` = 18, `..._ITERATE` = 1 per
  5 s → ~90 s of uncontested dominion to flip a town.

### 1.5 Change made (2026-06-22): town presence counts AI, not just leaders
The mission's one behavioural change: every **town-presence check** now counts
**all team units** — player **and** their AI — where it previously counted only
the team **leader** (`leader _x` → `units _x`). A lone AI bot in the radius now
activates and sustains a town exactly like a player would. It is applied at
**every** such check, so activation and the garrison/deactivation logic stay
consistent — the leader-vs-units mismatch was what made bot-activated towns
flicker and spam `STR_TownInactive`:
- `Addons/Strat_mode/Functions/SM_Allow_Capture.sqf` — town **activation** loop.
- `Addons/Strat_mode/FSM/town_occupation.fsm` — enemy detection that keeps the
  owner's garrison alive/engaged while attackers are near.
- `Addons/Strat_mode/FSM/town_resistance.fsm` — same, for the Resistance garrison.

(`town_capture.fsm` already counted `units _x`, so capture was unaffected; the
cleanup pass in `SM_Allow_Capture.sqf` keeps its original flag-based logic.)

### 1.6 Known nuances
- **Deactivation/despawn is timeout-bounded** by the garrison timeouts
  (`CTI_TOWNS_OCCUPATION_INACTIVE_MAX` = 240 s, `CTI_TOWNS_RESISTANCE_INACTIVE_MAX`
  = 30 s): "no enemy units → despawn defenders" is realised by the garrison FSM
  clearing its flag after that long without contact, not by an instantaneous body
  count. With the 1.5 change the timer is refreshed by **AI attackers too**, so a
  bot assault keeps the garrison alive the same as a player assault.
- **Strategic-mode modifiers** still apply on top of the core rules in
  `SM_Allow_Capture.sqf`: `CTI_SM_STRATEGIC` (=1) restricts activation to towns
  **adjacent** to one the side owns; `CTI_SM_STRATEGIC_NB` (=3) caps how many towns
  a side may have active at once; the commander's `CTI_PRIORITY` and admin
  `CTI_PREVENT` can force a town active/locked.

---

## 2. Pricing / Economy (central price book)

All purchasable prices and build/research times are centralised under
`Common/Config/Prices/`, loaded by `Common/Config/Prices.sqf` (itself called from
`init.sqf` before the unit/gear/upgrade configs).

- `Prices/Units.sqf` — unit & vehicle prices **+ build times** (West/East/Resistance)
- `Prices/Inventory.sqf` — weapon / magazine / item prices (West/East)
- `Prices/Upgrades.sqf` — upgrade costs **+ research times** (with `*CTI_UPGRADE_RATIO`)
- `Prices/Buildings.sqf` — structure prices + build times, defense prices

Maps are keyed by classname (units/gear/buildings) or ordered arrays (upgrades).
Each source config (`Units_*`, `Gear_*`, `Upgrades_*`, `Base_*`) reads these maps
at the end and overrides its inline defaults; an entry absent from the price book
keeps that file's inline fallback value.

**Debug mode** — `CTI_PRICES_DEBUG` in `Prices.sqf`: when `true`, every price = 1
and every time (research / build) = 1 s. **Set `false` for production.**
