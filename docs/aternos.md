# Aternos alternative without card

Use Aternos if Oracle Cloud is not feasible or if you do not want to add a card.
Aternos is free and browser-based, but it is not the same as a Linux VM:

- It does not stay online forever like a self-managed VM.
- You start it from the Aternos panel.
- You cannot run the Linux install scripts from this repository.
- GitHub is still useful for keeping `server.properties`, plugin lists, notes,
  and backup copies of configs.

## Setup

1. Go to https://aternos.org
2. Create a free account and accept Aternos terms/privacy policy.
3. Create a Java Edition server.
4. Pick Paper if Aternos offers it for your target Minecraft version. If not,
   choose Spigot/Paper-compatible software available in the panel.
5. Accept the Minecraft EULA when Aternos asks.
6. Copy the important settings from `server/server.properties` into the Aternos
   options panel:
   - `online-mode=true`
   - whitelist enabled
   - max players around 10
   - view distance around 8
   - simulation distance around 6
7. Add your Minecraft username to the whitelist and operator list in Aternos.

## When to choose this

Choose Aternos if:

- You cannot or do not want to use a credit card.
- You only need the server when friends are playing.
- You want a simple web panel instead of Linux commands.

Choose Oracle if:

- You want more control.
- You want a server that can stay online.
- You are comfortable creating a free cloud VM.
