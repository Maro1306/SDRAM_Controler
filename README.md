## SDRAMコントローラ

DE0-CVのSDRAMコントローラをつくる  
タイミングチャート作成には[タイミングチャート清書サービス](http://dora.bk.tsukuba.ac.jp/~takeuchi/?%E3%82%BD%E3%83%95%E3%83%88%E3%82%A6%E3%82%A7%E3%82%A2%2F%E3%82%BF%E3%82%A4%E3%83%9F%E3%83%B3%E3%82%B0%E3%83%81%E3%83%A3%E3%83%BC%E3%83%88%E6%B8%85%E6%9B%B8%E3%82%B5%E3%83%BC%E3%83%93%E3%82%B9)を使用しました

### DE0-CVのSDRAM

```
型番      IS42S16320D
容量      64MB=512Mb(32M*16)
データ幅  16bit
ROW       8K(A0-A12)
COLUMN    1K(A0-A9)
バンク数  4
REF間隔   64ms(≒8533333クロック)以内に8K(8192)回
周波数    133MHz(1クロック7.5ns)
```

### 状態遷移

![state](https://github.com/Maro1306/sdram_ctr/blob/master/statement.png?raw=true)

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
処理開始からアイドル状態に戻るまで **8クロック**

<img src="https://github.com/Maro1306/sdram_ctr/blob/master/read.png?raw=true">
<img src="https://github.com/Maro1306/sdram_ctr/blob/master/timing-read.png?raw=true">

### 書込み処理

AP付WRITEコマンドを使用しているためプリチャージは自動で行われる  
処理開始からアイドル状態に戻るまで **7クロック**

<img src="https://github.com/Maro1306/sdram_ctr/blob/master/write.png?raw=true">
<img src="https://github.com/Maro1306/sdram_ctr/blob/master/timing-write.png?raw=true">

### リフレッシュ処理

![ref](https://github.com/Maro1306/sdram_ctr/blob/master/refresh.png?raw=true)

#### リフレッシュ間隔
