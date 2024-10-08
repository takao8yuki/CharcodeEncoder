# 本ファイルはShift-JISで保存してください。
# エンコーディング処理用のクラス定義
class StringEncoder {
    <#
    .SYNOPSIS
    文字列のエンコーディングとデコーディングを行うクラス

    .DESCRIPTION
    このクラスは、指定されたエンコーディングを使用して文字列のエンコード、デコード、
    およびコードポイントの表示を行います。エンコーディングエラーを適切に処理し、
    デバッグ情報を提供します。

    .PARAMETER encodingName
    使用するエンコーディングの名前（例：utf-8, us-ascii）
    #>

    [System.Text.Encoding] $Encoding

    # コンストラクタでエンコーディング名を受け取る
    StringEncoder([string]$encodingName) {
        try {
            # 指定されたエンコーディング名を使用してEncodingオブジェクトを作成
            # EncoderExceptionFallbackとDecoderExceptionFallbackを使用して、
            # エンコード/デコードエラー時に例外を発生させる
            $this.Encoding = [System.Text.Encoding]::GetEncoding(
                $encodingName,
                [System.Text.EncoderExceptionFallback]::new(),
                [System.Text.DecoderExceptionFallback]::new()
            )
            # 設定されたエンコーディングを表示
            Write-Host "エンコーディングを設定しました: $encodingName"
        } catch {
            # エンコーディングが見つからない場合はエラーメッセージを表示して例外をスロー
            Write-Host "エラー: 指定されたエンコーディングが見つかりません: $encodingName"
            throw
        }
    }

    <#
    .SYNOPSIS
    入力文字列のコードポイントを表示します。

    .DESCRIPTION
    各文字のUnicodeコードポイントを16進数で表示します。

    .PARAMETER inputString
    コードポイントを表示する対象の文字列
    #>
    [void] ShowCodePoints([string]$inputString) {
        # 入力文字列を表示
        Write-Host "入力文字列: $inputString"
        # 文字列の各文字に対してループ
        foreach ($ch in $inputString.ToCharArray()) {
            # 文字をUnicode コードポイント（16進数）に変換
            $codePoint = [Convert]::ToUInt16($ch)
            # コードポイントを16進数で表示（4桁に整形）
            Write-Host ("{0:X4}" -f $codePoint) -NoNewline
            Write-Host " "
        }
        Write-Host ""
    }

    <#
    .SYNOPSIS
    文字列をバイト配列にエンコードします。

    .DESCRIPTION
    指定されたエンコーディングを使用して文字列をバイト配列に変換し、
    エンコードされたバイトを16進数で表示します。
    エンコードできない文字がある場合は例外をキャッチして情報を表示します。

    .PARAMETER inputString
    エンコードする文字列

    .RETURNS
    エンコードされたバイト配列
    #>
    [byte[]] EncodeString([string]$inputString) {
        try {
            # 文字列をバイト配列にエンコード
            $bytes = $this.Encoding.GetBytes($inputString)
            # エンコードされたバイトを16進数で表示
            Write-Host "エンコードされたバイト: " -NoNewline
            foreach ($byt in $bytes) {
                # バイトを16進数で表示（2桁に整形）
                Write-Host ("{0:X2}" -f $byt) -NoNewline
                Write-Host " "
            }
            Write-Host ""
            return $bytes
        } catch [System.Text.EncoderFallbackException] {
            # エンコードできない文字がある場合、その文字と位置を表示
            Write-Host "例外: 文字 0x{0:X4} をインデックス {1} でエンコードできません" -f `
                [Convert]::ToUInt16($_.CharUnknown), $_.Index
            return @() # 空のバイト配列を返す
        }
    }

    <#
    .SYNOPSIS
    バイト配列を文字列にデコードします。

    .DESCRIPTION
    指定されたエンコーディングを使用してバイト配列を文字列に変換し、
    元の文字列と一致するかどうかを確認します。
    一致しない場合は、デコードされた文字列とそのコードポイントを表示します。
    デコードできないバイトがある場合は例外をキャッチして情報を表示します。

    .PARAMETER bytes
    デコードするバイト配列

    .PARAMETER originalString
    元の文字列（比較用）
    #>
    [void] DecodeBytes([byte[]]$bytes, [string]$originalString) {
        try {
            # バイト配列を文字列にデコード
            $decodedString = $this.Encoding.GetString($bytes)
            # 元の文字列と一致するかチェック
            Write-Host "ラウンドトリップ成功: {0}" -f ($originalString -eq $decodedString)
            if ($originalString -ne $decodedString) {
                # 一致しない場合、デコードされた文字列とそのコードポイントを表示
                Write-Host "デコードされた文字列: $decodedString"
                foreach ($ch in $decodedString.ToCharArray()) {
                    $codePoint = [Convert]::ToUInt16($ch)
                    Write-Host ("{0:X4}" -f $codePoint) -NoNewline
                    Write-Host " "
                }
                Write-Host ""
            }
        } catch [System.Text.DecoderFallbackException] {
            # デコードできないバイトがある場合、そのバイトと位置を表示
            Write-Host "インデックス {0} のバイトをデコードできません" -f $_.Index
            foreach ($unknownByte in $_.BytesUnknown) {
                Write-Host "0x{0:X2} " -f $unknownByte
            }
        }
    }

    <#
    .SYNOPSIS
    バイト配列が有効な文字列かどうかを判別します。

    .DESCRIPTION
    指定されたエンコーディングを使用してバイト配列をデコードし、
    デコードが成功するかどうかで文字列かどうかを判断します。

    .PARAMETER bytes
    判別するバイト配列

    .RETURNS
    バイト配列が有効な文字列の場合はTrue、そうでない場合はFalse
    #>
    [bool] IsValidString([byte[]]$bytes) {
        try {
            $this.Encoding.GetString($bytes) | Out-Null
            return $true
        } catch {
            return $false
        }
    }

    <#
    .SYNOPSIS
    バイト配列からBOMを使用して文字コードを判別します。

    .DESCRIPTION
    バイト配列の先頭にあるBOM（Byte Order Mark）を確認し、
    対応する文字コードを返します。BOMがない場合はnullを返します。

    .PARAMETER bytes
    判別するバイト配列

    .RETURNS
    判別された文字コード（UTF-8, UTF-16LE, UTF-16BE, UTF-32LE, UTF-32BE）またはnull
    #>
    [string] DetectEncodingFromBOM([byte[]]$bytes) {
        if ($bytes.Length -ge 4) {
            if ($bytes[0] -eq 0x00 -and $bytes[1] -eq 0x00 -and $bytes[2] -eq 0xFE -and $bytes[3] -eq 0xFF) { return "UTF-32BE" }
            if ($bytes[0] -eq 0xFF -and $bytes[1] -eq 0xFE -and $bytes[2] -eq 0x00 -and $bytes[3] -eq 0x00) { return "UTF-32LE" }
        }
        if ($bytes.Length -ge 3) {
            if ($bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) { return "UTF-8" }
        }
        if ($bytes.Length -ge 2) {
            if ($bytes[0] -eq 0xFE -and $bytes[1] -eq 0xFF) { return "UTF-16BE" }
            if ($bytes[0] -eq 0xFF -and $bytes[1] -eq 0xFE) { return "UTF-16LE" }
        }
        return $null
    }

    <#
    .SYNOPSIS
    文字列を指定された文字コードから別の文字コードに変換します。

    .DESCRIPTION
    入力文字列を元の文字コードでデコードし、新しい文字コードでエンコードします。

    .PARAMETER inputString
    変換する文字列

    .PARAMETER sourceEncoding
    元の文字コード名

    .PARAMETER targetEncoding
    変換先の文字コード名

    .RETURNS
    変換された文字列
    #>
    [string] ConvertEncoding([string]$inputString, [string]$sourceEncoding, [string]$targetEncoding) {
        try {
            $sourceEnc = [System.Text.Encoding]::GetEncoding($sourceEncoding)
            $targetEnc = [System.Text.Encoding]::GetEncoding($targetEncoding)
            
            $bytes = $sourceEnc.GetBytes($inputString)
            $convertedString = $targetEnc.GetString($bytes)
            
            Write-Host "文字コードを変換しました: $sourceEncoding -> $targetEncoding"
            return $convertedString
        } catch {
            Write-Host "エラー: 文字コードの変換に失敗しました。"
            Write-Host $_.Exception.Message
            return $null
        }
    }
}

# 使用例
# エンコーディングを指定してStringEncoderオブジェクトを作成
# "utf-8", "us-ascii" など任意のエンコーディングを設定できる
$encodingName = "utf-8"
$encoder = [StringEncoder]::new($encodingName)

# テスト用の文字列（特殊文字を含む）
$string = "`u24C8 `u2075 `u221E"

# 文字列のコードポイントを表示
$encoder.ShowCodePoints($string)

# 文字列をエンコード
$encodedBytes = $encoder.EncodeString($string)

# エンコードされたバイト配列をデコードして元の文字列に戻す
$encoder.DecodeBytes($encodedBytes, $string)

# バイト配列が有効な文字列かどうかを判別
$testBytes = [System.Text.Encoding]::UTF8.GetBytes("こんにちは")
$isValid = $encoder.IsValidString($testBytes)
Write-Host "バイト配列は有効な文字列ですか？: $isValid"

# BOMから文字コードを判別
$bomBytes = [byte[]](0xEF, 0xBB, 0xBF) + $testBytes
$detectedEncoding = $encoder.DetectEncodingFromBOM($bomBytes)
Write-Host "検出された文字コード: $detectedEncoding"

# 文字コードの変換
$originalString = "こんにちは、世界！"
$convertedString = $encoder.ConvertEncoding($originalString, "utf-8", "shift-jis")
Write-Host "変換後の文字列: $convertedString"