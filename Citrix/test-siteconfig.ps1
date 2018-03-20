<#
.SYNOPSIS
    Perform sanity checks against current Citrix configuration for the given AdminAddress. 
.DESCRIPTION
    Using the main checks that studio uses, just affirms that no problems exist in the delivery controller
.PARAMETER AdminAddress
    Primary Admin address for the site
.PARAMETER ErrorFile
    Infrastructure Error File to log to.
.PARAMETER OutputFile
    Infrastructure Output File.  
.NOTES 
.CHANGE CONTROL
    Adam Yarborough, 1.0    19/03/2018      Initial Creation
#>

function Test-ControllerConfig {
    Param (
        [parameter(Mandatory = $true, ValueFromPipeline = $true)]$AdminAddress,
        [parameter(Mandatory = $true, ValueFromPipeline = $true)]$ErrorFile,
        [parameter(Mandatory = $true, ValueFromPipeline = $true)]$OutputFile
    )
    $ControllersUp = 0
    $ControllersDown = 0
    $XDDeliveryControllers = Get-BrokerController -AdminAddress $AdminAddress
    Write-Verbose "Variables and Arrays Initialized"
   
    foreach ( $DeliveryController in $XDDeliveryControllers) {
        $Status = "Passed"
        Write-Verbose "Initialize Test Variables"
        Write-Verbose "Testing $($DeliveryController.MachineName)"
        $TestTarget = New-EnvTestDiscoveryTargetDefinition -AdminAddress $AdminAddress -TargetIdType "Infrastructure" -TestSuiteId "Infrastructure" -TargetId $DeliveryController.Uuid
        $TestResults = Start-EnvTestTask -AdminAddress $AdminAddress -InputObject $TestTarget
        foreach ( $Result in $TestResults.TestResults ) {
            foreach ( $Component in $Result.TestComponents ) {
                Write-Verbose "$($DeliveryController.MachineName) - $($Component.TestID) - $($Component.TestComponentStatus)"
                if ( ($Component.TestComponentStatus -ne "CompletePassed") -and ($Component.TestComponentStatus -ne "NotRun") ) {
                    "$($DeliveryController.MachineName) - $($Component.TestID) - $($Component.TestComponentStatus)" | Out-File $ErrorFile -append
                    $Status = "Component Failure"
                }
            } 
        }
        if ( $Status -eq "Passed" ) { $ControllersUp++ }
        else { $ControllersDown++ }
    }

    Write-Verbose "Writing Controller Config Data to output file"
    "controllerconfig,$ControllersUp,$ControllersDown" | Out-File $OutputFile
}

<#
.SYNOPSIS
    Perform sanity checks against current delivery group configuration for the given AdminAddress. 
.DESCRIPTION
    Using the main checks that studio uses, just affirms that no problems exist in the delivery controller
.PARAMETER AdminAddress
    Primary Admin address for the site
.PARAMETER ErrorFile
    Infrastructure Error File to log to.
.PARAMETER OutputFile
    Infrastructure Output File.  
.NOTES 
.CHANGE CONTROL
    Adam Yarborough, 1.0    19/03/2018      Initial Creation
#>
Function Test-DeliveryGroup {
    Param (
        [parameter(Mandatory = $true, ValueFromPipeline = $true)]$AdminAddress,
        [parameter(Mandatory = $true, ValueFromPipeline = $true)]$ErrorFile,
        [parameter(Mandatory = $true, ValueFromPipeline = $true)]$OutputFile
    )

    $DeliveryGroupUp = 0
    $DeliveryGroupDown = 0
    $XDDeliveryGroups = Get-BrokerDesktopGroup -AdminAddress $AdminAddress
    Write-Verbose "Variables and Arrays Initialized"

    foreach ( $DeliveryGroup in $XDDeliveryGroups ) {
        $Status = "Passed"
        Write-Verbose "Initialize Test Variables"
        Write-Verbose "Testing $($DeliveryGroup.Name)"
        $TestTarget = New-EnvTestDiscoveryTargetDefinition -AdminAddress $AdminAddress -TargetIdType "DesktopGroup" -TestSuiteId "DesktopGroup" -TargetId $DeliveryGroup.Uuid
        $TestResults = Start-EnvTestTask -AdminAddress $AdminAddress -InputObject $TestTarget

        foreach ( $Result in $TestResults.TestResults ) {
            foreach ( $Component in $Result.TestComponents ) {
                Write-Verbose "$($DeliveryGroup.Name) - $($Component.TestID) - $($Component.TestComponentStatus)"
                if ( $Component.TestComponentStatus -ne "CompletePassed" -and ($Component.TestComponentStatus -ne "NotRun") ) {
                    "$(DeliveryGroup.Name) - $($Component.TestID) - $($Component.TestComponentStatus)`n" | Out-File $ErrorFile -Append
                    $Status = "Component Failure"
                }
            }
        }
        if ( $Status -eq "Passed" ) { $DeliveryGroupUp++ }
        else { $DeliveryGroupDown++ }
    }

    Write-Verbose "Writing Delivery Group Data to output file"
    "deliverygroup,$DeliveryGroupUp,$DeliveryGroupDown" | Out-File $OutputFile
}

<#
.SYNOPSIS
    Perform sanity checks against current catalog configuration for the given AdminAddress. 
.DESCRIPTION
    Using the main checks that studio uses, just affirms that no problems exist in the delivery controller
.PARAMETER AdminAddress
    Primary Admin address for the site
.PARAMETER ErrorFile
    Infrastructure Error File to log to.
.PARAMETER OutputFile
    Infrastructure Output File.  
.NOTES 
.CHANGE CONTROL
    Adam Yarborough, 1.0    19/03/2018      Initial Creation
#>

function Test-Catalog {
    Param (
        [parameter(Mandatory = $true, ValueFromPipeline = $true)]$AdminAddress,
        [parameter(Mandatory = $true, ValueFromPipeline = $true)]$ErrorFile,
        [parameter(Mandatory = $true, ValueFromPipeline = $true)]$OutputFile
    )
    
    $CatalogUp = 0 
    $CatalogDown = 0
    $XDCatalogs = Get-BrokerCatalog -AdminAddress $AdminAddress 
    Write-Verbose "Variables and Arrays Initialized"

    foreach ( $Catalog in $XDCatalogs ) {
        $Status = "Passed"
        Write-Verbose "Initialize Test Variables"
        Write-Verbose "Testing $($Catalog.Name)"
        $TestTarget = New-EnvTestDiscoveryTargetDefinition -AdminAddress $AdminAddress -TargetIdType "Catalog" -TestSuiteId "Catalog" -TargetId $Catalog.Uuid
        $TestResults =Start-EnvTestTask -AdminAddress $AdminAddress -InputObject $TestTarget
        foreach ( $Result in $TestResults.TestResults ) {
            foreach ( $Component in $Result.TestComponents ) {
                Write-Verbose "$Catalog.Name - $($Component.TestID) - $($Component.TestComponentStatus)"
                if ( ($Component.TestComponentStatus -ne "CompletePassed") -and ($Component.TestComponentStatus -ne "NotRun") ) {
                    "$Catalog.Name - $($Component.TestID) - $($Component.TestComponentStatus)" | Out-file $ErrorFile -append
                    $Status = "Component Failure"
                }
            }            
        }
        if ( $Status -eq "Passed" ) { $CatalogUp++ }
        else { $CatalogDown++ }
    }

    Write-Verbose "Writing Catalog Data to output file"
    "catalog,$CatalogUp,$CatalogDown" | Out-File $OutputFile
}
function Test-CatalogAsync {
    Param (
        [parameter(Mandatory = $true, ValueFromPipeline = $true)]$AdminAddress,
        [parameter(Mandatory = $true, ValueFromPipeline = $true)]$ErrorFile,
        [parameter(Mandatory = $true, ValueFromPipeline = $true)]$OutputFile
    )
    
    $CatalogUp = 0 
    $CatalogDown = 0
    $XDCatalogs = Get-BrokerCatalog -AdminAddress $AdminAddress 
    Write-Verbose "Variables and Arrays Initialized"

    foreach ( $Catalog in $XDCatalogs ) {
        $Status = "Passed"
        Write-Verbose "Initialize Test Variables"
        Write-Verbose "Testing $($Catalog.Name)"
        $TestTarget = New-EnvTestDiscoveryTargetDefinition -AdminAddress $AdminAddress -TargetIdType "Catalog" -TestSuiteId "Catalog" -TargetId $Catalog.Uuid
        $TestResults = Start-EnvTestTask -AdminAddress $AdminAddress -InputObject $TestTarget -RunAsynchronously
        foreach ( $Result in $TestResults.TestResults ) {
            foreach ( $Component in $Result.TestComponents ) {
                Write-Verbose "$Catalog.Name - $($Component.TestID) - $($Component.TestComponentStatus)"
                if ( ($Component.TestComponentStatus -ne "CompletePassed") -and ($Component.TestComponentStatus -ne "NotRun") ) {
                    "$Catalog.Name - $($Component.TestID) - $($Component.TestComponentStatus)" | Out-file $ErrorFile -append
                    $Status = "Component Failure"
                }
            }            
        }
        if ( $Status -eq "Passed" ) { $CatalogUp++ }
        else { $CatalogDown++ }
    }

    Write-Verbose "Writing Catalog Data to output file"
    "catalog,$CatalogUp,$CatalogDown" | Out-File $OutputFile
}
<#
.SYNOPSIS
    Perform sanity checks against current hypervisor configuration for the given AdminAddress. 
.DESCRIPTION
    Using the main checks that studio uses, just affirms that no problems exist in the delivery controller
.PARAMETER AdminAddress
    Primary Admin address for the site
.PARAMETER ErrorFile
    Infrastructure Error File to log to.
.PARAMETER OutputFile
    Infrastructure Output File.  
.NOTES 
.CHANGE CONTROL
    Adam Yarborough, 1.0    19/03/2018      Initial Creation
#>
Function Test-HypervisorConnection {
    Param (
        [parameter(Mandatory = $true, ValueFromPipeline = $true)]$AdminAddress,
        [parameter(Mandatory = $true, ValueFromPipeline = $true)]$ErrorFile,
        [parameter(Mandatory = $true, ValueFromPipeline = $true)]$OutputFile
    )
    $HyperUp = 0
    $HyperDown = 0
    $HypervisorConnections = Get-BrokerHypervisorConnection -AdminAddress $AdminAddress

    foreach ($Connection in $HypervisorConnections) {
        $Status = "Passed"
        Write-Verbose "Initialize Test Variables"
        Write-Verbose "Testing $($Connection.Name)"

        $TestTarget = New-EnvTestDiscoveryTargetDefinition -AdminAddress $AdminAddress -TargetIdType "HypervisorConnection" -TestSuiteId "HypervisorConnection" -TargetId $Connection.HypHypervisorConnectionUid
        $TestResults = Start-EnvTestTask -AdminAddress $AdminAddress -InputObject $TestTarget -RunAsynchronously 
        foreach ( $Result in $TestResults.TestResults ) {
            foreach ( $Component in $Result.TestComponents ) {
                Write-Verbose "$($Connection.Name) - $($Component.TestID) - $($Component.TestComponentStatus)"
                if ( ($Component.TestComponentStatus -ne "CompletePassed") -and ($Component.TestComponentStatus -ne "NotRun") ) {
                    "$($Connection.Name) - $($Component.TestID) - $($Component.TestComponentStatus)" | Out-file $ErrorFile -Append
                    $Status = "Component Failure"
                }
            }

        }       
        if ( $Status -eq "Passed" ) { $HyperUp++ }
        else { $HyperDown++ }
        
        Write-Verbose "Testing associated resources"

        #$HypervisorResources = Get-ProvTask -AdminAddress $AdminAddress | select HostingUnitName, HostingUnitUid -Unique | where HostingUnitName -notlike ""
        $HypervisorResources = Get-ChildItem XDHyp:\HostingUnits\* -AdminAddress $AdminAddress | Where-Object HypervisorConnection -like $Connection.Name

        # Check the resources
        foreach ($Resource in $HypervisorResources ) {
            $Status = "Passed"
            $TestTarget = New-EnvTestDiscoveryTargetDefinition -AdminAddress $AdminAddress -TargetIdType "HostingUnit" -TestSuiteId "HostingUnit" -TargetId $Resource.HostingUnitUid
            $TestResults = Start-EnvTestTask -AdminAddress $AdminAddress -InputObject $TestTarget
            foreach ( $Result in $TestResults.TestResults ) {
                Write-Verbose "$($Resource.HostingUnitName) - $($Component.TestID) - $($Component.TestComponentStatus)"
                foreach ( $Component in $Result.TestComponents ) {
                    if ( ($Component.TestComponentStatus -ne "CompletePassed") -and ($Component.TestComponentStatus -ne "NotRun") ) {
                        "$($Resource.HostingUnitName) - $($Component.TestID) - $($Component.TestComponentStatus)`n" | Outfile $ErrorFile -append   
                        $Status = "Component Failure"
                    }
                }
            }
            if ( $Status -eq "Passed" ) { $HyperUp++ }
            else { $HyperDown++ }
        }
    }

    Write-Verbose "Writing Hypervisor Data to output file"
    "hypervisor,$HyperUp,$HyperDown" | Out-File $OutputFile
}

#This is just for me to test.

Function Test-SiteConfig { 
    Param(
        [parameter(Mandatory = $true, ValueFromPipeline = $true)]$AdminAddress
    )
    #   if ((Connect-Server $AdminAddress) -eq "Successful") { 
    Write-Verbose "Connected to $AdminAddress"

    # This is just to show they work.
    Test-ControllerConfig -AdminAddress $AdminAddress -ErrorFile "dc-error.txt" -OutputFile "dc-output.txt"
    Test-DeliveryGroup -AdminAddress $AdminAddress -ErrorFile "dg-error.txt" -OutputFile "dg-output.txt"
    
    Measure-Command { Test-CatalogAsync -AdminAddress $AdminAddress -ErrorFile "c-error.txt" -OutputFile "c-output.txt" }
    
    Measure-Command { Test-Catalog -AdminAddress $AdminAddress -ErrorFile "c-error.txt" -OutputFile "c-output.txt" } 
    
    Test-HypervisorConnection -AdminAddress $AdminAddress -ErrorFile "h-error.txt" -OutputFile "h-output.txt"
    #   }
    #   else {
    Write-Verbose "Unable to connect to $AdminAddress for Site Config test"
    #   }
}

Test-SiteConfig -AdminAddress "primary-ddc.domain.org"