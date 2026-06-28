# Change History — armawarfare.Altis

Chronological log of notable mission changes. Newest first.
See `SPEC.md` for the current behavioural spec.

---

## 2026-06-28 — Mobile Radio Vehicle — jamming & menu fixes

Bug-fix pass on the Hunter/Ifrit (Radio) comms vehicle. Spec: `SPEC.md` §4.

- **Jamming now actually cuts comms.** The jam flag was stamped as
  `AN_Jammed = time + 5` on the server but read against each client's local mission
  `time` by the AdvNet guards (`AN_CheckConn.sqf` / `AN_Reconfigure.sqf`). `time` is
  counted per-machine and drifts apart over a long match, collapsing the window so the
  jam reached **nobody** — own side *or* enemy. Switched both the stamp and the two
  guards to **`serverTime`** (synchronised across machines) and widened the TTL to 6 s.
- **Scroll menu no longer "works once then disappears."** Each mode option used to hide
  itself the moment it became the active mode, so picking *jamming* made the *jamming*
  entry vanish — it read as a one-shot. Reworked `Radio_AddActions.sqf` into a stable
  toggle: both **retranslation** and **jamming** stay offered while stationary, and the
  active mode shows as `… (active)` and doubles as the **Off** switch.
- **Operator immunity clarified (unchanged):** the jammer exempts its own vehicle
  (`_x != _veh`) so the operator keeps comms; own-side units in range are still jammed.
- Touched: `AN_CheckConn.sqf`, `AN_Reconfigure.sqf`, `Radio_ServerVehicle.sqf`,
  `Radio_AddActions.sqf`.

> Not runtime-tested on this box — needs a mission reload on the server to confirm
> in-game.

## 2026-06-22 — FPV / Suicide-Drone Framework (`Drones/`)

New self-contained SQF framework (no addon dependency) that turns the AR-2 Darter
into a payload carrier. Spec: `SPEC.md` §3. Operator notes: `Drones/README.md`.
Built and refined iteratively against playtest feedback:

### Initial build
- Created `Drones/` module: `CfgFunctions.hpp`, `cfg/droneConfig.sqf`, and
  `functions/fn_drone*.sqf` (init, kamikaze, drop, autoHunt, spawn, actions).
- Wired via one `#include` in `description.ext`; auto-bootstrap through a `postInit`
  function — **no edits to BECTI logic**.
- Server-authoritative detonation/spawn/hunt; client→server `remoteExec`; single-shot
  `MyDrones_detonated` guard against duplicate blasts; `Respawn` re-init.
- Resolved the "resting on ground vs. striking ground" conflict via an airborne latch
  (`MyDrones_airborne`) + minimum ram speed (`DRONE_RAM_MIN_SPEED`).

### Iteration 1 — payloads
- Added selectable payloads **grenade / satchel / RPG** with a **visible** model
  attached under the drone (`fn_droneAttachPayload`, model read from live config).

### Iteration 2 — drop/detonate semantics
- **RPG**: detonate now blows the warhead **in place** (zero velocity + `setDamage`)
  instead of launching the rocket; visible model switched from the launcher to the
  **rocket** (`CfgAmmo >> R_PG32V_F`).
- **Drop bomb**: now drops the *selected* payload (was a fixed mine that never went
  off) and detonates it on ground impact.
- Renamed **Detonate drone → Detonate bomb**; gated to payloads with `canDetonate`
  (satchel / RPG); a grenade is drop-only.

### Iteration 3 — restrictions
- Arming restricted to the **AR-2** (`DRONE_ALLOWED_TYPES`, by base class
  `UAV_01_base_F` so all faction variants qualify).
- Added the **Set bomb** popup `[None, Grenade, Satchel, RPG]`; arming costs funds.

### Iteration 4 — action placement (de-duplication)
- **Set bomb** is a **player** action near a grounded AR-2 (same context as vanilla
  *Connect*), within `DRONE_SETBOMB_RANGE` = 10 m.
- **Detonate / Drop** live on the **drone's own context menu**, usable **in flight**
  (earlier ground-gating was removed — dropping/detonating over a target is the point).
- Eliminated duplicate scroll entries by keeping each action in exactly one place.
- Made "on the ground" robust (`DRONE_FNC_ONGROUND`: `isTouchingGround` OR height
  < 1.5 m) because `isTouchingGround` can read false for UAVs.

### Iteration 5 — drops & pricing fixes
- **Grenade now gives 6 drops** (one per visible grenade): `count` field drives both
  the model ring and the number of drops; the ring depletes one model per drop and the
  payload is stripped only after the last round.
- **Debug pricing fixed**: the cost now keys off the mission's real debug switch
  **`CTI_PRICES_DEBUG`** (`Common/Config/Prices.sqf`) via `DRONE_FNC_DEBUGPRICE`
  (fallback `CTI_DEBUG`), read at runtime. Debug = **$1**, production = **$500**
  (previously always charged $500 because it checked the wrong flag).

> Not runtime-tested on this box (no SQF linter / server launch here): bracket balance
> and config wiring verified statically. Validate in-editor with `-showScriptErrors`,
> especially that the chosen `CfgAmmo`/model classes produce the intended blasts.

---

## 2026-06-22 — Town presence counts AI, not just leaders

Strategic-mode town activation/garrison checks now count **all team units** (player +
AI), where they previously counted only the team **leader** (`leader _x` → `units _x`).
A lone AI in the activation radius now activates/sustains a town like a player. Applied
in `SM_Allow_Capture.sqf`, `town_occupation.fsm`, `town_resistance.fsm`. See `SPEC.md` §1.5.
