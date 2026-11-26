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

function kasir
    clear
    echo "=============================="
    echo "      KASIR FISH v1.0.1       "
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
    set tanggal (date +%d-%m-%Y_%H%M%S)
    set nama_file $HOME/storage/shared/struk/struk_$tanggal.txt
    
    # --- INI KHUSUS FILE TXT ---
    echo "========================================" > $nama_file
    echo "          TOKO BARANG DAN JASA" >> $nama_file
    echo "      Jalan Kenangan Lama Kota Baru" >> $nama_file
    echo "========================================" >> $nama_file
    echo "No Struk : STR-$tanggal" >> $nama_file
    echo "Tanggal  : "$tanggal >> $nama_file
    echo "Kasir    : fish shell" >> $nama_file
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
    echo "Total Item         : $total_item" >> $nama_file
    echo "TOTAL              : Rp $total" >> $nama_file
    echo "BAYAR              : Rp $bayar" >> $nama_file
    echo "KEMBALI            : Rp $kembalian" >> $nama_file
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
    echo "1. Transaksi Baru"
    echo "2. Keluar"
    echo "=============================="
    read -P "Pilih [1-2]: " pilih

    switch $pilih
        case 1
            kasir
        case 2
            echo "Terima kasih! Sampai jumpa."
            break
        case '*'
            echo "Pilihan gak valid!"
            sleep 1
    end
end