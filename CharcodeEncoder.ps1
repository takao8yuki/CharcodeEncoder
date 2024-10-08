# �{�t�@�C����Shift-JIS�ŕۑ����Ă��������B
# �G���R�[�f�B���O�����p�̃N���X��`
class StringEncoder {
    <#
    .SYNOPSIS
    ������̃G���R�[�f�B���O�ƃf�R�[�f�B���O���s���N���X

    .DESCRIPTION
    ���̃N���X�́A�w�肳�ꂽ�G���R�[�f�B���O���g�p���ĕ�����̃G���R�[�h�A�f�R�[�h�A
    ����уR�[�h�|�C���g�̕\�����s���܂��B�G���R�[�f�B���O�G���[��K�؂ɏ������A
    �f�o�b�O����񋟂��܂��B

    .PARAMETER encodingName
    �g�p����G���R�[�f�B���O�̖��O�i��Futf-8, us-ascii�j
    #>

    [System.Text.Encoding] $Encoding

    # �R���X�g���N�^�ŃG���R�[�f�B���O�����󂯎��
    StringEncoder([string]$encodingName) {
        try {
            # �w�肳�ꂽ�G���R�[�f�B���O�����g�p����Encoding�I�u�W�F�N�g���쐬
            # EncoderExceptionFallback��DecoderExceptionFallback���g�p���āA
            # �G���R�[�h/�f�R�[�h�G���[���ɗ�O�𔭐�������
            $this.Encoding = [System.Text.Encoding]::GetEncoding(
                $encodingName,
                [System.Text.EncoderExceptionFallback]::new(),
                [System.Text.DecoderExceptionFallback]::new()
            )
            # �ݒ肳�ꂽ�G���R�[�f�B���O��\��
            Write-Host "�G���R�[�f�B���O��ݒ肵�܂���: $encodingName"
        } catch {
            # �G���R�[�f�B���O��������Ȃ��ꍇ�̓G���[���b�Z�[�W��\�����ė�O���X���[
            Write-Host "�G���[: �w�肳�ꂽ�G���R�[�f�B���O��������܂���: $encodingName"
            throw
        }
    }

    <#
    .SYNOPSIS
    ���͕�����̃R�[�h�|�C���g��\�����܂��B

    .DESCRIPTION
    �e������Unicode�R�[�h�|�C���g��16�i���ŕ\�����܂��B

    .PARAMETER inputString
    �R�[�h�|�C���g��\������Ώۂ̕�����
    #>
    [void] ShowCodePoints([string]$inputString) {
        # ���͕������\��
        Write-Host "���͕�����: $inputString"
        # ������̊e�����ɑ΂��ă��[�v
        foreach ($ch in $inputString.ToCharArray()) {
            # ������Unicode �R�[�h�|�C���g�i16�i���j�ɕϊ�
            $codePoint = [Convert]::ToUInt16($ch)
            # �R�[�h�|�C���g��16�i���ŕ\���i4���ɐ��`�j
            Write-Host ("{0:X4}" -f $codePoint) -NoNewline
            Write-Host " "
        }
        Write-Host ""
    }

    <#
    .SYNOPSIS
    ��������o�C�g�z��ɃG���R�[�h���܂��B

    .DESCRIPTION
    �w�肳�ꂽ�G���R�[�f�B���O���g�p���ĕ�������o�C�g�z��ɕϊ����A
    �G���R�[�h���ꂽ�o�C�g��16�i���ŕ\�����܂��B
    �G���R�[�h�ł��Ȃ�����������ꍇ�͗�O���L���b�`���ď���\�����܂��B

    .PARAMETER inputString
    �G���R�[�h���镶����

    .RETURNS
    �G���R�[�h���ꂽ�o�C�g�z��
    #>
    [byte[]] EncodeString([string]$inputString) {
        try {
            # ��������o�C�g�z��ɃG���R�[�h
            $bytes = $this.Encoding.GetBytes($inputString)
            # �G���R�[�h���ꂽ�o�C�g��16�i���ŕ\��
            Write-Host "�G���R�[�h���ꂽ�o�C�g: " -NoNewline
            foreach ($byt in $bytes) {
                # �o�C�g��16�i���ŕ\���i2���ɐ��`�j
                Write-Host ("{0:X2}" -f $byt) -NoNewline
                Write-Host " "
            }
            Write-Host ""
            return $bytes
        } catch [System.Text.EncoderFallbackException] {
            # �G���R�[�h�ł��Ȃ�����������ꍇ�A���̕����ƈʒu��\��
            Write-Host "��O: ���� 0x{0:X4} ���C���f�b�N�X {1} �ŃG���R�[�h�ł��܂���" -f `
                [Convert]::ToUInt16($_.CharUnknown), $_.Index
            return @() # ��̃o�C�g�z���Ԃ�
        }
    }

    <#
    .SYNOPSIS
    �o�C�g�z��𕶎���Ƀf�R�[�h���܂��B

    .DESCRIPTION
    �w�肳�ꂽ�G���R�[�f�B���O���g�p���ăo�C�g�z��𕶎���ɕϊ����A
    ���̕�����ƈ�v���邩�ǂ������m�F���܂��B
    ��v���Ȃ��ꍇ�́A�f�R�[�h���ꂽ������Ƃ��̃R�[�h�|�C���g��\�����܂��B
    �f�R�[�h�ł��Ȃ��o�C�g������ꍇ�͗�O���L���b�`���ď���\�����܂��B

    .PARAMETER bytes
    �f�R�[�h����o�C�g�z��

    .PARAMETER originalString
    ���̕�����i��r�p�j
    #>
    [void] DecodeBytes([byte[]]$bytes, [string]$originalString) {
        try {
            # �o�C�g�z��𕶎���Ƀf�R�[�h
            $decodedString = $this.Encoding.GetString($bytes)
            # ���̕�����ƈ�v���邩�`�F�b�N
            Write-Host "���E���h�g���b�v����: {0}" -f ($originalString -eq $decodedString)
            if ($originalString -ne $decodedString) {
                # ��v���Ȃ��ꍇ�A�f�R�[�h���ꂽ������Ƃ��̃R�[�h�|�C���g��\��
                Write-Host "�f�R�[�h���ꂽ������: $decodedString"
                foreach ($ch in $decodedString.ToCharArray()) {
                    $codePoint = [Convert]::ToUInt16($ch)
                    Write-Host ("{0:X4}" -f $codePoint) -NoNewline
                    Write-Host " "
                }
                Write-Host ""
            }
        } catch [System.Text.DecoderFallbackException] {
            # �f�R�[�h�ł��Ȃ��o�C�g������ꍇ�A���̃o�C�g�ƈʒu��\��
            Write-Host "�C���f�b�N�X {0} �̃o�C�g���f�R�[�h�ł��܂���" -f $_.Index
            foreach ($unknownByte in $_.BytesUnknown) {
                Write-Host "0x{0:X2} " -f $unknownByte
            }
        }
    }

    <#
    .SYNOPSIS
    �o�C�g�z�񂪗L���ȕ����񂩂ǂ����𔻕ʂ��܂��B

    .DESCRIPTION
    �w�肳�ꂽ�G���R�[�f�B���O���g�p���ăo�C�g�z����f�R�[�h���A
    �f�R�[�h���������邩�ǂ����ŕ����񂩂ǂ����𔻒f���܂��B

    .PARAMETER bytes
    ���ʂ���o�C�g�z��

    .RETURNS
    �o�C�g�z�񂪗L���ȕ�����̏ꍇ��True�A�����łȂ��ꍇ��False
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
    �o�C�g�z�񂩂�BOM���g�p���ĕ����R�[�h�𔻕ʂ��܂��B

    .DESCRIPTION
    �o�C�g�z��̐擪�ɂ���BOM�iByte Order Mark�j���m�F���A
    �Ή����镶���R�[�h��Ԃ��܂��BBOM���Ȃ��ꍇ��null��Ԃ��܂��B

    .PARAMETER bytes
    ���ʂ���o�C�g�z��

    .RETURNS
    ���ʂ��ꂽ�����R�[�h�iUTF-8, UTF-16LE, UTF-16BE, UTF-32LE, UTF-32BE�j�܂���null
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
    ��������w�肳�ꂽ�����R�[�h����ʂ̕����R�[�h�ɕϊ����܂��B

    .DESCRIPTION
    ���͕���������̕����R�[�h�Ńf�R�[�h���A�V���������R�[�h�ŃG���R�[�h���܂��B

    .PARAMETER inputString
    �ϊ����镶����

    .PARAMETER sourceEncoding
    ���̕����R�[�h��

    .PARAMETER targetEncoding
    �ϊ���̕����R�[�h��

    .RETURNS
    �ϊ����ꂽ������
    #>
    [string] ConvertEncoding([string]$inputString, [string]$sourceEncoding, [string]$targetEncoding) {
        try {
            $sourceEnc = [System.Text.Encoding]::GetEncoding($sourceEncoding)
            $targetEnc = [System.Text.Encoding]::GetEncoding($targetEncoding)
            
            $bytes = $sourceEnc.GetBytes($inputString)
            $convertedString = $targetEnc.GetString($bytes)
            
            Write-Host "�����R�[�h��ϊ����܂���: $sourceEncoding -> $targetEncoding"
            return $convertedString
        } catch {
            Write-Host "�G���[: �����R�[�h�̕ϊ��Ɏ��s���܂����B"
            Write-Host $_.Exception.Message
            return $null
        }
    }
}

# �g�p��
# �G���R�[�f�B���O���w�肵��StringEncoder�I�u�W�F�N�g���쐬
# "utf-8", "us-ascii" �ȂǔC�ӂ̃G���R�[�f�B���O��ݒ�ł���
$encodingName = "utf-8"
$encoder = [StringEncoder]::new($encodingName)

# �e�X�g�p�̕�����i���ꕶ�����܂ށj
$string = "`u24C8 `u2075 `u221E"

# ������̃R�[�h�|�C���g��\��
$encoder.ShowCodePoints($string)

# ��������G���R�[�h
$encodedBytes = $encoder.EncodeString($string)

# �G���R�[�h���ꂽ�o�C�g�z����f�R�[�h���Č��̕�����ɖ߂�
$encoder.DecodeBytes($encodedBytes, $string)

# �o�C�g�z�񂪗L���ȕ����񂩂ǂ����𔻕�
$testBytes = [System.Text.Encoding]::UTF8.GetBytes("����ɂ���")
$isValid = $encoder.IsValidString($testBytes)
Write-Host "�o�C�g�z��͗L���ȕ�����ł����H: $isValid"

# BOM���當���R�[�h�𔻕�
$bomBytes = [byte[]](0xEF, 0xBB, 0xBF) + $testBytes
$detectedEncoding = $encoder.DetectEncodingFromBOM($bomBytes)
Write-Host "���o���ꂽ�����R�[�h: $detectedEncoding"

# �����R�[�h�̕ϊ�
$originalString = "����ɂ��́A���E�I"
$convertedString = $encoder.ConvertEncoding($originalString, "utf-8", "shift-jis")
Write-Host "�ϊ���̕�����: $convertedString"