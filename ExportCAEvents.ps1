
# QUEST SOFTWARE PROPRIETARY INFORMATION
# 
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

# Import the change Auditor Powershell module
Import-Module "C:\Program Files\Quest\ChangeAuditor\Client\Dell.ChangeAuditor.PowerShell.dll" 


##-------------------------------------------------------------------------
## This function returns all the events from the ChangeAuditor database.
##-------------------------------------------------------------------------
function Get-AllEvents
{
    param
    (
		# Valid connection to the ChangeAuditor coordinator
        [Dell.ChangeAuditor.PowerShell.PSCAServiceConnection] $caConnection,

		# ChangeAuditor subsystems to be fetched.
		[object[]] $caSubsystems,

		# Start batched time of the evetns to be fetched
		[DateTime] $caStartTime,

		# End batched time of the events to be fetched
		[DateTime] $caEndTime
    )

	# Retrieves all the events from the Change Auditor database
    $events = Export-CAEvents -Connection $caConnection -Subsystems $caSubsystems -StartTime $caStartTime -EndTime $caEndTime

    return $events
}

##-------------------------------------------------------------------------
## This function returns all the events from the ChangeAuditor database.
##-------------------------------------------------------------------------
function Get-EventsByBatch
{
    param
    (
		# Valid connection to the ChangeAuditor coordinator
        [Dell.ChangeAuditor.PowerShell.PSCAServiceConnection] $caConnection,

		# ChangeAuditor subsystems to be fetched.
		[object[]] $caSubsystems,

		# Start batched time of the evetns to be fetched
		[DateTime] $caStartTime,

		# End batched time of the events to be fetched
		[DateTime] $caEndTime,

		# Number of evetns to be fetched
		[int] $caNumberOfEvents
    )

	# Retrieves all the events from the Change Auditor database
    $events = Export-CAEvents -Connection $caConnection -Subsystems $caSubsystems -StartTime $caStartTime -EndTime $caEndTime | Select-Object -First $caNumberOfEvents

    return $events
}

# Prompt for installation name
$installationName = Read-Host 'Specify Change Auditor installation name'

# Connect the Change Auditor Powershell Client to the installation
$connection = Connect-CAClient -InstallationName $installationName

# Get the secure password to connect to the Coordinator
#$secureString = ConvertTo-SecureString -AsPlainText -Force -String 'password'

# Create credential object using username and secure string password
#$credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'userName' , $secureString
 
# Connect to the Change Auditor Coordinator
#$connection = Connect-CAClient -InstallationName 'DEFAULT_DI' -DomainName 'rovagard.dev.hal.ca.qsft' -Credential $credentials

# Start date (time batched) 
$startDateTime  = [datetime]::Now.AddMonths(-1).ToUniversalTime()

# end date
$endDateTime = [Datetime]::Now.ToUniversalTime()

# Get all the subsystems supported by the Data integration api
$subsystems = Get-CAEventExportSubsystems -Connection $connection

# Calling export events cmdlet to get all the events for all the suported subsystems.
$exportEvents = Get-EventsByBatch $connection $subsystems $startDateTime $endDateTime 1000

# print all export events.
$exportEvents

# Disconnect the Client
Disconnect-CAClient $connection

# Pause to see the output
Read-Host '::::::::::::::: Finished ::::::::::::::'

# SIG # Begin signature block
# MIImWgYJKoZIhvcNAQcCoIImSzCCJkcCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCBRmZ4tCTuG9ZRH
# dY3Evq2lU0iNg2lVtB7mHDrXSjnERaCCDB0wggXzMIIE26ADAgECAhAJvF2jX0kc
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
# q4gvjVcwVDGCGZMwghmPAgEBMIGmMIGRMQswCQYDVQQGEwJHQjEbMBkGA1UECBMS
# R3JlYXRlciBNYW5jaGVzdGVyMRAwDgYDVQQHEwdTYWxmb3JkMRowGAYDVQQKExFD
# T01PRE8gQ0EgTGltaXRlZDE3MDUGA1UEAxMuQ09NT0RPIFJTQSBFeHRlbmRlZCBW
# YWxpZGF0aW9uIENvZGUgU2lnbmluZyBDQQIQCbxdo19JHMuDUi5hyIJUrzANBglg
# hkgBZQMEAgEFAKB8MBAGCisGAQQBgjcCAQwxAjAAMBkGCSqGSIb3DQEJAzEMBgor
# BgEEAYI3AgEEMBwGCisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMC8GCSqGSIb3
# DQEJBDEiBCAokI/OSSnj2+PeozanptCoAJaffgIMiZqbSZkutM46TDANBgkqhkiG
# 9w0BAQEFAASCAQCFS1G6nQfF1mZdZUAcK/AhC68L7YheU8RJlZUPtGEvNepIDi4J
# 0rAcG3724NZ8vQIJ7mt8QY9e4WLJo2Vrw7Xs2oS/qseY2Y3ItIY6WejRQ8Ky0LuH
# 4xDskk4Qb7kqDITWenQtOXV6LdXdQQ0hMlJmhvM/9ixtRdKXTbfRgua2tSk6+pFt
# ucsoa6ePPnHbKJ+KyVqGr+pcICEobWYJNSO/OPiM5xF6d1yUh6Q22zj/HUDbR5KO
# RCgzmicYVEPJiuNdpi7cKEyHu4vw+wVbqAd6BMp3Q4zkJHHGTc8UkB6idsObg/Ht
# mtqcxx70oEZHJfaVKOvvUVTr510PNn8BrW0GoYIXPzCCFzsGCisGAQQBgjcDAwEx
# ghcrMIIXJwYJKoZIhvcNAQcCoIIXGDCCFxQCAQMxDzANBglghkgBZQMEAgEFADB3
# BgsqhkiG9w0BCRABBKBoBGYwZAIBAQYJYIZIAYb9bAcBMDEwDQYJYIZIAWUDBAIB
# BQAEIFOBrb1A/h+Hwk2uqkIJJtj0oj8t3GxuaV5bquFKaK7jAhAfClpwtwmbjZWW
# lPzr0O94GA8yMDIzMTExMzE1MzQwNFqgghMJMIIGwjCCBKqgAwIBAgIQBUSv85Sd
# CDmmv9s/X+VhFjANBgkqhkiG9w0BAQsFADBjMQswCQYDVQQGEwJVUzEXMBUGA1UE
# ChMORGlnaUNlcnQsIEluYy4xOzA5BgNVBAMTMkRpZ2lDZXJ0IFRydXN0ZWQgRzQg
# UlNBNDA5NiBTSEEyNTYgVGltZVN0YW1waW5nIENBMB4XDTIzMDcxNDAwMDAwMFoX
# DTM0MTAxMzIzNTk1OVowSDELMAkGA1UEBhMCVVMxFzAVBgNVBAoTDkRpZ2lDZXJ0
# LCBJbmMuMSAwHgYDVQQDExdEaWdpQ2VydCBUaW1lc3RhbXAgMjAyMzCCAiIwDQYJ
# KoZIhvcNAQEBBQADggIPADCCAgoCggIBAKNTRYcdg45brD5UsyPgz5/X5dLnXaEO
# CdwvSKOXejsqnGfcYhVYwamTEafNqrJq3RApih5iY2nTWJw1cb86l+uUUI8cIOrH
# mjsvlmbjaedp/lvD1isgHMGXlLSlUIHyz8sHpjBoyoNC2vx/CSSUpIIa2mq62DvK
# Xd4ZGIX7ReoNYWyd/nFexAaaPPDFLnkPG2ZS48jWPl/aQ9OE9dDH9kgtXkV1lnX+
# 3RChG4PBuOZSlbVH13gpOWvgeFmX40QrStWVzu8IF+qCZE3/I+PKhu60pCFkcOvV
# 5aDaY7Mu6QXuqvYk9R28mxyyt1/f8O52fTGZZUdVnUokL6wrl76f5P17cz4y7lI0
# +9S769SgLDSb495uZBkHNwGRDxy1Uc2qTGaDiGhiu7xBG3gZbeTZD+BYQfvYsSzh
# Ua+0rRUGFOpiCBPTaR58ZE2dD9/O0V6MqqtQFcmzyrzXxDtoRKOlO0L9c33u3Qr/
# eTQQfqZcClhMAD6FaXXHg2TWdc2PEnZWpST618RrIbroHzSYLzrqawGw9/sqhux7
# UjipmAmhcbJsca8+uG+W1eEQE/5hRwqM/vC2x9XH3mwk8L9CgsqgcT2ckpMEtGlw
# Jw1Pt7U20clfCKRwo+wK8REuZODLIivK8SgTIUlRfgZm0zu++uuRONhRB8qUt+JQ
# ofM604qDy0B7AgMBAAGjggGLMIIBhzAOBgNVHQ8BAf8EBAMCB4AwDAYDVR0TAQH/
# BAIwADAWBgNVHSUBAf8EDDAKBggrBgEFBQcDCDAgBgNVHSAEGTAXMAgGBmeBDAEE
# AjALBglghkgBhv1sBwEwHwYDVR0jBBgwFoAUuhbZbU2FL3MpdpovdYxqII+eyG8w
# HQYDVR0OBBYEFKW27xPn783QZKHVVqllMaPe1eNJMFoGA1UdHwRTMFEwT6BNoEuG
# SWh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFRydXN0ZWRHNFJTQTQw
# OTZTSEEyNTZUaW1lU3RhbXBpbmdDQS5jcmwwgZAGCCsGAQUFBwEBBIGDMIGAMCQG
# CCsGAQUFBzABhhhodHRwOi8vb2NzcC5kaWdpY2VydC5jb20wWAYIKwYBBQUHMAKG
# TGh0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFRydXN0ZWRHNFJT
# QTQwOTZTSEEyNTZUaW1lU3RhbXBpbmdDQS5jcnQwDQYJKoZIhvcNAQELBQADggIB
# AIEa1t6gqbWYF7xwjU+KPGic2CX/yyzkzepdIpLsjCICqbjPgKjZ5+PF7SaCinEv
# GN1Ott5s1+FgnCvt7T1IjrhrunxdvcJhN2hJd6PrkKoS1yeF844ektrCQDifXcig
# LiV4JZ0qBXqEKZi2V3mP2yZWK7Dzp703DNiYdk9WuVLCtp04qYHnbUFcjGnRuSvE
# xnvPnPp44pMadqJpddNQ5EQSviANnqlE0PjlSXcIWiHFtM+YlRpUurm8wWkZus8W
# 8oM3NG6wQSbd3lqXTzON1I13fXVFoaVYJmoDRd7ZULVQjK9WvUzF4UbFKNOt50MA
# cN7MmJ4ZiQPq1JE3701S88lgIcRWR+3aEUuMMsOI5ljitts++V+wQtaP4xeR0arA
# VeOGv6wnLEHQmjNKqDbUuXKWfpd5OEhfysLcPTLfddY2Z1qJ+Panx+VPNTwAvb6c
# Kmx5AdzaROY63jg7B145WPR8czFVoIARyxQMfq68/qTreWWqaNYiyjvrmoI1VygW
# y2nyMpqy0tg6uLFGhmu6F/3Ed2wVbK6rr3M66ElGt9V/zLY4wNjsHPW2obhDLN9O
# TH0eaHDAdwrUAuBcYLso/zjlUlrWrBciI0707NMX+1Br/wd3H3GXREHJuEbTbDJ8
# WC9nR2XlG3O2mflrLAZG70Ee8PBf4NvZrZCARK+AEEGKMIIGrjCCBJagAwIBAgIQ
# BzY3tyRUfNhHrP0oZipeWzANBgkqhkiG9w0BAQsFADBiMQswCQYDVQQGEwJVUzEV
# MBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cuZGlnaWNlcnQuY29t
# MSEwHwYDVQQDExhEaWdpQ2VydCBUcnVzdGVkIFJvb3QgRzQwHhcNMjIwMzIzMDAw
# MDAwWhcNMzcwMzIyMjM1OTU5WjBjMQswCQYDVQQGEwJVUzEXMBUGA1UEChMORGln
# aUNlcnQsIEluYy4xOzA5BgNVBAMTMkRpZ2lDZXJ0IFRydXN0ZWQgRzQgUlNBNDA5
# NiBTSEEyNTYgVGltZVN0YW1waW5nIENBMIICIjANBgkqhkiG9w0BAQEFAAOCAg8A
# MIICCgKCAgEAxoY1BkmzwT1ySVFVxyUDxPKRN6mXUaHW0oPRnkyibaCwzIP5WvYR
# oUQVQl+kiPNo+n3znIkLf50fng8zH1ATCyZzlm34V6gCff1DtITaEfFzsbPuK4CE
# iiIY3+vaPcQXf6sZKz5C3GeO6lE98NZW1OcoLevTsbV15x8GZY2UKdPZ7Gnf2ZCH
# RgB720RBidx8ald68Dd5n12sy+iEZLRS8nZH92GDGd1ftFQLIWhuNyG7QKxfst5K
# fc71ORJn7w6lY2zkpsUdzTYNXNXmG6jBZHRAp8ByxbpOH7G1WE15/tePc5OsLDni
# pUjW8LAxE6lXKZYnLvWHpo9OdhVVJnCYJn+gGkcgQ+NDY4B7dW4nJZCYOjgRs/b2
# nuY7W+yB3iIU2YIqx5K/oN7jPqJz+ucfWmyU8lKVEStYdEAoq3NDzt9KoRxrOMUp
# 88qqlnNCaJ+2RrOdOqPVA+C/8KI8ykLcGEh/FDTP0kyr75s9/g64ZCr6dSgkQe1C
# vwWcZklSUPRR8zZJTYsg0ixXNXkrqPNFYLwjjVj33GHek/45wPmyMKVM1+mYSlg+
# 0wOI/rOP015LdhJRk8mMDDtbiiKowSYI+RQQEgN9XyO7ZONj4KbhPvbCdLI/Hgl2
# 7KtdRnXiYKNYCQEoAA6EVO7O6V3IXjASvUaetdN2udIOa5kM0jO0zbECAwEAAaOC
# AV0wggFZMBIGA1UdEwEB/wQIMAYBAf8CAQAwHQYDVR0OBBYEFLoW2W1NhS9zKXaa
# L3WMaiCPnshvMB8GA1UdIwQYMBaAFOzX44LScV1kTN8uZz/nupiuHA9PMA4GA1Ud
# DwEB/wQEAwIBhjATBgNVHSUEDDAKBggrBgEFBQcDCDB3BggrBgEFBQcBAQRrMGkw
# JAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBBBggrBgEFBQcw
# AoY1aHR0cDovL2NhY2VydHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VHJ1c3RlZFJv
# b3RHNC5jcnQwQwYDVR0fBDwwOjA4oDagNIYyaHR0cDovL2NybDMuZGlnaWNlcnQu
# Y29tL0RpZ2lDZXJ0VHJ1c3RlZFJvb3RHNC5jcmwwIAYDVR0gBBkwFzAIBgZngQwB
# BAIwCwYJYIZIAYb9bAcBMA0GCSqGSIb3DQEBCwUAA4ICAQB9WY7Ak7ZvmKlEIgF+
# ZtbYIULhsBguEE0TzzBTzr8Y+8dQXeJLKftwig2qKWn8acHPHQfpPmDI2AvlXFvX
# bYf6hCAlNDFnzbYSlm/EUExiHQwIgqgWvalWzxVzjQEiJc6VaT9Hd/tydBTX/6tP
# iix6q4XNQ1/tYLaqT5Fmniye4Iqs5f2MvGQmh2ySvZ180HAKfO+ovHVPulr3qRCy
# Xen/KFSJ8NWKcXZl2szwcqMj+sAngkSumScbqyQeJsG33irr9p6xeZmBo1aGqwpF
# yd/EjaDnmPv7pp1yr8THwcFqcdnGE4AJxLafzYeHJLtPo0m5d2aR8XKc6UsCUqc3
# fpNTrDsdCEkPlM05et3/JWOZJyw9P2un8WbDQc1PtkCbISFA0LcTJM3cHXg65J6t
# 5TRxktcma+Q4c6umAU+9Pzt4rUyt+8SVe+0KXzM5h0F4ejjpnOHdI/0dKNPH+ejx
# mF/7K9h+8kaddSweJywm228Vex4Ziza4k9Tm8heZWcpw8De/mADfIBZPJ/tgZxah
# ZrrdVcA6KYawmKAr7ZVBtzrVFZgxtGIJDwq9gdkT/r+k0fNX2bwE+oLeMt8EifAA
# zV3C+dAjfwAL5HYCJtnwZXZCpimHCUcr5n8apIUP/JiW9lVUKx+A+sDyDivl1vup
# L0QVSucTDh3bNzgaoSv27dZ8/DCCBY0wggR1oAMCAQICEA6bGI750C3n79tQ4ghA
# GFowDQYJKoZIhvcNAQEMBQAwZTELMAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lD
# ZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0LmNvbTEkMCIGA1UEAxMbRGln
# aUNlcnQgQXNzdXJlZCBJRCBSb290IENBMB4XDTIyMDgwMTAwMDAwMFoXDTMxMTEw
# OTIzNTk1OVowYjELMAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZ
# MBcGA1UECxMQd3d3LmRpZ2ljZXJ0LmNvbTEhMB8GA1UEAxMYRGlnaUNlcnQgVHJ1
# c3RlZCBSb290IEc0MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAv+aQ
# c2jeu+RdSjwwIjBpM+zCpyUuySE98orYWcLhKac9WKt2ms2uexuEDcQwH/MbpDgW
# 61bGl20dq7J58soR0uRf1gU8Ug9SH8aeFaV+vp+pVxZZVXKvaJNwwrK6dZlqczKU
# 0RBEEC7fgvMHhOZ0O21x4i0MG+4g1ckgHWMpLc7sXk7Ik/ghYZs06wXGXuxbGrzr
# yc/NrDRAX7F6Zu53yEioZldXn1RYjgwrt0+nMNlW7sp7XeOtyU9e5TXnMcvak17c
# jo+A2raRmECQecN4x7axxLVqGDgDEI3Y1DekLgV9iPWCPhCRcKtVgkEy19sEcypu
# kQF8IUzUvK4bA3VdeGbZOjFEmjNAvwjXWkmkwuapoGfdpCe8oU85tRFYF/ckXEaP
# ZPfBaYh2mHY9WV1CdoeJl2l6SPDgohIbZpp0yt5LHucOY67m1O+SkjqePdwA5EUl
# ibaaRBkrfsCUtNJhbesz2cXfSwQAzH0clcOP9yGyshG3u3/y1YxwLEFgqrFjGESV
# GnZifvaAsPvoZKYz0YkH4b235kOkGLimdwHhD5QMIR2yVCkliWzlDlJRR3S+Jqy2
# QXXeeqxfjT/JvNNBERJb5RBQ6zHFynIWIgnffEx1P2PsIV/EIFFrb7GrhotPwtZF
# X50g/KEexcCPorF+CiaZ9eRpL5gdLfXZqbId5RsCAwEAAaOCATowggE2MA8GA1Ud
# EwEB/wQFMAMBAf8wHQYDVR0OBBYEFOzX44LScV1kTN8uZz/nupiuHA9PMB8GA1Ud
# IwQYMBaAFEXroq/0ksuCMS1Ri6enIZ3zbcgPMA4GA1UdDwEB/wQEAwIBhjB5Bggr
# BgEFBQcBAQRtMGswJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNv
# bTBDBggrBgEFBQcwAoY3aHR0cDovL2NhY2VydHMuZGlnaWNlcnQuY29tL0RpZ2lD
# ZXJ0QXNzdXJlZElEUm9vdENBLmNydDBFBgNVHR8EPjA8MDqgOKA2hjRodHRwOi8v
# Y3JsMy5kaWdpY2VydC5jb20vRGlnaUNlcnRBc3N1cmVkSURSb290Q0EuY3JsMBEG
# A1UdIAQKMAgwBgYEVR0gADANBgkqhkiG9w0BAQwFAAOCAQEAcKC/Q1xV5zhfoKN0
# Gz22Ftf3v1cHvZqsoYcs7IVeqRq7IviHGmlUIu2kiHdtvRoU9BNKei8ttzjv9P+A
# ufih9/Jy3iS8UgPITtAq3votVs/59PesMHqai7Je1M/RQ0SbQyHrlnKhSLSZy51P
# pwYDE3cnRNTnf+hZqPC/Lwum6fI0POz3A8eHqNJMQBk1RmppVLC4oVaO7KTVPeix
# 3P0c2PR3WlxUjG/voVA9/HYJaISfb8rbII01YBwCA8sgsKxYoA5AY8WYIsGyWfVV
# a88nq2x2zm8jLfR+cWojayL/ErhULSd+2DrZ8LaHlv1b0VysGMNNn3O3AamfV6pe
# KOK5lDGCA3YwggNyAgEBMHcwYzELMAkGA1UEBhMCVVMxFzAVBgNVBAoTDkRpZ2lD
# ZXJ0LCBJbmMuMTswOQYDVQQDEzJEaWdpQ2VydCBUcnVzdGVkIEc0IFJTQTQwOTYg
# U0hBMjU2IFRpbWVTdGFtcGluZyBDQQIQBUSv85SdCDmmv9s/X+VhFjANBglghkgB
# ZQMEAgEFAKCB0TAaBgkqhkiG9w0BCQMxDQYLKoZIhvcNAQkQAQQwHAYJKoZIhvcN
# AQkFMQ8XDTIzMTExMzE1MzQwNFowKwYLKoZIhvcNAQkQAgwxHDAaMBgwFgQUZvAr
# MsLCyQ+CXc6qisnGTxmcz0AwLwYJKoZIhvcNAQkEMSIEIHLN3X0yEhRwsbHSwt51
# 0Myd6GnCZ94mRiNpI4PCK+ftMDcGCyqGSIb3DQEJEAIvMSgwJjAkMCIEINL25G3t
# dCLM0dRAV2hBNm+CitpVmq4zFq9NGprUDHgoMA0GCSqGSIb3DQEBAQUABIICAFrk
# ICNcPVE4Uw77MwI87lcLMJ1Rje3S5SQR2zpbNQMoYwFISWS4lpjmkkYooVf80tzH
# gD+tB0VlLblkSFcc8ymQ4iI/eWc7q27ysforaki6a16y6XmwKWu8prkpO3efF41o
# 5S3uVRLes7Zcz8/uhUHdcC4k8JeGmmPuX/fKPgPk2YOw4gcNcFk+Wus1lJuXrCYs
# iRnw+WDTBTKdG3EptSzOKBT5okTs++LM+ou1dSl5vUI8CViV6xdmj5vbA8mQoM7y
# AKcITnYI0aCIgFiWN/1ksjhBwfw9m4trvNf8Lc51LZgu2phE/Fb+PSZ8BBUKuHI3
# CtHwnqSzOs4Vxj/I/aeQOCPI0O44PvTkPS8xaj4ZjEWjfw9Q6IaJ7C5nNwYk70dR
# 8WY0VJcRG91NoVD5ckOjqRF2iOYP0TW3yA7d7KAJ72Ap+MbtflM8lXFV6wV39TyU
# 0/RhKQWA8EvWb5W+gKd024gPacxkW4F+A8vEF5SDzKgQ7zdXsketR16zzGsGPDhZ
# SWmujuNdtK3AgKMLHAoMLj3C1EzwKGJQB/CRmyHwzP0hrdJ0DLw8kuaxYj4+hiw7
# t9XiO9MIH5J/6pFNZBxIs5RPDO1EMhS/LCcBPOIt8DcmAfavdX0uowQYz37/SE4I
# X3F6T0QfwgbMLgLmeBrMRguWELTAy4sMXGaswGs2
# SIG # End signature block
