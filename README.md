# Dotfiles

## Initialize

```shell
cd $HOME
git init
git remote add origin git@github.com:jmelahman/dotfiles.git
git fetch origin master
git reset origin/master
```

If you have `GIT_LFS_SKIP_SMUDGE=1` enabled, you may need,

```shell
git restore .
```

to restore the `deleted` files.

## Installing `dot-sync`

`dot-sync` can be enabled to automatically sync (push and pull) changes every 10 minutes.

```shell
systemctl enable --now --user dot-sync.timer
```

## Tracking New Files

For privacy, tracking files in the repo are opt-in.

To opt-in, update `.gitignore` with an exception for that file.
