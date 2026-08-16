# Security notes

## Keep these settings

- `online-mode=true`
- `white-list=true`
- `enforce-whitelist=true`
- `enable-rcon=false`

These defaults reduce the chance of random players entering the server or
someone controlling the server remotely.

## Add players safely

On Oracle/Ubuntu:

```bash
sudo bash scripts/add-player.sh MinecraftName player
sudo bash scripts/add-player.sh YourName op
```

Only give `op` to people you fully trust.

## Do not commit secrets

Never put these in GitHub:

- private SSH keys
- GitHub tokens
- Oracle API keys
- card details
- RCON passwords
- personal passwords

## Firewall

Open only what you need:

- TCP `25565` for Minecraft
- TCP `22` for SSH, preferably only from your IP

## Updates

To update Paper later:

```bash
cd minecraft-paper-free-server
sudo bash scripts/download-paper.sh
sudo chown minecraft:minecraft /opt/minecraft/paper/server/paper.jar /opt/minecraft/paper/server/.paper-version
sudo systemctl restart minecraft-paper
```
