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

## Screenshot
<img width="720" height="702" alt="12627" src="https://github.com/user-attachments/assets/5571d8ce-66ae-4beb-aea6-56e9f2082e9f" />
<img width="720" height="625" alt="12628" src="https://github.com/user-attachments/assets/45fafa66-d5f3-487f-ba14-1cdec603dbab" />
<img width="720" height="1612" alt="12630" src="https://github.com/user-attachments/assets/0d89e973-bf14-4b38-be25-33a16fd738df" />
<img width="720" height="1612" alt="12631" src="https://github.com/user-attachments/assets/d5f82c45-c41e-4370-9e44-ae5f1c8baf43" />
