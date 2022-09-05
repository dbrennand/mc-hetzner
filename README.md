# mc-hetzner

Deploy a Minecraft server on [Hetzner](https://www.hetzner.com/cloud) using [Terraform](https://www.terraform.io/) and [Ansible](https://www.ansible.com/).

## Prerequisites

* [Terraform](https://www.terraform.io/downloads)

* [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#installing-and-upgrading-ansible)

* [Hetzner Account](https://accounts.hetzner.com/signUp)

* [Hetzner API Token](https://docs.hetzner.com/cloud/api/getting-started/generating-api-token/)

## Playbook variables

```yaml
minecraft_image_tag: latest
```

The [itzg/minecraft-server](https://github.com/itzg/docker-minecraft-server) container image tag to use. See [itzg/minecraft-server/tags](https://hub.docker.com/r/itzg/minecraft-server/tags) for more available tags.

```yaml
# All container environment variables can be found at: https://github.com/itzg/docker-minecraft-server#server-configuration
minecraft_options:
  EULA: "TRUE"
  # https://github.com/itzg/docker-minecraft-server#versions
  VERSION: LATEST
  # https://github.com/itzg/docker-minecraft-server#downloadable-world
  WORLD: http://www.example.com/worlds/MySave.zip
  # https://github.com/itzg/docker-minecraft-server#server-configuration
  MOTD: A Minecraft Server created using https://github.com/dbrennand/mc-hetzner
  # ...
```

The environment variables passed to the [itzg/minecraft-server](https://github.com/itzg/docker-minecraft-server) container. These environment variables configure the Minecraft server.

```yaml
minecraft_backup: true
```

Whether or not to deploy the [itzg/mc-backup](https://github.com/itzg/docker-mc-backup) container image to backup the Minecraft server world.

```yaml
minecraft_backup_image_tag: latest
```

The [itzg/mc-backup](https://github.com/itzg/docker-mc-backup) container image tag to use. See [itzg/mc-backup/tags](https://hub.docker.com/r/itzg/mc-backup/tags) for more available tags.

```yaml
# All container environment variables can be found at: https://github.com/itzg/docker-mc-backup#common-variables
minecraft_backup_options:
  BACKUP_INTERVAL: 24h
  INITIAL_DELAY: 5m
  BACKUP_METHOD: restic
  RESTIC_REPOSITORY: b2:<bucket>
  # ...
```

The environment variables passed to the [itzg/mc-backup](https://github.com/itzg/docker-mc-backup) container. These environment variables configure backups for the Minecraft server world.

## Usage

1. Install the required Ansible roles:

    ```bash
    ansible-galaxy install -r requirements.yml
    ```

2. Create the `mc_hetzner` SSH key pair:

   ```bash
   ssh-keygen -f ~/.ssh/mc_hetzner -t rsa -b 4096 -N ""
   ```

3. Modify the Ansible playbook [vars](vars/main.yml#L24) file to configure the Minecraft server Docker container and backup container.

4. Initialise the [hcloud](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs) Terraform provider:

    ```bash
    terraform init
    ```

5. Deploy the server:

   ```bash
   terraform apply
   ```

> Later down the line, you may want to modify the Minecraft server container or backup container's environment variables.
> To re-run the creation of either without running the entire playbook, use the tags as below:
> ```bash
> ansible-playbook -u mc-hetzner -i "<Server IP>" --private-key ~/.ssh/mc_hetzner --tags "minecraft,backup" mc-hetzner.yml
> ```

## Authors & Contributors

* [**dbrennand**](https://github.com/dbrennand) - *Author*

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) for details.
