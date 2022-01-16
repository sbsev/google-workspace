# GAM Guide

## Rationale

As our chapter count grows, so does the size of our [Google Workspace](https://workspace.google.com). With active accounts soon to reach 200, it's becoming increasingly important to automate account creation, group memberships, profile information, email signatures, etc.

[![Chapter map](assets/chapter-map.png)](https://studenten-bilden-schueler.de/standorte)

GAM is a powerful command line interface (CLI) with comprehensive batch operations for all manner of Google Workspace functionality. It's available at <https://github.com/jay0lee/gam>.

## Installation

The [easiest installation option](https://github.com/jay0lee/GAM/pull/1417) is probably though `pip`. Open a terminal and run

```sh
pip install -U git+https://github.com/jay0lee/GAM.git#subdirectory=src
```

Once installed, invoke `gam` which will guide you through a somewhat lengthy authentication and authorization process. For guidance, consult the **[GAM docs](https://github.com/jay0lee/GAM/wiki)** (very detailed and comprehensive).

You might get an installation error if [swig](https://en.wikipedia.org/wiki/SWIG) and / or pcsclite ("winscard.h", for smartcard support) are not installed on your system. In that case, you must install them first.

```sh
apt-get install swig pcsc-lite # on Ubuntu
pacman -S swig pcsclite # on Arch Linux
brew install swig pcsc-lite # on macOS
```

### Update

To update an already installed version of GAM, run the same command

```sh
pip install -U git+https://github.com/jay0lee/GAM.git#subdirectory=src
```

and simply press `n` when GAM asks

> Can you run a full browser on this machine? (usually Y for MacOS, N for Linux if you SSH into this machine) n

followed by `n` again for

> GAM is now installed. Are you ready to set up a Google API project for GAM? (yes or no) n

You may need to delete the `nobrowser.txt` which `gam` then creates in its install directory. Run `which gam` to see where the binary is (will also be the `nobrowser.txt` location when not installed with `pip`) or for `pip`-installed `gam`:

```py
$ python
>>> import gam
>>> gam.__file__
'~/.venv/py310/lib/python3.10/site-packages/gam/__init__.py'
```

## Uninstall

```sh
pip uninstall -y GAM-for-Google-Workspace
# to get rid of all the Google Oauth packages
pip list | grep google | xargs pip uninstall -y
# delete gam created auth files polluting site-packages (only necessary when pip-installed)
rm ~/.venv/py310/lib/python3.10/site-packages/{oauth2.txt,client_secrets.json,oauth2service.json}
```

## Example 1: Create Accounts for new Chapter

The commands below create the accounts for all 3 divisions of a new chapter (Schüler, Studenten, Kommunikation). It also

- sets their profile picture to our two-owls logo,
- adds them each to their respective division groups (schueler|studenten|kommunikation@studenten-bilden-schueler.de) which automatically adds them to standorte@studenten-bilden-schueler and gives them access to the Shared Google Drive for chapters (Drive für Standorte), and finally
- [sets their Gmail signatures](https://github.com/jay0lee/GAM/wiki/ExamplesEmailSettings#setting-a-signature) according to our chapter template in [gmail/signatures/chapters.html](gmail/signatures/chapters.html)

A new chapter is then fully setup, at least in terms of our Google Workspace. The main remaining task is to setup their Airtable base.

```sh
city=kiel
City=Kiel
for division in schueler:Schüler studenten:Studenten info:Kommunikation
do
  firstname=${division#*:}
  division=${division%:*}

  gam create user $division.$city \
    firstname $firstname \
    lastname $City \
    password Abcdef1234 \
    changepassword on \
    org /Standorte \
    recoveryemail it@studenten-bilden-schueler.de

  gam user $division.$city update photo gmail/images/sbs-owls.png
  gam update group $division add member $division.$city
  gam user $division.$city signature file gmail/signatures/chapters.html html replace firstName $firstname replace lastName $City
done

# division info needs special treatment
gam update group kommunikation add member info.$city
gam update group info remove member info.$city
```

For setting profile picture and signature after the fact:

```sh
for division in schueler:Schüler studenten:Studenten info:Kommunikation
do
  firstname=${division#*:}
  division=${division%:*}

  gam user $division.bremen update photo gmail/images/sbs-owls.png
  gam user $division.bremen signature file gmail/signatures/chapters.html html replace firstName $firstname replace lastName Bremen
done
```

[To suspend all accounts for a chapter](https://github.com/jay0lee/GAM/wiki/GAM3DirectoryCommands#update-and-rename-a-user):

```sh
for division in schueler:Schüler studenten:Studenten info:Kommunikation
do
  firstname=${division#*:}
  division=${division%:*}

  gam update user $division.bayreuth suspended (on|off)
done
```

[If you made a mistake, you can fix it with](https://github.com/jay0lee/GAM/wiki/GAM3DirectoryCommands#update-and-rename-a-user):

```sh
gam update user <email address>
 [firstname <First Name>] [lastname <Last Name>]
 [password <Password>]
 [username <New Username>]
 [email <New Email>]
 [gal on|off] [suspended on|off] [archived on|off]
 [sha] [md5] [crypt] [nohash]
 [changepassword on|off] [org <Org Name>]
 [recoveryemail <email> [recoveryphone <phone>]
```

## Example 2: Create account for new board member

```sh
login=max.mustermann
firstname=Max
lastname=Mustermann
gam create user $login \
  firstname $firstname \
  lastname $lastname \
  password Abcdef1234 \
  changepassword on \
  org /Bundesvorstand \
  recoveryemail it@studenten-bilden-schueler.de

gam user $login signature file gmail/signatures/board.html html replace firstName $firstname replace lastName $lastname
# set initial profile picture to owl logo just so its not empty
gam user $login update photo gmail/images/sbs-owls.png
gam update group bundesvorstand add member $login
gam update group <some other resort like finanzen,it,recht,presse,...> add member $login
```

## Example 3: Set Profile Pictures for all Users in Group

To set the profile picture for all users in a group, use

```sh
gam group (schueler|studenten|kommunikation) update photo gmail/images/sbs-owls.png
```

## Example 4: Gmail Signatures

[To retrieve a user's current email signature](https://github.com/jay0lee/GAM/wiki/ExamplesEmailSettings#retrieving-a-signature)

```sh
gam user info.oldenburg show signature
```

[To retrieve signatures from all users in an organizational unit](https://github.com/jay0lee/GAM/wiki/ExamplesEmailSettings#retrieving-a-signature) and pipe them to a file, use

```sh
gam ou /Bundesvorstand show signature > tmp.html
```

To update a board member's signature, use

```sh
gam user janosh.riebesell signature file gmail/signatures/board.html html replace firstName Janosh replace lastName Riebesell replace department Bundesvorstand replace jobtitle IT
```

To get all users in an organizational unit, use

```sh
gam print users fields query "orgUnitPath='/Bundesvorstand'"
```

Quotes around org unit name are only necessary if the name contains spaces.

To query specific fields of users in a given org unit and pipe them to a file, use

```sh
gam print users fields name,organizations query "orgUnitPath='/Bundesvorstand'" > tmp.csv
```

To update a user's department and org title, use

```sh
gam update user iwo.hasenkamp organization title "Standortbetreuung" department "Unterstützer des Bundesvorstands" primary
```

To set the signature for all board members, use

```sh
# tail -n +2 skips the column header (primaryEmail) returned by gam print
for email in $(gam print users query "orgUnitPath='/Bundesvorstand'" | tail -n +2)
do
  userInfo=$(gam info user $email)
  firstname=`echo ${userInfo/*First Name: /} | head -1`
  lastname=`echo ${userInfo/*Last Name: /} | head -1`
  department=`echo ${userInfo/*department: /} | head -1`
  jobtitle=`echo ${userInfo/* title: /} | head -1`
  echo "Replacement values: firstname=$firstname, lastname=$lastname, department=$department, jobtitle=$jobtitle"
  gam user $email signature file gmail/signatures/board.html html replace firstName $firstname replace lastName $lastname replace department $department replace jobtitle $jobtitle
  echo
done
```

To update the signature of a single board member, use

```sh
email=janosh.riebesell
userInfo=$(gam info user $email)
firstname=`echo ${userInfo/*First Name: /} | head -1`
lastname=`echo ${userInfo/*Last Name: /} | head -1`
department=`echo ${userInfo/*department: /} | head -1`
jobtitle=`echo ${userInfo/* title: /} | head -1`
echo "Replacement values: firstname=$firstname, lastname=$lastname, department=$department, jobtitle=$jobtitle"
gam user $email signature file gmail/signatures/board.html html replace firstName $firstname replace lastName $lastname replace department $department replace jobtitle $jobtitle
```

[To retrieve a user's current email signature](https://github.com/jay0lee/GAM/wiki/ExamplesEmailSettings#retrieving-a-signature), use

```sh
gam user janosh.riebesell show signature
```

## Example 5: Groups

[To create a new group, use](https://github.com/jay0lee/GAM/wiki/GAM3DirectoryCommands#create-a-group)

```sh
gam create group bremen name Bremen description "Verteiler zur Koordination der Standortgründung in Bremen"
```

[To add members, owners or managers to a group](https://github.com/jay0lee/GAM/wiki/GAM3DirectoryCommands#add-members-managers-owners-to-a-group), you can specify a single user, a group of users, an org of users or a file with users (one per line), use

```sh
gam update group bremen add member foo@bar.baz1 foo@bar.baz2 foo@bar.baz3 add manager christoph.bischoff
```

[To delete a group, use](https://github.com/jay0lee/GAM/wiki/GAM3DirectoryCommands#delete-a-group)

```sh
gam delete group bremen
```

To delete all accounts for a chapter, use

```sh
city=bielefeld
for division in info schueler studenten; do
  gam delete user $division."$city"
done
```

To check which [OAuth scopes](https://wikipedia.org/wiki/OAuth) are currently authorized, run `gam oauth info`:

```txt
OAuth File: /Users/janosh/Repos/sbs-google-workspace/gam/oauth2.txt
Client ID: 436676890592-u137vkq3e3c42udj7egsoln4soci6v9j.apps.googleusercontent.com
Scopes (11)
  https://googleapis.com/auth/admin.directory.customer
  https://googleapis.com/auth/admin.directory.domain
  https://googleapis.com/auth/admin.directory.group
  https://googleapis.com/auth/admin.directory.orgunit
  https://googleapis.com/auth/admin.directory.rolemanagement
  https://googleapis.com/auth/admin.directory.user
  https://googleapis.com/auth/admin.directory.user.security
  https://googleapis.com/auth/admin.directory.userschema
  https://googleapis.com/auth/apps.groups.settings
  https://googleapis.com/auth/userinfo.email
  openid
Google Workspace Admin: janosh.riebesell@studenten-bilden-schueler.de
Expires: 2021-08-27T21:27:08.695019
audience: 436676890592-u137vkq3e3c42udj7egsoln4soci6v9j.apps.googleusercontent.com
user_id: 111512315526918277780
verified_email: True
access_type: offline
```

`openid` seems to be added automatically. Additional scopes will be selected by default during setup and shouldn't hurt but aren't needed. Feel free to deselect for safety.

If getting errors like

> ERROR: [...] Client is unauthorized to retrieve access tokens using this method, or client not authorized for any of the scopes requested.

you may need to enable "Domain-wide Delegation" for the service account you're using on Google Cloud Platform > IAM & Admin > Service Accounts.
