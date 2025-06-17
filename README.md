# clickpost-prepare

クリックポストで作成したPDFを封筒に直接印刷しやすい形に加工するシェルスクリプトです。

## 概要

- クリックポストPDFを4分割（2×2）  
- ページを180度回転（オプションでON/OFF可能）  
- 空白のページを自動で除去  

## 依存ツールのインストール（macOS）

```bash
brew install mupdf-tools qpdf poppler
```

## 使い方

```bash
./clickpost-prepare.sh [-r] input.pdf
```

- `input.pdf` : 処理したいクリックポストのPDFファイルパス（必須）  
- `-r`        : ページを180度回転させたい場合に指定（任意）  

### 例

回転ありで処理

```bash
./clickpost-prepare.sh -r clickpost-label.pdf
```

回転なしで処理
```bash
./clickpost-prepare.sh clickpost-label.pdf
```
