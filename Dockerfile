# Gunakan image NGINX resmi dari Docker Hub
FROM nginx:alpine

# Hapus konfigurasi default NGINX
RUN rm /etc/nginx/conf.d/default.conf

# Salin file konfigurasi kustom Anda ke dalam image
COPY nginx.conf /etc/nginx/nginx.conf

# Ekspos port yang akan didengarkan oleh NGINX di dalam container
EXPOSE 8080

# Perintah untuk menjalankan NGINX saat container dimulai
CMD ["nginx", "-g", "daemon off;"]
