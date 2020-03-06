# giipAgentUIP

## Introduce

This is giipAgent made by UiPath xaml file.
It needs to make a acount to giip service and git clone giipAgentWin as below

```sh
git clone https://github.com/LowyShin/giipAgentWin.git
```

### Directory Structure

* /ProjectRoot/
  * giipAgentUIP/
    * This repository
    * `git clone https://github.com/LowyShin/giipAgentUIP.git`
  * giipAgentWin/
    * giip Control Base Scripts for windows
    * `git clone https://github.com/LowyShin/giipAgentUIP.git`

## Startup

* Install git for windows
  * https://gitforwindows.org/
  * It need to sync repository on working giipAgentUIP
* Clone giipAgent for Windows
* Clone this repository. It need to same level of directory with giipAgent
* Browse to giip web site
  * https://giipasp.azurewebsites.net/
* Make account and login.
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

## We want contributors

You may change source you want.

If you want any question, mail to me. 

https://github.com/LowyShin/giip/wiki/Contact-Us

## Links

* giip
  * https://github.com/LowyShin/giip/wiki
