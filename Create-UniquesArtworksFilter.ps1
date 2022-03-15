#Questions? Message me Thanos#6505 on Discord.
#Set-ExecutionPolicy -ExecutionPolicy RemoteSigned
#Removed Replicas from items. They don't drop.

$DefaultLeagueName = "Archnemesis"
$LeagueName = Read-Host -Prompt "League Name, Spelling must be exact - Default ($DefaultLeagueName)"
$LeagueName = ($DefaultLeagueName,$LeagueName)[[bool]$LeagueName]

$DefaultChaosValue = 2
$ChaosValue = Read-Host -Prompt "Minimum Chaos value per Unique item - Default ($DefaultChaosValue)"
$ChaosValue = ($DefaultChaosValue,$ChaosValue)[[bool]$ChaosValue]

function Create-UniqueFilter {
    [CmdletBinding()]
    param(
	    [Parameter()]
	    $ChaosValue,
            [Parameter()]
            [string]$LeagueName
        )

        Write-Host "Your Chaos Value Is:" $ChaosValue -BackgroundColor DarkGreen
        Write-Host "Your League Is:" $LeagueName -BackgroundColor DarkGreen
        function Find-ItemArt {
            [CmdletBinding()]
    	        param(
		        [Parameter(Mandatory)]
		        [string] $NinjaItem
	            )
                    #Write-Host "Find Art name for Item:" $NinjaItem -BackgroundColor DarkGray
                    $FilteredItem =  $NinjaItem -replace " ","_" -replace "'",""
                    $POEDBURL =  "https://poedb.tw/us/$FilteredItem"
                    $ItemQueryInfo = Invoke-WebRequest -Uri $POEDBURL -UseBasicParsing
                    $ItemArt = ((((($ItemQueryInfo.RawContent) -split '\r?\n') | Where-Object {$_ -like '*art/2DItems/*'}) -split "<td>") | Where-Object {$_ -like "Art/2DItems/*"}) -replace "</td></tr><tr>",""
                    $ItemArtFilter = $ItemArt | Where-Object {$_ -notlike "Art/2DItems/Hideout*"}
                    $ItemArtFilter
                    }

        #Pull Unique Item Prices from poe.ninja
        #Unique Armours
        $UniqueArmoursURL = "https://poe.ninja/api/data/ItemOverview?league=$LeagueName&type=UniqueArmour&language=en"
        $UniqueArmoursRAW = Invoke-RestMethod -Method Get -Uri $UniqueArmoursURL

        #Unique Accessory
        $UniqueAccessoryURL = "https://poe.ninja/api/data/ItemOverview?league=$LeagueName&type=UniqueAccessory&language=en"
        $UniqueAccessoryRAW = Invoke-RestMethod -Method Get -Uri $UniqueAccessoryURL

        #Unique Flasks
        $UniqueFlasksURL = "https://poe.ninja/api/data/ItemOverview?league=$LeagueName&type=UniqueFlask&language=en"
        $UniqueFlasksRAW = Invoke-RestMethod -Method Get -Uri $UniqueFlasksURL

        #Unique Jewels
        $UniqueJewelsURL = "https://poe.ninja/api/data/ItemOverview?league=$LeagueName&type=UniqueJewel&language=en"
        $UniqueJewelsRAW = Invoke-RestMethod -Method Get -Uri $UniqueJewelsURL

        #Unique Weapons
        $UniqueWeaponsURL = "https://poe.ninja/api/data/ItemOverview?league=$LeagueName&type=UniqueWeapon&language=en"
        $UniqueWeaponsRAW = Invoke-RestMethod -Method Get -Uri $UniqueWeaponsURL

        #Filter results by chaos value
        $ValuedItems = $null
        $ValuedItems = $UniqueArmoursRAW.lines | Where-Object {$_.chaosValue -ge $ChaosValue -and $_.links -ne 5 -and $_.links -ne 6 -and $_.name -notlike "Replica *"} | Select Name -Unique
        $ValuedItems += $UniqueAccessoryRAW.lines | Where-Object {$_.chaosValue -ge $ChaosValue -and $_.name -notlike "Replica *"} | Select Name -Unique
        $ValuedItems += $UniqueFlasksRAW.lines | Where-Object {$_.chaosValue -ge $ChaosValue -and $_.name -notlike "Replica *"} | Select Name -Unique
        $ValuedItems += $UniqueJewelsRAW.lines | Where-Object {$_.chaosValue -ge $ChaosValue -and $_.name -notlike "Replica *"} | Select Name -Unique
        $ValuedItems += $UniqueWeaponsRAW.lines | Where-Object {$_.chaosValue -ge $ChaosValue -and $_.links -ne 5 -and $_.links -ne 6 -and $_.name -notlike "Replica *"} | Select Name -Unique
        
        #Total Unique Items
        Write-Host "Total Unique Items for your chaos value. You should have" $ValuedItems.Count "lines in UniquesArtwork.txt" -BackgroundColor DarkBlue        
        #Construct Filter file

        $AllItemValues = $ValuedItems.Name | Where-Object {$_ -ne ""} | ForEach-Object {
            Write-Host "Finding Unique Art Info for:" $_ -BackgroundColor DarkGray
            Find-ItemArt -NinjaItem $_
        }

        #Total Unique Items
        Write-Host "Total Unique Items for your chaos value. You should have" $ValuedItems.Count "lines in UniquesArtwork.txt" -BackgroundColor DarkBlue

        #Save Dialog
        Add-Type -AssemblyName System.Windows.Forms
        $SaveDialog = New-Object System.Windows.Forms.SaveFileDialog
        $SaveDialog.SupportMultiDottedExtensions = $true
        $SaveDialog.InitialDirectory = "C:\"
        $SaveDialog.Filter = "Text files (*.txt)|*.txt"
        $SaveDialog.FileName = "UniquesArtworks.txt"
        
        if ($AllItemValues){
            if($SaveDialog.ShowDialog() -eq 'Ok'){
                $AllItemValues | Out-File ($SaveDialog.FileName) 
            }
        }
            Else{
            Write-Host "Something is broken. Contact Thanos on Discord" -BackgroundColor DarkMagenta
            }
        
        Read-Host -Prompt "Press any key to continue"
}

Create-UniqueFilter -ChaosValue $ChaosValue -LeagueName $LeagueName
