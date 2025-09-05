# Gunakan image Nginx resmi dari Docker Hub
FROM nginx:alpine

# Hapus konfigurasi Nginx default
RUN rm /etc/nginx/conf.d/default.conf

# Buat file konfigurasi Nginx untuk reverse proxy gRPC
# Konfigurasi ini telah diperbaiki untuk mengatasi masalah konektivitas dan SSL handshake
RUN <<EOF cat > /etc/nginx/conf.d/grpc_proxy.conf
server {
    # Nginx akan mendengarkan di port 8080 untuk lalu lintas HTTP/2
    listen 8080 http2;

    location / {
        # SOLUSI 1: Gunakan resolver publik dan nonaktifkan pencarian IPv6.
        # Ini untuk menghindari kesalahan "Network unreachable" di lingkungan seperti Render.
        resolver 8.8.8.8 ipv6=off;

        # Variabel ini diperlukan agar Nginx menggunakan 'resolver' di atas.
        set $upstream_host "vps-monitor.fly.dev";

        # Teruskan permintaan gRPC ke server upstream (vps-monitor.fly.dev)
        grpc_pass grpcs://$upstream_host:443;

        # SOLUSI 2: Teruskan nama host yang benar ke upstream.
        # Ini memperbaiki kesalahan "peer closed connection in SSL handshake"
        # dengan memastikan SNI yang benar dikirim.
        grpc_set_header Host $upstream_host;
    }
}
EOF

# Ekspos port 8080 untuk mengizinkan lalu lintas masuk
EXPOSE 8080

# Jalankan Nginx di latar depan saat container dimulai
CMD ["nginx", "-g", "daemon off;"]
