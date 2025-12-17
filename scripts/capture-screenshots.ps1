# Screenshot Helper Script for Submission
# This script helps you capture all required screenshots for the final exam

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Screenshot Helper - Final Exam Submission" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

$screenshotDir = "screenshots"
if (!(Test-Path $screenshotDir)) {
    New-Item -ItemType Directory -Path $screenshotDir
    Write-Host "[INFO] Created screenshots directory" -ForegroundColor Green
}

Write-Host "This script will help you capture all required screenshots." -ForegroundColor Yellow
Write-Host "Please take screenshots manually and save them to the 'screenshots' folder." -ForegroundColor Yellow
Write-Host ""

# Section A - Docker
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "SECTION A: DOCKER SCREENSHOTS" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Docker Containers Running" -ForegroundColor Yellow
Write-Host "   Run this command and take a screenshot:" -ForegroundColor White
Write-Host "   docker ps" -ForegroundColor Green
Write-Host "   Save as: screenshots/section-a-docker-ps.png" -ForegroundColor Gray
Write-Host ""
Read-Host "Press Enter when screenshot is captured"

Write-Host ""
Write-Host "2. Docker Compose Services" -ForegroundColor Yellow
Write-Host "   Run this command and take a screenshot:" -ForegroundColor White
Write-Host "   docker-compose ps" -ForegroundColor Green
Write-Host "   Save as: screenshots/section-a-docker-compose-ps.png" -ForegroundColor Gray
Write-Host ""
Read-Host "Press Enter when screenshot is captured"

# Section B - CI/CD
Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "SECTION B: CI/CD SCREENSHOTS" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "3. GitHub Actions Workflow File" -ForegroundColor Yellow
Write-Host "   Open .github/workflows/ci-cd.yml in your editor and take a screenshot" -ForegroundColor White
Write-Host "   Save as: screenshots/section-b-workflow-file.png" -ForegroundColor Gray
Write-Host ""
Read-Host "Press Enter when screenshot is captured"

Write-Host ""
Write-Host "4. Pipeline Run - All Stages Completed" -ForegroundColor Yellow
Write-Host "   Go to GitHub repository → Actions tab" -ForegroundColor White
Write-Host "   Take a screenshot showing all stages completed (green checkmarks)" -ForegroundColor White
Write-Host "   Save as: screenshots/section-b-pipeline-success.png" -ForegroundColor Gray
Write-Host ""
Read-Host "Press Enter when screenshot is captured"

Write-Host ""
Write-Host "5. Docker Hub - Pushed Images" -ForegroundColor Yellow
Write-Host "   Go to Docker Hub → Your repositories" -ForegroundColor White
Write-Host "   Take a screenshot showing todo-backend and todo-frontend images" -ForegroundColor White
Write-Host "   Save as: screenshots/section-b-dockerhub-images.png" -ForegroundColor Gray
Write-Host ""
Read-Host "Press Enter when screenshot is captured"

# Section C - Kubernetes
Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "SECTION C: KUBERNETES SCREENSHOTS" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "6. Kubernetes Pods Running" -ForegroundColor Yellow
Write-Host "   Run this command and take a screenshot:" -ForegroundColor White
Write-Host "   kubectl get pods -n todo-app" -ForegroundColor Green
Write-Host "   Save as: screenshots/section-c-pods-running.png" -ForegroundColor Gray
Write-Host ""
Read-Host "Press Enter when screenshot is captured"

Write-Host ""
Write-Host "7. Kubernetes Services with External IPs" -ForegroundColor Yellow
Write-Host "   Run this command and take a screenshot:" -ForegroundColor White
Write-Host "   kubectl get svc -n todo-app" -ForegroundColor Green
Write-Host "   Save as: screenshots/section-c-services.png" -ForegroundColor Gray
Write-Host ""
Read-Host "Press Enter when screenshot is captured"

Write-Host ""
Write-Host "8. Running Application in Browser" -ForegroundColor Yellow
Write-Host "   Get frontend URL:" -ForegroundColor White
$getFrontendIP = Read-Host "Do you want to get the frontend IP now? (y/n)"
if ($getFrontendIP -eq "y") {
    $frontendIP = kubectl get svc frontend-service -n todo-app -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
    Write-Host "   Frontend URL: http://$frontendIP" -ForegroundColor Green
    Write-Host "   Open this URL in browser and take a screenshot" -ForegroundColor White
} else {
    Write-Host "   kubectl get svc frontend-service -n todo-app -o jsonpath='{.status.loadBalancer.ingress[0].ip}'" -ForegroundColor Green
}
Write-Host "   Save as: screenshots/section-c-app-running.png" -ForegroundColor Gray
Write-Host ""
Read-Host "Press Enter when screenshot is captured"

Write-Host ""
Write-Host "9. Azure Portal - AKS Cluster" -ForegroundColor Yellow
Write-Host "   Go to Azure Portal → Kubernetes services" -ForegroundColor White
Write-Host "   Take a screenshot showing your AKS cluster" -ForegroundColor White
Write-Host "   Save as: screenshots/section-c-aks-cluster.png" -ForegroundColor Gray
Write-Host ""
Read-Host "Press Enter when screenshot is captured"

Write-Host ""
Write-Host "10. Application Functionality Test" -ForegroundColor Yellow
Write-Host "    In the frontend:" -ForegroundColor White
Write-Host "    - Add a todo item" -ForegroundColor White
Write-Host "    - Mark it as completed" -ForegroundColor White
Write-Host "    - Take a screenshot showing the working app" -ForegroundColor White
Write-Host "    Save as: screenshots/section-c-app-working.png" -ForegroundColor Gray
Write-Host ""
Read-Host "Press Enter when screenshot is captured"

# Summary
Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "SCREENSHOT CHECKLIST" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

$screenshots = @(
    "section-a-docker-ps.png",
    "section-a-docker-compose-ps.png",
    "section-b-workflow-file.png",
    "section-b-pipeline-success.png",
    "section-b-dockerhub-images.png",
    "section-c-pods-running.png",
    "section-c-services.png",
    "section-c-app-running.png",
    "section-c-aks-cluster.png",
    "section-c-app-working.png"
)

Write-Host "Required screenshots:" -ForegroundColor Yellow
foreach ($screenshot in $screenshots) {
    $path = Join-Path $screenshotDir $screenshot
    if (Test-Path $path) {
        Write-Host "[✓] $screenshot" -ForegroundColor Green
    } else {
        Write-Host "[✗] $screenshot" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "All screenshots should be in the 'screenshots' folder" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Create a README in screenshots folder
$screenshotReadme = @"
# Screenshots for Final Exam Submission

## Section A: Containerization
- section-a-docker-ps.png - All Docker containers running
- section-a-docker-compose-ps.png - Docker Compose services

## Section B: CI/CD
- section-b-workflow-file.png - GitHub Actions workflow file
- section-b-pipeline-success.png - Pipeline run with all stages completed
- section-b-dockerhub-images.png - Docker Hub repositories

## Section C: Kubernetes (AKS)
- section-c-pods-running.png - All pods in Running state
- section-c-services.png - Services with External IPs
- section-c-app-running.png - Frontend application accessible
- section-c-aks-cluster.png - Azure Portal showing AKS cluster
- section-c-app-working.png - Application functionality test

## Notes
- All screenshots should clearly show the required information
- Include timestamps/dates if visible
- Ensure text is readable (use appropriate zoom level)
"@

Set-Content -Path (Join-Path $screenshotDir "README.md") -Value $screenshotReadme
Write-Host "[INFO] Created screenshots/README.md" -ForegroundColor Green
