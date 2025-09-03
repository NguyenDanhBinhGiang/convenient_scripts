# 🚀 Handy Scripts Collection

A collection of useful scripts for various tasks.

## 🛠️ Building Tools

This project uses a `Makefile` to build and package specific tools.

To build the `convenient-bash-tools` Debian package:

```bash
make build
```

#### Pre-requisites

`help2man` is used to generate man pages. If it's not installed, the Debian package will still build, just without man pages.

To install `help2man` on Debian/Ubuntu:

```bash
sudo apt-get install help2man
```

#### Included Tools
*   `docker_backup_volume`: Backs up a Docker volume. 💾
*   `docker_prune`: Cleans up Docker resources. ✨
*   `docker_restore_volume`: Restores a Docker volume. 🔄
*   `mkbash`: Quickly create a bash script with a shebang and executable permissions. 📝
*   `set_turbo`: Enables or disables turbo mode on Intel CPUs. ⚡
*   `turbo_status`: Checks the current turbo mode status on Intel CPUs. 📊
*   `to`: Navigate to a directory and list its contents. 📂
*   `venv_activate`: Quickly activate a Python virtual environment located in $HOME/python_venv/

### ☁️ Cloudflare DDNS Tools

First, edit the file [cloudflared_dynamic_dns_ipv6.py](cloudflared_dynamic_dns_ipv6.py), fill in your api key and domain names.

Once done, run 

```bash
make cloudflare-ddns
```

This copies `cloudflare_ipv6_ddns` and `cloudflared_dynamic_dns_ipv6.py` to `dist/bin/`.

## 📦 Installation

Install using the generated `.deb` package or download from releases:

```bash
sudo dpkg -i dist/your-package-name.deb
```

## 🧹 Cleaning Up

To remove all build artifacts:

```bash
make clean
```

## Contributing(??)

