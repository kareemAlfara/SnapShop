param(
    [Parameter(Mandatory = $true)]
    [string]$name
)

$base = "lib/feature/$name"

New-Item -ItemType Directory -Force -Path "$base/data/models" | Out-Null
New-Item -ItemType Directory -Force -Path "$base/data/repository" | Out-Null
New-Item -ItemType Directory -Force -Path "$base/domain/entities" | Out-Null
New-Item -ItemType Directory -Force -Path "$base/domain/usecases" | Out-Null
New-Item -ItemType Directory -Force -Path "$base/presentation/cubit" | Out-Null
New-Item -ItemType Directory -Force -Path "$base/presentation/pages" | Out-Null
New-Item -ItemType Directory -Force -Path "$base/presentation/widgets" | Out-Null

Write-Host "✅ Feature '$name' structure created successfully!"
