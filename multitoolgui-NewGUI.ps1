[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
[xml]$xamlCode = @'
<Window 
		xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
		xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"

        Title="MultiToolGUI" Height="450" Width="800">
    <Grid Name="gridMain">
        <Grid.ColumnDefinitions>
            <ColumnDefinition Width="*" />
            <ColumnDefinition Width="5" />
            <ColumnDefinition Width="*" />
        </Grid.ColumnDefinitions>
        <Grid.RowDefinitions>
            <RowDefinition Height="*" />
            <RowDefinition Height="5" />
            <RowDefinition Height="*" />
        </Grid.RowDefinitions>
        <GridSplitter Grid.Column="1" HorizontalAlignment="Stretch" Margin="0,0,0,5" Grid.RowSpan="2" />
        <TextBox Name="TextBox_targets" Margin="5,5,6,5" TextWrapping="NoWrap" Text="Target List" FontFamily="Courier New" Padding="5,5,5,5" ScrollViewer.CanContentScroll="True" ScrollViewer.HorizontalScrollBarVisibility="Visible" ScrollViewer.VerticalScrollBarVisibility="Auto" AllowDrop="True" Focusable="True" Grid.RowSpan="3" />
        <GridSplitter Grid.Column="2" Grid.Row="1" Height="5" ResizeDirection="Rows" HorizontalAlignment="Stretch" />
        <ComboBox Name="ComboBox1_PickGroup" Grid.Column="2" HorizontalAlignment="Stretch" Margin="20,10,10,0" VerticalAlignment="Top" RenderTransformOrigin="0.558,-0.681" Height="22" ToolTip="Select task from list" DisplayMemberPath="cboDisplay" Text="Select Task" />
		<Button Name="Button_TargetText" Grid.Column="2" Content="Pop Targets (code)" HorizontalAlignment="Left" Margin="22,88,0,0" VerticalAlignment="Top" RenderTransformOrigin="0.391,-0.749" Height="20" Width="110" ToolTip="Populate target text using code."/>
        <Button Name="Button_RunCodeBoxAction" Grid.Column="2" Content="Run Code" HorizontalAlignment="Left" Margin="144,88,0,0" VerticalAlignment="Top" RenderTransformOrigin="-0.114,-1" Height="20" Width="60" ToolTip="Run code against targets."/>
        <Button Name="Button_CheckOutputToggle" Grid.Column="2" Content="Check Output" HorizontalAlignment="Left" Margin="214,88,0,0" VerticalAlignment="Top" Height="20" Width="79" RenderTransformOrigin="0.562,0.552" ToolTip="Display output in output block."/>
        <CheckBox Name="CheckBox_NoOutputFile" Grid.Column="2" Content="No Output" HorizontalAlignment="Left" Margin="306,90,0,0" VerticalAlignment="Top" RenderTransformOrigin="0.497,-0.66" Height="18" Width="82" ToolTip="Run in own shell, output displayed there."/>
		<TextBox Name="TextBox_TopDesc" Grid.Column="2" HorizontalAlignment="Stretch" Margin="20,49,10,10" TextWrapping="Wrap" Text="Description" VerticalAlignment="Top" Height="25"/>
        <TextBox Name="TextBox_Code" Grid.Column="2" HorizontalAlignment="Stretch" TextWrapping="NoWrap" Text="CodeBlock" VerticalAlignment="Stretch" RenderTransformOrigin="0.496,0.528" Margin="20,114,10,10" ScrollViewer.HorizontalScrollBarVisibility="Auto" ScrollViewer.VerticalScrollBarVisibility="Auto" FontFamily="Courier New" />
        <TextBox Name="TextBox_Output" Grid.Column="2" HorizontalAlignment="Stretch" Margin="20,10,10,10" Grid.Row="2" TextWrapping="NoWrap" Text="Output" VerticalAlignment="Stretch" RenderTransformOrigin="0.504,0.474" ScrollViewer.HorizontalScrollBarVisibility="Auto" ScrollViewer.VerticalScrollBarVisibility="Auto" FontFamily="Courier New"/>
    </Grid>

</Window>
'@

$reader = (New-Object System.Xml.XmlNodeReader $xamlCode)
$GUI = [Windows.Markup.XamlReader]::Load($reader)

$xamlCode.SelectNodes("//*[@Name]") | ForEach-Object { Set-Variable -Name ($_.Name) -Value $GUI.FindName($_.Name) }

#Vars used in various functions
$ErrorActionPreference = "stop"
$pathToScript = (split-path -parent $PSCommandPath)
$splitoption = [System.StringSplitOptions]::RemoveEmptyEntries

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
    #if (($arrValue[0].split("#",$splitoption))[0].trim() -eq "script") {
	if ($arrValue[0].substring(0,$arrValue[0].indexof("#")).trim() -eq "script") {
		#$TextBox_Code.text = "#(" + $ComboBox1_PickGroup.SelectedIndex.ToString() + ")`r`n#" + ($ComboBox1_PickGroup.SelectedItem).cboDisplay + "`r`n" + ($arrValue[($arrValue.length-1)] -split '\n' | %{ $_ + "`r`n"})
		$TextBox_Code.text = "#" + ($ComboBox1_PickGroup.SelectedItem).cboDisplay + "`r`n" + ($arrValue[($arrValue.length-1)] -split '\n' | %{ $_ + "`r`n"})
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
	$useInvokeCommand = $false
    $origOFS = $OFS
    #Using * asterick as delimiter for array as string $OFS.  Change if needed
    $OFS = "*"        
	#Check to see if invoke-command is selected, search for "#Invoke-Command" in one of the lines.
	$TextBox_Code.Text.split("`r`n")|%{if ($_.indexof("#Invoke-Command") -gt -1){$useInvokeCommand = $true; $true}} | select-object -first 1
	#Need code to deal with spaces in target list entries.  Otherwise may cause problems especially with files or paths with spaces in it.
	$arrTarget = ($TextBox_targets.Text).Split("`n") | %{$_.trim()}
    #Using * asterick as delimiter for array as string $OFS.  Change if needed
	$strDelimiter = "*"
	if ($useInvokeCommand -eq $false)
		{$BtnCode = '$arrTarget = "' + $arrTarget + '".Split("' + $strDelimiter + '")' + "`r`n" +$TextBox_Code.Text}
	else {
		#strip Lines with # in 1st position after trim and strip empty lines.
		$BtnCode = ""
		$TextBox_Code.Text.split("`r`n").trim() | %{if ($_.indexof("#") -ne 0 -and $_.length -gt 0){ $BtnCode = $BtnCode + ($_.replace("`n","")) + "`r`n"}}
		$BtnCode = '$strCode = ' + " {`r`n" + $BtnCode + "}`r`n"
		$BtnCode = $BtnCode + '$arrTarget = "' + $arrTarget + '".Split("' + $strDelimiter + '")' + "`r`n"
		#$BtnCode = $BtnCode + '$arrTarget| %{invoke-command -cn $_ -scriptblock $strCode}'
		$BtnCode = $BtnCode + '$arrTarget| %{if(test-connection $_ -count 1 -quiet){invoke-command -cn $_ -scriptblock $strCode} else {"Ping Failed for $_"}}'
		$TextBox_Output.Text = $BtnCode
	}
	$OFS = $origOFS
    #Need to escape " with \" in order to pass commands(script) as argument to powershell.exe
    $processCommand = $BtnCode.replace('"','\"')
	
	#if ($CheckBox_NoOutputFile.Checked) {	#WPF version of control uses different property name for checked from windows.form
	if ($CheckBox_NoOutputFile.isChecked) {
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
            $TextBox_Output.Text = $TextBox_Output.Text + "`r`n" + ((date).ToString()) + "`r`n" +  (Get-Content "$pathToScript\multitoolOutput.txt" -Delimiter "`r`n") + "----------------------`r`n"
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
    #$TextBox_Output.Select()	#XAML version of control doesn't have this method.
    #$TextBox_Output.ScrollToCaret()	#XAML version of control doesn't have this method.
    #$Button_CheckOutputToggle.Select()	#XAML version of control doesn't have this method.
}

function CreateComboboxItem {
    #function to creat objects for adding display and value to combobox items
    Param ([string]$cbodisplay="display", [string]$cbovalue="value")
    #$ComboBox1_PickGroup.DisplayMember = "cboDisplay"
    #$ComboBox1_PickGroup.ValueMember = "cboValue"
    $cboObject = New-Object -TypeName PSObject
    $cboObject | Add-Member -Type NoteProperty -Name cboDisplay -Value $cbodisplay
    $cboObject | Add-Member -Type NoteProperty -Name cboValue -Value $cbovalue
    return $cboObject
}

Function Get-FileName($initialDirectory)
{
	if (test-path $initialDirectory) {
		[System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") |	Out-Null		
		$OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
		$OpenFileDialog.initialDirectory = $initialDirectory
		$OpenFileDialog.Multiselect = $true
		$OpenFileDialog.filter = "All files (*.*)| *.*"
		$OpenFileDialog.ShowDialog() | Out-Null
		$OpenFileDialog.filenames
	} else {"Initial folder not found: " + $initialDirectory}
} #end function Get-FileName

#Add events for controls on form.
$ComboBox1_PickGroup.Add_DropDownClosed({ ComboBox1PickGroup_SelectionChangeCommitted }) 
#$ComboBox1_PickGroup.Add_SelectionChangeCommitted({ ComboBox1PickGroup_SelectionChangeCommitted })
#$ComboBox1_PickGroup.ValueMember = "cboValue"
#$ComboBox1_PickGroup.Sorted      = $true
#$ComboBox1_PickGroup.AutoSize    = $true
$Button_TargetText.Add_Click({ButtonRunTargetText})
$Button_RunCodeBoxAction.Add_Click({ButtonRunCodeBoxActionClick})
$Button_CheckOutputToggle.Add_Click({ButtonCheckOutputToggleClick})

#populate combo box
#@((CreateComboboxItem -cboDisplay "Run Command" -cbovalue "disp1"),(CreateComboboxItem -cboDisplay 'Network' -cbovalue 'disp2')) | ForEach-Object {[void] $ComboBox1_PickGroup.Items.Add($_)}
#$pscript|format-hex  #This lets you look at hex output to see what line seperator is.
#0A 09 seperates the hex output lines.  0A is LF (Line Feed), 09 is HT (Horizontal Tab)  For this case, \n is used.

#Sample combo box entry for checking hotfix from powershell in variable in this script, single quotes to prevent var expansion:
#Note, using '++++++' as delimiter for description text box entry and code entry.  Description further seperated using # for script/file, example below is script
#File would be script loaded from seperate file in 'multitoolscripts' folder in same directory as this form script.:
$pscript = @'
    script#Run code block using invoke-command.  ++++++
	# Run block of code using invoke-command.  Note, interactive code won't run and will hang the sesssion.
	"$env:computername output start:"
	# Place code between start and end comment statement
	# Start code block
	
	# End code block
	"$env:computername output end:"
'@
[void] $ComboBox1_PickGroup.Items.Add((CreateComboboxItem -cboDisplay "Invoke-Command" -cbovalue $pscript))
$pscript = @'
    script#Uses powershell commandlet to check for hotfixes on target systems.  ++++++
    $hotfixes = "KB4012216", "KB4012217", "KB4012218", "KB4012219", "KB4012220", "KB4012598", "KB4012606", "KB4013198", "KB4013429", "KB4015217", "KB4015219", "KB4015221", "KB4015549", "KB4015550", "KB4015551", "KB4015552", "KB4015553", "KB4015554", "KB4016635", "KB4016636", "KB4016637", "KB4019213", "KB4019214", "KB4019215", "KB4019216", "KB4019217", "KB4019218", "KB4019263", "KB4019264", "KB4019265", "KB4019472", "KB4019473", "KB4019474", "KB4022719", "KB4022168", "KB4022722", "KB4022726", "KB4022717", "KB4022723", "KB4022715", "KB4023680"
    # Search for the HotFixes
    $arrTarget| %{$_; Get-HotFix -cn $_ | Where-Object {$hotfixes -contains $_.HotfixID} | Select-Object -property "HotFixID", "InstalledOn"}
'@
[void] $ComboBox1_PickGroup.Items.Add((CreateComboboxItem -cboDisplay "Check Hotfix" -cbovalue $pscript))
#Reboot Computers
$pscript = @'
    script#Reboot computers using the shutdown command, don't need to add credentials to command other than user context.  Restart-computer requires -credential parameter.  ++++++
    # /r restart otherwise shutsdown system
    $arrTarget | %{$_; shutdown /r /m \\$_}
'@
[void] $ComboBox1_PickGroup.Items.Add((CreateComboboxItem -cboDisplay "Reboot or Shutdown system with shutdown.exe" -cbovalue $pscript))
#Reg Query
$pscript = @'
    script#Uses Command Line to Req Query systems in target list.  ++++++
    # Req Query, for help "reg query /?"
    # Sample reg paths
	# reg query "\\VBAMGYPRT01\HKLM\SYSTEM\CurrentControlSet\services\SNMP\Parameters" /s
    # Reg Query "\\VBAMGYPRT01\HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Printers" /S | Out-GridView
    # Reg Query "\\VBAMGYPRT01\HKLM\Software\Microsoft\Cryptography\OID\Encoding Type 0\CertDllCreateCertificateChainEngine\Config\Default" /v WeakSha1ThirdPartyFlags
    # Uncomment following to use invoke-command instead
    # $arrTarget| %{if(test-connection $_ -count 1 -quiet){$_;  invoke-command -cn $_ -scriptblock {Reg Query "HKLM\Software\Microsoft\Windows\CurrentVersion\Uninstall" /S}} else {"Ping Failed for $_"}}
    $arrTarget| %{if(test-connection $_ -count 1 -quiet){$_; Reg Query "\\$_\HKLM\Software\Microsoft\Windows\CurrentVersion\Uninstall" /S} else {"Ping Failed for $_"}}
'@
[void] $ComboBox1_PickGroup.Items.Add((CreateComboboxItem -cboDisplay "Reg Query Systems in list" -cbovalue $pscript))
#Reg Query for SNMP parameters
$pscript = @'
    script#Uses Command Line to Req Query systems in target list.  ++++++
    # Req Query, for help "reg query /?"
    # Sample reg paths
	# reg query "\\VBAMGYPRT01\HKLM\SYSTEM\CurrentControlSet\services\SNMP\Parameters" /s
    # Reg Query "\\VBAMGYPRT01\HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Printers" /S | Out-GridView
    # Reg Query "\\VBAMGYPRT01\HKLM\Software\Microsoft\Cryptography\OID\Encoding Type 0\CertDllCreateCertificateChainEngine\Config\Default" /v WeakSha1ThirdPartyFlags
    # Uncomment following to use invoke-command instead
    # $arrTarget| %{if(test-connection $_ -count 1 -quiet){$_;  invoke-command -cn $_ -scriptblock {Reg Query "HKLM\Software\Microsoft\Windows\CurrentVersion\Uninstall" /S}} else {"Ping Failed for $_"}}
    $arrTarget| %{if(test-connection $_ -count 1 -quiet){$_; Reg Query "\\$_\HKLM\SYSTEM\CurrentControlSet\services\SNMP\Parameters\ValidCommunities" /S} else {"Ping Failed for $_"}}
'@
[void] $ComboBox1_PickGroup.Items.Add((CreateComboboxItem -cboDisplay "Reg Query SNMP parameters" -cbovalue $pscript))
#Sample populating target textblock
$pscript = @'
    script#Populate target list with files from a folder.  ++++++
	#$arrTarget = Get-ChildItem c:\windows -File | %{$_.fullname}
	$arrTarget = Get-FileName(c:)
'@
[void] $ComboBox1_PickGroup.Items.Add((CreateComboboxItem -cboDisplay "Populate target block with Files" -cbovalue $pscript))
#Generate file hash for target list files
$pscript = @'
    script#Generates hash based on files in target list.  ++++++
    # 
    # Available algorithms for -Algorithm parameter below.  Edit before running.
	# SHA1
    # SHA256
    # SHA384
    # SHA512
    # MD5
	$arrTarget| %{if(test-path $_ ){Get-FileHash -Algorithm MD5 $_} else {"Target not found $_"}}
'@
[void] $ComboBox1_PickGroup.Items.Add((CreateComboboxItem -cboDisplay "Generate hash values from target list" -cbovalue $pscript))
# All code that is visible to form must be inserted before this line.
$GUI.ShowDialog() | out-null