# Minecraft Paper Free Server

Repository pregatit pentru un server Minecraft Java Edition cu Paper.

Tinta recomandata: GitHub + Oracle Cloud Always Free. Alternativa fara card:
Aternos + GitHub pentru pastrarea configuratiilor.

Verificat pe 2026-08-16:

- Paper foloseste serviciul oficial de download `fill.papermc.io` si cere
  un `User-Agent` clar pentru descarcari automate.
- Paper 26.1+ cere Java 25.
- Oracle Cloud Always Free listeaza Ampere A1 ca resursa gratuita, pana la
  2 OCPU si 12 GB RAM pentru conturile Always Free, dar la inscriere poate
  cere telefon si card.
- Aternos este gratuit si nu are optiune de plata, dar nu este server Linux
  24/7 si nu poate rula direct scripturile din acest repository.

## Ce contine

- `server/server.properties` - setari Minecraft sigure pentru inceput.
- `server/eula.txt` - ramane `false`; tu trebuie sa accepti EULA.
- `scripts/install-oracle-ubuntu.sh` - instaleaza Paper pe Ubuntu in Oracle.
- `scripts/download-paper.sh` - descarca ultimul build stabil Paper.
- `scripts/add-player.sh` - adauga un username Minecraft in whitelist si,
  optional, in ops.
- `scripts/accept-eula.sh` - seteaza EULA pe `true` doar dupa confirmarea ta.
- `scripts/backup.sh` - creeaza backup-uri locale.
- `systemd/minecraft-paper.service` - ruleaza serverul ca serviciu Linux.
- `docs/` - pasi pentru GitHub, Oracle Cloud, Aternos si securitate.

## Start rapid pe Oracle Cloud

1. Creeaza un repository GitHub gol, de exemplu
   `fatzzu/minecraft-paper-free-server`.
2. Urca fisierele din acest folder in repository.
3. Creeaza in Oracle Cloud o instanta Always Free:
   - Image: Ubuntu
   - Shape: `VM.Standard.A1.Flex`
   - Recomandat: 2 OCPU, 12 GB RAM daca exista capacitate
   - Deschide portul TCP `25565` in VCN / Security List / NSG
4. Conecteaza-te prin SSH si ruleaza:

```bash
sudo apt-get update
sudo apt-get install -y git
git clone https://github.com/fatzzu/minecraft-paper-free-server.git
cd minecraft-paper-free-server
sudo bash scripts/install-oracle-ubuntu.sh
sudo bash scripts/add-player.sh NumeleTauMinecraft op
sudo bash scripts/accept-eula.sh
```

5. In Minecraft Java Edition, intra pe IP-ul public al instantei Oracle.

## Comenzi utile

```bash
sudo systemctl status minecraft-paper --no-pager
sudo systemctl restart minecraft-paper
sudo journalctl -u minecraft-paper -f
sudo bash scripts/backup.sh
```

## Ce trebuie facut manual de tine

- GitHub: autentificare si crearea repository-ului gol, daca nu exista deja.
- Oracle Cloud: inscriere, alegerea regiunii, creare VM, acceptare termeni,
  telefon si card daca Oracle le cere.
- Minecraft: citirea si acceptarea EULA. Scriptul nu accepta EULA fara ca tu
  sa tastezi `ACCEPT`.
- Date sensibile: nu pune niciodata chei SSH private, parole, tokenuri GitHub,
  parole RCON sau date de card in repository.

## Surse oficiale utile

- Paper downloads service: https://docs.papermc.io/misc/downloads-service/
- Paper getting started: https://docs.papermc.io/paper/getting-started/
- Oracle Always Free: https://docs.oracle.com/en-us/iaas/Content/FreeTier/freetier_topic-Always_Free_Resources.htm
- Oracle Free Tier: https://docs.oracle.com/en-us/iaas/Content/FreeTier/freetier.htm
- Aternos free server guide: https://support.aternos.org/hc/en-us/articles/12165605063325-Creating-a-free-Minecraft-server-with-Aternos
- Minecraft server download / EULA notice: https://www.minecraft.net/en-us/download/server
