#!/bin/bash

# --- PIXEL PRINCESS: SYSTEM GLAMOUR PROTOCOL ---
# Version: 3.1.0 | Logic: Absolute Gaming Orchestration
# Purpose: A cute, high-performance toolkit for trans girls who game.
# "Slay the frame times, darling. You're the main character."

STATE_FILE="/var/tmp/pixel_princess_state.sh"

# --- Aesthetics (Pastel Power) ---
PINK='\033[1;35m'
BLUE='\033[0;34m'
TRANS_BLUE='\033[1;34m'
WHITE='\033[1;37m'
BOLD='\033[1m'
NC='\033[0m'
GLITTER='\033[105m  \033[104m  \033[107m  \033[104m  \033[105m  \033[0m'

princess_say() { echo -e "${PINK}${BOLD}👑 PIXEL PRINCESS:${NC} ${TRANS_BLUE}$1${NC}"; }

# --- 0. SAFETY CHECK ---
check_state() {
    if [ -f "$STATE_FILE" ]; then
        princess_say "Warning: Previous session detected!"
        echo -e "The system is already glammed up. Did you forget to detox?"
        read -p "Force Detox now? (y/n): " detox_choice
        if [[ "$detox_choice" == "y" ]]; then
            apply_detox
        else
            princess_say "Proceeding with caution. Existing tweaks may be overwritten."
        fi
    fi
}

# --- 1. PROVISIONING & SPECS ---
get_specs() {
    [ -f /etc/os-release ] && source /etc/os-release || PRETTY_NAME="Unknown Platform"
    CPU=$(grep "model name" /proc/cpuinfo | head -n1 | cut -d':' -f2 | xargs)
    GPU=$(lspci | grep -Ei "vga|3d" | cut -d':' -f3 | xargs)
    [[ "$GPU" =~ "NVIDIA" ]] && IS_NVIDIA=true || IS_NVIDIA=false
    [[ "$GPU" =~ "AMD" ]] && IS_AMD=true || IS_AMD=false
    # Detect Desktop Environment for Compositor toggle
    [[ "$XDG_CURRENT_DESKTOP" =~ "GNOME" ]] && IS_GNOME=true || IS_GNOME=false
    [[ "$XDG_CURRENT_DESKTOP" =~ "KDE" ]] && IS_KDE=true || IS_KDE=false
}

provision_tools() {
    princess_say "Checking your inventory for essentials..."
    TOOLS=("gamescope" "gamemoded" "mangohud" "pciutils" "util-linux" "jq" "ionice")
    MISSING=()
    for t in "${TOOLS[@]}"; do if ! command -v "$t" &> /dev/null; then MISSING+=("$t"); fi; done

    if [ ${#MISSING[@]} -gt 0 ]; then
        princess_say "We're missing some accessories: ${WHITE}${MISSING[*]}${NC}"
        read -p "Shall we go shopping? (y/n): " shop
        if [[ "$shop" == "y" ]]; then
            if command -v dnf &>/dev/null; then sudo dnf install -y gamescope gamemode mangohud pciutils util-linux jq
            elif command -v apt &>/dev/null; then sudo apt install -y gamescope gamemode mangohud pciutils util-linux jq
            elif command -v pacman &>/dev/null; then sudo pacman -S --noconfirm gamescope gamemode mangohud pciutils util-linux jq
            fi
            # Special treatment: Grant Gamescope permission to be 'Nice'
            if command -v gamescope &>/dev/null; then
                sudo setcaps 'CAP_SYS_NICE=eip' "$(which gamescope)"
            fi
        fi
    fi
}

# --- 2. CORE OPTIMIZATIONS ---

tweak_cpu() {
    local current_gov=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null)
    if [ -f /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor ]; then
        echo "echo '$current_gov' | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor &>/dev/null" >> "$STATE_FILE"
        echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor &>/dev/null
        echo -e "  ${PINK}➤${NC} CPU Governor: ${WHITE}Performance${NC}"
    fi

    # Intel & AMD P-State EPP
    if [ -f /sys/devices/system/cpu/cpu0/cpufreq/energy_performance_preference ]; then
        local current_epp=$(cat /sys/devices/system/cpu/cpu0/cpufreq/energy_performance_preference)
        echo "for cpu in /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference; do echo '$current_epp' | sudo tee \$cpu &>/dev/null; done" >> "$STATE_FILE"
        echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference &>/dev/null
        echo -e "  ${PINK}➤${NC} CPU Energy Preference: ${WHITE}Performance${NC}"
    fi
}

tweak_memory() {
    local current_swappiness=$(sysctl -n vm.swappiness 2>/dev/null)
    local current_map=$(sysctl -n vm.max_map_count 2>/dev/null)
    local current_compact=$(sysctl -n vm.compaction_proactiveness 2>/dev/null)
    local current_cluster=$(sysctl -n vm.page-cluster 2>/dev/null)

    [ -n "$current_swappiness" ] && echo "sudo sysctl -w vm.swappiness=$current_swappiness &>/dev/null" >> "$STATE_FILE"
    [ -n "$current_map" ] && echo "sudo sysctl -w vm.max_map_count=$current_map &>/dev/null" >> "$STATE_FILE"
    [ -n "$current_compact" ] && echo "sudo sysctl -w vm.compaction_proactiveness=$current_compact &>/dev/null" >> "$STATE_FILE"
    [ -n "$current_cluster" ] && echo "sudo sysctl -w vm.page-cluster=$current_cluster &>/dev/null" >> "$STATE_FILE"
    
    # 1. Expand maps & reduce swap tendency
    sudo sysctl -w vm.swappiness=10 vm.max_map_count=2147483647 &>/dev/null
    
    # 2. Disable proactive compaction (Fixes Micro-stutters!) & page cluster latency
    sudo sysctl -w vm.compaction_proactiveness=0 vm.page-cluster=0 &>/dev/null

    if [ -f /sys/kernel/mm/transparent_hugepage/enabled ]; then
        local current_thp=$(cat /sys/kernel/mm/transparent_hugepage/enabled | grep -o '\[.*\]' | tr -d '[]')
        echo "echo '$current_thp' | sudo tee /sys/kernel/mm/transparent_hugepage/enabled &>/dev/null" >> "$STATE_FILE"
        echo always | sudo tee /sys/kernel/mm/transparent_hugepage/enabled &>/dev/null
    fi
    echo -e "  ${PINK}➤${NC} Memory: ${WHITE}Anti-Stutter Compaction Disabled, THP Enabled${NC}"
}

tweak_io() {
    # Find all non-rotational drives (SSDs/NVMe) and set to low-latency deadline
    local drives=$(lsblk -d -o NAME,ROTA | grep ' 0$' | awk '{print $1}')
    for drive in $drives; do
        local sched_path="/sys/block/$drive/queue/scheduler"
        if [ -f "$sched_path" ]; then
            local current_sched=$(cat "$sched_path" | grep -o '\[.*\]' | tr -d '[]' 2>/dev/null)
            [ -n "$current_sched" ] && echo "echo '$current_sched' | sudo tee $sched_path &>/dev/null" >> "$STATE_FILE"
            # Attempt to set mq-deadline or none (NVMe)
            echo mq-deadline | sudo tee "$sched_path" &>/dev/null || echo none | sudo tee "$sched_path" &>/dev/null
            echo -e "  ${PINK}➤${NC} I/O ($drive): ${WHITE}Low-Latency Profile${NC}"
        fi
    done
}

tweak_pcie() {
    # Disable Active State Power Management (ASPM) to reduce bus latency
    if [ -f /sys/module/pcie_aspm/parameters/policy ]; then
        local current_aspm=$(cat /sys/module/pcie_aspm/parameters/policy | grep -o '\[.*\]' | tr -d '[]')
        [ -n "$current_aspm" ] && echo "echo '$current_aspm' | sudo tee /sys/module/pcie_aspm/parameters/policy &>/dev/null" >> "$STATE_FILE"
        echo performance | sudo tee /sys/module/pcie_aspm/parameters/policy &>/dev/null
        echo -e "  ${PINK}➤${NC} PCIe Bus: ${WHITE}Power Limits Disabled (Maximum Bandwidth)${NC}"
    fi
}

tweak_network() {
    echo "sudo sysctl -w net.core.default_qdisc=$(sysctl -n net.core.default_qdisc) &>/dev/null" >> "$STATE_FILE"
    echo "sudo sysctl -w net.ipv4.tcp_congestion_control=$(sysctl -n net.ipv4.tcp_congestion_control) &>/dev/null" >> "$STATE_FILE"
    sudo sysctl -w net.core.default_qdisc=fq_codel &>/dev/null
    sudo sysctl -w net.ipv4.tcp_congestion_control=bbr &>/dev/null
    echo -e "  ${PINK}➤${NC} Network: ${WHITE}BBR + FQ_Codel${NC} (Ping Polish)"
}

tweak_gpu() {
    if [ "$IS_NVIDIA" == "true" ]; then
        local current_pl=$(nvidia-smi -q -d POWER | grep "Power Limit" | head -n 1 | awk '{print $4}')
        [[ "$current_pl" =~ ^[0-9]+$ ]] && echo "sudo nvidia-smi -pl $current_pl &>/dev/null" >> "$STATE_FILE"
        sudo nvidia-smi -pm 1 &>/dev/null
        local max_pl=$(nvidia-smi -q -d POWER | grep "Max Power Limit" | awk '{print $5}' | head -n 1)
        [[ "$max_pl" =~ ^[0-9]+$ ]] && sudo nvidia-smi -pl "$max_pl" &>/dev/null
        echo -e "  ${PINK}➤${NC} NVIDIA GPU: ${WHITE}Unlocked Power Limit${NC}"
        
    elif [ "$IS_AMD" == "true" ]; then
        for hw in /sys/class/drm/card*/device/hwmon/hwmon*/power_dpm_force_performance_level; do
            if [ -f "$hw" ]; then
                local current_lvl=$(cat "$hw")
                echo "echo '$current_lvl' | sudo tee $hw &>/dev/null" >> "$STATE_FILE"
                echo high | sudo tee "$hw" &>/dev/null
            fi
        done
        echo -e "  ${PINK}➤${NC} AMD GPU: ${WHITE}High Performance Profile${NC}"
    fi
}

toggle_compositor() {
    if [ "$IS_GNOME" == "true" ]; then
        local current_state=$(gsettings get org.gnome.desktop.interface enable-animations)
        if [[ "$current_state" == "true" ]]; then
            echo "gsettings set org.gnome.desktop.interface enable-animations true" >> "$STATE_FILE"
            gsettings set org.gnome.desktop.interface enable-animations false
            echo -e "  ${PINK}➤${NC} GNOME Animations: ${WHITE}Disabled${NC}"
        fi
    elif [ "$IS_KDE" == "true" ]; then
        local current_comp=$(qdbus org.kde.KWin /Compositor org.kde.kwin.Compositing.active 2>/dev/null)
        if [[ "$current_comp" == "true" ]]; then
            echo "qdbus org.kde.KWin /Compositor org.kde.kwin.Compositing.resume" >> "$STATE_FILE"
            qdbus org.kde.KWin /Compositor org.kde.kwin.Compositing.suspend
            echo -e "  ${PINK}➤${NC} KDE Compositor: ${WHITE}Suspended${NC}"
        fi
    fi
}

pause_services() {
    CLUTTER=("tracker-miner-fs-3" "packagekit" "accounts-daemon" "cups" "bluetooth")
    for srv in "${CLUTTER[@]}"; do
        if systemctl is-active --quiet "$srv"; then
            echo "sudo systemctl start $srv &>/dev/null" >> "$STATE_FILE"
            sudo systemctl stop "$srv" &>/dev/null
            echo -e "  ${PINK}➤${NC} Paused Background Service: ${WHITE}$srv${NC}"
        fi
    done
}

# --- 3. MAIN ROUTINES ---

apply_full_glow_up() {
    sudo -v
    echo "#!/bin/bash" > "$STATE_FILE"
    echo "# Pixel Princess Revert Script" >> "$STATE_FILE"
    
    princess_say "Applying Full Glamour Mask..."
    echo -e "\n${TRANS_BLUE}--- System Transformation ---${NC}"
    
    tweak_cpu
    tweak_memory
    tweak_io
    tweak_pcie
    tweak_network
    tweak_gpu
    toggle_compositor
    pause_services
    
    echo -e "\n${GLITTER} ${BOLD}Glow-Up Complete!${NC}"
    princess_say "You look absolutely stunning. Ready to dominate."
}

launch_and_slay() {
    princess_say "The Runway Mode: We boost, we accessorize, we launch, we detox."
    read -p "Enter game launch command (e.g. 'steam steam://rungameid/1151340' or 'wine game.exe'): " cmd
    if [ -z "$cmd" ]; then return; fi
    
    apply_full_glow_up
    
    # The Accessory Check: Inject ENV variables
    princess_say "Picking out the perfect accessories..."
    local env_prefix=""
    
    # Standard Gaming Env Vars
    env_prefix="WINEFSYNC=1 DXVK_STATE_CACHE=1"
    
    # MangoHud
    if command -v mangohud &>/dev/null; then 
        env_prefix="MANGOHUD=1 $env_prefix"
        echo -e "  ${PINK}➤${NC} MangoHud overlay ${WHITE}Equipped${NC}"
    fi
    
    # GameMode
    local launch_cmd=""
    if command -v gamemoded &>/dev/null; then 
        launch_cmd="gamemoderun $cmd"
        echo -e "  ${PINK}➤${NC} Feral GameMode ${WHITE}Equipped${NC}"
    else
        launch_cmd="$cmd"
    fi

    princess_say "Hitting the runway..."
    echo -e "${GLITTER} ${BOLD}EXECUTING: ${WHITE}${env_prefix} ${launch_cmd}${NC} ${GLITTER}"
    
    # Execute the game wrapper
    eval "$env_prefix $launch_cmd"
    
    princess_say "Show's over. Initiating cleanup..."
    apply_detox
}

apply_slay_mode() {
    princess_say "Targeting a running process for priority boost..."
    read -p "Enter Game Process Name (e.g. 'eldenring', 'cs2'): " game_name
    PID=$(pgrep -f "$game_name" | head -n 1)
    if [ -n "$PID" ]; then
        sudo -v
        # CPU Real-Time Priority
        sudo renice -n -15 -p "$PID" &>/dev/null
        sudo chrt -r -p 95 "$PID" &>/dev/null 
        # I/O Real-Time Priority (Class 1, Level 0 = Highest)
        if command -v ionice &>/dev/null; then
            sudo ionice -c 1 -n 0 -p "$PID" &>/dev/null
        fi
        princess_say "Process $PID has been elevated to ${WHITE}Absolute Priority (CPU & I/O)${NC}. Slay on."
    else
        princess_say "Couldn't find that process, honey. Is it running?"
    fi
}

apply_detox() {
    if [ -f "$STATE_FILE" ]; then
        princess_say "Washing off the performance makeup..."
        bash "$STATE_FILE"
        rm "$STATE_FILE"
        princess_say "Detox complete. Your system is back to casual wear."
    else
        princess_say "You're already in your natural state, darling."
    fi
}

# --- 4. INTERFACE ---
show_banner() {
    clear; get_specs
    echo -e "${PINK}${BOLD}"
    echo " ██████╗ ██╗██╗    ██╗███████╗███████╗ ██████╗ ███╗   ███╗███████╗"
    echo "██╔════╝███║██║    ██║██╔════╝██╔════╝██╔═══██╗████╗ ████║██╔════╝"
    echo "██║     ╚██║██║ █╗ ██║█████╗  ███████╗██║   ██║██╔████╔██║█████╗  "
    echo "██║      ██║██║███╗██║██╔══╝  ╚════██║██║   ██║██║╚██╔╝██║██╔══╝  "
    echo "╚██████╗ ██║╚███╔███╔╝███████╗███████║╚██████╔╝██║ ╚═╝ ██║███████╗"
    echo " ╚═════╝ ╚═╝ ╚══╝╚══╝ ╚══════╝╚══════╝ ╚═════╝ ╚═╝     ╚═╝╚══════╝"
    echo -e "                 ${PINK}P R I N C E S S${NC}"
    echo -e "         ${GLITTER} ${WHITE}THE ULTIMATE GAMING TOOLKIT${NC} ${GLITTER}"
    echo -e "${TRANS_BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${PINK}CPU:${NC} $CPU"
    echo -e "${BLUE}GPU:${NC} $GPU"
    echo -e "${TRANS_BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${WHITE}${BOLD}            Made with <3 by transfem.ca${NC}"
    echo ""
}

# --- MAIN ---
show_banner
check_state
provision_tools

echo -e "${BOLD}Routine Selection:${NC}"
echo -e "  1) ${PINK}FULL GLOW UP${NC} (Apply all kernel/system tweaks now)"
echo -e "  2) ${WHITE}LAUNCH & SLAY${NC} (Auto-Boost -> Add ENV accessories -> Run -> Detox)"
echo -e "  3) ${PINK}SLAY MODE${NC} (Elevate active game PID to Real-Time CPU & I/O)"
echo -e "  4) ${TRANS_BLUE}DETOX${NC} (Revert all changes)"
echo -e "  5) Exit\n"
read -p "▶ Choice: " main_choice

case $main_choice in
    1) apply_full_glow_up ;;
    2) launch_and_slay ;;
    3) apply_slay_mode ;;
    4) apply_detox ;;
    *) exit 0 ;;
esac
