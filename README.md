# PowerShellMultitoolGui
Convert of my HTA multitool GUI for vbscripts to Powershell

This project is a 'conversion' of my HTA for vbscripts.  Primary purpose of the GUI is to facilitate powershell scripts into a gui (.net controls).  You can add powershell scripts directly or organize them into files.  Did this over the weekend so still pretty rough and not completely documented.

The GUI is designed so that you can easily modify a powershell script and use it on multiple systems and 'sorta' organize them from a dropdown list control using name space like naming to order them.  The GUI is designed to display the code in a text control so that they can be modified and then executed on a list of targets.  Targets can be systems or other objects you wish to apply the powershell code too.


Explaination of controls so far:
Pop Targets (Code): Used to populate the target list from code you selected from drop down list.  You don't need to use this as you can copy and paste or just type in the targets directly into target text box.
Run Code: Runs the code you have selected displayed in code text box.  The code can be edited in the code textbox before running it.
Check Output:  Displays output of code execution if seperate output files are created, the 'No Output' checkbox isn't selected.  If the 'No Output' checkbox is selected, output isn't stored to files for later display.

No Output (checkbox): If this box is checked, output isn't stored or displayed in output text area.  The output stays in the powershell window that is launched.  The powershell window will also stay open for inspection later.  If this checkbox isn't checked, 2 files store the output of the process, these file names are hardcoded, multitoolOutput.txt and multitoolErrir.txt.  If the Check Output button is pressed, the file contents are displayed in the output text area.  The powershell window after the command is run will also close automaticaly (exit).


How to add select list item:
#Sample combo box entry for checking hotfixes from powershell in variable 'in this script', single quotes to prevent var expansion:
#Note, using '++++++' as delimiter for description text box entry and code entry.  Description further seperated using # for script/file, example below is script
#File would be script loaded from seperate file in 'multitoolscripts' folder in same directory as this form script.:
$pscript = @'
    script#Uses powershell commandlet to check for hotfixes on target systems.  ++++++
    $hotfixes = "KB4012216", "KB4012217", "KB4012218"
    # Search for the HotFixes
    $arrTarget| %{$_; Get-HotFix -ComputerName $_ | Where-Object {$hotfixes -contains $_.HotfixID} | Select-Object -property "HotFixID", "InstalledOn"}
'@
[void] $ComboBox1_PickGroup.Items.Add((CreateComboboxItem -cboDisplay "Check Hotfix" -cbovalue $pscript))


This line:
script#Uses powershell commandlet to check for hotfixes on target systems.  ++++++
is required to seperate the script from the description.  The script is displayed in the textbox for showing script and the description is displayed in the textbox for displaying a description of the script.  This line further uses # operator to distinguish from script stored in the form script itself and from a sperate file.

Example of list item for script stored in a seperate file from multitoolgui.ps1 script, form script.  
$pscript = @'
    file#Check loading of file.++++++GetHotFix.ps1
'@
[void] $ComboBox1_PickGroup.Items.Add((CreateComboboxItem -cboDisplay "Check Hotfix multiple hosts" -cbovalue $pscript))

Note the same format for the first line for $pscript.  This time 'file' is used instead of script before the # symbol.  The files are sought for in the same location as multitoolgui.ps1 file under the folder multitoolscripts.  In the example, GetHotFix.ps1 will be loaded from the multitoolscripts\GetHotFix.ps1.

The format for creating the scripts are pretty basic.  The target text box contents are converted to string arrays.  The script you want to add must have ability to either take a array of strings or objects as a default parameter, see example for hotfix above, $arrTarget is pipled to the get-hotfix commandlet, or be written to so that target array can be looped through.  Example follows:

$hotfixes = "KB4012216", "KB4012217"
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

The target array will be constructed using the $arrTarget variable so the code you use must also reference it.
