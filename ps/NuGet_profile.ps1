function global:ef()
{		
    $efcorefile = join-path $dte.Solution.FullName "..\efcore.json" -resolve

	if(test-path $efcorefile) 
	{
		$efcoreconf = Get-Content $efcorefile | ConvertFrom-Json
	}
    
    $cmd = "dotnet ef $args"

    function proj(){
        get-project $args | select -expand fullname
    }
    
    if($efcoreconf.project) {
        $cmd = "$cmd --project $(proj $efcoreconf.project)"
    }
    
    if($efcoreconf.startupProject) {
        $cmd = "$cmd --startup-project $(proj $efcoreconf.startupProject)"
    }
        
    if($efcoreconf.framework) {
        $cmd = "$cmd --framework $($efcoreconf.framework)"
    }
    
    write-host "$cmd"
    iex "$cmd"

}