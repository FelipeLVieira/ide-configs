# Game Design & Sound Engineering References

Research compiled for the Aphos MMORPG project (2D isometric pixel art on Real Earth).

## Game Designers

### Hironobu Sakaguchi (Final Fantasy)
- Emotional storytelling as core pillar
- Active Time Battle (ATB) combat system
- Cinematic RPG experiences with ensemble casts

### Yuji Horii (Dragon Quest)
- Accessibility first -- RPGs for everyone
- Simple interfaces hiding deep systems
- Consistent world-building across decades

### Richard Garriott (Ultima Online)
- Player agency in persistent worlds
- Moral choice systems (Virtues in Ultima)
- Sandbox MMO pioneer -- emergent player behavior

### Raph Koster (Ultima Online, Star Wars Galaxies)
- Social systems and emergent gameplay
- Player-driven economies and crafting
- Theory of fun -- learning as core engagement loop

### Brad McQuaid (EverQuest)
- Hardcore group-based progression
- Dangerous worlds where death matters
- Community-forged through shared challenge

### Tetsuya Takahashi (Xenogears, Xenosaga, Xenoblade)
- Deep philosophical narratives (Gnostic, Nietzschean themes)
- Genre-blending (JRPG + mecha + action)
- Ambitious world-building across multi-game sagas

### Yasumi Matsuno (Final Fantasy Tactics, Vagrant Story)
- Tactical depth with job/class systems
- Political intrigue and mature storytelling
- Grid-based combat with deep positioning mechanics

### Rob Pardo (World of Warcraft)
- Accessible MMO systems that scale to millions
- Quest design that guides without railroading
- Endgame loops (raids, PvP, reputation, dailies)

### Koichi Ishii (Secret of Mana, Final Fantasy)
- Action RPG real-time combat pioneer
- Co-op multiplayer in single-player RPGs
- Ring menu system (elegant radial UI)

---

## Design Principles for Aphos

1. **Nostalgia with modern polish** -- Readable pixel art, QoL features, satisfying grind loops
2. **Social-core world building** -- Real Earth cities as hubs, grouping incentives, shared economy, guilds, PvP
3. **Balanced progression** -- Class/job switching (Ragnarok-style), card systems, horizontal progression paths
4. **Player agency and emergence** -- Meaningful build choices, player-driven economy, discovery rewards
5. **Combat clarity in pixel art** -- Punchy telegraphed attacks, isometric positioning matters
6. **Scalability and retention** -- Seasonal events, solo vs group balance, content cadence
7. **Fantasy grounded in real Earth** -- Mythical creatures appear in real-world locations

---

## Reference Books

- **A Theory of Fun for Game Design** -- Raph Koster
  - Fun = learning. When the brain stops finding patterns, boredom sets in.
- **Designing Virtual Worlds** -- Richard Bartle
  - Definitive text on MMO world design, player types (Achievers, Explorers, Socializers, Killers)
- **The Art of Game Design: A Book of Lenses** -- Jesse Schell
  - 100+ lenses to evaluate game design decisions from every angle
- **Rules of Play: Game Design Fundamentals** -- Katie Salen & Eric Zimmerman
  - Academic foundation for game design theory (rules, play, culture)

---

## GDC Talks

- Raph Koster -- "Online World Design" (foundational MMO design talk)
- WoW designers -- Quest and system design postmortems
- RPG postmortems -- Final Fantasy, Dragon Quest, EverQuest dev retrospectives
- Mark Rosewater (Magic: The Gathering) -- "20 Years, 20 Lessons" (applicable to game balance)

---

## Sound Engineers & Composers

### Nobuo Uematsu (Final Fantasy)
- Epic melodic themes with leitmotifs per character
- Orchestral + rock fusion (One-Winged Angel, Liberi Fatali)
- Emotional range from tender piano to full orchestra

### Yasunori Mitsuda (Chrono Trigger, Xenogears)
- Emotional depth with ethnic/acoustic fusion
- Celtic, jazz, and world music influences
- "Scars of Time" as a masterclass in opening themes

### Koichi Sugiyama (Dragon Quest)
- Classical orchestral grandeur
- Symphonic suite approach -- every track stands alone
- Fanfare-driven identity (iconic level-up jingle)

### Yoko Shimomura (Kingdom Hearts, Street Fighter II)
- Lush piano-driven emotional compositions
- Versatile: action tracks to heartfelt ballads
- "Dearly Beloved" as iconic menu music

### Hiroki Kikuta (Secret of Mana)
- Atmospheric, experimental, layered ambient
- Blended world music with SNES limitations
- Created unique sonic identity through constraint

### Motoi Sakuraba (Tales series, Star Ocean)
- Progressive rock energy in JRPG battle themes
- Keyboard-driven compositions
- High-energy combat music specialist

### Hitoshi Sakimoto (FF Tactics, Vagrant Story, FFXII)
- Orchestral complexity and density
- Dark, sophisticated harmonic language
- Military/political themes reflected in music

### SoundTeMP (Ragnarok Online)
- Korean composers creating charming town themes
- Memorable, loopable tracks for extended play sessions
- Light-hearted aesthetic matching sprite art

### Western MMORPG Composers
- Jeremy Soule (Guild Wars) -- Cinematic orchestral, environmental storytelling
- Russell Brower (World of Warcraft) -- Epic zone themes, adaptive combat music

---

## Audio Design Principles for Aphos

1. **Retro authenticity with modern depth** -- Chiptune/FM synths layered with hi-res samples, reverb, dynamic mixing
2. **Adaptive/dynamic music** -- Seamless transitions between battle/exploration states, layered stems that add/remove
3. **Clear punchy SFX** -- Exaggerated for pixel art readability (attacks, UI, footsteps)
4. **Spatial/immersive audio** -- 3D audio positioning for isometric view (distance attenuation, panning)
5. **Nostalgia balance** -- Sea of Stars approach: retro waveforms + polished modern mastering

---

## Audio Tools & Software

### Middleware (Runtime)
- **FMOD Studio** -- Industry standard adaptive audio middleware
- **Wwise** -- Alternative middleware, strong spatial audio

### DAWs (Composition)
- **Reaper** -- Lightweight, scriptable, affordable
- **Ableton Live** -- Great for layered/loop-based composition
- **FL Studio** -- Strong synth/chiptune workflow

### Chiptune / Retro
- **DefleMask** -- Multi-platform chiptune tracker
- **Furnace** -- Open-source multi-system tracker
- **OpenMPT** -- Classic module tracker
- **Magical 8bit Plug** -- VST for authentic 8-bit sounds
- **Plogue chipsounds** -- Premium chip emulation VST

### Prototyping
- **Bosca Ceoil** -- Quick melody prototyping (free, by Terry Cavanagh)
- **BeepBox** -- Browser-based chiptune sketching
