
function new-PowerCLI_ESXCLIv2_Function{
	param(
	$ToAnalyse
	)
	process{
	
		$FullNameSpace = $ToAnalyse.Fullname -replace "vim.", ""
		$ShortName = $ToAnalyse.Name 
		#write-Host "$FullName  AND $ShortName"	
		
		#Line below will be executed only once for the esxcliv2 "root object" because it doesn't have a function "childelements" and no methods defined at this level.
		if($ToAnalyse.gettype().fullname -eq 'VMware.VimAutomation.ViCore.Impl.V1.EsxCli.EsxCliImpl'){
			$ToAnalyse | Get-Member -MemberType CodeProperty | foreach-object{
			$CodePropertyName = $_.Name
			new-PowerCLI_ESXCLIv2_Function -ToAnalyse $ToAnalyse.$CodePropertyName
			}
		}
		Else{

			#/////Identify all methods associated to this namespace, and generate a PowerCLI Function for each of them.
			$ToAnalyse.methods | foreach-object{
			$MethodName = $_.name
			#Write-host "MethodName $MethodName"
			
				$FunctionName = $MethodName + "-" + $FullNameSpace
				$Global:Stream.WriteLine("function $FunctionName{")#Start of the function
					
					#////Help section
					$Global:Stream.WriteLine('<#')
					
					$Global:Stream.WriteLine('.SYNOPSIS')
					$MethodHelp = $ToAnalyse.$MethodName.help().help
					$Global:Stream.WriteLine($MethodHelp)
					
					$Global:Stream.WriteLine("")					
					$Global:Stream.WriteLine('.DESCRIPTION')
					$Global:Stream.WriteLine('This function provide access via Power-Cli to the esxcli equivalent function.')
					$Global:Stream.WriteLine('All parameters and help associated to the original esxcli function are available.')
					$Global:Stream.WriteLine('This function is based on the original get-esxcli -v2 PowerCLI cmdlet')
					$Global:Stream.WriteLine('A PowerCli VMHost object is a mandatory parameter')
					$Global:Stream.WriteLine('It is also possible to pipe VMhost objects to execute this function accross many hosts in one operation')	

					$Global:Stream.WriteLine('')
					$Global:Stream.WriteLine('.NOTES')
					$Global:Stream.WriteLine('Author: Christophe Calvet')
					$Global:Stream.WriteLine('Blog: http://www.thecrazyconsultant.com/get-esxcli_on_steroids')
					
					if($ToAnalyse.$MethodName.help().param){
						$ToAnalyse.$MethodName.help().param | foreach-object{
						$Global:Stream.WriteLine('')
						
						
						$DisplayName = $_.DisplayName
							#Fix an issue with some variable that have already a meaning in PowerShell.
							If(($DisplayName -eq "host") -or ($DisplayName -eq "profile") -or ($DisplayName -eq "version") -or ($DisplayName -eq "debug")){
							$DisplayName = $DisplayName + "2"
							}
							
						#The parameter that have "-" in the name is esxcli, do not have it in get-esxcli
						$DisplayNameFixed = $DisplayName -replace "-",""
						$SringParameter = ".PARAMETER " + $DisplayNameFixed
						$Global:Stream.WriteLine($SringParameter)
						$ParameterHelp = $_.Help
						$Global:Stream.WriteLine($ParameterHelp)
						}
					}
					
					$Global:Stream.WriteLine('')
					$Global:Stream.WriteLine(".PARAMETER VMHost")
					$Global:Stream.WriteLine("One or many PowerCli VMHost object")	

					$Global:Stream.WriteLine('')
					$Global:Stream.WriteLine('.EXAMPLE')
					$Global:Stream.WriteLine('Some examples are available in the blog')
				
					$Global:Stream.WriteLine('#>')					
					
					#Add the cmdlebinding for better debug
					$NewOutputWithTab = "`t" +'[CmdletBinding()]'
					$Global:Stream.WriteLine($NewOutputWithTab)		
					
					#////Parameter section
					$NewOutputWithTab = "`t" +'param('
					$Global:Stream.WriteLine($NewOutputWithTab)					
					
					if($ToAnalyse.$MethodName | gm | where {$_.Name -eq 'CreateArgs'}){
						$Args = $ToAnalyse.$MethodName.CreateArgs()
							$Args.getEnumerator() | foreach-object{
							$Key = $_.Key
							#Fix an issue with some variable that have already a meaning in PowerShell.
							If(($Key -eq "host") -or ($Key -eq "profile") -or ($Key -eq "version") -or ($Key -eq "debug")){
							$Key = $Key + "2"
							}							
							$Value = $_.Value
								switch ($value){
									'Unset, ([boolean])'{
									#Write-host "TEST1" -foreground green -background yellow
									$ParameterMandatory = "`t" + '[Parameter(Mandatory=$true)]'
									$Global:Stream.WriteLine($ParameterMandatory)
									$ParameterLine = "`t" + '[boolean]$'+ $Key + ','
									$Global:Stream.WriteLine($ParameterLine)
									}
									'Unset, ([boolean], optional)'{
									#Write-host "TEST2" -foreground green -background yellow
									$ParameterLine = "`t" + '[boolean]$'+ $Key + ','
									$Global:Stream.WriteLine($ParameterLine)
									}
									'Unset, ([long])'{
									#Write-host "TEST3" -foreground green -background yellow
									$ParameterMandatory = "`t" + '[Parameter(Mandatory=$true)]'
									$Global:Stream.WriteLine($ParameterMandatory)								
									$ParameterLine = "`t" + '[long]$'+ $Key + ','
									$Global:Stream.WriteLine($ParameterLine)
									}
									'Unset, ([long], optional)'{
									#Write-host "TEST4" -foreground green -background yellow
									$ParameterLine = "`t" + '[long]$'+ $Key + ','
									$Global:Stream.WriteLine($ParameterLine)
									}
									'Unset, ([string[]])'{
									#Write-host "TEST5" -foreground green -background yellow
									$ParameterMandatory = "`t" + '[Parameter(Mandatory=$true)]'
									$Global:Stream.WriteLine($ParameterMandatory)								
									$ParameterLine = "`t" + '[string[]]$'+ $Key + ','
									$Global:Stream.WriteLine($ParameterLine)
									}
									'Unset, ([string[]], optional)'{
									#Write-host "TEST6" -foreground green -background yellow
									$ParameterLine = "`t" + '[string[]]$'+ $Key + ','
									$Global:Stream.WriteLine($ParameterLine)
									}
									'Unset, ([string])'{
									#Write-host "TEST7" -foreground green -background yellow
									$ParameterMandatory = "`t" + '[Parameter(Mandatory=$true)]'
									$Global:Stream.WriteLine($ParameterMandatory)								
									$ParameterLine = "`t" + '[string]$'+ $Key + ','
									$Global:Stream.WriteLine($ParameterLine)
									}
									'Unset, ([string], optional)'{
									#Write-host "TEST8" -foreground green -background yellow
									$ParameterLine = "`t" + '[string]$'+ $Key + ','
									$Global:Stream.WriteLine($ParameterLine)
									}
								}							
							}
					}					
					$NewOutputWithTab = "`t" +'[Parameter(Mandatory=$true,ValueFromPipeline=$true)]'
					$Global:Stream.WriteLine($NewOutputWithTab)
					$NewOutputWithTab = "`t" +'[VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl[]]$VMhost'
					$Global:Stream.WriteLine($NewOutputWithTab)
					$NewOutputWithTab = "`t" + ')'
					$Global:Stream.WriteLine($NewOutputWithTab)

				#////Process section
				$NewOutputWithTab = "`t" +'process{'
				$Global:Stream.WriteLine($NewOutputWithTab)
					$NewOutputWithTab = "`t" + 'foreach($SelectedVMHost in $VMhost){' #Handle case of using many host as parameters and not as pipe
					$Global:Stream.WriteLine("$NewOutputWithTab")

								$NewOutputWithTab = "`t`t" + 'Try{'
								$Global:Stream.WriteLine("$NewOutputWithTab")
																				
								$NewOutputWithTab = "`t`t" + '$esxcliv2 = Get-EsxCLI -VMHost $SelectedVMHost -V2'
								$Global:Stream.WriteLine("$NewOutputWithTab")
								
								$NewOutputWithTab = "`t`t" + '}'
								$Global:Stream.WriteLine("$NewOutputWithTab")
								$NewOutputWithTab = "`t`t" + 'Catch{'
								$Global:Stream.WriteLine("$NewOutputWithTab")								
								$NewOutputWithTab = "`t`t" + 'Write-error "Not able to get-esxcli for $(($SelectedVMHost).name)"'
								$Global:Stream.WriteLine("$NewOutputWithTab")
								$NewOutputWithTab = "`t`t" + 'continue'
								$Global:Stream.WriteLine("$NewOutputWithTab")											
								$NewOutputWithTab = "`t`t" + '}'
								$Global:Stream.WriteLine("$NewOutputWithTab")	
								
								$Global:Stream.WriteLine("")	
								
								$NewOutputWithTab = "`t`t" + 'if($esxcliv2.' + ($ToAnalyse.Fullname).replace("vim.EsxCLI.", "") + '.' + $MethodName + '){'
								$Global:Stream.WriteLine("$NewOutputWithTab")								
								$NewOutputWithTab = "`t`t" + '#Namespace available for this ESXi host'
								$Global:Stream.WriteLine("$NewOutputWithTab")									
								$NewOutputWithTab = "`t`t" + '}'
								$Global:Stream.WriteLine("$NewOutputWithTab")									
								$NewOutputWithTab = "`t`t" + 'Else{'
								$Global:Stream.WriteLine("$NewOutputWithTab")			
								$NewOutputWithTab = "`t`t" + 'Write-error "The namespace esxcliv2.' + ($ToAnalyse.Fullname).replace("vim.EsxCLI.", "") + '.' + $MethodName  + ' is not available for $(($SelectedVMHost).name)"'
								$Global:Stream.WriteLine("$NewOutputWithTab")
								$NewOutputWithTab = "`t`t" + 'continue'
								$Global:Stream.WriteLine("$NewOutputWithTab")	
								$NewOutputWithTab = "`t`t" + '}'
								$Global:Stream.WriteLine("$NewOutputWithTab")
								
								$Global:Stream.WriteLine("")	
								
								#Two scenario below, some parameters have been identified or none
								if($ToAnalyse.$MethodName | gm | where {$_.Name -eq 'CreateArgs'}){
								
								
									$NewOutputWithTab = "`t`t`t" +  'if($esxcliv2.' + ($ToAnalyse.Fullname).replace("vim.EsxCLI.", "") + '.' + $MethodName + ' | gm | where {$_.Name -eq ''CreateArgs''}){'
									$Global:Stream.WriteLine("$NewOutputWithTab")
									$NewOutputWithTab = "`t`t`t" +  '#To anticipate scenario with commands that didn''t have any parameters in a previous build'
									$Global:Stream.WriteLine("$NewOutputWithTab")	
									$NewOutputWithTab = "`t`t`t" +  '#More details about this challenge in the blog'
									$Global:Stream.WriteLine("$NewOutputWithTab")	

										#/// Create the hashtable
										$NewOutputWithTab = "`t`t`t" + '$HashTable = $esxcliv2.' + ($ToAnalyse.Fullname).replace("vim.EsxCLI.", "") + '.' + $MethodName	+ '.CreateArgs()'
										$Global:Stream.WriteLine("$NewOutputWithTab")
										
										#$NewOutputWithTab = "`t`t`t" + '$CheckAllParameters = $true'
										#$Global:Stream.WriteLine("$NewOutputWithTab")
										
										#/// Check if any parameters have been used to call the function
										#If it is the case, update the relevant item in the hashtable
										#Moreover if a parameter IS NOT in the hashtable, throw an error.
										#If someone was planning to use a parameter, better to not execute the command than executing it without taking it into account
										#Didn't manage to store the enumarator in a variable previously to reuse it here
										if($ToAnalyse.$MethodName | gm | where {$_.Name -eq 'CreateArgs'}){
											$Args = $ToAnalyse.$MethodName.CreateArgs()
											$Args.getEnumerator() | foreach-object{
											$Key = $_.Key
											$OriginalKey = $Key
												#Fix an issue with some variable that have already a meaning in PowerShell.										
												If(($Key -eq "host") -or ($Key -eq "profile") -or ($Key -eq "version") -or ($Key -eq "debug")){
												$Key = $Key + "2"
												}											
											$NewOutputWithTab = "`t`t`t`t" + 'if($PSBoundParameters.ContainsKey(''' + $Key + ''')){'
											$Global:Stream.WriteLine("$NewOutputWithTab")
											
												#For each parameter we check that it is available in the hashtable for this build and we update the value accordingly											
												$NewOutputWithTab = "`t`t`t`t`t" + 'if($HashTable.containskey('''+ $OriginalKey + ''')){'
												$Global:Stream.WriteLine("$NewOutputWithTab")										

													$NewOutputWithTab = "`t`t`t`t`t`t" + '$HashTable.' + $OriginalKey + ' = $'  + $Key
													$Global:Stream.WriteLine("$NewOutputWithTab")
												
												$NewOutputWithTab = "`t`t`t`t`t" + '}'
												$Global:Stream.WriteLine("$NewOutputWithTab")
												
												#If it nos the case, an error is generated
												$NewOutputWithTab = "`t`t`t`t`t" + 'Else{'
												$Global:Stream.WriteLine("$NewOutputWithTab")
												#$NewOutputWithTab = "`t`t`t`t`t`t" + '$CheckAllParameters = $False'
												#$Global:Stream.WriteLine("$NewOutputWithTab")										
												$NewOutputWithTab = "`t`t`t`t`t`t"  + 'Write-error "The parameter ' + $Key + ' is not available for $(($SelectedVMHost).name)"'
												$Global:Stream.WriteLine("$NewOutputWithTab")
												$NewOutputWithTab = "`t`t`t`t`t`t"  + 'continue'
												$Global:Stream.WriteLine("$NewOutputWithTab")												
												$NewOutputWithTab = "`t`t`t`t`t" + '}'
												$Global:Stream.WriteLine("$NewOutputWithTab")
																																	
											$NewOutputWithTab = "`t`t`t`t" + '}'
											$Global:Stream.WriteLine("$NewOutputWithTab")									
											}
											
										$Global:Stream.WriteLine("")	
										
										#$FullCommand = "`t`t`t`t" + 'if($CheckAllParameters){'
										#$Global:Stream.WriteLine($FullCommand)												
											
										$FullCommand = "`t`t`t`t`t" + '$esxcliv2.' + ($ToAnalyse.Fullname).replace("vim.EsxCLI.", "") + '.' + $MethodName + '.invoke($hashtable)'
										$Global:Stream.WriteLine($FullCommand)	
										
										#$FullCommand = "`t`t`t`t" + '}'
										#$Global:Stream.WriteLine($FullCommand)											
										}
										
									
									$NewOutputWithTab  = "`t`t`t" + '}'
									$Global:Stream.WriteLine("$NewOutputWithTab")
									
									#Scenario where we will work with a previous build of ESXi that don't have any parameters for this command
									$NewOutputWithTab = "`t`t`t" + 'Else{'
									$Global:Stream.WriteLine("$NewOutputWithTab")
									
										#Every parameter will not be compatible with this build
										$AllParameters = "Start"
										if($ToAnalyse.$MethodName | gm | where {$_.Name -eq 'CreateArgs'}){									
												$Args = $ToAnalyse.$MethodName.CreateArgs()
												$Args.getEnumerator() | foreach-object{
												$Key = $_.Key
													#Fix an issue with some variable that have already a meaning in PowerShell.										
													If(($Key -eq "host") -or ($Key -eq "profile") -or ($Key -eq "version") -or ($Key -eq "debug")){
													$Key = $Key + "2"
													}
												$AllParameters = $AllParameters + ' -or $PSBoundParameters.ContainsKey(''' + $Key + ''')'		

												}
												$AllParameters = $AllParameters.replace('Start -or ','')
												$NewOutputWithTab = "`t`t`t`t" + 'if(' + $AllParameters + '){'
												$Global:Stream.WriteLine("$NewOutputWithTab")
												
												$NewOutputWithTab = "`t`t`t`t`t"  + 'Write-error "No parameters are available for $(($SelectedVMHost).name)"'
												$Global:Stream.WriteLine("$NewOutputWithTab")	
												
												$NewOutputWithTab = "`t`t`t`t" + '}'
												$Global:Stream.WriteLine("$NewOutputWithTab")											
										}			
									
									
									
									$NewOutputWithTab = "`t`t`t`t" + 'Else{'
									$Global:Stream.WriteLine("$NewOutputWithTab")																		
									$FullCommand = "`t`t`t`t`t" + '$esxcliv2.' + ($ToAnalyse.Fullname).replace("vim.EsxCLI.", "") + '.' + $MethodName + '.invoke()'
									$Global:Stream.WriteLine($FullCommand)	
									$NewOutputWithTab = "`t`t`t`t" + '}'
									$Global:Stream.WriteLine("$NewOutputWithTab")	

									
									$NewOutputWithTab = "`t`t`t" + '}'

									$Global:Stream.WriteLine("$NewOutputWithTab")
							}
							Else{
									$FullCommand = "`t`t`t" + '$esxcliv2.' + ($ToAnalyse.Fullname).replace("vim.EsxCLI.", "") + '.' + $MethodName + '.invoke()'
									$Global:Stream.WriteLine($FullCommand)								
							}
														
							
					$NewOutputWithTab = "`t`t" + '}' #End of the foreach($SelectedVMHost -in $VMhost)
					$Global:Stream.WriteLine("$NewOutputWithTab")
				
				$NewOutputWithTab = "`t" +'}'
				$stream.WriteLine($NewOutputWithTab) #End of process				
				$Global:Stream.WriteLine('}')#End of the function
				$Global:Stream.WriteLine('')
				}				
			#/////End of Identify all methods associated to this namespace
			
			#/////Go through all child elements if any				
			#However it is necessary to isolate a bug with EsxCLI.vsan
			#Fix bug for vsan path. It is possible to use codeproperty as a workaround here because there are no methods defined at this level.		
			if(($FullNameSpace -eq 'EsxCLI.vsan')){
			#Write-host "In the special case" -foreground blue
				$ToAnalyse | Get-Member -MemberType CodeProperty | foreach-object{
				$CodePropertyName = $_.Name
				new-PowerCLI_ESXCLIv2_Function -ToAnalyse $ToAnalyse.$CodePropertyName
				}
			}			
			Else{
					$ToAnalyse.childelements | foreach-object{				
						$ChildElementName = $_.name
						#Write-host "ChildElementName $ChildElementName"
						new-PowerCLI_ESXCLIv2_Function -ToAnalyse $ToAnalyse.$ChildElementName	
					}	
				
			}
			#/////End of Go through all child elements if any	
			
		}
	
	}
}

#How to use it
#$MyHost = get-vmhost "10.0.0.101"
#$esxcli = get-esxcli -v2 -vmhost $MyHost

#$Global:Stream.close()
#$Global:Stream = [System.IO.StreamWriter] "C:\temp\Get-EsxCLI_on_steroids_21-07-2016.ps1"
#new-PowerCLI_ESXCLIv2_Function -ToAnalyse $esxcli
#$Global:Stream.close()