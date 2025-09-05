# Gunakan image Nginx resmi dari Docker Hub
FROM nginx:alpine

# Hapus konfigurasi Nginx default
RUN rm /etc/nginx/conf.d/default.conf

# Buat file konfigurasi Nginx untuk reverse proxy gRPC.
# Menggunakan <<'EOF' mencegah shell mencoba mengganti variabel Nginx ($grpc_target).
RUN <<'EOF' cat > /etc/nginx/conf.d/grpc_proxy.conf
server {
    # Mendengarkan di port 8080. Peringatan tentang 'listen ... http2' telah diperbaiki.
    listen 8080;
    http2 on;

    # Tambahkan resolver DNS untuk memastikan resolusi nama domain yang andal.
    # 'ipv6=off' akan memaksa Nginx untuk hanya menggunakan alamat IPv4.
    resolver 1.1.1.1 8.8.8.8 valid=10s ipv6=off;

    location / {
        # Menggunakan variabel untuk nama host akan memastikan Nginx
        # menggunakan resolver yang didefinisikan di atas saat runtime.
        set $grpc_target "vps-monitor.fly.dev:443";

        # Teruskan permintaan gRPC ke server upstream (vps-monitor.fly.dev)
        grpc_pass grpcs://$grpc_target;
    }
}
EOF

# Ekspos port 8080 untuk mengizinkan lalu lintas masuk
EXPOSE 8080

# Jalankan Nginx di latar depan saat container dimulai
CMD ["nginx", "-g", "daemon off;"]
