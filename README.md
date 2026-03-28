# Proxmox GitOps Infrastructure as Code
<div align="center">
    <!-- Your badges here -->
    <img src="https://img.shields.io/badge/packer-blue?style=for-the-badge&logo=packer&logoColor=white">
    <img src="https://img.shields.io/badge/cicd_github_actions-%23000.svg?style=for-the-badge&logo=github-actions&logoColor=white">
    <img src="https://img.shields.io/badge/terraform-%238511FA.svg?style=for-the-badge&logo=terraform&logoColor=white">
    <img src="https://img.shields.io/badge/proxmox-%23FF6F00.svg?style=for-the-badge&logo=proxmox&logoColor=white">
</div>
<br>

This repository provides a complete, automated Infrastructure-as-Code (IaC) pipeline for managing virtual machines in a Proxmox Virtual Environment (PVE). It leverages **Packer** to build golden OS templates, **GitHub Actions** for CI/CD automation over a secure **Tailscale VPN**, and **Terraform** modules to provision immutable infrastructure from those templates.

---

## 🚀 Features

* **Automated Golden Templates:** Build Ubuntu templates (22.04, 24.04, 25.10) dynamically via GitHub Actions using HashiCorp Packer.
* **Secure CI/CD Integration:** Uses Tailscale to securely connect GitHub Actions runners to your private Proxmox cluster without exposing Proxmox to the public internet.
* **Dynamic Cloud-Init:** Automatically injects hashed passwords, SSH keys, and optional pre-baked software (Docker, Nginx) into the templates during the Packer build phase.
* **Idempotency Protection:** Pre-flight checks in the pipeline prevent overwriting existing VMs or templates in Proxmox.
* **Reusable Terraform Modules:** Clean, modular Terraform setup using the modern `bpg/proxmox` provider to clone templates and assign network/cloud-init configurations.

---

## 📂 Repository Structure

```text
.
├── .github/
│   └── workflows/
│       └── build-vm-template.yaml  # GitHub Actions pipeline for Packer builds
├── packer/
│   ├── configs/
│   │   └── os_map.json             # Maps Ubuntu versions to ISO URLs & checksums
│   ├── http/
│   │   └── user-data.template      # Base Cloud-Init autoinstall configuration
│   ├── scripts/
│   │   ├── docker.sh               # Provisioning script for Docker
│   │   └── nginx.sh                # Provisioning script for Nginx
│   ├── dynamic.auto.pkrvars.hcl    # (Generated dynamically during pipeline)
│   ├── ubuntu.pkr.hcl              # Main Packer build configuration
│   └── variables.pkr.hcl           # Packer variables definition
└── terraform/
    └── modules/
        └── proxmox_vm/             # Reusable Terraform module for provisioning VMs
            ├── main.tf             # Core VM resource definition
            ├── outputs.tf          # Exports IP address and VM name
            ├── variables.tf        # Input variables (CPU, RAM, Disk, Cloud-Init)
            └── versions.tf         # Requires bpg/proxmox >= 0.69.1
```

---

## 🛠️ Prerequisites & Setup

### GitHub Secrets Required
To use the automated Packer build pipeline, you must configure the following **Repository Secrets** in GitHub:

| Secret Name | Description |
| :--- | :--- |
| `TS_OAUTH_CLIENT_ID` | Tailscale OAuth Client ID (to connect runner to your VPN). |
| `TS_OAUTH_SECRET` | Tailscale OAuth Secret. |
| `PROXMOX_API_URL` | Your Tailnet Proxmox API Endpoint (e.g., `https://pve.tail1a8407.ts.net:8006/api2/json`). |
| `PROXMOX_TOKEN_ID` | Proxmox API Token ID (e.g., `root@pam!github-actions`). |
| `PROXMOX_TOKEN_SECRET` | Proxmox API Token Secret/UUID. |
| `SSH_PRIVATE_KEY_B64` | Base64 encoded private SSH key (used by Packer to connect during build). |
| `SSH_PUBLIC_KEY_B64` | Base64 encoded public SSH key (injected into the `ubuntu` user). |

---

## 🏗️ Phase 1.A: Building Templates (Packer + GitHub Actions)

VM Templates are built on-demand via the GitHub Actions UI. 

1. Go to the **Actions** tab in your GitHub repository.
2. Select **Build Golden Image (VM Template) with Packer**.
3. Click **Run workflow** and configure the inputs:
   * **OS Version:** Ubuntu 22.04, 24.04, or 25.10.
   * **ISO Source:** Choose `local` (if already on your Proxmox datastore) or `url` (to download directly from Ubuntu).
   * **VM ID & Name:** Target ID (e.g., `900`) and Name (e.g., `ubuntu-2404-template`) for the resulting Proxmox template.
   * **Hardware:** Specify base CPU, RAM, and Disk size.
   * **Provisioning:** Optionally toggle **Install Docker** and/or **Install Nginx**.
   * **Cloud-Init Password:** Define the default password for the `ubuntu` user.

The pipeline will connect via Tailscale, validate that the VM ID/Name doesn't already exist, dynamically construct the `user-data` file, and trigger the Packer build.

---

## ☁️ Phase 1.B: Building Templates (Cloud-Images + GitHub Actions)

If you prefer building lightweight templates using official KVM Cloud-Images instead of Packer ISOs, you can use the **Build VM Template with Cloud-Images** workflow:

1. Go to the **Actions** tab in your GitHub repository.
2. Select **Build VM Template with Cloud-Images**.
3. Click **Run workflow** and configure the inputs:
   * **OS Version:** Ubuntu 22.04, 24.04, 25.10, or Debian 12 (Dropdown options fetched from `cloud-images/images.json`).
   * **VM ID & Name:** Target ID (e.g., `910`) and Name (e.g., `ubuntu-cloud-template`).
   * **Hardware:** CPU cores, RAM, Disk Size.
   * **Cloud-Init Credentials:** Specify target cloud-init username (e.g., `ubuntu`) and password.

> **Note on Access & Idempotency:**  
> The workflow will connect to Tailscale, check via Proxmox API if the VM template already exists, and SSH into your Proxmox Node as `root` (using the same `SSH_PRIVATE_KEY_B64` secret in GitHub). Therefore, ensure the **public key** of your secret is added to the Proxmox Node's `~/.ssh/authorized_keys`.  
> *It will install `libguestfs-tools` automatically on your Proxmox Host if not present, and cache the downloaded image to `/var/lib/vz/template/cloud-images/<filename>` persistently across job runs.*

---

## 🚀 Phase 2: Provisioning Infrastructure (Terraform)

Once your golden templates exist in Proxmox, you can rapidly deploy instances from **any other repository** by referencing this repository's Terraform module remotely. This ensures all your infrastructure adheres to the same standardized configurations.

### Example Usage (Remote Module)

In your target environment repository (e.g., `my-app`), create a `main.tf` file and reference the remote Git module:

```hcl
module "web_server" {
  # Remote module source using double slash (//) to point to the sub-directory
  # You can also pin to a specific branch or tag by adding ?ref=main or ?ref=v1.0.0
  source = "git::[https://github.com/omidiyanto/proxmox-gitops-infrastructure-as-code.git//terraform/modules/proxmox_vm](https://github.com/omidiyanto/proxmox-gitops-infrastructure-as-code.git//terraform/modules/proxmox_vm)"

  node_name   = "pve"
  vm_name     = "prod-web-01"
  clone_vm_id = 900                 # ID of the template built by Packer

  # Hardware
  cpu_cores = 4
  memory_mb = 4096
  disk_size = 30
  
  # Network & Cloud-Init
  network_bridge  = "vmbr0"
  ip_address      = "192.168.1.50/24"
  gateway         = "192.168.1.1"
  ci_user         = "ubuntu"
  ssh_public_keys = ["ssh-ed25519 AAAAC3... user@machine"]
}

output "web_server_ip" {
  value = module.web_server.vm_ipv4_address
}

### Applying the Configuration

```bash
cd terraform/
terraform init
terraform plan
terraform apply
```

---

## 🤝 How to Contribute

Contributions are always welcome! We appreciate any help to improve this Infrastructure-as-Code repository.

**Some simple ways to contribute:**
- **Add Cloud Images List**: Even simple contributions like adding a new OS mapping to the `cloud-images/images.json` file (and updating the dropdown option in GitHub Actions) are highly appreciated and will be warmly welcomed!
- **Improve Terraform Modules**: Add support for other Proxmox resources.
- **Bug Fixes**: Fix issues in automation scripts or GitHub Actions workflows.
- **Documentation**: Enhance the clarity of `README.md` or provide new usage examples.

Feel free to open an *Issue* or submit a *Pull Request* (PR)!