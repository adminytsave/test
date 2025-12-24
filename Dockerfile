# Gunakan image Ubuntu sebagai dasar
FROM ubuntu:20.04

# Set environment variables untuk locale dan timezone
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Jakarta

# Install dependensi yang diperlukan untuk menjalankan skrip Tailscale dan XRDP
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
    ca-certificates \
    bash \
    iproute2 \
    iputils-ping \
    && rm -rf /var/lib/apt/lists/*

# Set locale
RUN locale-gen en_US.UTF-8
RUN update-locale LANG=en_US.UTF-8

# Salin skrip install.sh yang telah diupload ke container
COPY install.sh /install.sh

# Memberikan izin eksekusi pada skrip
RUN chmod +x /install.sh

# Jalankan skrip untuk menginstal Tailscale
RUN /install.sh

# Konfigurasi XRDP
RUN adduser --disabled-password --gecos "" mpragans && echo "mpragans:123456" | chpasswd
RUN adduser mpragans sudo

# Install Tailscale dan autentikasi dengan authkey hardcoded
RUN tailscaled --state=/var/lib/tailscale/tailscaled.state & tailscale up --authkey=tskey-auth-kwqqsQ69E811CNTRL-enkPiyGJrugedCYpDPATugq392qWbsTv

# Buka port XRDP (3389) dan Tailscale (sebaiknya menggunakan port default)
EXPOSE 3389

# Gunakan skrip untuk menjalankan Tailscale dan XRDP agar sinyal diteruskan dengan benar
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Jalankan XRDP sebagai foreground process
CMD ["bash", "-c", "/entrypoint.sh && xrdp -nodaemon"]
