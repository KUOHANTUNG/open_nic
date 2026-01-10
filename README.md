# open_nic

Exploring FPGA-based SmartNIC designs for Network Acceleration in the Datacenter  
**Master Thesis Project**

`open_nic` is an FPGA-based SmartNIC research platform targeting Xilinx Alveo AU45N. The repository includes RTL/HLS components and Vivado build scripts to generate a SmartNIC design with configurable networking/PCIe parameters.

---

## Contents

- [Requirements](#requirements)
- [Repository Layout](#repository-layout)
- [Quick Start](#quick-start)
- [Build Details](#build-details)
  - [1) Generate HLS IP Cores](#1-generate-hls-ip-cores)
  - [2) Add IP to the Vivado Repository](#2-add-ip-to-the-vivado-repository)
  - [3) Build the Bitstream](#3-build-the-bitstream)
  - [4) Replace Plugin Sources](#4-replace-plugin-sources)
- [Configuration Parameters](#configuration-parameters)
- [Notes / Troubleshooting](#notes--troubleshooting)

---

## Requirements

### Hardware
- Xilinx Alveo **AU45N**

### Tools
- **Vivado 2022.2** (required)
- **Vitis HLS 2022.2** (required if regenerating HLS IP cores)

> Using other Vivado/Vitis versions may cause IP incompatibilities and build failures.

---

## Repository Layout

```text
open_nic/
├─ project/                 # Entry point for building the design
│  ├─ board_files/
│  ├─ constr/
│  ├─ plugin/               # rewrite official p2p
│  ├─ plugin_src/           # plugin main source
│  ├─ ip/                   # all IP designs (includes Xilinx ones)
│  ├─ ip_hls/               # HLS source files
│  ├─ sim/                  # simulation files
│  ├─ source/               # RTL/source files
│  ├─ script/
│  ├─ software/
│  │  ├─ DPDK_app/
│  │  └─ test_files/
│  ├─ src/
│  └─ config.txt            # all register config commands


---

## Quick Start

1. Generate HLS IP cores (if needed) and export them.
2. Add the exported IP cores to the Vivado IP repository.
3. Build the design using `build.tcl`.
4. Replace the generated plugin sources with the customized ones from `plugin_src/`.
5. Re-run the build step if your flow requires re-synthesis after plugin replacement.

---

## Build Details

### 1) Generate HLS IP Cores

If your design depends on HLS modules, generate the corresponding Vivado IP cores:

1. Launch **Vitis HLS 2022.2**
2. Create/open the HLS project using sources under `hls/`
3. Run C synthesis
4. **Export RTL / Export IP** (Vivado IP)

This produces IP directories that can be added to Vivado as an IP repository.

---

### 2) Add IP to the Vivado Repository

In Vivado 2022.2:

- **Tools → Settings → IP → Repository → Add Repository**
- Add the directory (or directories) containing the exported HLS IP cores.
- Click **Rescan** if needed.

> If you modify HLS IP, re-export and rescan the repository before rebuilding.

---

### 3) Build the Bitstream

Run the build from the `project/` directory:

```bash
cd project

vivado -mode tcl -source build.tcl -tclargs \
  -board au45n \
  -tag nic_udp_ram_2025_1 \
  -jobs 32 \
  -max_pkt_len 4096 \
  -num_phys_func 2 \
  -num_cmac_port 2 \
  -num_qdma 1
This command generates and builds the Vivado project using the specified configuration.

### 4) Replace Plugin Sources

After build.tcl generates the project/build output, you must overwrite the generated plugin sources with the customized versions:

Locate the generated source files created by the build flow.

Replace the corresponding generated files with the versions in:

plugin_src/

This step is required to integrate custom plugin logic into the design.

Important: this replacement may need to be repeated after a clean rebuild, since generated files can be recreated by build.tcl.

Notes / Troubleshooting

Vivado/Vitis version: use 2022.2 to avoid IP/version mismatches.

IP repository not found: ensure HLS IP is exported and the repository path is added in Vivado settings.

Plugin replacement: if you re-run a clean build, generated sources may be recreated; re-apply the plugin_src/ overwrite step.

Rebuild after plugin replace: depending on how build.tcl organizes synthesis runs, you may need to rerun synthesis/implementation after overwriting plugin sources.

### 5) License / Disclaimer

This project is provided for research and academic use. Validate and review thoroughly before using in production environments.

The network module design references the [FPGA Network Stack project](https://github.com/fpgasystems/fpga-network-stack).
