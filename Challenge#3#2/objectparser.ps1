function jsonparser{
     param(
         $Jsondata,
         $key
     
     )

     $data=$Jsondata  | ConvertFrom-Json
     $array_key=$key.trim('/') -split '/'
     
     if($array_key.length -ne 0)
     {
         for ([int] $i=0; $i -le ($array_key.length -1 ); $i++)
         {
            $key=$array_key[$i]
            $data=$data.$key
            if($i -eq ($array_key.length-1))
            {
               $result=$data
               return $result
               
            }
            
         }

     } 
   
}

$JSON = @'
    {
        "Rule": [{
            "MPName": "ManagementPackProject",
            "Request": "Apply",
            "Category": "Rule",
            "RuleId": {
                "1300": "false",
                "1304": "true"
            }
        }]
    }
'@

#test case1 passing key rule/ruleid
$result=jsonparser $JSON 'rule/ruleid'
Write-Output ($result | ConvertTo-Json)

#test case2 passing key rule/category
$result=jsonparser $JSON 'rule/category'
Write-Output ($result | ConvertTo-Json)

#test case3 passing key 'rule/abcd'
$result=jsonparser $JSON 'rule/abcd'
Write-Output ($result | ConvertTo-Json)

#test case 4 passing key 'rule1'
$result=jsonparser $JSON 'rule1'
Write-Output ($result | ConvertTo-Json)

