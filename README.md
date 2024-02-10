# DUPLICATI/DUPLICATI PROD IMAGE

### Prerequisite


```bash
./hello_world.sh
```

### Windows

```bash
./provide_container.sh
```

### More

```
sudo docker run -d --net=host -v ~/duplicati:/duplicati -v ~/backup:/backup --restart=unless-stopped duplicati:2
```
```
duplicati-cli repair TARGET-URL --passphrase="PASSPHRASE"
```
```
duplicati-cli list-broken-files TARGET-URL --full-result --dbpath=PATH --passphrase="PASSPHRASE"
```
```
duplicati-cli purge-broken-files TARGET-URL --full-result --dbpath=PATH --passphrase="PASSPHRASE"
```



See the official
[duplicati](https://duplicati.readthedocs.io/en/latest/)
documentation.
See also the official
[installation manual](https://duplicati.readthedocs.io/en/latest/02-installation/).
