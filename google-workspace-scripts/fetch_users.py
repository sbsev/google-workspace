# %%
import os.path

import matplotlib.pyplot as plt
import pandas as pd
from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build

# %%
# If modifying these scopes, delete the file token.json.
SCOPES = ["https://www.googleapis.com/auth/admin.directory.user"]


creds = None
# The file token.json stores the user's access and refresh tokens, and is
# created automatically on initial authorization flow completion.
if os.path.exists("token.json"):
    creds = Credentials.from_authorized_user_file("token.json", SCOPES)
# If there are no (valid) credentials available, let the user log in.
if not creds:  # or not creds.valid:
    if creds and creds.expired and creds.refresh_token:
        creds.refresh(Request())
    else:
        flow = InstalledAppFlow.from_client_secrets_file("credentials.json", SCOPES)
        creds = flow.run_local_server(port=0)
    # Save the credentials for the next run
    with open("token.json", "w") as token:
        token.write(creds.to_json())

service = build("admin", "directory_v1", credentials=creds)


# %%
# Call the Admin SDK Directory API
print("Getting users in domain...")
results = (
    service.users()
    # orderBy=email, givenName, or familyName
    .list(customer="my_customer", maxResults=500, orderBy="email").execute()
)
(users := pd.DataFrame(results.get("users", [])))


# %%
users["lastLoginTime"] = users["lastLoginTime"].astype("datetime64")
users["creationTime"] = users["creationTime"].astype("datetime64")


# %%
users[users.agreedToTerms].groupby(
    users["lastLoginTime"].dt.month
).lastLoginTime.count().plot(kind="bar")

plt.title("Last login of Google Workspace accounts by month")
plt.savefig("last-login-by-month.pdf")


# %%
users[users.agreedToTerms].groupby(
    users["lastLoginTime"].dt.year
).lastLoginTime.count().plot(kind="bar")

plt.title("Last login of Google Workspace accounts by year")
plt.savefig("last-login-by-year.pdf")


# %%
users.groupby(users["creationTime"].dt.year).creationTime.count().plot(kind="bar")

plt.title("Creation of Google Workspace accounts by year")
plt.savefig("creation-by-year.pdf")


# %%
users.creationTime.sort_values().reset_index(drop=True).reset_index().plot(
    y="index", x="creationTime"
)
plt.title("Number of Google Workspace accounts over time")
plt.savefig("accounts-over-time.pdf")


# %%
def chapter_email_to_city_name(email: str) -> str:
    if not email.startswith(("studenten.", "schueler.", "info.")):
        return ""

    return email.split("@")[0].split(".")[-1]


users["city"] = users.primaryEmail.apply(chapter_email_to_city_name)


# %%
with open("city-founding-dates.md", "w") as file:
    users[users.city != ""].sort_values(by="creationTime")[
        ["city", "creationTime"]
    ].drop_duplicates("city").to_markdown(file)
