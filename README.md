# AD User Generator

Hi! The purpose of this repo is to generate a large amount of AD Users for testing. Feel free to 'fork off' and do as you please with this code! PR's are also very welcomed too, of course!! 


## How to use

On a Windows Domain Controller, or other server that has the ablity to Import the 'ActiveDirectory' module.

```powershell
iex (new-object Net.WebClient).DownloadString('https://raw.githubusercontent.com/MartynKeigher/ADUser_Generator/main/ADUserGenerator.ps1'); ADUser-Generation -Company 'MyCompany'
```

## Available Parameters
- **Company** : This value must be provided.
- **AreaCode** : *(for telephone number)* If one is not specified, the default value used is '727'.
- **OU** : If one is not specified, the default value used is 'Staff'.
- **UserCount** : If one is not specified, the default value used is 15.
	- Min value: 1; Max value: 1500
	- I limited this to 1500, as this was a suitable number for my tests. There is no functional reason why this could not be made higher if you needed it to be? *- Let me know how that works out for you!? Should be fine!*

## Random Names
Retrieved from files in this repo, I'll update them from time to time, but not making any promises ;p

 - FirstNames.csv
 - LastNames.csv

## ToDo
While the code works... it needs work! Here is my list of stuff I plan on adding to it...

 - Create a security group for each department
	 - then, add users to their dept's sec group.
 - Create a distribution group for each department
	 - then, add users to their dept's distro group.
 - Create a security group for each 'position' within each department
	 - then, add users based on position\dept to those groups.
 - Create a distribution group for each 'position' within each department
	 - then, add users based on position\dept to those groups.
 - Assign Managers to users within departments.
 - ~~Randomize the enabled\disabled state of the user accounts.~~
	 * ~~*Currently, they are all enabled.*~~

*Enjoy!!*

*://mk*
