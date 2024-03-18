# APT

```bash
curl --fail --location --no-progress-meter -- 'https://github.com/ms-jpq.gpg' | sudo -- sudo -- gpg --batch --dearmor --yes --output -- /etc/apt/trusted.gpg.d/ms-jpq.gpg
```

```bash
sudo -- tee -- /etc/apt/sources.list.d/ms-jpq.list <<-'EOF'
deb https://ms-jpq.github.io/deb/ /
EOF
```
