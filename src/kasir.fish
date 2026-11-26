#!/usr/bin/env fish

# Cek apakah storage internal udah diizinkan
if not test -d ~/storage/shared
    echo "Belum ada izin penyimpanan!"
    echo "Gue bukain pop-up izin dulu ya..."
    termux-setup-storage
    echo ""
    echo "Pencet Izinkan, terus jalankan lagi kasirnya."
    echo "Perintahnya: fish src/kasir.fish"
    exit
end

function input_angka
    set -l prompt $argv[1]
    set -l tipe $argv[2]
    set -l max_len $argv[3]
    while true
        read -P "$prompt" input
        set input (string trim "$input")
        if test (string length "$input") -gt $max_len
            set input (string sub -l $max_len "$input")
        end
        if test -z "$input"
            continue
        end
        if test "$tipe" = "int"
            set regex '^[0-9]+$'
        else
            set regex '^-?[0-9]+(\.[0-9]+)?$'
        end
        if string match -qr "$regex" "$input"
            echo $input
            return
        end
    end
end

function input_teks
    set -l prompt $argv[1]
    set -l max_len $argv[2]
    while true
        read -P "$prompt" input
        set input (string trim "$input")
        if test (string length "$input") -gt $max_len
            set input (string sub -l $max_len "$input")
        end
        if test -n "$input"
            echo $input
            return
        end
    end
end

clear
echo "========================="
echo " PROGRAM KASIR FISH  "
echo "     Versi 1.0.0     "
echo " github.com/ricoyp96 "
echo "========================="

set nama_barang
set harga_barang
set jumlah_barang
set subtotal_list
set total 0

while true
    set nama (input_teks "Nama Barang [max 7]/ketik 'selesai' utk hitung: " 7)
    if test "$nama" = "selesai"
        break
    end

    set harga (input_angka "Harga Barang: Rp" "float" 7)
    set jumlah (input_angka "Jumlah: " "int" 3)

    set subtotal (math "$harga * $jumlah")
    set total (math "$total + $subtotal")

    set nama_barang $nama_barang $nama
    set harga_barang $harga_barang $harga
    set jumlah_barang $jumlah_barang $jumlah
    set subtotal_list $subtotal_list $subtotal

    echo "Ditambahkan: $nama x $jumlah = Rp$subtotal"
    echo "-------------------------"
end

if test (count $nama_barang) -eq 0
    exit
end

# 1. TAMPILKAN RINGKASAN + TOTAL DULU
clear
echo "========================="
echo " RINGKASAN BELANJA "
echo "========================="
for i in (seq 1 (count $nama_barang))
    printf "%-2d. %-7s x %3d = Rp%.0f\n" $i $nama_barang[$i] $jumlah_barang[$i] $subtotal_list[$i]
end
echo "-------------------------"
echo "TOTAL BELANJA: Rp$total"
echo "========================="
echo ""

# 2. BARU MINTA BAYAR
set bayar (input_angka "Uang Bayar: Rp" "float" 10)

set kembalian 0
set kurang 0
if test $bayar -lt $total
    set kurang (math "$total - $bayar")
else
    set kembalian (math "$bayar - $total")
end

# 3. CETAK STRUK LENGKAP
mkdir -p ~/storage/shared/struk
set tanggal (date "+%d-%m-%Y_%H%M%S")
set nama_file $HOME/storage/shared/struk/struk_$tanggal.txt

set struk_lines
set -a struk_lines "========================="
set -a struk_lines " STRUK BELANJA "
set -a struk_lines "========================="
set -a struk_lines (date)
set -a struk_lines "---------------------------------"
set -a struk_lines "No | Nama | Harga | Jml | Subtotal"
set -a struk_lines "---------------------------------"

for i in (seq 1 (count $nama_barang))
    set baris (printf "%-2d | %-7s | %7.0f | %3d | %9.0f" $i $nama_barang[$i] $harga_barang[$i] $jumlah_barang[$i] $subtotal_list[$i])
    set -a struk_lines "$baris"
end

set -a struk_lines "---------------------------------"
set -a struk_lines "TOTAL BELANJA: Rp$total"
set -a struk_lines "Uang Bayar: Rp$bayar"

if test $kurang -gt 0
    set -a struk_lines "Kekurangan: Rp$kurang"
else
    set -a struk_lines "Kembalian: Rp$kembalian"
end

set -a struk_lines "========================="
set -a struk_lines "Terima kasih sudah belanja :)"

clear
printf "%s\n" $struk_lines
printf "%s\n" $struk_lines > $nama_file

echo "---------------------------------------"
echo "Struk lengkap sudah disimpan ke: $nama_file"
