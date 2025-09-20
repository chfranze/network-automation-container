# Network Automation Container

## Build the Docker Image

```bash
docker build -t network-automation-container .
```

This command will build the Docker image with Python, Ansible, Terraform, and all required networking tools pre-installed.

---

## Run the Container

### Interactive Mode with Workspace Mount

```bash
docker run -it --rm -v $(pwd):/workspace network-automation-container
```

* Mounts the current directory into the container at `/workspace`.
* Removes the container automatically after you exit.

### Interactive Mode Without Mount

```bash
docker run -it network-automation-container
```

* Starts the container in interactive mode without mounting any local directories.