https://docs.anaconda.com/miniconda/#miniconda-latest-installer-links

```
sha256sum Miniconda3-latest-Linux-x86_64.sh
```

```
mkdir -p ~/miniconda3
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda3/miniconda.sh
bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3
rm ~/miniconda3/miniconda.sh
```