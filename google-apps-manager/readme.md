# Guide to Google Apps Manager

## Rationale

As our chapter count grows, do does the size of our [Google Workspace](https://workspace.google.com). With active accounts soon to reach 200, it's becoming increasingly important to automate account creation, group memberships, profile information, email signatures, etc.

[![Chapter map](../assets/chapter-map.png)](https://studenten-bilden-schueler.de/standorte)

Google Apps Manager (GAM) is a powerful command line utility with comprehensive batch operations for all manner of Google Workspace functionality. It's available at <https://github.com/jay0lee/gam>.

## Installaltion

Open a terminal and run

```sh
bash <(curl -s -S -L https://git.io/install-gam)
```

`gam` will guide you through a somewhat lengthy authentication and authorization process. For guidance, consult the **[GAM docs](https://github.com/jay0lee/GAM/wiki)** (very detailed and comprehensive).

## Example 1: Create Accounts for new Chapter

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

## Example 2: Set Profile Pictures for all Users in Group

To set the profile picture for all users in a group, use

```sh
gam group (schueler|studenten|kommunikation) update photo gmail/images/sbs-owls.png
```

## Example 3: Gmail Signatures

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

## Example 4: Groups

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
