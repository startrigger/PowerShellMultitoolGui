<# This form was initially created using POSHGUI.com  a free online gui designer for PowerShell
.NAME
    Multitool
#>

#Path to current running script.
$ErrorActionPreference = "stop"
$pathToScript = (split-path -parent $PSCommandPath)
$splitoption = [System.StringSplitOptions]::RemoveEmptyEntries
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

$Form                            = New-Object system.Windows.Forms.Form
$Form.ClientSize                 = '752,646'
$Form.text                       = "Multitool"
$Form.TopMost                    = $false

$ComboBox1_PickGroup             = New-Object system.Windows.Forms.ComboBox
$ComboBox1_PickGroup.text        = "Select a task"
$ComboBox1_PickGroup.BackColor   = "#7ed321"
$ComboBox1_PickGroup.width       = 736
$ComboBox1_PickGroup.height      = 20
$ComboBox1_PickGroup.DisplayMember = "cboDisplay"
$ComboBox1_PickGroup.ValueMember = "cboValue"
#@('Run Command','Network') | ForEach-Object {[void] $ComboBox1_PickGroup.Items.Add($_)}
$ComboBox1_PickGroup.location    = New-Object System.Drawing.Point(13,17)
$ComboBox1_PickGroup.Font        = 'Microsoft Sans Serif,10'
$ComboBox1_PickGroup.Sorted
$ComboBox1_PickGroup.Add_SelectionChangeCommitted({ ComboBox1PickGroup_SelectionChangeCommitted })

$ToolTip_ComboBox1PickGroup        = New-Object system.Windows.Forms.ToolTip
$ToolTip_ComboBox1PickGroup.ToolTipTitle  = "Select action to populate code block"
$ToolTip_ComboBox1PickGroup.isBalloon  = $true
$ToolTip_ComboBox1PickGroup.SetToolTip($ComboBox1_PickGroup,'Select action to populate code block.')

$TextBox_targets                = New-Object system.Windows.Forms.TextBox
$TextBox_targets.BackColor      = "#b8e986"
$TextBox_targets.text           = "Target List"
$TextBox_targets.multiline      = $true
$TextBox_targets.width          = 168
$TextBox_targets.height         = 565
$TextBox_targets.location       = New-Object System.Drawing.Point(18,52)
$TextBox_targets.Font           = 'Courier New,10'
$TextBox_targets.WordWrap       = $false
#docs for scrollbars in MS site show this for scroll bars but doesn't seem to work
#TextBox_targets.ScrollBars = System.Windows.Forms.ScrollBars.Vertical
$TextBox_targets.ScrollBars     = "Both"

$Button_TargetText               = New-Object system.Windows.Forms.Button
$Button_TargetText.text          = "Pop Targets (Code)"
$Button_TargetText.width         = 150
$Button_TargetText.height        = 30
$Button_TargetText.location      = New-Object System.Drawing.Point(200,120)
$Button_TargetText.Font          = 'Microsoft Sans Serif,10'
#$Button_TargetText.Add_Click({$TextBox_targets.Text = "vbahincav1`r`nvbachicav1"})
$Button_TargetText.Add_Click({ButtonRunTargetText})

$ToolTip_ButtonTargetText        = New-Object system.Windows.Forms.ToolTip
$ToolTip_ButtonTargetText.ToolTipTitle  = "Populate target text using code."
$ToolTip_ButtonTargetText.isBalloon  = $true
$ToolTip_ButtonTargetText.SetToolTip($Button_TargetText,'Use code from code block to populate target text area (left column).')

$Button_RunCodeBoxAction               = New-Object system.Windows.Forms.Button
$Button_RunCodeBoxAction.text          = "Run Code"
$Button_RunCodeBoxAction.width         = 147
$Button_RunCodeBoxAction.height        = 30
$Button_RunCodeBoxAction.location      = New-Object System.Drawing.Point(355,120)
$Button_RunCodeBoxAction.Font          = 'Microsoft Sans Serif,10'
$Button_RunCodeBoxAction.Add_Click({ButtonRunCodeBoxActionClick})

$ToolTip_RunCodeBoxAction              = New-Object system.Windows.Forms.ToolTip
$ToolTip_RunCodeBoxAction.ToolTipTitle = "Run code against targets."
$ToolTip_RunCodeBoxAction.isBalloon    = $true
$ToolTip_RunCodeBoxAction.SetToolTip($Button_RunCodeBoxAction,'Run action specified in code block with targets (left column).')

$Button_CheckOutputToggle               = New-Object system.Windows.Forms.Button
$Button_CheckOutputToggle.text          = "Check Output"
$Button_CheckOutputToggle.width         = 147
$Button_CheckOutputToggle.height        = 30
$Button_CheckOutputToggle.location      = New-Object System.Drawing.Point(510,120)
$Button_CheckOutputToggle.Font          = 'Microsoft Sans Serif,10'
$Button_CheckOutputToggle.Add_Click({ButtonCheckOutputToggleClick})

$ToolTip_CheckOutputToggle              = New-Object system.Windows.Forms.ToolTip
$ToolTip_CheckOutputToggle.ToolTipTitle = "Check output."
$ToolTip_CheckOutputToggle.isBalloon    = $true
$ToolTip_CheckOutputToggle.SetToolTip($Button_CheckOutputToggle,'Check the output files and display contents if output present.')

$CheckBox_NoOutputFile                    = New-Object system.Windows.Forms.CheckBox
$CheckBox_NoOutputFile.text               = "No Output"
$CheckBox_NoOutputFile.AutoSize           = $true
$CheckBox_NoOutputFile.width              = 104
$CheckBox_NoOutputFile.height             = 20
$CheckBox_NoOutputFile.location           = New-Object System.Drawing.Point(660,120)
$CheckBox_NoOutputFile.Font               = 'Microsoft Sans Serif,10'

$ToolTip_NoOutputFile              = New-Object system.Windows.Forms.ToolTip
$ToolTip_NoOutputFile.ToolTipTitle = "Check output."
$ToolTip_NoOutputFile.isBalloon    = $true
$ToolTip_NoOutputFile.SetToolTip($CheckBox_NoOutputFile,'Check if Cmd prompt output only.  Textbox on form will not be able to show output.')

$TextBox_TopDesc                = New-Object system.Windows.Forms.TextBox
$TextBox_TopDesc.BackColor      = "#b8e986"
$TextBox_TopDesc.text           = "Combobox selection Description"
$TextBox_TopDesc.multiline      = $true
$TextBox_TopDesc.width          = 550
$TextBox_TopDesc.height         = 65
$TextBox_TopDesc.location       = New-Object System.Drawing.Point(200,52)
$TextBox_TopDesc.Font           = 'Microsoft Sans Serif,10'
$TextBox_TopDesc.ReadOnly       = $true 
$TextBox_TopDesc.ScrollBars     = "Vertical"

$TextBox_Code                   = New-Object system.Windows.Forms.TextBox
$TextBox_Code.BackColor         = "#b8e986"
$TextBox_Code.text              = "Combobox selection Code"
$TextBox_Code.multiline         = $true
$TextBox_Code.width             = 550
$TextBox_Code.height            = 100
$TextBox_Code.location          = New-Object System.Drawing.Point(200,160)
$TextBox_Code.WordWrap          = $false
$TextBox_Code.Font              = 'Courier New,10'
#$TextBox_Code.ReadOnly          = $true 
$TextBox_Code.ScrollBars        = "Both"

$TextBox_Output                   = New-Object system.Windows.Forms.TextBox
$TextBox_Output.BackColor         = "#b8e986"
$TextBox_Output.text              = "Output textbox`r`n"
$TextBox_Output.multiline         = $true
$TextBox_Output.width             = 550
$TextBox_Output.height            = 330
$TextBox_Output.location          = New-Object System.Drawing.Point(200,280)
$TextBox_Output.Font              = 'Courier New,10'
$TextBox_Output.WordWrap          = $false
#$TextBox_Output.ReadOnly          = $true 
$TextBox_Output.ScrollBars        = "Both"

$Form.controls.AddRange(@($ComboBox1_PickGroup,$TextBox_targets,$Button_TargetText,$Button_RunCodeBoxAction,$Button_CheckOutputToggle,$CheckBox_NoOutputFile,$TextBox_TopDesc,$TextBox_Code,$TextBox_Output))

Function Add-Output {
    Param ($Message)
    # Sample of function use: Add-Output -Message "Adding line to textbox"
    $TextBox_Output.AppendText("`r`n$Message")
    $TextBox_Output.Refresh()
    $TextBox_Output.ScrollToCaret()
}

Function Add-Target {
    Param ($Message)
    # Sample of function use: Add-Output -Message "Adding line to textbox"
    $TextBox_targets.AppendText("`r`n$Message")
    $TextBox_targets.Refresh()
    $TextBox_targets.ScrollToCaret()
}

function ComboBox1PickGroup_SelectionChangeCommitted {
    $arrValue = ($ComboBox1_PickGroup.SelectedItem).cboValue.split("++++++")
    $TextBox_TopDesc.Text = $arrValue[0]
    if (($arrValue[0].split("#",$splitoption))[0].trim() -eq "script") {
        $TextBox_Code.text = "#(" + $ComboBox1_PickGroup.SelectedIndex.ToString() + ")`r`n#" + ($ComboBox1_PickGroup.SelectedItem).cboDisplay + "`r`n" + $arrValue[1..($arrValue.length-1)]
    } else {
        if (Test-Path ("$pathToScript\multitoolscripts\" + ($ComboBox1_PickGroup.SelectedItem).cboValue.split("++++++",$splitoption)[1])) {
            $TextBox_Code.text = (get-content ("$pathToScript\multitoolscripts\" + ($ComboBox1_PickGroup.SelectedItem).cboValue.split("++++++",$splitoption)[1]) -Delimiter "`r`n")
        } else {
            $TextBox_Code.text = "File not found in $pathToScript\multitoolscripts\" + ($ComboBox1_PickGroup.SelectedItem).cboValue.split("++++++",$splitoption)[1]
        }
    }
}

function ButtonRunTargetText {
    Invoke-Expression $TextBox_Code.Text
    $TextBox_Output.Text = "Total Targets: " + $arrTarget.Length.ToString()
    $origOFS = $OFS
    $OFS = "`r`n"        
    $TextBox_Targets.Text = $arrTarget
    $OFS = $origOFS        
}

function ButtonRunCodeBoxActionClick {
    $origOFS = $OFS
    #Using * asterick as delimiter for array as string $OFS.  Change if needed
    $OFS = "*"        
    $arrTarget = ($TextBox_targets.Text).Split("`n") | %{$_.trim()}
    #Using * asterick as delimiter for array as string $OFS.  Change if needed
    $BtnCode = '$arrTarget = "' + $arrTarget + '".Split("*")' + "`r`n" +$TextBox_Code.Text
    $OFS = $origOFS
    $TextBox_Output.Text = $BtnCode + "`r`n -------------------------------------------------------`r`n`r`n"
    #Need to escape " with \" in order to pass commands(script) as argument to powershell.exe
    $processCommand = $BtnCode.replace('"','\"')
    if ($CheckBox_NoOutputFile.Checked) {
        Start-Process -FilePath PowerShell -ArgumentList "-NoExit -NoProfile -ExecutionPolicy Bypass -Command & {$processCommand}"
        $TextBox_Output.text = "No Outputtext checked.`r`nStrip the 'exit' from the code before running.`r`n"
    } else {
        $processCommand = $processCommand + "`r`n exit"
        Start-Process -FilePath PowerShell -ArgumentList "-NoExit -NoProfile -ExecutionPolicy Bypass -Command & {$processCommand}" -RedirectStandardOutput "$pathToScript\multitoolOutput.txt" -RedirectStandardError "$pathToScript\multitoolError.txt"    
    }
    ButtonCheckOutputToggleClick
}

Function ButtonCheckOutputToggleClick {
    if (Test-Path "$pathToScript\multitoolOutput.txt" -PathType Leaf) { 
        if (Get-Content "$pathToScript\multitoolOutput.txt") {
            $TextBox_Output.Text = $TextBox_Output.Text + ((date).ToString()) + "`r`n" +  (Get-Content "$pathToScript\multitoolOutput.txt" -Delimiter "`r`n") + "----------------------`r`n"
        } else {$TextBox_Output.Text = $TextBox_Output.Text + ((date).ToString()) + " Not output yet.`r`n---------------------------`r`n"}
    } else {
        $TextBox_Output.Text = $TextBox_Output.Text + "----------------------" + (date).ToString() + " No Output generated yet.`r`n"
    }
    if (Test-Path "$pathToScript\multitoolError.txt" -PathType Leaf) { 
        if (Get-Content "$pathToScript\multitoolOutput.txt") {
            $TextBox_Output.Text = $TextBox_Output.Text + ((date).ToString()) + "`r`n" +  (Get-Content "$pathToScript\multitoolError.txt" -Delimiter "`r`n") + "----------------------`r`n"
        } else {$TextBox_Output.Text = $TextBox_Output.Text + ((date).ToString()) + " Not errors yet.`r`n---------------------------`r`n"}
    } else {
        $TextBox_Output.Text = $TextBox_Output.Text + "----------------------" + (date).ToString() + " No Errors generated yet.`r`n"
    }
    $TextBox_Output.Select()
    $TextBox_Output.ScrollToCaret()
    $Button_CheckOutputToggle.Select()
}

function CreateComboboxItem {
    Param ([string]$cbodisplay="display", [string]$cbovalue="value")
    #function to creat objects for adding display and value to combobox items
    #$ComboBox1_PickGroup.DisplayMember = "cboDisplay"
    #$ComboBox1_PickGroup.ValueMember = "cboValue"
    $cboObject = New-Object -TypeName PSObject
    $cboObject | Add-Member -Type NoteProperty -Name cboDisplay -Value $cbodisplay
    $cboObject | Add-Member -Type NoteProperty -Name cboValue -Value $cbovalue
    return $cboObject
}

#populate combo box
#@((CreateComboboxItem -cboDisplay "Run Command" -cbovalue "disp1"),(CreateComboboxItem -cboDisplay 'Network' -cbovalue 'disp2')) | ForEach-Object {[void] $ComboBox1_PickGroup.Items.Add($_)}

#Sample combo box entry for checking hotfix from powershell in variable in this script, single quotes to prevent var expansion:
#Note, using '++++++' as delimiter for description text box entry and code entry.  Description further seperated using # for script/file, example below is script
#File would be script loaded from seperate file in 'multitoolscripts' folder in same directory as this form script.:
$pscript = @'
    script#Uses powershell commandlet to check for hotfixes on target systems.  ++++++
    $hotfixes = "KB4012216", "KB4012217", "KB4012218", "KB4012219", "KB4012220", "KB4012598", "KB4012606", "KB4013198", "KB4013429", "KB4015217", "KB4015219", "KB4015221", "KB4015549", "KB4015550", "KB4015551", "KB4015552", "KB4015553", "KB4015554", "KB4016635", "KB4016636", "KB4016637", "KB4019213", "KB4019214", "KB4019215", "KB4019216", "KB4019217", "KB4019218", "KB4019263", "KB4019264", "KB4019265", "KB4019472", "KB4019473", "KB4019474", "KB4022719", "KB4022168", "KB4022722", "KB4022726", "KB4022717", "KB4022723", "KB4022715", "KB4023680"
    # Search for the HotFixes
    $arrTarget| %{$_; Get-HotFix -ComputerName $_ | Where-Object {$hotfixes -contains $_.HotfixID} | Select-Object -property "HotFixID", "InstalledOn"}
'@
[void] $ComboBox1_PickGroup.Items.Add((CreateComboboxItem -cboDisplay "Check Hotfix" -cbovalue $pscript))
$pscript = @'
    file#Check loading of file.++++++GetHotFix.ps1
'@
[void] $ComboBox1_PickGroup.Items.Add((CreateComboboxItem -cboDisplay "Check Hotfix multiple hosts" -cbovalue $pscript))


# All code that is visible to form must be inserted before this line.
$Form.ShowDialog()