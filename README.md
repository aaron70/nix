# Nixos Configurations

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

