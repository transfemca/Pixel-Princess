
<h1 align="center">
  👑 Pixel Princess 👑
</h1>

<p align="center">
  <strong>A cute, high-performance system optimization toolkit for trans girls who game.</strong>
  <br>
  <em>"Slay the frame times, darling. You're the main character."</em>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Made%20by-transfem.ca-pink?style=for-the-badge" alt="Made by transfem.ca">
  <img src="https://img.shields.io/badge/Platform-Linux-informational?style=for-the-badge" alt="Platform">
  <img src="https://img.shields.io/badge/License-MIT-success?style=for-the-badge" alt="License">
</p>

---

### 💖 About The Project

**Pixel Princess** is a comprehensive Bash script designed to temporarily transform your Linux system into a high-performance gaming rig. It applies advanced kernel tweaks, GPU optimizations, and I/O tuning to minimize latency and maximize frames.

Unlike other optimization scripts, Pixel Princess is designed with **safety** and **reversibility** in mind. It automatically generates a "Detox" script to revert all changes when you're done playing, ensuring your system returns to its stable, daily-driver state.

---

### ✨ Features (The "Glow Up")

Pixel Princess applies a "Full Glamour Mask" to your system. Here is what happens under the hood:

*   **👑 CPU Optimization:** Sets governor to `performance` and disables energy-saving preferences (EPP) for maximum clock speeds.
*   **🧠 Memory Tuning:** Adjusts `vm.swappiness`, expands `vm.max_map_count`, and enables Transparent Huge Pages (THP) to fix micro-stutters.
*   **🚀 I/O Acceleration:** Switches SSDs/NVMe drives to low-latency schedulers (`mq-deadline` or `none`).
*   **📡 Network Latency:** Enables `BBR` congestion control and `fq_codel` to polish your ping.
*   **⚡ GPU Power:**
    *   **NVIDIA:** Unlocks power limits to the hardware maximum and enables persistence mode.
    *   **AMD:** Forces performance level to `high` (DPM).
*   **🖌️ Desktop Polish:** Automatically suspends the compositor on GNOME/KDE to reduce desktop overhead.
*   **🛑 Service Management:** Pauses background clutter (Tracker, PackageKit, CUPS) to free up CPU cycles.

---

### 🏗️ Installation

You can install Pixel Princess easily via the terminal.

**Option 1: One-Line Install (Recommended)**
```bash
curl -s https://raw.githubusercontent.com/transfemca/Pixel-Princess/main/Pixel_Princess.sh | bash
```

**Option 2: Manual Install**
```bash
# Clone the repository
git clone https://github.com/transfemca/Pixel-Princess.git

# Enter the directory
cd Pixel-Princess

# Make the script executable
chmod +x Pixel_Princess.sh

# Run the script
./Pixel_Princess.sh
```

---

### 🎮 Usage

Pixel Princess offers four unique routines:

1.  **FULL GLOW UP:** Applies all optimizations immediately. Best used before launching a game manually.
2.  **LAUNCH & SLAY:** The "Runway Mode." It applies optimizations, launches your game with environment variables (MangoHud, GameMode), and automatically reverts changes when you quit the game.
3.  **SLAY MODE:** Elevates a *currently running* process (game) to Real-Time CPU and I/O priority.
4.  **DETOX:** Washes off the performance glitter. Reverts all kernel and hardware tweaks to their previous states.

---

### ⚠️ Safety & Disclaimer

This script modifies low-level system parameters.
*   **Sudo Required:** It requires `sudo` access to apply kernel and hardware tweaks.
*   **Reversibility:** Always use the **Detox** option or the **Launch & Slay** mode to ensure settings are reverted after gaming.
*   **Hardware Safety:** The script sets safe limits defined by your hardware manufacturer (e.g., NVIDIA Max Power Limit). It does not overclock your hardware beyond factory limits.

---

### 🤝 Contributing

Contributions are welcome! Whether it's adding support for new GPUs, improving the aesthetics, or optimizing the logic:

1.  Fork the Project.
2.  Create your Feature Branch (`git checkout -b feature/AmazingFeature`).
3.  Commit your Changes (`git commit -m 'Add some AmazingFeature'`).
4.  Push to the Branch (`git push origin feature/AmazingFeature`).
5.  Open a Pull Request.

---

### 📜 License

Distributed under the Apache License. See `LICENSE` for more information.

<p align="center">
  Made with love by <a href="https://transfem.ca">transfem.ca</a>
</p>
```
