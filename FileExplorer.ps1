Add-Type -AssemblyName System.Windows.Forms

$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ 
    InitialDirectory = [Environment]::GetFolderPath('Desktop') 
    Filter = 'Varonis Output Files (*.csv)|*.csv'
}

$null = $FileBrowser.ShowDialog()
