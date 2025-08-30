# Quick Install

## Unix/Linux/macOS

```bash
curl -sSL https://raw.githubusercontent.com/quazardous/doh/main/doh.sh | bash
```

Or with wget:

```bash
wget -qO- https://raw.githubusercontent.com/quazardous/doh/main/doh.sh | bash
```

## Windows (PowerShell)

```powershell
iwr -useb https://raw.githubusercontent.com/quazardous/doh/main/doh.bat | iex
```

Or download and execute:

```powershell
curl -o doh.bat https://raw.githubusercontent.com/quazardous/doh/main/doh.bat && doh.bat
```

## One-liner alternatives

### Unix/Linux/macOS (direct commands)
```bash
git clone https://github.com/quazardous/doh.git . && rm -rf .git
```

### Windows (cmd)
```cmd
git clone https://github.com/quazardous/doh.git . && rmdir /s /q .git
```

### Windows (PowerShell)
```powershell
git clone https://github.com/quazardous/doh.git .; Remove-Item -Recurse -Force .git
```
