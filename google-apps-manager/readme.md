# Guide to Google Apps Manager

## Rationale

As our chapter count grows, do does the size of our [Google Workspace](https://workspace.google.com). As the number of accounts has reached 200, it's becoming increasingly important to be able perform bulk operations for managing group memberships, profile information, email signatures, etc.

[![Chapter map](../assets/chapter-map.png)](https://studenten-bilden-schueler.de/standorte)

Google Apps Manager (GAM) is a powerful command line utility with comprehensive batch operations for all manner of Google Workspace functionality. It's available at <https://github.com/jay0lee/gam>. Install it by opening a terminal and running

```sh
bash <(curl -s -S -L https://git.io/install-gam)
```

`gam` will guide you through the authentication and authorization process.

## Usage Examples

### Add accounts to group

To add multiple (usually newly created) accounts to a group, use a CSV file containing all (and only) the emails to be added to the group in one column:

```sh
gam csv path/to/file.csv gam update group kommunikation add member user ~"Email Address [Required]"
```

![Bulk add accounts to group](../assets/bulk-add-accounts-to-group.png)

Or, directly on the command line without CSV:

```sh
gam update group kommunikation add member info.weimar info.hamburg info.bayreuth info.greifswald
gam update group schueler add member schueler.weimar schueler.hamburg schueler.bayreuth schueler.greifswald
gam update group studenten add member studenten.weimar studenten.hamburg studenten.bayreuth studenten.greifswald
```

### Set profile pictures

```sh
gam group (schueler|studenten|kommunikation) update photo path/to/image.png
```

![Bulk set profile picture](../assets/bulk-set-profile-picture.png)

## Helpful Links

- [GAM docs](https://github.com/jay0lee/GAM/wiki): very detailed and comprehensive
- [GAM commands](https://sites.google.com/jis.edu.bn/gam-commands): extensive list of usage examples
- [Google Drive](https://drive.google.com/drive/folders/1FfvgltvxH_fb1ee7efXcXgAZxO4HcBP4): Link to a folder with CSV files for bulk adding new users (requires authentication)

## Create Accounts for new Chapter

This script creates the accounts for all 3 divisions of a new chapter (Schüler, Studenten, Kommunikation). It also

- sets their profile picture to our two-owls logo,
- adds them each to their respective division groups (schueler|studenten|kommunikation@studenten-bilden-schueler.de) which automatically adds them to standorte@studenten-bilden-schueler and gives them access to the Shared Drive for chapters, and finally
- [sets their Gmail signatures](https://github.com/jay0lee/GAM/wiki/ExamplesEmailSettings#setting-a-signature) according to our chapter template in [gmail/signatures/chapters.html](gmail/signatures/chapters.html)

A new chapter is thus fully setup, at least in terms of our Google Workspace. The main remaining task is to setup their Airtable Base.

```sh
for division in schueler:Schüler studenten:Studenten info:Kommunikation
do
  firstname=${division#*:}
  division=${division%:*}

  gam create user $division.oldenburg \
    firstname $firstname \
    lastname Oldenburg \
    password Abcdef1234 \
    changepassword on \
    org /Standorte \
    recoveryemail it@studenten-bilden-schueler.de

  gam user $division.oldenburg update photo gmail/images/sbs-owls.png
  gam update group $division add member $division.oldenburg
  gam user $division.oldenburg signature file gmail/signatures/chapters.html html replace firstName $firstname replace lastName Oldenburg
done

# division info needs special treatment
gam update group kommunikation add member info.oldenburg
gam update group info remove member info.oldenburg
```

For setting group membership and profile picture after the fact:

```sh
for division in schueler:Schüler studenten:Studenten info:Kommunikation
do
  firstname=${division#*:}
  division=${division%:*}

  gam user $division.bayreuth update photo gmail/images/sbs-owls.png
  gam update user $division.bayreuth suspended on
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
