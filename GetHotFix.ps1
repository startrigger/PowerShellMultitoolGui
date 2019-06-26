# Edit following list of hotfixes as you see fit.
$hotfixes = "KB4012216", "KB4012217", "KB4012218", "KB4012219", "KB4012220", "KB4012598", "KB4012606", "KB4013198", "KB4013429", "KB4015217", "KB4015219", "KB4015221", "KB4015549", "KB4015550", "KB4015551", "KB4015552", "KB4015553", "KB4015554", "KB4016635", "KB4016636", "KB4016637", "KB4019213", "KB4019214", "KB4019215", "KB4019216", "KB4019217", "KB4019218", "KB4019263", "KB4019264", "KB4019265", "KB4019472", "KB4019473", "KB4019474", "KB4022719", "KB4022168", "KB4022722", "KB4022726", "KB4022717", "KB4022723", "KB4022715", "KB4023680"

foreach($system in $arrTarget) {
    $hotfix = Get-HotFix -ComputerName $system | Where-Object {$hotfixes -contains $_.HotfixID} | Select-Object -property "HotFixID", "InstalledOn"

    # See if the HotFix was found
    if ($hotfix) {
	for ($intCt=0; $intCt -lt $hotfix.HotFixID.length; $intCt++) {
        	$system + ": " + $hotfix.HotFixID[$intCt] + " installed on " +  $hotfix.InstalledOn[$intCt]
	}
	"`r`n"
    } else {
        $system + ": Didn't Find HotFix"
    }
}