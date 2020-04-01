# giipAgentUIP

## Introduce

If you want remote control your PC or Windows servers by UiPath, try it!

You can execute custom xaml file by mobile phone, and managing xaml files or wsf(Windows Script), vbs, ps1(Power shell), bat, py, rb, etc.

If you using giipAgentLinux, you can handling linux also!

This is giipAgent made by UiPath xaml file.

### Directory Structure

* /ProjectRoot/
  * giipAgent.cfg
    * Copy and set your secret key from giipAgentUIP/
    * See below Startup section
  * giipAgentUIP/
    * This repository
    * `git clone https://github.com/LowyShin/giipAgentUIP.git`
  * giipAgentWin/
    * giipAgent for windows
    * It supported ahk(Auto hot key), wsf(WScript)
    * `git clone https://github.com/LowyShin/giipAgentUIP.git`

## Related application

If you already installed, then skip this phase.

* Install git for windows
  * https://gitforwindows.org/
  * It need to sync repository on working giipAgentUIP
* Install UiPath
  * https://uipath.com

## Installation and configuration giipAgentUIP

* Clone giipAgent for Windows
  * `git clone https://github.com/LowyShin/giipAgentWin.git`
* Clone this repository. It need to same level of directory with giipAgent
  * `git clone https://github.com/LowyShin/giipAgentUIP.git`
* Copy giipAgent.cfg to parent directory
  * `copy giipAgent.cfg ..\`
  * Change your information
    * sk : your Secret key. you may see [Service management](https://giipasp.azurewebsites.net/view/SMAHTML/ServiceList.asp) or [Logical Server Detail Page](https://giipasp.azurewebsites.net/view/SMAHTML/LSvrList.asp).
    * lssn : Your machine's lssn for giip logical server management. If you are not add logical server yet, you may keep "0". It will be generated a Logical Server on your service automatically.

Well, Done! Run giipAgentUIP on UiPath Studio!

You may run background giipAgentUIP. Search google, because it is not offical information of UiPath.

## Control giipAgentUIP

* Browse to giip web site
  * https://giipasp.azurewebsites.net/
* Login giip.
  * If you have not account, create it. 
* Add a new script on [giip Automation](https://giipasp.azurewebsites.net/view/SMAHTML/ScrRepo.asp)
* Click to detail of your script, set a script to machine you have. 
  * if you don't know how to add, see official [giip automation manual](https://github.com/LowyShin/giip/wiki/Automation)

It's done! You are just waiting!

note: You may run any time click `Run icon`

## For a new giip user

If you are first time on giip, you need register environment.

* Create a Customer
  * Left Menu > Environment > Customers
  * Click [Add Customer](https://giipasp.azurewebsites.net/view/SMAHTML/CustomerAdd.asp) Button 
* Create a Service
  * Left Menu > Environment > Services
  * Click [Add Service](https://giipasp.azurewebsites.net/view/SMAHTML/ServiceAdd.asp) Button 
* Generate Secret Key
  * Left Menu > Environment > Services
  * Click [Add Key] of your service. If you done, no more need action.
  * Copy your Secret Key
* Update giipAgent.cnf and copy to parent directory(ProjectRoot)
  * Paste your Secret Key to below
  * `at = "<set secret key of your service>"`
* Execute giipAgent.wsf on giipAgentWin directory
  * If it done, you can see changed lssn is 0 to other number on giipAgent.cnf

Well done! Ready to execute giipAgentUIP

## Launch UiPath Application

Execute Main.xaml on UiPath Studio.

If you doesn't any error, you may execute MainSM.xaml for loop work.

You may registrate to Windows scheduler by batch every 1 min. If you want, use Main.xaml
If you just running simple, use MainSM.xaml

## Execute Custom Xaml file on giipAgentUIP

* Add script on giip Script Repository
  * Left Menu > Automation > Script Repository
  * Click [Add Script](https://giipaspstg02.azurewebsites.net/view/SMAHTML/ScrPut.asp) button.
  * Put Script Name you want
  * Select Script Type to `json`
  * Write JSON data
  ```json
  {
  "Execxaml" : "LowyAI\\MainOTM.xaml"
  }
  ```
  * Save and exit
* Set to your PC this script
  * Browse detail page of this script
  * Click to check your server on `Add Queue` Section
  * Set interval (Minute)
  * If you want onetime, `No` to Repeat
  * If you want just add, `No` to Activate
  * Click [Apply Queue] Button
    * If already added on checked server, skipped this action.
    * If you want modify, delete and add this action.

Well done!!

If you have many xaml files, you can deploy you want any PCs you have!!

## Known bugs

* Broken character with Japanese on wsf file.
  * UiPath forced UTF-8, whenever save to ANSI or UTF-8 the japanese code, it all broken. 

## We want contributors

You may change source you want.

If you want any question, mail to me. 

https://github.com/LowyShin/giip/wiki/Contact-Us

## Links

* giip
  * https://github.com/LowyShin/giip/wiki
* giipAgent for Windows
  * https://github.com/LowyShin/giipAgentWin
* giipAgent for Linux
  * https://github.com/LowyShin/giipAgentLinux
* giipAgent for UiPath
  * https://github.com/LowyShin/giipAgentUIP

* UiPath official
  * https://uipath.com

* UiPath Personal Knowledgebase
  * https://github.com/LowyShin/lwrpa-uip-study-ja/wiki

## Update History

* 20200309 Lowy
  * Simple excetion.
    * Just notify to Log message, and continue.
  * Minimize cmd window when execution.
    * Launch `CMD.exe` Process and add Params `"/c start /min giipExec.bat ^& exit"`
  * Integrate to giipAgentUIP. No more download giipAgentWin
  * Add interval variables. You may change execute interval at giipAgent.cfg
