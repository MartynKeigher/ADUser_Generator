# AD User Generator

Hi! The purpose of this repo is to generate a large amount of AD Users for testing. Feel free to 'fork off' and do and you please with this code! PR's are also very welcomed too, of course!! 


## How to use
```powershell
iex (new-object Net.WebClient).DownloadString('https://raw.githubusercontent.com/MartynKeigher/ADUser_Generator/main/ADUserGenerator.ps1'); ADUser-Generation -Company 'MyCompany'
```

## Available Parameters
- Company : (Mandatory) This value must be provided!
- OU : If one is not specified, the default value used is 'Staff'.
- AreaCode : If one is not specified, the default value used is '727'.
- UserCount : If one is not specified, the default value used is 15.
	- Min value: 1; Max value: 1500
	- I limited this to 1500, as this was a suitable number for my tests. There is no funcional reason why this could not be made higher if you needed it to be? *- Let me know!?*

## Random Names
Retrieved from files in this repo, I'll update them from time to time, but not making any promises ;p

 - FirstNames.csv
 - LastNames.csv


*Enjoy!! 

://mk*
