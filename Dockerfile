# Gunakan image Nginx resmi dari Docker Hub
FROM nginx:alpine

# Hapus konfigurasi Nginx default
RUN rm /etc/nginx/conf.d/default.conf

# Buat file konfigurasi Nginx untuk reverse proxy gRPC
RUN <<EOF cat > /etc/nginx/conf.d/grpc_proxy.conf
server {
    # Nginx akan mendengarkan di port 8080 untuk lalu lintas HTTP/2
    listen 8080 http2;

    location / {
        # Teruskan permintaan gRPC ke server upstream (vps-monitor.fly.dev)
        # "grpcs" menunjukkan bahwa koneksi ke upstream diamankan dengan TLS
        grpc_pass grpcs://vps-monitor.fly.dev:443;
    }
}
EOF

# Ekspos port 8080 untuk mengizinkan lalu lintas masuk
EXPOSE 8080

# Jalankan Nginx di latar depan saat container dimulai
CMD ["nginx", "-g", "daemon off;"]
