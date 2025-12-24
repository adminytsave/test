# Gunakan image Ubuntu sebagai dasar
FROM ubuntu:20.04

# Install dependensi untuk XRDP, Tailscale, dan alat lainnya
RUN apt-get update && apt-get install -y \
    software-properties-common \
    gnupg2 \
    curl \
    lsb-release \
    apt-transport-https \
    xrdp \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Install Tailscale
RUN curl -fsSL https://pkgs.tailscale.com/stable/ubuntu_$(lsb_release -rs).deb -o tailscale.deb \
    && dpkg -i tailscale.deb \
    && apt-get install -f -y \
    && rm -f tailscale.deb

# Konfigurasi XRDP untuk menerima koneksi
RUN systemctl enable xrdp && systemctl start xrdp
RUN adduser --disabled-password --gecos "" mpragans && echo "mpragans:123456" | chpasswd
RUN adduser mpragans sudo

# Install Tailscale dan autentikasi dengan authkey hardcoded
RUN tailscale up --authkey=tskey-auth-kwqqsQ69E811CNTRL-enkPiyGJrugedCYpDPATugq392qWbsTv

# Buka port XRDP (3389) dan Tailscale (sebaiknya menggunakan port default)
EXPOSE 3389

# Set Tailscale untuk mengaktifkan koneksi secara otomatis saat container dimulai
CMD tailscale up && xrdp -nodaemon
