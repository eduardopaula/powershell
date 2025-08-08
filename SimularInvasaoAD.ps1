Import-Module ActiveDirectory

# ======= PARÂMETROS =========
$dominio = "dominio.local"
$usuario = "intruso01"
$senha = ConvertTo-SecureString "P@ssword123!" -AsPlainText -Force
$ou = "OU=Seguranca,DC=dominio,DC=local" # Crie previamente
$grupos = @("GrupoEstagiarios", "GrupoTI", "GrupoSuporte", "AdministradoresDomínio")
# ============================

Write-Host "`n[1] Criando usuário básico..." -ForegroundColor Cyan
New-ADUser `
    -Name $usuario `
    -SamAccountName $usuario `
    -UserPrincipalName "$usuario@$dominio" `
    -AccountPassword $senha `
    -Enabled $true `
    -ChangePasswordAtLogon $false `
    -Path $ou `
    -Description "Usuário de teste - simulação de escalada"

# Criar os grupos simulados de escalada
foreach ($g in $grupos[0..2]) {
    if (-not (Get-ADGroup -Filter { Name -eq $g })) {
        New-ADGroup -Name $g -GroupScope Global -GroupCategory Security -Path $ou
        Write-Host "Grupo criado: $g"
    }
}

Write-Host "`n[2] Adicionando usuário ao grupo de entrada: $($grupos[0])" -ForegroundColor Cyan
Add-ADGroupMember -Identity $grupos[0] -Members $usuario

# Simulando "movimentação lateral" com permissões mal configuradas
Write-Host "`n[3] Escalando privilégios via grupos intermediários..." -ForegroundColor Yellow
Start-Sleep -Seconds 1

# Passo 1: Estagiários conseguem adicionar membros ao grupo TI
Add-ADGroupMember -Identity $grupos[1] -Members $usuario
Write-Host "Movimento: $usuario => $($grupos[1])"

# Passo 2: Grupo TI tem permissão para alterar membros do Suporte
Add-ADGroupMember -Identity $grupos[2] -Members $usuario
Write-Host "Movimento: $usuario => $($grupos[2])"

# Passo 3: Suporte tem permissão de adicionar membros ao grupo Admins
Add-ADGroupMember -Identity "Domain Admins" -Members $usuario
Write-Host "`n[4] Movimento FINAL: $usuario => Domain Admins 🚨" -ForegroundColor Red

# Confirmação
$userGroups = Get-ADUser $usuario -Properties MemberOf | Select-Object -ExpandProperty MemberOf
Write-Host "`n[+] Grupos finais do usuário $usuario:"
$userGroups | ForEach-Object { ($_ -split ",")[0] }

Write-Host "`n⚠️ Fim da simulação: usuário '$usuario' agora é Domain Admin." -ForegroundColor Green
