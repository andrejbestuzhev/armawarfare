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

---

## 3. FPV / Suicide-Drone Framework

Self-contained SQF framework under `Drones/` (no addon / Workshop dependency),
wired into `description.ext` via `#include "Drones\CfgFunctions.hpp"` and
`#include "Drones\gui.hpp"`. Auto-bootstraps on every machine via a `postInit`
function — it touches no BECTI logic. Full operator/usage notes live in
`Drones/README.md`; this section is the behavioural source of truth.

### 3.1 What it adds
Turns an existing **AR-2 Darter** (`UAV_01_base_F` — any faction variant) into a
payload carrier with two control modes:
- **FPV / manual** — the player assembles/connects the Darter (vanilla terminal →
  FPV camera) and arms/drops/detonates it.
- **Autonomous** — the drone loiters, finds the nearest enemy, dives and detonates
  (`fn_droneAutoHunt`). Spawn dynamically with `fn_droneSpawn`, or flag an
  Eden-placed drone (`this setVariable ["MyDrones_autonomous", true]`).

### 3.2 Payloads (visible, configurable)
`DRONE_PAYLOADS` in `Drones/cfg/droneConfig.sqf`. Each entry:
`[key, label, detonation CfgAmmo, modelConfig, modelClass, canDetonate, count, ring]`.

| Payload | Blast ammo | Visible model | canDetonate | count |
|---------|-----------|---------------|-------------|-------|
| grenade | `GrenadeHand` | `CfgMagazines >> HandGrenade` | no (drop-only) | **6** (ring r=0.15 m) |
| satchel | `SatchelCharge_Remote_Ammo` | `CfgMagazines >> SatchelCharge_Remote_Mag` | yes | 1 |
| rpg | `R_PG32V_F` | `CfgAmmo >> R_PG32V_F` (the rocket, **not** the launcher) | yes | 1 |

- The model path is read from the **live config** at runtime, so it is always valid.
- `count` is **both** the number of visible models **and** the number of drops.
  The visible ring depletes one model per drop.

### 3.3 Actions & where they live
- **Set bomb** — a **player** scroll action (`fn_droneAddActions`). Appears when the
  player stands within `DRONE_SETBOMB_RANGE` = 10 m of a **grounded** AR-2 (the same
  context as the vanilla *Connect*). Opens a popup `[None, Grenade, Satchel, RPG]`.
  Arming is **AR-2 only** (`DRONE_ALLOWED_TYPES`) and **ground only**
  (`DRONE_FNC_ONGROUND` = `isTouchingGround` OR height-above-terrain < 1.5 m, since
  `isTouchingGround` can read false for UAVs). *None* is free and strips the payload.
- **Detonate bomb / Drop bomb** — the **drone's own context menu**
  (`fn_droneAddDroneActions`), shown to the operator while piloting and to nearby
  players. Used **in flight** (not ground-gated). Detonate needs `canDetonate`
  (satchel/RPG); a grenade is drop-only. Drop releases one round and detonates it on
  ground impact; repeats until the count is exhausted.
- **Impact ram** — an armed drone detonates on a hard contact (`EpeContactStart`)
  once it has been airborne (`MyDrones_airborne`) and hits at ≥ `DRONE_RAM_MIN_SPEED`
  = 8 m/s. A drone resting on / landing softly on the ground does **not** detonate.

### 3.4 Economy
Arming any payload (except *None*) costs `DRONE_BOMB_COST` = **$500** in production,
`DRONE_BOMB_COST_DEBUG` = **$1** in debug. Debug is detected by `DRONE_FNC_DEBUGPRICE`,
which reads the mission's real switch **`CTI_PRICES_DEBUG`** (see §2), with `CTI_DEBUG`
as a fallback — evaluated at runtime. Funds go through BECTI's
`CTI_CL_FNC_GetPlayerFunds` / `CTI_CL_FNC_ChangePlayerFunds` (degrades to free if no
economy is present).

### 3.5 Multiplayer locality
- Drone creation, the auto-hunt loop and **all detonation** are server-authoritative;
  client actions `remoteExec` to the server (target `2`).
- A single-shot `MyDrones_detonated` guard prevents duplicate blasts across machines.
- Visible payload models are local objects (`createSimpleObject`) broadcast to **all**
  machines (`remoteExec` target `0`) with a **JIP id keyed to the drone's `netId`** so
  late joiners see the current payload; removed on death or after the last drop.
- Survives respawn (`Respawn` EH re-runs `fn_droneInit`).

### 3.6 Key tunables (`Drones/cfg/droneConfig.sqf`)
`DRONE_PAYLOADS`, `DRONE_DEFAULT_PAYLOAD` (=`none`), `DRONE_AUTO_PAYLOAD` (=`satchel`),
`DRONE_ALLOWED_TYPES`, `DRONE_SETBOMB_RANGE`, `DRONE_BOMB_COST`/`_DEBUG`,
`DRONE_DETECT_RANGE`/`DRONE_BLAST_RANGE`/`DRONE_DIVE_SPEED`/`DRONE_DIVE_HEIGHT`
(autonomous), `DRONE_RAM_MIN_SPEED`/`DRONE_AIRBORNE_HEIGHT` (impact arming).
