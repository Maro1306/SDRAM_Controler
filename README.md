## SDRAMコントローラ

DE0-CVのSDRAMコントローラをつくる

### DE0-CVのSDRAM

```
型番      IS42S16320D
容量      64MB=512Mb(32M\*16)
データ幅  16bit
ROW       8K(A0A12)
COLUMN    1K(A0A9)
バンク数  4
REF間隔   64ms以内に8K(8192)回
周波数    133MHz(1クロック7.5ns)
```

### 初期化処理

初期化処理終了後アイドル状態に遷移&リフレッシュカウンタ開始  
モードレジスタの設定はとりあえず以下の通り  

```
A0-A2(バースト長)      1(000)
A3(ラップタイプ)       シーケンシャル(0)
A4-A6(/CASレーテンシ)  2(010)
A7-A12(オプション)     なし(000000)
```

![init](https://github.com/Maro1306/sdram_ctr/blob/master/initialize.png?raw=true)

### 読込み処理

AP付READコマンドを使用しているためプリチャージは自動で行われる

![read](https://github.com/Maro1306/sdram_ctr/blob/master/read.png?raw=true)

