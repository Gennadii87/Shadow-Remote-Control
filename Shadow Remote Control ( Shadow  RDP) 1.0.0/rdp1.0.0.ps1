 Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

function Show-RDPForm {
    param (
        [string]$ComputerName,
        [int]$SessionID,
        [string]$Username,
        [string]$Password
    )

    $form = New-Object System.Windows.Forms.Form
    $form.Text = 'RDP Connect'
    $form.Width = 400
    $form.Height = 400
    $form.StartPosition = 'CenterScreen'
    
    $menuStrip = New-Object System.Windows.Forms.MenuStrip
    $menuItem = $menuStrip.Items.Add('File')
    $menuItem.DropDownItems.Add('Exit').Add_Click({
        $form.Close()
    }) | Out-Null
    $form.Controls.Add($menuStrip)

    $labelGroup = New-Object System.Windows.Forms.Label
    $labelGroup.Text = 'Select user group:'
    $labelGroup.Height = 15
    $labelGroup.Location = New-Object System.Drawing.Point(10, 102)
    $form.Controls.Add($labelGroup)

    $comboBoxGroup = New-Object System.Windows.Forms.ComboBox
    $comboBoxGroup.Location = New-Object System.Drawing.Point(10, 125)
    $comboBoxGroup.Width = 200
    $comboBoxGroup.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList

    foreach ($group in $config) {
        $comboBoxGroup.Items.Add($group.GroupName)
    }
    
    $comboBoxGroup.Add_SelectedIndexChanged({
        $selectedGroup = $comboBoxGroup.SelectedItem.ToString()
        $comboBoxUser.Items.Clear()
    
        $config | Where-Object { $_.GroupName -eq $selectedGroup } | ForEach-Object {
            $_.Users | ForEach-Object {
                $comboBoxUser.Items.Add($_.Username)
            }
        }
    })

    $form.Controls.Add($comboBoxGroup)

    $labelComputer = New-Object System.Windows.Forms.Label
    $labelComputer.Text = 'Enter computer or IP address:'
    $labelComputer.Width = 200
    $labelComputer.Height = 15
    $labelComputer.Location = New-Object System.Drawing.Point(10, 50)
    $form.Controls.Add($labelComputer)

    $textBoxComputer = New-Object System.Windows.Forms.TextBox
    $textBoxComputer.Location = New-Object System.Drawing.Point(10, 70)
    $textBoxComputer.Width = 200
    $textBoxComputer.Text = $ComputerName 
    $form.Controls.Add($textBoxComputer)

    $labelUser = New-Object System.Windows.Forms.Label
    $labelUser.Text = 'Select user:'
    $labelUser.Height =15
    $labelUser.Location = New-Object System.Drawing.Point(10, 158)
    $form.Controls.Add($labelUser)

    $comboBoxUser = New-Object System.Windows.Forms.ComboBox
    $comboBoxUser.Location = New-Object System.Drawing.Point(10, 178)
    $comboBoxUser.Width = 200
    $comboBoxUser.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
    $form.Controls.Add($comboBoxUser)

    $labelPassword = New-Object System.Windows.Forms.Label
    $labelPassword.Text = 'Enter your password:'
    $labelPassword.Width = 200
    $labelPassword.Height = 15
    $labelPassword.Location = New-Object System.Drawing.Point(10, 210)
    $form.Controls.Add($labelPassword)

    $textBoxPassword = New-Object System.Windows.Forms.TextBox
    $textBoxPassword.Location = New-Object System.Drawing.Point(10, 232)
    $textBoxPassword.Width = 200
    $textBoxPassword.Height = 20
    $textBoxPassword.PasswordChar = '*'
    $form.Controls.Add($textBoxPassword)

    $buttonShowPassword = New-Object System.Windows.Forms.Button
    $buttonShowPassword.Text = 'Show Password:'
    $buttonShowPassword.Location = New-Object System.Drawing.Point(10, 270)
    $buttonShowPassword.Add_Click({
        if ($textBoxPassword.PasswordChar -eq '*') {
            $textBoxPassword.PasswordChar = 0
        } else {
            $textBoxPassword.PasswordChar = '*'
        }
    })
    $form.Controls.Add($buttonShowPassword)

    $buttonConnect = New-Object System.Windows.Forms.Button
    $buttonConnect.Text = 'Connect'
    $buttonConnect.Location = New-Object System.Drawing.Point(10, 300)
    $buttonConnect.BackColor = [System.Drawing.Color]::Blue
    $buttonConnect.ForeColor = [System.Drawing.Color]::White
    $buttonConnect.Add_Click({
        $selectedGroup = $comboBoxGroup.SelectedItem.ToString()
        $selectedUser = $comboBoxUser.SelectedItem.ToString()

        $selectedUserConfig = $config | Where-Object { $_.GroupName -eq $selectedGroup } | Select-Object -ExpandProperty Users | Where-Object { $_.Username -eq $selectedUser }

        $username = $selectedUserConfig.Username
        $password = $selectedUserConfig.Password
        $computer = $textBoxComputer.Text  

        Start-Process -FilePath "mstsc.exe" -ArgumentList "/v:$computer /shadow:$SessionID /prompt /control /noConsentPrompt /admin"

        Start-Sleep -Seconds 1

        [System.Windows.Forms.SendKeys]::SendWait($username)
        [System.Windows.Forms.SendKeys]::SendWait("{TAB}")
        [System.Windows.Forms.SendKeys]::SendWait($password)
        [System.Windows.Forms.SendKeys]::SendWait("{ENTER}")

        $form.Close()
    })
    $form.Controls.Add($buttonConnect)

    $comboBoxGroup.Add_SelectedIndexChanged({
        $selectedGroup = $comboBoxGroup.SelectedItem.ToString()
        $comboBoxUser.Items.Clear()
    
        if ($config | Where-Object { $_.GroupName -eq $selectedGroup }) {
            $textBoxComputer.Text = $config | Where-Object { $_.GroupName -eq $selectedGroup } | Select-Object -ExpandProperty Users | Select-Object -First 1 | Select-Object -ExpandProperty ComputerName
        } else {
            $textBoxComputer.Text = ""
        }
    
        $config | Where-Object { $_.GroupName -eq $selectedGroup } | ForEach-Object {
            $_.Users | ForEach-Object {
                $comboBoxUser.Items.Add($_.Username)
            }
        }
    })

    $textBoxComputer.Text = ""

    $comboBoxUser.Add_SelectedIndexChanged({
        $selectedGroup = $comboBoxGroup.SelectedItem.ToString()
        $selectedUser = $comboBoxUser.SelectedItem.ToString()

        $selectedUserConfig = $config | Where-Object { $_.GroupName -eq $selectedGroup } | Select-Object -ExpandProperty Users | Where-Object { $_.Username -eq $selectedUser }
        $textBoxPassword.Text = $selectedUserConfig.Password
    })

    $form.ShowDialog()
}

$scriptPath = $PSScriptRoot
$configPath = Join-Path -Path $scriptPath -ChildPath "config.json"
$config = Get-Content -Path $configPath -Raw -Encoding UTF8 | ConvertFrom-Json

Show-RDPForm -ComputerName $config[0].Users[0].ComputerName -SessionID $config[0].Users[0].SessionID -Username $config[0].Users[0].Username -Password $config[0].Users[0].Password

