# Product: who plays Más Mus and what v1 must do

First version, 2026-09-25, from desk research: store listings and about a
hundred reviews of the Mus apps on the App Store and Google Play, and the
rulebooks of ASESMUS, Madrid, Barcelona, Bizkaia and Navarra. Review counts
are approximate (the stores show a sample). To be checked against real
players in #31 (table playtest) and #43 (closed beta).

## The market

- Almost every Mus app is online-only: Mus Online Maestro (iOS 4.5 with 17K
  ratings), UsuMus (subscription), Puzztime, Las40, TFD, TxL… The online ones
  have no bots.
- The only big offline app with bots is **El Mus / Mus Don Naipe** (Google
  Play 4.2 with 12.5K ratings, 500K+ downloads; iOS 4.4 with 2.9K): seven bot
  personalities that make and read señas, consulting your partner, 30 or 40
  points, speed, statistics and a tutorial; 8 reyes only; ads, 1.99 € to
  remove them. Its online mode shut down in 2020.
- No app explains why a hand was won or lost.
- Most listings are PEGI 18 for "simulated gambling" (coins and bets); Don
  Naipe, without them, is PEGI 12.

## What players complain about

| # | Need | Evidence | What it means for us |
|---|---|---|---|
| 1 | Ads that don't get in the way | ~19 reviews; 6 of the 10 visible on Maestro's iOS page; Don Naipe's ads cut the user's music | No ads mid-hand or with sound; the model is decided in #45 |
| 2 | A deal they can believe | ~14, including Don Naipe, which is offline | Fair shuffle, every hand shown after each hand, "ver el reparto" (#27), bots never see hidden cards |
| 3 | Bots and a partner that play well | ~12 (7 complaints, 5 praising realism): señas that don't match the hand, a partner who blunders, predictable bots; they ask to consult the partner | M4: decisions tested and benchmarked, señas coherent with the hand, consulting the partner, personalities |
| 4 | Stable, friendly online play | ~11 disconnections, ~10 toxicity, ~5 bots posing as humans | Out of scope: v1 is offline |
| 5 | Playing with friends | ~10 | After v1 (#46); the pure, serializable engine keeps the door open |
| 6 | A readable table and a good pace | ~9: small cards and text, slow, no way out, bets not visible | M3 and AGENTS.md → UI / UX rules; pace control; exit and resume (#29) |
| 7 | Correct counting | ~8, 6 of them on one app | M1 (rules spec + tests) and the itemized count (#27) |
| 8 | Learning | ~3, weak | Hints about your hand, rules and glossary in the app (#24, #30) |
| 9 | Rule variants | ~1, plus Don Naipe saying since 2015 that 4 reyes is requested | 4 reyes and 30 points as options |

## Rules players expect

- **By default**: 8 reyes, 40 points, first hand with *mus corrido* and no
  señas, no 31 real, no extra *deje*, órdago always allowed, the usual count
  (a "no quiero" is worth 1 or the last accepted stake; pares 1/2/3; juego 3
  for 31, else 2; punto 1). This is what the rulebooks say and what Don Naipe
  calls the most widespread version.
- **Regional**: 4 reyes (Gipuzkoa, Navarra, La Rioja), 30 points, 31 real
  (valid in Barcelona, not in ASESMUS, Madrid, Navarra, Aragón or Galicia),
  the extra *deje* (Madrid), vacas of several games.
- **Señas** are part of the rulebooks, with an official list; false señas
  are not allowed.

The spec the engine implements is `docs/RULES.md` (#11).

## Players

- **Veteran.** Has played Mus in bars for years and knows the rules and the
  señas; plays on the phone when there is no table. Wants correct rules, bots
  that play like people and a quick pace. Leaves over a wrong count or a
  clumsy partner.
- **Returning player.** Played years ago and is rusty on the señas and the
  counting. The itemized count and the hints get them back in.
- **Learner.** Friends play and they want to join. Needs the vocabulary
  explained, to see why a lance was won or lost, and help reading their own
  hand.

## Principles

- **A count the player can check.** Rules come first; every hand ends with
  every card on the table and the points explained.
- **Nothing hidden, nothing faked.** A fair deal, bots that know only what a
  player would, no fake features.
- **The table reads at a glance**, on a phone, with one hand.
- **Respect the player's time**: pace control, exit and resume anywhere, no
  interruptions mid-hand.
- Every addition must pass "would a real Mus player need this?".

## v1 scope

**In**
- One human and three bots, offline, no account, no data leaving the device,
  Spanish.
- The rules of `docs/RULES.md` with its defaults; 4 reyes and 30 points as
  options.
- The redesigned match (M3): start, table, bets, discards, declarations, the
  itemized count with every hand shown, end of match and rematch, exit and
  resume, settings (defaults, pace, hints), how to play, the fair-deal note.
- Bots (M4): sensible mus, discards and bets; a partner who plays with you;
  señas between partners; consulting the partner; four personalities.
- Quality (M5): accessibility, motion and sound that can be turned off,
  release configuration, end-to-end tests on simulators and emulators.

**Out** (backlog in #46): online and friends, catching señas, vacas, 31 real
and other regional variants, statistics, an interactive tutorial, difficulty
levels, other languages, alternative tables and decks.

## v1 is done when

- A full match to 40 against three bots follows `docs/RULES.md`: every rule
  has a passing test, and thousands of simulated matches keep the invariants.
- A player who knows Mus plays a whole match without asking how, and can
  check every count.
- The bots beat the baseline bots clearly in the arena (#32), and the
  partner's señas always match its hand.
- The match survives the app being killed, at any point.
- At least five Mus players have played it (#31, #43) with no blocking issue
  left open.
- Store listings, signed builds and the end-to-end gate are green.

## Open questions for the owner

1. **Señas in v1** (#35, #36). The research ranks them as essential and they
   are where the main offline rival is criticized. Alternative: ship v1
   without them and add them right after. Recommended: in v1.
2. **Business model** (#45): free without ads, one-time purchase, or free with
   a one-time purchase to remove ads (never mid-hand).
3. **Languages**: Spanish only at launch, with Basque, Catalan, Galician and
   English later? Don Naipe's listing exists in Catalan, Basque and English.
4. **License**: the README used to claim MIT, but there is no `LICENSE` file
   and the repo is public.

## Sources

- Don Naipe: [App Store ES](https://apps.apple.com/es/app/mus-don-naipe/id954161061?see-all=reviews), [Google Play](https://play.google.com/store/apps/details?id=donnaipe.mus&hl=es&gl=ES), [blog 2015](http://donnaipe.com/blog/2015/01/31/novedades-en-el-mus/)
- Mus Online Maestro: [App Store](https://apps.apple.com/es/app/mus-online-maestro-juego-mus/id1566790783?see-all=reviews), [Google Play](https://play.google.com/store/apps/details?id=com.kangaroo.musmaestro&hl=es&gl=ES)
- UsuMus: [App Store](https://apps.apple.com/es/app/usumus-juego-de-mus-online/id523500272?see-all=reviews)
- Puzztime Mus Online: [App Store](https://apps.apple.com/es/app/mus-online/id6747138761?see-all=reviews)
- Others: [TFD](https://play.google.com/store/apps/details?id=com.tfdevelopment.musonline&hl=es&gl=ES), [Las40](https://play.google.com/store/apps/details?id=es.las40.mus&hl=es&gl=ES), [TxL](https://play.google.com/store/apps/details?id=com.txl.mus&hl=es&gl=ES), [MusMus](https://apps.apple.com/es/app/musmus-jugar-al-mus-online/id6761478100), [Ludoteka](https://www.ludoteka.com/games/mus)
- Rules: [ASESMUS](https://www.asesmus.com/wp-content/uploads/2018/08/Reglamento_asesmus_v1.01.pdf), [Barcelona Mus Club](https://barcelonamus.com/club/reglamento), [Asociación Navarra de Mus](https://musnavarra.com/reglamento/reglamento-de-juego/), [Bizkaia](https://www.asesmus.com/wp-content/uploads/2022/06/RegMusBIZKAIA.pdf), [pagat.com](https://www.pagat.com/vying/mus.html), [Wikipedia](https://es.wikipedia.org/wiki/Mus)
