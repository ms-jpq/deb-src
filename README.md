# APT

```bash
curl --disable --fail --location --no-progress-meter -- 'https://ms-jpq.github.io/deb/key.asc' | command -- sudo -- gpg --batch --dearmor --yes --output /etc/apt/trusted.gpg.d/ms-jpq.gpg
```

```bash
command -- sudo -- tee -- /etc/apt/sources.list.d/ms-jpq.list <<-'EOF'
deb https://ms-jpq.github.io/deb/ /
EOF
```
