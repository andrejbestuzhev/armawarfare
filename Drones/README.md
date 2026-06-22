# FPV / Suicide-Drone Framework

Self-contained SQF framework (no addons, no Workshop dependency). Ships inside the
mission PBO. Adds **kamikaze detonation**, **bomb dropping**, an **FPV/manual** mode and
an **autonomous** suicide mode to *existing* drones. Vanilla default: AR-2 Darter
(`B_UAV_01_F`), assembled from `B_UAV_01_backpack_F`.

## Install
Already wired: `description.ext` includes `Drones\CfgFunctions.hpp`. The bootstrap runs
automatically on every machine (`postInit`) — nothing else to do.

## Functions (`MyDrones_fnc_*`)
| Function | Where | Purpose |
|----------|-------|---------|
| `droneInit` | server (auto-forwards) | EHs + state on a drone; idempotent; re-applies on respawn |
| `droneKamikaze` | server (auto-forwards) | spawn warhead + destroy drone (single-shot guarded) |
| `droneDropBomb` | server (auto-forwards) | release ordnance, drone survives; limited by bomb count |
| `droneAutoHunt` | server | loiter → acquire enemy → dive → detonate |
| `droneSpawn` | server (auto-forwards) | dynamic spawn + AI crew or player terminal |
| `droneAddActions` | client | Set/Detonate/Drop actions on the player |
| `droneAddDroneActions` | all machines | same actions on the drone's own context menu |
| `droneSetBombMenu` | client | open the "Set bomb" popup |
| `droneSetBomb` | client | arm/clear payload, charge BECTI funds |
| `droneSetPayload` | server (auto-forwards) | set payload: ammo + broadcast visible model (JIP-safe) |
| `droneAttachPayload` | all machines | (re)attach the visible payload model(s) |

## Payloads (visible suspended ordnance)
Three payloads ship in [`cfg/droneConfig.sqf`](cfg/droneConfig.sqf) → `DRONE_PAYLOADS`:
**Frag grenade**, **Satchel charge**, **RPG rocket**. Each ties a detonation `CfgAmmo`
to a **visible model** (read from the live game config, so the p3d path is always valid)
attached under the drone via `DRONE_PAYLOAD_OFFSET`, plus a `canDetonate` flag. Add/edit
entries there.

The operator cycles payloads with the **"Drone payload: cycle"** terminal action. The
model is shown to every client (JIP-safe, keyed by the drone's netId) and removed when the
drone dies or drops its bomb. Set the starting payload with `DRONE_DEFAULT_PAYLOAD`.

### Drop vs. detonate
- **Drop bomb** — releases the *selected* payload below the drone; it falls and detonates on
  ground impact (drone survives, payload consumed). Available for all payloads.
- **Detonate bomb** — explodes the carried payload in place (rockets are pinned so they blow
  up instead of flying off). Only enabled when the payload's `canDetonate` is true
  (**satchel / RPG**); a grenade is drop-only.

### Arming costs money (BECTI funds)
**Set bomb...** opens a popup with **[None, Frag grenade, Satchel charge, RPG rocket]**.
Anything but *None* costs `DRONE_BOMB_COST` ($500) in production, or `DRONE_BOMB_COST_DEBUG`
($1) in debug. Debug is detected via `DRONE_FNC_DEBUGPRICE`, which follows the mission's real
debug switch **`CTI_PRICES_DEBUG`** (see `Common\Config\Prices.sqf`), with `CTI_DEBUG` as a
fallback — read at runtime. *None* is free and strips the payload. Funds use BECTI's
`CTI_CL_FNC_GetPlayerFunds` / `CTI_CL_FNC_ChangePlayerFunds` (degrades to free if the
economy isn't present). FPV drones start with **no** payload (`DRONE_DEFAULT_PAYLOAD = none`);
autonomous drones self-arm with `DRONE_AUTO_PAYLOAD`.

Each payload's `count` field is both the number of visible models **and** the number of drops.
The grenade carries 6 → **6 separate drops**, one grenade removed from the ring per drop; the
payload is stripped only after the last round. Satchel/RPG carry 1.

### Where the actions live
- **Set bomb** — a **player** scroll action (`fn_droneAddActions`). It appears when you stand
  within `DRONE_SETBOMB_RANGE` (10 m) of a grounded AR-2 — the same context as the vanilla
  *Connect* — and arms that drone. Allowed type = base class `UAV_01_base_F` (all factions).
- **Detonate / Drop** — the **drone's own context menu** (`fn_droneAddDroneActions`), used
  **in the air** over a target (shown while piloting and to nearby players). Not ground-gated.

"On the ground" uses `DRONE_FNC_ONGROUND` (`isTouchingGround` OR height-above-terrain < 1.5 m)
because `isTouchingGround` alone can read false for UAVs.

The autonomous dive and the in-flight ram trigger detonate independently of these actions.

### Only the AR-2 can be armed
Arming a payload is restricted to the UAV types in `DRONE_ALLOWED_TYPES` (default the AR-2
Darter `B_UAV_01_F`). The "Set bomb" action is hidden for other UAVs, and `droneSetBomb`
refuses them. Clearing to *None* is allowed on any drone.

### Grenade payload
The grenade payload shows **6 grenades arranged in a ring** (`count = 6`, `ring = 0.15` m)
under the drone — tune `count`/`ring` per payload in `DRONE_PAYLOADS`.

### Ground vs. impact (resolved)
A drone **resting on the ground** never detonates from contact. A drone **striking the
ground/target** does. Two conditions gate the impact trigger:
1. `MyDrones_airborne` — set true only once the drone climbs past `DRONE_AIRBORNE_HEIGHT`
   (so a grounded/just-assembled drone is inert), and
2. impact speed ≥ `DRONE_RAM_MIN_SPEED` (so a gentle landing is ignored).

The scroll-menu **Detonate** action and the autonomous dive bypass this and fire directly.

## Config
All tunables live in [`cfg/droneConfig.sqf`](cfg/droneConfig.sqf) — ammo classes, detect/blast
radius, target sides, dive speed, bomb count. Change them there only.

## Usage

### A) FPV / manual (player-flown)
1. Player takes the `B_UAV_01_backpack_F` backpack, **Assemble**s the Darter, connects via
   the **UAV terminal** (vanilla → FPV camera + manual flight).
2. While connected, scroll actions appear on the player:
   - **Detonate drone** — kamikaze now.
   - **Drop bomb** — release ordnance (drone survives).
   - **Drone ammo: cycle warhead** — pick the warhead the drone will use.
3. The framework auto-inits the drone on connect, so a hard ram also detonates it.

### B) Pre-placed in Eden (autonomous)
In the drone's **init field**:
```sqf
this setVariable ["MyDrones_autonomous", true];
[this] call MyDrones_fnc_droneInit;
[this] call MyDrones_fnc_droneAutoHunt;
```
(or just `this setVariable ["MyDrones_autonomous", true];` — the bootstrap picks it up server-side.)

### C) Dynamic spawn (script)
```sqf
// Autonomous hunter:
["B_UAV_01_F", getPos myMarker, east, true] call MyDrones_fnc_droneSpawn;

// FPV drone handed to a player:
["B_UAV_01_F", getPos player, west, false, player] call MyDrones_fnc_droneSpawn;
```

## Multiplayer notes
- Creation, hunt loops and detonation run on the **server**; clients `remoteExec` to it.
- `MyDrones_detonated` guard prevents double explosions.
- Works on hosted and dedicated servers; survives drone respawn (`Respawn` EH).
