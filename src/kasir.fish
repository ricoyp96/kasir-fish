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

# --- CONFIG TOKO ---
set -g config_file "config.txt"
set -g nama_toko "TOKO BARANG DAN JASA"
set -g alamat_toko "Jalan Kenangan Lama Kota Baru"
set -g telp_toko "0812-3456-7890"
set -g nama_kasir "Admin"

function load_config
    if test -f $config_file
        for line in (cat $config_file)
            set -l parts (string split -m 1 "=" -- $line)
            switch $parts[1]
                case "nama_toko"
                    set -g nama_toko $parts[2]
                case "alamat_toko"
                    set -g alamat_toko $parts[2]
                case "telp_toko"
                    set -g telp_toko $parts[2]
                case "nama_kasir"
                    set -g nama_kasir $parts[2]
            end
        end
    end
end

function save_config
    echo "nama_toko=$nama_toko" > $config_file
    echo "alamat_toko=$alamat_toko" >> $config_file
    echo "telp_toko=$telp_toko" >> $config_file
    echo "nama_kasir=$nama_kasir" >> $config_file
end

function input_angka -a prompt_text tipe max_digit
    while true
        read -P "$prompt_text" input

        if test "$input" = "batal"
            set -g hasil_input "__BATAL__"
            return
        end

        if test -z "$input"
            echo "Input gak boleh kosong! Ketik angka atau 'batal'."
            continue
        end

        if test "$tipe" = "int"
            if not string match -qr '^[0-9]+$' -- $input
                echo " '$input' bukan angka. Ketik angka atau 'batal'."
                continue
            end
        else
            if not string match -qr '^[0-9]+(\.[0-9]+)?$' -- $input
                echo "'$input' bukan angka. Ketik angka atau 'batal'."
                continue
            end
        end

        if test (string length -- $input) -gt $max_digit
            echo "Kepanjangan! Maksimal $max_digit digit."
            continue
        end

        set -g hasil_input $input
        return
    end
end

function pengaturan_toko
    clear
    echo "=============================="
    echo "      PENGATURAN TOKO"
    echo "=============================="
    echo "Data sekarang:"
    echo "1. Nama Toko : $nama_toko"
    echo "2. Alamat    : $alamat_toko"
    echo "3. No. Telp  : $telp_toko"
    echo "4. Nama Kasir: $nama_kasir"
    echo "=============================="
    echo "Kosongin = tetap pakai yang lama"
    echo "Ketik 'batal' untuk batal"
    echo ""

    read -P "Nama Toko : " baru_nama
    if test "$baru_nama" = "batal"
        echo "Dibatalkan."
        sleep 1
        return
    end
    if test -n "$baru_nama"
        set -g nama_toko $baru_nama
    end

    read -P "Alamat Toko : " baru_alamat
    if test "$baru_alamat" = "batal"
        echo "Dibatalkan."
        sleep 1
        return
    end
    if test -n "$baru_alamat"
        set -g alamat_toko $baru_alamat
    end

        # --- INPUT NO. TELP: HANYA ANGKA, MAX 12 DIGIT ---
    while true
        read -P "No. Telp [$telp_toko]: " baru_telp

        if test -z "$baru_telp"
            break
        end

        if test "$baru_telp" = "batal"
            echo "Dibatalkan."
            sleep 1
            return
        end

        # Cek harus angka doang
        if not string match -qr '^[0-9]+$' -- $baru_telp
            echo "No. Telp harus angka doang! '$baru_telp' ada hurufnya."
            continue
        end

        # Cek maksimal 12 digit
        if test (string length -- $baru_telp) -gt 12
            echo "Kepanjangan! Maksimal 12 digit. Kamu input "(string length -- $baru_telp)" digit."
            continue
        end

        # Cek minimal, biar gak keisi 1 digit doang
        if test (string length -- $baru_telp) -lt 9
            echo "Kependekan! Minimal 9 digit."
            continue
        end

        # Lolos semua, simpan
        set -g telp_toko $baru_telp
        break
    end

    if test "$baru_telp" = "batal"
        echo "Dibatalkan."
        sleep 1
        return
    end
    if test -n "$baru_telp"
        set -g telp_toko $baru_telp
    end

    read -P "Nama Kasir : " baru_kasir
    if test "$baru_kasir" = "batal"
        echo "Dibatalkan."
        sleep 1
        return
    end
    if test -n "$baru_kasir"
        set -g nama_kasir $baru_kasir
    end

    save_config
    echo ""
    echo "Tersimpan!"
    echo "Toko: $nama_toko | Kasir: $nama_kasir"
    echo "Tekan Enter..."
    read
end

function kasir
    clear
    echo "=============================="
    echo "      KASIR FISH v1.1.0       "
    echo "     github.com/ricoyp96   "
    echo "=============================="
    echo "Perintah:"
    echo "  selesai = selesai input, lanjut bayar"
    echo "  batal   = batalin barang / transaksi"
    echo "=============================="
    echo ""

    set -l keranjang_nama
    set -l keranjang_harga
    set -l keranjang_jumlah
    set -l total 0

    while true
        read -P "Nama Barang : " nama

        if test "$nama" = "selesai"
            break
        end

        if test "$nama" = "batal"
            echo ""
            echo "Transaksi dibatalkan. Tidak ada struk yang disimpan."
            echo "Tekan Enter untuk balik ke menu..."
            read
            return
        end

        if test -z "$nama"
            echo "Nama gak boleh kosong!"
            continue
        end

        input_angka "Harga Barang : " "float" 7
        set harga $hasil_input
        if test "$harga" = "__BATAL__"
            echo "Batal input '$nama', barang tidak ditambahkan."
            echo ""
            continue
        end

        input_angka "Jumlah : " "int" 3
        set jumlah $hasil_input
        if test "$jumlah" = "__BATAL__"
            echo "Batal input '$nama', barang tidak ditambahkan."
            echo ""
            continue
        end

        set -a keranjang_nama "$nama"
        set -a keranjang_harga $harga
        set -a keranjang_jumlah $jumlah

        set subtotal (math "$harga * $jumlah")
        set total (math "$total + $subtotal")

        echo "Ditambahkan: $nama x $jumlah = Rp $subtotal"
        echo "Total sementara: Rp $total"
        echo ""
    end

    if test (count $keranjang_nama) -eq 0
        echo "Tidak ada barang, transaksi dibatalkan."
        echo "Tekan Enter untuk balik..."
        read
        return
    end

    echo ""
    echo "---------- STRUK ----------"
    for i in (seq (count $keranjang_nama))
        set sub (math "$keranjang_harga[$i] * $keranjang_jumlah[$i]")
        echo "$keranjang_nama[$i] x $keranjang_jumlah[$i] = Rp $sub"
    end
    echo "---------------------------"
    echo "TOTAL: Rp $total"
    echo ""

    while true
        input_angka "Uang Bayar : " "float" 7
        set bayar $hasil_input
        if test "$bayar" = "__BATAL__"
            echo "Pembayaran dibatalkan. Transaksi tidak disimpan."
            echo "Tekan Enter untuk balik..."
            read
            return
        end

        if test $bayar -lt $total
            echo "Uang kurang Rp "(math "$total - $bayar")
            continue
        end
        break
    end

    set kembalian (math "$bayar - $total")
    echo "Kembalian: Rp $kembalian"
    echo ""

    mkdir -p $HOME/storage/shared/struk
    set nomor_struk (date +%d-%m-%Y_%H%M%S)
    set tanggal (date +%d-%m-%Y)
    set jam (date "+%H:%M:%S")
    set nama_file $HOME/storage/shared/struk/struk-$nomor_struk.txt
    
    # --- INI KHUSUS FILE TXT ---
    echo "========================================" > $nama_file
    echo "          $nama_toko" >> $nama_file
    echo "      $alamat_toko" >> $nama_file
    echo "            Telp: $telp_toko" >> $nama_file
    echo "========================================" >> $nama_file
    echo "No Struk : STR-$nomor_struk" >> $nama_file
    echo "Tanggal  : "$tanggal >> $nama_file
    echo "Jam          : $jam" >> $nama_file
    echo "Kasir       : $nama_kasir" >> $nama_file
    echo "--------------------------------------------------------------------------" >> $nama_file
    printf "%-3s %-14s %-4s %-7s %s\n" "No" "Barang" "Jml" "Harga" "Subtotal" >> $nama_file
    echo "--------------------------------------------------------------------------" >> $nama_file

    set -l total_item 0
    for i in (seq (count $keranjang_nama))
        set sub (math "$keranjang_harga[$i] * $keranjang_jumlah[$i]")
        set total_item (math "$total_item + $keranjang_jumlah[$i]")
        printf "%-3s %-14s %-4s %-7s %s\n" $i $keranjang_nama[$i] $keranjang_jumlah[$i] $keranjang_harga[$i] $sub >> $nama_file
    end

    echo "--------------------------------------------------------------------------" >> $nama_file
    echo "Jumlah Item   : $total_item" >> $nama_file
    echo "TOTAL              : Rp $total" >> $nama_file
    echo "BAYAR              : Rp $bayar" >> $nama_file
    echo "KEMBALI        : Rp $kembalian" >> $nama_file
    echo "========================================" >> $nama_file
    echo "        *** TERIMA KASIH ***" >> $nama_file
    echo "   Barang yang sudah dibeli" >> $nama_file
    echo "   tidak dapat ditukar / kembali" >> $nama_file
    echo "========================================" >> $nama_file

    echo "Struk tersimpan: $nama_file"
    echo "Tekan Enter untuk balik ke menu..."
    read
end

while true
    clear
    echo "=============================="
    echo "      KASIR FISH v1.0.1       "
    echo "     github.com/ricoyp96   "
    echo "=============================="
    echo "Toko: $nama_toko"
    echo "Kasir: $nama_kasir"
    echo "=============================="
    echo "1. Transaksi Baru"
    echo "2. Pengaturan Toko"
    echo "3. Keluar"
    echo "=============================="
    read -P "Pilih [1-3]: " pilih

    switch $pilih
        case 1
            kasir
        case 2
            pengaturan_toko
        case 3
            echo "Terima kasih! Sampai jumpa."
            break
        case '*'
            echo "Pilihan gak valid!"
            sleep 1
    end
end
