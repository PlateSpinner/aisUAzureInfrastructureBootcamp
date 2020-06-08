function Get-RandomPassword {
    param (
        $pLength
    )    
    $SegmentTypes = "[
        {
            'Number': 1,
            'MinimumRandom': 65,
            'MaximumRandom': 91
        },
        {
            'Number': 2,
            'MinimumRandom': 97,
            'MaximumRandom': 122
        },
        {
            'Number': 3,
            'MinimumRandom': 48,
            'MaximumRandom': 58
        },
        {
            'Number': 4,
            'MinimumRandom': 37,
            'MaximumRandom': 47
        }
    ]" | ConvertFrom-Json
    $PasswordSegments = @()
    do{
        $Fourtet = @()    
        do{
            $SegmentsToAdd = @()
            foreach($SegmentType in $SegmentTypes){
                if($Fourtet -notcontains $SegmentType.Number){$SegmentsToAdd+=$SegmentType.Number}
            }
            $RandomSegment = Get-Random -InputObject $SegmentsToAdd
            $Fourtet += $RandomSegment
            $PasswordSegments += $RandomSegment
        }until($Fourtet.Count -ge 4 -or $PasswordSegments.Count -ge $pLength)    
    }until($PasswordSegments.Count -ge $pLength)
    $RandomPassword = $null
    foreach($PasswordSegment in $PasswordSegments){
        $SegmentType=$null;$SegmentType = $SegmentTypes | Where-Object -Property Number -EQ -Value $PasswordSegment    
        $RandomPassword += [char](Get-Random -Minimum $SegmentType.MinimumRandom -Maximum $SegmentType.MaximumRandom)
    }
    $RandomPassword
}
$s1 = "Richardson, Clint <Clint.Richardson@appliedis.com>; Fertig, Jason <Jason.Fertig@appliedis.com>; Walter, Steven <Steven.Walter@AppliedIS.com>; Nelson, Bob <Bob.Nelson@appliedis.com>Hawk, Francesca <Francesca.Hawk@AppliedIS.com>; Tucker, Dustin <Dustin.Tucker@appliedis.com>; LeBlanc, Christopher <christopher.leblanc@appliedis.com>; Mason, Zoe <Zoe.Mason@AppliedIS.com>; Anderson, Daryl <Daryl.Anderson@AppliedIS.com>; King, Veronica <Veronica.King@appliedis.com>; Pham, David <David.Pham@AppliedIS.com>; Hebert, Kerri <Kerri.Hebert@appliedis.com>; Saheb, Musthafa <Musthafa.Saheb@appliedis.com>; Smith, Quintin <Quintin.Smith@AppliedIS.com>; Abell, Johnny <Johnny.Abell@appliedis.com>; Hnat, Joshua <Joshua.Hnat@appliedis.com>; Tsegaye, Mewael (Mo) <Mewael.Tsegaye@appliedis.com>"
$list = @()
$subnet1 = "10."
$subnet2 = 161
foreach($s2 in ($s1.Split(";").replace(" ","")))
{
    $S3 = $s2.split("<").replace(">","")
    $firstName = $s3[0].Split(",")[1].replace(" ","")
    $lastName = $s3[0].Split(",")[0].replace(" ","")
    $list += New-Object -TypeName PSObject -Property @{"LastName"=$lastName
                                                       "FirstName"=$firstName
                                                       "FullName"=($firstName + " " + $lastName)
                                                       "Username"=($firstName + "." + $lastName).ToLower()
                                                       "email"=$s3[1].replace(" ","").toLower()
                                                       "password"=(get-randompassword -pLength 9)
                                                       "supernet"=($subnet1 + [string]$subnet2 + ".0.0/16")}
    $subnet2 += 1  
}
$list | Select-Object FirstName, LastName, FullName, Username, email, password, supernet |  ConvertTo-Csv -NoTypeInformation