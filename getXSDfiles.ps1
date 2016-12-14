param ([string]$SourcePATH, [string]$DestinationPATH)

$sourceDir = '.\XSD\'
$targetDir = '.\results\'

$arrFiles = "Cena",
"DajDetailDietetickejPotraviny_Request",
"DajDetailDietetickejPotraviny_Response",
"DajDetailInformacieZnalostnehoSystemu_Request",
"DajDetailInformacieZnalostnehoSystemu_Response",
"DajDetailLieciva_Request",
"DajDetailLieciva_Response",
"DajDetailLieku_Request",
"DajDetailLieku_Response",
"DajDetailMagistraliterPripravku_Request",
"DajDetailMagistraliterPripravku_Response",
"DajDetailReceptu_Response",
"DajDetailZdravotnickejPomocky_Request",
"DajDetailZdravotnickejPomocky_Response",
"DajEReceptLekaren_Request",
"Davkovanie",
"DoplnNeuplnyERecept_Response",
"EN13606-demographics",
"EN13606-extract",
"EN13606-restrictions",
"EN13606-RM",
"Mnozstvo",
"MPD_IdCiselniky",
"MPD_Identifikatory",
"MPD_OIDCiselniky",
"MPD_OIDJRUZ",
"MPD_Strankovanie",
"NotifikujOEReceptoch_Request",
"NotifikujOEReceptoch_Response",
"OverAlergie_Request",
"OverAlergie_Response",
"OverDavkovanie_Request",
"OverDavkovanie_Response",
"OverInterakcie_Request",
"OverInterakcie_Response",
"OverKontraindikacie_Request",
"OverKontraindikacie_Response",
"OverObjemLiekov_Request",
"OverObjemLiekov_Response",
"OverPreskripcneObmedzenia_Request",
"OverPreskripcneObmedzenia_Response",
"OverZnalostnymSystemom_Request",
"OverZnalostnymSystemom_Response",
"StornujERecept_Response",
"StornujMedikacnyZaznam_Response",
"StornujVydajZEReceptu_Request",
"StornujVydajZEReceptu_Response",
"SysCheckConfiguration_Response",
"TS14796-dataTypes",
"VstupyPreZnalostnySystem",
"VyhladajDietetickePotraviny_Request",
"VyhladajDietetickePotraviny_Response",
"VyhladajDispenzacneZaznamy_Request",
"VyhladajERecepty_Request",
"VyhladajEReceptyLekaren_Request",
"VyhladajFiltrovanyZoznamMedikacnejHistorie_Request",
"VyhladajFiltrovanyZoznamMedikacnejHistorie_Response",
"VyhladajLieciva_Request",
"VyhladajLieciva_Response",
"VyhladajLieky_Request",
"VyhladajLieky_Response",
"VyhladajMagistraliterPripravky_Request",
"VyhladajMagistraliterPripravky_Response",
"VyhladajMedikacneZaznamy_Request",
"VyhladajZdravotnickePomocky_Request",
"VyhladajZdravotnickePomocky_Response",
"VystupneVarovanieMedikacie",
"ZablokujERecept_Response",
"ZapisERecept_Response",
"ZapisMedikacnyZaznam_Response",
"ZapisNeuplnyERecept_Response",
"ZapisVydajZEReceptu_Response",
"ZdravotnickyPracovnikOU",
"ZdrojInformacieZS",
"ZnalostnaInformacia",
"ZneplatniERecept_Response",
"ZneplatniMedikacnyZaznam_Response"

$IncludedArray = New-Object System.Collections.ArrayList
$ImportedArray = New-Object System.Collections.ArrayList


function IncludedTrimStringXML([string]$s)
{
	$idxStart = $s.LastIndexOf("/")
	$idxEnd = $s.LastIndexOf(".xsd")
	$temps = $s.Substring( $idxStart+1, $idxEnd-$idxStart-1 )
	$temps = $temps.TrimStart('schemaLocation="')
	[void] $IncludedArray.Add($temps)    
}

function ImportedTrimStringXML([string]$s)
{
	$idxStart = $s.LastIndexOf("/")
	$idxEnd = $s.LastIndexOf(".xsd")
	$temps = $s.Substring( $idxStart+1, $idxEnd-$idxStart-1 )
	$temps = $temps.TrimStart('schemaLocation="')
	[void] $ImportedArray.Add($temps)
}

#====================================================================
# Script usage
#====================================================================
function Usage
{
@"
    Usage: 
    
	./getXSDfiles.ps1 <SourcePATH> <DestinationPATH>
	
	<SourcePATH> folder contains all .xsd files
	<DestinationPATH> destination folder, MPD related .xsd files are copied here 
        
"@
    return
}

#====================================================================
# Initialization
#====================================================================
function Init
{    
	cls
}

#====================================================================
# Function reads sections xs:include and xs:import and loads
#  all files from these sections to IncludedArray and ImportedArray
#====================================================================
function LoadAllIncluded
{
	Get-ChildItem $sourceDir -Recurse | % {
   		$dest = $targetDir + $_.Name
		If ( $arrFiles -contains ($_.Name.Replace(".xsd","")) ) {
			#[xml]$userfile = Get-Content $dest
			[xml]$userfile = Get-Content $_.FullName
			$includedfiles = $userfile.schema.include
			foreach ($ifile in $includedfiles) {
				#Write-Output $ifile
				IncludedTrimStringXML($ifile.Attributes[0].OuterXml.ToString())
			}
			#Write-Output $includedfiles.Count

			$importedfiles = $userfile.schema.import
			foreach ($imfile in $importedfiles) {
				#Write-Output $imfile
				ImportedTrimStringXML($imfile.Attributes[1].OuterXml.ToString())
			}
			#Write-Output $importedfiles.Count
		}
	}	
}

#====================================================================
# Function creates target destination folder for .XSD files and then copy
#  all files from lists arrfiles, IncludedArray and ImportedArray in there
#====================================================================
function CreateAndCopy
{
	mkdir $targetDir -Force
	Get-ChildItem $sourceDir -Recurse | % {
   		$dest = $targetDir + $_.Name	
		#If ($_.Name -eq "TS14796-dataTypes.xsd") {
		#	Write-Output "issue file:"
		#	Write-Output $_.Name
		#	Write-Output $_.FullName
		#	Write-Output $dest
		#	Write-Output ($ImportedArray -contains ($_.Name.Replace(".xsd","")))
		#	Write-Output $_.Name.Replace(".xsd","")
		#	Write-Output $ImportedArray
		#}
		If ( ($arrFiles -contains ($_.Name.Replace(".xsd",""))) -or ($IncludedArray -contains ($_.Name.Replace(".xsd",""))) -or ($ImportedArray -contains ($_.Name.Replace(".xsd",""))) ) 
		{
			Copy-Item $_.FullName -Destination $dest -Force
		}
	}	
}

#====================================================================
# MAIN
#====================================================================
function Main
{    
	Init

	#Write-Output "Params:"
	#Write-Output $SourcePATH
	#Write-Output $DestinationPATH
	
	If (($SourcePATH -eq $null) -or ($SourcePATH -eq '')  -or ($DestinationPATH -eq $null) -or ($DestinationPATH -eq '') ) 
	{
		Usage
		return
	}
	else {
		$sourceDir = $SourcePATH
		$targetDir = $DestinationPATH

		if ( !($targetDir[-1] -eq '\') ) {
			$targetDir = $targetDir + '\'
		} 
		#Write-Output $targetDir
		LoadAllIncluded
		CreateAndCopy
		#Write-Output "IncludedArray:"
		#Write-Output $IncludedArray
		#Write-Output "ImportedArray:"
		#Write-Output $ImportedArray
	}
}

Main
