#!/bin/bash

# Memantau lalu lintas menggunakan vnstat -l
vnstat -l > /tmp/vnstat.log &

# Mendapatkan PID dari proses vnstat
vnstat_pid=$!

# Memeriksa lalu lintas setiap 1 detik
while true; do
    clear  # Membersihkan layar terminal
    echo "Live Traffic Monitoring:"
    echo "========================"
    tail -n 1 /tmp/vnstat.log  # Menampilkan baris terakhir dari log vnstat
    sleep 1  # Menunggu 1 detik sebelum memeriksa lagi

    # Mendapatkan data lalu lintas terbaru dari log vnstat dan memeriksa apakah kecepatan lalu lintas melebihi 100 Mbit/s
    if (( $(tail -n 10 /tmp/vnstat.log | grep -c "100 Mbit/s") )); then
        echo "Traffic speed exceeds 100 Mbit/s. Checking UDP connections..."
        
        # Mengecek koneksi UDP dengan netstat
        connections=$(netstat -pun | grep -i udp)

        # Memeriksa apakah ada koneksi UDP yang terdeteksi
        if [ -n "$connections" ]; then
            echo "UDP connections detected:"
            echo "$connections"

            # Mendapatkan PID dari koneksi UDP dan menghentikan proses
            while read -r line; do
                pid=$(echo "$line" | awk '{print $7}' | cut -d '/' -f 1)
                if [ -n "$pid" ]; then
                    echo "Killing process with PID: $pid"
                    kill -9 "$pid"
                else
                    echo "Failed to retrieve PID."
                fi
            done <<< "$connections"
        else
            echo "No UDP connections detected."
        fi
    else
        echo "Traffic speed is within limits."
    fi
done