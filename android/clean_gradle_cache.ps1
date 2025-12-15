# Script PowerShell pour nettoyer le cache Gradle corrompu
# Exécutez ce script si vous rencontrez des erreurs de timeout Gradle

Write-Host "Nettoyage du cache Gradle..." -ForegroundColor Yellow

# Chemin du cache Gradle
$gradleCachePath = "$env:USERPROFILE\.gradle\wrapper\dists\gradle-8.7-all"

# Arrêter tous les processus Gradle/Java en cours
Write-Host "`nArrêt des processus Gradle/Java en cours..." -ForegroundColor Cyan
Get-Process | Where-Object {$_.ProcessName -like '*gradle*' -or ($_.ProcessName -like '*java*' -and $_.MainWindowTitle -like '*gradle*')} | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

# Supprimer le cache Gradle 8.7
if (Test-Path $gradleCachePath) {
    Write-Host "`nSuppression du cache Gradle 8.7..." -ForegroundColor Cyan
    try {
        Remove-Item -Path $gradleCachePath -Recurse -Force
        Write-Host "Cache supprimé avec succès!" -ForegroundColor Green
    } catch {
        Write-Host "Erreur lors de la suppression: $_" -ForegroundColor Red
        Write-Host "Essayez de fermer tous les IDE et processus Java, puis réessayez." -ForegroundColor Yellow
    }
} else {
    Write-Host "`nCache Gradle 8.7 non trouvé." -ForegroundColor Green
}

# Nettoyer aussi le cache de build local
$buildCachePath = ".\build"
if (Test-Path $buildCachePath) {
    Write-Host "`nSuppression du cache de build local..." -ForegroundColor Cyan
    Remove-Item -Path $buildCachePath -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "Cache de build supprimé!" -ForegroundColor Green
}

Write-Host "`nNettoyage terminé!" -ForegroundColor Green
Write-Host "Vous pouvez maintenant relancer: flutter clean && flutter pub get && flutter run" -ForegroundColor Cyan

