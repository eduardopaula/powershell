Import-Module ActiveDirectory

# ===================== CONFIGURAÇÕES =====================
$domain = "dominio.local"              # ajuste seu domínio
$baseOU = "OU=Usuarios,DC=dominio,DC=local"  # OU raiz para OUs filhas
$departamentos = 10
$usuariosTotal = 500
$usuariosPorDepto = [math]::Ceiling($usuariosTotal / $departamentos)
$empresa = "Empresa Exemplo S/A"
$csvSaida = "usuarios_AD_{0}.csv" -f (Get-Date -Format "yyyyMMdd_HHmmss")
# =========================================================

# Listas básicas
$Nomes = "Lucas","Pedro","Ana","João","Juliana","Bruno","Camila","Tiago","Isabela","Rafael","Carla","Diego","Fernanda","Mateus","Letícia"
$Sobrenomes = "Silva","Santos","Oliveira","Pereira","Lima","Costa","Martins","Ribeiro","Barbosa","Rocha","Souza","Almeida","Araújo","Melo"

$Cargos = "Analista","Assistente","Coordenador","Gerente","Especialista","Técnico","Supervisor"
$Enderecos = "Rua A, 123","Av. Brasil, 456","Rua das Flores, 789","Rua Central, 111","Av. Paulista, 900"

# Função para gerar senha segura
function New-RandomPassword {
    param([int]$Length = 12)
    $all = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%&*'.ToCharArray()
    -join ((1..$Length) | ForEach-Object { $all | Get-Random })
}

# Criar OUs
for ($d = 1; $d -le $departamentos; $d++) {
    $ouName = "Departamento{0:D2}" -f $d
    $ouPath = "OU=$ouName,$baseOU"
    if (-not (Get-ADOrganizationalUnit -Filter "Name -eq '$ouName'" -ErrorAction SilentlyContinue)) {
        New-ADOrganizationalUnit -Name $ouName -Path $baseOU -ProtectedFromAccidentalDeletion:$false
        Write-Host "OU criada: $ouPath" -ForegroundColor Cyan
    }
}

# Lista para salvar resultado
$resultado = @()

# Criar usuários
for ($i = 1; $i -le $usuariosTotal; $i++) {
    $nome = Get-Random $Nomes
    $sobrenome = Get-Random $Sobrenomes
    $displayName = "$nome $sobrenome"
    $sam = ($nome.Substring(0,1) + $sobrenome + $i).ToLower()
    $email = "$sam@$domain"
    $senha = New-RandomPassword
    $cargo = Get-Random $Cargos
    $tel = "61 9" + (Get-Random -Minimum 10000000 -Maximum 99999999)
    $endereco = Get-Random $Enderecos
    $deptoIndex = (($i - 1) % $departamentos) + 1
    $ou = "OU=Departamento{0:D2},$baseOU" -f $deptoIndex

    try {
        New-ADUser `
            -Name $displayName `
            -GivenName $nome `
            -Surname $sobrenome `
            -SamAccountName $sam `
            -UserPrincipalName "$sam@$domain" `
            -DisplayName $displayName `
            -EmailAddress $email `
            -Title $cargo `
            -Department "Departamento {0:D2}" -f $deptoIndex `
            -Company $empresa `
            -OfficePhone $tel `
            -StreetAddress $endereco `
            -City "Brasília" `
            -State "DF" `
            -PostalCode "70000-000" `
            -Country "BR" `
            -Path $ou `
            -AccountPassword (ConvertTo-SecureString $senha -AsPlainText -Force) `
            -ChangePasswordAtLogon $true `
            -Enabled $true

        Write-Host "Criado: $displayName ($sam) em $ou" -ForegroundColor Green

        $resultado += [PSCustomObject]@{
            NomeCompleto       = $displayName
            Login              = $sam
           UPN                = "$sam@$domain"
            Senha              = $senha
            Email              = $email
            Cargo              = $cargo
            Departamento       = "Departamento {0:D2}" -f $deptoIndex
            Telefone           = $tel
            Endereco           = $endereco
            OU                 = $ou
        }
    } catch {
        Write-Warning "Erro ao criar $displayName: $_"
    }
}

# Exportar CSV
$resultado | Export-Csv -Path $csvSaida -NoTypeInformation -Encoding UTF8
Write-Host "Arquivo CSV salvo em: $csvSaida" -ForegroundColor Yellow
