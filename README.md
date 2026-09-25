# Más Mus

> *Four players, two teams, forty cards, and one órdago away from glory.*

[![Build Status](https://img.shields.io/github/actions/workflow/status/clarriu97/masmus/flutter.yml?branch=master&style=flat-square&logo=githubactions&logoColor=white)](https://github.com/clarriu97/masmus/actions/workflows/flutter.yml)
[![Flutter](https://img.shields.io/badge/flutter-3.47-02569B?style=flat-square&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/dart-3.13-0175C2?style=flat-square&logo=dart&logoColor=white)](https://dart.dev)
[![Platform](https://img.shields.io/badge/platform-android%20|%20ios-blue?style=flat-square)]()

---

## What is this?

A Flutter app to play **Mus**, the Spanish card game, on the phone: you and a bot partner against two bot rivals. Offline, no accounts, nothing leaves the device.

**Status: prototype, being rebuilt.** The current app deals, bets and scores, but its rules engine has known bugs and the table is hard to follow. The plan to turn it into a first real version is in [docs/ROADMAP.md](docs/ROADMAP.md) and tracked as [issues and milestones](https://github.com/clarriu97/masmus/milestones).

## Getting Started

```bash
git clone https://github.com/clarriu97/masmus.git
cd masmus
flutter pub get
flutter run            # pick a simulator, emulator or device
```

## Testing

```bash
tool/ci.sh             # format, analyze, unit and widget tests: what every PR runs (~1 min)
tool/ci.sh all         # + release builds for Android and iOS
```

Run the checks automatically before every push (once per clone):

```bash
git config core.hooksPath tool/git-hooks
```

Pull requests run `analyze` and `test` on GitHub and `master` only accepts green ones. Release builds run after every merge. The test strategy (rules tested against a written spec, scripted hands on a stacked deck, thousands of simulated matches checked for invariants, and later layout matrix, goldens and end-to-end flows) is in [AGENTS.md](AGENTS.md#testing-paranoid-mindset).

## Working on it

Built with coding agents in mind: [AGENTS.md](AGENTS.md) holds the architecture, the rules for code, UI and tests, and the workflow; [docs/ROADMAP.md](docs/ROADMAP.md) holds the state of the project and its decisions. Both load into every Claude Code session through `CLAUDE.md`, and the `continue` skill picks up the next issue.

## Built With

| Tool | Purpose |
|---|---|
| [Flutter](https://flutter.dev) | UI framework |
| [Dart](https://dart.dev) | Language |
| [flutter_lints](https://pub.dev/packages/flutter_lints) | Strict lint rules |
| [GitHub Actions](https://github.com/features/actions) | CI |

---

<p align="center">
  <i>¿Hay mus?</i><br>
  <img src="https://img.shields.io/badge/built%20with-anger%20and%20coffee-brown?style=flat-square" alt="Built with anger and coffee">
</p>
