# APT

```bash
source -- /etc/os-release
tee -- /etc/apt/sources.list.d/ms-jpq.list <<-EOF
deb https://ms-jpq.github.io/deb-src/\$(ARCH) /
EOF
```
