<!-- PROTOTYPE - NOT FOR PRODUCTION -->
<!-- Question: Is "dive deeper for rarer creatures while your base is open to thieves" fun on Roblox? -->
<!-- Date: 2026-11-08 -->
# Steal the Rot — Roblox prototype

**Hypothesis:** Diving into the Rot Cave for rarer creatures is more exciting when your base is
unguarded while you're down there. We'll know it works if players (1) go deeper than floor 2 on
their own, (2) rush back up because someone is stealing, and (3) want to keep playing after 15 minutes.

**Status:** in-progress (not yet run in Roblox Studio)

**Findings:** (fill in after playtests)

## Setup in Roblox Studio (about 5 minutes)

You need a Windows or Mac computer with Roblox Studio.

1. Open Roblox Studio → **New** → **Baseplate**.
2. Open the **View** tab and turn on **Explorer** and **Output**.
3. **Config:** in Explorer, hover **ReplicatedStorage** → click **+** → **ModuleScript**.
   Rename it to exactly `RotConfig`. Delete the text inside and paste all of `RotConfig.luau`.
4. **Server:** hover **ServerScriptService** → **+** → **Script**. Rename it `GameServer`.
   Delete the text inside and paste all of `GameServer.server.luau`.
5. **Screen:** open **StarterPlayer** → hover **StarterPlayerScripts** → **+** → **LocalScript**.
   Rename it `RotHUD`. Delete the text inside and paste all of `RotHUD.client.luau`.
6. Press **Play** (F5).

To test stealing you need two players: **Test** tab → **Clients and Servers** → set **2 Players** →
**Start**. Two game windows open; play one as the thief.

If something breaks, the **Output** window shows red error text. Copy it and send it to Claude.

## How to play

- You spawn in **your base** (sign on the back fence shows your name).
- Walk to the purple **ENTER THE ROT** circle in the middle and hold **E** (or tap the button on mobile) to dive.
- In the cave, hold **E** on a creature to **grab** it. Glowing ones take longer and run away. Max 3 in your hands.
- **Climb out** at the orange rope to bring them home, or **Go deeper** at the red hole for rarer ones.
- Your **Sanity** bar drains faster every floor. At 0 you're yanked home with only your rarest creature.
- Creatures on your pedestals earn **$ every second**. Spend it in the **SHOP** (bigger Sanity, more hands).
- Other players can **Steal** creatures from your base while it's open. **Lock** it at the red pad
  (60 s, then a cooldown), or chase thieves and hit them with the **Bonk Bat** to send the creature home.
- Bonk someone in the cave and they drop their last grabbed creature.

## Not in this prototype

Saving progress, real 3D creature models, sounds beyond the bat, the Bottom, monetization.
