$OutputEncoding = [System.Text.Encoding]::UTF8
$disks = Get-WmiObject -Query "SELECT * from Win32_DiskDrive"

foreach ($disk in $disks)
{
	if ($disk.Partitions -eq 0)
	{
		wsl --mount $disk.DeviceID --bare
	}
}
