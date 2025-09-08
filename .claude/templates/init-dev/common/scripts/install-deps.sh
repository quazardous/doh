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
            # Install Docker on Ubuntu/Debian
            curl -fsSL https://get.docker.com -o get-docker.sh
            sudo sh get-docker.sh
            sudo usermod -aG docker $USER
            rm get-docker.sh
            echo "⚠️  Please logout and login again for Docker group to take effect"
            ;;
        "windows")
            echo "❌ Please install Docker Desktop manually from: https://docker.com/products/docker-desktop"
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
            if command -v apt >/dev/null; then
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
            else
                echo "❌ Package manager not supported. Install mkcert manually"
                exit 1
            fi
            ;;
        "windows")
            echo "❌ Please install mkcert manually on Windows"
            echo "   Download from: https://github.com/FiloSottile/mkcert/releases"
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
                xcode-select --install
                ;;
            "linux") 
                if command -v apt >/dev/null; then
                    sudo apt update && sudo apt install -y build-essential
                elif command -v yum >/dev/null; then
                    sudo yum groupinstall -y "Development Tools"
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