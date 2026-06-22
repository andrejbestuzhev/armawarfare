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
| `droneAddActions` | client | FPV scroll actions on the player |
| `droneSelectAmmo` | client | cycle the warhead via the terminal |

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
