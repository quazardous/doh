#!/bin/bash
set -e

echo "📦 Installing Docker Development Dependencies"
echo "=============================================="

# Detect OS
OS="unknown"
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
elif [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "msys" ]]; then
    OS="windows"
fi

echo "🔍 Detected OS: $OS"
echo ""

# Install Docker
install_docker() {
    if command -v docker >/dev/null; then
        echo "✅ Docker already installed"
        return
    fi
    
    echo "📦 Installing Docker..."
    case $OS in
        "macos")
            if command -v brew >/dev/null; then
                brew install --cask docker
            else
                echo "❌ Homebrew required on macOS. Install from: https://brew.sh"
                exit 1
            fi
            ;;
        "linux")
            # Detect Linux distribution
            if [ -f /etc/os-release ]; then
                . /etc/os-release
                DISTRO=$ID
                VERSION=$VERSION_ID
            else
                echo "❌ Cannot detect Linux distribution"
                exit 1
            fi
            
            case $DISTRO in
                "ubuntu"|"debian")
                    echo "📦 Installing Docker on Ubuntu/Debian..."
                    # Remove old versions if any
                    sudo apt-get remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true
                    
                    # Install prerequisites
                    sudo apt-get update
                    sudo apt-get install -y \
                        ca-certificates \
                        curl \
                        gnupg \
                        lsb-release
                    
                    # Add Docker's official GPG key
                    sudo mkdir -p /etc/apt/keyrings
                    curl -fsSL https://download.docker.com/linux/$DISTRO/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
                    
                    # Set up the repository
                    echo \
                      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/$DISTRO \
                      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
                    
                    # Install Docker Engine
                    sudo apt-get update
                    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
                    ;;
                    
                "fedora")
                    echo "📦 Installing Docker on Fedora..."
                    # Remove old versions
                    sudo dnf remove -y docker \
                        docker-client \
                        docker-client-latest \
                        docker-common \
                        docker-latest \
                        docker-latest-logrotate \
                        docker-logrotate \
                        docker-selinux \
                        docker-engine-selinux \
                        docker-engine 2>/dev/null || true
                    
                    # Install Docker
                    sudo dnf -y install dnf-plugins-core
                    sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
                    sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
                    
                    # Start Docker
                    sudo systemctl start docker
                    sudo systemctl enable docker
                    ;;
                    
                "rhel"|"centos"|"rocky"|"almalinux")
                    echo "📦 Installing Docker on RHEL/CentOS/Rocky/AlmaLinux..."
                    # Remove old versions
                    sudo yum remove -y docker \
                        docker-client \
                        docker-client-latest \
                        docker-common \
                        docker-latest \
                        docker-latest-logrotate \
                        docker-logrotate \
                        docker-engine 2>/dev/null || true
                    
                    # Install required packages
                    sudo yum install -y yum-utils
                    sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
                    
                    # Install Docker
                    sudo yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
                    
                    # Start Docker
                    sudo systemctl start docker
                    sudo systemctl enable docker
                    ;;
                    
                "arch"|"manjaro")
                    echo "📦 Installing Docker on Arch Linux..."
                    sudo pacman -Syu --noconfirm
                    sudo pacman -S --noconfirm docker docker-compose
                    
                    # Start Docker
                    sudo systemctl start docker
                    sudo systemctl enable docker
                    ;;
                    
                "opensuse"|"suse")
                    echo "📦 Installing Docker on openSUSE/SUSE..."
                    sudo zypper install -y docker docker-compose
                    
                    # Start Docker
                    sudo systemctl start docker
                    sudo systemctl enable docker
                    ;;
                    
                *)
                    echo "⚠️  Distribution $DISTRO not directly supported. Falling back to generic installer..."
                    curl -fsSL https://get.docker.com -o get-docker.sh
                    sudo sh get-docker.sh
                    rm get-docker.sh
                    ;;
            esac
            
            # Add user to docker group
            sudo usermod -aG docker $USER
            echo "⚠️  Please logout and login again for Docker group to take effect"
            ;;
        "windows")
            echo "📦 Docker installation on Windows requires manual setup:"
            echo ""
            echo "1. Enable WSL2 (Windows Subsystem for Linux):"
            echo "   - Open PowerShell as Administrator"
            echo "   - Run: wsl --install"
            echo "   - Restart your computer"
            echo ""
            echo "2. Install Docker Desktop:"
            echo "   - Download from: https://docker.com/products/docker-desktop"
            echo "   - During installation, ensure 'Use WSL 2 instead of Hyper-V' is checked"
            echo "   - After installation, go to Settings > General"
            echo "   - Ensure 'Use the WSL 2 based engine' is enabled"
            echo ""
            echo "3. Configure WSL2 integration:"
            echo "   - In Docker Desktop, go to Settings > Resources > WSL Integration"
            echo "   - Enable integration with your distro (Ubuntu recommended)"
            echo ""
            echo "4. Use Docker from WSL2 terminal:"
            echo "   - Open WSL2 terminal (Ubuntu)"
            echo "   - Docker commands will work: docker ps, docker compose, etc."
            echo ""
            echo "⚠️  Note: Always use WSL2 terminal for Docker commands, not PowerShell/CMD"
            exit 1
            ;;
        *)
            echo "❌ Unsupported OS: $OSTYPE"
            exit 1
            ;;
    esac
}

# Install mkcert  
install_mkcert() {
    if command -v mkcert >/dev/null; then
        echo "✅ mkcert already installed"
        return
    fi
    
    echo "📦 Installing mkcert..."
    case $OS in
        "macos")
            if command -v brew >/dev/null; then
                brew install mkcert
            else
                echo "❌ Homebrew required. Install from: https://brew.sh"
                exit 1
            fi
            ;;
        "linux")
            # Check if Homebrew is available on Linux (Linuxbrew)
            if command -v brew >/dev/null; then
                echo "🍺 Homebrew detected, using it to install mkcert..."
                brew install mkcert
            elif command -v apt >/dev/null; then
                sudo apt update
                sudo apt install -y libnss3-tools
                curl -JLO "https://dl.filippo.io/mkcert/latest?for=linux/amd64"
                chmod +x mkcert-v*-linux-amd64
                sudo mv mkcert-v*-linux-amd64 /usr/local/bin/mkcert
            elif command -v yum >/dev/null; then
                sudo yum install -y nss-tools
                curl -JLO "https://dl.filippo.io/mkcert/latest?for=linux/amd64" 
                chmod +x mkcert-v*-linux-amd64
                sudo mv mkcert-v*-linux-amd64 /usr/local/bin/mkcert
            elif command -v pacman >/dev/null; then
                # Arch Linux
                sudo pacman -S --noconfirm mkcert
            elif command -v zypper >/dev/null; then
                # openSUSE - mkcert might not be in repos, use binary
                sudo zypper install -y mozilla-nss-tools
                curl -JLO "https://dl.filippo.io/mkcert/latest?for=linux/amd64"
                chmod +x mkcert-v*-linux-amd64
                sudo mv mkcert-v*-linux-amd64 /usr/local/bin/mkcert
            else
                echo "❌ Package manager not supported. Install mkcert manually"
                exit 1
            fi
            ;;
        "windows")
            echo "📦 Installing mkcert on Windows/WSL2:"
            echo ""
            echo "Option 1: Install in WSL2 (Recommended):"
            echo "   1. Open WSL2 Ubuntu terminal"
            echo "   2. Run: sudo apt update && sudo apt install -y libnss3-tools"
            echo "   3. Download: curl -JLO 'https://dl.filippo.io/mkcert/latest?for=linux/amd64'"
            echo "   4. Install: chmod +x mkcert-v*-linux-amd64 && sudo mv mkcert-v*-linux-amd64 /usr/local/bin/mkcert"
            echo "   5. Setup: mkcert -install"
            echo ""
            echo "Option 2: Install natively on Windows:"
            echo "   - With Chocolatey: choco install mkcert"
            echo "   - Or download from: https://github.com/FiloSottile/mkcert/releases"
            echo ""
            echo "⚠️  Note: Use WSL2 installation for better Docker integration"
            exit 1
            ;;
    esac
}

# Install other tools
install_other_tools() {
    # curl is usually pre-installed, but check anyway
    if ! command -v curl >/dev/null; then
        echo "📦 Installing curl..."
        case $OS in
            "macos")
                echo "✅ curl should be pre-installed on macOS"
                ;;
            "linux")
                if command -v apt >/dev/null; then
                    sudo apt update && sudo apt install -y curl
                elif command -v yum >/dev/null; then
                    sudo yum install -y curl
                fi
                ;;
        esac
    else
        echo "✅ curl already installed"
    fi
    
    # make is usually pre-installed
    if ! command -v make >/dev/null; then
        echo "📦 Installing make..."
        case $OS in
            "macos")
                if command -v brew >/dev/null; then
                    brew install make
                else
                    xcode-select --install
                fi
                ;;
            "linux") 
                # Check for Homebrew first
                if command -v brew >/dev/null; then
                    echo "🍺 Homebrew detected, using it to install make..."
                    brew install make
                elif command -v apt >/dev/null; then
                    sudo apt update && sudo apt install -y build-essential
                elif command -v yum >/dev/null; then
                    sudo yum groupinstall -y "Development Tools"
                elif command -v pacman >/dev/null; then
                    sudo pacman -S --noconfirm base-devel
                elif command -v zypper >/dev/null; then
                    sudo zypper install -y make gcc
                fi
                ;;
        esac
    else
        echo "✅ make already installed"
    fi
}

# Main installation
main() {
    install_docker
    install_mkcert
    install_other_tools
    
    echo ""
    echo "🎉 Installation complete!"
    echo ""
    echo "Next steps:"
    echo "1. make setup    # Setup SSL certificates"  
    echo "2. make dev      # Start development environment"
    echo "3. make hello-world  # Validate everything works"
}

main