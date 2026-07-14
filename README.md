# Nixos Configurations

## Preview

![Preview Image](./resources/images/preview.png)

## Security

### Git Crypt

To keep some sensible files protected **git-crypt** is used to encrypt and decrypt the files. 

[git-crypt](https://github.com/AGWA/git-crypt) is used to transparently encrypt and decrypt files when pushed or when checked out.

```sh
# Export the private key
git-crypt export-key /path/to/key

# To unlock the encrypted files with the exported key
git-crypt unlock /path/to/key

# To encrypt the files again
git-crypt lock
```

## Maintenance

### Update Noctalia Plugins

Get the commit has from the latest commit on the [Plugins Repository](https://github.com/noctalia-dev/noctalia-plugins/commits/main) and replace it on the `fetchgit` function, then use `sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=` as the **sha256** and run the configuration, it will fail and give you the real `sha256`.

## Troubleshooting

### No audio on headsets

Open `pavucontrol` or `Bluetooth Manager` and change the audio profile. Currently is working with `High Fidelity Playback (A2DP Sink, codec AAC)`.

### Setup the monitors position

For setting up the monitors position, `wdisplays` is intalled, you can set the positions within the application and then copy the values shown in the application into the nix configuration.

### Git Credentials broken

If Nixos rebuilds `gh` then the configuration for git Credentials might get broken, since it might be still pointing to the old path of `gh`.
To fix it just run the command `gh auth setup-git`
