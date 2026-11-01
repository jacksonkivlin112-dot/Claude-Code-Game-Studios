# Game Concept: Deep Rot

*Created: 2026-11-01*
*Status: Draft*

---

## Elevator Pitch

> It's a push-your-luck collection simulator where you dive into a bottomless
> cave of absurd brainrot creatures, grab the rarest ones you can, and get back
> to the surface before your Sanity Meter runs out — then show off your haul on
> your plot for the whole server to see.

---

## Core Identity

| Aspect | Detail |
| ---- | ---- |
| **Genre** | Collection simulator + push-your-luck dive (light roguelite tension) |
| **Platform** | Roblox (PC, mobile, console via Roblox client) |
| **Target Audience** | Roblox simulator players, ages ~9–16 — see Target Player Profile |
| **Player Count** | Multiplayer server (shared lobby/plots, co-op dives with light interference) |
| **Session Length** | 30–60 min; one dive is ~3–5 min |
| **Monetization** | F2P — cosmetics, plot decorations, convenience passes. Never depth or Sanity (see Anti-Pillars) |
| **Estimated Scope** | Small (4–8 weeks, solo, first game) |
| **Comparable Titles** | Pet Simulator 99, Grow a Garden, R.E.P.O. / Lethal Company (push-your-luck with friends) |

---

## Core Fantasy

You are a greedy, slightly unhinged treasure hunter pushing deeper into a cave
that gets stranger every floor. The thrill is the gamble — *one more floor* —
and the payoff is walking back into the lobby carrying something nobody else
on the server has ever seen.

---

## Unique Hook

It's like a pet/collection simulator, **and also** every haul is a gamble:
the deeper you go, the rarer the creatures and the faster your sanity drains,
and you decide when to turn back. The simulator grind becomes a tense,
funny risk decision instead of a click-and-wait.

---

## Player Experience Analysis (MDA Framework)

### Target Aesthetics (What the player FEELS)

| Aesthetic | Priority | How We Deliver It |
| ---- | ---- | ---- |
| **Challenge** (obstacle course, mastery) | 1 | The deeper-or-back-up decision; timed grabs on squirmy rares; faster Sanity drain with depth |
| **Discovery** (exploration, secrets) | 2 | Each floor weirder than the last; Rot Index to complete; the mystery of the Bottom |
| **Expression** (self-expression, creativity) | 3 | Plot showcase of your hauled creatures, visible to the server; rare-find announcements |
| **Fellowship** (social connection) | 4 | Co-op dives; bumping friends so they drop a catch; shared server flex |
| **Sensation** (sensory pleasure) | 5 | Each creature's ridiculous grab sound; juicy pickup/bank feedback |
| **Fantasy** (make-believe, role-playing) | 6 | Greedy cave-diver identity |
| **Narrative** (drama, story arc) | 7 | Environmental only — floor signs, the Bottom's mystery |
| **Submission** (relaxation, comfort zone) | 8 | Shallow floors are low-stakes; offline plot income |

### Key Dynamics (Emergent player behaviors)
- Players will argue with themselves (and friends) about whether to risk one more floor.
- Players will screenshot and share rare finds and the weirdest creatures.
- Friends will "accidentally" bump each other at the worst moment, then laugh about it.
- Players will learn floor layouts and sanity timing to push deeper on the same upgrades.

### Core Mechanics (Systems we build)
1. **Dive & Sanity** — descending floors, a Sanity Meter that drains faster with depth, forced surfacing at 0 (keep only the rarest held creature).
2. **Grab & Carry** — spot, grab (timed for rares), carry with limited slots; bumping makes a player drop their top creature.
3. **Plot & Economy** — banked creatures go on your plot and earn Rot Coins passively (including offline).
4. **Upgrades** — Sanity tank, carry slots, grab speed; each lets you go one floor deeper.
5. **Rot Index** — discovery log of every creature found, with rarity tiers.

---

## Player Motivation Profile

### Primary Psychological Needs Served

| Need | How This Game Satisfies It | Strength |
| ---- | ---- | ---- |
| **Autonomy** (freedom, meaningful choice) | The player always decides when to turn back and what to carry | Core |
| **Competence** (mastery, skill growth) | Upgrades and learned timing visibly push the player deeper each session | Core |
| **Relatedness** (connection, belonging) | Diving with friends, bumping, flexing plots on a shared server | Supporting |

### Player Type Appeal (Bartle Taxonomy)

- [x] **Achievers** (goal completion, collection, progression) — How: complete the Rot Index, reach the Bottom, upgrade ladder.
- [x] **Explorers** (discovery, understanding systems, finding secrets) — How: new creatures and rules every floor; the Bottom's mystery.
- [x] **Socializers** (relationships, cooperation, community) — How: co-op dives, plot showcase, rare-find server announcements.
- [ ] **Killers/Competitors** (domination, PvP, leaderboards) — Only lightly, via bumping; no real PvP.

### Flow State Design

- **Onboarding curve**: First dive is on Floor 1 with a near-full Sanity Meter and guaranteed common creatures; the first forced surfacing happens on purpose so players learn "keep the rarest" without real loss.
- **Difficulty scaling**: Sanity drain rate and creature squirm both rise per floor; upgrades raise the player's ceiling one floor at a time.
- **Feedback clarity**: Max-depth reached and Rot Index % shown on the plot; Sanity Meter is always on screen with an escalating visual distortion.
- **Recovery from failure**: Instant — surfacing drops you in the lobby next to the cave entrance; a new dive starts in seconds. You always keep one creature.

---

## Core Loop

### Moment-to-Moment (30 seconds)
Spot a creature, grab it, carry it. Commons grab instantly; rares squirm and
need a timed grab. Every creature makes its own absurd sound when grabbed.
The Sanity Meter ticks down the whole time, faster the deeper you are.

*Decision logged (autonomous):* core action feel is **frantic grab-and-run**.
Alternatives considered: careful stealth grab, relaxed scoop.

### Short-Term (5-15 minutes)
One dive: descend floor by floor. At each floor exit, choose **go deeper or
head back up**. Surfacing banks everything you carry onto your plot, where it
earns Rot Coins.

*Decision logged (autonomous):* at Sanity 0 the player is yanked to the
surface and loses all carried creatures **except the single rarest one**.
Alternatives considered: lose everything (too punishing for the audience),
lose nothing and pay a fee (removes the tension).

### Session-Level (30-120 minutes)
Several dives with upgrade purchases between them (Sanity tank, carry slots,
grab speed). A good session ends with a new max depth or a new Rot Index entry
— a natural stopping point — while the plot keeps earning offline.

### Long-Term Progression
Deeper floors, Rot Index completion, and (post-MVP) a rebirth for a coin
multiplier. The long goal is to **reach the Bottom** and uncover what's down
there.

### Retention Hooks
- **Curiosity**: The next, weirder floor; empty Rot Index slots; the Bottom.
- **Investment**: A plot full of creatures earning offline coins.
- **Social**: Friends on the server; diving together; showing off rares.
- **Mastery**: Pushing max depth with better timing and route knowledge.
- **Daily** (post-MVP): a rotating "weird floor" with special rares.

---

## Game Pillars

*Decision logged (autonomous):* pillars locked as drafted. CD-PILLARS and
AD-CONCEPT-VISUAL skipped — Lean mode.

### Pillar 1: One More Floor
The turn-back decision is the heart of the game.

*Design test*: Debating two features, pick the one that makes "deeper or back
up?" a tenser choice.

### Pillar 2: Rot Is Funny, Not Cruel
Failure is a laugh, and the player always keeps something.

*Design test*: Debating two penalties, pick the funnier one over the harsher one.

### Pillar 3: Flex What You Found
Every rare find can be seen by other players.

*Design test*: Debating two options, pick the one other players can see.

### Pillar 4: Weirder the Deeper
Depth is discovery — each floor adds new creatures and new rules.

*Design test*: New content goes deeper, not wider.

*Tension by design:* Pillar 1 (risk) and Pillar 2 (soft punishment) pull
against each other; the "keep the rarest" rule is where they meet.

### Anti-Pillars (What This Game Is NOT)

- **NOT pay-for-depth**: We will not sell depth or Sanity for Robux — it would hollow out **One More Floor**. Cosmetics and convenience are fine.
- **NOT a PvP combat game**: No damage or kills between players; bumping is the limit — real PvP compromises **Rot Is Funny, Not Cruel**.
- **NOT story-through-cutscenes**: No cutscenes or text walls; the floors tell the story (**Weirder the Deeper**), and it keeps scope in weeks.
- **NOT built on existing memes**: No existing brainrot meme characters or clones of other games' creatures. Every creature is original — protects the game from takedowns and gives it its own identity.

---

## Visual Identity Anchor

*Decision logged (autonomous, AD-CONCEPT-VISUAL skipped — Lean mode):*
direction proposed below; revisit in `/art-bible`.

**Direction: "Cursed Toy Box"**

*Visual rule:* The creatures are glossy, saturated, toy-like and absurd; the
cave is dark and muted — so every creature pops like a prize.

Supporting principles:
1. **Silhouette first** — each creature is readable from its shape alone at Roblox camera distance. *Test: if two creatures look alike in silhouette, change one.*
2. **Deeper = stranger** — color and distortion intensify with depth (Floor 1 is almost normal; deep floors glitch and over-saturate). *Test: a screenshot should reveal roughly how deep it was taken.*
3. **Low-poly, mobile-safe** — simple stylized meshes and flat materials over detail, for Roblox mobile performance. *Test: if it needs a texture to read, simplify the shape.*

*Color philosophy:* Muted blue-grey cave, warm amber light near exits (safety),
and creature palettes in loud candy colors; rarity tiers get a consistent glow
color.

---

## Inspiration and References

| Reference | What We Take From It | What We Do Differently | Why It Matters |
| ---- | ---- | ---- | ---- |
| Pet Simulator 99 | Collect, rarity tiers, flex | Collection is earned by a risky dive, not eggs/clicks | Proves the collect-and-flex audience is huge on Roblox |
| Grow a Garden | Plot as a public showcase that earns passively | Plot fills from dives, not planting timers | Validates passive plot income + social showcase |
| R.E.P.O. / Lethal Company | Push-your-luck scavenging with friends, comedic failure | Kid-friendly, no death/horror; Sanity instead of monsters | Validates that greed + friends + failure = funny clips |

**Non-game inspirations**: Absurdist AI-meme internet humor; toy capsule
machines (the "what did I get?" moment); spelunking documentaries.

---

## Target Player Profile

| Attribute | Detail |
| ---- | ---- |
| **Age range** | ~9–16 (core Roblox simulator audience) |
| **Gaming experience** | Casual to mid-core |
| **Time availability** | 30–60 min after school; longer on weekends, often with friends |
| **Platform preference** | Roblox on mobile and PC |
| **Current games they play** | Pet Simulator 99, Grow a Garden, brainrot-themed simulators |
| **What they're looking for** | A simulator with real tension and funny moments, not just waiting on timers |
| **What would turn them away** | Losing too much on failure; pay-to-win; slow first 5 minutes |

---

## Technical Considerations

| Consideration | Assessment |
| ---- | ---- |
| **Recommended Engine** | Roblox Studio (Luau) — the user's choice. Note: this studio's engine tooling (`/setup-engine`, engine specialists, `/test-setup`, `/dev-story` run-and-observe) supports only Godot/Unity/Unreal; implementation work for Roblox happens outside that tooling. |
| **Key Technical Challenges** | Server-authoritative grab/carry/bump (anti-exploit); DataStore persistence of plots, coins and Index; floor generation or layout; mobile performance |
| **Art Style** | 3D stylized low-poly |
| **Art Pipeline Complexity** | Low–Medium (simple custom meshes; many creatures) |
| **Audio Needs** | Moderate — one signature sound per creature is part of the fun |
| **Networking** | Client-server (Roblox) |
| **Content Volume** | MVP: 3 floors, ~10 creatures. Full: 8–10 floors, 40+ creatures, the Bottom |
| **Procedural Systems** | Creature spawning per floor (weighted by rarity); floor layouts hand-built or lightly randomized — decide in prototype |

---

## Risks and Open Questions

### Design Risks
- Losing the haul could feel punishing to a young audience — mitigated by "keep the rarest"; must be playtested.
- The deeper/back-up decision may be too easy to solve (always surface at X% Sanity) if drain is predictable.

### Technical Risks
- Exploits: clients faking grabs or coins — all grab, carry, bank and bump logic must be server-side.
- DataStore loss or throttling corrupting player progress.
- Technical feasibility: NOT ASSESSED — TD-FEASIBILITY skipped (Lean mode), and the studio has no Roblox reference docs to source against.

### Market Risks
- Brainrot is a trend; the theme could cool before launch — the push-your-luck loop must stand on its own.
- Very crowded simulator market; discovery on Roblox depends on thumbnails, early retention and clip-ability.

### Scope Risks
- First game in weeks: three systems (dive, plot economy, social bump) is the ceiling. If time runs short, cut bumping first.
- Creature art volume — each creature needs a model and a sound.
- Scope realism: NOT ASSESSED — PR-SCOPE skipped (Lean mode).

### Open Questions
- Is the deeper/back-up decision fun for 30+ minutes? — answer with `/prototype` (a single-floor-chain greybox).
- Hand-built floors or randomized? — prototype both on one floor.
- What does the Sanity distortion look and feel like? — art-bible and prototype.

---

## MVP Definition

**Core hypothesis**: Players find the "go deeper or head back up" decision
exciting enough to repeat dives for a 30-minute session.

**Required for MVP**:
1. Dive through 3 floors with a Sanity Meter that drains faster per floor
2. Grab and carry ~10 original creatures across 3 rarity tiers, with limited carry slots
3. Forced surfacing at Sanity 0, keeping only the rarest held creature
4. Plot showcase that earns Rot Coins (online only)
5. Three upgrades: Sanity tank, carry slots, grab speed
6. Saved progress (DataStore)

**Explicitly NOT in MVP** (defer to later):
- Bumping other players
- Rot Index UI (track data only)
- Rebirth, daily weird floor, offline earnings
- The Bottom and its mystery
- Monetization

### Scope Tiers (if budget/time shrinks)

| Tier | Content | Features | Timeline |
| ---- | ---- | ---- | ---- |
| **MVP** | 3 floors, ~10 creatures | Dive, Sanity, grab/carry, plot income, 3 upgrades, saving | 3–4 weeks |
| **Vertical Slice** | 3 polished floors | MVP + Rot Index, bumping, juice/sound pass | +1–2 weeks |
| **Alpha** | 6 floors, ~25 creatures | + offline earnings, rebirth, first monetization | +2 weeks |
| **Full Vision** | 8–10 floors, 40+ creatures, the Bottom | + daily weird floor, polish, launch | +2–3 weeks (total ~8 weeks) |

---

## Next Steps

- [ ] Platform engine decision: Roblox Studio — see the tooling note in Technical Considerations
- [ ] **Prototype core idea** (`/prototype dive-and-sanity`) — validate the deeper/back-up decision is fun
- [ ] Visual identity (`/art-bible`)
- [ ] Validate concept (`/design-review design/gdd/game-concept.md`)
- [ ] If prototype PROCEEDS: decompose into systems (`/map-systems`)
- [ ] Design each system (`/design-system [system-name]`)
- [ ] Validate core loop with playtest (`/playtest-report`)
