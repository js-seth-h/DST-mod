
"to-be-a-fighter","to-do-chores" | ForEach-Object {
	 
	Remove-Item "ds-$($_)"  -Force -Recurse 
	copy-item $_ "ds-$($_)" -force -recurse -verbose

	cd "ds-$($_)" 
	(Get-Content modinfo.lua)  | Foreach-Object {
		$_ -replace 'api_version = 10','api_version = 6'
	} | Out-File  -Encoding utf8 modinfo.lua
 
	../bomremover .  "modinfo.lua" 
	cd .. 

}

 