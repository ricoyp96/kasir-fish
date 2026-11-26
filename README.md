# Kasir Fish

Program kasir sederhana pake fish shell untuk Termux.
Bisa hitung total belanja, cetak struk, dan nyimpen struk otomatis.

## Fitur
- Input nama barang, harga, dan jumlah
- Hitung total otomatis
- Cetak struk ke layar
- Simpan struk otomatis ke folder `struk/`

## 1. Install fish dan git (Termux)

```bash
pkg update && pkg upgrade
pkg install fish git
```
cek udah ke-install apa belum:
```bash
fish --version
git --version
```

## 2. Download program ini

Pake git clone biar gampang update:
```bash
git clone https://github.com/ricoyp96/kasir-fish.git
```

## 3. Jalanin programnya

```bash
cd ~/kasir-fish
fish src/kasir.fish
```

## 4. Cara pakai

1. Masukkan nama barang
2. Masukkan harga barang
3. Masukkan jumlah barang
4. Ketik `selesai` kalau sudah selesai input
5. Struk bakal muncul dan tersimpan di folder struk

## 5. Cara update

```bash
cd ~/kasir-fish
git pull
```
