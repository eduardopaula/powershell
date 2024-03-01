﻿# 
# This software is confidential.  Quest Software Inc., or one of its
# subsidiaries, has supplied this software to you under terms of a
# license agreement, nondisclosure agreement or both.
# 
# You may not copy, disclose, or use this software except in accordance with
# those terms.
# 
# 
# Copyright 2023 Quest Software Inc.
# ALL RIGHTS RESERVED.
# 
# QUEST SOFTWARE INC. MAKES NO REPRESENTATIONS OR
# WARRANTIES ABOUT THE SUITABILITY OF THE SOFTWARE,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED
# TO THE IMPLIED WARRANTIES OF MERCHANTABILITY
# FITNESS FOR A PARTICULAR PURPOSE, OR
# NON-INFRINGEMENT.  QUEST SOFTWARE SHALL NOT BE
# LIABLE FOR ANY DAMAGES SUFFERED BY LICENSEE
# AS A RESULT OF USING, MODIFYING OR DISTRIBUTING
# THIS SOFTWARE OR ITS DERIVATIVES.

# Import the Change Auditor PowerShell module
Import-Module "C:\Program Files\Quest\ChangeAuditor\Client\ChangeAuditor.PowerShell.dll"

# Prompt for the Change Auditor installation name
$installationName = Read-Host 'Specify Change Auditor installation name'

#Prompt for the Domain Name
$domainName = Read-Host 'Specify the Domain Name'
    
# Connect the Change Auditor PowerShell client to the installation
$connection = Connect-CAClient -DomainName $domainName -InstallationName $installationName

# Gather list of existing AD Database Protection Templates
$removeTemplate = Get-CAADDProtectionTemplates -Connection $connection

if (!$connection.IsConnected)
{
    Throw 'Connection failed - invalid installation name?'
}


Clear-Host
$validInputs = @('1', '2', '3')
do {
    $input = Read-Host ("Specify the number corresponding to what you want to do`n" +
    "     1. Delete an existing AD Database Protection Templates`n" +
    "     2. Delete all disabled existing AD Database Protection Templates`n" + 
    "     3. Delete all existing AD Database Protection Templates`n")

    $inputIsValid = $validInputs.Contains($input)

    if (!$inputIsValid){
        'Incorrect input. The input must be one of the following: ' + $validInputs
    }
} until ($inputIsValid)

switch ($input){
    '1' {
        # Remove a AD Database Protection Templates from the installation
            write-host "Here is a list of the following AD Datatbase Protection Template IDs" 
            foreach($r in $removeTemplate)
                {
                    write-host $r.id
                }
            $deletetemplate = Read-Host 'Specify the ID of the AD Database Protection Templates to delete'

            Get-CAADDProtectionTemplates `
                -Connection $connection `
                    -id $deletetemplate `
                        | Remove-CAADDProtectionTemplate 
                            `-Connection $connection  
    }
    '2' {
        'Warning: You are about to delete all AD Database Protection Templates in the installation with their Enabled property set to false.'
        $verifyIntent = Read-Host 'Type "yes" to continue or "no" to exit'

        if ($verifyIntent.ToLower() -eq "yes"){
            # Remove disabled AD Database Protection Templates from the installation
            Get-CAADDProtectionTemplates `
                -Connection $connection `
                | ? { $_.disabled -eq $false } `
                | Remove-CAADDProtectionTemplate `
                    -Connection $connection
        }
        else {
            'Cancelled deletion.'
        }
    }
    '3' {
        'Warning: You are about to delete all AD Database Protection Templates in the installation.'
        $verifyIntent = Read-Host 'Type "yes" to continue or "no" to exit'
        
        if ($verifyIntent.ToLower() -eq "yes"){
            # Remove all AD Database Protection templates from the installation
            Get-CAADDProtectionTemplates `
                -Connection $connection `
                | Remove-CAADDProtectTemplate `
                    -Connection $connection
        }
        else {
            'Cancelled deletion.'
        }
    }
}
# Disconnect the client
Disconnect-CAClient $connection

# Pause to see the output
Read-Host '::::::::::::::: Finished ::::::::::::::'
# SIG # Begin signature block
# MIImWwYJKoZIhvcNAQcCoIImTDCCJkgCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCACGQwPzsB7SHI/
# CrQ/+Qlv/YIaWOElXwAOTWKUYexvpKCCDB0wggXzMIIE26ADAgECAhAJvF2jX0kc
# y4NSLmHIglSvMA0GCSqGSIb3DQEBCwUAMIGRMQswCQYDVQQGEwJHQjEbMBkGA1UE
# CBMSR3JlYXRlciBNYW5jaGVzdGVyMRAwDgYDVQQHEwdTYWxmb3JkMRowGAYDVQQK
# ExFDT01PRE8gQ0EgTGltaXRlZDE3MDUGA1UEAxMuQ09NT0RPIFJTQSBFeHRlbmRl
# ZCBWYWxpZGF0aW9uIENvZGUgU2lnbmluZyBDQTAeFw0yMTAzMjkwMDAwMDBaFw0y
# NDAzMjgyMzU5NTlaMIHXMRAwDgYDVQQFEwc0NjQ1MzM2MRMwEQYLKwYBBAGCNzwC
# AQMTAlVTMRkwFwYLKwYBBAGCNzwCAQITCERlbGF3YXJlMR0wGwYDVQQPExRQcml2
# YXRlIE9yZ2FuaXphdGlvbjELMAkGA1UEBhMCVVMxEzARBgNVBAgMCkNhbGlmb3Ju
# aWExFDASBgNVBAcMC0FMSVNPIFZJRUpPMR0wGwYDVQQKDBRRVUVTVCBTT0ZUV0FS
# RSwgSU5DLjEdMBsGA1UEAwwUUVVFU1QgU09GVFdBUkUsIElOQy4wggEiMA0GCSqG
# SIb3DQEBAQUAA4IBDwAwggEKAoIBAQC3H9P30Qr2B+UarsSVlAT+PSlGV6yVTnWQ
# x43sZ+a8+z9eK+NIfHQ+mxfbaGDj/mIY22lrU2VMF4M2nVQ6svNbCj28wF7zIUML
# gP+MkaO8G0tWIPIs/EpDfVK3Z0jpAzExuB0XpM8WtaddIOFX2ZHpFaSGiBiaH4CZ
# NJwtLLtutd+baK9vSfEYQN6Cf7j+ebt/4g4Sp05MN8rcF2zlooeNlEGVJR4TcaBJ
# Oxn4LhxL6vVczoCZDeQb4b9LvIUfoxziIHd3Vllyn5GvSf00G10LyuL7TcxJ7ngG
# AeUJuak3gUdVG6mPkrcV1L/c3v6haCo/IX5KaDWt7BJ1SwZVxll9AgMBAAGjggH9
# MIIB+TAfBgNVHSMEGDAWgBTfj/MgDOnKpgTYW1g3Kj2rRtyDSTAdBgNVHQ4EFgQU
# akRqNJE+fmRC6eGnfmxII+TxRY8wDgYDVR0PAQH/BAQDAgeAMAwGA1UdEwEB/wQC
# MAAwEwYDVR0lBAwwCgYIKwYBBQUHAwMwEQYJYIZIAYb4QgEBBAQDAgQQMEkGA1Ud
# IARCMEAwNQYMKwYBBAGyMQECAQYBMCUwIwYIKwYBBQUHAgEWF2h0dHBzOi8vc2Vj
# dGlnby5jb20vQ1BTMAcGBWeBDAEDMFUGA1UdHwROMEwwSqBIoEaGRGh0dHA6Ly9j
# cmwuY29tb2RvY2EuY29tL0NPTU9ET1JTQUV4dGVuZGVkVmFsaWRhdGlvbkNvZGVT
# aWduaW5nQ0EuY3JsMIGGBggrBgEFBQcBAQR6MHgwUAYIKwYBBQUHMAKGRGh0dHA6
# Ly9jcnQuY29tb2RvY2EuY29tL0NPTU9ET1JTQUV4dGVuZGVkVmFsaWRhdGlvbkNv
# ZGVTaWduaW5nQ0EuY3J0MCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5jb21vZG9j
# YS5jb20wRgYDVR0RBD8wPaAjBggrBgEFBQcIA6AXMBUME1VTLURFTEFXQVJFLTQ2
# NDUzMzaBFmRhdmlkLnJvYnNvbkBxdWVzdC5jb20wDQYJKoZIhvcNAQELBQADggEB
# AA8qzX1RKnES/YURDtwx8/M4CEv0xTF/ub137B8zeZu8wJO0Q7S3FWjRbMvMdX5V
# z3sCqn9XZS+6bkEcgh7wH0JphQxYerPnaKkdREUKAzugQDTJcMDpeOnJ4BbyCJFw
# ycFiufJbWZP3uDJUfZ1UStoAB9bwHDd0xf7EKtWe6LU/S530QkP2gxG6NFc7FtKd
# N6Y3f9Kih/z7X/NFADpIAJjr0vsPp9rwH5RqLViiFMwkAfDIGn+hON7pMnvrwaBU
# WCgrrUpiy5E8oYGHD0XWdCdrmoh7cvAj/x4DdpteVlBCH6ZA4dwTHa+v7rZhUPhF
# d3RHbc3+SFbAK4q3/lOVaIkwggYiMIIECqADAgECAhBt1HLrAq4EBuPdhD9f4UXh
# MA0GCSqGSIb3DQEBDAUAMIGFMQswCQYDVQQGEwJHQjEbMBkGA1UECBMSR3JlYXRl
# ciBNYW5jaGVzdGVyMRAwDgYDVQQHEwdTYWxmb3JkMRowGAYDVQQKExFDT01PRE8g
# Q0EgTGltaXRlZDErMCkGA1UEAxMiQ09NT0RPIFJTQSBDZXJ0aWZpY2F0aW9uIEF1
# dGhvcml0eTAeFw0xNDEyMDMwMDAwMDBaFw0yOTEyMDIyMzU5NTlaMIGRMQswCQYD
# VQQGEwJHQjEbMBkGA1UECBMSR3JlYXRlciBNYW5jaGVzdGVyMRAwDgYDVQQHEwdT
# YWxmb3JkMRowGAYDVQQKExFDT01PRE8gQ0EgTGltaXRlZDE3MDUGA1UEAxMuQ09N
# T0RPIFJTQSBFeHRlbmRlZCBWYWxpZGF0aW9uIENvZGUgU2lnbmluZyBDQTCCASIw
# DQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAIr9vUPwPchVH/NZivBatNyT0WQV
# SoqEpS3LJvjgRTijuQHFTxMIWdAxVMrNkGGjPizyTRVc1O7DaiKXSNEGQzQJmcnP
# MMSfRP1WnO7M54O5gc3I2gscEkj/b6LsxHXLCXDPUeW7i5+qvXgGfZXWYYH22lPH
# rJ2zALoe1L5AYgmZgz1F3U1llQTM/PrHW3riLgw9VTVXNUiJifK5VqVLUBsc3piQ
# vfMu3Iip8XWbqD6iBdlBte93rRfAWvWj202f0cSxe4O17hCUKy5yrr7vlSmcUmLF
# LG0i931EehBfY5NpTdl9spqxTrVZv/+F+72s7OErpuMsLOjZbttfTRd4y1MCAwEA
# AaOCAX4wggF6MB8GA1UdIwQYMBaAFLuvfgI9+qbxPISOre44mOzZMjLUMB0GA1Ud
# DgQWBBTfj/MgDOnKpgTYW1g3Kj2rRtyDSTAOBgNVHQ8BAf8EBAMCAYYwEgYDVR0T
# AQH/BAgwBgEB/wIBADATBgNVHSUEDDAKBggrBgEFBQcDAzA+BgNVHSAENzA1MDMG
# BFUdIAAwKzApBggrBgEFBQcCARYdaHR0cHM6Ly9zZWN1cmUuY29tb2RvLmNvbS9D
# UFMwTAYDVR0fBEUwQzBBoD+gPYY7aHR0cDovL2NybC5jb21vZG9jYS5jb20vQ09N
# T0RPUlNBQ2VydGlmaWNhdGlvbkF1dGhvcml0eS5jcmwwcQYIKwYBBQUHAQEEZTBj
# MDsGCCsGAQUFBzAChi9odHRwOi8vY3J0LmNvbW9kb2NhLmNvbS9DT01PRE9SU0FB
# ZGRUcnVzdENBLmNydDAkBggrBgEFBQcwAYYYaHR0cDovL29jc3AuY29tb2RvY2Eu
# Y29tMA0GCSqGSIb3DQEBDAUAA4ICAQBmTuy3FndvEegbXWpO2fKLbLFWKECLwDHE
# mUgjPfgO6ICX720gCx8TxIb7FzQV4Y5U98K4AHMV4CjZ2rr6glTC9+u/wzbQMJ/l
# oRyU3+986PYseKKszyZqFaEVMdYxNJi9U0/EhIOjxJZcPdj+1vlU/2eTbfg+K2ss
# ogh8VkiBMhiybqyQwdvk3jmLhuXHGEBZpN+WR7qyf7H4Vw+FgHQ4DjpYYh7+UuPm
# rlMJhv6Pm9tWVswHsInBBPFTC2xvd+yyH+z2W0BDYA8bqxhUtBAEjvgO6cuDsXry
# NE5qVEzpgyrpsDAlHM5ijg7rheYp/rFK4/KuPJH1TKG+yBcOXLtCTeMaipLNPiB+
# 3el1seofdFyeVMKUN7Jh3QcWWX+WgBbgmbXSbrDJIwYVrNEj9DOLznXwwYbT/+Eu
# +pBP/kb5u9tPu7f+0Q0rBPHS0ZWFLIouuIVW8sOEUqHpM7HrUMihsJ/jw4s6h57n
# VdPTbTQXMA1oIgvVue1zNXLD7ac3zeNDrkXNNL8oyodi7UOkr/rLMcshWGFGXrbG
# eqYeUyqo+FxRHzpaEA8owOR0i3TGBKr4SyYoCjKJ250qYHFqw5ZOFrljv2GVZ4xL
# LruwToPpTTHljici9Twme0SR09Ra8NN89Di+FJqZDouxW+rkiw8RnXdCghxcOtTa
# q4gvjVcwVDGCGZQwghmQAgEBMIGmMIGRMQswCQYDVQQGEwJHQjEbMBkGA1UECBMS
# R3JlYXRlciBNYW5jaGVzdGVyMRAwDgYDVQQHEwdTYWxmb3JkMRowGAYDVQQKExFD
# T01PRE8gQ0EgTGltaXRlZDE3MDUGA1UEAxMuQ09NT0RPIFJTQSBFeHRlbmRlZCBW
# YWxpZGF0aW9uIENvZGUgU2lnbmluZyBDQQIQCbxdo19JHMuDUi5hyIJUrzANBglg
# hkgBZQMEAgEFAKB8MBAGCisGAQQBgjcCAQwxAjAAMBkGCSqGSIb3DQEJAzEMBgor
# BgEEAYI3AgEEMBwGCisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMC8GCSqGSIb3
# DQEJBDEiBCA4V2Gztn33QevkZ59Fr6AbE4Pswml7NJTmscCqOmMupDANBgkqhkiG
# 9w0BAQEFAASCAQApY50Nw+UCPHpFtmKx7reRsePERspl5MPqPeE02brF7prkVx99
# hK2bhp/N7F1S/oQddGm9FdxXlXKGtILxqfXMvKen6/wWSXcCyUAq5w7zGVntjiHf
# iq6XbLDtCif1YX4/3lXEXrekkTDknS/crV1Ihwe+v7wKlsm8woVhB8d5q8JJQ7UI
# VsB/wkucz8RYVKTFlfEtuGLtw3AfUGeDik+4p/VMehSPzhs/cIbzXe4cuhoOcyBk
# sh15f/1ewX6/B3M0DTnLPA/aJ6bjBNHb93QW5qBHTEI9shqDQDdoXmVJ1gEVLeS6
# Mbwvg9wx+QFS8xOWMnQWZxpOQiePxEQqMZiuoYIXQDCCFzwGCisGAQQBgjcDAwEx
# ghcsMIIXKAYJKoZIhvcNAQcCoIIXGTCCFxUCAQMxDzANBglghkgBZQMEAgEFADB4
# BgsqhkiG9w0BCRABBKBpBGcwZQIBAQYJYIZIAYb9bAcBMDEwDQYJYIZIAWUDBAIB
# BQAEIPxD+W5f1PjfoUjMEZVypla+vLzjhE4p89Mxjz9XZymGAhEAipMEHxWKU7+v
# fFXjNjYLLxgPMjAyMzExMTMxNTM1NDRaoIITCTCCBsIwggSqoAMCAQICEAVEr/OU
# nQg5pr/bP1/lYRYwDQYJKoZIhvcNAQELBQAwYzELMAkGA1UEBhMCVVMxFzAVBgNV
# BAoTDkRpZ2lDZXJ0LCBJbmMuMTswOQYDVQQDEzJEaWdpQ2VydCBUcnVzdGVkIEc0
# IFJTQTQwOTYgU0hBMjU2IFRpbWVTdGFtcGluZyBDQTAeFw0yMzA3MTQwMDAwMDBa
# Fw0zNDEwMTMyMzU5NTlaMEgxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2Vy
# dCwgSW5jLjEgMB4GA1UEAxMXRGlnaUNlcnQgVGltZXN0YW1wIDIwMjMwggIiMA0G
# CSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQCjU0WHHYOOW6w+VLMj4M+f1+XS512h
# DgncL0ijl3o7Kpxn3GIVWMGpkxGnzaqyat0QKYoeYmNp01icNXG/OpfrlFCPHCDq
# x5o7L5Zm42nnaf5bw9YrIBzBl5S0pVCB8s/LB6YwaMqDQtr8fwkklKSCGtpqutg7
# yl3eGRiF+0XqDWFsnf5xXsQGmjzwxS55DxtmUuPI1j5f2kPThPXQx/ZILV5FdZZ1
# /t0QoRuDwbjmUpW1R9d4KTlr4HhZl+NEK0rVlc7vCBfqgmRN/yPjyobutKQhZHDr
# 1eWg2mOzLukF7qr2JPUdvJscsrdf3/Dudn0xmWVHVZ1KJC+sK5e+n+T9e3M+Mu5S
# NPvUu+vUoCw0m+PebmQZBzcBkQ8ctVHNqkxmg4hoYru8QRt4GW3k2Q/gWEH72LEs
# 4VGvtK0VBhTqYggT02kefGRNnQ/fztFejKqrUBXJs8q818Q7aESjpTtC/XN97t0K
# /3k0EH6mXApYTAA+hWl1x4Nk1nXNjxJ2VqUk+tfEayG66B80mC866msBsPf7Kobs
# e1I4qZgJoXGybHGvPrhvltXhEBP+YUcKjP7wtsfVx95sJPC/QoLKoHE9nJKTBLRp
# cCcNT7e1NtHJXwikcKPsCvERLmTgyyIryvEoEyFJUX4GZtM7vvrrkTjYUQfKlLfi
# UKHzOtOKg8tAewIDAQABo4IBizCCAYcwDgYDVR0PAQH/BAQDAgeAMAwGA1UdEwEB
# /wQCMAAwFgYDVR0lAQH/BAwwCgYIKwYBBQUHAwgwIAYDVR0gBBkwFzAIBgZngQwB
# BAIwCwYJYIZIAYb9bAcBMB8GA1UdIwQYMBaAFLoW2W1NhS9zKXaaL3WMaiCPnshv
# MB0GA1UdDgQWBBSltu8T5+/N0GSh1VapZTGj3tXjSTBaBgNVHR8EUzBRME+gTaBL
# hklodHRwOi8vY3JsMy5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVzdGVkRzRSU0E0
# MDk2U0hBMjU2VGltZVN0YW1waW5nQ0EuY3JsMIGQBggrBgEFBQcBAQSBgzCBgDAk
# BggrBgEFBQcwAYYYaHR0cDovL29jc3AuZGlnaWNlcnQuY29tMFgGCCsGAQUFBzAC
# hkxodHRwOi8vY2FjZXJ0cy5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVzdGVkRzRS
# U0E0MDk2U0hBMjU2VGltZVN0YW1waW5nQ0EuY3J0MA0GCSqGSIb3DQEBCwUAA4IC
# AQCBGtbeoKm1mBe8cI1PijxonNgl/8ss5M3qXSKS7IwiAqm4z4Co2efjxe0mgopx
# LxjdTrbebNfhYJwr7e09SI64a7p8Xb3CYTdoSXej65CqEtcnhfOOHpLawkA4n13I
# oC4leCWdKgV6hCmYtld5j9smViuw86e9NwzYmHZPVrlSwradOKmB521BXIxp0bkr
# xMZ7z5z6eOKTGnaiaXXTUOREEr4gDZ6pRND45Ul3CFohxbTPmJUaVLq5vMFpGbrP
# FvKDNzRusEEm3d5al08zjdSNd311RaGlWCZqA0Xe2VC1UIyvVr1MxeFGxSjTredD
# AHDezJieGYkD6tSRN+9NUvPJYCHEVkft2hFLjDLDiOZY4rbbPvlfsELWj+MXkdGq
# wFXjhr+sJyxB0JozSqg21Llyln6XeThIX8rC3D0y33XWNmdaifj2p8flTzU8AL2+
# nCpseQHc2kTmOt44OwdeOVj0fHMxVaCAEcsUDH6uvP6k63llqmjWIso765qCNVco
# Fstp8jKastLYOrixRoZruhf9xHdsFWyuq69zOuhJRrfVf8y2OMDY7Bz1tqG4Qyzf
# Tkx9HmhwwHcK1ALgXGC7KP845VJa1qwXIiNO9OzTF/tQa/8Hdx9xl0RBybhG02wy
# fFgvZ0dl5Rtztpn5aywGRu9BHvDwX+Db2a2QgESvgBBBijCCBq4wggSWoAMCAQIC
# EAc2N7ckVHzYR6z9KGYqXlswDQYJKoZIhvcNAQELBQAwYjELMAkGA1UEBhMCVVMx
# FTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0LmNv
# bTEhMB8GA1UEAxMYRGlnaUNlcnQgVHJ1c3RlZCBSb290IEc0MB4XDTIyMDMyMzAw
# MDAwMFoXDTM3MDMyMjIzNTk1OVowYzELMAkGA1UEBhMCVVMxFzAVBgNVBAoTDkRp
# Z2lDZXJ0LCBJbmMuMTswOQYDVQQDEzJEaWdpQ2VydCBUcnVzdGVkIEc0IFJTQTQw
# OTYgU0hBMjU2IFRpbWVTdGFtcGluZyBDQTCCAiIwDQYJKoZIhvcNAQEBBQADggIP
# ADCCAgoCggIBAMaGNQZJs8E9cklRVcclA8TykTepl1Gh1tKD0Z5Mom2gsMyD+Vr2
# EaFEFUJfpIjzaPp985yJC3+dH54PMx9QEwsmc5Zt+FeoAn39Q7SE2hHxc7Gz7iuA
# hIoiGN/r2j3EF3+rGSs+QtxnjupRPfDWVtTnKC3r07G1decfBmWNlCnT2exp39mQ
# h0YAe9tEQYncfGpXevA3eZ9drMvohGS0UvJ2R/dhgxndX7RUCyFobjchu0CsX7Le
# Sn3O9TkSZ+8OpWNs5KbFHc02DVzV5huowWR0QKfAcsW6Th+xtVhNef7Xj3OTrCw5
# 4qVI1vCwMROpVymWJy71h6aPTnYVVSZwmCZ/oBpHIEPjQ2OAe3VuJyWQmDo4EbP2
# 9p7mO1vsgd4iFNmCKseSv6De4z6ic/rnH1pslPJSlRErWHRAKKtzQ87fSqEcazjF
# KfPKqpZzQmiftkaznTqj1QPgv/CiPMpC3BhIfxQ0z9JMq++bPf4OuGQq+nUoJEHt
# Qr8FnGZJUlD0UfM2SU2LINIsVzV5K6jzRWC8I41Y99xh3pP+OcD5sjClTNfpmEpY
# PtMDiP6zj9NeS3YSUZPJjAw7W4oiqMEmCPkUEBIDfV8ju2TjY+Cm4T72wnSyPx4J
# duyrXUZ14mCjWAkBKAAOhFTuzuldyF4wEr1GnrXTdrnSDmuZDNIztM2xAgMBAAGj
# ggFdMIIBWTASBgNVHRMBAf8ECDAGAQH/AgEAMB0GA1UdDgQWBBS6FtltTYUvcyl2
# mi91jGogj57IbzAfBgNVHSMEGDAWgBTs1+OC0nFdZEzfLmc/57qYrhwPTzAOBgNV
# HQ8BAf8EBAMCAYYwEwYDVR0lBAwwCgYIKwYBBQUHAwgwdwYIKwYBBQUHAQEEazBp
# MCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5kaWdpY2VydC5jb20wQQYIKwYBBQUH
# MAKGNWh0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFRydXN0ZWRS
# b290RzQuY3J0MEMGA1UdHwQ8MDowOKA2oDSGMmh0dHA6Ly9jcmwzLmRpZ2ljZXJ0
# LmNvbS9EaWdpQ2VydFRydXN0ZWRSb290RzQuY3JsMCAGA1UdIAQZMBcwCAYGZ4EM
# AQQCMAsGCWCGSAGG/WwHATANBgkqhkiG9w0BAQsFAAOCAgEAfVmOwJO2b5ipRCIB
# fmbW2CFC4bAYLhBNE88wU86/GPvHUF3iSyn7cIoNqilp/GnBzx0H6T5gyNgL5Vxb
# 122H+oQgJTQxZ822EpZvxFBMYh0MCIKoFr2pVs8Vc40BIiXOlWk/R3f7cnQU1/+r
# T4osequFzUNf7WC2qk+RZp4snuCKrOX9jLxkJodskr2dfNBwCnzvqLx1T7pa96kQ
# sl3p/yhUifDVinF2ZdrM8HKjI/rAJ4JErpknG6skHibBt94q6/aesXmZgaNWhqsK
# RcnfxI2g55j7+6adcq/Ex8HBanHZxhOACcS2n82HhyS7T6NJuXdmkfFynOlLAlKn
# N36TU6w7HQhJD5TNOXrd/yVjmScsPT9rp/Fmw0HNT7ZAmyEhQNC3EyTN3B14OuSe
# reU0cZLXJmvkOHOrpgFPvT87eK1MrfvElXvtCl8zOYdBeHo46Zzh3SP9HSjTx/no
# 8Zhf+yvYfvJGnXUsHicsJttvFXseGYs2uJPU5vIXmVnKcPA3v5gA3yAWTyf7YGcW
# oWa63VXAOimGsJigK+2VQbc61RWYMbRiCQ8KvYHZE/6/pNHzV9m8BPqC3jLfBInw
# AM1dwvnQI38AC+R2AibZ8GV2QqYphwlHK+Z/GqSFD/yYlvZVVCsfgPrA8g4r5db7
# qS9EFUrnEw4d2zc4GqEr9u3WfPwwggWNMIIEdaADAgECAhAOmxiO+dAt5+/bUOII
# QBhaMA0GCSqGSIb3DQEBDAUAMGUxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdp
# Q2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xJDAiBgNVBAMTG0Rp
# Z2lDZXJ0IEFzc3VyZWQgSUQgUm9vdCBDQTAeFw0yMjA4MDEwMDAwMDBaFw0zMTEx
# MDkyMzU5NTlaMGIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMx
# GTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xITAfBgNVBAMTGERpZ2lDZXJ0IFRy
# dXN0ZWQgUm9vdCBHNDCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAL/m
# kHNo3rvkXUo8MCIwaTPswqclLskhPfKK2FnC4SmnPVirdprNrnsbhA3EMB/zG6Q4
# FutWxpdtHauyefLKEdLkX9YFPFIPUh/GnhWlfr6fqVcWWVVyr2iTcMKyunWZanMy
# lNEQRBAu34LzB4TmdDttceItDBvuINXJIB1jKS3O7F5OyJP4IWGbNOsFxl7sWxq8
# 68nPzaw0QF+xembud8hIqGZXV59UWI4MK7dPpzDZVu7Ke13jrclPXuU15zHL2pNe
# 3I6PgNq2kZhAkHnDeMe2scS1ahg4AxCN2NQ3pC4FfYj1gj4QkXCrVYJBMtfbBHMq
# bpEBfCFM1LyuGwN1XXhm2ToxRJozQL8I11pJpMLmqaBn3aQnvKFPObURWBf3JFxG
# j2T3wWmIdph2PVldQnaHiZdpekjw4KISG2aadMreSx7nDmOu5tTvkpI6nj3cAORF
# JYm2mkQZK37AlLTSYW3rM9nF30sEAMx9HJXDj/chsrIRt7t/8tWMcCxBYKqxYxhE
# lRp2Yn72gLD76GSmM9GJB+G9t+ZDpBi4pncB4Q+UDCEdslQpJYls5Q5SUUd0vias
# tkF13nqsX40/ybzTQRESW+UQUOsxxcpyFiIJ33xMdT9j7CFfxCBRa2+xq4aLT8LW
# RV+dIPyhHsXAj6KxfgommfXkaS+YHS312amyHeUbAgMBAAGjggE6MIIBNjAPBgNV
# HRMBAf8EBTADAQH/MB0GA1UdDgQWBBTs1+OC0nFdZEzfLmc/57qYrhwPTzAfBgNV
# HSMEGDAWgBRF66Kv9JLLgjEtUYunpyGd823IDzAOBgNVHQ8BAf8EBAMCAYYweQYI
# KwYBBQUHAQEEbTBrMCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5kaWdpY2VydC5j
# b20wQwYIKwYBBQUHMAKGN2h0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNvbS9EaWdp
# Q2VydEFzc3VyZWRJRFJvb3RDQS5jcnQwRQYDVR0fBD4wPDA6oDigNoY0aHR0cDov
# L2NybDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9vdENBLmNybDAR
# BgNVHSAECjAIMAYGBFUdIAAwDQYJKoZIhvcNAQEMBQADggEBAHCgv0NcVec4X6Cj
# dBs9thbX979XB72arKGHLOyFXqkauyL4hxppVCLtpIh3bb0aFPQTSnovLbc47/T/
# gLn4offyct4kvFIDyE7QKt76LVbP+fT3rDB6mouyXtTP0UNEm0Mh65ZyoUi0mcud
# T6cGAxN3J0TU53/oWajwvy8LpunyNDzs9wPHh6jSTEAZNUZqaVSwuKFWjuyk1T3o
# sdz9HNj0d1pcVIxv76FQPfx2CWiEn2/K2yCNNWAcAgPLILCsWKAOQGPFmCLBsln1
# VWvPJ6tsds5vIy30fnFqI2si/xK4VC0nftg62fC2h5b9W9FcrBjDTZ9ztwGpn1eq
# XijiuZQxggN2MIIDcgIBATB3MGMxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdp
# Q2VydCwgSW5jLjE7MDkGA1UEAxMyRGlnaUNlcnQgVHJ1c3RlZCBHNCBSU0E0MDk2
# IFNIQTI1NiBUaW1lU3RhbXBpbmcgQ0ECEAVEr/OUnQg5pr/bP1/lYRYwDQYJYIZI
# AWUDBAIBBQCggdEwGgYJKoZIhvcNAQkDMQ0GCyqGSIb3DQEJEAEEMBwGCSqGSIb3
# DQEJBTEPFw0yMzExMTMxNTM1NDRaMCsGCyqGSIb3DQEJEAIMMRwwGjAYMBYEFGbw
# KzLCwskPgl3OqorJxk8ZnM9AMC8GCSqGSIb3DQEJBDEiBCCV65RzB1hJeU9B71ut
# L6UZjJrOTpU0hfIGX4+LLSjWqzA3BgsqhkiG9w0BCRACLzEoMCYwJDAiBCDS9uRt
# 7XQizNHUQFdoQTZvgoraVZquMxavTRqa1Ax4KDANBgkqhkiG9w0BAQEFAASCAgBz
# wDdJZLv3ucdRoGxvZhnLn7uOARmTZIhARpJPtv9D14eS7WsLokSrhlCivppCtGX8
# 5WoOAKdmC7ZsFV/ahfYqgVEznhafNuU0JFSh3Bu7ep1kQxNbhWNs94NHgG0ymhJ0
# 8B4o9xJKINZyDSclB5Ir607bfsoiRDhHhp2Ot0Oq71/cPFdsH4VDmZrwRME3PRNV
# ozUjZWODCjA2aUGX0g3e2f01E5vCXy6L3oXfWHIG5UcOpxVFphpFrLyJl0UG6kxW
# 30brTimqgI5nv4jQqvrTYoNsNiCJYrwKfvqSXQ4ic29dpmc7oWXxSzs4Oyk4579g
# NmuD1Lo1D/tNW/w7UL47x7iCS8JBWOqoVOksB3yV3TSW7RzTObnY6Thh3vrNb9Qd
# 1PkFPpqnnKW79Lkp85oOHWLlaHIh+0HhUI3z7q9/MIhGHIzMRiVy5G381BYfd/yO
# BRF6xwmvrdJFEOdOMfLybP+vOmjbosoK8vQvte0jFQaJJbwvoaMYkxssYHbNY1CO
# mKCr+D9qiLcaQLnCk+LoNLuimHrMZ2FFMWGdktvGQyDcU2xXCLfjwc+OWwMatPmF
# m2hafFS19bB4CX2tPQDw4cxjObp9CK11YaZ83O5eosseLi1q6WLoIcwQ9zAQOX8t
# yRFIzNFBKwUMf5SeDvbeCGxCcWpiWKAVvbVLVZCvwQ==
# SIG # End signature block