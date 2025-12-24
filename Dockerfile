# Gunakan image Ubuntu sebagai dasar
FROM ubuntu:20.04

# Set environment variables untuk locale dan timezone
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Jakarta

# Install dependensi untuk XRDP, Tailscale, dan alat lainnya
RUN apt-get update && apt-get install -y \
    software-properties-common \
    gnupg2 \
    curl \
    lsb-release \
    apt-transport-https \
    xrdp \
    sudo \
    locales \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Set locale
RUN locale-gen en_US.UTF-8
RUN update-locale LANG=en_US.UTF-8

# Install Tailscale dengan URL yang lebih aman
RUN curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/focal_amd64.deb -o tailscale.deb \
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

# Gunakan skrip untuk menjalankan Tailscale dan XRDP agar sinyal diteruskan dengan benar
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Set entrypoint untuk menjalankan Tailscale dan XRDP
ENTRYPOINT ["/entrypoint.sh"]
