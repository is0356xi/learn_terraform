param(
    [parameter(mandatory=$true)][string]$folder_path,
    [parameter(mandatory=$true)][string]$search_filetype,
    [parameter(mandatory=$true)][string]$search_str
)

remove-item result.txt
$folder_paths = (get-childitem -Recurse -Directory $folder_path | %{$_.FullName})

foreach ($folder in $folder_paths){
    $files = (get-childitem -Recurse $folder -Filter $search_filetype | %{$_.FullName})

    foreach ($file in $files){
        echo "-------------------------------"
        $file 
        # findstr /N $search_str $file | out-file -append result.txt
        findstr /N $search_str $file
    }
}


