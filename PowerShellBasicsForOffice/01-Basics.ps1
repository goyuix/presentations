# Basics
# This is a comment
Get-Help
Get-Command
Get-Member

# Variables
$name = 'Greg'
$env:COMPUTERNAME

# Piping
@() | Get-Member

# Control Structures
if ($true) { "Tis True" } else { "Must Be False" }
do { "The Neverending Story" } while ($true)
foreach ($num in 1..5) { $num * 10 }
1..5 | ForEach-Object { $_ * 2 }
