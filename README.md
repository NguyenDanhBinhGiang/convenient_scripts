# Handy Scripts Collection

A collection of useful scripts for various tasks.

## 📋Included Tools

* `docker_backup_volume`: Backs up a Docker volume.
* `docker_prune`: Cleans up Docker resources.
* `docker_restore_volume`: Restores a Docker volume.
* `mkbash`: Quickly create a bash script with a shebang and executable permissions.
* `set_turbo`: Enables or disables turbo mode on Intel CPUs.
* `turbo_status`: Checks the current turbo mode status on Intel CPUs.
* `to`: Navigate to a directory and list its contents.
* `venv_activate`: Quickly activate a Python virtual environment located in `$HOME/python_venv/`.

## 🛠️ How to build.

### 📦 Bash convenience tools

1. Build the `convenient-bash-tools` Debian package:
    ```bash
    make build
    ```
2. The debian package will be created in the `dist/` directory. Install using `dpkg` or `apt`:
    ```bash
    sudo dpkg -i dist/your-package-name.deb
    ```
3. Cleaning Up
   To remove all build artifacts:
    ```bash
    make clean
    ```

### ☁️ Cloudflare DDNS Tools

First, edit the file [cloudflared_dynamic_dns_ipv6.py](cloudflared_dynamic_dns_ipv6.py), fill in your api key and domain
names.

Once done, run

```bash
make cloudflare-ddns
```

### 🧹 Cleaning Up

To remove all build artifacts:

```bash
make clean
```

### 🗑️ Uninstall

To uninstall both bash tools and cloudflare ddns tool, run:

```bash
sudo make uninstall
```

## Contributing(??)

You have.

## License
[GLPL](LICENSE)(Gas Lighting Public License)
