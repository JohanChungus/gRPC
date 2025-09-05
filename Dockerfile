# Gunakan image Nginx resmi dari Docker Hub
FROM nginx:alpine

# Hapus konfigurasi Nginx default
RUN rm /etc/nginx/conf.d/default.conf

# Buat file konfigurasi Nginx untuk reverse proxy gRPC
# dengan perbaikan untuk masalah konektivitas IPv6 dan SSL/SNI
RUN <<EOF cat > /etc/nginx/conf.d/grpc_proxy.conf
server {
    listen 8080 http2;

    # Tambahkan resolver untuk memastikan resolusi DNS berfungsi dengan andal di dalam container.
    # Cloudflare (1.1.1.1) dan Google (8.8.8.8) adalah pilihan yang baik.
    # "ipv6=off" sangat penting untuk mencegah kesalahan "Network unreachable" di lingkungan Render.
    resolver 1.1.1.1 8.8.8.8 valid=60s ipv6=off;

    location / {
        # Setel upstream ke variabel. Ini memaksa Nginx untuk menggunakan resolver yang
        # ditentukan di atas pada saat runtime, alih-alih saat Nginx dimulai.
        set $upstream_grpc vps-monitor.fly.dev:443;

        # Teruskan permintaan ke server gRPC upstream
        grpc_pass grpcs://$upstream_grpc;

        # Perbaikan Kritis untuk Kesalahan SSL Handshake:
        # Aktifkan SNI. Ini memberitahu Nginx untuk meneruskan nama host ("vps-monitor.fly.dev")
        # selama handshake TLS, sehingga server upstream tahu domain mana yang Anda coba jangkau.
        grpc_ssl_server_name on;
    }
}
EOF

# Ekspos port 8080 untuk mengizinkan lalu lintas masuk
EXPOSE 8080

# Jalankan Nginx di latar depan saat container dimulai
CMD ["nginx", "-g", "daemon off;"]
