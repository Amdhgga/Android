#!/bin/bash

# Update system and install required packages
apt-get update
apt-get install -y qemu-system-x86 wget unzip

# Create directory for Android
mkdir -p ~/android-x86
cd ~/android-x86

# Download Android-x86 (using version 7.1-r5 as it's more stable for emulation)
wget "https://downloads.sourceforge.net/project/android-x86/Release%209.0/android-x86_64-9.0-r2.iso?ts=gAAAAABnIKAUqCY54yeRISprscU6E50x2gGnQtFXDoNSxiM8TpSGid3ekSNIGvNpbgkEuaxD5yWzJPblQqc5KDsJBrIMUPpgzA%3D%3D&use_mirror=cyfuture&r=https%3A%2F%2Ftemp-mail.gg%2F"

# Create a virtual disk for Android
qemu-img create -f qcow2 android.img 8G

# Run Android-x86 installation (without KVM)
qemu-system-x86_64 \
    -m 2048 \
    -smp cores=2 \
    -vga std \
    -display vnc=:0 \
    -drive file=android-x86-7.1-r5.iso,media=cdrom \
    -drive file=android.img,format=qcow2 \
    -net nic,model=e1000 \
    -net user \
    -boot d

# After installation, create run script (save as run-android.sh)
cat > run-android.sh << 'EOL'
#!/bin/bash
qemu-system-x86_64 \
    -m 2048 \
    -smp cores=2 \
    -vga std \
    -display vnc=:0 \
    -drive file=android.img,format=qcow2 \
    -net nic,model=e1000 \
    -net user \
    -boot c
EOL

chmod +x run-android.sh

# Create instructions file
cat > README.txt << 'EOL'
To connect to Android:

1. On your local machine, create an SSH tunnel:
   ssh -L 5900:localhost:5900 your-vps-username@your-vps-ip

2. Use a VNC viewer to connect to localhost:5900

3. To start Android:
   ./run-android.sh

Tips for better performance:
- Disable animations in Android settings
- Set background processes limit to 'no background processes'
- Use a lightweight launcher
- Avoid resource-intensive apps

Note: Replace your-vps-username and your-vps-ip with your actual VPS credentials
EOL
