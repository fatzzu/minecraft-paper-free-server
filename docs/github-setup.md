# GitHub setup

The GitHub connector can write files into an existing repository, but in this
session it did not expose repository creation. The connected GitHub account is:

```text
fatzzu
```

## Recommended repository

Create an empty public or private repository named:

```text
minecraft-paper-free-server
```

Repository full name:

```text
fatzzu/minecraft-paper-free-server
```

After the repository exists, these files can be uploaded through the GitHub web
interface or pushed with Git.

## Upload from GitHub web

1. Open GitHub and create a new repository.
2. Do not add README, license, or `.gitignore`; this folder already has them.
3. Click `Add file` -> `Upload files`.
4. Upload everything from this folder.
5. Commit to the `main` branch.

## Push with Git

From this folder:

```bash
git init -b main
git add .
git commit -m "Add Paper Minecraft server config"
git remote add origin https://github.com/fatzzu/minecraft-paper-free-server.git
git push -u origin main
```

GitHub may ask you to sign in. Do not paste passwords or tokens into this repo.
