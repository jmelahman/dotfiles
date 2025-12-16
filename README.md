# Dotfiles

## Initialize

```shell
git clone git@github.com:jmelahman/dotfiles.git "$HOME/.dotfiles"
```

And configure `status.showUntrackedFiles`,

```shell
dotfiles config --local status.showUntrackedFiles no
```

_`dotfiles` is an alias for `/usr/bin/git --git-dir="$HOME/.dotfiles/" --work-tree="$HOME"`._

If you have `GIT_LFS_SKIP_SMUDGE=1` enabled, you may need,

```shell
dotfiles lfs pull origin master
```

to restore the `deleted` files.

## Installing `dot-sync`

`dot-sync` can be enabled to automatically sync (push and pull) changes every 10 minutes.

```shell
systemctl enable --now --user dot-sync.timer
```
