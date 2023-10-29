# 設定要被替換的原始字串
$OrigStr = "yjring"

# 讀取 env.yaml，並存入相應變數
$envContent = Get-Content -Path env.yaml
$DOCKER_ACCOUNT = $envContent | Select-String "dockerAccount:\s*([\S]+)" | ForEach-Object { $_.Matches.Groups[1].Value }
$OS_ARCH = $envContent | Select-String "os:\s*([\S]+)" | ForEach-Object { $_.Matches.Groups[1].Value }

switch ($OS_ARCH) {
    {"arm", "arm64"} {
        $PLATFORMS = "linux/arm64"
    }
    {"amd", "amd64"} {
        $PLATFORMS = "linux/amd64"
    }
    default {
        $PLATFORMS = "linux/amd64,linux/arm64"
    }
}

# 進入到 .github/workflows/
Set-Location -Path .\.github\workflows\

# 列出要處理的檔案
$files = "1_dev_backend_ci.yaml", "2_dev_frontend_ci.yaml", "4_uat_backend_ci.yaml", "5_uat_frontend_ci.yaml"

# 更換Github Action中的 image檔案名稱
foreach ($file in $files) {
    $fileContent = Get-Content -Path $file
    $fileContent = $fileContent -replace "IMAGE_NAME: $OrigStr", "IMAGE_NAME: $DOCKER_ACCOUNT"
    $fileContent = $fileContent -replace "platforms:.*", "platforms: $PLATFORMS"
    Set-Content -Path $file -Value $fileContent
    Write-Output "Modified: $file"
}